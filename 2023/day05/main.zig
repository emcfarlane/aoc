const std = @import("std");
const print = std.debug.print;

const input = @embedFile("input.txt");
const example = @embedFile("example.txt");

const Result = struct {
    part1: u64,
    part2: u64,
};

const ValueRange = struct {
    dst: u64,
    src: u64,
    range: u64,
    fn end(self: ValueRange) u64 {
        return self.src + self.range - 1;
    }
};

const Range = struct {
    src: u64,
    range: u64,
    fn end(self: Range) u64 {
        return self.src + self.range - 1;
    }
    fn convert(
        self: Range,
        value: ValueRange,
        mapped: *std.ArrayList(Range),
        unmapped: *std.ArrayList(Range),
    ) !void {
        if (self.end() < value.src or self.src > value.end()) {
            try unmapped.append(self);
            return;
        }
        var a = self.src; // 99
        if (self.src < value.src) {
            a = value.src; // 98
            try unmapped.append(Range{
                .src = self.src,
                .range = value.src - self.src,
            });
        }
        var b = self.end(); // 101
        if (self.end() > value.end()) {
            b = value.end(); // 99
            try unmapped.append(Range{
                .src = value.end() + 1, // 100 101 102 -> 100
                .range = self.end() - value.end(), // 102 - 99 -> 3
            });
        }
        if (b >= a) { // 99 >= 99
            print("a: {}, b: {}\n", .{ a, b });
            print("range: {}\n", .{self});
            print("valueRange: {}\n", .{value});
            const valueDst: i64 = @intCast(value.dst); // 50
            const valueSrc: i64 = @intCast(value.src); // 98
            const srcStart: i64 = @intCast(a); // 99
            const dstStart: u64 = @intCast(valueDst - valueSrc + srcStart); // 50
            try mapped.append(Range{
                .src = dstStart,
                .range = b - a + 1, // 99 - 99 + 1 -> 1
            });
        }
    }
};

test "convert" {
    const value = ValueRange{
        .dst = 50,
        .src = 98,
        .range = 2,
    };
    const testCase = struct {
        range: Range,
        mappedLen: usize,
        unmappedLen: usize,
    };
    const testCases = [_]testCase{
        .{
            .range = Range{
                .src = 96,
                .range = 10,
            },
            .mappedLen = 1,
            .unmappedLen = 2,
        },
    };
    for (testCases) |tt| {
        print("range: {}\n", .{tt.range});
        var mapped = std.ArrayList(Range).init(std.testing.allocator);
        defer mapped.deinit();
        var unmapped = std.ArrayList(Range).init(std.testing.allocator);
        defer unmapped.deinit();
        try tt.range.convert(value, &mapped, &unmapped);
        print("mapped: {any}\n", .{mapped.items});
        print("unmapped: {any}\n", .{unmapped.items});
        try std.testing.expectEqual(@as(u64, tt.mappedLen), mapped.items.len);
        try std.testing.expectEqual(@as(u64, tt.unmappedLen), unmapped.items.len);
    }
}

