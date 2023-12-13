const std = @import("std");
const print = std.debug.print;

const input = @embedFile("input.txt");
const example = @embedFile("example.txt");
const example2 = @embedFile("example2.txt");
const example3 = @embedFile("example3.txt");

const Result = struct {
    part1: u64,
    part2: u64,
};

const Part = packed struct {
    one: bool = false,
    two: bool = false,
};

fn run(src: []const u8, allocator: std.mem.Allocator, part: Part) !Result {
    print("\n", .{});
    var result: Result = std.mem.zeroes(Result);

    const insIndex = std.mem.indexOf(u8, src, "\n\n").?;
    const ins = src[0..insIndex];

    var map = std.StringHashMap([2][]const u8).init(allocator);
    defer map.deinit();
    var lineIter = std.mem.tokenizeAny(u8, src[insIndex + 2 ..], "\n");

    var startNodes = std.ArrayList([]const u8).init(allocator);
    defer startNodes.deinit();

    while (lineIter.next()) |line| {
        const key = line[0..3];
        // AAA = (
        const left = line[3 + 4 .. 3 + 4 + 3];
        const right = line[3 + 4 + 3 + 2 .. 3 + 4 + 3 + 2 + 3];
        print("{s} => {s} {s}\n", .{ key, left, right });
        try map.put(key, [2][]const u8{ left, right });
        if (key[2] == 'A') {
            try startNodes.append(key);
        }
    }

    if (part.one) {
        var start: []const u8 = "AAA";
        const goal: []const u8 = "ZZZ";
        while (!std.mem.eql(u8, start, goal)) {
            const in = ins[result.part1 % ins.len];
            result.part1 += 1;
            if (std.mem.eql(u8, start, goal)) {
                print("Found {s}\n", .{start});
                break;
            }
            print("Looking for {s}\n", .{start});
            const next = map.get(start) orelse {
                std.debug.panic("No next for {s}\n", .{start});
            };
            switch (in) {
                'L' => start = next[0],
                'R' => start = next[1],
                else => std.debug.panic("Unknown instruction {any}\n", .{in}),
            }
        }
    }

    // Part 2
    if (part.two) {
        print("{s}\n", .{startNodes.items});
        // BRUTE FORCE... doesn't work
        //while (!isEnd(startNodes.items)) {
        //    const in = ins[result.part2 % ins.len];
        //    result.part2 += 1;
        //    for (startNodes.items, 0..) |node, i| {
        //        const next = map.get(node) orelse {
        //            std.debug.panic("No next for {s}\n", .{node});
        //        };
        //        const nextNode = switch (in) {
        //            'L' => next[0],
        //            'R' => next[1],
        //            else => std.debug.panic("Unknown instruction {any}\n", .{in}),
        //        };
        //        startNodes.items[i] = nextNode;
        //    }
        //}
        var shortcuts = std.HashMap(ShortcutKey, ShortcutValue, ShortcutContext, 80).init(allocator);
        defer shortcuts.deinit();
        var queue = std.PriorityQueue(Item, void, compareItem).init(allocator, {});
        defer queue.deinit();
        for (startNodes.items) |node| {
            try queue.add(Item{ .name = node, .steps = 0 });
        }
        while (true) {
            var item: Item = queue.remove();
            //print("Looking at {any}\n", .{item});
            var iter = queue.iterator();
            var isEnd = item.name[2] == 'Z';
            if (isEnd) {
                while (iter.next()) |nextItem| {
                    isEnd = isEnd and (item.steps == nextItem.steps and nextItem.name[2] == 'Z');
                }
            }
            if (isEnd) {
                print("YAY {any}\n", .{item});
                result.part2 = item.steps;
                break;
            }

            const instruction = ins[item.steps % ins.len];
            const shortcutsKey = ShortcutKey{ .name = item.name, .instruction = instruction };
            //print("Looking for shortcut {any}\n", .{shortcutsKey});
            const shortcut = shortcuts.get(shortcutsKey);
            if (shortcut) |s| {
                item.steps += s.steps;
                item.name = s.name;
                //print("Shortcut {any}\n", .{item});
                try queue.add(item);
                continue;
            }

            const startItem = item;
            while (true) {
                const in = ins[item.steps % ins.len];
                const next = map.get(item.name) orelse {
                    std.debug.panic("No next for {s}\n", .{item.name});
                };
                item.steps += 1;
                item.name = switch (in) {
                    'L' => next[0],
                    'R' => next[1],
                    else => std.debug.panic("Unknown instruction {any}\n", .{in}),
                };
                if (item.name[2] == 'Z') {
                    break;
                }
            }
            print("Adding back {s} {d}\n", .{ item.name, item.steps });
            try queue.add(item);
            if (startItem.name[2] == 'Z') {
                const key = ShortcutKey{ .name = startItem.name, .instruction = ins[startItem.steps % ins.len] };
                const value = ShortcutValue{ .name = item.name, .steps = item.steps - startItem.steps };
                try shortcuts.put(key, value);
                print("Adding shortcut {s}@{d} => {s}+{d}\n", .{ key.name, key.instruction, item.name, item.steps - startItem.steps });
            }
        }
        print("{s}\n", .{startNodes.items});
    }
    return result;
}

const Item = struct {
    name: []const u8,
    steps: u64,
};

fn compareItem(ctx: void, a: Item, b: Item) std.math.Order {
    _ = ctx;
    if (a.steps < b.steps) {
        return std.math.Order.lt;
    } else if (a.steps > b.steps) {
        return std.math.Order.gt;
    } else {
        return std.math.Order.eq;
    }
}

const ShortcutKey = struct {
    name: []const u8, // At node
    instruction: usize, // At instruction index
};
const ShortcutValue = struct {
    name: []const u8,
    steps: u64,
};

const ShortcutContext = struct {
    pub fn hash(self: @This(), key: ShortcutKey) u64 {
        _ = self;
        var hasher = std.hash.Wyhash.init(0);
        hasher.update(key.name);
        const instruction = std.mem.toBytes(key.instruction);
        hasher.update(&instruction);
        return @truncate(hasher.final());
    }
    pub fn eql(self: @This(), key_1: ShortcutKey, key_2: ShortcutKey) bool {
        _ = self;
        return std.mem.eql(u8, key_1.name, key_2.name) and
            key_2.instruction == key_2.instruction;
    }
};

//fn isEnd(nodes: [][]const u8) bool {
//    for (nodes) |node| {
//        if (node[2] != 'Z') {
//            return false;
//        }
//    }
//    return true;
//}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const result = try run(input, allocator, Part{ .one = true, .two = true });
    print("Result: {any}\n", .{result});
}

test "example1" {
    const result = try run(example, std.testing.allocator, Part{ .one = true, .two = false });
    print("Result: {any}\n", .{result});
    try std.testing.expectEqual(@as(u64, 2), result.part1);
}
test "example2" {
    const result = try run(example2, std.testing.allocator, Part{ .one = true, .two = false });
    print("Result: {any}\n", .{result});
    try std.testing.expectEqual(@as(u64, 6), result.part1);
}
test "example3" {
    const result = try run(example3, std.testing.allocator, Part{ .one = false, .two = true });
    print("Result: {any}\n", .{result});
    try std.testing.expectEqual(@as(u64, 6), result.part2);
}
