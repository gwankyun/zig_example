//! 頂級注釋

const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const mem = std.mem;
const list = @import("list.zig");
const vector = @import("vector.zig");
const stack = @import("stack.zig");
const queue = @import("queue.zig");
const testing = std.testing;

pub fn print_example() !void {
    const io = std.io;

    const out = io.getStdOut().writer();
    const err = io.getStdErr().writer();

    var out_buffer = io.bufferedWriter(out);
    var err_buffer = io.bufferedWriter(err);

    var out_writer = out_buffer.writer();
    var err_writer = err_buffer.writer();

    try out_writer.print("Hello {s}!\n", .{"out"});
    try err_writer.print("Hello {s}!\n", .{"err"});

    try out_buffer.flush();
    try err_buffer.flush();
}

/// 變量與常量
pub fn var_example() !void {
    var v: u32 = 0; // 默認可變
    v = 2;
    print("v: {}\n", .{v});
    assert(v == 2);

    const c: u32 = 3;
    print("c: {}\n", .{c});
    assert(c == 3);
}

pub fn char_bool_example() !void {
    const c: u8 = 'c';
    print("c: {c}\n", .{c});

    const b: bool = true;
    assert(b);
}

pub fn add(a: u32, b: u32) u32 {
    return a + b;
}

/// 泛型
pub fn addAny(a: anytype, b: anytype) @TypeOf(a) {
    return a + b;
}

/// 字符串
pub fn string_example() !void {
    const bytes = "hello";
    print("{}\n", .{@TypeOf(bytes)});
    assert(bytes.len == 5);
    assert(bytes[0] == 'h');
    assert(bytes[bytes.len - 1] == 'o');
    assert(bytes[bytes.len] == 0); // 以0結束
}

/// 數組
pub fn array_example() !void {
    const a = [_]u32{ 1, 2, 3, 4, 5 }; // _可用具體數字代替
    print("a[1]: {}\n", .{a[0]});
    assert(a[0] == 1);
    assert(a.len == 5);
    assert(a[a.len - 1] == 5);

    // 哨兵數組
    const aST = [_:0]u32{ 1, 2, 3, 4, 5 }; // 以0結尾
    assert(aST.len == 5);
    assert(aST[a.len - 1] == 5);
    assert(aST[a.len] == 0);
}

/// 指針
pub fn ptr_example() !void {
    // 單項指針
    var v: u32 = 0;
    // 取地址
    const ptr = &v;
    // 解地址
    ptr.* += 1;
    assert(v == 1);

    // 函數指針
    const ptr_add = &add;
    assert(ptr_add(1, 2) == 3);

    //
    const a = [_]i32{ 1, 2, 3, 4, 5 };
    const ptr_a = &a;
    assert(ptr_a[0] == 1);
    assert(ptr_a.len == 5);
}

pub fn slice_example() !void {
    const a = [_]i32{ 1, 2, 3, 4, 5 };
    const s = a[1..3]; // 2, 3
    assert(s.len == 2);
    assert(s[0] == 2);
    assert(s[s.len - 1] == 3);
}

const Point = struct {
    x: i32,
    y: i32,

    pub fn init(x: i32, y: i32) Point {
        return Point{ .x = x, .y = y };
    }

    // pub fn distance(self: *const Point) f64 {
    //     const x = @as(f64, self.x);
    //     const y = @as(f64, self.y);
    //     return @sqrt(x * x + y * y);
    // }
};

// const ListNode = struct {
//     value: i32,
//     prev: ?*ListNode, // 可空指針
//     next: ?*ListNode, // 可空指針
// };

pub fn list_example(allocator: std.mem.Allocator) !void {
    var lst = list.List(i32).init(allocator);
    defer lst.deinit();

    _ = try lst.pushBack(1);
    _ = try lst.pushBack(2);
    _ = try lst.pushBack(3);
    assert(lst.size == 3);
    // test "size" {
    //     try std.testing.expect(lst.size == 3);
    // };
    assert(lst.head.?.value == 1);
    assert(lst.tail.?.value == 3);
    _ = try lst.pushFront(0);
    assert(lst.size == 4);
    assert(lst.head.?.value == 0);
    assert(lst.tail.?.value == 3);

    {
        const value = try lst.popBack();
        assert(value == 3);
        assert(lst.size == 3);
    }

    {
        const value = try lst.popFront();
        assert(value == 0);
        assert(lst.size == 2);
    }
}

pub fn struct_example() !void {
    const p = Point.init(3, 4);
    assert(p.x == 3);
    assert(p.y == 4);
    // const i: i32
    // const i: i32 = @intFromFloat(p.distance());
    // assert(i == 5);
}

