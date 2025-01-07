const std = @import("std");
const testing = std.testing;
const utils = @import("utils.zig");

/// Caller must free memory.
fn readFileAlloc(alloc: std.mem.Allocator) ![]const u8 {
    return try std.fs.cwd().readFileAlloc(alloc, "src/day1.txt", 14000);
}

fn lineToPair(line: []const u8) ![]isize {
    var i: usize = 0;
    var nums: [2]isize = undefined;
    var tokens = std.mem.splitScalar(u8, line, ' ');

    while (tokens.next()) |t| {
        if (t.len > 0) {
            nums[i] = try std.fmt.parseInt(isize, t, 10);
            i += 1;
        }
    }

    return &nums;
}

fn part1(side_a: []const isize, side_b: []const isize) usize {
    var a: [1000]isize = undefined;
    var b: [1000]isize = undefined;

    @memcpy(&a, side_a);
    @memcpy(&b, side_b);

    std.mem.sort(isize, &a, {}, std.sort.asc(isize));
    std.mem.sort(isize, &b, {}, std.sort.asc(isize));

    var total_distance: usize = 0;
    for (0..side_a.len) |i| {
        total_distance += @abs(a[i] - b[i]);
    }

    return total_distance;
}

fn part2(side_a: []const isize, side_b: []const isize, allocator: std.mem.Allocator) !usize {
    var answer: usize = 0;
    var seen = std.AutoArrayHashMap(isize, u8).init(allocator);
    defer seen.deinit();

    // Populate.
    for (side_b[0..]) |i| {
        if (seen.get(i)) |val| {
            try seen.put(i, val + 1);
        } else {
            try seen.put(i, 1);
        }
    }

    for (side_a[0..]) |i| {
        if (seen.get(i)) |val| {
            answer += @intCast(i * val);
        }
    }

    return answer;
}

test "lineToPair" {
    const text = "51 52";
    const expected = [_]isize{ 51, 52 };
    try testing.expectEqualSlices(isize, &expected, try lineToPair(text));
}

test "Day 1" {
    const allocator = testing.allocator;

    var side_a: [1000]isize = undefined;
    var side_b: [1000]isize = undefined;

    const content = try readFileAlloc(allocator);
    const lines = try utils.splitLinesAlloc(content, allocator);
    defer {
        allocator.free(lines);
        allocator.free(content);
    }

    for (0.., lines[0 .. lines.len - 1]) |i, line| {
        const nums = try lineToPair(line);
        side_a[i] = nums[0];
        side_b[i] = nums[1];
    }

    std.debug.print("Part 1: {d}\n", .{part1(&side_a, &side_b)});
    std.debug.print("Part 2: {d}\n", .{try part2(&side_a, &side_b, allocator)});
}
