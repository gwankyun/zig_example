const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;

pub fn ListNode(comptime T: type) type {
    return struct {
        const Self = @This(); // 當前結構體類型
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
        allocator: Allocator,

        pub fn init(allocator: Allocator) Self {
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

        fn insert(self: *Self, prev: ?*Node, value: T, next: ?*Node) !*Node {
            const node = try self.create(value);
            node.prev = prev;
            node.next = next;
            if (prev) |p| {
                p.next = node;
            }
            if (next) |n| {
                n.prev = node;
            }
            self.size += 1;
            return node;
        }

        pub fn pushBack(self: *Self, value: T) !*Node {
            const node =
                try self.insert(self.tail, value, null);
            self.tail = node;
            if (self.size == 1) {
                self.head = node;
            }
            return node;
        }

        pub fn pushFront(self: *Self, value: T) !*Node {
            const node =
                try self.insert(null, value, self.head);
            self.head = node;
            if (self.size == 1) {
                self.tail = node;
            }
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
            const tail = self.tail.?;
            const value = tail.value;
            self.tail = tail.prev;
            self.remove(tail);
            return value;
        }

        pub fn popFront(self: *Self) !T {
            if (self.size == 0) {
                return error.EmptyList;
            }
            const head = self.head.?;
            const value = head.value;
            self.head = head.next;
            self.remove(head);
            return value;
        }
    };
}

pub const Test = struct {
    test "list" {
        const heap = std.heap;
        var gpa =
            heap.DebugAllocator(heap.DebugAllocatorConfig{}){};
        const allocator = gpa.allocator();
        const expectEqual =
            testing.expectEqual;

        var lst = List(i32).init(allocator);
        defer lst.deinit();

        _ = try lst.pushBack(1);
        _ = try lst.pushBack(2);
        _ = try lst.pushBack(3);
        try expectEqual(lst.size, 3);
        try expectEqual(lst.head.?.value, 1);
        try expectEqual(lst.tail.?.value, 3);
        _ = try lst.pushFront(0);
        try expectEqual(lst.size, 4);
        try expectEqual(lst.head.?.value, 0);
        try expectEqual(lst.tail.?.value, 3);

        {
            const value = try lst.popBack();
            try expectEqual(value, 3);
            try expectEqual(lst.size, 3);
        }

        {
            const value = try lst.popFront();
            try expectEqual(value, 0);
            try expectEqual(lst.size, 2);
        }
    }
};

test "list" {
    _ = Test;
}