fn run(src: []const u8, allocator: std.mem.Allocator) !Result {
    var result: Result = std.mem.zeroes(Result);

    const firstLineIndex = std.mem.indexOf(u8, src, "\n").?;
    var seedsIter = std.mem.tokenize(u8, src["seeds:".len..firstLineIndex], " ");
    var seeds = std.ArrayList(u64).init(allocator);
    defer seeds.deinit();
    while (seedsIter.next()) |seed| {
        print("seed: '{s}'\n", .{seed});
        const value = try std.fmt.parseInt(u64, seed, 10);
        try seeds.append(value);
    }

    var maps = std.ArrayList(std.ArrayList(ValueRange)).init(allocator);
    defer {
        for (maps.items) |map| {
            map.deinit();
        }
        maps.deinit();
    }

    var sectionIter = std.mem.tokenizeSequence(u8, src[firstLineIndex..], "\n\n");
    while (sectionIter.next()) |section| {
        //print("section: '{s}'\n", .{section});
        const mapIndex = std.mem.indexOf(u8, section, " map:").?;
        const toIndex = std.mem.indexOf(u8, section, "-to-").?;
        const from = section[0..toIndex];
        _ = from;
        const to = section[toIndex + "-to-".len .. mapIndex];
        _ = to;
        //print("from: '{s}'\n", .{from});
        //print("to: '{s}'\n", .{to});

        var values = std.ArrayList(ValueRange).init(allocator);

        var linesIter = std.mem.tokenize(u8, section[mapIndex + " map:".len ..], "\n");
        while (linesIter.next()) |line| {
            print("line: '{s}'\n", .{line});
            var numbersIter = std.mem.tokenize(u8, line, " ");
            const numberDst = try std.fmt.parseInt(u64, numbersIter.next().?, 10);
            const numberSrc = try std.fmt.parseInt(u64, numbersIter.next().?, 10);
            const numberRange = try std.fmt.parseInt(u64, numbersIter.next().?, 10);
            try values.append(ValueRange{
                .dst = numberDst,
                .src = numberSrc,
                .range = numberRange,
            });
        }
        try maps.append(values);
    }

    // part 1
    for (seeds.items, 0..) |seed, i| {
        print("seed: {d}\n", .{seed});
        var location = seed;
        for (maps.items) |map| {
            print("map: {}\n", .{map});
            for (map.items) |valueRange| {
                print("valueRange: {}\n", .{valueRange});
                if (valueRange.src <= location and location <= valueRange.src + valueRange.range) {
                    location = valueRange.dst + (location - valueRange.src);
                    break;
                }
            }
        }
        print("location: {d}\n", .{location});
        if (i == 0 or result.part1 > location) {
            result.part1 = location;
        }
    }

    // part 2
    var ranges = std.ArrayList(Range).init(allocator);
    defer ranges.deinit();
    {
        var i: usize = 0;
        while (i < seeds.items.len) : (i += 2) {
            try ranges.append(Range{
                .src = seeds.items[i],
                .range = seeds.items[i + 1],
            });
        }
    }
    print("ranges: {any}\n", .{ranges.items});
    for (maps.items) |map| {
        var mapped = std.ArrayList(Range).init(allocator);
        for (map.items) |valueRange| {
            var unmapped = std.ArrayList(Range).init(allocator);
            for (ranges.items) |range| {
                // <---> xxx <---->
                try range.convert(valueRange, &mapped, &unmapped);
            }
            ranges.deinit();
            ranges = unmapped;
        }

        print("mapped: {any}\n", .{mapped.items});
        print("unmapped: {any}\n", .{ranges.items});
        for (ranges.items) |range| {
            try mapped.append(range); // one to one conversion
        }
        ranges.deinit();
        ranges = mapped;
    }
    print("ranges: {any}\n", .{ranges.items});
    result.part2 = ranges.items[0].src;
    for (ranges.items) |range| {
        if (range.src < result.part2) {
            print("FOUND lower: {d}\n", .{range.src});
            result.part2 = range.src;
        }
    }
    print("result.part2: {d}\n", .{result.part2});

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
    try std.testing.expectEqual(@as(u64, 35), result.part1);
    try std.testing.expectEqual(@as(u64, 46), result.part2);
}

//const MappingContext = struct {
//    pub fn hash(self: @This(), key: Value) u64 {
//        _ = self;
//        var hasher = std.hash.Wyhash.init(0);
//        hasher.update(key.name);
//        const value = std.mem.toBytes(key.value);
//        hasher.update(&value);
//        return @truncate(hasher.final());
//    }
//    pub fn eql(self: @This(), key_1: Value, key_2: Value) bool {
//        _ = self;
//        return std.mem.eql(u8, key_1.name, key_2.name) and key_2.value == key_2.value;
//    }
//};
