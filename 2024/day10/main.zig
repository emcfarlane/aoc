const std = @import("std");
const print = std.debug.print;

const input = @embedFile("input.txt");
const example = @embedFile("example.txt");

const Result = struct {
    part1: u64,
    part2: u64,
};

fn run(src: []const u8, allocator: std.mem.Allocator) !Result {
    _ = src;
    _ = allocator;
    print("\n", .{});
    var result: Result = std.mem.zeroes(Result);
    result.part1 = 0;
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
    try std.testing.expectEqual(@as(u64, 1928), result.part1);
    try std.testing.expectEqual(@as(u64, 2858), result.part2);
}
