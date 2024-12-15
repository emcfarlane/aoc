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

    fn add(a: @This(), b: Pos) Pos {
        return Pos{ .x = a.x + b.x, .y = a.y + b.y };
    }
};

const Direction = enum {
    down,
    right,
    up,
    left,
};

fn turn(dir: Direction) Direction {
    return switch (dir) {
        .down => Direction.right,
        .right => Direction.up,
        .up => Direction.left,
        .left => Direction.down,
    };
}

fn step(dir: Direction) Pos {
    return switch (dir) {
        .up => Pos{ .x = 0, .y = 1 },
        .right => Pos{ .x = 1, .y = 0 },
        .down => Pos{ .x = 0, .y = -1 },
        .left => Pos{ .x = -1, .y = 0 },
    };
}

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
    result.part1 = 0;

    var grid = std.ArrayList([]const u8).init(allocator);
    defer grid.deinit();

    var lineIter = std.mem.tokenizeSequence(u8, src, "\n");
    var pos = Pos{ .x = 0, .y = 0 };
    var y: usize = 0;
    while (lineIter.next()) |line| {
        print("line: {s}\n", .{line});
        try grid.append(line);

        if (std.mem.indexOf(u8, line, "^")) |x| {
            pos = Pos{ .x = @intCast(x), .y = @intCast(y) };
        }
        y += 1;
    }

    print("POS {}\n", .{pos});

    const length = grid.items[0].len;
    const height = grid.items.len;

    // Do the walk...
    const map = Map{ .map = grid.items };
    var dir = Direction.down;
    var visited = try std.bit_set.DynamicBitSet.initEmpty(allocator, length * height);
    defer visited.deinit();
    while (map.inBounds(pos)) {
        const next = pos.add(step(dir));
        print("{c} {} -> {?c} \n", .{ map.charAt(pos).?, dir, map.charAt(next) });
        if (map.charAt(next)) |peek| {
            if (peek == '#') {
                dir = turn(dir);
                continue;
            }
        }
        const xOffset: usize = @intCast(pos.x);
        const yOffset: usize = @intCast(pos.y);
        const index = length * yOffset + xOffset;

        visited.set(index);
        pos = next;
    }
    print("DONE {} \n", .{pos});
    result.part1 = visited.count();

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
    try std.testing.expectEqual(@as(u64, 41), result.part1);
}
