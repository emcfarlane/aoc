const std = @import("std");
const print = std.debug.print;

const input = @embedFile("input.txt");
const example = @embedFile("example.txt");

const Result = struct {
    part1: u64,
    part2: i64,
};

fn run(src: []const u8, allocator: std.mem.Allocator) !Result {
    print("\n", .{});
    var result: Result = std.mem.zeroes(Result);

    var columnA = std.ArrayList(i64).init(allocator);
    defer columnA.deinit();
    var columnB = std.ArrayList(i64).init(allocator);
    defer columnB.deinit();

    var lineIter = std.mem.tokenizeAny(u8, src, "\n");
    var counts = std.AutoHashMap(i64, i64).init(allocator);
    defer counts.deinit();
    while (lineIter.next()) |line| {
        var tokenIter = std.mem.tokenizeAny(u8, line, " ");

        const a = try std.fmt.parseInt(i64, tokenIter.next().?, 10);
        const b = try std.fmt.parseInt(i64, tokenIter.next().?, 10);
        std.debug.print("a: {d} b: {d}\n", .{ a, b });

        try columnA.append(a);
        try columnB.append(b);

        // part 2
        if (counts.get(b)) |count| {
            try counts.put(b, count + 1);
        } else {
            try counts.put(b, 1);
        }
    }
    std.mem.sort(i64, columnA.items, {}, comptime std.sort.asc(i64));
    std.mem.sort(i64, columnB.items, {}, comptime std.sort.asc(i64));
    for (columnA.items, columnB.items) |a, b| {
        result.part1 += @abs(b - a);
    }
    // Calc similarity.
    for (columnA.items) |a| {
        if (counts.get(a)) |count| {
            std.debug.print("a: {d} count: {d}\n", .{ a, count });
            result.part2 += a * count;
            std.debug.print("adding {d}\n", .{a * count});
        }
    }
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
    try std.testing.expectEqual(@as(u64, 11), result.part1);
    try std.testing.expectEqual(@as(i64, 31), result.part2);
}
