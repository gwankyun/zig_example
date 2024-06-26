//! 頂級注釋

const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const mem = std.mem;

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

    // pub fn distance(self: *Point) f64 {
    //     return @sqrt(self.x * self.x + self.y * self.y);
    // }
};

pub fn struct_example() !void {
    const p = Point.init(3, 4);
    assert(p.x == 3);
    assert(p.y == 4);
    // assert(@as(i32, p.distance()) == 5.0);
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
        return comptime Borrow { .read = 0 };
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
}
