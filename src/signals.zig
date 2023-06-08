const signal = @cImport({
    @cInclude("signal.h");
});

/// Alarm signal sent to the process when it wakes up from sleep.
/// Should not be sent manually under normal circumstances.
pub const Alarm = signal.SIGALRM;

/// Sent when the user acknowledges the alarm.
pub const Acknowledge = signal.SIGUSR1;

/// Sent when the user leaves the computer.
pub const Standup = signal.SIGUSR2;

/// Sent when the user sits down at the computer.
///
/// SIGCONT has the positive side effect of continuing program execution, this
/// can be coupled with a self-raised SIGSTOP after a standup signal to reduce
/// CPU usage.
pub const Sitdown = signal.SIGCONT;

pub const Error = error{
    HandlersDisallowedForSignal,
};

pub fn register(signal_number: c_int, comptime handler: fn (c_int) callconv(.C) void) !void {
    if (signal.signal(signal_number, handler) == signal.SIG_ERR) {
        return Error.HandlersDisallowedForSignal;
    }
}

fn nullHandler(signal_number: c_int) callconv(.C) void {
    _ = signal_number;
}
pub inline fn sinkhole(signal_number: c_int) !void {
    try register(signal_number, nullHandler);
}

pub const raise = signal.raise;
