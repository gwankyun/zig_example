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

        pub fn pop(self: *Self) !T {
            if (self.size == 0) {
                return error.Empty;
            }
            self.size -= 1;
            return self.data[self.size];
        }

        pub fn get(self: *Self, index: usize) !T {
            if (index >= self.size) {
                return error.IndexOutOfBounds;
            }
            return self.data[index];
        }

        pub fn set(self: *Self, index: usize, value: T) !void {
            if (index >= self.size) {
                return error.IndexOutOfBounds;
            }
            self.data[index] = value;
        }

        pub fn resize(self: *Self, new_size: usize, value: T) !void {
            if (new_size > self.capacity) {
                const new_capacity = new_size;
                const new_data =
                    try self.allocator.alloc(T, new_capacity);
                std.mem.copyForwards(T, new_data, self.data);
                self.data = new_data;
                self.capacity = new_capacity;
            }
            for (self.data[self.size..new_size]) |*item| {
                item.* = value;
            }
            self.size = new_size;
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

        try expectEqual(vec.pop(), 2);
        try expectEqual(vec.size, 1);

        try vec.resize(3, 0);
        try expectEqual(3, vec.size);
        try expectEqual(0, vec.get(2));

        try vec.set(1, 3);
        try expectEqual(3, vec.get(1));
    }
};

test "Vec" {
    _ = Test;
}
