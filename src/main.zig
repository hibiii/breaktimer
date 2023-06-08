const std = @import("std");
const args = @import("./args.zig");
const signals = @import("./signals.zig");
const unistd = @cImport({
    @cInclude("unistd.h");
});

const SECONDS_PER_MINUTE = 60;

const State = enum {
    idle,
    ticking,
    alarm_ringing,
    alarm_chiming,
};

var state = State.idle;
var seconds: u16 = undefined;

pub fn main() !void {
    var minutes: u8 = 0;
    try args.processMain(&minutes);
    seconds = minutes * SECONDS_PER_MINUTE;

    try signals.register(signals.Alarm, transitions.alarm);
    try signals.register(signals.Acknowledge, transitions.acknowledge);
    try signals.register(signals.Sitdown, transitions.sitdown);
    try signals.register(signals.Standup, transitions.standup);
    _ = signals.raise(signals.Sitdown);
    while (true) {
        _ = unistd.pause();
        std.debug.print("{?}\n", .{state});
    }
}

const transitions = struct {
    fn acknowledge(signo: c_int) callconv(.C) void {
        _ = signo;
        if (state != .alarm_ringing) return;
        state = .alarm_chiming;
        _ = unistd.alarm(5 * SECONDS_PER_MINUTE);
    }
    fn alarm(signo: c_int) callconv(.C) void {
        _ = signo;
        state = .alarm_ringing;
        _ = unistd.alarm(0);
    }
    fn sitdown(signo: c_int) callconv(.C) void {
        _ = signo;
        if (state != .idle) return;
        state = .ticking;
        _ = unistd.alarm(seconds);
    }
    fn standup(signo: c_int) callconv(.C) void {
        _ = signo;
        state = .idle;
        _ = unistd.alarm(0);
    }
};
