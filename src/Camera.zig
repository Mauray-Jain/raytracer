const std = @import("std");
const vec = @import("vec.zig");
const Ray = @import("Ray.zig");
const obj = @import("objects.zig");
const Interval = @import("Interval.zig");

aspect_ratio: f64   = 1.0,
image_width:  usize = 100,

const Self = @This();

const ImgConstants = struct {
    image_height:  usize,     // Rendered image height
    camera_center: vec.Vec3,  // Camera center
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
            const pixel_center = img.pixel00_loc
                                 + vec.scale(img.pixel_delta_u, i)
                                 + vec.scale(img.pixel_delta_v, j);
            const ray_dirn = pixel_center - img.camera_center;
            const r = Ray{ .origin = img.camera_center, .dirn = ray_dirn };
            const pixel_color = ray_colour(r, world);
            try stdout.print("{f}", .{ vec.ColorFmt{ .data = pixel_color } });
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
        .image_height  = image_height,
        .camera_center = camera_center,
        .pixel00_loc   = pixel00_loc,
        .pixel_delta_u = pixel_delta_u,
        .pixel_delta_v = pixel_delta_v,
    };
}

fn ray_colour(r: Ray, world: []const obj.Hittable) vec.Vec3 {
    if (obj.hitAll(world, r, .{ .min = 0.0 })) |hit| {
        return vec.splat(0.5) * (hit.normal + vec.Vec3{1, 1, 1});
    }
    const unit = vec.unit(r.dirn);
    const a = 0.5 * (unit[1] + 1.0);
    return vec.scale(vec.Vec3{0.5, 0.7, 1.0}, a)
         + vec.scale(vec.Vec3{1.0, 1.0, 1.0}, 1.0 - a);
}
