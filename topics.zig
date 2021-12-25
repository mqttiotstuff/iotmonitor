const std = @import("std");
const mem = std.mem;

const assert = std.debug.assert;

// test if the evaluted topic belong to the reference Topic,
// return the sub path if it is
pub fn doesTopicBelongTo(evaluatedTopic: []const u8, referenceTopic: []const u8) !?[]const u8 {
    if (evaluatedTopic.len < referenceTopic.len) return null;
    const isWatched = mem.eql(u8, evaluatedTopic[0..referenceTopic.len], referenceTopic);
    if (isWatched) {
        const subTopic = evaluatedTopic[referenceTopic.len..];
        return subTopic;
    }
    return null;
}

test "Test belong to" {
    const topic1: []const u8 = "/home";
    const topic2: []const u8 = "/home";
    const a = try doesTopicBelongTo(topic1, topic2);
    assert(a != null);
    assert(a.?.len == 0);
}
test "sub path" {
    const topic1: []const u8 = "/home";
    const topic2: []const u8 = "/ho";
    const a = try doesTopicBelongTo(topic1, topic2);
    assert(a != null);
    assert(a.?.len == 2);
    assert(mem.eql(u8, a.?, "me"));
}
test "no match 1" {
    const topic1: []const u8 = "/home";
    const topic2: []const u8 = "/ho2";
    const a = try doesTopicBelongTo(topic1, topic2);
    assert(a == null);
}
test "no match 2" {
    const topic1: []const u8 = "/home";
    const topic2: []const u8 = "/home2";
    const a = try doesTopicBelongTo(topic1, topic2);
    assert(a == null);
}
