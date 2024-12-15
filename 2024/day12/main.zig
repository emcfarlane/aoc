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
    fn move(a: Pos, x: i64, y: i64) Pos {
        return Pos{ .x = a.x + x, .y = a.y + y };
    }
    fn neighbours(pos: Pos) [4]Pos {
        return [_]Pos{
            Pos{ .x = pos.x, .y = pos.y - 1 },
            Pos{ .x = pos.x, .y = pos.y + 1 },
            Pos{ .x = pos.x - 1, .y = pos.y },
            Pos{ .x = pos.x + 1, .y = pos.y },
        };
    }
    fn index(self: Pos, length: usize) usize {
        return @intCast(self.y * @as(i64, @intCast(length)) + self.x);
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
    fn perimiter(self: @This(), pos: Pos) u64 {
        const c = self.charAt(pos) orelse return 0;
        var length: u64 = 0;
        for (pos.neighbours()) |p| {
            if (self.charAt(p)) |v| {
                if (c == v) {
                    continue; // Not a perimiter.
                }
            }
            length += 1;
        }
        return length;
    }
    fn isCorner(self: @This(), pos: Pos, x: i64, y: i64, tox: i64, toy: i64) bool {
        //  ...
        //  .AA
        //  .AA
        //
        const p = self.charAt(pos) orelse return false;

        const a = self.charAt(pos.move(x, y)) orelse '.';
        const posTo = pos.move(tox, toy);
        const b = self.charAt(posTo) orelse '.';
        const c = self.charAt(posTo.move(x, y)) orelse '.';
        print("\n\t{c}{c}\n\t{c}{c}\n", .{ c, a, b, p });
        if (p == a) {
            print("\t=> false\n", .{});
            return false;
        }
        if (p != b) {
            print("\t=> true\n", .{});
            return true;
        }
        if (p == c) {
            print("\t=> true\n", .{});
            return true;
        }
        print("\t=> false\n", .{});
        return false;
    }
    fn permiiter2(self: @This(), pos: Pos) u64 {
        var length: u64 = 0;
        print("---\n", .{});
        // Check UP.
        print("↑", .{});
        if (self.isCorner(pos, 0, 1, -1, 0)) {
            length += 1;
        }
        // Check RIGHT.
        print("→", .{});
        if (self.isCorner(pos, 1, 0, 0, -1)) {
            length += 1;
        }
        // Check DOWN.
        print("↓", .{});
        if (self.isCorner(pos, 0, -1, -1, 0)) {
            length += 1;
        }
        // Check LEFT.
        print("←", .{});
        if (self.isCorner(pos, -1, 0, 0, -1)) {
            length += 1;
        }
        print("\n", .{});
        for (0..3) |i| {
            for (0..3) |j| {
                const p = pos.move(@as(i64, @intCast(i)) - 1, @as(i64, @intCast(j)) - 1);
                print("{c}", .{self.charAt(p) orelse '.'});
            }
            print("\n", .{});
        }
        print("=> {d} edges\n", .{length});
        return length;
    }
    const PointsIterator = struct {
        length: usize,
        height: usize,
        index: usize,
        fn next(self: *PointsIterator) ?Pos {
            if (self.index >= self.height * self.length) {
                return null;
            }
            const pos = Pos{
                .x = @intCast(self.index % self.length),
                .y = @intCast(self.index / self.length),
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
};

fn run(src: []const u8, allocator: std.mem.Allocator) !Result {
    print("\n", .{});

    var grid = std.ArrayList([]const u8).init(allocator);
    defer grid.deinit();

    var linesIt = std.mem.tokenizeSequence(u8, src, "\n");
    while (linesIt.next()) |line| {
        try grid.append(line);
    }

    const length = grid.items[0].len;
    const height = grid.items.len;

    var visited = try std.bit_set.DynamicBitSet.initEmpty(allocator, length * height);
    defer visited.deinit();

    const map = Map{ .map = grid.items };

    var regions = std.ArrayList([]Pos).init(allocator);
    defer {
        for (regions.items) |region| {
            allocator.free(region);
        }
        regions.deinit();
    }

    var pointsIt = map.points();
    while (pointsIt.next()) |pos| {
        if (visited.isSet(pos.index(length))) {
            continue;
        }
        var region = std.ArrayList(Pos).init(allocator);
        errdefer region.deinit();

        var points = std.ArrayList(Pos).init(allocator);
        defer points.deinit();
        try points.append(pos);

        while (points.items.len > 0) {
            const p = points.pop();
            print("Point: {d} {d}\n", .{ p.x, p.y });
            std.debug.assert(map.charAt(p).? == map.charAt(pos).?);
            std.debug.assert(map.inBounds(p));
            if (visited.isSet(p.index(length))) {
                continue;
            }
            visited.set(p.index(length));
            try region.append(p);

            for (p.neighbours()) |n| {
                if (!map.inBounds(n) or visited.isSet(n.index(length))) {
                    continue;
                }
                if (map.charAt(n).? == map.charAt(pos).?) {
                    try points.append(n);
                }
            }
        }
        try regions.append(try region.toOwnedSlice());
    }

    // Sum is the Area x Perimiter.
    var result: Result = std.mem.zeroes(Result);
    var part1: u64 = 0;
    var part2: u64 = 0;
    for (regions.items) |region| {
        const area: u64 = @intCast(region.len);
        var perimiter: u64 = 0;
        var perimiter2: u64 = 0;
        for (region) |pos| {
            perimiter += map.perimiter(pos);
            perimiter2 += map.permiiter2(pos);
        }
        print("Region {?c}: {d} {d}\n", .{ map.charAt(region[0]), area, perimiter });
        part1 += area * perimiter;
        part2 += area * perimiter2;
    }
    result.part1 = part1;
    result.part2 = part2;
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
    if (result.part1) |p1| try std.testing.expectEqual(@as(u64, 140), p1);
    if (result.part2) |p2| try std.testing.expectEqual(@as(u64, 80), p2);
}

test "example2" {
    const result = try run(example2, std.testing.allocator);
    print("Result: {any}\n", .{result});
    if (result.part1) |p1| try std.testing.expectEqual(@as(u64, 1930), p1);
    if (result.part2) |p2| try std.testing.expectEqual(@as(u64, 1206), p2);
}
