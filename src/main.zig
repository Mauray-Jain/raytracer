const std = @import("std");
const vec = @import("vec.zig");
const Ray = @import("Ray.zig");

fn hit_sphere(ray: Ray, center: vec.Vec3, r: f64) bool {
    const a = vec.dot(ray.dirn, ray.dirn);
    const oc = center - ray.origin;
    const c = vec.dot(oc, oc) - r * r;
    const b = 2.0 * vec.dot(ray.dirn, oc);
    return b * b >= 4.0 * a * c;
}

fn ray_color(r: Ray) vec.Color {
    if (hit_sphere(r, .{0, 0, -1}, 0.5))
        return .{1, 0, 0};
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
    const image_width_float = @as(f64, @floatFromInt(image_width));
    const image_height_float = image_width_float / aspect_ratio;
    const image_height = if (image_height_float < 1) 1 else @as(u64, @intFromFloat(image_height_float));

    // Camera
    const focal_len = 1.0; // dist b/w camera_center and viewport
    const viewport_height = 2.0;
    const viewport_width = viewport_height * (image_width_float / image_height_float);
    const camera_center = vec.zero;

    // Viewport const
    const viewport_u = vec.Vec3{ viewport_width, 0, 0 };
    const viewport_v = vec.Vec3{ 0, -viewport_height, 0 };
    const pixel_delta_u = vec.scale(viewport_u, 1 / image_width_float);
    const pixel_delta_v = vec.scale(viewport_v, 1 / image_height_float);
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
                                 + vec.scale(pixel_delta_u, @floatFromInt(i))
                                 + vec.scale(pixel_delta_v, @floatFromInt(j));
            const ray_dirn = pixel_center - camera_center;
            const r = Ray{ .origin = camera_center, .dirn = ray_dirn };
            const pixel_color = ray_color(r);
            try stdout.print("{f}", .{ vec.ColorFmt{ .data = pixel_color } });
        }
    }

    std.debug.print("\rDone.                 \n", .{});
    try stdout.flush();
}
