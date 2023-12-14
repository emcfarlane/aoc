const std = @import("std");
const print = std.debug.print;

const input = @embedFile("input.txt");
const example = @embedFile("example.txt");

const Result = struct {
    part1: i64,
    part2: i64,
};

const Part = packed struct {
    one: bool = false,
    two: bool = false,
};

fn extend(sequence: *std.ArrayList(i64)) !void {
    var isZero = true;
    var j: usize = 0;
    while (isZero and j < sequence.items.len) : (j += 1) {
        isZero = isZero and sequence.items[j] == 0;
    }
    if (isZero) {
        try sequence.insert(0, 0);
        try sequence.insert(0, 0);
        try sequence.append(0);
        return;
    }
    var diffs = std.ArrayList(i64).init(sequence.allocator);
    defer diffs.deinit();
    var i: usize = 1;
    while (i < sequence.items.len) : (i += 1) {
        const prev = sequence.items[i - 1];
        const item = sequence.items[i];
        const diff = item - prev;
        try diffs.append(diff);
    }
    try extend(&diffs);
    try sequence.insert(0, sequence.items[0] - diffs.items[0]);
    try sequence.append(diffs.getLast() + sequence.getLast());
}

fn run(src: []const u8, allocator: std.mem.Allocator, part: Part) !Result {
    _ = part;
    print("\n", .{});
    var result: Result = std.mem.zeroes(Result);

    var sequences = std.ArrayList(std.ArrayList(i64)).init(allocator);
    defer sequences.deinit();
    var lineIter = std.mem.tokenizeAny(u8, src, "\n");
    while (lineIter.next()) |line| {
        var tokenIter = std.mem.tokenizeAny(u8, line, " ");
        var sequence = std.ArrayList(i64).init(allocator);
        while (tokenIter.next()) |token| {
            const value = try std.fmt.parseInt(i64, token, 10);
            try sequence.append(value);
        }
        try sequences.append(sequence);
    }
    for (sequences.items) |*sequence| {
        try extend(sequence);
        result.part1 += sequence.getLast();
        result.part2 += sequence.items[0];
    }
    for (sequences.items) |*sequence| {
        sequence.deinit();
    }
    return result;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const result = try run(input, allocator, Part{ .one = true, .two = true });
    print("Result: {any}\n", .{result});
}

test "example" {
    const result = try run(example, std.testing.allocator, Part{ .one = true, .two = false });
    print("Result: {any}\n", .{result});
    try std.testing.expectEqual(@as(i64, 114), result.part1);
    try std.testing.expectEqual(@as(i64, 2), result.part2);
}
