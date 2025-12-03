const std = @import("std");

fn parseU32(str: []const u8) !u32 {
    return try std.fmt.parseInt(u32, str, 10);
}

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
fn splitStringToRanges(alloc: std.mem.Allocator, str: []const u8) ![]Range {
    var segments = std.mem.tokenizeScalar(u8, str, ',');
    var ranges = try std.ArrayList(Range).initCapacity(alloc, 0);
    defer ranges.deinit(alloc); // just in case
    var i: usize = 0;
    while (segments.next()) |segment| : (i += 1) {
        var iter = std.mem.tokenizeScalar(u8, segment, '-');
        const first = try parseU32(iter.next().?);
        const last = try parseU32(iter.next().?);
        std.debug.print("{d} - {d}\n", .{ first, last });

        try ranges.append(alloc, Range{ .first = first, .last = last });
    }
    return ranges.toOwnedSlice(alloc);
}

fn invalidIDTotal(alloc: std.mem.Allocator, in: []const u8) !u32 {
    const ranges = try comptime splitStringToRanges(alloc, in);
    defer alloc.free(ranges);

    // TODO: actually iterate the ranges and find the invalid IDs

    return @intCast(ranges.len);
}

test "example" {
    const alloc = std.testing.allocator;

    const ex = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";
    try std.testing.expectEqual(@as(u32, 1227775554), invalidIDTotal(alloc, ex));
}
