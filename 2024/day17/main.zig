const std = @import("std");
const print = std.debug.print;

const input = @embedFile("input.txt");
const example1 = @embedFile("example.txt");
const example2 = @embedFile("example2.txt");

const Result = struct {
    part1: []u64,
    part2: ?u64,
    fn deinit(self: Result, allocator: std.mem.Allocator) void {
        allocator.free(self.part1);
    }
};

const Machine = struct {
    register: [3]u64,
    program: []u64,
    ip: usize,
    fn combo(register: [3]u64, operand: u64) u64 {
        return switch (operand) {
            0...3 => operand,
            4 => register[0],
            5 => register[1],
            6 => register[2],
            else => std.debug.panic("Invalid combo operand: {d}", .{operand}),
        };
    }
    fn step(self: *Machine, outs: *std.ArrayList(u64)) !void {
        const operand = self.program[self.ip + 1];
        const opcode = self.program[self.ip];
        self.ip += 2;
        switch (opcode) {
            // The adv instruction (opcode 0) performs division. The numerator
            // is the value in the A register. The denominator is found by
            // raising 2 to the power of the instruction's combo operand. (So,
            // an operand of 2 would divide A by 4 (2^2); an operand of 5 would
            // divide A by 2^B.) The result of the division operation is
            // truncated to an integer and then written to the A register.
            0 => {
                const comboOp: u6 = @truncate(combo(self.register, operand));
                self.register[0] = self.register[0] >> comboOp;
            },
            // The bxl instruction (opcode 1) calculates the bitwise XOR of
            // register B and the instruction's literal operand, then stores
            // the result in register B.
            1 => {
                self.register[1] = self.register[1] ^ operand;
            },
            // The bst instruction (opcode 2) calculates the value of its combo
            // operand modulo 8 (thereby keeping only its lowest 3 bits), then
            // writes that value to the B register.
            2 => {
                const comboOp = combo(self.register, operand);
                self.register[1] = @mod(comboOp, 8);
            },
            // The jnz instruction (opcode 3) does nothing if the A register is
            // 0. However, if the A register is not zero, it jumps by setting
            // the instruction pointer to the value of its literal operand; if
            // this instruction jumps, the instruction pointer is not increased
            // by 2 after this instruction.
            3 => {
                if (self.register[0] != 0) self.ip = @intCast(operand);
            },
            // The bxc instruction (opcode 4) calculates the bitwise XOR of
            // register B and register C, then stores the result in register B.
            // (For legacy reasons, this instruction reads an operand but
            // ignores it.)
            4 => {
                self.register[1] = self.register[1] ^ self.register[2];
            },
            // The out instruction (opcode 5) calculates the value of its combo
            // operand modulo 8, then outputs that value. (If a program outputs
            // multiple values, they are separated by commas.)
            5 => {
                const comboOp: u6 = @truncate(combo(self.register, operand));
                try outs.append(@mod(comboOp, 8));
            },
            // The bdv instruction (opcode 6) works exactly like the adv
            // instruction except that the result is stored in the B register.
            // (The numerator is still read from the A register.)
            6 => {
                const comboOp: u6 = @truncate(combo(self.register, operand));
                self.register[1] = self.register[0] >> comboOp;
            },
            // The cdv instruction (opcode 7) works exactly like the adv
            // instruction except that the result is stored in the C register.
            // (The numerator is still read from the A register.)
            7 => {
                const comboOp: u6 = @truncate(combo(self.register, operand));
                self.register[2] = self.register[0] >> comboOp;
            },
            else => return error.@"Invalid opcode",
        }
        return {};
    }
    fn eval(self: *Machine, a: u64, b: u64, c: u64, outs: *std.ArrayList(u64)) !void {
        outs.clearRetainingCapacity();
        self.register[0] = a;
        self.register[1] = b;
        self.register[2] = c;
        self.ip = 0;
        while (self.ip < self.program.len) {
            try self.step(outs);
        }
    }
};

