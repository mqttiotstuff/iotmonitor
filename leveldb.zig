// This library is a thick binding to leveldb C API

const std = @import("std");
const builtin = @import("builtin");
const trait = std.meta.trait;
const debug = std.debug;
const log = std.log;
const assert = debug.assert;
const Allocator = mem.Allocator;
const mem = std.mem;

const cleveldb = @cImport({
    @cInclude("leveldb/c.h");
});
const c = @cImport({
    @cInclude("stdio.h");
    @cInclude("unistd.h");
});

///////////////////////////////////////////////////////////////////////
// Serialization / Deserialisation

// this define the generic API for either Simple Type and composite Type for serialization
fn SerDeserAPI(comptime T: type, comptime INType: type, comptime OUTType: type) type {
    _ = T;
    return struct {
        const MarshallFn = fn (*const INType, *Allocator) []const u8;
        const UnMarshallFn = fn ([]const u8, *Allocator) *align(1) OUTType;
        marshall: MarshallFn,
        unMarshall: UnMarshallFn,
    };
}

pub fn ArrSerDeserType(comptime T: type) SerDeserAPI(T, []const T, []T) {
    const MI = struct {
        // default functions when the type is still serializable
        fn noMarshallFn(t: *const []const T, allocator: *Allocator) []const u8 {
            _ = allocator;
            return t.*;
        }

        // unmarshall must make a copy,
        // because leveldb has its own buffers
        fn noUnMarshallFn(e: []const u8, allocator: *Allocator) *align(1) []T {
            const ptrContainer = @ptrToInt(&e);
            const elements = @intToPtr(*align(1) []T, ptrContainer);
            const pNew = allocator.create([]T) catch unreachable;
            pNew.* = elements.*;
            return pNew;
        }
    };

    const S = SerDeserAPI(T, []const T, []T);
    return S{
        .marshall = MI.noMarshallFn,
        .unMarshall = MI.noUnMarshallFn,
    };
}
// need sed deser for storing on disk
pub fn SerDeserType(comptime T: type) SerDeserAPI(T, T, T) {
    comptime {
        if (@typeInfo(T) == .Pointer) {
            @panic("this ser deser type is only for simple types");
        }
    }

    const MI = struct {
        // default functions when the type is still serializable
        fn noMarshallFn(t: *const T, allocator: *Allocator) []const u8 {
            _ = allocator;
            return mem.asBytes(t);
        }

        // unmarshall must make a copy,
        // because leveldb has its own buffers
        fn noUnMarshallFn(e: []const u8, allocator: *Allocator) *align(1) T {
            _ = allocator;
            const eptr = @ptrToInt(&e[0]);
            return @intToPtr(*align(1) T, eptr);
        }
    };

    const S = SerDeserAPI(T, T, T);
    return S{
        .marshall = MI.noMarshallFn,
        .unMarshall = MI.noUnMarshallFn,
    };
}

test "use of noMarshallFn" {
    var allocator = std.heap.c_allocator;
    const i: u32 = 12;
    var r = SerDeserType(u32).marshall(&i, &allocator);
    const ur = SerDeserType(u32).unMarshall(r, &allocator);
    debug.assert(i == ur.*);
}

// create level db type for single element,
pub fn LevelDBHash(comptime K: type, comptime V: type) type {
    return LevelDBHashWithSerialization(K, K, K, V, V, V, SerDeserType(K), SerDeserType(V));
}

// create a leveldb type for arrays of element, for instance
// []u8 (strings)
pub fn LevelDBHashArray(comptime K: type, comptime V: type) type {
    return LevelDBHashWithSerialization(K, []const K, []K, V, []const V, []V, ArrSerDeserType(K), ArrSerDeserType(V));
}

