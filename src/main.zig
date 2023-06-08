const std = @import("std");
const args = @import("./args.zig");

pub fn main() !void {
    var minutes: u8 = 0;
    try args.processMain(&minutes);
    std.debug.print("{d}\n", .{minutes});
}
