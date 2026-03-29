const std = @import("std");

pub inline fn degreesToRadians(degrees: f64) f64 {
    return degrees * std.math.pi / 180.0;
}

pub inline fn randomf64() f64 {
    return std.crypto.random.float(f64);
}

pub inline fn randomRangef64(min: f64, max: f64) f64 {
    return min + (max - min) * randomf64();
}
