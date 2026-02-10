const std = @import("std");
const vec = @import("vec.zig");
const Ray = @import("Ray.zig");

fn hit_sphere(ray: Ray, center: vec.Vec3, r: f64) f64 {
    const a = vec.lengthSquared(ray.dirn);
    const oc = center - ray.origin;
    const c = vec.lengthSquared(oc) - r * r;
    // const b = -2.0 * vec.dot(ray.dirn, oc);
    const h = vec.dot(ray.dirn, oc);
    // const d = b * b - 4.0 * a * c;
    const d = h * h - a * c;
    if (d < 0.0) return -1.0;
    // return (-b - std.math.sqrt(d)) / (2.0 * a);
    return (h - std.math.sqrt(d)) / a;
}

fn ray_color(r: Ray) vec.Color {
    const t = hit_sphere(r, .{0, 0, -1}, 0.5);
    if (t > 0.0) {
        const n = vec.unit(r.at(t) - vec.Vec3{0, 0, -1});
        return vec.scale(.{n[0] + 1.0, n[1] + 1.0, n[2] + 1.0}, 0.5);
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
            const pixel_color = ray_color(r);
            try stdout.print("{f}", .{ vec.ColorFmt{ .data = pixel_color } });
        }
    }

    std.debug.print("\rDone.                 \n", .{});
    try stdout.flush();
}
