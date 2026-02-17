const std = @import("std");
const Ray = @import("Ray.zig");
const vec = @import("vec.zig");
const Vec3 = vec.Vec3;

pub const Hit = struct {
    p: Vec3,
    normal: Vec3,
    t: f64,
    front_face: bool,

    pub fn set_face_normal(self: *Hit, r: Ray, outward_normal: Vec3) void {
        self.front_face = vec.dot(r.dirn, outward_normal) < 0.0;
        self.normal = if (self.front_face) self.normal else -self.normal;
    }
};

const Hittable = struct {
    ptr: *anyopaque,
    hitfn: fn(ptr: *anyopaque, r: Ray, ray_tmin: f64, ray_tmax: f64) ?Hit,

    pub fn init(ptr: anytype) Hittable {
        const T = @TypeOf(ptr);
        std.debug.assert(@typeInfo(T) == .pointer);

        const gen = struct {
            pub fn hit(p: *anyopaque, r: Ray, ray_tmin: f64, ray_tmax: f64) ?Hit {
                const self: T = @ptrCast(@alignCast(p));
                return self.hit(r, ray_tmin, ray_tmax);
            }
        };

        return .{
            .ptr = ptr,
            .hitfn = gen.hit,
        };
    }

    pub fn hit(self: Hittable, r: Ray, ray_tmin: f64, ray_tmax: f64) ?Hit {
        return self.hitfn(self.ptr, r, ray_tmin, ray_tmax);
    }
};

pub const Sphere = struct {
    center: Vec3,
    radius: f64,

    pub fn hit(self: *const Sphere, r: Ray, ray_tmin: f64, ray_tmax: f64) ?Hit {
        const a = vec.lengthSquared(r.dirn);
        const oc = self.center - r.origin;
        const c = vec.lengthSquared(oc) - r * r;
        // const b = -2.0 * vec.dot(r.dirn, oc);
        const h = vec.dot(r.dirn, oc);
        // const d = b * b - 4.0 * a * c;
        const d = h * h - a * c;
        if (d < 0.0) return null;

        const sqrtd = @sqrt(d);
        // nearest root in acceptable range
        const root = (h - sqrtd) / a;
        if (root <= ray_tmin or ray_tmax <= root) {
            root = (h + sqrtd) / a;
            if (root <= ray_tmin or ray_tmax <= root) return null;
        }

        var rec: Hit = .{
            .p = r.at(root),
            .t = root,
        };
        rec.set_face_normal(r, (rec.p - self.center) / vec.splat(self.radius));
        return rec;
    }
};
