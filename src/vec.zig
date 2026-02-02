const std = @import("std");

pub const Vec3 = @Vector(3, f64);

pub const zero = Vec3{0, 0, 0};

pub fn x(v: Vec3) f64 {
    return v[0];
}

pub fn y(v: Vec3) f64 {
    return v[1];
}

pub fn z(v: Vec3) f64 {
    return v[2];
}

pub fn lengthSquared(v: Vec3) f64 {
    return @reduce(.Add, v * v);
}

pub fn length(v: Vec3) f64 {
    return std.math.sqrt(lengthSquared(v));
}

pub fn dot(u: Vec3, v: Vec3) f64 {
    return @reduce(.Add, u * v);
}

pub fn cross(u: Vec3, v: Vec3) Vec3 {
    return .{
        u[1] * v[2] - u[2] * v[1],
        u[2] * v[0] - u[0] * v[2],
        u[0] * v[1] - u[1] * v[0]
    };
}

pub fn unit(v: Vec3) Vec3 {
    const len = length(v);
    if (len == 0) return zero;
    return v / @as(Vec3, @splat(len));
}

pub const Fmt = std.fmt.Alt(Vec3, format);
fn format(v: Vec3, writer: *std.Io.Writer) std.Io.Writer.Error!void {
    try writer.print("{d} {d} {d}", .{v[0], v[1], v[2]});
}

pub const ColorFmt = std.fmt.Alt(Vec3, colorFormat);
fn colorFormat(v: Vec3, writer: *std.Io.Writer) std.Io.Writer.Error!void {
    const r: i64 = @intFromFloat(255.99 * v[0]);
    const g: i64 = @intFromFloat(255.99 * v[1]);
    const b: i64 = @intFromFloat(255.99 * v[2]);
    try writer.print("{d} {d} {d}\n", .{r, g, b});
}
