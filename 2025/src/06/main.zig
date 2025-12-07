const std = @import("std");

const input = @embedFile("./input.txt");

pub fn main() !void {
    const in = comptime parse(input);
    const part1 = completeWorksheet(in);

    std.debug.print("Part 1: {d}\n", .{part1});

    const part2 = 0;

    std.debug.print("Part 2: {d}\n", .{part2});
}

const Operator = enum { mul, add };

const Calculation = struct {
    values: []const u64,
    operator: Operator,
};

fn parse(comptime in: []const u8) []const Calculation {
    std.debug.assert(@inComptime());

    @setEvalBranchQuota(100_000);
    const lines = comptime std.mem.count(u8, in, &[_]u8{'\n'});
    var iter = std.mem.tokenizeScalar(u8, in, '\n');
    const first = iter.peek().?;
    var columns: usize = 0;
    var column_iter = std.mem.tokenizeScalar(u8, first, ' ');
    while (column_iter.next() != null) columns += 1;

    @setEvalBranchQuota(lines * columns * 1_000);
    var values: [lines - 1][columns]u64 = undefined;
    var operators: [columns]Operator = undefined;
    for (0..lines) |i| {
        const line = iter.next().?;
        var val_iter = std.mem.tokenizeScalar(u8, line, ' ');
        for (0..columns) |j| {
            const val = val_iter.next().?;
            if (i < lines - 1) {
                values[i][j] = std.fmt.parseInt(u64, val, 10) catch unreachable;
            } else {
                const rune = val[0];
                operators[j] = switch (rune) {
                    '*' => Operator.mul,
                    '+' => Operator.add,
                    else => std.debug.panic("Unknown operator: {s}\n", .{val}),
                };
            }
        }
    }

    // now map into calculations
    var calcs: [columns]Calculation = undefined;
    for (0..columns) |i| {
        var vals: [lines - 1]u64 = undefined;
        for (0..lines - 1) |v| {
            vals[v] = values[v][i];
        }

        const v = vals;
        calcs[i] = Calculation{
            .operator = operators[i],
            .values = &v,
        };
    }

    const calculations = calcs;
    return &calculations;
}

fn completeWorksheet(in: []const Calculation) u64 {
    var total: u64 = 0;
    for (in) |calc| {
        const answer = switch (calc.operator) {
            .mul => blk: {
                var val: u64 = 1;
                for (calc.values) |v| {
                    val *= v;
                }
                break :blk val;
            },
            .add => blk: {
                var val: u64 = 0;
                for (calc.values) |v| {
                    val += v;
                }
                break :blk val;
            },
        };
        total += answer;
    }
    return total;
}

test "example - part 1" {
    const ex =
        \\123 328  51 64 
        \\ 45 64  387 23 
        \\  6 98  215 314
        \\*   +   *   +     
        \\
    ;
    const in = comptime parse(ex);
    try std.testing.expectEqual(4277556, completeWorksheet(in));
}
