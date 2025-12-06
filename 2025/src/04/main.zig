const std = @import("std");

const input = @embedFile("./input.txt");

const Grid = []const []const u8;

pub fn main() !void {
    const part1 = countAccessible(comptime parseGrid(input));

    std.debug.print("Part 1: {d}\n", .{part1});

    const part2 = countAllAccessible(comptime parseGrid(input)) catch 0;

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

fn countAdjacent(grid: Grid, y: usize, x: usize) u32 {
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

fn countAccessible(grid: Grid) u32 {
    var count: u32 = 0;
    for (grid, 0..) |row, y| {
        for (row, 0..) |cell, x| {
            if (cell != '@') continue;
            if (countAdjacent(grid, y, x) < 4) count += 1;
        }
    }
    return count;
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

fn countAllAccessible(grid: Grid) !u32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    var mutGrid = try MutGrid.init(allocator, grid);
    defer mutGrid.deinit();

    var count: u32 = 0;
    loop: while (true) {
        var taken: u32 = 0;
        for (mutGrid.grid, 0..) |row, y| {
            for (row, 0..) |cell, x| {
                if (cell != '@') continue;
                if (countAdjacent(mutGrid.grid, y, x) < 4) {
                    count += 1;
                    taken += 1;
                    mutGrid.grid[y][x] = '.';
                }
            }
        }
        if (taken == 0) break :loop;
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

test "example - part 2" {
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
    try std.testing.expectEqual(43, countAllAccessible(grid) catch 0);
}
