const std = @import("std");

const input = @embedFile("./input.txt");

pub fn main() !void {
    const in = comptime parse(input);
    const part1 = countFreshIngredients(in);

    std.debug.print("Part 1: {d}\n", .{part1});

    const part2 = totalFreshIngredientIDs(in);

    std.debug.print("Part 2: {d}\n", .{part2});
}

const ID = u64;

const Range = struct {
    min: ID,
    max: ID,
    fn includes(self: Range, id: ID) bool {
        return id >= self.min and id <= self.max;
    }
};

const Input = struct {
    ranges: []const Range,
    ids: []const ID,
};

fn splitSections(comptime in: []const u8) [2][]const u8 {
    std.debug.assert(@inComptime());

    @setEvalBranchQuota(in.len * 1000);
    var splitter = std.mem.tokenizeSequence(u8, in, &.{ '\n', '\n' });
    var sections: [2][]const u8 = undefined;
    sections[0] = splitter.next().?;
    sections[1] = splitter.next().?;
    return sections;
}

fn parse(comptime in: []const u8) Input {
    std.debug.assert(@inComptime());

    @setEvalBranchQuota(in.len * 1000);
    const sections = comptime splitSections(in);
    const range_lines = sections[0];
    const id_lines = sections[1];
    const range_len = comptime std.mem.count(u8, range_lines, &[_]u8{'\n'}) + 1;
    var range_iter = std.mem.tokenizeScalar(
        u8,
        range_lines,
        '\n',
    );
    var ranges: [range_len]Range = undefined;
    for (0..range_len) |i| {
        const line = range_iter.next().?;
        var line_iter = std.mem.tokenizeScalar(
            u8,
            line,
            '-',
        );
        const min = line_iter.next().?;
        const max = line_iter.next().?;
        ranges[i] = Range{
            .min = std.fmt.parseInt(ID, min, 10) catch unreachable,
            .max = std.fmt.parseInt(ID, max, 10) catch unreachable,
        };
    }
    const id_len = comptime std.mem.count(u8, id_lines, &[_]u8{'\n'});
    var id_iter = std.mem.tokenizeScalar(
        u8,
        id_lines,
        '\n',
    );
    var ids: [id_len]ID = undefined;
    for (0..id_len) |i| {
        const num = id_iter.next().?;
        ids[i] = std.fmt.parseInt(ID, num, 10) catch unreachable;
    }
    const r = ranges;
    const i = ids;
    return Input{ .ranges = &r, .ids = &i };
}

fn countFreshIngredients(in: Input) u32 {
    var count: u32 = 0;
    ids: for (in.ids) |id| {
        for (in.ranges) |range| {
            if (range.includes(id)) {
                count += 1;
                continue :ids;
            }
        }
    }
    return count;
}

fn calculateOverlapsWithRanges(range: Range, others: []const Range) u64 {
    var overlaps: u64 = 0;
    var mutRange: Range = range;
    for (others, 0..) |other, o| {
        // test for outside of range first
        if (other.min > mutRange.max or other.max < mutRange.min) continue;
        // test for o fully inside of range
        if (other.min >= mutRange.min and other.max <= mutRange.max) {
            overlaps += other.max - other.min + 1; // plus 1 because inclusive
            // split into a before and after range and calculate with recursion
            const before = Range{ .min = mutRange.min, .max = other.min - 1 };
            const after = Range{ .min = other.max + 1, .max = mutRange.max };
            const beforeOverlaps = calculateOverlapsWithRanges(before, others[o + 1 ..]);
            const afterOverlaps = calculateOverlapsWithRanges(after, others[o + 1 ..]);
            overlaps += beforeOverlaps + afterOverlaps;
            break;
        }
        // test for range fully inside of o
        else if (mutRange.min >= other.min and mutRange.max <= other.max) {
            overlaps += mutRange.max - mutRange.min + 1; // plus 1 because inclusive
            break;
        }
        // test right overlap
        else if (other.min >= mutRange.min and other.min <= mutRange.max) {
            overlaps += mutRange.max - other.min + 1;
            mutRange = Range{ .min = mutRange.min, .max = other.min - 1 };
        }
        // test left overlap
        else if (other.max <= mutRange.max and other.max >= mutRange.min) {
            overlaps += other.max - mutRange.min + 1;
            mutRange = Range{ .min = other.max + 1, .max = mutRange.max };
        }
    }

    return overlaps;
}

