const std = @import("std");
const print = std.debug.print;

const input = @embedFile("input.txt");
const example = @embedFile("example.txt");
const example2 = @embedFile("example2.txt");

const Result = struct {
    part1: ?u64,
    part2: ?u64,
};

const Pos = struct {
    x: i64,
    y: i64,

    fn add(a: Pos, b: Pos) Pos {
        return Pos{ .x = a.x + b.x, .y = a.y + b.y };
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
    fn charAt(self: @This(), pos: Pos) ?u8 {
        if (!self.inBounds(pos)) {
            return null;
        }
        return self.map[@intCast(pos.y)][@intCast(pos.x)];
    }
    fn intAt(self: @This(), pos: Pos) ?i64 {
        if (self.charAt(pos)) |c| {
            const str = [_]u8{c};
            return std.fmt.parseInt(i64, str[0..], 10) catch null;
        }
        return null;
    }
    fn printTrail(self: @This(), trail: []Pos, allocator: std.mem.Allocator) !void {
        var positions = std.AutoArrayHashMap(Pos, void).init(allocator);
        defer positions.deinit();

        for (trail) |pos| {
            try positions.put(pos, {});
        }
        for (0..self.map.len) |y| {
            for (0..self.map[y].len) |x| {
                const pos = Pos{ .x = @intCast(x), .y = @intCast(y) };
                if (positions.contains(pos)) {
                    print("{c}", .{self.map[y][x]});
                } else {
                    print(".", .{});
                }
            }
            print("\n", .{});
        }
    }
};

fn run(src: []const u8, allocator: std.mem.Allocator) !Result {
    print("\n", .{});

    var grid = std.ArrayList([]const u8).init(allocator);
    defer grid.deinit();

    var trails = std.ArrayList([]Pos).init(allocator);
    defer {
        for (trails.items) |pos| {
            allocator.free(pos);
        }
        trails.deinit();
    }

    var linesIt = std.mem.splitSequence(u8, src, "\n");
    while (linesIt.next()) |line| {
        for (0..line.len) |x| {
            if (line[x] == '0') {
                var trail = try allocator.alloc(Pos, 1);
                trail[0] = Pos{ .x = @intCast(x), .y = @intCast(grid.items.len) };
                try trails.append(trail);
            }
        }
        try grid.append(line);
    }

    const map = Map{ .map = grid.items };

    var trailHeads = std.AutoHashMap([2]Pos, u64).init(allocator);
    defer trailHeads.deinit();

    print("trails: {d}\n", .{trails.items.len});

    var result: Result = std.mem.zeroes(Result);
    while (trails.items.len > 0) {
        const trail = trails.pop();
        defer allocator.free(trail);

        const pos = trail[trail.len - 1];
        const height = map.intAt(pos) orelse unreachable;
        if (height == 9) {
            const trailHead = [2]Pos{ trail[0], pos };
            try map.printTrail(trail, allocator);
            try trailHeads.put(trailHead, (trailHeads.get(trailHead) orelse 0) + 1);
            continue;
        }

        const directions = [_]Pos{ .{ .x = 0, .y = 1 }, .{ .x = 1, .y = 0 }, .{ .x = 0, .y = -1 }, .{ .x = -1, .y = 0 } };
        for (directions) |dir| {
            const newPos = pos.add(dir);
            if (map.intAt(newPos)) |newHeight| {
                if (newHeight > height and newHeight - height == 1) {
                    var newTrail = try allocator.alloc(Pos, trail.len + 1);
                    for (0..trail.len) |i| {
                        newTrail[i] = trail[i];
                    }
                    newTrail[trail.len] = newPos;
                    try trails.append(newTrail);
                }
            }
        }
    }

    var it = trailHeads.iterator();
    var sum: u64 = 0;
    while (it.next()) |entry| {
        print("entry: {any} {d}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
        sum += entry.value_ptr.*;
    }
    result.part1 = trailHeads.count();
    result.part2 = sum;
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
    if (result.part1) |p1| try std.testing.expectEqual(@as(u64, 36), p1);
    if (result.part2) |p2| try std.testing.expectEqual(@as(u64, 81), p2);
}

test "example2" {
    const result = try run(example2, std.testing.allocator);
    print("Result: {any}\n", .{result});
    if (result.part1) |p1| try std.testing.expectEqual(@as(u64, 2), p1);
    if (result.part2) |p2| try std.testing.expectEqual(@as(u64, 2), p2);
}
