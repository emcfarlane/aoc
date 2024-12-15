const std = @import("std");
const print = std.debug.print;

const input = @embedFile("input.txt");
const example = @embedFile("example.txt");

const Result = struct {
    part1: i64,
    part2: i64,
};

fn isSorted(allocator: std.mem.Allocator, rules: std.AutoHashMap(i64, []i64), values: []i64) !bool {
    var hasSeen = std.AutoHashMap(i64, void).init(allocator);
    defer hasSeen.deinit();
    try hasSeen.ensureTotalCapacity(@intCast(values.len));
    for (0.., values) |i, num| {
        _ = i;
        if (rules.get(num)) |rule| {
            for (rule) |rv| {
                if (hasSeen.get(rv)) |_| {
                    return false;
                }
            }
        }

        hasSeen.putAssumeCapacity(num, {});
    }
    return true;
}

fn run(src: []const u8, allocator: std.mem.Allocator) !Result {
    print("\n", .{});
    var result: Result = std.mem.zeroes(Result);
    result.part1 = 0;

    var rules = std.AutoHashMap(i64, []i64).init(allocator);
    defer rules.deinit();

    defer {
        var it = rules.valueIterator();
        while (it.next()) |value| {
            allocator.free(value.*);
        }
    }

    var sectionIter = std.mem.tokenizeSequence(u8, src, "\n\n");

    var lineIter = std.mem.tokenizeAny(u8, sectionIter.next().?, "\n");
    while (lineIter.next()) |line| {
        print("{s}\n", .{line});

        var kv_it = std.mem.splitScalar(u8, line, '|');
        const a = try std.fmt.parseInt(i64, kv_it.first(), 10);
        const b = try std.fmt.parseInt(i64, kv_it.rest(), 10);

        if (rules.get(a)) |nums| {
            var new_nums = std.ArrayList(i64).fromOwnedSlice(allocator, nums);
            errdefer new_nums.deinit();
            try new_nums.append(b);
            try rules.put(a, try new_nums.toOwnedSlice());
        } else {
            var nums = try allocator.alloc(i64, 1);
            nums[0] = b;
            try rules.put(a, nums);
        }
    }

    var it = rules.iterator();
    while (it.next()) |entry| {
        print("RULE {}: {any}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }

    lineIter = std.mem.tokenizeAny(u8, sectionIter.next().?, "\n");
    while (lineIter.next()) |line| {
        print("{s}\n", .{line});
        var values = std.ArrayList(i64).init(allocator);
        defer values.deinit();

        var numIt = std.mem.tokenizeAny(u8, line, ",");
        while (numIt.next()) |numStr| {
            try values.append(try std.fmt.parseInt(i64, numStr, 10));
        }

        print("VALUES {any}\n", .{values.items});

        if (try isSorted(allocator, rules, values.items)) {
            const mid = values.items[values.items.len / 2];
            print("IS SORTED! {any} => ADDING {} {}\n", .{ values.items, mid });
            result.part1 += mid;
        } else {
            print("NOT SORTED! {any}\n", .{values.items});
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
    try std.testing.expectEqual(@as(i64, 143), result.part1);
}
