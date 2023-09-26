const std = @import("std");
const Allocator = std.mem.Allocator;
const SdlApp = @import("SdlApp.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var app = try SdlApp.init(allocator);
    defer app.deinit();
    try app.run();
}
