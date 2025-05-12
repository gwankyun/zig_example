const std = @import("std");

pub fn ListNode(comptime T: type) type {
    return struct {
        const Self = @This();
        value: T,
        prev: ?*Self, // 可空指針
        next: ?*Self, // 可空指針

        pub fn init(value: T) Self {
            return Self{
                .value = value,
                .prev = null,
                .next = null,
            };
        }
    };
}

pub fn List(comptime T: type) type {
    return struct {
        const Self = @This();
        const Node = ListNode(T);
        head: ?*Node, // 可空指針
        tail: ?*Node, // 可空指針
        size: usize,
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .head = null,
                .tail = null,
                .size = 0,
                .allocator = allocator,
            };
        }

        fn create(self: *Self, value: T) !*Node {
            const node =
                try self.allocator.create(Node);
            node.* = Node.init(value);
            return node;
        }

        fn destroy(self: *Self, node: *Node) void {
            self.allocator.destroy(node);
        }

        pub fn deinit(self: *Self) void {
            var node = self.head;
            while (node) |n| {
                const next = n.next;
                self.destroy(n);
                node = next;
                self.size -= 1;
            }
        }

        pub fn pushBack(self: *Self, value: T) !*Node {
            var node = try self.create(value);
            if (self.size == 0) {
                self.head = node;
                self.tail = node;
            } else {
                self.tail.?.next = node;
                node.prev = self.tail;
                self.tail = node;
            }
            self.size += 1;
            return node;
        }

        pub fn pushFront(self: *Self, value: T) !*Node {
            var node = try self.create(value);
            if (self.size == 0) {
                self.head = node;
                self.tail = node;
            } else {
                self.head.?.prev = node;
                node.next = self.head;
                self.head = node;
            }
            self.size += 1;
            return node;
        }

        fn remove(self: *Self, node: *Node) void {
            if (self.size == 0) {
                return;
            }
            const prev = node.prev;
            const next = node.next;
            if (prev) |p| {
                p.next = next;
            }
            if (next) |n| {
                n.prev = prev;
            }
            self.size -= 1;
            self.destroy(node);
        }

        pub fn popBack(self: *Self) !T {
            if (self.size == 0) {
                return error.EmptyList;
            }
            const node = self.tail.?;
            const value = node.value;
            self.tail = node.prev;
            self.remove(node);
            return value;
        }

        pub fn popFront(self: *Self) !T {
            if (self.size == 0) {
                return error.EmptyList;
            }
            const node = self.head.?;
            const value = node.value;
            self.head = node.next;
            self.remove(node);
            return value;
        }
    };
}
