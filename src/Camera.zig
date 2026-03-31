const std = @import("std");
const vec = @import("vec.zig");
const Ray = @import("Ray.zig");
const obj = @import("objects.zig");
const utils = @import("utils.zig");
const Interval = @import("Interval.zig");

aspect_ratio:      f64   = 1.0,
image_width:       usize = 100,
samples_per_pixel: usize = 10,
max_depth:         i32   = 10,

const Self = @This();

const ImgConstants = struct {
    image_height:     usize,  // Rendered image height
    camera_center: vec.Vec3,  // Camera center
    pixel_sample_scale: f64,  // Color scale factor for a sum of pixel samples
    pixel00_loc:   vec.Vec3,  // Location of pixel 0, 0
    pixel_delta_u: vec.Vec3,  // Offset to pixel to the right
    pixel_delta_v: vec.Vec3,  // Offset to pixel below
};

pub fn render(self: Self, world: []const obj.Hittable) !void {
    var stdout_buf: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buf);
    const stdout = &stdout_writer.interface;

    const img = self.initialise();

    try stdout.print("P3\n{d} {d}\n255\n", .{ self.image_width, img.image_height });

    for (0..img.image_height) |j| {
        std.debug.print("\rScanlines remaining: {d} ", .{ img.image_height - j });
        for (0..self.image_width) |i| {
            var pixel_color = vec.zero;
            // antialiasing
            for (0..self.samples_per_pixel) |_| {
                const r = getRay(img, i, j);
                pixel_color += ray_colour(r, self.max_depth, world);
            }
            try stdout.print("{f}", .{ vec.ColorFmt{ .data = vec.scale(pixel_color, img.pixel_sample_scale) } });
        }
    }

    std.debug.print("\rDone.                 \n", .{});
    try stdout.flush();
}

fn initialise(self: Self) ImgConstants {
    const image_width_float: f64 = @floatFromInt(self.image_width);
    const image_height_float = image_width_float / self.aspect_ratio;
    const image_height: usize = @intFromFloat(image_height_float);

    // Camera
    const focal_len = 1.0; // dist b/w camera_center and viewport
    const viewport_height = 2.0;
    const viewport_width = viewport_height * image_width_float / image_height_float;
    const camera_center = vec.zero;

    // Viewport const
    const viewport_u = vec.Vec3{ viewport_width, 0, 0 };
    const viewport_v = vec.Vec3{ 0, -viewport_height, 0 };
    const pixel_delta_u = viewport_u / vec.splat(self.image_width);
    const pixel_delta_v = viewport_v / vec.splat(image_height);
    const viewport_upper_left = camera_center
                               - vec.Vec3{0.0, 0.0, focal_len}
                               - vec.scale(viewport_u, 0.5)
                               - vec.scale(viewport_v, 0.5);
    const pixel00_loc = viewport_upper_left + vec.scale(pixel_delta_u + pixel_delta_v, 0.5);

    return .{
        .image_height       = image_height,
        .camera_center      = camera_center,
        .pixel_sample_scale = 1.0 / @as(f64, @floatFromInt(self.samples_per_pixel)),
        .pixel00_loc        = pixel00_loc,
        .pixel_delta_u      = pixel_delta_u,
        .pixel_delta_v      = pixel_delta_v,
    };
}

fn getRay(img: ImgConstants, i: usize, j: usize) Ray {
    // Construct a camera ray originating from the origin and directed at randomly sampled point around the pixel location i, j.
    const ifloat = @as(f64, @floatFromInt(i));
    const jfloat = @as(f64, @floatFromInt(j));
    const offset = sampleSquare();
    const pixel_sample = img.pixel00_loc
                         + vec.scale(img.pixel_delta_u, ifloat + offset[0])
                         + vec.scale(img.pixel_delta_v, jfloat + offset[1]);
    return .{
        .origin = img.camera_center,
        .dirn   = pixel_sample - img.camera_center,
    };
}

fn sampleSquare() vec.Vec3 {
    return .{ utils.randomf64() - 0.5, utils.randomf64() - 0.5, 0 };
}

fn ray_colour(r: Ray, depth: i32, world: []const obj.Hittable) vec.Vec3 {
    if (depth <= 0) {
        return vec.zero;
    }

    if (obj.hitAll(world, r, .{ .min = 0.0 })) |hit| {
        // recursive call for reflection
        const dirn = vec.randomOnHemisphere(hit.normal);
        return vec.splat(0.5) * ray_colour(.{
            .origin = hit.p,
            .dirn = dirn
        }, depth - 1, world);
    }
    const unit = vec.unit(r.dirn);
    const a = 0.5 * (unit[1] + 1.0);
    return vec.scale(vec.Vec3{0.5, 0.7, 1.0}, a)
         + vec.scale(vec.Vec3{1.0, 1.0, 1.0}, 1.0 - a);
}
