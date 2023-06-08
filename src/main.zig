const std = @import("std");
const args = @import("./args.zig");
const signals = @import("./signals.zig");
const unistd = @cImport({
    @cInclude("unistd.h");
});
const raylib = @cImport({
    @cInclude("raylib.h");
});

const SECONDS_PER_MINUTE = 60;

const State = enum {
    idle,
    ticking,
    alarm_ringing,
    alarm_chiming,
};

var state = State.idle;
var seconds: u14 = undefined;
var should_run = true;
var ring_sound: raylib.Sound = undefined;
var chime_sound: raylib.Sound = undefined;

pub fn main() !void {
    var params = try args.processMain();
    seconds = @as(u14, params.minutes) * SECONDS_PER_MINUTE;

    try signals.register(signals.Alarm, transitions.alarm);
    try signals.register(signals.Acknowledge, transitions.acknowledge);
    try signals.register(signals.Sitdown, transitions.sitdown);
    try signals.register(signals.Standup, transitions.standup);
    try signals.register(signals.Terminate, terminate);
    try signals.register(signals.Interrupt, terminate);

    raylib.InitAudioDevice();
    defer raylib.CloseAudioDevice();

    ring_sound = raylib.LoadSound(params.ring_path);
    if (!raylib.IsSoundReady(ring_sound)) {
        std.debug.print("error: could not load sound\n", .{});
        return;
    }
    defer raylib.UnloadSound(ring_sound);
    chime_sound = raylib.LoadSound(params.chime_path);
    if (!raylib.IsSoundReady(chime_sound)) {
        std.debug.print("error: could not load sound\n", .{});
        return;
    }
    defer raylib.UnloadSound(chime_sound);

    _ = signals.raise(signals.Sitdown);
    while (should_run) {
        switch (state) {
            .idle => _ = unistd.pause(),
            .ticking => _ = unistd.pause(),
            .alarm_ringing => if (!raylib.IsSoundPlaying(ring_sound)) raylib.PlaySound(ring_sound),
            .alarm_chiming => if (!raylib.IsSoundPlaying(chime_sound)) raylib.PlaySound(chime_sound),
        }
    }
}

const transitions = struct {
    fn acknowledge(signo: c_int) callconv(.C) void {
        _ = signo;
        if (state != .alarm_ringing) return;
        state = .alarm_chiming;
        raylib.StopSound(ring_sound);
        _ = unistd.alarm(5 * SECONDS_PER_MINUTE);
    }
    fn alarm(signo: c_int) callconv(.C) void {
        _ = signo;
        state = .alarm_ringing;
        raylib.StopSound(chime_sound);
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
        if (state != .alarm_chiming) return;
        state = .idle;
        raylib.StopSound(chime_sound);
        _ = unistd.alarm(0);
    }
};

fn terminate(signo: c_int) callconv(.C) void {
    _ = signo;
    should_run = false;
}
