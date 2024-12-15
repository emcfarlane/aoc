const std = @import("std");
const print = std.debug.print;

const input = @embedFile("input.txt");
const example = @embedFile("example.txt");

const Result = struct {
    part1: u64,
    part2: u64,
};

const Pos = struct {
    x: i64,
    y: i64,

    fn sub(a: Pos, b: Pos) Pos {
        return Pos{ .x = a.x - b.x, .y = a.y - b.y };
    }
    fn grad(a: Pos, b: Pos) f64 {
        const dx = a.x - b.x;
        const dy = a.y - b.y;
        if (dy == 0) {
            return std.math.inf(f64);
        }
        return @as(f64, @floatFromInt(dx)) / @as(f64, @floatFromInt(dy));
    }
};

const Map = struct {
    map: [][]const u8,

    fn inBounds(self: @This(), pos: Pos) bool {
        if (pos.x < 0 or pos.y < 0) {
            return false;
        }
        const x: usize = @intCast(pos.x);
        const y: usize = @intCast(pos.y);
        return (y < self.map.len and x < self.map[y].len);
    }
    pub fn charAt(self: @This(), pos: Pos) ?u8 {
        if (!self.inBounds(pos)) {
            return null;
        }
        return self.map[@intCast(pos.y)][@intCast(pos.x)];
    }
};

fn run(src: []const u8, allocator: std.mem.Allocator) !Result {
    print("\n", .{});
    var result: Result = std.mem.zeroes(Result);

    var grid = std.ArrayList([]const u8).init(allocator);
    defer grid.deinit();

    var charToPositions = std.AutoArrayHashMap(u8, []Pos).init(allocator);
    defer {
        for (charToPositions.values()) |positions| {
            allocator.free(positions);
        }
        charToPositions.deinit();
    }

    var lineIter = std.mem.tokenizeSequence(u8, src, "\n");
    var y: usize = 0;

    // Dict of char to []positions.
    while (lineIter.next()) |line| {
        print("line: {s}\n", .{line});
        try grid.append(line);

        for (0.., line) |x, char| {
            if (char != '.') {
                const pos = Pos{ .x = @intCast(x), .y = @intCast(y) };
                if (charToPositions.get(char)) |positions| {
                    var positions_array = std.ArrayList(Pos).fromOwnedSlice(allocator, positions);
                    errdefer positions_array.deinit();
                    try positions_array.append(pos);
                    try charToPositions.put(char, try positions_array.toOwnedSlice());
                } else {
                    var positions = try allocator.alloc(Pos, 1);
                    positions[0] = pos;
                    try charToPositions.put(char, positions);
                }
            }
        }

        y += 1;
    }

    const map = Map{ .map = grid.items };

    // Find the unique locations or all antinode points.
    var antinodes = std.AutoHashMap(Pos, void).init(allocator);
    defer antinodes.deinit();

    var it = charToPositions.iterator();
    while (it.next()) |entry| {
        const positions = entry.value_ptr.*;
        print("char: {c} positions: {any}\n", .{ entry.key_ptr.*, positions });
        for (0..positions.len - 1) |i| {
            for (i + 1..positions.len) |j| {
                print("i: {d} j: {d}\n", .{ i, j });
                const a = positions[i];
                const b = positions[j];
                const dx = b.x - a.x;
                const dy = b.y - a.y;

                var m = Pos{ .x = a.x - dx, .y = a.y - dy };
                var k: usize = 0;
                while (map.inBounds(m)) : (k += 1) {
                    if (!antinodes.contains(m)) {
                        try antinodes.put(m, {});
                        if (k == 0) {
                            result.part1 += 1;
                        }
                        result.part2 += 1;
                    }
                    m = Pos{ .x = m.x - dx, .y = m.y - dy };
                }
                m = Pos{ .x = a.x + dx, .y = a.y + dy };
                k = 0;
                while (map.inBounds(m)) : (k += 1) {
                    if (!antinodes.contains(m)) {
                        try antinodes.put(m, {});
                        result.part2 += 1;
                    }
                    m = Pos{ .x = m.x - dx, .y = m.y - dy };
                }

                var n = Pos{ .x = b.x + dx, .y = b.y + dy };
                k = 0;
                while (map.inBounds(n)) : (k += 1) {
                    if (!antinodes.contains(n)) {
                        try antinodes.put(n, {});
                        if (k == 0) {
                            result.part1 += 1;
                        }
                        result.part2 += 1;
                    }
                    n = Pos{ .x = n.x + dx, .y = n.y + dy };
                }
                n = Pos{ .x = b.x - dx, .y = b.y - dy };
                k = 0;
                while (map.inBounds(n)) : (k += 1) {
                    if (!antinodes.contains(n)) {
                        try antinodes.put(n, {});
                        result.part2 += 1;
                    }
                    n = Pos{ .x = n.x + dx, .y = n.y + dy };
                }
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
    try std.testing.expectEqual(@as(u64, 14), result.part1);
    try std.testing.expectEqual(@as(u64, 34), result.part2);
}
