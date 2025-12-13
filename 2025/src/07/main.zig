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

const Coord = [2]usize;

const Result = struct {
    splits: u32,
    paths: u32,
};

const Path = struct {
    depth: u32 = 0,
    pos: Coord,
};

fn simulateTachyonBeams(allocator: std.mem.Allocator, grid: Grid) !Result {
    var splitters = std.AutoHashMap(Coord, void).init(allocator);
    defer splitters.deinit();
    var paths = try std.ArrayList(Path).initCapacity(allocator, 1);
    defer paths.deinit(allocator);

    // setup the first path
    const start = std.mem.indexOfScalar(u8, grid[0], 'S').?;
    const first = Path{
        .pos = Coord{ 0, start },
    };
    try paths.append(allocator, first);

    var path_count: u32 = 1;

    // keep going while we have unfinished paths
    while (paths.items.len > 0) {
        var path = paths.swapRemove(0);
        std.debug.print("paths {d} depth {d} \n", .{ path_count, path.depth });
        while (path.pos[0] < grid.len - 1) {
            const y, const x = path.pos;
            const below = grid[y + 1][x];
            switch (below) {
                '^' => { // handle splitter
                    try splitters.put(.{ y + 1, x }, {});
                    // keep the left path
                    path.pos = Coord{ y + 2, x - 1 };
                    path.depth += 2;
                    // create a new path for the right
                    path_count += 1;
                    const right = Path{
                        .pos = Coord{ y + 2, x + 1 },
                        .depth = path.depth,
                    };
                    // append the new path last, as append will invalidate the `path` pointer
                    try paths.append(allocator, right);
                },
                else => { // handle anything else
                    path.pos = Coord{ y + 1, x };
                    path.depth += 1;
                },
            }
        }
    }

    return Result{ .splits = splitters.count(), .paths = path_count };
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
