pub const va_list = __builtin_va_list;
pub const __gnuc_va_list = __builtin_va_list;
pub const __u_char = u8;
pub const __u_short = c_ushort;
pub const __u_int = c_uint;
pub const __u_long = c_ulong;
pub const __int8_t = i8;
pub const __uint8_t = u8;
pub const __int16_t = c_short;
pub const __uint16_t = c_ushort;
pub const __int32_t = c_int;
pub const __uint32_t = c_uint;
pub const __int64_t = c_long;
pub const __uint64_t = c_ulong;
pub const __int_least8_t = __int8_t;
pub const __uint_least8_t = __uint8_t;
pub const __int_least16_t = __int16_t;
pub const __uint_least16_t = __uint16_t;
pub const __int_least32_t = __int32_t;
pub const __uint_least32_t = __uint32_t;
pub const __int_least64_t = __int64_t;
pub const __uint_least64_t = __uint64_t;
pub const __quad_t = c_long;
pub const __u_quad_t = c_ulong;
pub const __intmax_t = c_long;
pub const __uintmax_t = c_ulong;
pub const __dev_t = c_ulong;
pub const __uid_t = c_uint;
pub const __gid_t = c_uint;
pub const __ino_t = c_ulong;
pub const __ino64_t = c_ulong;
pub const __mode_t = c_uint;
pub const __nlink_t = c_ulong;
pub const __off_t = c_long;
pub const __off64_t = c_long;
pub const __pid_t = c_int;
const struct_unnamed_1 = extern struct {
    __val: [2]c_int,
};
pub const __fsid_t = struct_unnamed_1;
pub const __clock_t = c_long;
pub const __rlim_t = c_ulong;
pub const __rlim64_t = c_ulong;
pub const __id_t = c_uint;
pub const __time_t = c_long;
pub const __useconds_t = c_uint;
pub const __suseconds_t = c_long;
pub const __daddr_t = c_int;
pub const __key_t = c_int;
pub const __clockid_t = c_int;
pub const __timer_t = ?*c_void;
pub const __blksize_t = c_long;
pub const __blkcnt_t = c_long;
pub const __blkcnt64_t = c_long;
pub const __fsblkcnt_t = c_ulong;
pub const __fsblkcnt64_t = c_ulong;
pub const __fsfilcnt_t = c_ulong;
pub const __fsfilcnt64_t = c_ulong;
pub const __fsword_t = c_long;
pub const __ssize_t = c_long;
pub const __syscall_slong_t = c_long;
pub const __syscall_ulong_t = c_ulong;
pub const __loff_t = __off64_t;
pub const __caddr_t = [*c]u8;
pub const __intptr_t = c_long;
pub const __socklen_t = c_uint;
pub const __sig_atomic_t = c_int;
const union_unnamed_3 = extern union {
    __wch: c_uint,
    __wchb: [4]u8,
};
const struct_unnamed_2 = extern struct {
    __count: c_int,
    __value: union_unnamed_3,
};
pub const __mbstate_t = struct_unnamed_2;
pub const struct__G_fpos_t = extern struct {
    __pos: __off_t,
    __state: __mbstate_t,
};
pub const __fpos_t = struct__G_fpos_t;
pub const struct__G_fpos64_t = extern struct {
    __pos: __off64_t,
    __state: __mbstate_t,
};
pub const __fpos64_t = struct__G_fpos64_t;
pub const struct__IO_marker = @OpaqueType();
pub const struct__IO_codecvt = @OpaqueType();
pub const struct__IO_wide_data = @OpaqueType();
pub const struct__IO_FILE = extern struct {
    _flags: c_int,
    _IO_read_ptr: [*c]u8,
    _IO_read_end: [*c]u8,
    _IO_read_base: [*c]u8,
    _IO_write_base: [*c]u8,
    _IO_write_ptr: [*c]u8,
    _IO_write_end: [*c]u8,
    _IO_buf_base: [*c]u8,
    _IO_buf_end: [*c]u8,
    _IO_save_base: [*c]u8,
    _IO_backup_base: [*c]u8,
    _IO_save_end: [*c]u8,
    _markers: ?*struct__IO_marker,
    _chain: [*c]struct__IO_FILE,
    _fileno: c_int,
    _flags2: c_int,
    _old_offset: __off_t,
    _cur_column: c_ushort,
    _vtable_offset: i8,
    _shortbuf: [1]u8,
    _lock: ?*_IO_lock_t,
    _offset: __off64_t,
    _codecvt: ?*struct__IO_codecvt,
    _wide_data: ?*struct__IO_wide_data,
    _freeres_list: [*c]struct__IO_FILE,
    _freeres_buf: ?*c_void,
    __pad5: usize,
    _mode: c_int,
    _unused2: [20]u8,
};
pub const __FILE = struct__IO_FILE;
pub const FILE = struct__IO_FILE;
pub const _IO_lock_t = c_void;
pub const off_t = __off_t;
pub const fpos_t = __fpos_t;
pub extern var stdin: [*c]FILE;
pub extern var stdout: [*c]FILE;
pub extern var stderr: [*c]FILE;
pub extern fn remove(__filename: [*c]const u8) c_int;
pub extern fn rename(__old: [*c]const u8, __new: [*c]const u8) c_int;
pub extern fn renameat(__oldfd: c_int, __old: [*c]const u8, __newfd: c_int, __new: [*c]const u8) c_int;
pub extern fn tmpfile() [*c]FILE;
pub extern fn tmpnam(__s: [*c]u8) [*c]u8;
pub extern fn tmpnam_r(__s: [*c]u8) [*c]u8;
pub extern fn tempnam(__dir: [*c]const u8, __pfx: [*c]const u8) [*c]u8;
pub extern fn fclose(__stream: [*c]FILE) c_int;
pub extern fn fflush(__stream: [*c]FILE) c_int;
pub extern fn fflush_unlocked(__stream: [*c]FILE) c_int;
pub extern fn fopen(__filename: [*c]const u8, __modes: [*c]const u8) [*c]FILE;
pub extern fn freopen(noalias __filename: [*c]const u8, noalias __modes: [*c]const u8, noalias __stream: [*c]FILE) [*c]FILE;
pub extern fn fdopen(__fd: c_int, __modes: [*c]const u8) [*c]FILE;
pub extern fn fmemopen(__s: ?*c_void, __len: usize, __modes: [*c]const u8) [*c]FILE;
pub extern fn open_memstream(__bufloc: [*c][*c]u8, __sizeloc: [*c]usize) [*c]FILE;
pub extern fn setbuf(noalias __stream: [*c]FILE, noalias __buf: [*c]u8) void;
pub extern fn setvbuf(noalias __stream: [*c]FILE, noalias __buf: [*c]u8, __modes: c_int, __n: usize) c_int;
pub extern fn setbuffer(noalias __stream: [*c]FILE, noalias __buf: [*c]u8, __size: usize) void;
pub extern fn setlinebuf(__stream: [*c]FILE) void;
pub extern fn fprintf(__stream: [*c]FILE, __format: [*c]const u8, ...) c_int;
pub extern fn printf(__format: [*c]const u8, ...) c_int;
pub extern fn sprintf(__s: [*c]u8, __format: [*c]const u8, ...) c_int;
pub const struct___va_list_tag = extern struct {
    gp_offset: c_uint,
    fp_offset: c_uint,
    overflow_arg_area: ?*c_void,
    reg_save_area: ?*c_void,
};
pub extern fn vfprintf(__s: [*c]FILE, __format: [*c]const u8, __arg: [*c]struct___va_list_tag) c_int;
pub extern fn vprintf(__format: [*c]const u8, __arg: [*c]struct___va_list_tag) c_int;
pub extern fn vsprintf(__s: [*c]u8, __format: [*c]const u8, __arg: [*c]struct___va_list_tag) c_int;
pub extern fn snprintf(__s: [*c]u8, __maxlen: c_ulong, __format: [*c]const u8, ...) c_int;
pub extern fn vsnprintf(__s: [*c]u8, __maxlen: c_ulong, __format: [*c]const u8, __arg: [*c]struct___va_list_tag) c_int;
pub extern fn vdprintf(__fd: c_int, noalias __fmt: [*c]const u8, __arg: [*c]struct___va_list_tag) c_int;
pub extern fn dprintf(__fd: c_int, noalias __fmt: [*c]const u8, ...) c_int;
pub extern fn fscanf(noalias __stream: [*c]FILE, noalias __format: [*c]const u8, ...) c_int;
pub extern fn scanf(noalias __format: [*c]const u8, ...) c_int;
pub extern fn sscanf(noalias __s: [*c]const u8, noalias __format: [*c]const u8, ...) c_int;
pub extern fn vfscanf(noalias __s: [*c]FILE, noalias __format: [*c]const u8, __arg: [*c]struct___va_list_tag) c_int;
pub extern fn vscanf(noalias __format: [*c]const u8, __arg: [*c]struct___va_list_tag) c_int;
pub extern fn vsscanf(noalias __s: [*c]const u8, noalias __format: [*c]const u8, __arg: [*c]struct___va_list_tag) c_int;
pub extern fn fgetc(__stream: [*c]FILE) c_int;
pub extern fn getc(__stream: [*c]FILE) c_int;
pub extern fn getchar() c_int;
pub extern fn getc_unlocked(__stream: [*c]FILE) c_int;
pub extern fn getchar_unlocked() c_int;
pub extern fn fgetc_unlocked(__stream: [*c]FILE) c_int;
pub extern fn fputc(__c: c_int, __stream: [*c]FILE) c_int;
pub extern fn putc(__c: c_int, __stream: [*c]FILE) c_int;
pub extern fn putchar(__c: c_int) c_int;
pub extern fn fputc_unlocked(__c: c_int, __stream: [*c]FILE) c_int;
pub extern fn putc_unlocked(__c: c_int, __stream: [*c]FILE) c_int;
pub extern fn putchar_unlocked(__c: c_int) c_int;
pub extern fn getw(__stream: [*c]FILE) c_int;
pub extern fn putw(__w: c_int, __stream: [*c]FILE) c_int;
pub extern fn fgets(noalias __s: [*c]u8, __n: c_int, noalias __stream: [*c]FILE) [*c]u8;
pub extern fn __getdelim(noalias __lineptr: [*c][*c]u8, noalias __n: [*c]usize, __delimiter: c_int, noalias __stream: [*c]FILE) __ssize_t;
pub extern fn getdelim(noalias __lineptr: [*c][*c]u8, noalias __n: [*c]usize, __delimiter: c_int, noalias __stream: [*c]FILE) __ssize_t;
pub extern fn getline(noalias __lineptr: [*c][*c]u8, noalias __n: [*c]usize, noalias __stream: [*c]FILE) __ssize_t;
pub extern fn fputs(noalias __s: [*c]const u8, noalias __stream: [*c]FILE) c_int;
pub extern fn puts(__s: [*c]const u8) c_int;
pub extern fn ungetc(__c: c_int, __stream: [*c]FILE) c_int;
pub extern fn fread(__ptr: ?*c_void, __size: c_ulong, __n: c_ulong, __stream: [*c]FILE) c_ulong;
pub extern fn fwrite(__ptr: ?*const c_void, __size: c_ulong, __n: c_ulong, __s: [*c]FILE) c_ulong;
pub extern fn fread_unlocked(noalias __ptr: ?*c_void, __size: usize, __n: usize, noalias __stream: [*c]FILE) usize;
pub extern fn fwrite_unlocked(noalias __ptr: ?*const c_void, __size: usize, __n: usize, noalias __stream: [*c]FILE) usize;
pub extern fn fseek(__stream: [*c]FILE, __off: c_long, __whence: c_int) c_int;
pub extern fn ftell(__stream: [*c]FILE) c_long;
pub extern fn rewind(__stream: [*c]FILE) void;
pub extern fn fseeko(__stream: [*c]FILE, __off: __off_t, __whence: c_int) c_int;
pub extern fn ftello(__stream: [*c]FILE) __off_t;
pub extern fn fgetpos(noalias __stream: [*c]FILE, noalias __pos: [*c]fpos_t) c_int;
pub extern fn fsetpos(__stream: [*c]FILE, __pos: [*c]const fpos_t) c_int;
pub extern fn clearerr(__stream: [*c]FILE) void;
pub extern fn feof(__stream: [*c]FILE) c_int;
pub extern fn ferror(__stream: [*c]FILE) c_int;
pub extern fn clearerr_unlocked(__stream: [*c]FILE) void;
pub extern fn feof_unlocked(__stream: [*c]FILE) c_int;
pub extern fn ferror_unlocked(__stream: [*c]FILE) c_int;
pub extern fn perror(__s: [*c]const u8) void;
pub extern var sys_nerr: c_int;
pub extern const sys_errlist: [*c]const [*c]const u8;
pub extern fn fileno(__stream: [*c]FILE) c_int;
pub extern fn fileno_unlocked(__stream: [*c]FILE) c_int;
pub extern fn popen(__command: [*c]const u8, __modes: [*c]const u8) [*c]FILE;
pub extern fn pclose(__stream: [*c]FILE) c_int;
pub extern fn ctermid(__s: [*c]u8) [*c]u8;
pub extern fn flockfile(__stream: [*c]FILE) void;
pub extern fn ftrylockfile(__stream: [*c]FILE) c_int;
pub extern fn funlockfile(__stream: [*c]FILE) void;
pub extern fn __uflow([*c]FILE) c_int;
pub extern fn __overflow([*c]FILE, c_int) c_int;
pub const MQTTPROPERTY_CODE_PAYLOAD_FORMAT_INDICATOR = @enumToInt(enum_MQTTPropertyCodes.MQTTPROPERTY_CODE_PAYLOAD_FORMAT_INDICATOR);
pub const MQTTPROPERTY_CODE_MESSAGE_EXPIRY_INTERVAL = @enumToInt(enum_MQTTPropertyCodes.MQTTPROPERTY_CODE_MESSAGE_EXPIRY_INTERVAL);
pub const MQTTPROPERTY_CODE_CONTENT_TYPE = @enumToInt(enum_MQTTPropertyCodes.MQTTPROPERTY_CODE_CONTENT_TYPE);
pub const MQTTPROPERTY_CODE_RESPONSE_TOPIC = @enumToInt(enum_MQTTPropertyCodes.MQTTPROPERTY_CODE_RESPONSE_TOPIC);
pub const MQTTPROPERTY_CODE_CORRELATION_DATA = @enumToInt(enum_MQTTPropertyCodes.MQTTPROPERTY_CODE_CORRELATION_DATA);
pub const MQTTPROPERTY_CODE_SUBSCRIPTION_IDENTIFIER = @enumToInt(enum_MQTTPropertyCodes.MQTTPROPERTY_CODE_SUBSCRIPTION_IDENTIFIER);
pub const MQTTPROPERTY_CODE_SESSION_EXPIRY_INTERVAL = @enumToInt(enum_MQTTPropertyCodes.MQTTPROPERTY_CODE_SESSION_EXPIRY_INTERVAL);
pub const MQTTPROPERTY_CODE_ASSIGNED_CLIENT_IDENTIFER = @enumToInt(enum_MQTTPropertyCodes.MQTTPROPERTY_CODE_ASSIGNED_CLIENT_IDENTIFER);
pub const MQTTPROPERTY_CODE_SERVER_KEEP_ALIVE = @enumToInt(enum_MQTTPropertyCodes.MQTTPROPERTY_CODE_SERVER_KEEP_ALIVE);
pub const MQTTPROPERTY_CODE_AUTHENTICATION_METHOD = @enumToInt(enum_MQTTPropertyCodes.MQTTPROPERTY_CODE_AUTHENTICATION_METHOD);
pub const MQTTPROPERTY_CODE_AUTHENTICATION_DATA = @enumToInt(enum_MQTTPropertyCodes.MQTTPROPERTY_CODE_AUTHENTICATION_DATA);
pub const MQTTPROPERTY_CODE_REQUEST_PROBLEM_INFORMATION = @enumToInt(enum_MQTTPropertyCodes.MQTTPROPERTY_CODE_REQUEST_PROBLEM_INFORMATION);
pub const MQTTPROPERTY_CODE_WILL_DELAY_INTERVAL = @enumToInt(enum_MQTTPropertyCodes.MQTTPROPERTY_CODE_WILL_DELAY_INTERVAL);
pub const MQTTPROPERTY_CODE_REQUEST_RESPONSE_INFORMATION = @enumToInt(enum_MQTTPropertyCodes.MQTTPROPERTY_CODE_REQUEST_RESPONSE_INFORMATION);
pub const MQTTPROPERTY_CODE_RESPONSE_INFORMATION = @enumToInt(enum_MQTTPropertyCodes.MQTTPROPERTY_CODE_RESPONSE_INFORMATION);
pub const MQTTPROPERTY_CODE_SERVER_REFERENCE = @enumToInt(enum_MQTTPropertyCodes.MQTTPROPERTY_CODE_SERVER_REFERENCE);
pub const MQTTPROPERTY_CODE_REASON_STRING = @enumToInt(enum_MQTTPropertyCodes.MQTTPROPERTY_CODE_REASON_STRING);
pub const MQTTPROPERTY_CODE_RECEIVE_MAXIMUM = @enumToInt(enum_MQTTPropertyCodes.MQTTPROPERTY_CODE_RECEIVE_MAXIMUM);
pub const MQTTPROPERTY_CODE_TOPIC_ALIAS_MAXIMUM = @enumToInt(enum_MQTTPropertyCodes.MQTTPROPERTY_CODE_TOPIC_ALIAS_MAXIMUM);
pub const MQTTPROPERTY_CODE_TOPIC_ALIAS = @enumToInt(enum_MQTTPropertyCodes.MQTTPROPERTY_CODE_TOPIC_ALIAS);
pub const MQTTPROPERTY_CODE_MAXIMUM_QOS = @enumToInt(enum_MQTTPropertyCodes.MQTTPROPERTY_CODE_MAXIMUM_QOS);
pub const MQTTPROPERTY_CODE_RETAIN_AVAILABLE = @enumToInt(enum_MQTTPropertyCodes.MQTTPROPERTY_CODE_RETAIN_AVAILABLE);
pub const MQTTPROPERTY_CODE_USER_PROPERTY = @enumToInt(enum_MQTTPropertyCodes.MQTTPROPERTY_CODE_USER_PROPERTY);
pub const MQTTPROPERTY_CODE_MAXIMUM_PACKET_SIZE = @enumToInt(enum_MQTTPropertyCodes.MQTTPROPERTY_CODE_MAXIMUM_PACKET_SIZE);
pub const MQTTPROPERTY_CODE_WILDCARD_SUBSCRIPTION_AVAILABLE = @enumToInt(enum_MQTTPropertyCodes.MQTTPROPERTY_CODE_WILDCARD_SUBSCRIPTION_AVAILABLE);
pub const MQTTPROPERTY_CODE_SUBSCRIPTION_IDENTIFIERS_AVAILABLE = @enumToInt(enum_MQTTPropertyCodes.MQTTPROPERTY_CODE_SUBSCRIPTION_IDENTIFIERS_AVAILABLE);
pub const MQTTPROPERTY_CODE_SHARED_SUBSCRIPTION_AVAILABLE = @enumToInt(enum_MQTTPropertyCodes.MQTTPROPERTY_CODE_SHARED_SUBSCRIPTION_AVAILABLE);
pub const enum_MQTTPropertyCodes = extern enum(c_int) {
    MQTTPROPERTY_CODE_PAYLOAD_FORMAT_INDICATOR = 1,
    MQTTPROPERTY_CODE_MESSAGE_EXPIRY_INTERVAL = 2,
    MQTTPROPERTY_CODE_CONTENT_TYPE = 3,
    MQTTPROPERTY_CODE_RESPONSE_TOPIC = 8,
    MQTTPROPERTY_CODE_CORRELATION_DATA = 9,
    MQTTPROPERTY_CODE_SUBSCRIPTION_IDENTIFIER = 11,
    MQTTPROPERTY_CODE_SESSION_EXPIRY_INTERVAL = 17,
    MQTTPROPERTY_CODE_ASSIGNED_CLIENT_IDENTIFER = 18,
    MQTTPROPERTY_CODE_SERVER_KEEP_ALIVE = 19,
    MQTTPROPERTY_CODE_AUTHENTICATION_METHOD = 21,
    MQTTPROPERTY_CODE_AUTHENTICATION_DATA = 22,
    MQTTPROPERTY_CODE_REQUEST_PROBLEM_INFORMATION = 23,
    MQTTPROPERTY_CODE_WILL_DELAY_INTERVAL = 24,
    MQTTPROPERTY_CODE_REQUEST_RESPONSE_INFORMATION = 25,
    MQTTPROPERTY_CODE_RESPONSE_INFORMATION = 26,
    MQTTPROPERTY_CODE_SERVER_REFERENCE = 28,
    MQTTPROPERTY_CODE_REASON_STRING = 31,
    MQTTPROPERTY_CODE_RECEIVE_MAXIMUM = 33,
    MQTTPROPERTY_CODE_TOPIC_ALIAS_MAXIMUM = 34,
    MQTTPROPERTY_CODE_TOPIC_ALIAS = 35,
    MQTTPROPERTY_CODE_MAXIMUM_QOS = 36,
    MQTTPROPERTY_CODE_RETAIN_AVAILABLE = 37,
    MQTTPROPERTY_CODE_USER_PROPERTY = 38,
    MQTTPROPERTY_CODE_MAXIMUM_PACKET_SIZE = 39,
    MQTTPROPERTY_CODE_WILDCARD_SUBSCRIPTION_AVAILABLE = 40,
    MQTTPROPERTY_CODE_SUBSCRIPTION_IDENTIFIERS_AVAILABLE = 41,
    MQTTPROPERTY_CODE_SHARED_SUBSCRIPTION_AVAILABLE = 42,
    _,
};
pub extern fn MQTTPropertyName(value: enum_MQTTPropertyCodes) [*c]const u8;
pub const MQTTPROPERTY_TYPE_BYTE = @enumToInt(enum_MQTTPropertyTypes.MQTTPROPERTY_TYPE_BYTE);
pub const MQTTPROPERTY_TYPE_TWO_BYTE_INTEGER = @enumToInt(enum_MQTTPropertyTypes.MQTTPROPERTY_TYPE_TWO_BYTE_INTEGER);
pub const MQTTPROPERTY_TYPE_FOUR_BYTE_INTEGER = @enumToInt(enum_MQTTPropertyTypes.MQTTPROPERTY_TYPE_FOUR_BYTE_INTEGER);
pub const MQTTPROPERTY_TYPE_VARIABLE_BYTE_INTEGER = @enumToInt(enum_MQTTPropertyTypes.MQTTPROPERTY_TYPE_VARIABLE_BYTE_INTEGER);
pub const MQTTPROPERTY_TYPE_BINARY_DATA = @enumToInt(enum_MQTTPropertyTypes.MQTTPROPERTY_TYPE_BINARY_DATA);
pub const MQTTPROPERTY_TYPE_UTF_8_ENCODED_STRING = @enumToInt(enum_MQTTPropertyTypes.MQTTPROPERTY_TYPE_UTF_8_ENCODED_STRING);
pub const MQTTPROPERTY_TYPE_UTF_8_STRING_PAIR = @enumToInt(enum_MQTTPropertyTypes.MQTTPROPERTY_TYPE_UTF_8_STRING_PAIR);
pub const enum_MQTTPropertyTypes = extern enum(c_int) {
    MQTTPROPERTY_TYPE_BYTE,
    MQTTPROPERTY_TYPE_TWO_BYTE_INTEGER,
    MQTTPROPERTY_TYPE_FOUR_BYTE_INTEGER,
    MQTTPROPERTY_TYPE_VARIABLE_BYTE_INTEGER,
    MQTTPROPERTY_TYPE_BINARY_DATA,
    MQTTPROPERTY_TYPE_UTF_8_ENCODED_STRING,
    MQTTPROPERTY_TYPE_UTF_8_STRING_PAIR,
    _,
};
pub extern fn MQTTProperty_getType(value: enum_MQTTPropertyCodes) c_int;
const struct_unnamed_4 = extern struct {
    len: c_int,
    data: [*c]u8,
};
pub const MQTTLenString = struct_unnamed_4;
const struct_unnamed_8 = extern struct {
    data: MQTTLenString,
    value: MQTTLenString,
};
const union_unnamed_6 = extern union {
    byte: u8,
    integer2: c_ushort,
    integer4: c_uint,
    unnamed_7: struct_unnamed_8,
};
const struct_unnamed_5 = extern struct {
    identifier: enum_MQTTPropertyCodes,
    value: union_unnamed_6,
};
pub const MQTTProperty = struct_unnamed_5;
pub const struct_MQTTProperties = extern struct {
    count: c_int,
    max_count: c_int,
    length: c_int,
    array: [*c]MQTTProperty,
};
pub const MQTTProperties = struct_MQTTProperties;
pub extern fn MQTTProperties_len(props: [*c]MQTTProperties) c_int;
pub extern fn MQTTProperties_add(props: [*c]MQTTProperties, prop: [*c]const MQTTProperty) c_int;
pub extern fn MQTTProperties_write(pptr: [*c][*c]u8, properties: [*c]const MQTTProperties) c_int;
pub extern fn MQTTProperties_read(properties: [*c]MQTTProperties, pptr: [*c][*c]u8, enddata: [*c]u8) c_int;
pub extern fn MQTTProperties_free(properties: [*c]MQTTProperties) void;
pub extern fn MQTTProperties_copy(props: [*c]const MQTTProperties) MQTTProperties;
pub extern fn MQTTProperties_hasProperty(props: [*c]MQTTProperties, propid: enum_MQTTPropertyCodes) c_int;
pub extern fn MQTTProperties_propertyCount(props: [*c]MQTTProperties, propid: enum_MQTTPropertyCodes) c_int;
pub extern fn MQTTProperties_getNumericValue(props: [*c]MQTTProperties, propid: enum_MQTTPropertyCodes) c_int;
pub extern fn MQTTProperties_getNumericValueAt(props: [*c]MQTTProperties, propid: enum_MQTTPropertyCodes, index: c_int) c_int;
pub extern fn MQTTProperties_getProperty(props: [*c]MQTTProperties, propid: enum_MQTTPropertyCodes) [*c]MQTTProperty;
pub extern fn MQTTProperties_getPropertyAt(props: [*c]MQTTProperties, propid: enum_MQTTPropertyCodes, index: c_int) [*c]MQTTProperty;
pub const MQTTREASONCODE_SUCCESS = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_SUCCESS);
pub const MQTTREASONCODE_NORMAL_DISCONNECTION = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_NORMAL_DISCONNECTION);
pub const MQTTREASONCODE_GRANTED_QOS_0 = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_GRANTED_QOS_0);
pub const MQTTREASONCODE_GRANTED_QOS_1 = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_GRANTED_QOS_1);
pub const MQTTREASONCODE_GRANTED_QOS_2 = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_GRANTED_QOS_2);
pub const MQTTREASONCODE_DISCONNECT_WITH_WILL_MESSAGE = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_DISCONNECT_WITH_WILL_MESSAGE);
pub const MQTTREASONCODE_NO_MATCHING_SUBSCRIBERS = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_NO_MATCHING_SUBSCRIBERS);
pub const MQTTREASONCODE_NO_SUBSCRIPTION_FOUND = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_NO_SUBSCRIPTION_FOUND);
pub const MQTTREASONCODE_CONTINUE_AUTHENTICATION = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_CONTINUE_AUTHENTICATION);
pub const MQTTREASONCODE_RE_AUTHENTICATE = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_RE_AUTHENTICATE);
pub const MQTTREASONCODE_UNSPECIFIED_ERROR = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_UNSPECIFIED_ERROR);
pub const MQTTREASONCODE_MALFORMED_PACKET = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_MALFORMED_PACKET);
pub const MQTTREASONCODE_PROTOCOL_ERROR = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_PROTOCOL_ERROR);
pub const MQTTREASONCODE_IMPLEMENTATION_SPECIFIC_ERROR = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_IMPLEMENTATION_SPECIFIC_ERROR);
pub const MQTTREASONCODE_UNSUPPORTED_PROTOCOL_VERSION = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_UNSUPPORTED_PROTOCOL_VERSION);
pub const MQTTREASONCODE_CLIENT_IDENTIFIER_NOT_VALID = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_CLIENT_IDENTIFIER_NOT_VALID);
pub const MQTTREASONCODE_BAD_USER_NAME_OR_PASSWORD = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_BAD_USER_NAME_OR_PASSWORD);
pub const MQTTREASONCODE_NOT_AUTHORIZED = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_NOT_AUTHORIZED);
pub const MQTTREASONCODE_SERVER_UNAVAILABLE = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_SERVER_UNAVAILABLE);
pub const MQTTREASONCODE_SERVER_BUSY = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_SERVER_BUSY);
pub const MQTTREASONCODE_BANNED = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_BANNED);
pub const MQTTREASONCODE_SERVER_SHUTTING_DOWN = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_SERVER_SHUTTING_DOWN);
pub const MQTTREASONCODE_BAD_AUTHENTICATION_METHOD = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_BAD_AUTHENTICATION_METHOD);
pub const MQTTREASONCODE_KEEP_ALIVE_TIMEOUT = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_KEEP_ALIVE_TIMEOUT);
pub const MQTTREASONCODE_SESSION_TAKEN_OVER = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_SESSION_TAKEN_OVER);
pub const MQTTREASONCODE_TOPIC_FILTER_INVALID = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_TOPIC_FILTER_INVALID);
pub const MQTTREASONCODE_TOPIC_NAME_INVALID = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_TOPIC_NAME_INVALID);
pub const MQTTREASONCODE_PACKET_IDENTIFIER_IN_USE = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_PACKET_IDENTIFIER_IN_USE);
pub const MQTTREASONCODE_PACKET_IDENTIFIER_NOT_FOUND = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_PACKET_IDENTIFIER_NOT_FOUND);
pub const MQTTREASONCODE_RECEIVE_MAXIMUM_EXCEEDED = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_RECEIVE_MAXIMUM_EXCEEDED);
pub const MQTTREASONCODE_TOPIC_ALIAS_INVALID = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_TOPIC_ALIAS_INVALID);
pub const MQTTREASONCODE_PACKET_TOO_LARGE = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_PACKET_TOO_LARGE);
pub const MQTTREASONCODE_MESSAGE_RATE_TOO_HIGH = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_MESSAGE_RATE_TOO_HIGH);
pub const MQTTREASONCODE_QUOTA_EXCEEDED = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_QUOTA_EXCEEDED);
pub const MQTTREASONCODE_ADMINISTRATIVE_ACTION = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_ADMINISTRATIVE_ACTION);
pub const MQTTREASONCODE_PAYLOAD_FORMAT_INVALID = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_PAYLOAD_FORMAT_INVALID);
pub const MQTTREASONCODE_RETAIN_NOT_SUPPORTED = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_RETAIN_NOT_SUPPORTED);
pub const MQTTREASONCODE_QOS_NOT_SUPPORTED = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_QOS_NOT_SUPPORTED);
pub const MQTTREASONCODE_USE_ANOTHER_SERVER = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_USE_ANOTHER_SERVER);
pub const MQTTREASONCODE_SERVER_MOVED = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_SERVER_MOVED);
pub const MQTTREASONCODE_SHARED_SUBSCRIPTIONS_NOT_SUPPORTED = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_SHARED_SUBSCRIPTIONS_NOT_SUPPORTED);
pub const MQTTREASONCODE_CONNECTION_RATE_EXCEEDED = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_CONNECTION_RATE_EXCEEDED);
pub const MQTTREASONCODE_MAXIMUM_CONNECT_TIME = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_MAXIMUM_CONNECT_TIME);
pub const MQTTREASONCODE_SUBSCRIPTION_IDENTIFIERS_NOT_SUPPORTED = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_SUBSCRIPTION_IDENTIFIERS_NOT_SUPPORTED);
pub const MQTTREASONCODE_WILDCARD_SUBSCRIPTIONS_NOT_SUPPORTED = @enumToInt(enum_MQTTReasonCodes.MQTTREASONCODE_WILDCARD_SUBSCRIPTIONS_NOT_SUPPORTED);
pub const enum_MQTTReasonCodes = extern enum(c_int) {
    MQTTREASONCODE_SUCCESS = 0,
    MQTTREASONCODE_NORMAL_DISCONNECTION = 0,
    MQTTREASONCODE_GRANTED_QOS_0 = 0,
    MQTTREASONCODE_GRANTED_QOS_1 = 1,
    MQTTREASONCODE_GRANTED_QOS_2 = 2,
    MQTTREASONCODE_DISCONNECT_WITH_WILL_MESSAGE = 4,
    MQTTREASONCODE_NO_MATCHING_SUBSCRIBERS = 16,
    MQTTREASONCODE_NO_SUBSCRIPTION_FOUND = 17,
    MQTTREASONCODE_CONTINUE_AUTHENTICATION = 24,
    MQTTREASONCODE_RE_AUTHENTICATE = 25,
    MQTTREASONCODE_UNSPECIFIED_ERROR = 128,
    MQTTREASONCODE_MALFORMED_PACKET = 129,
    MQTTREASONCODE_PROTOCOL_ERROR = 130,
    MQTTREASONCODE_IMPLEMENTATION_SPECIFIC_ERROR = 131,
    MQTTREASONCODE_UNSUPPORTED_PROTOCOL_VERSION = 132,
    MQTTREASONCODE_CLIENT_IDENTIFIER_NOT_VALID = 133,
    MQTTREASONCODE_BAD_USER_NAME_OR_PASSWORD = 134,
    MQTTREASONCODE_NOT_AUTHORIZED = 135,
    MQTTREASONCODE_SERVER_UNAVAILABLE = 136,
    MQTTREASONCODE_SERVER_BUSY = 137,
    MQTTREASONCODE_BANNED = 138,
    MQTTREASONCODE_SERVER_SHUTTING_DOWN = 139,
    MQTTREASONCODE_BAD_AUTHENTICATION_METHOD = 140,
    MQTTREASONCODE_KEEP_ALIVE_TIMEOUT = 141,
    MQTTREASONCODE_SESSION_TAKEN_OVER = 142,
    MQTTREASONCODE_TOPIC_FILTER_INVALID = 143,
    MQTTREASONCODE_TOPIC_NAME_INVALID = 144,
    MQTTREASONCODE_PACKET_IDENTIFIER_IN_USE = 145,
    MQTTREASONCODE_PACKET_IDENTIFIER_NOT_FOUND = 146,
    MQTTREASONCODE_RECEIVE_MAXIMUM_EXCEEDED = 147,
    MQTTREASONCODE_TOPIC_ALIAS_INVALID = 148,
    MQTTREASONCODE_PACKET_TOO_LARGE = 149,
    MQTTREASONCODE_MESSAGE_RATE_TOO_HIGH = 150,
    MQTTREASONCODE_QUOTA_EXCEEDED = 151,
    MQTTREASONCODE_ADMINISTRATIVE_ACTION = 152,
    MQTTREASONCODE_PAYLOAD_FORMAT_INVALID = 153,
    MQTTREASONCODE_RETAIN_NOT_SUPPORTED = 154,
    MQTTREASONCODE_QOS_NOT_SUPPORTED = 155,
    MQTTREASONCODE_USE_ANOTHER_SERVER = 156,
    MQTTREASONCODE_SERVER_MOVED = 157,
    MQTTREASONCODE_SHARED_SUBSCRIPTIONS_NOT_SUPPORTED = 158,
    MQTTREASONCODE_CONNECTION_RATE_EXCEEDED = 159,
    MQTTREASONCODE_MAXIMUM_CONNECT_TIME = 160,
    MQTTREASONCODE_SUBSCRIPTION_IDENTIFIERS_NOT_SUPPORTED = 161,
    MQTTREASONCODE_WILDCARD_SUBSCRIPTIONS_NOT_SUPPORTED = 162,
    _,
};
pub extern fn MQTTReasonCode_toString(value: enum_MQTTReasonCodes) [*c]const u8;
pub const struct_MQTTSubscribe_options = extern struct {
    struct_id: [4]u8,
    struct_version: c_int,
    noLocal: u8,
    retainAsPublished: u8,
    retainHandling: u8,
};
pub const MQTTSubscribe_options = struct_MQTTSubscribe_options;
pub const Persistence_open = ?fn ([*c]?*c_void, [*c]const u8, [*c]const u8, ?*c_void) callconv(.C) c_int;
pub const Persistence_close = ?fn (?*c_void) callconv(.C) c_int;
pub const Persistence_put = ?fn (?*c_void, [*c]u8, c_int, [*c][*c]u8, [*c]c_int) callconv(.C) c_int;
pub const Persistence_get = ?fn (?*c_void, [*c]u8, [*c][*c]u8, [*c]c_int) callconv(.C) c_int;
pub const Persistence_remove = ?fn (?*c_void, [*c]u8) callconv(.C) c_int;
pub const Persistence_keys = ?fn (?*c_void, [*c][*c][*c]u8, [*c]c_int) callconv(.C) c_int;
pub const Persistence_clear = ?fn (?*c_void) callconv(.C) c_int;
pub const Persistence_containskey = ?fn (?*c_void, [*c]u8) callconv(.C) c_int;
const struct_unnamed_9 = extern struct {
    context: ?*c_void,
    popen: Persistence_open,
    pclose: Persistence_close,
    pput: Persistence_put,
    pget: Persistence_get,
    premove: Persistence_remove,
    pkeys: Persistence_keys,
    pclear: Persistence_clear,
    pcontainskey: Persistence_containskey,
};
pub const MQTTClient_persistence = struct_unnamed_9;
const struct_unnamed_10 = extern struct {
    struct_id: [4]u8,
    struct_version: c_int,
    do_openssl_init: c_int,
};
pub const MQTTClient_init_options = struct_unnamed_10;
pub extern fn MQTTClient_global_init(inits: [*c]MQTTClient_init_options) void;
pub const MQTTClient = ?*c_void;
pub const MQTTClient_deliveryToken = c_int;
pub const MQTTClient_token = c_int;
const struct_unnamed_11 = extern struct {
    struct_id: [4]u8,
    struct_version: c_int,
    payloadlen: c_int,
    payload: ?*c_void,
    qos: c_int,
    retained: c_int,
    dup: c_int,
    msgid: c_int,
    properties: MQTTProperties,
};
pub const MQTTClient_message = struct_unnamed_11;
pub const MQTTClient_messageArrived = fn (?*c_void, [*c]u8, c_int, [*c]MQTTClient_message) callconv(.C) c_int;
pub const MQTTClient_deliveryComplete = fn (?*c_void, MQTTClient_deliveryToken) callconv(.C) void;
pub const MQTTClient_connectionLost = fn (?*c_void, [*c]u8) callconv(.C) void;
pub extern fn MQTTClient_setCallbacks(handle: MQTTClient, context: ?*c_void, cl: ?MQTTClient_connectionLost, ma: ?MQTTClient_messageArrived, dc: ?MQTTClient_deliveryComplete) c_int;
pub const MQTTClient_disconnected = fn (?*c_void, [*c]MQTTProperties, enum_MQTTReasonCodes) callconv(.C) void;
pub extern fn MQTTClient_setDisconnected(handle: MQTTClient, context: ?*c_void, co: ?MQTTClient_disconnected) c_int;
pub const MQTTClient_published = fn (?*c_void, c_int, c_int, [*c]MQTTProperties, enum_MQTTReasonCodes) callconv(.C) void;
pub extern fn MQTTClient_setPublished(handle: MQTTClient, context: ?*c_void, co: ?MQTTClient_published) c_int;
pub extern fn MQTTClient_create(handle: [*c]MQTTClient, serverURI: [*c]const u8, clientId: [*c]const u8, persistence_type: c_int, persistence_context: ?*c_void) c_int;
const struct_unnamed_12 = extern struct {
    struct_id: [4]u8,
    struct_version: c_int,
    MQTTVersion: c_int,
};
pub const MQTTClient_createOptions = struct_unnamed_12;
pub extern fn MQTTClient_createWithOptions(handle: [*c]MQTTClient, serverURI: [*c]const u8, clientId: [*c]const u8, persistence_type: c_int, persistence_context: ?*c_void, options: [*c]MQTTClient_createOptions) c_int;
const struct_unnamed_14 = extern struct {
    len: c_int,
    data: ?*const c_void,
};
const struct_unnamed_13 = extern struct {
    struct_id: [4]u8,
    struct_version: c_int,
    topicName: [*c]const u8,
    message: [*c]const u8,
    retained: c_int,
    qos: c_int,
    payload: struct_unnamed_14,
};
pub const MQTTClient_willOptions = struct_unnamed_13;
const struct_unnamed_15 = extern struct {
    struct_id: [4]u8,
    struct_version: c_int,
    trustStore: [*c]const u8,
    keyStore: [*c]const u8,
    privateKey: [*c]const u8,
    privateKeyPassword: [*c]const u8,
    enabledCipherSuites: [*c]const u8,
    enableServerCertAuth: c_int,
    sslVersion: c_int,
    verify: c_int,
    CApath: [*c]const u8,
    ssl_error_cb: ?fn ([*c]const u8, usize, ?*c_void) callconv(.C) c_int,
    ssl_error_context: ?*c_void,
    ssl_psk_cb: ?fn ([*c]const u8, [*c]u8, c_uint, [*c]u8, c_uint, ?*c_void) callconv(.C) c_uint,
    ssl_psk_context: ?*c_void,
    disableDefaultTrustStore: c_int,
};
pub const MQTTClient_SSLOptions = struct_unnamed_15;
const struct_unnamed_17 = extern struct {
    serverURI: [*c]const u8,
    MQTTVersion: c_int,
    sessionPresent: c_int,
};
const struct_unnamed_18 = extern struct {
    len: c_int,
    data: ?*const c_void,
};
const struct_unnamed_16 = extern struct {
    struct_id: [4]u8,
    struct_version: c_int,
    keepAliveInterval: c_int,
    cleansession: c_int,
    reliable: c_int,
    will: [*c]MQTTClient_willOptions,
    username: [*c]const u8,
    password: [*c]const u8,
    connectTimeout: c_int,
    retryInterval: c_int,
    ssl: [*c]MQTTClient_SSLOptions,
    serverURIcount: c_int,
    serverURIs: [*c]const [*c]u8,
    MQTTVersion: c_int,
    returned: struct_unnamed_17,
    binarypwd: struct_unnamed_18,
    maxInflightMessages: c_int,
    cleanstart: c_int,
};
pub const MQTTClient_connectOptions = struct_unnamed_16;
const struct_unnamed_19 = extern struct {
    name: [*c]const u8,
    value: [*c]const u8,
};
pub const MQTTClient_nameValue = struct_unnamed_19;
pub extern fn MQTTClient_getVersionInfo() [*c]MQTTClient_nameValue;
pub extern fn MQTTClient_connect(handle: MQTTClient, options: [*c]MQTTClient_connectOptions) c_int;
pub const struct_MQTTResponse = extern struct {
    version: c_int,
    reasonCode: enum_MQTTReasonCodes,
    reasonCodeCount: c_int,
    reasonCodes: [*c]enum_MQTTReasonCodes,
    properties: [*c]MQTTProperties,
};
pub const MQTTResponse = struct_MQTTResponse;
pub extern fn MQTTResponse_free(response: MQTTResponse) void;
pub extern fn MQTTClient_connect5(handle: MQTTClient, options: [*c]MQTTClient_connectOptions, connectProperties: [*c]MQTTProperties, willProperties: [*c]MQTTProperties) MQTTResponse;
pub extern fn MQTTClient_disconnect(handle: MQTTClient, timeout: c_int) c_int;
pub extern fn MQTTClient_disconnect5(handle: MQTTClient, timeout: c_int, reason: enum_MQTTReasonCodes, props: [*c]MQTTProperties) c_int;
pub extern fn MQTTClient_isConnected(handle: MQTTClient) c_int;
pub extern fn MQTTClient_subscribe(handle: MQTTClient, topic: [*c]const u8, qos: c_int) c_int;
pub extern fn MQTTClient_subscribe5(handle: MQTTClient, topic: [*c]const u8, qos: c_int, opts: [*c]MQTTSubscribe_options, props: [*c]MQTTProperties) MQTTResponse;
pub extern fn MQTTClient_subscribeMany(handle: MQTTClient, count: c_int, topic: [*c]const [*c]u8, qos: [*c]c_int) c_int;
pub extern fn MQTTClient_subscribeMany5(handle: MQTTClient, count: c_int, topic: [*c]const [*c]u8, qos: [*c]c_int, opts: [*c]MQTTSubscribe_options, props: [*c]MQTTProperties) MQTTResponse;
pub extern fn MQTTClient_unsubscribe(handle: MQTTClient, topic: [*c]const u8) c_int;
pub extern fn MQTTClient_unsubscribe5(handle: MQTTClient, topic: [*c]const u8, props: [*c]MQTTProperties) MQTTResponse;
pub extern fn MQTTClient_unsubscribeMany(handle: MQTTClient, count: c_int, topic: [*c]const [*c]u8) c_int;
pub extern fn MQTTClient_unsubscribeMany5(handle: MQTTClient, count: c_int, topic: [*c]const [*c]u8, props: [*c]MQTTProperties) MQTTResponse;
pub extern fn MQTTClient_publish(handle: MQTTClient, topicName: [*c]const u8, payloadlen: c_int, payload: ?*const c_void, qos: c_int, retained: c_int, dt: [*c]MQTTClient_deliveryToken) c_int;
pub extern fn MQTTClient_publish5(handle: MQTTClient, topicName: [*c]const u8, payloadlen: c_int, payload: ?*const c_void, qos: c_int, retained: c_int, properties: [*c]MQTTProperties, dt: [*c]MQTTClient_deliveryToken) MQTTResponse;
pub extern fn MQTTClient_publishMessage(handle: MQTTClient, topicName: [*c]const u8, msg: [*c]MQTTClient_message, dt: [*c]MQTTClient_deliveryToken) c_int;
pub extern fn MQTTClient_publishMessage5(handle: MQTTClient, topicName: [*c]const u8, msg: [*c]MQTTClient_message, dt: [*c]MQTTClient_deliveryToken) MQTTResponse;
pub extern fn MQTTClient_waitForCompletion(handle: MQTTClient, dt: MQTTClient_deliveryToken, timeout: c_ulong) c_int;
pub extern fn MQTTClient_getPendingDeliveryTokens(handle: MQTTClient, tokens: [*c][*c]MQTTClient_deliveryToken) c_int;
pub extern fn MQTTClient_yield() void;
pub extern fn MQTTClient_receive(handle: MQTTClient, topicName: [*c][*c]u8, topicLen: [*c]c_int, message: [*c][*c]MQTTClient_message, timeout: c_ulong) c_int;
pub extern fn MQTTClient_freeMessage(msg: [*c][*c]MQTTClient_message) void;
pub extern fn MQTTClient_free(ptr: ?*c_void) void;
pub extern fn MQTTClient_destroy(handle: [*c]MQTTClient) void;
pub const MQTTCLIENT_TRACE_MAXIMUM = @enumToInt(enum_MQTTCLIENT_TRACE_LEVELS.MQTTCLIENT_TRACE_MAXIMUM);
pub const MQTTCLIENT_TRACE_MEDIUM = @enumToInt(enum_MQTTCLIENT_TRACE_LEVELS.MQTTCLIENT_TRACE_MEDIUM);
pub const MQTTCLIENT_TRACE_MINIMUM = @enumToInt(enum_MQTTCLIENT_TRACE_LEVELS.MQTTCLIENT_TRACE_MINIMUM);
pub const MQTTCLIENT_TRACE_PROTOCOL = @enumToInt(enum_MQTTCLIENT_TRACE_LEVELS.MQTTCLIENT_TRACE_PROTOCOL);
pub const MQTTCLIENT_TRACE_ERROR = @enumToInt(enum_MQTTCLIENT_TRACE_LEVELS.MQTTCLIENT_TRACE_ERROR);
pub const MQTTCLIENT_TRACE_SEVERE = @enumToInt(enum_MQTTCLIENT_TRACE_LEVELS.MQTTCLIENT_TRACE_SEVERE);
pub const MQTTCLIENT_TRACE_FATAL = @enumToInt(enum_MQTTCLIENT_TRACE_LEVELS.MQTTCLIENT_TRACE_FATAL);
pub const enum_MQTTCLIENT_TRACE_LEVELS = extern enum(c_int) {
    MQTTCLIENT_TRACE_MAXIMUM = 1,
    MQTTCLIENT_TRACE_MEDIUM = 2,
    MQTTCLIENT_TRACE_MINIMUM = 3,
    MQTTCLIENT_TRACE_PROTOCOL = 4,
    MQTTCLIENT_TRACE_ERROR = 5,
    MQTTCLIENT_TRACE_SEVERE = 6,
    MQTTCLIENT_TRACE_FATAL = 7,
    _,
};
pub extern fn MQTTClient_setTraceLevel(level: enum_MQTTCLIENT_TRACE_LEVELS) void;
pub const MQTTClient_traceCallback = fn (enum_MQTTCLIENT_TRACE_LEVELS, [*c]u8) callconv(.C) void;
pub extern fn MQTTClient_setTraceCallback(callback: ?MQTTClient_traceCallback) void;
pub extern fn MQTTClient_strerror(code: c_int) [*c]const u8;
pub const __INTMAX_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __UINTMAX_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_unsigned = void }");
pub const __PTRDIFF_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __INTPTR_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __SIZE_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_unsigned = void }");
pub const __WINT_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __CHAR16_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_short = void }");
pub const __CHAR32_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __UINTPTR_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_unsigned = void }");
pub const __INT8_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_signed = void }");
pub const __INT64_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __UINT8_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_char = void }");
pub const __UINT16_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_short = void }");
pub const __UINT32_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __UINT64_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_unsigned = void }");
pub const __INT_LEAST8_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_signed = void }");
pub const __UINT_LEAST8_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_char = void }");
pub const __UINT_LEAST16_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_short = void }");
pub const __UINT_LEAST32_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __INT_LEAST64_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __UINT_LEAST64_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_unsigned = void }");
pub const __INT_FAST8_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_signed = void }");
pub const __UINT_FAST8_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_char = void }");
pub const __UINT_FAST16_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_short = void }");
pub const __UINT_FAST32_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __INT_FAST64_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __UINT_FAST64_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_unsigned = void }");
pub const DLLImport = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_extern = void }");
pub const __GLIBC_USE = @compileError("unable to translate C expr: unexpected token Id{ .HashHash = void }");
pub const __THROW = @compileError("unable to translate C expr: expected ')'' here");
pub const __NTH = @compileError("unable to translate C expr: expected ')'' here");
pub const __NTHNL = @compileError("unable to translate C expr: unexpected token Id{ .Identifier = void }");
pub const __CONCAT = @compileError("unable to translate C expr: unexpected token Id{ .HashHash = void }");
pub const __STRING = @compileError("unable to translate C expr: unexpected token Id{ .Hash = void }");
pub const __ptr_t = @compileError("unable to translate C expr: unexpected token Id{ .Nl = void }");
pub const __warndecl = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_extern = void }");
pub const __warnattr = @compileError("unable to translate C expr: unexpected token Id{ .Nl = void }");
pub const __errordecl = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_extern = void }");
pub const __flexarr = @compileError("unable to translate C expr: unexpected token Id{ .LBracket = void }");
pub const __REDIRECT = @compileError("unable to translate C expr: unexpected token Id{ .Identifier = void }");
pub const __REDIRECT_NTH = @compileError("unable to translate C expr: unexpected token Id{ .Identifier = void }");
pub const __REDIRECT_NTHNL = @compileError("unable to translate C expr: unexpected token Id{ .Identifier = void }");
pub const __ASMNAME2 = @compileError("unable to translate C expr: unexpected token Id{ .Identifier = void }");
pub const __attribute_alloc_size__ = @compileError("unable to translate C expr: unexpected token Id{ .Nl = void }");
pub const __nonnull = @compileError("unable to translate C expr: expected ')'' here");
pub const __always_inline = @compileError("unable to translate C expr: unexpected token Id{ .Identifier = void }");
pub const __extern_inline = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_extern = void }");
pub const __extern_always_inline = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_extern = void }");
pub const __fortify_function = @compileError("unable to translate C expr: unexpected token Id{ .Identifier = void }");
pub const __attribute_copy__ = @compileError("unable to translate C expr: unexpected token Id{ .Nl = void }");
pub const __LDBL_REDIR1 = @compileError("unable to translate C expr: unexpected token Id{ .Identifier = void }");
pub const __LDBL_REDIR = @compileError("unable to translate C expr: unexpected token Id{ .Identifier = void }");
pub const __LDBL_REDIR1_NTH = @compileError("unable to translate C expr: unexpected token Id{ .Identifier = void }");
pub const __LDBL_REDIR_NTH = @compileError("unable to translate C expr: unexpected token Id{ .Identifier = void }");
pub const __LDBL_REDIR_DECL = @compileError("unable to translate C expr: unexpected token Id{ .Nl = void }");
pub const __glibc_macro_warning1 = @compileError("unable to translate C expr: unexpected token Id{ .Hash = void }");
pub const __glibc_macro_warning = @compileError("unable to translate C expr: expected ',' or ')'");
pub const NULL = @compileError("unable to translate C expr: expected ')'' here");
pub const __S16_TYPE = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __U16_TYPE = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_short = void }");
pub const __U32_TYPE = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __SLONGWORD_TYPE = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __ULONGWORD_TYPE = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_long = void }");
pub const __SQUAD_TYPE = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __UQUAD_TYPE = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_long = void }");
pub const __SWORD_TYPE = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __UWORD_TYPE = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_long = void }");
pub const __ULONG32_TYPE = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __S64_TYPE = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __U64_TYPE = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_long = void }");
pub const __STD_TYPE = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_typedef = void }");
pub const __TIMER_T_TYPE = @compileError("unable to translate C expr: unexpected token Id{ .Nl = void }");
pub const __FSID_T_TYPE = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_struct = void }");
pub const __getc_unlocked_body = @compileError("unable to translate C expr: expected ':'");
pub const __putc_unlocked_body = @compileError("unable to translate C expr: expected ':'");
pub const __feof_unlocked_body = @compileError("unable to translate C expr: expected ')'' here");
pub const __ferror_unlocked_body = @compileError("unable to translate C expr: expected ')'' here");
pub const MQTTProperties_initializer = @compileError("unable to translate C expr: unexpected token Id{ .LBrace = void }");
pub const MQTTSubscribe_options_initializer = @compileError("unable to translate C expr: unexpected token Id{ .LBrace = void }");
pub const MQTTClient_init_options_initializer = @compileError("unable to translate C expr: unexpected token Id{ .LBrace = void }");
pub const MQTTClient_message_initializer = @compileError("unable to translate C expr: unexpected token Id{ .LBrace = void }");
pub const MQTTClient_createOptions_initializer = @compileError("unable to translate C expr: unexpected token Id{ .LBrace = void }");
pub const MQTTClient_willOptions_initializer = @compileError("unable to translate C expr: unexpected token Id{ .LBrace = void }");
pub const MQTTClient_SSLOptions_initializer = @compileError("unable to translate C expr: unexpected token Id{ .LBrace = void }");
pub const MQTTClient_connectOptions_initializer = @compileError("unable to translate C expr: unexpected token Id{ .LBrace = void }");
pub const MQTTClient_connectOptions_initializer5 = @compileError("unable to translate C expr: unexpected token Id{ .LBrace = void }");
pub const MQTTResponse_initializer = @compileError("unable to translate C expr: unexpected token Id{ .LBrace = void }");
pub const __UINT64_MAX__ = @as(c_ulong, 18446744073709551615);
pub const __WORDSIZE_TIME64_COMPAT32 = 1;
pub const MQTTCLIENT_BAD_MQTT_VERSION = -11;
pub const __FINITE_MATH_ONLY__ = 0;
pub const __SYSCALL_WORDSIZE = 64;
pub const __SIZEOF_FLOAT__ = 4;
pub const __SEG_GS = 1;
pub const __UINT_LEAST64_FMTX__ = "lX";
pub const __INT_FAST8_MAX__ = 127;
pub const __OBJC_BOOL_IS_BOOL = 0;
pub const __CLOCKID_T_TYPE = __S32_TYPE;
pub const __INT_LEAST8_FMTi__ = "hhi";
pub const __USE_POSIX2 = 1;
pub const __UINT64_FMTX__ = "lX";
pub inline fn va_start(ap: var, param: var) @TypeOf(__builtin_va_start(ap, param)) {
    return __builtin_va_start(ap, param);
}
pub const __SIG_ATOMIC_MAX__ = 2147483647;
pub const __SSE__ = 1;
pub const __BYTE_ORDER__ = __ORDER_LITTLE_ENDIAN__;
pub const __NO_MATH_INLINES = 1;
pub const __SIZEOF_FLOAT128__ = 16;
pub inline fn __GNUC_PREREQ(maj: var, min: var) @TypeOf(__GNUC__ << 16 + __GNUC_MINOR__ >= maj << 16 + min) {
    return __GNUC__ << 16 + __GNUC_MINOR__ >= maj << 16 + min;
}
pub const __INT_FAST32_FMTd__ = "d";
pub const _POSIX_C_SOURCE = @as(c_long, 200809);
pub const __STDC_UTF_16__ = 1;
pub const __UINT_FAST16_MAX__ = 65535;
pub const __ATOMIC_ACQUIRE = 2;
pub const _FEATURES_H = 1;
pub const __LDBL_HAS_DENORM__ = 1;
pub const __INTMAX_FMTi__ = "li";
pub const __FLT_EPSILON__ = @as(f32, 1.19209290e-7);
pub const __UINT_FAST32_FMTo__ = "o";
pub const __UINT32_MAX__ = @as(c_uint, 4294967295);
pub const MQTTCLIENT_TOPICNAME_TRUNCATED = -7;
pub const __INT_MAX__ = 2147483647;
pub const __INT_LEAST64_MAX__ = @as(c_long, 9223372036854775807);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_8 = 1;
pub const __USE_FORTIFY_LEVEL = 0;
pub const __RLIM_T_MATCHES_RLIM64_T = 1;
pub const __SIZEOF_INT128__ = 16;
pub const __INT64_MAX__ = @as(c_long, 9223372036854775807);
pub const __DBL_MIN_10_EXP__ = -307;
pub const MQTTCLIENT_WRONG_MQTT_VERSION = -16;
pub const __INT_LEAST32_MAX__ = 2147483647;
pub const __INT_FAST16_FMTd__ = "hd";
pub const MQTT_SSL_VERSION_TLS_1_1 = 2;
pub const __attribute_pure__ = __attribute__(__pure__);
pub const __UINT_LEAST64_FMTu__ = "lu";
pub const __DBL_DENORM_MIN__ = 4.9406564584124654e-324;
pub const __UINT8_FMTu__ = "hhu";
pub const __INT_FAST16_MAX__ = 32767;
pub inline fn __bos0(ptr: var) @TypeOf(__builtin_object_size(ptr, 0)) {
    return __builtin_object_size(ptr, 0);
}
pub const __LP64__ = 1;
pub const __SIZE_FMTx__ = "lx";
pub const __ORDER_PDP_ENDIAN__ = 3412;
pub const __UINT8_FMTX__ = "hhX";
pub const __LDBL_MIN_10_EXP__ = -4931;
pub const __LDBL_MAX_10_EXP__ = 4932;
pub const __DBL_MAX_10_EXP__ = 308;
pub const __PTRDIFF_FMTi__ = "li";
pub const __STDC_IEC_559__ = 1;
pub const MQTT_BAD_SUBSCRIBE = 0x80;
pub inline fn __REDIRECT_NTH_LDBL(name: var, proto: var, alias: var) @TypeOf(__REDIRECT_NTH(name, proto, alias)) {
    return __REDIRECT_NTH(name, proto, alias);
}
pub const __FLT_MIN_EXP__ = -125;
pub const __SIZEOF_LONG__ = 8;
pub const __FLT_MIN__ = @as(f32, 1.17549435e-38);
pub const __FLT_EVAL_METHOD__ = 0;
pub const P_tmpdir = "/tmp";
pub const __UINTMAX_FMTx__ = "lx";
pub const __UINT_LEAST8_FMTo__ = "hho";
pub const __code_model_small_ = 1;
pub const __ELF__ = 1;
pub const __UINT_FAST8_FMTu__ = "hhu";
pub const __DADDR_T_TYPE = __S32_TYPE;
pub const _LP64 = 1;
pub const MQTTVERSION_3_1 = 3;
pub const __FLT_MAX_EXP__ = 128;
pub const __DBL_HAS_DENORM__ = 1;
pub const __WINT_UNSIGNED__ = 1;
pub const __INT_LEAST64_FMTd__ = "ld";
pub const __GNU_LIBRARY__ = 6;
pub const __UINT_LEAST8_FMTu__ = "hhu";
pub const __FLT_MAX__ = @as(f32, 3.40282347e+38);
pub inline fn __glibc_likely(cond: var) @TypeOf(__builtin_expect(cond, 1)) {
    return __builtin_expect(cond, 1);
}
pub const __CPU_MASK_TYPE = __SYSCALL_ULONG_TYPE;
pub const __UINT_FAST8_FMTX__ = "hhX";
pub const __UINT_FAST16_FMTu__ = "hu";
pub const __amdfam10 = 1;
pub const SEEK_END = 2;
pub const MQTTVERSION_5 = 5;
pub const __UINT_FAST32_FMTX__ = "X";
pub const __DECIMAL_DIG__ = __LDBL_DECIMAL_DIG__;
pub const __LZCNT__ = 1;
pub inline fn __glibc_clang_has_extension(ext: var) @TypeOf(__has_extension(ext)) {
    return __has_extension(ext);
}
pub const __BLKCNT_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const _BITS_TYPES_H = 1;
pub const __SSP_STRONG__ = 2;
pub const __clang_patchlevel__ = 0;
pub const __UINT64_FMTu__ = "lu";
pub const _IONBF = 2;
pub const MQTTCLIENT_PERSISTENCE_USER = 2;
pub const __SIZEOF_SHORT__ = 2;
pub const __LDBL_DIG__ = 18;
pub const __OPENCL_MEMORY_SCOPE_DEVICE = 2;
pub const __INT_FAST8_FMTd__ = "hhd";
pub const __FLT_DENORM_MIN__ = @as(f32, 1.40129846e-45);
pub const __MMX__ = 1;
pub const __NO_INLINE__ = 1;
pub const __SIZEOF_WINT_T__ = 4;
pub inline fn __GLIBC_PREREQ(maj: var, min: var) @TypeOf(__GLIBC__ << 16 + __GLIBC_MINOR__ >= maj << 16 + min) {
    return __GLIBC__ << 16 + __GLIBC_MINOR__ >= maj << 16 + min;
}
pub const __STDC_IEC_559_COMPLEX__ = 1;
pub const __CLANG_ATOMIC_POINTER_LOCK_FREE = 2;
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_4 = 1;
pub const __INTMAX_C_SUFFIX__ = L;
pub const __UINT_LEAST32_FMTu__ = "u";
pub const __INT_LEAST16_FMTi__ = "hi";
pub const __LITTLE_ENDIAN__ = 1;
pub const MQTTCLIENT_DISCONNECTED = -3;
pub const __UINTMAX_C_SUFFIX__ = UL;
pub const __INO_T_MATCHES_INO64_T = 1;
pub inline fn __attribute_deprecated_msg__(msg: var) @TypeOf(__attribute__(__deprecated__(msg))) {
    return __attribute__(__deprecated__(msg));
}
pub const _IO_USER_LOCK = 0x8000;
pub const __OPENCL_MEMORY_SCOPE_WORK_ITEM = 0;
pub const __VERSION__ = "Clang 9.0.0 (tags/RELEASE_900/final)";
pub const __DBL_HAS_INFINITY__ = 1;
pub const __INT_LEAST16_MAX__ = 32767;
pub const __SCHAR_MAX__ = 127;
pub const __GNUC_MINOR__ = 2;
pub const __UINT32_FMTx__ = "x";
pub const __LDBL_HAS_QUIET_NAN__ = 1;
pub const __UINT_FAST32_FMTu__ = "u";
pub const __UINT8_FMTx__ = "hhx";
pub const __UINT_LEAST8_FMTX__ = "hhX";
pub const _DEFAULT_SOURCE = 1;
pub const __UINT_LEAST64_FMTx__ = "lx";
pub const __UINT_LEAST64_MAX__ = @as(c_ulong, 18446744073709551615);
pub const MQTT_SSL_VERSION_DEFAULT = 0;
pub const __GCC_ATOMIC_CHAR16_T_LOCK_FREE = 2;
pub const __pic__ = 2;
pub const __clang__ = 1;
pub const __FLT_HAS_INFINITY__ = 1;
pub const __GLIBC__ = 2;
pub const __USE_XOPEN2K8 = 1;
pub const __UINTPTR_FMTu__ = "lu";
pub const __3dNOW__ = 1;
pub const __unix__ = 1;
pub const EOF = -1;
pub const __UID_T_TYPE = __U32_TYPE;
pub const __INT_FAST32_TYPE__ = c_int;
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_1 = 1;
pub inline fn __va_copy(d: var, s: var) @TypeOf(__builtin_va_copy(d, s)) {
    return __builtin_va_copy(d, s);
}
pub const __restrict_arr = __restrict;
pub const __UINT16_FMTx__ = "hx";
pub const __UINT_LEAST32_FMTo__ = "o";
pub const __glibc_c99_flexarr_available = 1;
pub const SEEK_SET = 0;
pub const __FLT_MIN_10_EXP__ = -37;
pub const __UINT_LEAST16_FMTX__ = "hX";
pub const __UINT_LEAST32_MAX__ = @as(c_uint, 4294967295);
pub const __RLIM64_T_TYPE = __UQUAD_TYPE;
pub const __FSFILCNT_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __GNUC_VA_LIST = 1;
pub const __UINT_FAST8_FMTx__ = "hhx";
pub const __SIZE_FMTu__ = "lu";
pub const __SIZEOF_POINTER__ = 8;
pub const __SIZE_FMTX__ = "lX";
pub const __USE_XOPEN2K = 1;
pub const __INT16_FMTd__ = "hd";
pub const __clang_version__ = "9.0.0 (tags/RELEASE_900/final)";
pub const __ATOMIC_RELEASE = 3;
pub const __UINT_FAST64_FMTX__ = "lX";
pub const __INTMAX_FMTd__ = "ld";
pub const __SEG_FS = 1;
pub const __USE_POSIX199309 = 1;
pub const TMP_MAX = 238328;
pub const __UINT_FAST8_FMTo__ = "hho";
pub const __WINT_WIDTH__ = 32;
pub const SEEK_CUR = 1;
pub const __FLT_MAX_10_EXP__ = 38;
pub const __LDBL_MAX__ = @as(c_longdouble, 1.18973149535723176502e+4932);
pub const __GCC_ATOMIC_LONG_LOCK_FREE = 2;
pub const __gnu_linux__ = 1;
pub const _DEBUG = 1;
pub const _____fpos64_t_defined = 1;
pub const _IO_EOF_SEEN = 0x0010;
pub inline fn __PMT(args: var) @TypeOf(args) {
    return args;
}
pub const __UINTPTR_WIDTH__ = 64;
pub const __INT_LEAST32_FMTi__ = "i";
pub const __WCHAR_WIDTH__ = 32;
pub const __UINT16_FMTX__ = "hX";
pub const __OFF64_T_TYPE = __SQUAD_TYPE;
pub const unix = 1;
pub const __STDC_ISO_10646__ = @as(c_long, 201706);
pub const __SYSCALL_ULONG_TYPE = __ULONGWORD_TYPE;
pub const __BLKSIZE_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __GNUC_PATCHLEVEL__ = 1;
pub const _IO_ERR_SEEN = 0x0020;
pub const __INT_LEAST16_TYPE__ = c_short;
pub const __INT64_FMTd__ = "ld";
pub const __SSE3__ = 1;
pub const __SYSCALL_SLONG_TYPE = __SLONGWORD_TYPE;
pub const __UINT16_MAX__ = 65535;
pub const __ATOMIC_RELAXED = 0;
pub const FOPEN_MAX = 16;
pub const _POSIX_SOURCE = 1;
pub const __SSE4A__ = 1;
pub const __GCC_ATOMIC_CHAR_LOCK_FREE = 2;
pub const __UINT_LEAST16_FMTx__ = "hx";
pub const __UINT_FAST64_FMTu__ = "lu";
pub const __CLANG_ATOMIC_CHAR16_T_LOCK_FREE = 2;
pub const __SSE2__ = 1;
pub const _ATFILE_SOURCE = 1;
pub const __STDC__ = 1;
pub const __attribute_warn_unused_result__ = __attribute__(__warn_unused_result__);
pub const ____FILE_defined = 1;
pub const __GLIBC_USE_IEC_60559_BFP_EXT = 0;
pub const __INT_FAST16_TYPE__ = c_short;
pub const __UINT64_C_SUFFIX__ = UL;
pub const MQTTCLIENT_SUCCESS = 0;
pub const __LONG_MAX__ = @as(c_long, 9223372036854775807);
pub const __DBL_MAX__ = 1.7976931348623157e+308;
pub const __MODE_T_TYPE = __U32_TYPE;
pub const __CHAR_BIT__ = 8;
pub const __DBL_DECIMAL_DIG__ = 17;
pub const __UINT_LEAST8_FMTx__ = "hhx";
pub const __FSBLKCNT64_T_TYPE = __UQUAD_TYPE;
pub const MQTTCLIENT_MAX_MESSAGES_INFLIGHT = -4;
pub const MQTTCLIENT_PERSISTENCE_ERROR = -2;
pub const linux = 1;
pub const __ORDER_BIG_ENDIAN__ = 4321;
pub const MQTT_SSL_VERSION_TLS_1_0 = 1;
pub const __INTPTR_MAX__ = @as(c_long, 9223372036854775807);
pub const __INT_LEAST8_FMTd__ = "hhd";
pub const __INTMAX_WIDTH__ = 64;
pub const MQTTCLIENT_PERSISTENCE_NONE = 1;
pub const __CLANG_ATOMIC_SHORT_LOCK_FREE = 2;
pub const _BITS_STDIO_LIM_H = 1;
pub const __FLOAT128__ = 1;
pub const __attribute_deprecated__ = __attribute__(__deprecated__);
pub const MQTTCLIENT_FAILURE = -1;
pub const __LDBL_DENORM_MIN__ = @as(c_longdouble, 3.64519953188247460253e-4951);
pub const __GLIBC_MINOR__ = 30;
pub const __PID_T_TYPE = __S32_TYPE;
pub const __x86_64 = 1;
pub const __CLANG_ATOMIC_LONG_LOCK_FREE = 2;
pub const __INTMAX_MAX__ = @as(c_long, 9223372036854775807);
pub const __INT8_FMTd__ = "hhd";
pub const __UINTMAX_WIDTH__ = 64;
pub const __UINT8_MAX__ = 255;
pub const __DBL_MIN__ = 2.2250738585072014e-308;
pub const __GLIBC_USE_IEC_60559_FUNCS_EXT = 0;
pub const __PRAGMA_REDEFINE_EXTNAME = 1;
pub const __DBL_HAS_QUIET_NAN__ = 1;
pub const __clang_minor__ = 0;
pub const __LDBL_DECIMAL_DIG__ = 21;
pub const MQTTCLIENT_BAD_UTF8_STRING = -5;
pub const __USE_MISC = 1;
pub const __WCHAR_TYPE__ = c_int;
pub const __INT_FAST64_FMTd__ = "ld";
pub const _STDIO_H = 1;
pub const __KEY_T_TYPE = __S32_TYPE;
pub const __GCC_ATOMIC_WCHAR_T_LOCK_FREE = 2;
pub const __seg_fs = __attribute__(address_space(257));
pub const __attribute_malloc__ = __attribute__(__malloc__);
pub const __HAVE_GENERIC_SELECTION = 1;
pub const __INT16_FMTi__ = "hi";
pub const __UINTMAX_FMTX__ = "lX";
pub const __LDBL_MIN_EXP__ = -16381;
pub const __PRFCHW__ = 1;
pub const __ID_T_TYPE = __U32_TYPE;
pub const __UINTMAX_FMTu__ = "lu";
pub const __UINT_LEAST16_FMTo__ = "ho";
pub const L_tmpnam = 20;
pub const __glibc_has_include = __has_include;
pub const _STDC_PREDEF_H = 1;
pub const __UINT32_FMTu__ = "u";
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 = 1;
pub const __SIG_ATOMIC_WIDTH__ = 32;
pub const MQTTCLIENT_PERSISTENCE_DEFAULT = 0;
pub const __amd64__ = 1;
pub const __INT64_C_SUFFIX__ = L;
pub const __LDBL_EPSILON__ = @as(c_longdouble, 1.08420217248550443401e-19);
pub const __CLANG_ATOMIC_INT_LOCK_FREE = 2;
pub const _BITS_TYPESIZES_H = 1;
pub const _IOLBF = 1;
pub const __SSE2_MATH__ = 1;
pub const __GCC_ATOMIC_SHORT_LOCK_FREE = 2;
pub inline fn __P(args: var) @TypeOf(args) {
    return args;
}
pub const __TIME_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __POPCNT__ = 1;
pub const __POINTER_WIDTH__ = 64;
pub const __UINT64_FMTx__ = "lx";
pub const __ATOMIC_ACQ_REL = 4;
pub const __UINT_LEAST32_FMTx__ = "x";
pub const __OFF_T_MATCHES_OFF64_T = 1;
pub const __STDC_HOSTED__ = 1;
pub const __INO64_T_TYPE = __UQUAD_TYPE;
pub const __GNUC__ = 4;
pub const __INT_FAST32_FMTi__ = "i";
pub const __PIC__ = 2;
pub const __BLKCNT64_T_TYPE = __SQUAD_TYPE;
pub const __GCC_ATOMIC_BOOL_LOCK_FREE = 2;
pub const __seg_gs = __attribute__(address_space(256));
pub const __FXSR__ = 1;
pub const __UINT64_FMTo__ = "lo";
pub const MQTTVERSION_DEFAULT = 0;
pub const __UINT_FAST16_FMTx__ = "hx";
pub const MQTT_SSL_VERSION_TLS_1_2 = 3;
pub const MQTTCLIENT_SSL_NOT_SUPPORTED = -10;
pub const __CLOCK_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __GLIBC_USE_DEPRECATED_SCANF = 0;
pub const __UINT_LEAST64_FMTo__ = "lo";
pub const __attribute_used__ = __attribute__(__used__);
pub const __STDC_UTF_32__ = 1;
pub const __FSFILCNT64_T_TYPE = __UQUAD_TYPE;
pub const __PTRDIFF_WIDTH__ = 64;
pub const __SIZE_WIDTH__ = 64;
pub const __LDBL_MIN__ = @as(c_longdouble, 3.36210314311209350626e-4932);
pub const __UINTMAX_MAX__ = @as(c_ulong, 18446744073709551615);
pub const _SYS_CDEFS_H = 1;
pub const __INT_LEAST16_FMTd__ = "hd";
pub const __SIZEOF_PTRDIFF_T__ = 8;
pub inline fn __glibc_clang_prereq(maj: var, min: var) @TypeOf(__clang_major__ << 16 + __clang_minor__ >= maj << 16 + min) {
    return __clang_major__ << 16 + __clang_minor__ >= maj << 16 + min;
}
pub const __UINT_LEAST16_FMTu__ = "hu";
pub const __UINT16_FMTu__ = "hu";
pub const MQTTVERSION_3_1_1 = 4;
pub const __DBL_MANT_DIG__ = 53;
pub const __CLANG_ATOMIC_WCHAR_T_LOCK_FREE = 2;
pub const __INT_LEAST64_FMTi__ = "li";
pub const __GNUC_STDC_INLINE__ = 1;
pub const __UINT32_FMTX__ = "X";
pub const __DBL_DIG__ = 15;
pub const __SHRT_MAX__ = 32767;
pub inline fn va_copy(dest: var, src: var) @TypeOf(__builtin_va_copy(dest, src)) {
    return __builtin_va_copy(dest, src);
}
pub const __ATOMIC_CONSUME = 1;
pub const __GLIBC_USE_DEPRECATED_GETS = 0;
pub const __UINT_FAST16_FMTX__ = "hX";
pub const MQTTCLIENT_BAD_STRUCTURE = -8;
pub const __FSBLKCNT_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __INT_FAST16_FMTi__ = "hi";
pub const __INT32_FMTd__ = "d";
pub const __INT8_MAX__ = 127;
pub const __FLT_DECIMAL_DIG__ = 9;
pub const __INT_LEAST32_FMTd__ = "d";
pub const MQTTCLIENT_BAD_PROTOCOL = -14;
pub const __UINT8_FMTo__ = "hho";
pub const __USE_POSIX199506 = 1;
pub const __struct_FILE_defined = 1;
pub const __amdfam10__ = 1;
pub inline fn __bos(ptr: var) @TypeOf(__builtin_object_size(ptr, __USE_FORTIFY_LEVEL > 1)) {
    return __builtin_object_size(ptr, __USE_FORTIFY_LEVEL > 1);
}
pub const __FLT_HAS_DENORM__ = 1;
pub const __FLT_DIG__ = 6;
pub const DLLExport = __attribute__(visibility("default"));
pub const __INTPTR_FMTi__ = "li";
pub const __UINT32_FMTo__ = "o";
pub const __UINT_FAST64_MAX__ = @as(c_ulong, 18446744073709551615);
pub const __GID_T_TYPE = __U32_TYPE;
pub const MQTTCLIENT_NULL_PARAMETER = -6;
pub const _____fpos_t_defined = 1;
pub const __UINT_FAST64_FMTo__ = "lo";
pub const __GXX_ABI_VERSION = 1002;
pub const __tune_amdfam10__ = 1;
pub const __SIZEOF_LONG_LONG__ = 8;
pub const __INT32_TYPE__ = c_int;
pub inline fn __ASMNAME(cname: var) @TypeOf(__ASMNAME2(__USER_LABEL_PREFIX__, cname)) {
    return __ASMNAME2(__USER_LABEL_PREFIX__, cname);
}
pub const __OPENCL_MEMORY_SCOPE_ALL_SVM_DEVICES = 3;
pub const __UINTPTR_FMTX__ = "lX";
pub const __INT8_FMTi__ = "hhi";
pub const __SIZEOF_LONG_DOUBLE__ = 16;
pub const __DBL_MIN_EXP__ = -1021;
pub const __INT64_FMTi__ = "li";
pub const __INT_FAST64_FMTi__ = "li";
pub const __RLIM_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __attribute_const__ = __attribute__(__const__);
pub inline fn __attribute_format_arg__(x: var) @TypeOf(__attribute__(__format_arg__(x))) {
    return __attribute__(__format_arg__(x));
}
pub const __GCC_ATOMIC_TEST_AND_SET_TRUEVAL = 1;
pub const __clang_major__ = 9;
pub const __USE_ISOC95 = 1;
pub const __OPENCL_MEMORY_SCOPE_SUB_GROUP = 4;
pub const __INT16_MAX__ = 32767;
pub const __linux = 1;
pub const __OFF_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const MQTTCLIENT_BAD_QOS = -9;
pub const __GCC_ATOMIC_LLONG_LOCK_FREE = 2;
pub const FILENAME_MAX = 4096;
pub const __UINT16_FMTo__ = "ho";
pub const BUFSIZ = 8192;
pub const __INT_FAST8_FMTi__ = "hhi";
pub const __NLINK_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __UINT_FAST64_FMTx__ = "lx";
pub const __GLIBC_USE_LIB_EXT2 = 0;
pub const __UINT_LEAST8_MAX__ = 255;
pub const __LDBL_HAS_INFINITY__ = 1;
pub const __UINT_LEAST32_FMTX__ = "X";
pub const __WORDSIZE = 64;
pub const __USE_POSIX = 1;
pub const __UINT_LEAST16_MAX__ = 65535;
pub const __unix = 1;
pub const __CONSTANT_CFSTRINGS__ = 1;
pub const __SSE_MATH__ = 1;
pub const __DBL_EPSILON__ = 2.2204460492503131e-16;
pub const __TIME64_T_TYPE = __TIME_T_TYPE;
pub const __llvm__ = 1;
pub const __SLONG32_TYPE = c_int;
pub const __DBL_MAX_EXP__ = 1024;
pub const __CLANG_ATOMIC_CHAR_LOCK_FREE = 2;
pub const MQTTCLIENT_BAD_MQTT_OPTION = -15;
pub const __CLANG_ATOMIC_CHAR32_T_LOCK_FREE = 2;
pub inline fn __glibc_unlikely(cond: var) @TypeOf(__builtin_expect(cond, 0)) {
    return __builtin_expect(cond, 0);
}
pub const __GCC_ASM_FLAG_OUTPUTS__ = 1;
pub inline fn __glibc_has_attribute(attr: var) @TypeOf(__has_attribute(attr)) {
    return __has_attribute(attr);
}
pub const __PTRDIFF_MAX__ = @as(c_long, 9223372036854775807);
pub const __ORDER_LITTLE_ENDIAN__ = 1234;
pub const __linux__ = 1;
pub const __INT16_TYPE__ = c_short;
pub const __attribute_noinline__ = __attribute__(__noinline__);
pub const __FSWORD_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __UINTPTR_FMTx__ = "lx";
pub const __USE_ISOC99 = 1;
pub const __LDBL_MAX_EXP__ = 16384;
pub const __UINT_FAST32_MAX__ = @as(c_uint, 4294967295);
pub const __3dNOW_A__ = 1;
pub const __S32_TYPE = c_int;
pub const __FLT_RADIX__ = 2;
pub const __FD_SETSIZE = 1024;
pub const __amd64 = 1;
pub const __WINT_MAX__ = @as(c_uint, 4294967295);
pub const _IOFBF = 0;
pub inline fn __attribute_format_strfmon__(a: var, b: var) @TypeOf(__attribute__(__format__(__strfmon__, a, b))) {
    return __attribute__(__format__(__strfmon__, a, b));
}
pub const __UINTPTR_FMTo__ = "lo";
pub const __INT32_MAX__ = 2147483647;
pub const __INTPTR_FMTd__ = "ld";
pub inline fn va_arg(ap: var, type_1: var) @TypeOf(__builtin_va_arg(ap, type_1)) {
    return __builtin_va_arg(ap, type_1);
}
pub const __USECONDS_T_TYPE = __U32_TYPE;
pub const __INTPTR_WIDTH__ = 64;
pub const MQTT_INVALID_PROPERTY_ID = -2;
pub const __INT_FAST32_MAX__ = 2147483647;
pub const _BITS_TIME64_H = 1;
pub const __INT32_FMTi__ = "i";
pub const __GCC_ATOMIC_CHAR32_T_LOCK_FREE = 2;
pub const __UINT_FAST16_FMTo__ = "ho";
pub const __USE_ISOC11 = 1;
pub const __GCC_ATOMIC_INT_LOCK_FREE = 2;
pub const __FILE_defined = 1;
pub const __FLT_HAS_QUIET_NAN__ = 1;
pub const __INT_LEAST32_TYPE__ = c_int;
pub const __BIGGEST_ALIGNMENT__ = 16;
pub inline fn __REDIRECT_LDBL(name: var, proto: var, alias: var) @TypeOf(__REDIRECT(name, proto, alias)) {
    return __REDIRECT(name, proto, alias);
}
pub const __GCC_ATOMIC_POINTER_LOCK_FREE = 2;
pub const __SIZE_MAX__ = @as(c_ulong, 18446744073709551615);
pub const __INT_FAST64_MAX__ = @as(c_long, 9223372036854775807);
pub const __CLANG_ATOMIC_LLONG_LOCK_FREE = 2;
pub const __UINTPTR_MAX__ = @as(c_ulong, 18446744073709551615);
pub const __UINT_FAST32_FMTx__ = "x";
pub const __PTRDIFF_FMTd__ = "ld";
pub const __INO_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __LONG_LONG_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __CLANG_ATOMIC_BOOL_LOCK_FREE = 2;
pub const __WCHAR_MAX__ = 2147483647;
pub const __ATOMIC_SEQ_CST = 5;
pub const __LDBL_MANT_DIG__ = 64;
pub const __UINT_FAST8_MAX__ = 255;
pub const __SIZEOF_SIZE_T__ = 8;
pub const __STDC_VERSION__ = @as(c_long, 201112);
pub const __THROWNL = __attribute__(__nothrow__);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_16 = 1;
pub const __OPENCL_MEMORY_SCOPE_WORK_GROUP = 1;
pub const __SSIZE_T_TYPE = __SWORD_TYPE;
pub const L_ctermid = 9;
pub const __DEV_T_TYPE = __UQUAD_TYPE;
pub const __SIZEOF_INT__ = 4;
pub const __TIMESIZE = __WORDSIZE;
pub const __UINT32_C_SUFFIX__ = U;
pub const __x86_64__ = 1;
pub inline fn va_end(ap: var) @TypeOf(__builtin_va_end(ap)) {
    return __builtin_va_end(ap);
}
pub const __SUSECONDS_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __FLT_MANT_DIG__ = 24;
pub const __INT_LEAST8_MAX__ = 127;
pub const __GLIBC_USE_IEC_60559_TYPES_EXT = 0;
pub const __UINTMAX_FMTo__ = "lo";
pub const ____mbstate_t_defined = 1;
pub const __SIZE_FMTo__ = "lo";
pub const __SIZEOF_DOUBLE__ = 8;
pub const __USE_ATFILE = 1;
pub const __USE_POSIX_IMPLICITLY = 1;
pub const __SIZEOF_WCHAR_T__ = 4;
pub const _G_fpos_t = struct__G_fpos_t;
pub const _G_fpos64_t = struct__G_fpos64_t;
pub const _IO_marker = struct__IO_marker;
pub const _IO_codecvt = struct__IO_codecvt;
pub const _IO_wide_data = struct__IO_wide_data;
pub const _IO_FILE = struct__IO_FILE;
pub const __va_list_tag = struct___va_list_tag;
pub const MQTTPropertyCodes = enum_MQTTPropertyCodes;
pub const MQTTPropertyTypes = enum_MQTTPropertyTypes;
pub const MQTTReasonCodes = enum_MQTTReasonCodes;
pub const MQTTCLIENT_TRACE_LEVELS = enum_MQTTCLIENT_TRACE_LEVELS;
