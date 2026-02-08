const vec = @import("vec.zig");

origin: vec.Vec3,
dirn: vec.Vec3,

pub fn at(self: @This(), t: f64) vec.Vec3 {
    return self.origin + @as(vec.Vec3, @splat(t)) * self.dirn;
}
