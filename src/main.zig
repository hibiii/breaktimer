const std = @import("std");
const args = @import("./args.zig");
const signals = @import("./signals.zig");
const unistd = @cImport({
    @cInclude("unistd.h");
});

pub fn main() !void {
    var minutes: u8 = 0;
    try args.processMain(&minutes);
    const seconds = minutes * 60;

    try signals.sinkhole(signals.Alarm);
    while (true) {
        std.debug.print("tick\n", .{});
        _ = unistd.sleep(seconds);
    }
}
