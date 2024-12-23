const std = @import("std");
const print = std.debug.print;

const input = @embedFile("input.txt");
const example = @embedFile("example.txt");
const example_small = @embedFile("example_small.txt");
const example_part2 = @embedFile("example_part2.txt");

const Result = struct {
    part1: ?u64,
    part2: ?u64,
};

pub const Vec2 = @Vector(2, i32);

const Map = struct {
    map: [][]u8,

    fn inBounds(self: @This(), pos: Vec2) bool {
        if (pos[0] < 0 or pos[1] < 0) {
            return false;
        }
        const x: usize = @intCast(pos[0]);
        const y: usize = @intCast(pos[1]);
        return (y < self.map.len and x < self.map[y].len);
    }
    fn charAt(self: @This(), pos: Vec2) ?u8 {
        if (!self.inBounds(pos)) {
            return null;
        }
        const x: usize = @intCast(pos[0]);
        const y: usize = @intCast(pos[1]);
        return self.map[y][x];
    }
    fn intAt(self: @This(), pos: Vec2) ?i64 {
        if (self.charAt(pos)) |c| {
            const str = [_]u8{c};
            return std.fmt.parseInt(i64, str[0..], 10) catch null;
        }
        return null;
    }
    fn setAt(self: @This(), pos: Vec2, c: u8) void {
        const x: usize = @intCast(pos[0]);
        const y: usize = @intCast(pos[1]);
        self.map[y][x] = c;
    }
    fn findStart(self: @This()) Vec2 {
        // Find the start pos.
        var pointIt = self.points();
        while (pointIt.next()) |pos| {
            if (self.charAt(pos).? == '@') {
                return pos;
            }
        }
        unreachable;
    }
    fn printMap(self: Map) void {
        var i: usize = self.map.len - 1;
        // -%= is wrapping subtraction.
        while (i < self.map.len) : (i -%= 1) {
            const row = self.map[i];
            for (row) |cell| {
                print("{c}", .{cell});
            }
            print("\n", .{});
        }
    }
    const PointsIterator = struct {
        length: usize,
        height: usize,
        index: usize,
        fn next(self: *PointsIterator) ?Vec2 {
            if (self.index >= self.height * self.length) {
                return null;
            }
            const pos: Vec2 = .{
                @intCast(self.index % self.length),
                @intCast(self.index / self.length),
            };
            self.index += 1;
            return pos;
        }
    };
    fn points(self: Map) PointsIterator {
        return PointsIterator{
            .length = self.map[0].len,
            .height = self.map.len,
            .index = 0,
        };
    }
    fn move(self: @This(), allocator: std.mem.Allocator, pos: Vec2, dir: Vec2) !Vec2 {
        var set = std.AutoArrayHashMap(Vec2, void).init(allocator);
        defer set.deinit();
        var values = std.ArrayList(Vec2).init(allocator);
        defer values.deinit();

        const isVertical = dir[1] != 0;

        try values.append(pos);
        var i: usize = 0;
        while (i < values.items.len) : (i += 1) {
            const p = values.items[i] + dir;
            switch (self.charAt(p).?) {
                '#' => return pos, // Can't move.
                '.' => {},
                'O' => {
                    try values.append(p);
                },
                '[' => {
                    if (set.contains(p)) {
                        continue;
                    }
                    try set.put(p, {});
                    try values.append(p);
                    if (isVertical) {
                        const p2 = p + Vec2{ 1, 0 };
                        try set.put(p2, {});
                        try values.append(p2);
                    }
                },
                ']' => {
                    if (set.contains(p)) {
                        continue;
                    }
                    try set.put(p, {});
                    try values.append(p);
                    if (isVertical) {
                        const p2 = p + Vec2{ -1, 0 };
                        try set.put(p2, {});
                        try values.append(p2);
                    }
                },
                else => unreachable,
            }
        }

        // Move all the points in reverse order.
        reverse(values.items);
        for (values.items) |p| {
            const next = p + dir;
            std.debug.assert(self.charAt(next).? != '#');
            self.setAt(next, self.charAt(p).?);
            self.setAt(p, '.');
        }
        return pos + dir;
    }
};

fn reverse(slice: anytype) void {
    for (0..slice.len / 2) |i| {
        const j = slice.len - i - 1;
        const tmp = slice[i];
        slice[i] = slice[j];
        slice[j] = tmp;
    }
}

