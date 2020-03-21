/// Crush File Format:
///
/// Echo (0)     len (1-byte) data...
/// SetData (1)  id (1-byte) len (1-byte) data...
/// CopyData (2) id (1-byte) offset (1-byte) len (1-byte)
/// Newline (3)
///
///
const std = @import("std");
const os = std.os;
const mem = std.mem;
const fs = std.fs;

const ArrayList = std.ArrayList;
const Allocator = mem.Allocator;
const File = fs.File;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

const DataStore = struct {
    // TODO: need some way of tracking which data stores are the most/least used
    table: [256][256]u8,
};
var dataStore : DataStore = undefined;

pub fn main() anyerror!void {
    try loop(&std.io.getStdIn().inStream().stream);
}

fn loop(inStream: var) !void {
    var buf = ArrayList(u8).init(&arena.allocator);
    while (true) {
        inStream.readUntilDelimiterArrayList(&buf, '\n', std.math.maxInt(usize)) catch |e| switch (e) {
        
        };
        const len = try os.read(fd, buf);
        try process(buf[0..len]);
    }
}

fn process(buf: []const u8) !void {
    std.debug.warn("got '{}'\n", .{buf});
}
