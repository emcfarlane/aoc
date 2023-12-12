const std = @import("std");
const print = std.debug.print;

const input = @embedFile("input.txt");
const example = @embedFile("example.txt");

const Result = struct {
    part1: u64,
    part2: u64,
};

fn run(src: []const u8, allocator: std.mem.Allocator) !Result {
    var result: Result = std.mem.zeroes(Result);

    const firstLineIndex = std.mem.indexOf(u8, src, "\n").?;
    var timesIter = std.mem.tokenizeAny(u8, src["Time: ".len..firstLineIndex], " ");
    var times = std.ArrayList(i64).init(allocator);
    defer times.deinit();
    var oneTimeToken = std.ArrayList(u8).init(allocator);
    defer oneTimeToken.deinit();
    while (timesIter.next()) |token| {
        if (token.len == 0) {
            continue;
        }
        print("token: {s}\n", .{token});
        const time = try std.fmt.parseInt(i64, token, 10);
        try times.append(time);
        try oneTimeToken.appendSlice(token);
    }
    const oneTime = try std.fmt.parseInt(i64, oneTimeToken.items, 10);

    var distsIter = std.mem.tokenizeAny(u8, src[(firstLineIndex + "Distance: ".len)..], " \n");
    var dists = std.ArrayList(i64).init(allocator);
    defer dists.deinit();
    var oneDistToken = std.ArrayList(u8).init(allocator);
    defer oneDistToken.deinit();
    while (distsIter.next()) |token| {
        if (token.len == 0) {
            continue;
        }
        print("token: {s}\n", .{token});
        const dist = try std.fmt.parseInt(i64, token, 10);
        try dists.append(dist);
        try oneDistToken.appendSlice(token);
    }
    const oneDist = try std.fmt.parseInt(i64, oneDistToken.items, 10);

    result.part1 = 0;
    print("Times: {any}\n", .{times.items});
    print("Dists: {any}\n", .{dists.items});

    // distance = (holdFor * (time - holdFor))
    //          = (2 * (7 - 2)) == 10
    //          = (3 * (7 - 3)) == 12
    //          = (4 * (7 - 4)) == 12
    //          = (5 * (7 - 5)) == 10
    //          = (6 * (7 - 6)) == 6
    //          = (7 * (7 - 7)) == 0
    //        d = x*t - x**2
    //
    //  x^2 - 7x + 9 = 0
    result.part1 = 1;
    for (times.items, dists.items) |time, dist| {
        result.part1 *= try calcRange(time, dist);
    }
    result.part2 = try calcRange(oneTime, oneDist);
    return result;
}

fn calcRange(time: i64, dist: i64) !u64 {
    const b = -@as(f64, @floatFromInt(time));
    const c = @as(f64, @floatFromInt(dist));
    const discriminant = std.math.sqrt(b * b - 4 * c);
    const x1 = (-b + discriminant) / 2;
    const x2 = (-b - discriminant) / 2;
    const ix1 = @as(u64, @intFromFloat(@round(x1 - 0.50000001)));
    const ix2 = @as(u64, @intFromFloat(@round(x2 + 0.5)));
    return ix1 - ix2 + 1;
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
    try std.testing.expectEqual(@as(u64, 288), result.part1);
    try std.testing.expectEqual(@as(u64, 71503), result.part2);
}