fn part1(grid: []const u8, moves: []const u8, allocator: std.mem.Allocator) !u64 {
    var gridIt = std.mem.tokenize(u8, grid, "\n");
    var gridRows = std.ArrayList([]u8).init(allocator);
    defer {
        for (gridRows.items) |row| {
            allocator.free(row);
        }
        gridRows.deinit();
    }
    while (gridIt.next()) |line| {
        const row = try allocator.alloc(u8, line.len);
        std.mem.copyForwards(u8, row, line);
        try gridRows.append(row);
    }
    reverse(gridRows.items);

    var m = Map{ .map = gridRows.items };

    // Find the start pos.
    var startPos = m.findStart();
    print("START POS: {d}\n", .{startPos});

    moves: for (moves) |move| {
        const a = switch (move) {
            '>' => Vec2{ 1, 0 },
            '<' => Vec2{ -1, 0 },
            '^' => Vec2{ 0, 1 },
            'v' => Vec2{ 0, -1 },
            else => continue :moves,
        };
        startPos = try m.move(allocator, startPos, a);
        //print("{c}\n", .{move});
        //m.printMap();
        //print("\n", .{});
    }
    print("\nDONE POS: {d}\n", .{startPos});
    m.printMap();
    print("\n", .{});

    const height: u64 = m.map.len;

    var sum: u64 = 0;
    var pointIt2 = m.points();
    while (pointIt2.next()) |pos| {
        if (m.charAt(pos).? == 'O') {
            sum += 100 * (height - 1 - @as(u64, @intCast(pos[1]))) + @as(u64, @intCast(pos[0]));
        }
    }
    return sum;
}

fn part2(grid: []const u8, moves: []const u8, allocator: std.mem.Allocator) !u64 {
    var gridIt = std.mem.tokenize(u8, grid, "\n");
    var gridRows = std.ArrayList([]u8).init(allocator);
    defer {
        for (gridRows.items) |row| {
            allocator.free(row);
        }
        gridRows.deinit();
    }
    while (gridIt.next()) |line| {
        const row = try allocator.alloc(u8, line.len * 2);
        for (0..line.len) |i| {
            const chars = switch (line[i]) {
                '#' => [2]u8{ '#', '#' },
                '.' => [2]u8{ '.', '.' },
                'O' => [2]u8{ '[', ']' },
                '@' => [2]u8{ '@', '.' },
                else => unreachable,
            };
            row[i * 2] = chars[0];
            row[i * 2 + 1] = chars[1];
        }
        try gridRows.append(row);
    }
    reverse(gridRows.items);

    var m = Map{ .map = gridRows.items };

    // Find the start pos.
    var startPos = m.findStart();
    print("START POS: {d}\n", .{startPos});
    m.printMap();
    print("\n", .{});

    moves: for (moves) |move| {
        const a = switch (move) {
            '>' => Vec2{ 1, 0 },
            '<' => Vec2{ -1, 0 },
            '^' => Vec2{ 0, 1 },
            'v' => Vec2{ 0, -1 },
            else => continue :moves,
        };
        startPos = try m.move(allocator, startPos, a);
        //print("{c}\n", .{move});
        //m.printMap();
        //print("\n", .{});
    }
    print("\nDONE POS: {d}\n", .{startPos});
    m.printMap();
    print("\n", .{});

    const height: u64 = m.map.len;

    var sum: u64 = 0;
    var pointIt2 = m.points();
    while (pointIt2.next()) |pos| {
        if (m.charAt(pos).? == '[') {
            sum += 100 * (height - 1 - @as(u64, @intCast(pos[1]))) + @as(u64, @intCast(pos[0]));
        }
    }
    return sum;
}

fn run(src: []const u8, allocator: std.mem.Allocator) !Result {
    const index = if (std.mem.indexOf(u8, src, "\n\n")) |index| index else return error.InvalidInput;

    const grid = src[0..index];
    const moves = src[index + 2 ..];

    print("\n", .{});
    return Result{
        .part1 = try part1(grid, moves, allocator),
        .part2 = try part2(grid, moves, allocator),
    };
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const result = try run(input, allocator);
    print("Result: {any}\n", .{result});
}

test "example_small" {
    const result = try run(example_small, std.testing.allocator);
    print("Result: {any}\n", .{result});
    if (result.part1) |p1| try std.testing.expectEqual(@as(u64, 2028), p1);
}

test "example_part2" {
    const result = try run(example_part2, std.testing.allocator);
    print("Result: {any}\n", .{result});
}

test "example" {
    const result = try run(example, std.testing.allocator);
    print("Result: {any}\n", .{result});
    if (result.part1) |p1| try std.testing.expectEqual(@as(u64, 10092), p1);
    if (result.part2) |p2| try std.testing.expectEqual(@as(u64, 9021), p2);
}