fn find(m: *Machine, a: u64, b: u64, c: u64, out: *std.ArrayList(u64), i: usize) !?u64 {
    try m.eval(a, b, c, out);
    if (std.mem.eql(u64, m.program, out.items)) {
        print("Found match: a {d}\n", .{a});
        return a;
    }
    if (i > m.program.len) {
        return null;
    }
    const want = m.program[m.program.len - i ..];
    //print("Comparing a {d} => {any} to {any}\n", .{ a, out.items, want });
    if (i == 0 or std.mem.eql(u64, want, out.items)) {
        print("Partial match: a {d} i {d}\n", .{ a, i });
        for (0..8) |n| {
            if (try find(m, 8 * a + @as(u64, @intCast(n)), b, c, out, i + 1)) |val| {
                return val;
            }
        }
    }
    return null;
}

fn run(src: []const u8, allocator: std.mem.Allocator) !Result {
    print("\n", .{});
    var register = [3]u64{ 0, 0, 0 };
    var program = std.ArrayList(u64).init(allocator);
    defer program.deinit();

    var lineIt = std.mem.tokenize(u8, src, "\n");
    for (0..3) |i| {
        const line = lineIt.next().?;
        const j = std.mem.indexOf(u8, line, ": ").?;
        register[i] = try std.fmt.parseInt(u64, line[j + 2 ..], 10);
    }
    const line = lineIt.next().?;
    const j = std.mem.indexOf(u8, line, ": ").?;
    var numIt = std.mem.tokenize(u8, line[j + 2 ..], ",");
    while (numIt.next()) |num| {
        try program.append(try std.fmt.parseInt(u64, num, 10));
    }

    var output = std.ArrayList(u64).init(allocator);
    defer output.deinit();

    var m1 = Machine{
        .register = register,
        .program = program.items,
        .ip = 0,
    };
    while (m1.ip < program.items.len) {
        try m1.step(&output);
    }

    var outs = std.ArrayList(u64).init(allocator);
    defer outs.deinit();

    //// Test the min value of register A to output the same machine.
    //var part2: u64 = 117440;
    //while (true) {
    //    outs.clearRetainingCapacity();
    //    var m = Machine{
    //        .register = register,
    //        .program = program.items,
    //        .ip = 0,
    //    };
    //    m.register[0] = @intCast(part2);
    //    while (m.ip < program.items.len) {
    //        m.step(&outs) catch |err| {
    //            print("Invalid machine: {d} {any}\n", .{ part2, err });
    //            break;
    //        };
    //        if (outs.items.len >= m.program.len or !std.mem.eql(u64, outs.items, m.program[0..outs.items.len])) {
    //            break;
    //        }
    //    }
    //    if (part2 % 1000000 == 0) {
    //        print("{d}\n", .{part2});
    //    }
    //    if (std.mem.eql(u64, m.program, outs.items)) {
    //        print("Found machine: {d}\n", .{part2});
    //        break;
    //    }
    //    part2 += 1;
    //}
    //
    var m2 = Machine{
        .register = register,
        .program = program.items,
        .ip = 0,
    };
    const part2 = try find(&m2, 0, register[1], register[2], &outs, 0);
    print("Part 2: {?d}\n", .{part2});

    var result: Result = std.mem.zeroes(Result);
    result.part1 = try output.toOwnedSlice();
    result.part2 = part2;
    return result;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const result = try run(input, allocator);
    defer result.deinit(allocator);
    print("Result: {any}\n", .{result});
}

test "example1" {
    const result = try run(example1, std.testing.allocator);
    defer result.deinit(std.testing.allocator);
    print("Result: {any}\n", .{result});
    const part1 = [_]u64{ 4, 6, 3, 5, 6, 3, 5, 2, 1, 0 };
    try std.testing.expectEqualSlices(u64, part1[0..], result.part1);
}

test "example2" {
    const result = try run(example2, std.testing.allocator);
    defer result.deinit(std.testing.allocator);
    print("Result: {any}\n", .{result});
    try std.testing.expectEqual(117440, result.part2);
}
