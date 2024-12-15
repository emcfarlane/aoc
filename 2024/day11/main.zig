const std = @import("std");
const print = std.debug.print;

const input = @embedFile("input.txt");
const example = @embedFile("example.txt");

const Result = struct {
    part1: ?u64,
    part2: ?u64,
};

fn numOfPlaces(x: u64) u64 {
    var y: u64 = x;
    var n: u64 = 1;
    while (y >= 10) {
        y /= 10;
        n += 1;
    }
    return n;
}

fn add(dst: *std.AutoArrayHashMap(u64, u64), key: u64, value: u64) !void {
    try dst.put(key, (dst.get(key) orelse 0) + value);
}

fn blink(dst: *std.AutoArrayHashMap(u64, u64), src: std.AutoArrayHashMap(u64, u64)) !void {
    var it = src.iterator();
    while (it.next()) |entry| {
        const x = entry.key_ptr.*;
        const n = entry.value_ptr.*;
        if (x == 0) {
            //try dst.append(1);
            //print("{d} -> {d}\n", .{ x, 1 });
            try add(dst, 1, n);
        } else {
            const size = numOfPlaces(entry.key_ptr.*);
            if (size % 2 == 0) {
                // Split the left and right digits, discarding leading zeros.
                // 1000 would become 10 and 0.
                //try dst.append(x * 2024);
                const split = std.math.pow(u64, 10, size / 2);
                const left = x / split;
                const right = x % split;
                //print("{d} -> {d} {d}\n", .{ x, left, right });
                //try dst.append(left);
                //try dst.append(right);
                try add(dst, left, n);
                try add(dst, right, n);
            } else {
                //try dst.append(x * 2024);
                try add(dst, x * 2024, n);
                //print("{d} -> {d}\n", .{ x, x * 2024 });
            }
        }
    }
}

fn run(src: []const u8, allocator: std.mem.Allocator) !Result {
    var stones = std.AutoArrayHashMap(u64, u64).init(allocator);
    defer stones.deinit();

    var stoneIt = std.mem.tokenizeAny(u8, src, " \n");
    while (stoneIt.next()) |stone| {
        const x = try std.fmt.parseInt(u64, stone, 10);
        try stones.put(x, (stones.get(x) orelse 0) + 1);
    }

    var nextStones = std.AutoArrayHashMap(u64, u64).init(allocator);
    defer nextStones.deinit();

    var result: Result = std.mem.zeroes(Result);
    var i: usize = 0;
    while (i < 25) : (i += 1) {
        try blink(&nextStones, stones);
        const tmp = stones;
        stones = nextStones;
        nextStones = tmp;
        nextStones.clearRetainingCapacity();
        print("blink {d}: size {d}\n", .{ i + 1, stones.count() });
    }
    //result.part1 = @as(u64, @intCast(stones.count()));
    var sum: u64 = 0;
    for (stones.values()) |v| {
        sum += v;
    }
    result.part1 = sum;

    while (i < 75) : (i += 1) {
        try blink(&nextStones, stones);
        const tmp = stones;
        stones = nextStones;
        nextStones = tmp;
        nextStones.clearRetainingCapacity();
        print("blink {d}: size {d}\n", .{ i + 1, stones.count() });
    }
    //result.part2 = @as(u64, @intCast(stones.items.len));
    var sum2: u64 = 0;
    for (stones.values()) |v| {
        sum2 += v;
    }
    result.part2 = sum2;
    return result;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const result = try run(input, allocator);
    print("Result: {any}\n", .{result});
}

test "example" {
    const result = try run(example, std.testing.allocator);
    print("Result: {any}\n", .{result});
    if (result.part1) |p1| try std.testing.expectEqual(@as(u64, 55312), p1);
    //if (result.part2) |p2| try std.testing.expectEqual(@as(u64, ), p2);
}
