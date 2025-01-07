const std = @import("std");
const utils = @import("utils.zig");
const testing = std.testing;

fn isSafeInterval(a: u8, b: u8) bool {
    if (b > a)
        return (b - a >= 1) and (b - a <= 3);
    return (a - b >= 1) and (a - b <= 3);
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

test "isSafeInterval" {
    try testing.expect(isSafeInterval(1, 2));
    try testing.expect(!isSafeInterval(2, 7));
}

test "isAscending" {
    try testing.expect(isAscending(&[_]u8{ 1, 2, 3 }));
    try testing.expect(!isAscending(&[_]u8{ 2, 1, 3 }));
}

test "Example" {
    const input =
        \\ 7 6 4 2 1
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

    var answer: u8 = 0;

    for (lines[0..]) |line| {
        if (isSafeLine(line))
            answer += 1;
    }

    try testing.expectEqual(2, answer);
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
}