fn totalFreshIngredientIDs(in: Input) u64 {
    var totalAllRanges: u64 = 0;
    for (in.ranges) |range| {
        // plus 1 because ranges are inclusive
        const total = range.max - range.min + 1;
        // std.debug.print("TOTAL: {d}\n", .{total});
        totalAllRanges += total;
    }
    // std.debug.print("TOTAL TOTAL: {d}\n", .{totalAllRanges});
    var overlaps: u64 = 0;
    for (in.ranges, 0..) |range, i| {
        // plus 1 because ranges are inclusive
        const overlap = calculateOverlapsWithRanges(range, in.ranges[i + 1 ..]);
        // std.debug.print("OVERLAP: {d}\n", .{overlap});
        overlaps += overlap;
    }
    // std.debug.print("TOTAL OVERLAP: {d}\n", .{overlaps});

    return totalAllRanges - overlaps;
}

test "example - part 1" {
    const ex =
        \\3-5
        \\10-14
        \\16-20
        \\12-18
        \\
        \\1
        \\5
        \\8
        \\11
        \\17
        \\32
        \\
    ;
    try std.testing.expectEqual(3, countFreshIngredients(comptime parse(ex)));
}

test "example - part 2" {
    const ex =
        \\3-5
        \\10-14
        \\16-20
        \\12-18
        \\
        \\1
        \\5
        \\8
        \\11
        \\17
        \\32
        \\
    ;
    try std.testing.expectEqual(14, totalFreshIngredientIDs(comptime parse(ex)));
}

test "overlap calculations" {
    const eql = std.testing.expectEqual;
    try eql(2, calculateOverlapsWithRanges(.{ .min = 10, .max = 20 }, &.{.{ .min = 15, .max = 16 }}));
    try eql(2, calculateOverlapsWithRanges(.{ .min = 15, .max = 16 }, &.{.{ .min = 10, .max = 20 }}));
    try eql(1, calculateOverlapsWithRanges(.{ .min = 10, .max = 20 }, &.{.{ .min = 6, .max = 10 }}));
    try eql(2, calculateOverlapsWithRanges(.{ .min = 10, .max = 20 }, &.{.{ .min = 6, .max = 11 }}));
    try eql(1, calculateOverlapsWithRanges(.{ .min = 10, .max = 20 }, &.{.{ .min = 20, .max = 34 }}));
    try eql(2, calculateOverlapsWithRanges(.{ .min = 10, .max = 20 }, &.{.{ .min = 19, .max = 34 }}));
    try eql(11, calculateOverlapsWithRanges(.{ .min = 10, .max = 20 }, &.{.{ .min = 10, .max = 20 }}));

    // now test with multiple ranges
    try eql(8, calculateOverlapsWithRanges(.{ .min = 10, .max = 20 }, &.{ .{ .min = 5, .max = 15 }, .{ .min = 19, .max = 35 } }));
    try eql(11, calculateOverlapsWithRanges(.{ .min = 10, .max = 20 }, &.{ .{ .min = 5, .max = 15 }, .{ .min = 19, .max = 35 }, .{ .min = 0, .max = 100 } }));
}

test "total fresh ingredients" {
    const eql = std.testing.expectEqual;
    const in = Input{
        .ids = &.{},
        .ranges = &.{ .{ .min = 10, .max = 20 }, .{ .min = 13, .max = 16 }, .{ .min = 5, .max = 15 }, .{ .min = 19, .max = 35 }, .{ .min = 0, .max = 100 } },
    };

    try eql(101, totalFreshIngredientIDs(in));
}
