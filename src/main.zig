const std = @import("std");
const vec = @import("vec.zig");

pub fn main() !void {
    var stdout_buf: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buf);
    const stdout = &stdout_writer.interface;

    const image_width = 256;
    const image_height = 256;

    try stdout.print("P3\n{d} {d}\n255\n", .{ image_width, image_height });

    for (0..image_height) |j| {
        std.debug.print("\rScanlines remaining: {d} ", .{image_height - j});
        for (0..image_width) |i| {
            const pixel_color = vec.Vec3{
                @as(f64, @floatFromInt(i)) / (image_width - 1),
                @as(f64, @floatFromInt(j)) / (image_height - 1),
                0.0
            };
            try stdout.print("{f}", .{ vec.ColorFmt{ .data = pixel_color } });
        }
    }

    std.debug.print("\rDone.                 \n", .{});
    try stdout.flush();
}
