const std = @import("std");

const input = @embedFile("./input.txt");

pub fn main() !void {
    const part1 = countAccessible(comptime parseGrid(input));

    std.debug.print("Part 1: {d}\n", .{part1});

    const part2 = 0;

    std.debug.print("Part 2: {d}\n", .{part2});
}

fn parseGrid(comptime in: []const u8) []const []const u8 {
    std.debug.assert(@inComptime()); // this function only seems to work at comptime

    @setEvalBranchQuota(100_000);
    const len = comptime std.mem.count(u8, in, &[_]u8{'\n'});
    @setEvalBranchQuota(len * 1000);
    var iter = std.mem.tokenizeScalar(u8, in, '\n');
    var rows: [len][]const u8 = undefined;
    for (0..len) |i| {
        rows[i] = iter.next().?;
    }
    // copy mutable slice to a const to return from comptime
    const final = rows;
    return &final;
}

fn countAdjacent(grid: []const []const u8, y: usize, x: usize) u32 {
    const maxY = grid.len - 1;
    const maxX = grid[0].len - 1;
    var count: u32 = 0;
    if (y > 0 and grid[y - 1][x] == '@') count += 1;
    if (x > 0 and grid[y][x - 1] == '@') count += 1;
    if (y < maxY and grid[y + 1][x] == '@') count += 1;
    if (x < maxX and grid[y][x + 1] == '@') count += 1;
    if (x > 0 and y > 0 and grid[y - 1][x - 1] == '@') count += 1;
    if (y < maxY and x < maxX and grid[y + 1][x + 1] == '@') count += 1;
    if (y < maxY and x > 0 and grid[y + 1][x - 1] == '@') count += 1;
    if (y > 0 and x < maxX and grid[y - 1][x + 1] == '@') count += 1;
    return count;
}

fn countAccessible(grid: []const []const u8) u32 {
    var count: u32 = 0;
    for (grid, 0..) |row, y| {
        for (row, 0..) |cell, x| {
            if (cell != '@') continue;
            if (countAdjacent(grid, y, x) < 4) count += 1;
        }
    }
    return count;
}

test "example - part 1" {
    const ex =
        \\..@@.@@@@.
        \\@@@.@.@.@@
        \\@@@@@.@.@@
        \\@.@@@@..@.
        \\@@.@@@@.@@
        \\.@@@@@@@.@
        \\.@.@.@.@@@
        \\@.@@@.@@@@
        \\.@@@@@@@@.
        \\@.@.@@@.@.
        \\
    ;
    const grid = comptime parseGrid(ex);
    try std.testing.expectEqual(13, countAccessible(grid));
}
