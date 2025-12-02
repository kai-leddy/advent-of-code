const std = @import("std");

const input = @embedFile("./input.txt");

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    const part1 = getPassword(input);

    std.debug.print("Part 1: {d}\n", .{part1});
}

fn getPassword(in: []const u8) u32 {
    var lines = std.mem.tokenizeScalar(u8, in, '\n');
    var dial: i32 = 50;
    var count: u32 = 0;

    while (lines.next()) |line| {
        const dir = line[0];
        const num = std.fmt.parseInt(i32, line[1..], 10) catch 0;
        switch (dir) {
            'L' => {
                dial -= num;
            },
            'R' => {
                dial += num;
            },
            // skip unknown lines
            else => continue,
        }
        // get rid of all the denominations of 100 (basically wrapping)
        dial = @mod(dial, 100);
        if (dial == 0) {
            count += 1;
        }
    }
    return count;
}

test "example" {
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
    try std.testing.expectEqual(@as(u32, 3), getPassword(eg));
}
