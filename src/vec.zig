const std = @import("std");
const utils = @import("utils.zig");
const Interval = @import("Interval.zig");

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

pub fn scale(v: Vec3, s: anytype) Vec3 {
    return v * splat(s);
}

pub fn splat(n: anytype) Vec3 {
    return switch (@TypeOf(n)) {
        usize, comptime_int, i64, u64 => @as(Vec3, @splat(@floatFromInt(n))),
        f64, comptime_float => @as(Vec3, @splat(n)),
        else => unreachable,
    };
}

pub fn lengthSquared(v: Vec3) f64 {
    return @reduce(.Add, v * v);
}

pub fn length(v: Vec3) f64 {
    return @sqrt(lengthSquared(v));
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

pub fn random() Vec3 {
    return .{
        utils.randomf64(),
        utils.randomf64(),
        utils.randomf64(),
    };
}

pub fn randomRange(min: f64, max: f64) Vec3 {
    return .{
        utils.randomRangef64(min, max),
        utils.randomRangef64(min, max),
        utils.randomRangef64(min, max),
    };
}

pub fn randomUnitVector() Vec3 {
    while (true) {
        const p = randomRange(-1, 1);
        const len = lengthSquared(p);
        if (1e-160 < len and len <= 1) {
            return scale(p, @sqrt(len));
        }
    }
}

pub fn randomOnHemisphere(normal: Vec3) Vec3 {
    const rand_unit = randomUnitVector();
    if (dot(rand_unit, normal) > 0.0) {
        return rand_unit;
    }
    return -rand_unit;
}

pub const Fmt = std.fmt.Alt(Vec3, format);
fn format(v: Vec3, writer: *std.Io.Writer) std.Io.Writer.Error!void {
    try writer.print("{d} {d} {d}", .{v[0], v[1], v[2]});
}

pub const Color = Vec3;
pub const ColorFmt = std.fmt.Alt(Color, colorFormat);
const intensity = Interval{ .min = 0.0, .max = 0.999 };
// print the colour
fn colorFormat(v: Vec3, writer: *std.Io.Writer) std.Io.Writer.Error!void {
    const r: i64 = @intFromFloat(255.99 * intensity.clamp(v[0]));
    const g: i64 = @intFromFloat(255.99 * intensity.clamp(v[1]));
    const b: i64 = @intFromFloat(255.99 * intensity.clamp(v[2]));
    try writer.print("{d} {d} {d}\n", .{r, g, b});
}
