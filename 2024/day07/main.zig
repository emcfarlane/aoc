const std = @import("std");
const print = std.debug.print;

const input = @embedFile("input.txt");
const example = @embedFile("example.txt");

const Result = struct {
    part1: i64,
    part2: i64,
};

fn sumValues(answer: i64, acc: i64, nums: []const i64) bool {
    if (nums.len == 0) {
        return answer == acc;
    }
    if (acc > answer) {
        return false;
    }
    return sumValues(answer, acc + nums[0], nums[1..]) or
        sumValues(answer, acc * nums[0], nums[1..]);
}

fn run(src: []const u8, allocator: std.mem.Allocator) !Result {
    print("\n", .{});
    var result: Result = std.mem.zeroes(Result);
    result.part1 = 0;

    var lineIt = std.mem.tokenizeSequence(u8, src, "\n");
    while (lineIt.next()) |line| {
        var partIt = std.mem.splitScalar(u8, line, ':');
        const ans = try std.fmt.parseInt(i64, partIt.first(), 10);

        var nums = std.ArrayList(i64).init(allocator);
        defer nums.deinit();

        var numIt = std.mem.tokenizeSequence(u8, partIt.rest(), " ");
        while (numIt.next()) |numStr| {
            const num = try std.fmt.parseInt(i64, numStr, 10);
            try nums.append(num);
        }

        // DO the logic here.
        if (sumValues(ans, 0, nums.items)) {
            result.part1 += ans;
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
    try std.testing.expectEqual(@as(i64, 3749), result.part1);
}
