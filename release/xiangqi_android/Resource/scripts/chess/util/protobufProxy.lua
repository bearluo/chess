local pb = require("libs.protobuf")
require("chess/util/schemesProxy")

ProtobufProxy = {}
-- 弃用 因为不能发正常解析string
function ProtobufProxy.register(path)
    local str = require(path)
    local byteStr = SchemesProxy.FromBase64(str)
    local pbObj = pb.register(byteStr)
    return pbObj
end

function ProtobufProxy.encode(msg, value)
    return pb.encode(msg, value)
end

function ProtobufProxy.decode(msg, buffer, offset)
    return pb.decode(msg, buffer, offset)
end