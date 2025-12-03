const std = @import("std");

const input = @embedFile("./input.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer gpa.deinit();
    const alloc = gpa.allocator();

    const part1 = try invalidIDTotal(alloc, input);

    std.debug.print("Part 1: {d}\n", .{part1});

    const part2 = 0;

    std.debug.print("Part 2: {d}\n", .{part2});
}

const Range = struct {
    first: u32,
    last: u32,
};

/// Caller owns and must free the returned slice with `allocator.free()`.
fn splitStringToRanges(str: []const u8) []Range {
    const len = std.mem.count(u8, str, &[_]u8{','});
    var segments = std.mem.tokenizeScalar(u8, str, ',');
    var ranges: [len + 1]Range = undefined;
    for (0..len) |i| {
        const segment = segments.next().?;
        var iter = std.mem.tokenizeScalar(u8, segment, '-');
        const first = try std.fmt.parseInt(u32, iter.next().?, 10);
        const last = try std.fmt.parseInt(u32, iter.next().?, 10);

        ranges[i] = Range{ .first = first, .last = last };
    }
    return &ranges;
}

fn invalidIDTotal(comptime in: []const u8) !u32 {
    @setEvalBranchQuota(10_000);
    const ranges = comptime splitStringToRanges(in);

    // TODO: actually iterate the ranges and find the invalid IDs

    return @intCast(ranges.len);
}

test "example" {
    const ex = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";
    try std.testing.expectEqual(@as(u32, 1227775554), invalidIDTotal(ex));
}
