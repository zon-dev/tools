const std = @import("std");
const testing = std.testing;
const mem = std.mem;
const Uri = std.Uri;
const ParseError = std.Uri.ParseError;
const StringHashMap = @import("std").StringHashMap;
const URL = @import("url.zig");

test "URL" {
    var url = URL.init(.{});
    const text = "http://example.com/path?query=1&query2=2";
    const result = url.parse(text) catch return;
    try testing.expectEqualStrings("http", result.scheme());
    try testing.expectEqualStrings(
        "example.com",
        result.host(),
    );
    try testing.expectEqualStrings(
        "/path",
        result.path(),
    );
    try testing.expectEqualStrings("query=1&query2=2", result.query());

    var querymap = result.queryMap();
    try testing.expectEqualStrings("1", querymap.get("query").?);
    try testing.expectEqualStrings("2", querymap.get("query2").?);

    if (querymap.get("query3") != null) {
        try testing.expect(false);
    }

    // query=1&query2=2
    var qm = URL.parseQuery(result.query());
    try testing.expectEqualStrings("1", qm.get("query").?);
    try testing.expectEqualStrings("2", qm.get("query2").?);

    if (qm.get("query3") != null) {
        try testing.expect(false);
    }

    const uri = "foo://example.com:8042/over/there?name=ferret#nose";
    var url2 = URL.init(.{});
    const result2 = url2.parse(uri) catch return;
    try testing.expectEqualStrings("foo", result2.scheme());
    try testing.expectEqualStrings(
        "example.com",
        result2.host(),
    );
    try testing.expectEqualStrings(
        "/over/there",
        result2.path(),
    );
    try testing.expectEqualStrings("name=ferret", result2.query());
    var qm2 = url2.queryMap();
    try testing.expectEqualStrings("ferret", qm2.get("name").?);
    try testing.expectEqualStrings("nose", result2.fragment());
}