/// 聯合
pub fn union_example() !void {
    const PayloadTag = enum {
        int,
        float,
        boolean,
    };

    const Payload = union(PayloadTag) {
        int: i64,
        float: f64,
        boolean: bool,
    };

    const payload = Payload{ .int = 2 };
    assert(payload.int == 2);
    assert(@as(PayloadTag, payload) == PayloadTag.int);
}

pub fn is_even(x: u32) bool {
    if (x % 2 == 0) {
        return true;
    } else {
        return false;
    }
}

pub fn decision_example() !void {
    assert(is_even(0));
    assert(!is_even(1));
}

pub fn loop_example() !void {
    const items = [_]i32{ 3, 7, 2, 1 };
    var sum: i32 = 0;
    for (items) |value| {
        sum += value;
    }
    assert(sum == 13);
}

pub fn defer_example() !void {
    defer {
        print("snd\n", .{});
    }
    defer {
        print("fst\n", .{});
    }
}

pub fn max(comptime T: type, a: T, b: T) T {
    if (a > b) {
        return a;
    } else {
        return b;
    }
}

const Borrow = struct {
    read: comptime_int,

    pub fn init() Borrow {
        return comptime Borrow{ .read = 0 };
    }

    pub fn addRef(self: *Borrow) void {
        comptime self.read += 1;
        // return comptime Borrow { .read = self.read + 1 };
    }

    pub fn release(self: *Borrow) void {
        comptime self.read -= 1;
        // return comptime Borrow { .read = self.read - 1 };
    }

    pub fn check(self: *Borrow) bool {
        return comptime self.read == 0;
    }
};

pub fn comptime_example() !void {
    const a32: i32 = 3;
    const b32: i32 = 2;
    assert(max(@TypeOf(a32), a32, b32) == a32);

    comptime var borrow = Borrow.init();
    var v: i32 = 0;
    comptime borrow.addRef();
    const p = &v;
    comptime borrow.addRef();
    p.* = 2;
    {
        const p2 = &v;
        assert(p2.* == 2);
        comptime borrow.addRef();
        comptime borrow.release();
    }
    comptime borrow.release();
    comptime borrow.release();
    assert(comptime borrow.check());
}

fn sqrt(a: i32, b: i32) f64 {
    return @as(f64, a * a + b * b);
}

fn point_example() !void {
    // 單項指針
    var i: i32 = 0;
    const p = &i;
    p.* = 1;
    assert(i == 1);

    // 多項指針
    var a = [_]i32{ 1, 2, 3, 4, 5 };
    const pa = &a;
    pa[0] = 0;
    assert(pa[0] == 0);
    assert(pa.len == 5);
}

const Test = struct {
    const expectEqual = testing.expectEqual;
    const Detail = struct {
        fn add(a: i32, b: i32) i32 {
            return a + b;
        }
    };

    test "add" {
        try testing.expect(Detail.add(1, 2) == 3);
    }

    test "alloc" {
        const heap = std.heap;
        var gpa =
            heap.DebugAllocator(heap.DebugAllocatorConfig{}){};
        const allocator = gpa.allocator();

        {
            const a = try allocator.alloc(i32, 10);
            defer allocator.free(a);

            var i: i32 = 0;
            while (i < 10) : (i += 1) {
                const u: usize = @intCast(i);
                a[u] = i;
            }

            const b = try allocator.alloc(i32, 10);
            defer allocator.free(b);
            std.mem.copyForwards(i32, b, a);
            try expectEqual(b[3], 3);
        }

        {
            const i: i32 = 3;
            try expectEqual(@TypeOf(i), i32);
        }

        {
            const u: usize = 3;
            // 類型轉換
            const i: i32 = @intCast(u);
            try expectEqual(@TypeOf(i), i32);
        }
    }
};

test "main" {
    _ = Test;
    _ = list.Test;
    _ = vector.Test;
    _ = stack.Test;
    _ = queue.Test;
    try testing.expect(true);
}

pub fn main() !void {
    try print_example();
    try var_example();
    try char_bool_example();
    assert(add(1, 2) == 3);
    assert(addAny(1, 2) == 3);
    try array_example();
    try string_example();
    try ptr_example();
    try slice_example();
    try struct_example();
    try union_example();
    try decision_example();
    try loop_example();
    try defer_example();
    try comptime_example();
    try point_example();

    var gpa =
        std.heap.DebugAllocator(std.heap.DebugAllocatorConfig{}){};
    const allocator = gpa.allocator();
    try list_example(allocator);

    // 類型
    {
        const i: i32 = 4;
        print("i: {}\n", .{i});
        const f: f64 = i;
        print("f: {}\n", .{f});
        print("sqrt: {}\n", .{@sqrt(@as(f64, i))});
    }

    {}
}
