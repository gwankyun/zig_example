const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;
const vector = @import("vector.zig");
const Vector = vector.Vector;

pub fn hashMap(comptime K: type, comptime V: type) type {
    return struct {
        const Self = @This();
        const Node = struct {
            key: K,
            value: ?V,
        };
        const Item = *?Node;
        const DataType = Vector(Item);
        allocator: Allocator,
        data: DataType,
        hashFunction: fn (K) usize,

        pub fn init(allocator: Allocator, initial_capacity: usize, hashFunc: fn (K) usize) Self {
            const vec = DataType.init(allocator);
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

        fn getIndex(self: *Self, key: K, vec: *DataType) ?usize {
            const index = self.hashFunction(key);
            const current = vec.get(index);
            if (current == null) {
                return index;
            } else {
                var i: usize = 1;
                while (true) {
                    // 平方法
                    const idx = i * i;
                    if (idx >= index + vec.size) {
                        return null;
                    }
                    // 允許從頭再找
                    const new_index = (index + idx) % vec.size;
                    const new_current = vec.get(new_index);
                    if (new_current == null) {
                        return new_index;
                    }
                    i += 1;
                }
            }
        }

        pub fn extend(self: *Self) !void {
            var new_capacity = self.data.size * 2 + 1;

            while (true) {
                // 複製出來，重新加
                var new_data = DataType.init(self.allocator);
                try new_data.resize(new_capacity, null);

                for (self.data) |value| {
                    if (value != null) {
                        const index = self.getIndex(value.key, &new_data);
                        if (index == null) {
                            new_data.deinit();
                            new_capacity = new_capacity * 2 + 1;
                            continue;
                        }
                        try new_data.set(index, value);
                    }
                }
                self.data.deinit();
                self.data = new_data;
                break;
            }
        }

        pub fn set(self: *Self, key: K, value: V) !void {
            while (true) {
                const index = self.getIndex(key, self.data);
                if (index == null) {
                    try self.extend();
                    continue;
                }
                const node = try self.allocator.create(Node);
                node.key = key;
                node.value = value;
                try self.data.set(index, node);
                break;
            }
        }
    };
}
