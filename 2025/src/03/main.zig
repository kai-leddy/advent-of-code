const std = @import("std");

const input = @embedFile("./input.txt");

pub fn main() !void {
    const part1 = maxJoltageFromBanks(comptime splitIntoBanks(input));

    std.debug.print("Part 1: {d}\n", .{part1});

    const part2 = 0;

    std.debug.print("Part 2: {d}\n", .{part2});
}

fn splitIntoBanks(comptime in: []const u8) []const []const u8 {
    std.debug.assert(@inComptime()); // this function only seems to work at comptime

    @setEvalBranchQuota(100_000);
    const len = comptime std.mem.count(u8, in, &[_]u8{'\n'});
    @setEvalBranchQuota(len * 100);
    var iter = std.mem.tokenizeScalar(u8, in, '\n');
    var banks: [len][]const u8 = undefined;
    for (0..len) |i| {
        banks[i] = iter.next().?;
    }
    // copy mutable slice to a const to return from comptime
    const final = banks;
    return &final;
}

fn maxJoltageFromBanks(allBanks: []const []const u8) u64 {
    var total: u64 = 0;
    for (allBanks) |bank| {
        total += maxJoltage(bank);
    }
    return total;
}

fn maxJoltage(bank: []const u8) u64 {
    const first, const first_i = largestNumInSliceAsChar(bank[0 .. bank.len - 1]);
    const second, _ = largestNumInSliceAsChar(bank[first_i + 1 .. bank.len]);
    var buf: [200]u8 = undefined;
    const total = std.fmt.bufPrint(&buf, "{c}{c}", .{ first, second }) catch unreachable;
    return std.fmt.parseInt(u64, total, 10) catch unreachable;
}

fn largestNumInSliceAsChar(slice: []const u8) struct { u8, usize } {
    var largest: u8 = '0';
    var index: usize = 0;
    for (slice, 0..) |char, i| {
        if (char > largest) {
            largest = char;
            index = i;
        }
    }
    return .{ largest, index };
}

test "example" {
    const ex =
        \\987654321111111
        \\811111111111119
        \\234234234234278
        \\818181911112111
        \\
    ;
    const banks = comptime splitIntoBanks(ex);
    try std.testing.expectEqual(357, maxJoltageFromBanks(banks));
}
