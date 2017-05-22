
require(MODEL_PATH.."online/private/privateScene");
require(MODEL_PATH.."online/onlineScene");
require("chess/util/roomProxy");

SchemesProxy = class();
SchemesProxy.SCHEMA = "boyaachess";
SchemesProxy.HOST = SchemesProxy.SCHEMA .. "://v1";
function SchemesProxy.getIntentData()
    call_native("getIntentData");
    return dict_get_string("Schemes","IntentData") or "";
end

function SchemesProxy.clearIntentData()
    call_native("clearIntentData");
end

function SchemesProxy.onSchemesEvent(controler)
    local str = SchemesProxy.getIntentData();
    Log.i("SchemesProxy onSchemesEvent :".. (str or "nil") );
    SchemesProxy.clearIntentData();
    event = SchemesProxy.analyzeSchemesStr(str,true,controler);
    if type(event) == "function" then
        event();
    end
end

function SchemesProxy.analyzeSchemesStr(str,isNotEncode,controler)
    local url = require("libs/url");
    local u = url.parse(str);
    if u.scheme ~= SchemesProxy.SCHEMA then return end
    local data = u.query;
    if type(data) ~= "table" or data.isEncode == nil then return end

    if data.method then
        local method = data.method;
        if method == "gotoCustomEndgateRoom" then
            local params = data;
            if type(params) == 'table' then
                return function()
                        kEndgateData:setPlayCreateEndingData(params);
                        StateMachine.getInstance():pushState(States.playCreateEndgate,StateMachine.STYPE_CUSTOM_WAIT);
                    end,data;
            end
        elseif method == "gotoPrivateRoom" then
            local params = data;
            if type(params) == 'table' then
                return function()
                        if RoomProxy.getInstance():getCurRoomType() ~= RoomConfig.ROOM_TYPE_NULL then
                            ChessToastManager.getInstance():showSingle("游戏房间内不支持跳转!")
                            return 
                        end
                        -- 私人房大厅特殊处理
                        if controler ~= nil and typeof(controler,PrivateController) then
                            Log.i("SchemesProxy loginStartCustomRoom");
                            if controler.m_view and controler.m_view.loginStartCustomRoom then
                                RoomProxy.getInstance():setTid(params.tid);
                                controler.m_view:loginStartCustomRoom(params.pwd);
                            end
                        else
                            StateMachine.getInstance():pushState(States.PrivateHall,StateMachine.STYPE_CUSTOM_WAIT);
                            PrivateScene.setGotoRoom(params.tid,params.pwd);
                        end
                    end,data;
            end
        elseif method == "gotoMoneyRoom" then
            return function()
                        if RoomProxy.getInstance():getCurRoomType() ~= RoomConfig.ROOM_TYPE_NULL then
                            ChessToastManager.getInstance():showSingle("游戏房间内不支持跳转!")
                            return 
                        end
                        if UserInfo.getInstance():isFreezeUser() then return end;
                        StateMachine.getInstance():pushState(States.Compete,StateMachine.STYPE_CUSTOM_WAIT)
                    end,data;
        elseif method == "showSociatyInfoDialog" then
            return function()
                        SociatyModuleData.getInstance():onCheckSociatyData2(data.sociaty_id)
                    end,data;
        elseif method == "goto" then
            local params = data;
            if type(params) == 'table' then
                return function()
                        if RoomProxy.getInstance():getCurRoomType() ~= RoomConfig.ROOM_TYPE_NULL then
                            ChessToastManager.getInstance():showSingle("游戏房间内不支持跳转!")
                            return 
                        end
                        local jumpScene = params.jumpScene;
                        if jumpScene and jumpScene ~= 0 and StatesMap[jumpScene] then
                            if tonumber(jumpScene) == States.Friends then
                                TaskScene.s_showRelationshipDialog()
                                return
                            elseif tonumber(jumpScene) == States.Replay then
                                TaskScene.s_showReplayDialog()
                                return
                            end
                            StateMachine.getInstance():pushState(jumpScene,StateMachine.STYPE_CUSTOM_WAIT);
                        end
                    end,data;
            end
        end
    end
