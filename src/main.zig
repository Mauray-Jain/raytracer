const std = @import("std");
const vec = @import("vec.zig");
const Ray = @import("Ray.zig");
const obj = @import("objects.zig");

fn ray_color(r: Ray, world: []const obj.Hittable) vec.Color {
    if (obj.hitAll(world, r, 0.0, std.math.inf(f64))) |hit| {
        return vec.splat(0.5) * (hit.normal + vec.Vec3{1, 1, 1});
    }
    const unit = vec.unit(r.dirn);
    const a = 0.5 * (unit[1] + 1.0);
    return vec.scale(vec.Vec3{0.5, 0.7, 1.0}, a)
         + vec.scale(vec.Vec3{1.0, 1.0, 1.0}, 1.0 - a);
}

pub fn main() !void {
    var stdout_buf: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buf);
    const stdout = &stdout_writer.interface;

    // Image const
    const aspect_ratio = 16.0 / 9.0;
    const image_width = 400;
    const image_height = blk: {
        const a: comptime_int = @intFromFloat((image_width + 0.0) / aspect_ratio);
        if (a < 1) break :blk 1;
        break :blk a;
    };

    // Camera
    const focal_len = 1.0; // dist b/w camera_center and viewport
    const viewport_height = 2.0;
    const viewport_width = viewport_height * (image_width + 0.0) / (image_height + 0.0);
    const camera_center = vec.zero;

    // Viewport const
    const viewport_u = vec.Vec3{ viewport_width, 0, 0 };
    const viewport_v = vec.Vec3{ 0, -viewport_height, 0 };
    const pixel_delta_u = viewport_u / vec.splat(image_width);
    const pixel_delta_v = viewport_v / vec.splat(image_height);
    const viewport_upper_left = camera_center
                               - vec.Vec3{0.0, 0.0, focal_len}
                               - vec.scale(viewport_u, 0.5)
                               - vec.scale(viewport_v, 0.5);
    const pixel00_loc = viewport_upper_left + vec.scale(pixel_delta_u + pixel_delta_v, 0.5);

    // Objects
    const world = [_]obj.Hittable{
        obj.Hittable.init(&obj.Sphere{
            .center = vec.Vec3{0, 0, -1},
            .radius = 0.5,
        }),
        obj.Hittable.init(&obj.Sphere{
            .center = vec.Vec3{0, -100.5, -1},
            .radius = 100,
        }),
    };

    // Render
    try stdout.print("P3\n{d} {d}\n255\n", .{ image_width, image_height });

    for (0..image_height) |j| {
        std.debug.print("\rScanlines remaining: {d} ", .{ image_height - j });
        for (0..image_width) |i| {
            const pixel_center = pixel00_loc
                                 + vec.scale(pixel_delta_u, i)
                                 + vec.scale(pixel_delta_v, j);
            const ray_dirn = pixel_center - camera_center;
            const r = Ray{ .origin = camera_center, .dirn = ray_dirn };
            const pixel_color = ray_color(r, &world);
            try stdout.print("{f}", .{ vec.ColorFmt{ .data = pixel_color } });
        }
    }

    std.debug.print("\rDone.                 \n", .{});
    try stdout.flush();
}
