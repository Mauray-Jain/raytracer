const std = @import("std");

pub fn main() !void {
    var stdout_buf: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buf);
    const stdout = &stdout_writer.interface;

    const image_width = 256;
    const image_height = 256;

    try stdout.print(
    \\P3
    \\{d} {d}
    \\255
    \\
    , .{ image_width, image_height });

    for (0..image_height) |j| {
        for (0..image_width) |i| {
            const r = @as(f64, @floatFromInt(i)) / (image_width - 1);
            const g = @as(f64, @floatFromInt(j)) / (image_height - 1);
            const b = 0.0;

            const ir: i64 = @intFromFloat(255.99 * r);
            const ig: i64 = @intFromFloat(255.99 * g);
            const ib: i64 = @intFromFloat(255.99 * b);

            try stdout.print("{d} {d} {d}\n", .{ ir, ig, ib });
        }
    }

    try stdout.flush();
}
