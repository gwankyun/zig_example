const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;
const vector = @import("vector.zig");

pub fn Stack(comptime T: type) type {
    return struct {
        const Self = @This();
        allocator: Allocator,
        data: vector.Vector(T),

        pub fn init(allocator: Allocator) Self {
            return Self{
                .allocator = allocator,
                .data = vector.Vector(T).init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.data.deinit();
        }

        pub fn push(self: *Self, value: T) !void {
            try self.data.push(value);
        }

        pub fn pop(self: *Self) !T {
            return self.data.pop();
        }

        pub fn top(self: *Self) !T {
            return self.data.get(self.data.size - 1);
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
        var stack = Stack(i32).init(allocator);
        defer stack.deinit();

        try stack.push(1);
        try stack.push(2);
        try stack.push(3);
        try expectEqual(3, stack.top());
        try expectEqual(3, stack.pop());
        try expectEqual(2, stack.pop());
        try stack.push(3);
        try stack.push(1);
        try expectEqual(1, stack.top());
        _ = try stack.pop();
    }
};

test "Stack" {
    _ = Test;
}
