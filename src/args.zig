const std = @import("std");

const ArgError = error{
    TooMuchTime,
    InvalidCharacter,
    TimeNotProvided,
};

pub fn processMain(minutes: *u8) ArgError!void {
    var args = std.process.args();
    defer args.deinit();
    _ = args.skip();
    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg[0..2], "-m") and arg.len > 2) {
            minutes.* = std.fmt.parseInt(u8, arg[2..], 10) catch |err| switch (err) {
                std.fmt.ParseIntError.Overflow => return ArgError.TooMuchTime,
                std.fmt.ParseIntError.InvalidCharacter => return ArgError.InvalidCharacter,
            };
        }
    }
    if (minutes.* == 0) {
        return ArgError.TimeNotProvided;
    }
}
