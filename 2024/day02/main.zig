const std = @import("std");
const print = std.debug.print;

const input = @embedFile("input.txt");
const example = @embedFile("example.txt");

const Result = struct {
    part1: u64,
    part2: i64,
};

const Direction = enum { unknown, asc, desc, invalid };

fn direction(a: i64, b: i64) Direction {
    const r = @abs(b - a);
    if (r > 3 or r < 1) {
        return Direction.invalid;
    }
    if (a - b < 0) {
        return Direction.desc;
    }
    return Direction.asc;
}

fn isSafe(line: []const i64) (usize) {
    var dir = Direction.unknown;
    for (1.., line[1..]) |i, b| {
        const a = line[i - 1];
        const d = direction(a, b);
        if (d == Direction.invalid or (dir != Direction.unknown and d != dir)) {
            return i;
        }
        dir = d;
    }
    return line.len;
}

fn run(src: []const u8, allocator: std.mem.Allocator) !Result {
    print("\n", .{});
    var result: Result = std.mem.zeroes(Result);

    var lineIter = std.mem.tokenizeAny(u8, src, "\n");
    while (lineIter.next()) |lineStrs| {
        var tokenIter = std.mem.tokenizeAny(u8, lineStrs, " ");
        var line = std.ArrayList(i64).init(allocator);
        defer line.deinit();
        while (tokenIter.next()) |token| {
            const n = try std.fmt.parseInt(i64, token, 10);
            try line.append(n);
        }
        print("-----------------\nline {any}\n", .{line.items});

        // Loop over each and check
        const i = isSafe(line.items);
        if (i == line.items.len) {
            print("safe on all\n", .{});
            result.part1 += 1;
            result.part2 += 1;
            continue;
        }

        // Split and check
        print("unsafe part1 {any}\n", .{line.items});

        for (0..line.items.len) |j| {
            var lineA = try line.clone();
            defer lineA.deinit();
            _ = lineA.orderedRemove(j);
            print("\ttrying {} {any}\n", .{ j, lineA.items });
            if (isSafe(lineA.items) == lineA.items.len) {
                print("\tsafe on pop {} slice{any}->{any}\n", .{ j, line.items, lineA.items });
                result.part2 += 1;
                break;
            }
        } else {
            print("unsafe part2 {any}\n", .{line.items});
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
    try std.testing.expectEqual(@as(u64, 2), result.part1);
    try std.testing.expectEqual(@as(i64, 4), result.part2);
}
