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

/// `MutGrid` provides a mutable grid of `u8`s, backed by an `ArenaAllocator`.
/// It can be initialized from an immutable `Grid` and must be deinitialized to free its memory.
const MutGrid = struct {
    grid: [][]u8,
    arena: std.heap.ArenaAllocator,

    /// Initializes a mutable grid from an immutable grid.
    /// The mutable grid is allocated within an arena, and its contents are a deep copy of the original grid.
    /// The arena is owned by the returned `MutGrid` and must be deinitialized when no longer needed.
    fn init(allocator: std.mem.Allocator, orig: Grid) !MutGrid {
        var arena = std.heap.ArenaAllocator.init(allocator);
        const alloc = arena.allocator();
        errdefer arena.deinit(); // Ensure arena is deinitialized if allocation fails

        const slice: [][]u8 = try alloc.alloc([]u8, orig.len);
        for (0..orig.len) |i| {
            slice[i] = try alloc.alloc(u8, orig[i].len);
            @memcpy(slice[i], orig[i]);
        }

        return MutGrid{
            .grid = slice,
            .arena = arena,
        };
    }
    /// Deinitializes the grid's arena allocator.
    fn deinit(self: *MutGrid) void {
        self.arena.deinit();
    }
};

const Coord = struct { y: usize, x: usize };

const Result = struct {
    splits: u32,
    paths: u32,
};

const Path = struct { done: bool, splits: []Coord };

fn simulateTachyonBeams(allocator: std.mem.Allocator, grid: Grid) !Result {
    var mutGrid = try MutGrid.init(allocator, grid);
    defer mutGrid.deinit();

    const start = std.mem.indexOfScalar(u8, grid[0], 'S').?;
    mutGrid.grid[0][start] = '|';

    var nodes = std.AutoHashMap(Coord, void).init(allocator);
    defer nodes.deinit();
    // TODO: change the implementation to traverse paths individually and track them
    // rather than trying to iterate the grid itself (e.g. a depth/breadth first search)

    var paths = try std.ArrayList(Path).initCapacity(allocator, 1);
    defer paths.deinit(allocator);

    for (mutGrid.grid, 0..) |row, y| {
        // don't bother processing the last row
        if (y + 1 >= mutGrid.grid.len) break;
        for (row, 0..) |cell, x| {
            switch (cell) {
                '.' => continue,
                '^' => continue,
                '|' => {
                    const below = mutGrid.grid[y + 1][x];
                    switch (below) {
                        '|' => continue,
                        '.' => mutGrid.grid[y + 1][x] = '|',
                        '^' => {
                            if (mutGrid.grid[y + 1][x - 1] != '|') {
                                try paths.append(allocator, .{ .done = false, .splits = undefined });
                            }
                            if (mutGrid.grid[y + 1][x + 1] != '|') {
                                try paths.append(allocator, .{ .done = false, .splits = undefined });
                            }
                            mutGrid.grid[y + 1][x - 1] = '|';
                            mutGrid.grid[y + 1][x + 1] = '|';
                            try nodes.put(.{ .y = y, .x = x }, {});
                        },
                        else => unreachable,
                    }
                },
                else => unreachable,
            }
        }
    }

    return Result{ .splits = nodes.count(), .paths = @intCast(paths.items.len) };
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
