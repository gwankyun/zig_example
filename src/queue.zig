const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;
const vector = @import("vector.zig");

pub fn Queue(comptime T: type) type {
    return struct {
        const Self = @This();
        allocator: Allocator,
        data: vector.Vector(T),
        index: usize,

        pub fn init(allocator: Allocator) Self {
            return Self{
                .allocator = allocator,
                .data = vector.Vector(T).init(allocator),
                .index = 0,
            };
        }

        pub fn deinit(self: *Self) void {
            self.data.deinit();
        }

        pub fn push(self: *Self, value: T) !void {
            try self.data.push(value);
        }

        pub fn top(self: *Self) !T {
            return try self.data.get(self.index);
        }

        pub fn pop(self: *Self) !T {
            const value = try self.top();
            // 下標前移
            self.index += 1;
            return value;
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
        var queue = Queue(i32).init(allocator);
        defer queue.deinit();

        try queue.push(1);
        try queue.push(2);
        try queue.push(3);
        try expectEqual(1, queue.top());
        try expectEqual(1, queue.pop());
        try expectEqual(2, queue.top());
    }
};

test "Queue" {
    _ = Test;
}
