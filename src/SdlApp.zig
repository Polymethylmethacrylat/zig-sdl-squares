const std = @import("std");
const sdl = @import("sdl2");

const Self = @This();

const Square = struct {
    pos: sdl.Point,
    size: c_int,

    pub fn getRect(self: *const Square) sdl.Rectangle {
        return .{
            .x = self.pos.x - @divTrunc(self.size, 2), 
            .y = self.pos.y - @divTrunc(self.size, 2),
            .width = self.size,
            .height = self.size,
        };
    }
};

window: sdl.Window,
renderer: sdl.Renderer,
bg_color: sdl.Color = sdl.Color.black,
fg_color: sdl.Color = sdl.Color.white,
squares: std.ArrayList(Square),
square_creation: bool = false,

pub fn run(self: *Self) !void {
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
                .mouse_button_down => |mouse_event| eblk: {
                    if (self.square_creation)
                        break;
                    for (self.squares.items) |square| {
                        if (try std.math.absInt(mouse_event.x - square.pos.x) <= @divTrunc(square.size, 2) and
                            try std.math.absInt(mouse_event.y - square.pos.y) <= @divTrunc(square.size, 2))
                            break :eblk;
                    }
                    try self.squares.append(.{
                        .pos = .{.x = mouse_event.x, .y = mouse_event.y},
                        .size = 50,
                    });
                    try self.render();
                    self.square_creation = true;
                },
                .mouse_motion => |mouse_motion_event| {
                    if (!self.square_creation)
                        break;
                    var square: Square = self.squares.pop();
                    square.size = @max(
                        try std.math.absInt(square.pos.x - mouse_motion_event.x),
                        try std.math.absInt(square.pos.y - mouse_motion_event.y),
                    ) * 2;
                    try self.squares.append(square);
                    try self.render();
                },
                .mouse_button_up => {
                    self.square_creation = false;
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
    for (self.squares.items) |square| {
        try self.renderer.fillRect(square.getRect());
    }
    self.renderer.present();
}

pub fn init(allocator: std.mem.Allocator) !Self {
    try sdl.init(.{
        .video = true,
        .events = true,
    });

    var self = Self{
        .window = undefined,
        .renderer = undefined,
        .squares = undefined,
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
    
    self.squares = try std.ArrayList(Square).initCapacity(allocator, 128);
    errdefer self.squares.deinit();

    return self;
}

pub fn deinit(self: *const Self) void {
    self.squares.deinit();
    self.renderer.destroy();
    self.window.destroy();
    sdl.quit();
}