// This function create a given type for using the leveldb, with serialization
// and deserialization
pub fn LevelDBHashWithSerialization(
    // K is the key type,
    comptime K: type,
    // KIN is the associated type used in "put" primitive (when the element is passed in)
    comptime KIN: type,
    // KOUT is the associated type for out, see get primitive
    comptime KOUT: type,
    // V is the value base type
    comptime V: type,
    comptime VIN: type,
    comptime VOUT: type,
    // marshallkey function serialize the k to be stored in the database
    comptime marshallKey: SerDeserAPI(K, KIN, KOUT),
    comptime marshallValue: SerDeserAPI(V, VIN, VOUT),
) type {
    return struct {
        leveldbHandle: *cleveldb.leveldb_t = undefined,
        writeOptions: *cleveldb.leveldb_writeoptions_t = undefined,
        readOptions: *cleveldb.leveldb_readoptions_t = undefined,
        allocator: *Allocator,

        const Self = @This();
        const KSerDeser = marshallKey;
        const VSerDeser = marshallValue;

        pub fn init(allocator: *Allocator) !*Self {
            const self = try allocator.create(Self);
            self.allocator = allocator;
            self.writeOptions = cleveldb.leveldb_writeoptions_create().?;
            self.readOptions = cleveldb.leveldb_readoptions_create().?;
            return self;
        }

        pub fn deinit(self: *Self) void {
            debug.print("deinit \n", .{});
            // close already free the leveldb handle
            // cleveldb.leveldb_free(self.leveldbHandle);
            cleveldb.leveldb_free(self.writeOptions);
            cleveldb.leveldb_free(self.readOptions);
        }

        pub fn open(self: *Self, filename: [*c]const u8) !void {
            const options = cleveldb.leveldb_options_create();
            defer cleveldb.leveldb_free(options);

            // defining a small LRU cache,
            // on level db, initialy initialized to 32Gb with 4096 bock size
            // because, the key replace, will keep the values until compaction
            // to full iteration can get all datas and put them into LRU cache

            const cache = cleveldb.leveldb_cache_create_lru(4096);
            const env = cleveldb.leveldb_create_default_env();
            cleveldb.leveldb_options_set_cache(options, cache);
            cleveldb.leveldb_options_set_create_if_missing(options, 1);
            cleveldb.leveldb_options_set_max_open_files(options, 10);
            cleveldb.leveldb_options_set_block_restart_interval(options, 4);
            cleveldb.leveldb_options_set_write_buffer_size(options, 1000);
            cleveldb.leveldb_options_set_env(options, env);
            cleveldb.leveldb_options_set_info_log(options, null);
            cleveldb.leveldb_options_set_block_size(options, 1024);

            var err: [*c]u8 = null;
            const result = cleveldb.leveldb_open(options, filename, &err);

            if (err != null) {
                _ = log.warn("{s}", .{"open failed"});
                defer cleveldb.leveldb_free(err);
                return error.OPEN_FAILED;
            }
            assert(result != null);
            self.leveldbHandle = result.?;
        }

        pub fn close(self: *Self) void {
            log.warn("close database \n", .{});
            cleveldb.leveldb_close(self.leveldbHandle);
            self.leveldbHandle = undefined;
        }

        pub fn put(self: *Self, key: KIN, value: VIN) !void {
            var err: [*c]u8 = null;
            // debug.print("k size {}\n", .{@sizeOf(K)});
            // debug.print("array size {}\n", .{value.len});

            // marshall value
            const marshalledKey = KSerDeser.marshall(&key, self.allocator);
            // defer self.allocator.free(marshalledKey);
            const marshalledValue = VSerDeser.marshall(&value, self.allocator);
            // defer self.allocator.free(marshalledValue);
            cleveldb.leveldb_put(self.leveldbHandle, self.writeOptions, marshalledKey.ptr, marshalledKey.len, marshalledValue.ptr, marshalledValue.len, &err);
            if (err != null) {
                log.warn("{s}", .{"open failed"});
                defer cleveldb.leveldb_free(err);
                return error.KEY_WRITE_FAILED;
            }
        }

        // retrieve the content of a key
        pub fn get(self: *Self, key: KIN) !?*align(1) VOUT {
            var read: ?[*]u8 = undefined;
            var read_len: usize = 0;
            var err: [*c]u8 = null;
            const marshalledKey = KSerDeser.marshall(&key, self.allocator);
            // defer self.allocator.free(marshalledKey);
            read = cleveldb.leveldb_get(self.leveldbHandle, self.readOptions, marshalledKey.ptr, marshalledKey.len, &read_len, &err);

            if (err != null) {
                _ = c.printf("open failed");
                defer cleveldb.leveldb_free(err);
                return null;
            }
            if (read == null) {
                debug.print("key not found \n", .{});
                return null;
            }
            const torelease = @ptrCast(*anyopaque, read);
            defer cleveldb.leveldb_free(torelease);
            // _ = c.printf("returned : %s %d\n", read, read_len);
            const structAddr = @ptrToInt(read);
            var cmsg = @intToPtr([*]u8, structAddr);
            const vTypePtr = VSerDeser.unMarshall(cmsg[0..read_len], self.allocator);
            //return &cmsg[0..read_len];
            return vTypePtr;
        }

        // iterator structure
        const Iterator = struct {
            const ItSelf = @This();
            db: *Self = undefined,
            innerIt: *cleveldb.leveldb_iterator_t = undefined,
            allocator: *Allocator = undefined,
            const ConstIter_t = *const cleveldb.leveldb_iterator_t;

            fn init(allocator: *Allocator, db: *Self) !*Iterator {
                const obj = try allocator.create(Iterator);
                obj.allocator = allocator;
                const result = cleveldb.leveldb_create_iterator(db.leveldbHandle, db.readOptions);
                if (result) |innerhandle| {
                    obj.innerIt = innerhandle;
                    return obj;
                }
                return error.CannotCreateIterator;
            }

            pub fn first(self: *ItSelf) void {
                cleveldb.leveldb_iter_seek_to_first(self.innerIt);
            }

            /// iterKey retrieve the value of the iterator
            /// the memory on the value has been allocated and needs to be freed if not used
            pub fn iterKey(self: *ItSelf) ?*align(1) KOUT {
                var read_len: usize = 0;
                const read: ?[*c]const u8 = cleveldb.leveldb_iter_key(self.innerIt, &read_len);

                if (read) |existValue| {
                    const structAddr = @ptrToInt(existValue);
                    var cmsg = @intToPtr([*]const u8, structAddr);
                    const spanRead = mem.bytesAsSlice(u8, cmsg[0..read_len]);
                    const vTypePtr = KSerDeser.unMarshall(spanRead, self.allocator);
                    return vTypePtr;
                }
                return null;
            }

            /// iterValue retrieve the value of the iterator
            /// the memory on the value has been allocated and needs to be freed if not used
            pub fn iterValue(self: *ItSelf) ?*align(1) VOUT {
                var read_len: usize = 0;
                const read: ?[*c]const u8 = cleveldb.leveldb_iter_value(self.innerIt, &read_len);

                if (read) |existValue| {
                    const structAddr = @ptrToInt(existValue);
                    var cmsg = @intToPtr([*]const u8, structAddr);
                    const spanRead = mem.bytesAsSlice(u8, cmsg[0..read_len]);
                    const vTypePtr = VSerDeser.unMarshall(spanRead, self.allocator);
                    return vTypePtr;
                }
                return null;
            }

            pub fn next(self: *ItSelf) void {
                cleveldb.leveldb_iter_next(self.innerIt);
            }

            pub fn isValid(self: *ItSelf) bool {
                const result = cleveldb.leveldb_iter_valid(self.innerIt);
                return result > 0;
            }

            pub fn deinit(self: *ItSelf) void {
                cleveldb.leveldb_iter_destroy(self.innerIt);
            }
        };

        pub fn iterator(self: *Self) !*Iterator {
            return Iterator.init(self.allocator, self);
        }
    };
}

