const std = @import("std");
const sdl = @import("sdl2");

const Self = @This();

const Square = struct {
    pos: sdl.Point,
    size: c_int,

    pub fn getRect(self: *const Square) sdl.Rectangle {
        return .{
            .x = self.pos.x - self.size>>1, 
            .y = self.pos.y - self.size>>1,
            .width = self.size,
            .height = self.size,
        };
    }
};

window: sdl.Window,
renderer: sdl.Renderer,
bg_color: sdl.Color = sdl.Color.black,
fg_color: sdl.Color = sdl.Color.white,
square: Square = Square{.pos = .{.x = 40, .y = 40}, .size = 20},

pub fn run(self: *const Self) !void {
    main_loop: while (true) {
        while (sdl.pollEvent()) |e| {
            switch (e) {
                .window => try self.render(),
                .key_up => |key_event| {
                    var is_exit_key = key_event.keycode == .q;
                    is_exit_key = is_exit_key and key_event.modifiers.get(.left_control);
                    if (is_exit_key) 
                        break :main_loop;
                },
                .quit => break :main_loop,
                else => {},
            }
        }
    }
}

fn render(self: *const Self) !void {
    try self.renderer.clear();
    try self.renderer.setColor(self.bg_color);
    try self.renderer.fillRect(self.renderer.getViewport());
    try self.renderer.setColor(self.fg_color);
    try self.renderer.fillRect(self.square.getRect());
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
    ) catch |err| fallback: {
        std.debug.print("Error '{}' while using hardware accelarated rendering, falling back to software rendering", .{err});
        break :fallback try sdl.createRenderer(
            self.window, null,
            .{.software = true},
        );
    };
    errdefer self.renderer.destroy();

    return self;
}

pub fn deinit(self: *const Self) void {
    self.renderer.destroy();
    self.window.destroy();
    sdl.quit();
}

