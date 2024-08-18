const std = @import("std");
const testing = std.testing;
const mem = std.mem;
const Uri = std.Uri;
const ParseError = std.Uri.ParseError;
const StringHashMap = @import("std").StringHashMap;

pub const URL = @This();

allocator: std.mem.Allocator = std.heap.page_allocator,
uri: Uri = undefined,
querymap: StringHashMap([]const u8) = StringHashMap([]const u8).init(std.heap.page_allocator),

pub fn init(self: URL) URL {
    return .{
        .allocator = self.allocator,
        .uri = self.uri,
        .querymap = self.querymap,
    };
}

pub fn parse(self: *URL, text: []const u8) ParseError!*URL {
    self.uri = try Uri.parse(text);
    self.querymap = self.queryMap();
    return self;
}

pub fn query(self: *URL) []const u8 {
    return self.uri.query.?.percent_encoded;
}

pub fn fragment(self: *URL) []const u8 {
    return self.uri.fragment.?.percent_encoded;
}

pub fn scheme(self: *URL) []const u8 {
    return self.uri.scheme;
}

pub fn host(self: *URL) []const u8 {
    return self.uri.host.?.percent_encoded;
}

pub fn path(self: *URL) []const u8 {
    return self.uri.path.percent_encoded;
}

pub fn queryMap(self: *URL) StringHashMap([]const u8) {
    self.querymap = parseQuery(self.query());
    return self.querymap;
}

pub fn parseQuery(uri_query: []const u8) StringHashMap([]const u8) {
    var querymap = StringHashMap([]const u8).init(std.heap.page_allocator);
    var queryitmes = std.mem.splitSequence(u8, uri_query, "&");
    while (true) {
        const pair = queryitmes.next();
        if (pair == null) {
            break;
        }
        var kv = std.mem.splitSequence(u8, pair.?, "=");
        if (kv.buffer.len == 0) {
            break;
        }
        const key = kv.next();
        if (key == null) {
            break;
        }
        const value = kv.next();
        if (value == null) {
            break;
        }
        querymap.put(key.?, value.?) catch break;
    }
    return querymap;
}