test "test iterators" {
    // already created database
    var filename = "countingstorage\x00";

    var allocator = std.heap.c_allocator;

    const SS = LevelDBHash(u32, u32);
    var l = try SS.init(&allocator);
    defer l.deinit();
    debug.print("opening databse", .{});
    try l.open(filename);
    defer l.close();

    debug.print("create iterator", .{});
    const iterator = try l.iterator();
    defer iterator.deinit();

    debug.print("call first", .{});
    iterator.first();
    var r: ?*align(1) u32 = null;
    while (iterator.isValid()) {
        debug.print("iterKey", .{});
        r = iterator.iterKey();
        var v = iterator.iterValue();
        debug.print("key :{} value: {}\n", .{ r.?.*, v.?.* });
        allocator.destroy(v.?);
        iterator.next();
    }
    debug.print("now, close the iterator\n", .{});
}

test "test no specialization" {
    
    var allocator = std.heap.c_allocator;

    const SS = LevelDBHash(u32, u8);
    _ = try SS.init(&allocator);
    
    //var l = try SS.init(&allocator);
    // assert(l != null);
}

test "test storing ints" {
    var filename = "countingstorage\x00";
 
    var allocator = std.heap.c_allocator;

    const SS = LevelDBHash(u32, u32);
    var l = try SS.init(&allocator);
    defer l.deinit();

    _ = try l.open(filename);

    var i: u32 = 0;
    while (i < 1000) {
        try l.put(i, i + 10);
        i += 1;
    }
    l.close();
}

