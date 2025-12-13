const std = @import("std");

const input = @embedFile("./input.txt");

const Grid = []const []const u8;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    const grid = comptime parseGrid(input);
    const res = try simulateTachyonBeams(allocator, grid);
    const part1 = res.splits;

    std.debug.print("Part 1: {d}\n", .{part1});

    const part2 = res.paths;

    std.debug.print("Part 2: {d}\n", .{part2});
}

/// Parses a grid from a multiline string literal at comptime.
///
/// Panics:
///   - If the input string is empty or ill-formed (e.g., missing newlines).
///   - If `std.mem.tokenizeScalar` or `std.mem.count` exceed the evaluation branch quota.
///
/// Note: This function is specifically designed for `comptime` execution.
fn parseGrid(comptime in: []const u8) Grid {
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

const Coord = [2]usize;

const Result = struct {
    splits: u32 = 0,
    paths: u64 = 0,
};

fn simulateBeamPaths(grid: Grid, nodeCache: *std.AutoArrayHashMap(Coord, u64), pos: Coord) !u64 {
    var y, const x = pos;
    while (y < grid.len - 1) {
        switch (grid[y][x]) {
            '^' => {
                if (nodeCache.get(.{ y, x })) |cached| {
                    return cached;
                }

                const left = try simulateBeamPaths(grid, nodeCache, Coord{ y + 1, x - 1 });
                const right = try simulateBeamPaths(grid, nodeCache, Coord{ y + 1, x + 1 });
                const count = left + right;
                try nodeCache.put(.{ y, x }, count);
                return count;
            },
            else => {
                y += 1;
            },
        }
    }
    return 1;
}

fn simulateTachyonBeams(allocator: std.mem.Allocator, grid: Grid) !Result {
    var nodeCache = std.AutoArrayHashMap(Coord, u64).init(allocator);
    defer nodeCache.deinit();

    const start = std.mem.indexOfScalar(u8, grid[0], 'S').?;

    const paths = try simulateBeamPaths(grid, &nodeCache, Coord{ 0, start });

    return Result{
        .splits = @intCast(nodeCache.count()),
        .paths = paths,
    };
}

test "example - part 1" {
    const ex =
        \\.......S.......
        \\...............
        \\.......^.......
        \\...............
        \\......^.^......
        \\...............
        \\.....^.^.^.....
        \\...............
        \\....^.^...^....
        \\...............
        \\...^.^...^.^...
        \\...............
        \\..^...^.....^..
        \\...............
        \\.^.^.^.^.^...^.
        \\...............
        \\
    ;
    const grid = comptime parseGrid(ex);
    const res = try simulateTachyonBeams(std.testing.allocator, grid);
    try std.testing.expectEqual(21, res.splits);
}

test "example - part 2" {
    const ex =
        \\.......S.......
        \\...............
        \\.......^.......
        \\...............
        \\......^.^......
        \\...............
        \\.....^.^.^.....
        \\...............
        \\....^.^...^....
        \\...............
        \\...^.^...^.^...
        \\...............
        \\..^...^.....^..
        \\...............
        \\.^.^.^.^.^...^.
        \\...............
        \\
    ;
    const grid = comptime parseGrid(ex);
    const res = try simulateTachyonBeams(std.testing.allocator, grid);
    try std.testing.expectEqual(40, res.paths);
}
