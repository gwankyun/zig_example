const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;

pub fn Vector(comptime T: type) type {
    return struct {
        const Self = @This();
        allocator: Allocator,
        data: []T,
        size: usize,
        capacity: usize,

        pub fn init(allocator: Allocator) Self {
            return Self{
                .allocator = allocator,
                .data = &[_]T{},
                .size = 0,
                .capacity = 0,
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.data);
        }

        pub fn push(self: *Self, value: T) !void {
            if (self.size == self.capacity) {
                const new_capacity = self.capacity * 2 + 1;
                const new_data =
                    try self.allocator.alloc(T, new_capacity);
                std.mem.copyForwards(T, new_data, self.data);
                self.data = new_data;
                self.capacity = new_capacity;
            }
            self.data[self.size] = value;
            self.size += 1;
        }

        pub fn get(self: *Self, index: usize) !T {
            if (index >= self.size) {
                return error.IndexOutOfBounds;
            }
            return self.data[index];
        }
    };
}

pub const Test = struct {
    const expectEqual =
        testing.expectEqual;

    test "init" {
        const heap = std.heap;
        var gpa =
            heap.DebugAllocator(heap.DebugAllocatorConfig{}){};
        const allocator = gpa.allocator();

        var vec = Vector(i32).init(allocator);
        defer vec.deinit();
        try vec.push(1);
        try vec.push(2);

        try expectEqual(vec.size, 2);
        try expectEqual(vec.get(0), 1);
        try expectEqual(vec.get(1), 2);
    }
};

test "Vec" {
    _ = Test;
}