test "test storing letters" {
    var filename = "stringstoragetest\x00";

    var allocator = std.heap.c_allocator;

    const SS = LevelDBHashArray(u8, u8);
    var l = try SS.init(&allocator);
    defer l.deinit();

    _ = try l.open(filename);

    const MAX_ITERATIONS = 1_000_000;

    var i: u64 = 0;
    while (i < MAX_ITERATIONS) {
        var keyBuffer = [_]u8{ 65, 65, 65, 65, 65, 65 };
        var valueBuffer = [_]u8{ 65, 65, 65, 65, 65, 65 };
        _ = c.sprintf(&keyBuffer[0], "%d", i % 1000);
        _ = c.sprintf(&valueBuffer[0], "%d", (i + 1) % 1000);
        // debug.print(" {} -> {} , key length {}\n", .{ keyBuffer, valueBuffer, keyBuffer.len });
        try l.put(keyBuffer[0..], valueBuffer[0..]);
        const opt = try l.get(keyBuffer[0..]);
        allocator.destroy(opt.?);
        i += 1;
        // used for reduce pression in test
        if (i % 100_000 == 0) {
            _ = c.sleep(2);
        }
    }
    var s = "1\x00AAAA";
    const t = mem.span(s);
    debug.print("test key length : {}\n", .{t[0..].len});
    const lecturealea = try l.get(t[0..]);
    debug.assert(lecturealea != null);
    debug.print("retrieved : {}\n", .{lecturealea});
    if (lecturealea) |value| {
        allocator.destroy(value);
    }
    const it = try l.iterator();
    defer allocator.destroy(it);
    defer l.deinit();
    it.first();
    while (it.isValid()) {
        const optK = it.iterKey();
        const optV = it.iterValue();
        if (optK) |k| {
            defer allocator.destroy(k);
            debug.print("  {any}  value : {any}\n", .{ k.*, optV.?.* });
            // debug.print(" key for string \"{}\" \n", .{k.*});
            const ovbg = try l.get(k.*);
            if (ovbg) |rv| {
                debug.print("  {any}  value : {any}\n", .{ k.*, rv.* });
            }
        }
        if (optV) |v| {
            defer allocator.destroy(v);
            debug.print(" value for string \"{any}\" \n", .{v.*});
        }
        it.next();
    }
    it.deinit();

    l.close();
}

test "test marshalling" {
    debug.print("start marshall tests\n", .{});

    var allocator = std.heap.c_allocator;

    const StringMarshall = ArrSerDeserType(u8);
    const stringToMarshall = "hello\x00";
    debug.print("original string ptr \"{}\"\n", .{@ptrToInt(stringToMarshall)});

    const sspan = mem.span(stringToMarshall);
    debug.print("span type \"{}\"\n", .{@typeInfo(@TypeOf(sspan))});
    const marshalledC = StringMarshall.marshall(&sspan, &allocator);
    debug.print("marshalled \"{any}\", ptr {any} \n", .{ marshalledC, marshalledC.ptr });
    debug.print("pointer to first element {} \n", .{@ptrToInt(marshalledC.ptr)});

    debug.assert(&marshalledC[0] == &stringToMarshall[0]);
}

test "test reading" {
    var filename = "countingstorage\x00";

    var allocator = std.heap.c_allocator;
    
    const SS = LevelDBHash(u32, u32);
    var l = try SS.init(&allocator);
    defer l.deinit();

    _ = try l.open(filename);
    var i: u32 = 0;
    while (i < 1000) {
        const v = try l.get(i);
        debug.assert(v.?.* == i + 10);
        i += 1;
    }
    l.close();
}

// test "test serialization types" {
//     // var filename : [100]u8 = [_]u8{0} ** 100;
//     var filename = "hellosimpletypes2\x00";

//     var allocator = std.heap.c_allocator;

//     const u32SerializationType = SerDeserType(u32);
//     const u8ArrSerializationType = ArrSerDeserType(u8);
//     const SS = LevelDBHashWithSerialization(u32, u32, u32, u8, []const u8, []u8, u32SerializationType, u8ArrSerializationType);

//     var l = try SS.init(&allocator);

//     _ = try l.open(filename);
//     var h = @intCast(u32, 5);
//     var w = [_]u8{ 'w', 'o', 'r', 'l', 'd', 0x00 };
//     // debug.print("slice size : {}\n", .{w[0..].len});
//     _ = try l.put(h, w[0..]);

//     const t = try l.get(h);
//     debug.print("returned value {}\n", .{t.?.*});
//     if (t) |result| {
//         debug.print("result is :{}\n", .{result.*});
//         // debug.print("result type is :{}\n", .{@TypeOf(result.*)});
//     }

//     defer l.close();
// }

// RAW C API Tests

//test "creating file" {
//    const options = cleveldb.leveldb_options_create();
//    cleveldb.leveldb_options_set_create_if_missing(options, 1);
//    var err: [*c]u8 = null;
//    // const db = c.leveldb_open(options, "testdb", @intToPtr([*c][*c]u8,@ptrToInt(&err[0..])));
//    const db = cleveldb.leveldb_open(options, "testdb", &err);
//    if (err != null) {
//        _ = c.printf("open failed");
//        defer cleveldb.leveldb_free(err);
//        return;
//    }
//    var woptions = cleveldb.leveldb_writeoptions_create();
//    cleveldb.leveldb_put(db, woptions, "key", 3, "value", 6, &err);
//
//    const roptions = cleveldb.leveldb_readoptions_create();
//    var read: [*c]u8 = null;
//    var read_len: usize = 0;
//    read = cleveldb.leveldb_get(db, roptions, "key", 3, &read_len, &err);
//    if (err != null) {
//        _ = c.printf("open failed");
//        defer cleveldb.leveldb_free(err);
//        return;
//    }
//    _ = c.printf("returned : %s %d\n", read, read_len);
//    cleveldb.leveldb_close(db);
//}
