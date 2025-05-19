const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;
const vector = @import("vector.zig");

pub fn hashMap(comptime K: type, comptime V: type) type {
    return struct {
        const Self = @This();
        const Node = struct {
            key: K,
            value: V,
        };
        const Item = *?Node;
        allocator: Allocator,
        data: vector.Vector(Item),
        hashFunction: fn (K) usize,

        pub fn init(allocator: Allocator, initial_capacity: usize, hashFunc: fn (K) usize) Self {
            const vec = vector.Vector(Item).init(allocator);
            vec.resize(initial_capacity, null);
            return Self{
                .allocator = allocator,
                .data = vec,
                .hashFunction = hashFunc,
            };
        }

        pub fn deinit(self: *Self) void {
            self.data.deinit();
        }
    };
}
