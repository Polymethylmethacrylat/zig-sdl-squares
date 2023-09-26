const std = @import("std");
const SdlApp = @import("SdlApp.zig");

pub fn main() !void {
    const app = try SdlApp.init();
    defer app.deinit();
    try app.run();
}
