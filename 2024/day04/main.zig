const std = @import("std");
const print = std.debug.print;

const input = @embedFile("input.txt");
const example = @embedFile("example.txt");

const Result = struct {
    part1: u64,
    part2: u64,
};

fn has(c: u8, ix: i32, iy: i32, lines: [][]const u8) bool {
    if (iy < 0 or ix < 0) {
        return false;
    }
    const x: usize = @intCast(ix);
    const y: usize = @intCast(iy);
    return (y < lines.len and x < lines[y].len) and
        (lines[y][x] == c);
}

fn hasXmasAt(uy: usize, ux: usize, lines: [][]const u8) usize {
    const c = lines[uy][ux];
    if (c != 'X') {
        return 0;
    }

    const x: i32 = @intCast(ux);
    const y: i32 = @intCast(uy);

    // Need to calculate up, down, left, right and diagonals.
    var i: usize = 0;
    const vecs = [_][2]i32{
        [_]i32{ 0, 1 },
        [_]i32{ 0, -1 },
        [_]i32{ 1, 0 },
        [_]i32{ -1, 0 },
        [_]i32{ 1, 1 },
        [_]i32{ -1, -1 },
        [_]i32{ 1, -1 },
        [_]i32{ -1, 1 },
    };
    for (vecs) |vec| {
        if (has('M', x + 1 * vec[0], y + 1 * vec[1], lines) and
            has('A', x + 2 * vec[0], y + 2 * vec[1], lines) and
            has('S', x + 3 * vec[0], y + 3 * vec[1], lines))
        {
            i += 1;
        }
    }
    return i;
}

fn hasXMasAt(uy: usize, ux: usize, lines: [][]const u8) usize {
    const c = lines[uy][ux];
    if (c != 'A') {
        return 0;
    }
    const x: i32 = @intCast(ux);
    const y: i32 = @intCast(uy);

    var i: usize = 0;
    // m => y + 1
    // s +> y - 1
    if (has('M', x + 1, y + 1, lines) and has('S', x - 1, y - 1, lines) and
        has('M', x - 1, y + 1, lines) and has('S', x + 1, y - 1, lines))
    {
        i += 1;
    }
    // m => y - 1
    // s => y + 1
    if (has('M', x + 1, y - 1, lines) and has('S', x + 1, y + 1, lines) and
        has('M', x - 1, y - 1, lines) and has('S', x - 1, y + 1, lines))
    {
        i += 1;
    }
    // m => x + 1
    // s => x - 1
    if (has('M', x + 1, y - 1, lines) and has('S', x - 1, y + 1, lines) and
        has('M', x + 1, y + 1, lines) and has('S', x - 1, y - 1, lines))
    {
        i += 1;
    }
    // m => x - 1
    // s => x + 1
    if (has('M', x - 1, y - 1, lines) and has('S', x + 1, y + 1, lines) and
        has('M', x - 1, y + 1, lines) and has('S', x + 1, y - 1, lines))
    {
        i += 1;
    }
    return i;
}

fn run(src: []const u8, allocator: std.mem.Allocator) !Result {
    print("\n", .{});
    var result: Result = std.mem.zeroes(Result);

    var lines = std.ArrayList([]const u8).init(allocator);
    defer lines.deinit();

    // ..X...\n
    // Y.....
    //
    // y(x+1)-1 = src.len
    // y = (src.len + 1)/(x+1)
    var lineIter = std.mem.tokenizeAny(u8, src, "\n");
    while (lineIter.next()) |line| {
        print("line: {s}\n", .{line});
        try lines.append(line);
    }

    for (0.., lines.items) |y, line| {
        for (0..line.len) |x| {
            const n = hasXmasAt(y, x, lines.items);
            if (n > 0) {
                print("found xmas at {} {}\n", .{ y, x });
                result.part1 += n;
            }
            const m = hasXMasAt(y, x, lines.items);
            if (m > 0) {
                print("found x-mas at {} {}\n", .{ y, x });
                result.part2 += m;
            }
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
    try std.testing.expectEqual(@as(u64, 18), result.part1);
    try std.testing.expectEqual(@as(u64, 9), result.part2);
}
