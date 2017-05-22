local pb = {}

-- define message
local wire_types = {
    int32 = 0,
    int64 = 0,
    sint32 = 0,
    sint64 = 0,
    uint32 = 0,
    uint64 = 0,
    bool = 0,
    enum = 0,
    fixed64 = 1,
    sfixed64 = 1,
    double = 1,
    string = 2,
    bytes = 2,
    fixed32 = 5,
    sfixed32 = 5,
    float = 5,
}
local default_objects = {
    int32 = 0,
    int64 = 0,
    sint32 = 0,
    sint64 = 0,
    uint32 = 0,
    uint64 = 0,
    bool = false,
    enum = 0,
    fixed64 = 0,
    sfixed64 = 0,
    double = 0.0,
    string = '',
    bytes = '',
    fixed32 = 0,
    sfixed32 = 0,
    float = 0.0,
}
local function encode_varint(writer, n)
    writer(c_pb.signed_varint_encoder(n))
end
local function encode_unsigned_varint(writer, n)
    writer(c_pb.varint_encoder(n))
end
local function encode_zigzag_varint32(writer, n)
    encode_unsigned_varint(writer, c_pb.zig_zag_encode32(n))
end
local function encode_zigzag_varint64(writer, n)
    encode_unsigned_varint(writer, c_pb.zig_zag_encode64(n))
end
local function encode_type(writer, type, index)
    encode_unsigned_varint(writer, index * 8 + type)
end
local function encode_bool(writer, v)
    writer(v and '\1' or '\0')
end
local function struct_encoder(fmt)
    return function(writer, v)
        writer(c_pb.struct_pack(string.byte(fmt), v))
    end
