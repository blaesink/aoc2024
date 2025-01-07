const std = @import("std");

pub fn splitLinesAlloc(text: []const u8, allocator: std.mem.Allocator) ![][]const u8 {
    var lines = std.ArrayList([]const u8).init(allocator);
    var it = std.mem.splitScalar(u8, text, '\n');

    while (it.next()) |line| {
        try lines.append(line);
    }

    return lines.toOwnedSlice();
}

/// Caller owns returned memory.
pub fn splitLineToNumbersAlloc(comptime T: type, data: []const u8, allocator: std.mem.Allocator) ![]const T {
    var numbers = std.ArrayList(T).init(allocator);
    var tokens = std.mem.splitScalar(u8, data, ' ');

    while (tokens.next()) |t| {
        if (t.len > 0)
            try numbers.append(try std.fmt.parseInt(T, t, 10));
    }

    return numbers.toOwnedSlice();
}
