const std = @import("std");
const print = std.debug.print;

const input = @embedFile("input.txt");
const example = @embedFile("example.txt");

const Result = struct {
    part1: ?u64,
    part2: ?u64,
};

const Pos = struct {
    x: i64,
    y: i64,
    fn equal(a: Pos, b: Pos) bool {
        return a.x == b.x and a.y == b.y;
    }
    fn add(a: Pos, b: Pos) Pos {
        return Pos{ .x = a.x + b.x, .y = a.y + b.y };
    }
};

const Machine = struct {
    buttonA: Pos, // Cost 3
    buttonB: Pos, // Cost 1
    prize: Pos,

    fn play(self: Machine) ?u64 {
        for (0..100) |i| {
            for (0..100) |j| {
                const am: i64 = @intCast(i);
                const bm: i64 = @intCast(j);
                const pos = Pos{
                    .x = am * self.buttonA.x + bm * self.buttonB.x,
                    .y = am * self.buttonA.y + bm * self.buttonB.y,
                };
                if (pos.equal(self.prize)) {
                    return 3 * i + 1 * j;
                }
                if (pos.x > self.prize.x or pos.y > self.prize.y) {
                    break;
                }
            }
        }
        return null;
    }
    fn play_fast(self: Machine) ?u64 {
        // y = a * ay + b * by
        // x = a * ax + b * bx
        //
        // b = (y-a*ay)/by
        //
        // b = (y - a * ay) / by
        // a = (x - b * bx) / ax
        const ax: f64 = @floatFromInt(self.buttonA.x);
        const ay: f64 = @floatFromInt(self.buttonA.y);
        const bx: f64 = @floatFromInt(self.buttonB.x);
        const by: f64 = @floatFromInt(self.buttonB.y);
        const x: f64 = @floatFromInt(self.prize.x);
        const y: f64 = @floatFromInt(self.prize.y);
        const a = (y * bx - x * by) / (ay * bx - ax * by);
        const b = (x - a * ax) / bx;
        if (!std.math.isInf(a) and !std.math.isInf(b) and a == @round(a) and b == @round(b)) {
            return @intFromFloat(3.0 * a + 1.0 * b);
        }
        return null;
    }
};

const Game = struct {
    turn: usize,
    cost: u64,
    pos: Pos,
    fn move(self: Game, pos: Pos, cost: u64) Game {
        return Game{
            .turn = self.turn + 1,
            .cost = self.cost + cost,
            .pos = pos.add(self.pos),
        };
    }
};

fn compareGame(_: void, a: Game, b: Game) std.math.Order {
    return std.math.order(a.cost, b.cost).invert();
}

fn parsePos(line: []const u8, ch: u8) Pos {
    print("{s}\n", .{line});
    var pos: Pos = .{ .x = 0, .y = 0 };
    var i: usize = 0;
    while (line[i] != ch) i += 1;
    i += 1;
    while (line[i] >= '0' and line[i] <= '9') : (i += 1) {
        pos.x = pos.x * 10 + line[i] - '0';
    }
    while (line[i] != ch) i += 1;
    i += 1;
    while (i < line.len and line[i] >= '0' and line[i] <= '9') : (i += 1) {
        pos.y = pos.y * 10 + line[i] - '0';
    }
    return pos;
}

fn run(src: []const u8, allocator: std.mem.Allocator) !Result {
    var machines = std.ArrayList(Machine).init(allocator);
    defer machines.deinit();

    var lines = std.mem.tokenizeSequence(u8, src, "\n");
    while (lines.peek() != null) {
        try machines.append(Machine{
            .buttonA = parsePos(lines.next().?, '+'),
            .buttonB = parsePos(lines.next().?, '+'),
            .prize = parsePos(lines.next().?, '='),
        });
    }

    print("{any}\n", .{machines});
    var result: Result = std.mem.zeroes(Result);
    var part1: u64 = 0;
    var part2: u64 = 0;
    for (0.., machines.items) |i, machine| {
        print("Machine {d}\n", .{i});
        print("A: {any} B: {any} Prize: {any}\n", .{ machine.buttonA, machine.buttonB, machine.prize });
        if (machine.play()) |c| {
            print("Game {d} won in {d} turns\n", .{ i, c });
            part1 += c;
        } else {
            print("Game {d} lost\n", .{i});
        }
        const largeMachine = Machine{
            .buttonA = machine.buttonA,
            .buttonB = machine.buttonB,
            .prize = machine.prize.add(Pos{
                .x = 10000000000000,
                .y = 10000000000000,
            }),
        };
        print("Large prize {any}\n", .{largeMachine.prize});
        if (largeMachine.play_fast()) |c| {
            print("Large game {d} won in {d} turns\n", .{ i, c });
            part2 += c;
        } else {
            print("Large game {d} lost\n", .{i});
        }
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
    if (result.part1) |p1| try std.testing.expectEqual(@as(u64, 480), p1);
}
