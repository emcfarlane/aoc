const std = @import("std");
const print = std.debug.print;

const input = @embedFile("input.txt");
const example = @embedFile("example.txt");
const example2 = @embedFile("example2.txt");

const Result = struct {
    part1: ?u64,
    part2: ?u64,
};

const Vec2 = @Vector(2, i32);

const dirs = [_]Vec2{ Vec2{ 0, 1 }, Vec2{ 1, 0 }, Vec2{ 0, -1 }, Vec2{ -1, 0 } };
const dirChars = [_]u8{ 'v', '>', '^', '<' };

const Map = struct {
    map: []const u8,
    width: usize,
    height: usize,
    fn index(self: @This(), pos: Vec2) ?usize {
        if (pos[0] < 0 or pos[1] < 0) return null;
        const x: usize = @intCast(pos[0]);
        const y: usize = @intCast(pos[1]);
        if (y >= self.height or x >= self.width) return null;
        return x + y * (self.width + 1); // +1 for newline.
    }
    fn charAt(self: @This(), pos: Vec2) ?u8 {
        return self.map[self.index(pos) orelse return null];
    }
};

//const Step = struct {
//    dirs: dirSet,
//    cost: usize, // 1 for step, 1000 for each 90 deg turns.
//};
//const Trail = std.AutoArrayHashMap(Vec2, Step); // pos -> steps

const Trail = struct {
    prev: ?*Trail,
    pos: Vec2,
    dir: usize,
    cost: usize,
};
const TrailPool = struct {
    allocator: std.mem.Allocator,
    pool: std.ArrayList(*Trail),
    fn init(allocator: std.mem.Allocator) TrailPool {
        return TrailPool{
            .allocator = allocator,
            .pool = std.ArrayList(*Trail).init(allocator),
        };
    }
    fn deinit(self: *TrailPool) void {
        for (self.pool.items) |trail| {
            self.allocator.destroy(trail);
        }
        self.pool.deinit();
    }
    fn new(self: *TrailPool, prev: ?*Trail, pos: Vec2, dir: usize, cost: usize) !*Trail {
        const trail = try self.allocator.create(Trail);
        trail.* = Trail{
            .prev = prev,
            .pos = pos,
            .dir = dir,
            .cost = cost,
        };
        try self.pool.append(trail);
        return trail;
    }
};
fn lessTrail(context: void, a: *Trail, b: *Trail) std.math.Order {
    _ = context;
    return std.math.order(a.cost, b.cost);
}
const Queue = std.PriorityQueue(*Trail, void, lessTrail);

//fn Queue(comptime T: type) type {
//    return struct {
//        const Self = @This();
//        allocator: std.mem.Allocator,
//        head: std.ArrayListUnmanaged(T),
//        tail: std.ArrayListUnmanaged(T),
//        fn init(allocator: std.mem.Allocator) Self {
//            return Self{
//                .allocator = allocator,
//                .head = std.ArrayListUnmanaged(T){},
//                .tail = std.ArrayListUnmanaged(T){},
//            };
//        }
//        fn deinit(self: *Self) void {
//            self.head.deinit(self.allocator);
//            self.tail.deinit(self.allocator);
//        }
//        fn push(self: *Self, value: T) !void {
//            try self.tail.append(self.allocator, value);
//        }
//        fn pop(self: *Self) !T {
//            if (self.head.items.len == 0) {
//                const tmp = self.head;
//                self.head = self.tail;
//                self.tail = tmp;
//                // Reverse the list.
//                reverse(self.head.items);
//            }
//            return self.head.pop();
//        }
//        fn count(self: *Self) usize {
//            return self.head.items.len + self.tail.items.len;
//        }
//    };
//}
//fn reverse(slice: anytype) void {
//    for (0..slice.len / 2) |i| {
//        const j = slice.len - i - 1;
//        const tmp = slice[i];
//        slice[i] = slice[j];
//        slice[j] = tmp;
//    }
//}

