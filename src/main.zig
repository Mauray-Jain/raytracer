const std = @import("std");
const vec = @import("vec.zig");
const obj = @import("objects.zig");
const Camera = @import("Camera.zig");

pub fn main() !void {
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

    // Camera
    const cam = Camera{
        .aspect_ratio = 16.0 / 9.0,
        .image_width = 400,
    };

    // Render
    try cam.render(&world);
}
