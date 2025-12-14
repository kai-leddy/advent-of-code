const std = @import("std");

const input = @embedFile("./input.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    const boxes = comptime parseJBoxes(input);

    const part1 = try multLargest3Circuits(allocator, boxes, 1000);

    std.debug.print("Part 1: {d}\n", .{part1});

    const part2 = 0;

    std.debug.print("Part 2: {d}\n", .{part2});
}

const JBox = struct {
    id: u32,
    x: u32,
    y: u32,
    z: u32,
    distTo: []const f64,
};

fn parseJBoxes(comptime in: []const u8) []const JBox {
    std.debug.assert(@inComptime()); // this function only seems to work at comptime

    @setEvalBranchQuota(100_000);
    const len = comptime std.mem.count(u8, in, &[_]u8{'\n'});
    @setEvalBranchQuota(len * 10_000);
    var iter = std.mem.tokenizeScalar(u8, in, '\n');
    var boxes: [len]JBox = undefined;
    for (0..len) |i| {
        const line = iter.next().?;
        var line_iter = std.mem.tokenizeScalar(u8, line, ',');
        boxes[i] = JBox{
            .id = i,
            .x = try std.fmt.parseInt(u32, line_iter.next().?, 10),
            .y = try std.fmt.parseInt(u32, line_iter.next().?, 10),
            .z = try std.fmt.parseInt(u32, line_iter.next().?, 10),
            .distTo = undefined,
        };
    }
    // calculate distances
    for (0..len) |i| {
        var dists: [len]f64 = undefined;
        for (0..len) |j| {
            if (i == j) {
                dists[j] = 0;
            } else {
                dists[j] = distanceBetween(boxes[i], boxes[j]);
            }
        }
        const d = dists;
        boxes[i].distTo = &d;
    }
    // copy mutable slice to a const to return from comptime
    const final = boxes;
    return &final;
}

fn distanceBetween(a: JBox, b: JBox) f64 {
    const dx = @as(i64, a.x) - b.x;
    const dy = @as(i64, a.y) - b.y;
    const dz = @as(i64, a.z) - b.z;
    const dist = @sqrt(@as(f64, @floatFromInt(dx * dx)) + @as(f64, @floatFromInt(dy * dy)) + @as(f64, @floatFromInt(dz * dz)));
    return dist;
}

const Connection = struct {
    a: usize,
    b: usize,
    distance: f64,
};

fn connCompare(ctx: void, a: Connection, b: Connection) bool {
    _ = ctx;
    return a.distance < b.distance;
}

fn getAllConnectionsByDistance(comptime boxes: []const JBox) []const Connection {
    const conn_count = boxes.len * (boxes.len - 1) / 2;
    var connections: [conn_count]Connection = undefined;
    var index: usize = 0;
    for (boxes, 0..) |box_a, i| {
        for (i + 1..boxes.len) |j| {
            connections[index] = Connection{
                .a = i,
                .b = j,
                .distance = box_a.distTo[j],
            };
            index += 1;
        }
    }
    std.sort.block(Connection, &connections, {}, connCompare);
    const final = connections;
    return &final;
}

const UsedConns = std.AutoHashMap([2]usize, void);

fn smallestUnusedConnection(used: *UsedConns, connections: []const Connection) !?Connection {
    for (connections) |conn| {
        if (!used.contains(.{ conn.a, conn.b })) {
            try used.put(.{ conn.a, conn.b }, {});
            return conn;
        }
    }
    return null;
}

fn multLargest3Circuits(allocator: std.mem.Allocator, comptime boxes: []const JBox, conn_count: comptime_int) !u64 {
    const connections = comptime getAllConnectionsByDistance(boxes);

    var used = UsedConns.init(allocator);
    defer used.deinit();

    for (0..conn_count) |_| {
        const conn = (try smallestUnusedConnection(&used, connections)).?;
        std.debug.print("Smallest: ({d},{d},{d}) -> ({d},{d},{d}) == {d}\n", .{
            boxes[conn.a].x,
            boxes[conn.a].y,
            boxes[conn.a].z,
            boxes[conn.b].x,
            boxes[conn.b].y,
            boxes[conn.b].z,
            conn.distance,
        });
    }

    return 0;
}

test "example - part 1" {
    const ex =
        \\162,817,812
        \\57,618,57
        \\906,360,560
        \\592,479,940
        \\352,342,300
        \\466,668,158
        \\542,29,236
        \\431,825,988
        \\739,650,466
        \\52,470,668
        \\216,146,977
        \\819,987,18
        \\117,168,530
        \\805,96,715
        \\346,949,466
        \\970,615,88
        \\941,993,340
        \\862,61,35
        \\984,92,344
        \\425,690,689
        \\
    ;
    const allocator = std.testing.allocator;
    const boxes = comptime parseJBoxes(ex);
    try std.testing.expectEqual(40, try multLargest3Circuits(allocator, boxes, 10));
}