fn run(src: []const u8, allocator: std.mem.Allocator) !Result {
    print("\n", .{});

    const width = std.mem.indexOf(u8, src, "\n") orelse return error.@"Invalid input";
    const length = width + 1;
    const height = std.mem.count(u8, src, "\n") + 1;
    print("Width: {d}, Height: {d}\n", .{ width, height });
    const map = Map{
        .map = src,
        .width = width,
        .height = height,
    };

    // Find the goal.
    const startIndex = std.mem.indexOf(u8, src, "S") orelse return error.@"Invalid input";
    const endIndex = std.mem.indexOf(u8, src, "E") orelse return error.@"Invalid input";
    print("Start index: {d}, End index: {d}\n", .{ startIndex, endIndex });
    const end = Vec2{ @intCast(endIndex % length), @intCast(endIndex / length) };
    print("End: {d}x{d} => {?c}\n", .{ end[0], end[1], map.charAt(end) });
    const start = Vec2{ @intCast(startIndex % length), @intCast(startIndex / length) };
    print("Start: {d}x{d} => {?c}\n", .{ start[0], start[1], map.charAt(start) });

    //var trail = Trail.init(allocator);
    //defer trail.deinit();
    //var queue = Queue(Vec2).init(allocator);
    //defer queue.deinit();
    //
    //try trail.put(start, Step{ .dirs = makeDirSet(1), .cost = 0 });
    //try queue.push(start);

    var goalMin: ?usize = null;
    var trailPool = TrailPool.init(allocator);
    defer trailPool.deinit();
    var trails = std.ArrayList(*Trail).init(allocator);
    defer trails.deinit();
    var queue = Queue.init(allocator, {});
    defer queue.deinit();

    const Key = struct {
        pos: Vec2,
        dir: usize,
    };
    var costs = std.AutoHashMap(Key, usize).init(allocator);
    defer costs.deinit();

    const head = try trailPool.new(null, start, 1, 0);
    try queue.add(head);

    while (queue.count() > 0) {
        const trail = queue.remove();
        if (std.meta.eql(trail.pos, end)) {
            print("Found end at {any}\n", .{trail});
            if (goalMin == null) goalMin = trail.cost;
            std.debug.assert(goalMin == trail.cost);
            try trails.append(trail);
            continue;
        }
        // TODO: must do BFS here.

        if (goalMin != null and trail.cost > goalMin.?) {
            print("Skipping trail {any}\n", .{trail});
            continue;
        }
        const key = Key{ .pos = trail.pos, .dir = trail.dir };
        if (costs.get(key)) |cost| {
            if (trail.cost > cost) {
                print("Skipping due to cost {any} > {any}\n", .{ trail.cost, cost });
                continue;
            }
        }
        try costs.put(key, trail.cost);

        //const nextSteps = [_]Step{
        //    Step{ .dirs = makeDirSet(dir), .cost = step.cost + 1 }, // forward
        //    Step{ .dirs = makeDirSet((dir + 4 - 1) % 4), .cost = step.cost + 1 + 1000 }, // left
        //    Step{ .dirs = makeDirSet((dir + 1) % 4), .cost = step.cost + 1 + 1000 }, // right
        //};
        const nextDirs = [_]usize{ trail.dir, (trail.dir + 4 - 1) % 4, (trail.dir + 1) % 4 };
        const nextCosts = [_]usize{ trail.cost + 1, trail.cost + 1 + 1000, trail.cost + 1 + 1000 };
        for (nextDirs, nextCosts) |nextDir, nextCost| {
            const next = trail.pos + dirs[nextDir];
            const nextChar = map.charAt(next) orelse continue;
            if (nextChar == '#' or nextChar == 'S') continue;

            const nextTrail = try trailPool.new(trail, next, nextDir, nextCost);
            try queue.add(nextTrail);

            //const nstep = trail.getPtr(next);
            //if (nstep == null or nextCost < nstep.?.cost) {
            //    try trail.put(next, Step{ .dirs = makeDirSet(nextDir), .cost = nextCost });
            //    try queue.push(next);
            //} else if (nextCost == nstep.?.cost) {
            //    nstep.?.dirs.set(nextDir);
            //    print("Union: {any}\n", .{nstep.?});
            //}
        }
    }
    print("Goal min: {?d} with {d} trails\n", .{ goalMin, trails.items.len });
    var points = std.AutoHashMap(Vec2, void).init(allocator);
    defer points.deinit();
    for (trails.items) |trail| {
        // Print the trail.
        var display = try allocator.dupe(u8, map.map);
        defer allocator.free(display);
        var t: ?*Trail = trail;
        while (t != null) {
            try points.put(t.?.pos, {});
            display[map.index(t.?.pos).?] = dirChars[t.?.dir];
            t = t.?.prev;
        }
        print("\n{s}\n", .{display});
    }

    // Print the trail.
    //var display = try allocator.dupe(u8, map.map);
    //defer allocator.free(display);
    //try queue.push(end);
    //while (queue.count() > 0) {
    //    const pos = try queue.pop();
    //    if (std.meta.eql(pos, start)) continue;
    //    print("Pos: {d}x{d}\n", .{ pos[0], pos[1] });
    //    const step = trail.get(pos) orelse return error.@"Invalid trail";

    //    var dirIt = step.dirs.iterator(.{});
    //    while (dirIt.next()) |dir| {
    //        display[map.index(pos).?] = dirChars[dir]; // TODO: fix last one wins.
    //        const nextPos = pos + dirs[dir];
    //        try queue.push(nextPos);
    //    }
    //}
    //print("MAP:\n{s}\n", .{display});
    //for (0..height) |i| {
    //    for (0..width) |j| {
    //        const pos = Vec2{ @intCast(j), @intCast(i) };
    //        var char = map.charAt(pos) orelse return error.@"Invalid map";
    //        if (trail.get(pos)) |step| {
    //            char = '0' + @as(u8, @intCast(step.dirs.count()));
    //        }
    //        print("{c}", .{char});
    //    }
    //    print("\n", .{});
    //}
    //var pos = end;
    //while (!std.meta.eql(pos, start)) {
    //    const step = trail.get(pos) orelse return error.@"Invalid trail";
    //    display[map.index(pos).?] = dirChars[step.dir];
    //    pos = pos - dirs[step.dir];
    //}

    var result: Result = std.mem.zeroes(Result);
    result.part1 = goalMin.?;
    result.part2 = points.count();
    return result;
}

// 133588 is too high.
// 133588
// 133584

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const result = try run(input, allocator);
    print("Result: {any}\n", .{result});
}

test "example1" {
    const result = try run(example, std.testing.allocator);
    print("Result: {any}\n", .{result});
    if (result.part1) |p1| try std.testing.expectEqual(@as(u64, 7036), p1);
    if (result.part2) |p2| try std.testing.expectEqual(@as(u64, 45), p2);
}

test "example2" {
    const result2 = try run(example2, std.testing.allocator);
    print("Result: {any}\n", .{result2});
    if (result2.part1) |p1| try std.testing.expectEqual(@as(u64, 11048), p1);
    if (result2.part2) |p2| try std.testing.expectEqual(@as(u64, 64), p2);
}

test "thisone" {
    const testdata =
        \\#######
        \\##...E#
        \\##.#.##
        \\#S...##
        \\#######
    ;
    const result = try run(testdata, std.testing.allocator);
    print("Result: {any}\n", .{result});
}