end
local function encode_bytes(writer, v, name)
    assert(type(v) == 'string', name and ('invalid value ' .. name))
    encode_unsigned_varint(writer, #v)
    writer(v)
end
local function message_encoder(msg)
    return function(writer, value)
        for _, f in ipairs(msg._fields) do
            local v = value[f.name]
            if v ~= nil then
                if f.packed then
                    assert(type(v) == 'table')
                    local buf = {}
                    local writer2 = function(vv)
                        table.insert(buf, vv)
                    end
                    for _, i in ipairs(v) do
                        f.encoder(writer2, i, f.name)
                    end
                    encode_type(writer, f.wire_type, f.index)
                    encode_bytes(writer, table.concat(buf), f.name)
                elseif f.repeated then
                    assert(type(v) == 'table')
                    for _, i in ipairs(v) do
                        encode_type(writer, f.wire_type, f.index)
                        if type(f.type) == 'table' then
                            local buf = {}
                            local writer2 = function(vv)
                                table.insert(buf, vv)
                            end
                            f.encoder(writer2, i, f.name)
                            encode_bytes(writer, table.concat(buf), f.name)
                        else
                            f.encoder(writer, i, f.name)
                        end
                    end
                else
                    encode_type(writer, f.wire_type, f.index)
                    if type(f.type) == 'table' then
                        local buf = {}
                        local writer2 = function(vv)
                            table.insert(buf, vv)
                        end
                        f.encoder(writer2, v, f.name)
                        encode_bytes(writer, table.concat(buf))
                    else
                        f.encoder(writer, v, f.name)
                    end
                end
            end
        end
    end
end

local encoders = {
    int32 = encode_varint,
    int64 = encode_varint,
    sint32 = encode_zigzag_varint32,
    sint64 = encode_zigzag_varint64,
    uint32 = encode_unsigned_varint,
    uint64 = encode_unsigned_varint,
    fixed32 = struct_encoder('I'),
    fixed64 = struct_encoder('Q'),
    sfixed32 = struct_encoder('i'),
    sfixed64 = struct_encoder('q'),
    float = struct_encoder('f'),
    double = struct_encoder('d'),
    bool = encode_bool,
    enum = encode_varint,
    string = encode_bytes,
    bytes = encode_bytes,
}
local function skip_unknown_field(buffer, pos, wtype)
    if wtype == 0 then
        -- varint
        return c_pb.varint_size(buffer, pos)
    elseif wtype == 1 then
        -- fixed 64 / double
        assert(pos + 8 <= #buffer, 'skip failed, not enough space.')
        return pos + 8
    elseif wtype == 5 then
        -- fixed 32 / float
        assert(pos + 4 <= #buffer, 'skip failed, not enough space.')
        return pos + 4
    elseif wtype == 2 then
        -- bytes
        local len, pos = c_pb.varint_decoder(buffer, pos)
        assert(pos + len <= #buffer, 'skip failed, not enough space.')
        return pos + len
    else
        error('unknown wire type:' .. wtype)
    end
end
local function decode_zigzag32(buffer, pos)
    local v
    v, pos = c_pb.varint_decoder(buffer, pos)
    return c_pb.zig_zag_decode32(v), pos
end
local function decode_zigzag64(buffer, pos)
    local v
    v, pos = c_pb.varint_decoder(buffer, pos)
    return c_pb.zig_zag_decode32(v), pos
end
local function decode_delimited(buffer, pos)
    local len
    len, pos = c_pb.signed_varint_decoder(buffer, pos)
    return pos + len, pos
end
local function decode_bytes(buffer, pos)
    local offset
    pos, offset = decode_delimited(buffer, pos)
    return string.sub(buffer, offset, pos-1), pos
end
local meta_message = {
    __index = function(self, name)
        -- return default value
        local f = self.___message[name]
        if f then
            if f.repeated then
                local v = {}
                self[name] = v
                return v
            else
                return f.default
            end
        end
    end,
}
local function decode_message(buffer, pos, stop, msg)
    local o = setmetatable({
        ___message = msg
    }, meta_message)
    local v
    while pos <= stop do
        local tag
        tag, pos = c_pb.varint_decoder(buffer, pos)
        local findex = bit.brshift(tag, 3)
        local wtype = bit.band(tag, 0x07)
        local f = msg._by_index[findex]
        if not f then
            -- try to skip
            pos = skip_unknown_field(buffer, pos, wtype)
        else
            local packed = wtype == 2 and f.is_numeric
            if packed then
                assert(f.repeated, 'packed encoding data must is repeated field.')
                local offset
                pos, offset = decode_delimited(buffer, pos)
                if o[f.name] == nil then
                    o[f.name] = {}
                end
                v = o[f.name]
                while offset < pos do
                    local i
                    i, offset = f.decoder(buffer, offset)
                    table.insert(v, i)
                end
            else
                v, pos = f.decoder(buffer, pos)
                if f.repeated then
                    if o[f.name] == nil then
                        o[f.name] = {}
                    end
                    table.insert(o[f.name], v)
                else
                    o[f.name] = v
                end
            end
        end
    end
    return o
end
local function message_decoder(msg)
    return function(buffer, pos)
        local offset
        pos, offset = decode_delimited(buffer, pos)
        return decode_message(buffer, offset, pos-1, msg), pos
    end
end
local function struct_decoder(fmt)
    return function(buffer, pos)
        return c_pb.struct_unpack(string.byte(fmt), buffer, pos)
    end
end
local function decode_bool(buffer, pos)
    return string.byte(buffer, pos)~=0, pos+1
end

local decoders = {
    int32 = c_pb.signed_varint_decoder,
    int64 = c_pb.signed_varint_decoder,
    sint32 = decode_zigzag32,
    sint64 = decode_zigzag64,
    uint32 = c_pb.varint_decoder,
    uint64 = c_pb.varint_decoder,
    fixed32 = struct_decoder('I'),
    fixed64 = struct_decoder('Q'),
    sfixed32 = struct_decoder('i'),
    sfixed64 = struct_decoder('q'),
    float = struct_decoder('f'),
    double = struct_decoder('d'),
    bool = decode_bool,
    enum = c_pb.varint_decoder,
    string = decode_bytes,
    bytes = decode_bytes,
}

pb.message = function(msg_name, fields)
    local obj = {
        _class = pb.message,
        _by_index = {},
        _fields = {},
        _name = msg_name,
    }
    for k, v in pairs(fields) do
        obj[k] = v
    end
    -- indexes
    for name, f in pairs(fields) do
        if type(f) == 'table' then
            f.name = name
            assert(obj._by_index[f.index] == nil, 'conflict field index')
            obj._by_index[f.index] = f
            table.insert(obj._fields, f)
        end
    end
    table.sort(obj._fields, function(a,b)
        return a.index < b.index
    end)
    obj._encoder = message_encoder(obj)
    obj._decoder = message_decoder(obj)
    return obj
end
local function extend_message(msg, name, f)
    assert(msg[f.name] == nil, 'conflict field name')
    assert(msg._by_index[f.index] == nil, 'conflict field index')
    msg[name] = f
    f.name = name
    msg._by_index[f.index] = f
    table.insert(msg._fields, f)
    table.sort(msg._fields, function(a,b)
        return a.index < b.index
    end)
end
local function is_numeric_type(type_)
    -- not message, not string, not bytes.
    return type(type_) == 'string' and type_ ~= 'string' and type_ ~= 'bytes'
end
pb.field = function(type_, index, opt)
    -- name, type, index, packed, required, repeated, default
    local field = {
        _class = pb.field,
        type = type_,
        index = index,
        required = true,
        repeated = false,
        packed = false,
        is_numeric = is_numeric_type(type_)
    }
    if opt and opt.required ~= nil then
        field.required = opt.required
    end
    if opt and opt.packed ~= nil then
        field.packed = opt.packed
    end
    if field.packed then
        assert(field.is_numeric, 'packed field must be primitive numeric type.')
        field.repeated = true
    elseif opt and opt.repeated ~= nil then
        field.repeated = opt.repeated
    end
    if opt and opt.default ~= nil then
        field.default = field.default
    else
        field.default = default_objects[field.type]
    end
    field.wire_type = field.packed and 2 or (wire_types[field.type] or 2)
    if type(type_) == 'table' and #type_ == 2 then
        -- unresolved reference.
        field.resolved = false
    else
        if type(type_) == 'table' then
            field.encoder = field.type._encoder
            field.decoder = field.type._decoder
        else
            field.encoder = encoders[field.type] or field.type._encoder
            field.decoder = decoders[field.type] or field.type._decoder
        end
        assert(field.encoder and field.decoder, 'not found encoder/decoder' .. tostring(field.type))
        field.resolved = true
    end
    return field
end
local _rpc_impl = nil
pb.set_rpc_impl = function(fn)
    _rpc_impl = fn
end
local meta_method = {
    async = function(self, req, callback)
        assert(_rpc_impl, 'no rpc implementation.')
        _rpc_impl(self.service, self.name, pb.encode(self.request_message, req), function(rsp)
            callback(pb.decode(self.response_message, rsp))
        end)
    end,
    __call = function(self, req)
        return coroutine.yield(function(callback)
            self:async(req, callback)
        end)
    end
}
meta_method.__index = meta_method
pb.method = function(name, req_msg, rsp_msg)
    return setmetatable({
        name = name,
        request_message = req_msg,
        response_message = rsp_msg,
    }, meta_method)
end
pb.service = function(name, methods)
    local obj = {}
    for _, m in ipairs(methods) do
        m.service = name
        obj[m.name] = m
    end
    return obj
end
pb.encode = function(msg, value)
    assert(type(value) == 'table')
    local str = {}
    local writer = function(value)
        table.insert(str, value)
    end
    msg._encoder(writer, value)
    return table.concat(str)
end
pb.decode = function(msg, buffer, offset)
    return decode_message(buffer, offset or 1, #buffer, msg)
end
pb.resolve_message_references = function(m)
    for _, msg in pairs(m) do
        if type(msg) == 'table' and msg._class == pb.message then
            for _, f in ipairs(msg._fields) do
                assert(f._class == pb.field)
                if not f.resolved then
                    assert(type(f.type) == 'table' and #f.type == 2, 'invalid unresolved type.')
                    local t, name = unpack(f.type)
                    f.type = t[name]
                    assert(f.type and f.type._class == pb.message, 'invalid message reference: ' .. name)
                    f.encoder = f.type._encoder
                    f.decoder = f.type._decoder
                    f.resolved = true
                end
            end
        end
    end
end

local plugin = {}
pb.plugin = plugin

plugin.Location = pb.message('Location', {
    path            = pb.field('int32',	1, { repeated=true, packed=true}),
    span            = pb.field('int32',	2, { repeated=true, packed=true}),
})

plugin.SourceCodeInfo = pb.message('SourceCodeInfo', {
    location        = pb.field(plugin.Location,	1, { repeated=true}),
})

plugin.NamePart = pb.message('NamePart', {
    name_part       = pb.field('string',	1),
    is_extension    = pb.field('bool',	2),
})

plugin.UninterpretedOption = pb.message('UninterpretedOption', {
    name            = pb.field(plugin.NamePart,	2, { repeated=true}),
    identifier_value = pb.field('string',	3, { required=false}),
    positive_int_value = pb.field('uint64',	4, { required=false}),
    negative_int_value = pb.field('int64',	5, { required=false}),
    double_value    = pb.field('double',	6, { required=false}),
    string_value    = pb.field('bytes',	7, { required=false}),
    aggregate_value = pb.field('string',	8, { required=false}),
})

plugin.EnumValueOptions = pb.message('EnumValueOptions', {
    uninterpreted_option = pb.field(plugin.UninterpretedOption,	999, { repeated=true}),
})

plugin.FieldOptions = pb.message('FieldOptions', {
    -- enum CType
    STRING=0,
    CORD=1,
    STRING_PIECE=2,
    ctype           = pb.field('enum',	1, { required=false, default=0}),
    packed          = pb.field('bool',	2, { required=false}),
    deprecated      = pb.field('bool',	3, { required=false, default=false}),
    experimental_map_key = pb.field('string',	9, { required=false}),
    uninterpreted_option = pb.field(plugin.UninterpretedOption,	999, { repeated=true}),
})

plugin.MessageOptions = pb.message('MessageOptions', {
    message_set_wire_format = pb.field('bool',	1, { required=false, default=false}),
    no_standard_descriptor_accessor = pb.field('bool',	2, { required=false, default=false}),
    uninterpreted_option = pb.field(plugin.UninterpretedOption,	999, { repeated=true}),
})

plugin.ExtensionRange = pb.message('ExtensionRange', {
    start           = pb.field('int32',	1, { required=false}),
    end_             = pb.field('int32',	2, { required=false}),
})

plugin.EnumValueDescriptorProto = pb.message('EnumValueDescriptorProto', {
    name            = pb.field('string',	1, { required=false}),
    number          = pb.field('int32',	2, { required=false}),
    options         = pb.field(plugin.EnumValueOptions,	3, { required=false}),
})

plugin.FileOptions = pb.message('FileOptions', {
    -- enum OptimizeMode
    SPEED=1,
    CODE_SIZE=2,
    LITE_RUNTIME=3,
    java_package    = pb.field('string',	1, { required=false}),
    java_outer_classname = pb.field('string',	8, { required=false}),
    java_multiple_files = pb.field('bool',	10, { required=false, default=false}),
    java_generate_equals_and_hash = pb.field('bool',	20, { required=false, default=false}),
    optimize_for    = pb.field('enum',	9, { required=false, default=1}),
    cc_generic_services = pb.field('bool',	16, { required=false, default=false}),
    java_generic_services = pb.field('bool',	17, { required=false, default=false}),
    py_generic_services = pb.field('bool',	18, { required=false, default=false}),
    uninterpreted_option = pb.field(plugin.UninterpretedOption,	999, { repeated=true}),
})

plugin.ServiceOptions = pb.message('ServiceOptions', {
    uninterpreted_option = pb.field(plugin.UninterpretedOption,	999, { repeated=true}),
})

plugin.FieldDescriptorProto = pb.message('FieldDescriptorProto', {
    -- enum Type
    TYPE_DOUBLE=1,
    TYPE_FLOAT=2,
    TYPE_INT64=3,
    TYPE_UINT64=4,
    TYPE_INT32=5,
    TYPE_FIXED64=6,
    TYPE_FIXED32=7,
    TYPE_BOOL=8,
    TYPE_STRING=9,
    TYPE_GROUP=10,
    TYPE_MESSAGE=11,
    TYPE_BYTES=12,
    TYPE_UINT32=13,
    TYPE_ENUM=14,
    TYPE_SFIXED32=15,
    TYPE_SFIXED64=16,
    TYPE_SINT32=17,
    TYPE_SINT64=18,
    -- enum Label,
    LABEL_OPTIONAL=1,
    LABEL_REQUIRED=2,
    LABEL_REPEATED=3,
    name            = pb.field('string',	1, { required=false}),
    number          = pb.field('int32',	3, { required=false}),
    label           = pb.field('enum',	4, { required=false}),
    type            = pb.field('enum',	5, { required=false}),
    type_name       = pb.field('string',	6, { required=false}),
    extendee        = pb.field('string',	2, { required=false}),
    default_value   = pb.field('string',	7, { required=false}),
    options         = pb.field(plugin.FieldOptions,	8, { required=false}),
})

plugin.EnumOptions = pb.message('EnumOptions', {
    uninterpreted_option = pb.field(plugin.UninterpretedOption,	999, { repeated=true}),
})

plugin.EnumDescriptorProto = pb.message('EnumDescriptorProto', {
    name            = pb.field('string',	1, { required=false}),
    value           = pb.field(plugin.EnumValueDescriptorProto,	2, { repeated=true}),
    options         = pb.field(plugin.EnumOptions,	3, { required=false}),
})

plugin.DescriptorProto = pb.message('DescriptorProto', {
    name            = pb.field('string',	1, { required=false}),
    field           = pb.field(plugin.FieldDescriptorProto,	2, { repeated=true}),
    extension       = pb.field(plugin.FieldDescriptorProto,	6, { repeated=true}),
    nested_type     = pb.field({plugin, 'DescriptorProto'},	3, { repeated=true}),
    enum_type       = pb.field(plugin.EnumDescriptorProto,	4, { repeated=true}),
    extension_range = pb.field(plugin.ExtensionRange,	5, { repeated=true}),
    options         = pb.field(plugin.MessageOptions,	7, { required=false}),
})

plugin.MethodOptions = pb.message('MethodOptions', {
    uninterpreted_option = pb.field(plugin.UninterpretedOption,	999, { repeated=true}),
})

plugin.MethodDescriptorProto = pb.message('MethodDescriptorProto', {
    name            = pb.field('string',	1, { required=false}),
    input_type      = pb.field('string',	2, { required=false}),
    output_type     = pb.field('string',	3, { required=false}),
    options         = pb.field(plugin.MethodOptions,	4, { required=false}),
})

plugin.ServiceDescriptorProto = pb.message('ServiceDescriptorProto', {
    name            = pb.field('string',	1, { required=false}),
    method          = pb.field(plugin.MethodDescriptorProto,	2, { repeated=true}),
    options         = pb.field(plugin.ServiceOptions,	3, { required=false}),
})

plugin.FileDescriptorProto = pb.message('FileDescriptorProto', {
    name            = pb.field('string',	1, { required=false}),
    package         = pb.field('string',	2, { required=false}),
    dependency      = pb.field('string',	3, { repeated=true}),
    message_type    = pb.field(plugin.DescriptorProto,	4, { repeated=true}),
    enum_type       = pb.field(plugin.EnumDescriptorProto,	5, { repeated=true}),
    service         = pb.field(plugin.ServiceDescriptorProto,	6, { repeated=true}),
    extension       = pb.field(plugin.FieldDescriptorProto,	7, { repeated=true}),
    options         = pb.field(plugin.FileOptions,	8, { required=false}),
    source_code_info = pb.field(plugin.SourceCodeInfo,	9, { required=false}),
})

plugin.FileDescriptorSet = pb.message('FileDescriptorSet', {
    file            = pb.field(plugin.FileDescriptorProto,	1, { repeated=true}),
})

-- file: plugin.proto
plugin.CodeGeneratorRequest = pb.message('CodeGeneratorRequest', {
    file_to_generate = pb.field('string',	1, { repeated=true}),
    parameter       = pb.field('string',	2, { required=false}),
    proto_file      = pb.field(plugin.FileDescriptorProto,	15, { repeated=true}),
})

plugin.File = pb.message('File', {
    name            = pb.field('string',	1, { required=false}),
    insertion_point = pb.field('string',	2, { required=false}),
    content         = pb.field('string',	15, { required=false}),
})

plugin.CodeGeneratorResponse = pb.message('CodeGeneratorResponse', {
    error           = pb.field('string',	1, { required=false}),
    file            = pb.field(plugin.File,	15, { repeated=true}),
})

pb.resolve_message_references(plugin)

local function register_enum(t, enum_type)
    for _, e in ipairs(enum_type) do
        for _, i in ipairs(e.value) do
            t[i.name] = i.number
        end
    end
end

local string_types = {
    [plugin.FieldDescriptorProto.TYPE_DOUBLE]='double',
    [plugin.FieldDescriptorProto.TYPE_FLOAT]='float',
    [plugin.FieldDescriptorProto.TYPE_INT64]='int64',
    [plugin.FieldDescriptorProto.TYPE_UINT64]='uint64',
    [plugin.FieldDescriptorProto.TYPE_INT32]='int32',
    [plugin.FieldDescriptorProto.TYPE_FIXED64]='fixed64',
    [plugin.FieldDescriptorProto.TYPE_FIXED32]='fixed32',
    [plugin.FieldDescriptorProto.TYPE_BOOL]='bool',
    [plugin.FieldDescriptorProto.TYPE_STRING]='string',
    [plugin.FieldDescriptorProto.TYPE_BYTES]='bytes',
    [plugin.FieldDescriptorProto.TYPE_UINT32]='uint32',
    [plugin.FieldDescriptorProto.TYPE_ENUM]='enum',
    [plugin.FieldDescriptorProto.TYPE_SFIXED32]='sfixed32',
    [plugin.FieldDescriptorProto.TYPE_SFIXED64]='sfixed64',
    [plugin.FieldDescriptorProto.TYPE_SINT32]='sint32',
    [plugin.FieldDescriptorProto.TYPE_SINT64]='sint64',
}

local _registered_messages = {} -- tracking reference between messages.
local function register_field(f)
    local fargs = {}
    if f.label == plugin.FieldDescriptorProto.LABEL_REPEATED then
        fargs.repeated = true
    elseif f.label == plugin.FieldDescriptorProto.LABEL_OPTIONAL then
        fargs.required = false
    end
    if f.default_value then
        if f.type == plugin.FieldDescriptorProto.TYPE_STRING or f.type == plugin.FieldDescriptorProto.TYPE_BYTES then
            fargs.default = f.default_value
        else
            fargs.default = loadstring('return ' .. f.default_value)()
        end
    end
    return pb.field(string_types[f.type] or {_registered_messages, f.type_name}, f.number, fargs)
end
local function register_msg(pkg_name, msg)
    local fullname = pkg_name and ('.' .. pkg_name .. '.' .. msg.name) or ('.' .. msg.name)
    local args = {}
    for _, f in ipairs(msg.field) do
        args[f.name] = register_field(f)
    end
    for _, f in ipairs(msg.extension) do
        args[f.name] = register_field(f)
    end
    register_enum(args, msg.enum_type)
    local result = pb.message(fullname, args)
    _registered_messages[fullname] = result

    -- nest message
    local nest_pkg_name = (pkg_name and  pkg_name .. '.' or '') .. msg.name
    for _, nest_msg in ipairs(msg.nested_type) do
        result[nest_msg.name] = register_msg(nest_pkg_name, nest_msg)
    end

    return result
end

local function register_service(srv)
    local methods = {}
    for _, m in ipairs(srv.method) do
        table.insert(methods, pb.method(
            m.name, 
            _registered_messages[m.input_type],
            _registered_messages[m.output_type]
        ))
    end
    return pb.service(srv.name, methods)
end

local function register_package(pkg_name, files)
    local m = {}
    for _, file in ipairs(files) do
        for _, msg in ipairs(file.message_type) do
            assert(m[msg.name] == nil, 'conflict message name.')
            local t = register_msg(pkg_name, msg)
            m[msg.name] = t
        end
        for _, f in ipairs(file.extension) do
            local msg = _registered_messages[f.extendee]
            assert(msg, 'msg not found' .. f.extendee)
            extend_message(msg, f.name, register_field(f))
        end
        for _, srv in ipairs(file.service) do
            assert(m[srv.name] == nil, 'conflict service name.')
            m[srv.name] = register_service(srv)
        end
        register_enum(m, file.enum_type)
    end
    return m
end
function pb.register_file(...)
    local files = {...}
    local buffers = {}
    for _, filename in ipairs(files) do
        local fp = io.open(filename, 'rb')
        table.insert(buffers, fp:read('*a'))
        fp:close()
    end
    return pb.register(unpack(buffers))
end
function pb.register(...)
    local buffers = {...}
    local fileset
    for _, buffer in ipairs(buffers) do
        if not fileset then
            fileset = pb.decode(plugin.FileDescriptorSet, buffer)
        else
            local tmp = pb.decode(plugin.FileDescriptorSet, buffer)
            for _, file in ipairs(tmp.file) do
                table.insert(fileset.file, file)
            end
        end
    end
    local toplevel = {}
    local packages = {}
    for _, file in ipairs(fileset.file) do
        if not file.package or #file.package == 0 then
           table.insert(toplevel, file)
        else
            if packages[file.package] == nil then
                packages[file.package] = {}
            end
            table.insert(packages[file.package], file)
        end
    end
    local m = register_package(nil, toplevel)
    for pkg_name, files in pairs(packages) do
        m[pkg_name] = register_package(pkg_name, files)
    end
    pb.resolve_message_references(_registered_messages)
    _registered_messages = {}
    return m
end

local function gen_options(opt)
end
local function gen_field(f)
    --return string.format('pb.field(%s, %d, {%s})', f.type, f.index, gen_options(f))
end

local function gen_message(msg)
end

local function test_gen()
    print(gen_field(pb.field('int32', 1, {
    })))
end
test_gen()

return pb
