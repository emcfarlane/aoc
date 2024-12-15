const std = @import("std");
const print = std.debug.print;

const input = @embedFile("input.txt");
const example = @embedFile("example.txt");
const example2 = @embedFile("example2.txt");

const Result = struct {
    part1: u64,
    part2: u64,
};

const State = enum {
    start,
    mul,
    do,
    dont,
};

fn run(src: []const u8, allocator: std.mem.Allocator) !Result {
    print("\n", .{});
    var result: Result = std.mem.zeroes(Result);

    var i: usize = 0;
    var state = State.start;
    var mulEnabled: bool = true;
    while (i < src.len) {
        switch (state) {
            .start => if (std.mem.startsWith(u8, src[i..], "mul(")) {
                state = State.mul;
                i += 4;
            } else if (std.mem.startsWith(u8, src[i..], "do()")) {
                state = State.do;
                i += 4;
            } else if (std.mem.startsWith(u8, src[i..], "don't()")) {
                state = State.dont;
                i += 7;
            } else {
                i += 1;
            },
            .do => {
                print("do\n", .{});
                mulEnabled = true;
                state = State.start;
            },
            .dont => {
                print("dont\n", .{});
                mulEnabled = false;
                state = State.start;
            },
            .mul => {
                const j = std.mem.indexOf(u8, src[i..], ")");
                if (j) |k| {
                    const part = src[i .. k + i];
                    print("part {} {}: {s}\n", .{ i, k, part });
                    var numberIter = std.mem.tokenizeAny(u8, part, ",");
                    var line = std.ArrayList(u64).init(allocator);
                    defer line.deinit();
                    while (numberIter.next()) |b| {
                        const n = std.fmt.parseInt(u64, b, 10) catch {
                            line.clearAndFree();
                            break;
                        };
                        try line.append(n);
                    }
                    print("mul: {any}\n", .{line.items});
                    if (line.items.len == 2) {
                        const mul = line.items[0] * line.items[1];
                        result.part1 += mul;
                        if (mulEnabled) {
                            result.part2 += mul;
                        }
                        i += k + 1;
                    }
                }
                state = State.start;
            },
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
    try std.testing.expectEqual(@as(u64, 161), result.part1);
}

test "example2" {
    const result = try run(example2, std.testing.allocator);
    print("Result: {any}\n", .{result});
    try std.testing.expectEqual(@as(u64, 48), result.part2);
}
