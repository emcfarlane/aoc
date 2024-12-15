const std = @import("std");
const print = std.debug.print;

const input = @embedFile("input.txt");
const example = @embedFile("example.txt");

const Result = struct {
    part1: usize,
    part2: i64,
};

const Pos = struct {
    x: usize,
    y: usize,
};

const Tile = struct {
    up: bool,
    down: bool,
    left: bool,
    right: bool,
};

fn tileDirection(char: u8) Tile {
    return switch (char) {
        '|' => .{ .up = true, .down = true, .left = false, .right = false }, // is a vertical pipe connecting north and south.
        '-' => .{ .up = false, .down = false, .left = true, .right = true }, // is a horizontal pipe connecting east and west.
        'L' => .{ .up = true, .down = false, .left = false, .right = true }, // is a 90-degree bend connecting north and east.
        'J' => .{ .up = true, .down = false, .left = true, .right = false }, // is a 90-degree bend connecting north and west.
        '7' => .{ .up = false, .down = true, .left = true, .right = false }, // is a 90-degree bend connecting south and west.
        'F' => .{ .up = false, .down = true, .left = false, .right = true }, // is a 90-degree bend connecting south and east.
        '.' => .{ .up = false, .down = false, .left = false, .right = false }, // is grou.nd; there is .no pipe in th.is tile.
        'S' => .{ .up = true, .down = true, .left = true, .right = true }, // is the starting position of the animal; there is a pipe on this tile, but your sketch doesn't show what shape the pipe has.
        else => unreachable,
    };
}

const Value = struct {
    char: u8,
    visited: bool,
};

const Map = struct {
    field: *std.ArrayList(std.ArrayList(Value)),

    fn createPos(self: Map, x: usize, y: usize) ?Pos {
        if (y >= self.field.items.len) {
            return null;
        }
        const line = self.field.items[@intCast(y)];
        if (x >= line.items.len) {
            return null;
        }
        return Pos{ .x = x, .y = y };
    }
    fn get(self: Map, pos: Pos) ?Value {
        if (pos.y >= self.field.items.len) {
            return null;
        }
        const line = self.field.items[@intCast(pos.y)];
        if (pos.x >= line.items.len) {
            return null;
        }
        return line.items[@intCast(pos.x)];
    }
    fn getChar(self: Map, pos: Pos) ?u8 {
        const val = self.get(pos) orelse return null;
        return val.char;
    }
    fn visit(self: *Map, pos: Pos) void {
        const line = self.field.items[@intCast(pos.y)];
        line.items[@intCast(pos.x)].visited = true;
    }
    fn isFree(self: Map, pos: Pos) bool {
        const val = self.get(pos) orelse return false;
        return !val.visited;
    }
};

fn run(src: []const u8, allocator: std.mem.Allocator) !Result {
    print("\n", .{});
    var result: Result = std.mem.zeroes(Result);

    var field = std.ArrayList(std.ArrayList(Value)).init(allocator);
    defer field.deinit();
    defer {
        for (field.items) |*items| {
            items.deinit();
        }
    }
    var map = Map{ .field = &field };
    var lineIter = std.mem.tokenizeAny(u8, src, "\n");
    var sPos: Pos = std.mem.zeroes(Pos);
    var x: usize = 0;
    while (lineIter.next()) |line| {
        var items = std.ArrayList(Value).init(allocator);
        for (line, 0..) |char, y| {
            try items.append(Value{ .char = char, .visited = false });
            if (char == 'S') {
                sPos = Pos{ .x = x, .y = y };
            }
        }
        try field.append(items);
        x += 1;
    }

    var steps: usize = 0;
    var next = std.ArrayList(Pos).init(allocator);
    defer next.deinit();
    var after = std.ArrayList(Pos).init(allocator);
    defer after.deinit();
    try next.append(sPos);
    while (next.items.len > 0) {
        print("LOOP: {any}\n", .{next.items.len});
        for (next.items) |pos| {
            if (!map.isFree(pos)) {
                print("GOT SOMETHING!: {any}\n", .{pos});
                result.part1 = steps;
                continue;
            }
            map.visit(pos);
            const dir = tileDirection(map.getChar(pos).?);
            print("POS: {c} {any} {any}\n", .{ map.getChar(pos).?, pos, dir });
            if (dir.up and pos.y > 0) {
                if (map.createPos(pos.x, pos.y - 1)) |up| {
                    print("UP: {any}\n", .{up});
                    if (map.getChar(up)) |char| {
                        print("UP CHAR: {any}\n", .{char});
                        if (tileDirection(char).down and map.isFree(up)) {
                            print("UP FREE: {any}\n", .{up});
                            try after.append(up);
                        }
                    }
                }
            }
            if (dir.down) {
                if (map.createPos(pos.x, pos.y + 1)) |down| {
                    if (map.getChar(down)) |char| {
                        if (tileDirection(char).up and map.isFree(down)) {
                            try after.append(down);
                        }
                    }
                }
            }
            if (dir.left and pos.x > 0) {
                if (map.createPos(pos.x - 1, pos.y)) |left| {
                    if (map.getChar(left)) |char| {
                        if (tileDirection(char).right and map.isFree(left)) {
                            try after.append(left);
                        }
                    }
                }
            }
            if (dir.right) {
                if (map.createPos(pos.x + 1, pos.y)) |right| {
                    if (map.getChar(right)) |char| {
                        if (tileDirection(char).left and map.isFree(right)) {
                            try after.append(right);
                        }
                    }
                }
            }
        }
        next.clearAndFree();
        const tmp = next;
        next = after;
        after = tmp;
        steps += 1;
        print("Steps: {any}\n", .{steps});
    }
    result.part2 = 0;
    return result;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const result = try run(input, allocator);
    print("Result: {any}\n", .{result});
}

test "example1" {
    const src = (
        \\-L|F7  0
        \\7S-7|  1
        \\L|7||  2
        \\-L-J|  3
        \\L|-JF  4
        \\.....
        \\.....
        \\.....
        \\.....
    );
    const result = try run(src, std.testing.allocator);
    print("Result: {any}\n", .{result});
    try std.testing.expectEqual(@as(usize, 4), result.part1);
}

test "example2" {
    const src = (
        \\7-F7-
        \\.FJ|7
        \\SJLL7
        \\|F--J
        \\LJ.LJ
    );
    const result = try run(src, std.testing.allocator);
    print("Result: {any}\n", .{result});
    try std.testing.expectEqual(@as(usize, 8), result.part1);
}
