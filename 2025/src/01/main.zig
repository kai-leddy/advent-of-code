const std = @import("std");

const input = @embedFile("./input.txt");

pub fn main() !void {
    const part1 = getPassword(input, false);

    std.debug.print("Part 1: {d}\n", .{part1});

    const part2 = getPassword(input, true);

    std.debug.print("Part 2: {d}\n", .{part2});
}

fn getPassword(in: []const u8, enPassant: bool) u32 {
    var lines = std.mem.tokenizeScalar(u8, in, '\n');
    var dial: i32 = 50;
    var count: u32 = 0;

    while (lines.next()) |line| {
        std.debug.assert(dial >= 0); // dial should never be negative here
        var next = dial;
        const dir = line[0];
        const num = std.fmt.parseInt(i32, line[1..], 10) catch 0;
        switch (dir) {
            'L' => {
                next -= num;
            },
            'R' => {
                next += num;
            },
            // skip unknown lines
            else => continue,
        }
        // if counting en passant, check for multiple wraps of 100
        if (enPassant) {
            std.debug.assert(dial >= 0); // dial should never be negative here
            const passes = @divTrunc(next, 100);
            count += @abs(passes);
            // count landing on a zero exactly
            if (next == 0) {
                count += 1;
            }
            // account for crossing zero without wrapping over 100
            if (dial != 0 and (next < 0)) {
                count += 1;
            }
        }
        // get rid of all the denominations of 100 (basically wrapping)
        dial = @mod(next, 100);
        if (!enPassant and dial == 0) {
            count += 1;
        }
    }
    return count;
}

test "mod of negative wraps around" {
    try std.testing.expectEqual(@as(i32, 99), @mod(-1, 100));
}

test "divtrunc less than 0 is 0" {
    try std.testing.expectEqual(@as(i32, 0), @divTrunc(50, 100));
    try std.testing.expectEqual(@as(i32, 0), @divTrunc(-50, 100));
}

test "divtrunc 100 equals 1" {
    try std.testing.expectEqual(@as(i32, 1), @divTrunc(100, 100));
}

test "divtrunc -100 equals -1" {
    try std.testing.expectEqual(@as(i32, 1), @divTrunc(100, 100));
}

test "example part 1" {
    const eg =
        \\L68
        \\L30
        \\R48
        \\L5
        \\R60
        \\L55
        \\L1
        \\L99
        \\R14
        \\L82
    ;
    try std.testing.expectEqual(@as(u32, 3), getPassword(eg, false));
}

test "example part 2" {
    const eg =
        \\L68
        \\L30
        \\R48
        \\L5
        \\R60
        \\L55
        \\L1
        \\L99
        \\R14
        \\L82
    ;
    try std.testing.expectEqual(@as(u32, 6), getPassword(eg, true));
}

test "part 2 - ending on 0" {
    try std.testing.expectEqual(@as(u32, 1), getPassword("L50\n", true));
}

test "part 2 - passing 0 once" {
    try std.testing.expectEqual(@as(u32, 1), getPassword("L70\n", true));
}

test "part 2 - passing 100 once" {
    try std.testing.expectEqual(@as(u32, 1), getPassword("R70\n", true));
}

test "part 2 - ending on 100" {
    try std.testing.expectEqual(@as(u32, 1), getPassword("R50\n", true));
}

test "part 2 - passing -100 once" {
    try std.testing.expectEqual(@as(u32, 2), getPassword("L170\n", true));
}

test "part 2 - ending on -100" {
    try std.testing.expectEqual(@as(u32, 2), getPassword("L150\n", true));
}
