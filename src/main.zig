const std = @import("std");

pub fn main() void {
    std.debug.print("Run tests instead!\n", .{});
}
test {
    _ = @import("day1.zig");
    _ = @import("day2.zig");
}
