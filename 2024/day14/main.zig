const std = @import("std");
const print = std.debug.print;

const input = @embedFile("input.txt");
const example = @embedFile("example.txt");
const example_min = @embedFile("example_min.txt");

const Result = struct {
    part1: ?u64,
    part2: ?u64,
};

const Vec2 = struct {
    x: i64,
    y: i64,
    fn move(self: Vec2, x: i64, y: i64) Vec2 {
        return Vec2{ .x = self.x + x, .y = self.y + y };
    }
};

const Robot = struct {
    pos: Vec2,
    vel: Vec2,
};

fn parseVec2(src: []const u8) !Vec2 {
    var numIt = std.mem.split(u8, src[std.mem.indexOf(u8, src, "=").? + 1 ..], ",");
    return Vec2{
        .x = try std.fmt.parseInt(i64, numIt.next().?, 10),
        .y = try std.fmt.parseInt(i64, numIt.next().?, 10),
    };
}

fn move(robots: []Robot, length: i64, height: i64, turns: i64) !void {
    var i: usize = 0;
    while (i < robots.len) : (i += 1) {
        var robot = &robots[i];
        var pos = robot.pos.move(robot.vel.x * turns, robot.vel.y * turns);
        pos.x = @rem(pos.x, length);
        pos.y = @rem(pos.y, height);
        if (pos.x < 0) pos.x += @as(i64, @intCast(length));
        std.debug.assert(pos.x >= 0);
        if (pos.y < 0) pos.y += @as(i64, @intCast(height));
        std.debug.assert(pos.y >= 0);
        robot.pos = pos;
    }
}

fn run(src: []const u8, allocator: std.mem.Allocator, length: usize, height: usize) !Result {
    print("\n", .{});

    var robots = std.ArrayList(Robot).init(allocator);
    defer robots.deinit();

    var lineIter = std.mem.tokenizeAny(u8, src, "\n");
    while (lineIter.next()) |line| {
        var partIt = std.mem.split(u8, line, " ");
        try robots.append(Robot{
            .pos = try parseVec2(partIt.next().?),
            .vel = try parseVec2(partIt.next().?),
        });
    }
    var result: Result = std.mem.zeroes(Result);
    result.part1 = 0;

    var map = std.AutoArrayHashMap(Vec2, usize).init(allocator);
    defer map.deinit();

    // Run the loop.
    const turns: i64 = 100;
    const xmid = length / 2;
    const ymid = height / 2;
    var quadrants: @Vector(4, u64) = @splat(0);
    var robotsPart1 = try robots.clone();
    defer robotsPart1.deinit();
    try move(robotsPart1.items, @intCast(length), @intCast(height), turns);

    for (robotsPart1.items) |robot| {
        const pos = robot.pos;
        if (pos.y < ymid) {
            if (pos.x > xmid) {
                quadrants[0] += 1;
            } else if (pos.x < xmid) {
                quadrants[1] += 1;
            }
        } else if (pos.y > ymid) {
            if (pos.x > xmid) {
                quadrants[2] += 1;
            } else if (pos.x < xmid) {
                quadrants[3] += 1;
            }
        }
    }

    // Print out each turn.
    var robotsPart2 = try robots.clone();
    defer robotsPart2.deinit();
    // NEEDED 7603 generations for the tree.
    for (0..10) |turn| {
        print("---- {d} ----\n", .{turn});
        try move(robotsPart2.items, @intCast(length), @intCast(height), 1);

        var visited = try std.bit_set.DynamicBitSet.initEmpty(allocator, length * height);
        defer visited.deinit();
        for (robotsPart2.items) |robot| {
            visited.set(@intCast(robot.pos.x + robot.pos.y * @as(i64, @intCast(length))));
        }

        for (0..height) |y| {
            for (0..length) |x| {
                const index: usize = x + y * length;
                const char: u8 = if (visited.isSet(index)) '#' else '.';
                print("{c}", .{char});
            }
            print("\n", .{});
        }
        print("\n\n", .{});
    }

    print("quadrants {any}\n", .{quadrants});
    // Debug
    result.part1 = @reduce(.Mul, quadrants);
    return result;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const result = try run(input, allocator, 101, 103);
    print("Result: {any}\n", .{result});
}

test "example_min" {
    const result = try run(example_min, std.testing.allocator, 11, 7);
    print("Result: {any}\n", .{result});
}

test "example" {
    const result = try run(example, std.testing.allocator, 11, 7);
    print("Result: {any}\n", .{result});
    if (result.part1) |p1| try std.testing.expectEqual(@as(u64, 12), p1);
}
