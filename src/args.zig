const std = @import("std");

const ArgError = error{
    TooMuchTime,
    InvalidCharacter,
    TimeNotProvided,
    PathNotProvided,
};

pub const MainParams = struct {
    minutes: u8,
    ring_path: ?[*:0]const u8,
    chime_path: ?[*:0]const u8,
};

pub fn processMain() ArgError!MainParams {
    var minutes: u8 = 0;
    var ring_path: ?[*:0]const u8 = null;
    var chime_path: ?[*:0]const u8 = null;
    var args = std.process.args();
    defer args.deinit();
    _ = args.skip();
    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg[0..2], "-m")) {
            minutes = std.fmt.parseInt(u8, arg[2..], 10) catch |err| switch (err) {
                std.fmt.ParseIntError.Overflow => return ArgError.TooMuchTime,
                std.fmt.ParseIntError.InvalidCharacter => return ArgError.InvalidCharacter,
            };
        } else if (std.mem.eql(u8, arg[0..2], "-r")) {
            ring_path = arg[2..];
        } else if (std.mem.eql(u8, arg[0..2], "-c")) {
            chime_path = arg[2..];
        }
    }
    if (minutes == 0) {
        return ArgError.TimeNotProvided;
    }
    if (ring_path == null or chime_path == null) {
        return ArgError.PathNotProvided;
    }
    return MainParams{
        .minutes = minutes,
        .ring_path = ring_path,
        .chime_path = chime_path,
    };
}
