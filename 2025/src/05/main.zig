const std = @import("std");

const input = @embedFile("./input.txt");

pub fn main() !void {
    const in = comptime parse(input);
    const part1 = countFreshIngredients(in);

    std.debug.print("Part 1: {d}\n", .{part1});

    const part2 = 0;

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
    const range_len = comptime std.mem.count(u8, range_lines, &[_]u8{'\n'});
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
