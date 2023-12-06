const std = @import("std");
const print = std.debug.print;

const input = @embedFile("input.txt");
const example = @embedFile("example.txt");

const Result = struct {
    value: u32,
    total: u32,
};

fn run(src: []const u8, allocator: std.mem.Allocator) !Result {
    var lines = std.mem.splitSequence(u8, src, "\n");
    var result: Result = std.mem.zeroes(Result);
    var counts = std.ArrayList(u32).init(allocator);
    defer counts.deinit();

    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        print("->{s}\n", .{line});
        const idxCard = std.mem.indexOf(u8, line, ":").?;
        const idxGame = std.mem.indexOf(u8, line, "|").?;
        const draw = line[idxCard + 1 .. idxGame];
        const wins = line[idxGame + 1 ..];

        var numMap = std.StringHashMap(u32).init(allocator);
        defer numMap.deinit();
        var nums = std.mem.splitSequence(u8, wins, " ");
        print("winners\n", .{});
        while (nums.next()) |num| {
            if (num.len == 0) {
                continue;
            }
            print("{s}\n", .{num});
            try numMap.put(num, 1);
        }
        print("draw\n", .{});

        var count: u32 = 0;
        nums = std.mem.splitSequence(u8, draw, " ");
        while (nums.next()) |num| {
            if (num.len == 0) {
                continue;
            }
            print("{s}\n", .{num});
            if (numMap.contains(num)) {
                count += 1;
            }
        }

        if (count > 0) {
            result.value += std.math.pow(u32, 2, count - 1);
            print("GOT NUM: {d}->{d}\n", .{ count, std.math.pow(u32, 2, count - 1) });
        }
        try counts.append(count);
    }

    var copyCounts = std.ArrayList(u32).init(allocator);
    defer copyCounts.deinit();
    try copyCounts.appendNTimes(0, counts.items.len);
    print("counts: {any}\n", .{counts.items});
    // counts: { 4, 2, 2, 1, 0, 0 }
    var i: usize = 0;
    while (i < counts.items.len) : (i += 1) {
        const count = counts.items[i];
        copyCounts.items[i] += 1;
        const copyCount = copyCounts.items[i];
        var j: u32 = 1;
        while (j <= count) : (j += 1) {
            copyCounts.items[i + j] += copyCount;
        }
        result.total += copyCounts.items[i];
    }
    print("counts: {any}\n", .{counts.items});
    print("copyCounts: {any}\n", .{copyCounts.items});
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
    try std.testing.expectEqual(@as(u32, 13), result.value);
    try std.testing.expectEqual(@as(u32, 30), result.total);
}
