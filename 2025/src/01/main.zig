const std = @import("std");

const input = @embedFile("./input.txt");

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    const part1 = getPassword(input);

    std.debug.print("Part 1: {d}\n", .{part1});
}

fn getPassword(in: []const u8) u8 {
    return @intCast(in.len);
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
    try std.testing.expectEqual(@as(u8, 3), getPassword(eg));
}
