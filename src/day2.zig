const std = @import("std");
const utils = @import("utils.zig");
const testing = std.testing;

fn isSafeInterval(a: u8, b: u8) bool {
    if (b > a)
        return (b - a >= 1) and (b - a <= 3);
    return (a - b >= 1) and (a - b <= 3);
}

fn intervalDiff(comptime T: type, a: T, b: T) T {
    if (b > a)
        return b - a;
    if (a > b)
        return a - b;
    return 0;
}

/// More verbose than sorting and comparing, but also faster.
fn isAscending(a: []const u8) bool {
    var prev: u8 = a[0];
    for (a[1..]) |i| {
        if (prev > i)
            return false;
        prev = i;
    }
    return true;
}

fn isDescending(a: []const u8) bool {
    var prev: u8 = a[0];
    for (a[1..]) |i| {
        if (prev < i)
            return false;
        prev = i;
    }
    return true;
}

fn isSafeLine(line: []const u8) bool {
    var prev: u8 = line[0];
    if (!isAscending(line) and !isDescending(line))
        return false;

    for (line[1..]) |i| {
        if (!isSafeInterval(prev, i))
            return false;

        prev = i;
    }
    return true;
}

fn part1(lines: [][]const u8) u16 {
    var answer: u16 = 0;

    for (lines[0..]) |line| {
        if (isSafeLine(line)) {
            answer += 1;
        }
    }
    return answer;
}

fn isSafeWithSingleBadInterval(line: []const u8, allocator: std.mem.Allocator) !bool {
    if (isSafeLine(line))
        return true;

    // The index we're skipping.
    var subarray = try std.ArrayList(u8).initCapacity(allocator, line.len - 1);
    defer subarray.deinit();

    // We don't care about this data, but just need to populate the underlying array;
    try subarray.insertSlice(0, line[1..]);

    // Permute over every subarray that excludes the item at line[skipped_index].
    // Start at 0 and move forward.
    var index_to_skip: usize = 0;

    while (index_to_skip < line.len) : (index_to_skip += 1) {

        // The index we're replacing in the above subarray.
        var current_insert_index: usize = 0;

        for (0.., line[0..]) |i, num| {
            if (i == index_to_skip)
                continue;
            subarray.items[current_insert_index] = num;
            current_insert_index += 1;
        }

        if (isSafeLine(subarray.items))
            return true;
    }

    return false;
}

fn part2(lines: [][]const u8, allocator: std.mem.Allocator) !u16 {
    var answer: u16 = 0;

    for (lines[0..]) |line| {
        if (try isSafeWithSingleBadInterval(line, allocator))
            answer += 1;
    }
    return answer;
}

test "isSafeInterval" {
    try testing.expect(isSafeInterval(1, 2));
    try testing.expect(!isSafeInterval(2, 7));
}

test "isAscending" {
    try testing.expect(isAscending(&[_]u8{ 1, 2, 3 }));
    try testing.expect(!isAscending(&[_]u8{ 2, 1, 3 }));
}

test "Examples" {
    const input =
        \\7 6 4 2 1
        \\1 2 7 8 9
        \\9 7 6 2 1
        \\1 3 2 4 5
        \\8 6 4 4 1
        \\1 3 6 7 9
    ;
    var lines: [6][]const u8 = undefined;
    defer for (lines[0..]) |line| {
        testing.allocator.free(line);
    };

    const text_lines = try utils.splitLinesAlloc(input, testing.allocator);
    defer testing.allocator.free(text_lines);

    for (0.., text_lines[0..]) |i, line| {
        lines[i] = try utils.splitLineToNumbersAlloc(u8, line, testing.allocator);
    }

    {
        var answer: u8 = 0;

        for (lines[0..]) |line| {
            if (isSafeLine(line))
                answer += 1;
        }

        try testing.expectEqual(2, answer);
    }
    // Part 2
    {
        var answer: u8 = 0;

        for (lines[0..]) |line| {
            if (try isSafeWithSingleBadInterval(line, testing.allocator))
                answer += 1;
        }
        try testing.expectEqual(4, answer);
    }
}

test "Day 2" {
    const allocator = testing.allocator;
    const contents = try std.fs.cwd().readFileAlloc(allocator, "src/day2.txt", 19253);
    const text_lines = try utils.splitLinesAlloc(contents, allocator);
    var lines: [1000][]const u8 = undefined;
    defer {
        allocator.free(text_lines);
        allocator.free(contents);

        for (lines[0..]) |line| {
            allocator.free(line);
        }
    }

    for (0.., text_lines[0 .. text_lines.len - 1]) |i, line| {
        lines[i] = try utils.splitLineToNumbersAlloc(u8, line, allocator);
    }

    std.debug.print("\nDay 2:\n======\n", .{});
    std.debug.print("Part 1: {d}\n", .{part1(&lines)});
    std.debug.print("Part 2: {d}\n", .{try part2(&lines, testing.allocator)});
}
