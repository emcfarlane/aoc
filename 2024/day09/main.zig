const std = @import("std");
const print = std.debug.print;

const input = @embedFile("input.txt");
const example = @embedFile("example.txt");
const example2 = @embedFile("example2.txt");

const Result = struct {
    part1: u64,
    part2: u64,
};

const Segment = struct {
    id: ?u64,
    size: usize,
};

fn printDisk(str: []const u8, disk: []Segment) void {
    print("{s}: ", .{str});
    for (disk) |segment| {
        for (0..segment.size) |_| {
            if (segment.id) |id| {
                print("{d}", .{id});
            } else {
                print(".", .{});
            }
        }
    }
    print("\n", .{});
}

fn checksum(disk: []Segment) u64 {
    var sum: u64 = 0;
    var pos: u64 = 0;
    for (disk) |segment| {
        for (0..segment.size) |_| {
            if (segment.id) |id| {
                sum += pos * id;
            }
            pos += 1;
        }
    }
    // OLD
    //for (0.., disk[0..]) |pos, segment| {
    //    for (segment.si
    //    if (segment.id) |x| {
    //        sum += pos * x;
    //    }
    //}
    return sum;
}

fn compactPart1(disk: *std.ArrayList(Segment)) !void {
    //printDisk("before", disk.items);
    var i: usize = 0;
    //var j: usize = segments.items.len - 1;
    while (i < disk.items.len - 1) {
        const a = disk.items[i];
        if (a.id != null) {
            i += 1;
            continue;
        }
        const b = disk.pop();
        if (b.id == null) {
            continue;
        }
        if (a.size > b.size) {
            // insert free slot after i.
            try disk.insert(i + 1, .{ .id = null, .size = a.size - b.size });
            disk.items[i] = .{ .id = b.id, .size = b.size };
            i += 1;
        } else if (a.size < b.size) {
            // append b back to the end.
            try disk.append(.{ .id = b.id, .size = b.size - a.size });
            disk.items[i] = .{ .id = b.id, .size = a.size };
        } else {
            // same size, no need to do anything.
            disk.items[i] = b;
            i += 1;
        }
    }
    //printDisk("compact1", disk.items);
    return;
    // OLD:
    //        const a = disk[i];
    //        const b = disk[j];
    //        if (b == null) {
    //            j -= 1;
    //            continue;
    //        }
    //        if (a != null) {
    //            i += 1;
    //            continue;
    //        }
    //        disk[i] = b;
    //        disk[j] = null;
    //        i += 1;
    //        j -= 1;
    //    }
    //    return j + 1;
    //return disk.items.len;
}

fn compactPart2(disk: *std.ArrayList(Segment)) !void {
    //printDisk("=>", disk.items);
    var i: usize = disk.items.len - 1;
    var lastID: ?u64 = null;
    while (i > 0) : (i -= 1) {
        const a = disk.items[i];
        if (a.id == null) {
            continue;
        }
        if (lastID) |id| {
            if (a.id.? > id) {
                continue;
            }
        }
        for (0..i) |j| {
            const b = disk.items[j];
            if (b.id != null or b.size < a.size) {
                continue;
            } else if (b.size > a.size) {
                disk.items[i] = .{ .id = null, .size = a.size };
                disk.items[j] = .{ .id = a.id, .size = a.size };
                try disk.insert(j + 1, .{ .id = null, .size = b.size - a.size });
                i += 1;
            } else {
                disk.items[i] = .{ .id = null, .size = a.size };
                disk.items[j] = .{ .id = a.id, .size = a.size };
            }
            //printDisk("=>", disk.items);
            break;
        }
        lastID = a.id;
    }
    //printDisk("==", disk.items);
    return;
}

fn run(src: []const u8, allocator: std.mem.Allocator) !Result {
    print("\n", .{});
    var result: Result = std.mem.zeroes(Result);

    var disk = std.ArrayList(Segment).init(allocator);
    defer disk.deinit();

    var lines = std.mem.tokenizeSequence(u8, src, "\n");
    const line = lines.next().?;

    var id: u64 = 0;
    var i: usize = 0;
    while (i < line.len) : (i += 1) {
        if (i > 1 and i % 2 == 0) {
            id += 1;
        }
        const n = try std.fmt.parseInt(u64, line[i .. i + 1], 10);

        var segment: Segment = .{ .id = null, .size = n };
        if (i % 2 == 0) {
            segment.id = id;
        }
        try disk.append(segment);
    }

    {
        var disk1 = try disk.clone();
        defer disk1.deinit();

        try compactPart1(&disk1);
        result.part1 = checksum(disk1.items);
    }

    {
        var disk2 = try disk.clone();
        defer disk2.deinit();

        try compactPart2(&disk2);
        result.part2 = checksum(disk2.items);
    }
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
    try std.testing.expectEqual(@as(u64, 1928), result.part1);
    try std.testing.expectEqual(@as(u64, 2858), result.part2);
}

test "example2" {
    const result = try run(example2, std.testing.allocator);
    print("Result: {any}\n", .{result});
    try std.testing.expectEqual(@as(u64, 97898222299196), result.part2);
}
