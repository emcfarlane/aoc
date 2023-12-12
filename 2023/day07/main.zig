const std = @import("std");
const print = std.debug.print;

const input = @embedFile("input.txt");
const example = @embedFile("example.txt");

const Result = struct {
    part1: u64,
    part2: u64,
};

const HandType = enum(u64) {
    HighCard,
    OnePair,
    TwoPair,
    ThreeOfAKind,
    FullHouse,
    FourOfAKind,
    FiveOfAKind,
};

fn cardValue(card: u8) u8 {
    return switch (card) {
        '2' => 2,
        '3' => 3,
        '4' => 4,
        '5' => 5,
        '6' => 6,
        '7' => 7,
        '8' => 8,
        '9' => 9,
        'T' => 10,
        'J' => 11,
        'Q' => 12,
        'K' => 13,
        'A' => 14,
        else => {
            unreachable;
        },
    };
}

fn classify(hand: []const u8) HandType {
    var counts = std.mem.zeroes([13]u8);
    for (hand) |card| {
        const value = cardValue(card);
        counts[value - 2] += 1;
    }
    var handType = HandType.HighCard;
    for (counts) |count| {
        switch (count) {
            5 => handType = HandType.FiveOfAKind,
            4 => handType = HandType.FourOfAKind,
            3 => {
                if (handType == HandType.OnePair) {
                    handType = HandType.FullHouse;
                } else {
                    handType = HandType.ThreeOfAKind;
                }
            },
            2 => {
                if (handType == HandType.ThreeOfAKind) {
                    handType = HandType.FullHouse;
                } else if (handType == HandType.OnePair) {
                    handType = HandType.TwoPair;
                } else {
                    handType = HandType.OnePair;
                }
            },
            0, 1 => {},
            else => {
                std.debug.panic("invalid count: {d}", .{count});
            },
        }
    }
    return handType;
}

fn cmpLine(ctx: void, a: []const u8, b: []const u8) bool {
    _ = ctx;
    const handTypeA = classify(a[0..5]);
    const handTypeB = classify(b[0..5]);
    if (@intFromEnum(handTypeA) != @intFromEnum(handTypeB)) {
        return @intFromEnum(handTypeA) < @intFromEnum(handTypeB);
    }
    print("handTypeA: {any}\n", .{(handTypeA)});
    print("handTypeB: {any}\n", .{(handTypeB)});
    for (0..5) |i| {
        const cardA = cardValue(a[i]);
        const cardB = cardValue(b[i]);
        if (cardA != cardB) {
            return cardA < cardB;
        }
    }
    unreachable;
}

fn run(src: []const u8, allocator: std.mem.Allocator) !Result {
    print("\n", .{});
    var result: Result = std.mem.zeroes(Result);

    var lineIter = std.mem.tokenizeAny(u8, src, "\n");
    var lines = std.ArrayList([]const u8).init(allocator);
    defer lines.deinit();
    while (lineIter.next()) |line| {
        try lines.append(line);
    }

    // SORT
    std.sort.heap([]const u8, lines.items, {}, cmpLine);
    for (lines.items, 0..) |line, pos| {
        const bid = try std.fmt.parseInt(u64, line[6..], 10);
        const rank = pos + 1;
        result.part1 += bid * rank;
        print("{s}\n", .{line});
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

test "example" {
    const result = try run(example, std.testing.allocator);
    print("Result: {any}\n", .{result});
    try std.testing.expectEqual(@as(u64, 6440), result.part1);
    try std.testing.expectEqual(@as(u64, 0), result.part2);
}
