const std = @import("std");

min: f64 = -std.math.inf(f64),
max: f64 =  std.math.inf(f64),

const Self = @This();

pub const empty = Self{
    .min = std.math.inf(f64),
    .max = -std.math.inf(f64),
};

pub const universe = Self{};

pub fn size(self: Self) f64 {
    return self.max - self.min;
}

pub fn contains(self: Self, x: f64) bool {
    return self.min <= x and x <= self.max;
}

pub fn surrounds(self: Self, x: f64) bool {
    return self.min < x and x < self.max;
}
