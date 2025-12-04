const std = @import("std");

const input = @embedFile("./input.txt");

pub fn main() !void {
    const part1 = invalidIDTotal(input, Method.doubled);

    std.debug.print("Part 1: {d}\n", .{part1});

    const part2 = invalidIDTotal(input, Method.repeated);

    std.debug.print("Part 2: {d}\n", .{part2});
}

const Range = struct {
    first: u64,
    last: u64,
};

/// Caller owns and must free the returned slice with `allocator.free()`.
fn splitStringToRanges(str: []const u8) []const Range {
    const len = std.mem.count(u8, str, &[_]u8{','});
    @setEvalBranchQuota(len * 1000);
    var segments = std.mem.tokenizeAny(u8, str, &[_]u8{ ',', '\n' });
    var ranges: [len + 1]Range = undefined;
    for (0..(len + 1)) |i| {
        const segment = segments.next().?;
        var iter = std.mem.tokenizeScalar(u8, segment, '-');
        const first = std.fmt.parseInt(u64, iter.next().?, 10) catch unreachable;
        const last = std.fmt.parseInt(u64, iter.next().?, 10) catch unreachable;

        ranges[i] = Range{ .first = first, .last = last };
    }
    // copy mutable slice to a const to return from comptime
    const final = ranges;
    return &final;
}

const Method = enum { doubled, repeated };

fn invalidIDTotal(comptime in: []const u8, method: Method) u64 {
    const ranges = comptime splitStringToRanges(in);

    var total: u64 = 0;

    for (ranges) |range| {
        for ((range.first)..(range.last + 1)) |x| {
            const id = @as(u64, @intCast(x));
            const isInvalid = switch (method) {
                Method.doubled => isDoubledID(id),
                Method.repeated => isRepeatedID(id),
            };
            if (isInvalid) {
                total += id;
            }
        }
    }

    return total;
}

fn isDoubledID(id: u64) bool {
    // unlikely that any of the numbers will be more than 64 digits
    var buf: [64]u8 = undefined;
    const asStr = std.fmt.bufPrint(&buf, "{}", .{id}) catch {
        return false;
    };

    const left = asStr[0..(asStr.len / 2)];
    const right = asStr[(asStr.len / 2)..asStr.len];

    return std.mem.eql(u8, left, right);
}

fn isRepeatedID(id: u64) bool {
    // unlikely that any of the numbers will be more than 64 digits
    var buf: [64]u8 = undefined;
    const asStr = std.fmt.bufPrint(&buf, "{}", .{id}) catch {
        return false;
    };
    for (1..(asStr.len / 2) + 1) |char_count| {
        // if the string length is not perfectly divisible by this character count
        // then it cannot be perfectly repeating, so skip it
        if (@rem(asStr.len, char_count) != 0) {
            continue;
        }
        const repetitions = asStr.len / char_count;
        const chars = asStr[0..char_count];
        var match = true;
        for (0..repetitions) |i| {
            const start = i * char_count;
            const slice = asStr[start..(start + char_count)];

            if (!std.mem.eql(u8, chars, slice)) {
                match = false;
            }
        }
        if (match) {
            return true;
        }
    }
    return false;
}

test "example - part 1" {
    const ex = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";
    try std.testing.expectEqual(@as(u64, 1227775554), invalidIDTotal(ex, Method.doubled));
}

test "example - part 2" {
    const ex = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";
    try std.testing.expectEqual(@as(u64, 4174379265), invalidIDTotal(ex, Method.repeated));
}
