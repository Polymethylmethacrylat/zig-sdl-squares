const std = @import("std");
const sdl = @import("sdl2");

const Self = @This();

window: sdl.Window,
renderer: sdl.Renderer,

pub fn run(self: *const Self) !void {
    main_loop: while (true) {
        while (sdl.pollEvent()) |e| {
            switch (e) {
                .window => try self.render(),
                .quit => break :main_loop,
                else => {},
            }
        }
    }
}

fn render(self: *const Self) !void {
    try self.renderer.clear();
    try self.renderer.setColorRGB(0, 0, 0);
    try self.renderer.fillRect(self.renderer.getViewport());
    self.renderer.present();
}

pub fn init() !Self {
    try sdl.init(.{
        .video = true,
        .events = true,
    });

    var self = Self{
        .window = undefined,
        .renderer = undefined,
    };

    self.window = try sdl.createWindow(
        "squares",
        .{.default = {}}, .{.default = {}},
        640, 480,
        .{
            .vis = .shown,
            .resizable = true,
            .allow_high_dpi = true,
        },
    );
    errdefer self.window.destroy();

    self.renderer = sdl.createRenderer(
        self.window, null,
        .{.accelerated = true},
    ) catch try sdl.createRenderer(
        self.window, null,
        .{.software = true},
    );
    errdefer self.renderer.destroy();

    return self;
}

pub fn deinit(self: *const Self) void {
    self.renderer.destroy();
    self.window.destroy();
    sdl.quit();
}