end
--[Comment]
-- 参数不准有中文  中文容易超包体
function SchemesProxy.getMySchemesUrl(tab)
    local url = require("libs/url");
    local params = Copy(tab)
    params.isEncode = 0
    params.uid = UserInfo.getInstance():getUid();
    local u = url.parse(SchemesProxy.HOST);
    u:setQuery(params);
    return u:build();
end

--[Comment]
-- 参数不准有中文  中文容易超包体
function SchemesProxy.getWebSchemesUrl(tab)
    local url = require("libs/url");
    local params = Copy(tab);
    params.isEncode = 0
    params.uid = UserInfo.getInstance():getUid();
    _,params.down_url = UserInfo.getInstance():getGameShareUrl();
    local u = url.parse(UserInfo.getInstance():getInviteFriendsUrl());
    u:addQuery(params);
    return u:build();
end

SchemesProxy.KEY = "boyaachess";

function SchemesProxy.encodeStr(str)
    if type(str) ~= "string" then return "" end
    local len = #str;
    local charTab = { string.byte(str,1,len) };
    Log.i( table.concat(charTab," "));
    local keyTab = { string.byte(SchemesProxy.KEY,1, string.len(SchemesProxy.KEY)) };
    local ret = {};
    local i = 1;
    local j = 1;
    while next(charTab) do
        local char = table.remove(charTab,1);
        ret[2*i-1] = bit.bxor(char,keyTab[j]);
        ret[2*i] = keyTab[j];
        i = i+1;
        j = j+1;
        if j > #keyTab then
            j = 1;
        end
    end
    Log.i( table.concat(ret," "));
    return string.char(unpack(ret));
end

function SchemesProxy.decodeStr(str)
    if type(str) ~= "string" then return "" end
    local len =  #str;
    local charTab = { string.byte(str,1,len) };
    Log.i( table.concat(charTab," "));
    local keyTab = { string.byte(SchemesProxy.KEY,1, string.len(SchemesProxy.KEY)) };
    local ret = {};
    local i = 1;
    local j = 1;
    while next(charTab) do
        local char = table.remove(charTab,1);
        table.remove(charTab,1)
        ret[i] = bit.bxor(char,keyTab[j]);
        i = i+1;
        j = j+1;
        if j > #keyTab then
            j = 1;
        end
    end
    Log.i( table.concat(ret," "));
    return string.char(unpack(ret));
end

function SchemesProxy.ToBase64(source_str)
    local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local s64 = ''
    local str = source_str

    while #str > 0 do
        local bytes_num = 0
        local buf = 0

        for byte_cnt=1,3 do
            buf = (buf * 256)
            if #str > 0 then
                buf = buf + string.byte(str, 1, 1)
                str = string.sub(str, 2)
                bytes_num = bytes_num + 1
            end
        end

        for group_cnt=1,(bytes_num+1) do
            b64char = math.fmod(math.floor(buf/262144), 64) + 1
            s64 = s64 .. string.sub(b64chars, b64char, b64char)
            buf = buf * 64
        end

        for fill_cnt=1,(3-bytes_num) do
            s64 = s64 .. '='
        end
    end

    return s64
end

function SchemesProxy.FromBase64(str64)
    local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local temp={}
    for i=1,64 do
        temp[string.sub(b64chars,i,i)] = i
    end
    temp['=']=0
    local str=""
    for i=1,#str64,4 do
        if i>#str64 then
            break
        end
        local data = 0
        local str_count=0
        for j=0,3 do
            local str1=string.sub(str64,i+j,i+j)
            if not temp[str1] then
                return
            end
            if temp[str1] < 1 then
                data = data * 64
            else
                data = data * 64 + temp[str1]-1
                str_count = str_count + 1
            end
        end
        for j=16,0,-8 do
            if str_count > 0 then
                str=str..string.char(math.floor(data/math.pow(2,j)))
                data=math.mod(data,math.pow(2,j))
                str_count = str_count - 1
            end
        end
    end
    return str
end

function SchemesProxy.decodeURI(s)
    s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
    return s
end

function SchemesProxy.encodeURI(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end
