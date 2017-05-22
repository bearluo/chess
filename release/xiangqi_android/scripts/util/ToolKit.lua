
require("core/constants");
require("core/object");
require("util/online_config");
require("util/endgate_config");

ToolKit = {};

-- 将long转换成:xx年xx月xx日xx时xx分xx秒格式
ToolKit.getTimeYMD = function(time)
    local days = "";
    if time and tonumber(time) then
        local timeNum = tonumber(time);
        timeNum = math.abs(timeNum);
        local str = "%Y" .. string_get("yearStr") .. "%m" .. string_get("mouthStr") .. "%d" .. string_get("dayStr") .. "%H" .. string_get("hourStr") .. "%M" .. string_get("minStr") .. "%S".. string_get("secStr");
        days = os.date(str,timeNum);
    end
    return days;
end

-- 将long转换成:xx月xx日xx:xx:xx格式
ToolKit.getTimeMDHMS = function(time)
    local days = "";
    if time and tonumber(time) then
        local timeNum = tonumber(time);
        timeNum = math.abs(timeNum);
        local str = "%m" .. string_get("mouthStr") .. "%d" .. string_get("dayStr") .. "%H" .. ":%M" .. ":%S";
        days = os.date(str,timeNum);
    end
    return days;
end

-- 拆分时间：00时:00分:00秒
ToolKit.skipTime = function(time)
    local times = nil;
    if time then
        local timeNum = tonumber(time);
        if timeNum and timeNum > 0 then
            local hour = os.date("*t",timeNum).hour - 8;
            local min  = os.date("*t",timeNum).min;
            local sec  = os.date("*t",timeNum).sec;

            hour = string.format("%02d",hour);
            min = string.format("%02d",min);
            sec = string.format("%02d",sec);
            times = hour .. ":" .. min .. ":" .. sec;
        end
    end
    return times or " " or string_get("initTimeStr") ;
end

-- 拆分时间：00时:00分
ToolKit.skipTimeHM = function(time)
    local times = nil;
    if time then
        local timeNum = tonumber(time);
        if timeNum and timeNum > 0 then
            local hour = os.date("*t",timeNum).hour - 8;
            local min  = os.date("*t",timeNum).min;

            hour = string.format("%02d",hour);
            min = string.format("%02d",min);
            times = hour .. ":" .. min;
        end
    end
    return times or string_get("initTimeStr");
end

-- 是否是隔天消息
ToolKit.isSecondDay = function(time)
    if not time then
        return true;
    end;
    local currentTime = os.time();
    local lastSendTime = time;
    if tonumber(os.date("%Y",lastSendTime)) == tonumber(os.date("%Y",currentTime)) then
       if tonumber(os.date("%m",lastSendTime)) == tonumber(os.date("%m",currentTime)) then
            if tonumber(os.date("%d",lastSendTime)) == tonumber(os.date("%d",currentTime)) then
                return false;
            elseif tonumber(os.date("%d",lastSendTime)) < tonumber(os.date("%d",currentTime)) then
                return true;
            end;
       elseif tonumber(os.date("%m",lastSendTime)) < tonumber(os.date("%m",currentTime)) then
            return true;
       end;
    elseif tonumber(os.date("%Y",lastSendTime)) < tonumber(os.date("%Y",currentTime)) then 
        return true;
    end;    
end;


-- 两条发送的消息是否在10分钟内（时间可以自由设置）
ToolKit.isInTenMinute = function(lastSendTime, currentTime)
    if not lastSendTime then
        return false;
    end;
    if tonumber(os.date("%H",lastSendTime)) == tonumber(os.date("%H",currentTime)) then
        if tonumber(os.date("%M",lastSendTime)) == tonumber(os.date("%M",currentTime)) then
            return true;
        elseif math.abs(tonumber(os.date("%M",lastSendTime)) - tonumber(os.date("%M",currentTime))) <= 1 then--是否在3分钟内
            return true;
        else
            return false;
        end;
    else
        return false;
    end;
end;


-- 获得易识别的时间格式，如“50分钟以前”
ToolKit.getEasyTime = function(time)
    local curTime = os.time();
    if tonumber(os.date("%Y",time)) == tonumber(os.date("%Y",curTime)) then
       if tonumber(os.date("%m",time)) == tonumber(os.date("%m",curTime)) then
            if tonumber(os.date("%d",time)) == tonumber(os.date("%d",curTime)) then
                if tonumber(os.date("%H",time)) == tonumber(os.date("%H",curTime)) then
                    if tonumber(os.date("%M",time)) <= tonumber(os.date("%M",curTime)) then
                        if tonumber(os.date("%M",curTime)) - tonumber(os.date("%M",time)) < 10 then
                            return "刚刚";
                        else
                            return tonumber(os.date("%M",curTime)) - tonumber(os.date("%M",time)).."分钟以前";
                        end;
                    end;
                elseif tonumber(os.date("%H",time)) < tonumber(os.date("%H",curTime)) then
                    return tonumber(os.date("%H",curTime)) - tonumber(os.date("%H",time)).."小时以前";
                end;
                
            elseif tonumber(os.date("%d",time)) < tonumber(os.date("%d",curTime)) then
                if (tonumber(os.date("%d",curTime)) - tonumber(os.date("%d",time))) == 1 then
                    return "昨天"
                else
                    return os.date("%Y-%m-%d",time);
                end;
            end;
        elseif tonumber(os.date("%m",time)) < tonumber(os.date("%m",curTime)) then
            return os.date("%Y-%m-%d",time); 
        end;
    elseif tonumber(os.date("%Y",time)) < tonumber(os.date("%Y",curTime)) then 
        return os.date("%Y-%m-%d",time);
    end;    

end;
--拆分金币每3位用逗号隔开
ToolKit.skipMoney = function(curMoney)
    local moneyStr = nil;
    if curMoney and tonumber(curMoney) then
        local money = curMoney .. "";
        if tonumber(curMoney) < 0 then
            money = string.sub(money .. "", 2, #money)
        end
        local length = #money;
        local spead = 1;
        for i=length,0, -3 do
            local x = length - spead*3 + 1;
            if x < 1 then
                x=1;
            end
            if moneyStr then
                moneyStr = string.sub(money, x, length - (spead-1)*3) .. "," .. moneyStr;
            else
                moneyStr = string.sub(money, x, length - (spead-1)*3);
            end
            spead = spead +1;
        end
        if string.sub(moneyStr, 1, 1) == "," then
            moneyStr = string.sub(moneyStr, 2, #moneyStr);
        end

        if tonumber(curMoney) < 0 then
            moneyStr = "-"..moneyStr;
        end
    end
    if not moneyStr then
        moneyStr = curMoney;
    end
    return moneyStr;
end

--重置图层显示
ToolKit.resetLayerVisible = function(layer,endLayer)
    print_string("layer=" .. layer);
    if layer then
        local start = 1;
        local endIndex = layer;
        if endLayer then
            start = layer;
            endIndex = endLayer;
        end
        for i=start,endIndex do 
            layer_set_visible(i,1);
        end
    end
end

--重置图层可拾取
ToolKit.resetPickable = function(layer,endLayer)
    if layer then
        local start = 1;
        local endIndex = layer;
        if endLayer then
            start = layer;
            endIndex = endLayer;
        end
        for i=start,endIndex do 
            layer_set_pickable(i,1);
        end
    end
end

--设置图层不可拾取
ToolKit.setPickEnable = function(startlayer,endLayer)
    if startlayer and endLayer then
        for i=startlayer,endLayer do 
            layer_set_pickable(i,0);
        end
    end
end

--创建一个Images
ToolKit.createImgs = function(obj,imgFile,startId,endId,diffRect,layer)
    local img = new(Images,imgFile,startId,endId);
    ToolKit.setElemRect(obj,img,diffRect);
    img.m_drawing:setLayer(layer);                     
    img:create();
    return img;
end

--创建一个Image
ToolKit.createImg = function(obj,imgFile,diffRect,layer)
    local img = new(Image,imgFile);
    ToolKit.setElemRect(obj,img,diffRect);
    img.m_drawing:setLayer(layer);
    img:create();
    return img;
end

--创建一个Button
ToolKit.createBtn = function(obj,imgFile,diffRect,layer)
    local btn = new(Button,imgFile);
    ToolKit.setElemRect(obj,btn,diffRect);
    btn:setLayer(layer);
    btn:create();
    return btn;
end

--创建一个Button2
ToolKit.createBtn2 = function(obj,imgFile,file_disable,diffRect,layer)
    local btn = new(Button2,imgFile,file_disable);
    ToolKit.setElemRect(obj,btn,diffRect);
    btn:setLayer(layer);
    btn:create();
    return btn; 
end

--创建一个Text 
ToolKit.createTex = function(obj,mData,diffRect,layer)
    local text = new(Text,unpack(mData));
    ToolKit.setElemRect(obj,text,diffRect);
    text:setLayer(layer);
    text:create();
    return text;
end

--创建一个EditText 
ToolKit.createEditTex = function(obj,mData,diffRect,layer)
    local editTex = new(EditText,unpack(mData));
    ToolKit.setElemRect(obj,editTex,diffRect);
    editTex:setLayer(layer);
    editTex:create();
    return editTex;
end

--创建一个TextView 
ToolKit.createTextView = function(obj,mData,diffRect,layer)
    local text = new(TextView,unpack(mData));
    ToolKit.setElemRect(obj,text,diffRect);
    text:setLayer(layer);
    text:create();
    return text;
end

--设置element区域
ToolKit.setElemRect = function(obj,element,diffRect)
    if diffRect.w and diffRect.h then
        element:setRect(obj.m_x+diffRect.x,obj.m_y+diffRect.y, diffRect.w, diffRect.h);
    else
        element:setRect(obj.m_x+diffRect.x,obj.m_y+diffRect.y);
    end
end

--获取utf8字符串的子字符串
ToolKit.utf8_substring = function(str, first, num)
	local ret = "";
	
	local n = string.len(str);
	local offset = 1;
	local cp;
	local b, e;
	local i = 1;
	while i <= n do
		if not b and offset >= first then
			b = i;
		end;
		if not e and offset >= first + num then
			e = i;
			break;
		end;
		cp = string.byte(str, i);
		if cp >= 0xF0 then
			i = i + 4;
			offset = offset + 2;
		elseif cp >= 0xE0 then
			i = i + 3;
			offset = offset + 2;
		elseif cp >= 0xC0 then
			i = i + 2;
			offset = offset + 2;
		else
			i = i + 1;
			offset = offset + 1;
		end;
	end;
	
	if not b then
		return "";
	end;
	
	if not e then
		e = n + 1;
	end;
	
	ret = string.sub(str, b, e-b);

	return ret;
end;

ToolKit.subString = function(str,strMaxLen)
	if nil == str then
		return "";
	end
	return ToolKit.utf8_substring(str, 1, strMaxLen);
end

ToolKit.utf8_len = function(str)
    local n = string.len(str);
    local utf_count = 0;
    local cn, en = 0, 0
    local p_byte;
    local i = 1;
    while i <= n do
        p_byte = string.byte(str, i);
        if p_byte >= 0xF0 then
            i = i + 4;
            utf_count = utf_count + 1;
            cn = cn + 1
        elseif p_byte >= 0xE0 then
            i = i + 3;
            utf_count = utf_count + 1;
            cn = cn + 1
        elseif p_byte >= 0xC0 then
            i = i + 2;
            utf_count = utf_count + 1;
            cn = cn + 1
        else
            i = i + 1;
            utf_count = utf_count + 1;
            en = en + 1
        end;
    end;

    return utf_count, cn, en;
end

-- 用来截取utf8字符串
-- utf8_sub("hi你好", 1, 3) --> hi你
-- utf8_sub("hi你好", 4, 4) --> 好 
ToolKit.utf8_sub = function(str, u_start, u_end)
    local ret = "";

    local n = string.len(str);
    local offset = 1;
    local cp;
    local b, e;
    local i = 1;
    while i <= n do
        if not b and offset >= u_start then
            b = i;
        end;
        
        cp = string.byte(str, i);
        if cp >= 0xF0 then
            i = i + 4;
        elseif cp >= 0xE0 then
            i = i + 3;
        elseif cp >= 0xC0 then
            i = i + 2;
        else
            i = i + 1;
        end;
        offset = offset + 1;


        if not e and offset > u_end then
            e = i-1;
            break;
        end;
    end;
    
    if not b then
        return "",0;
    end;

    if not e then
        e = n;
    end;

    ret = string.sub(str, b, e);

    return ret,offset-1;
end

ToolKit.split = function(str, delim, maxNb)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
        return { str }
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0    -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gfind(str, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end
    -- Handle the last field
    if nb ~= maxNb then
        result[nb + 1] = string.sub(str, lastPos)
    end
    return result;
end

ToolKit.formatNick = function(nick)
	local subStr = ToolKit.subString(nick, 8);
	if subStr == "" then
	elseif subStr ~= nick then
		subStr = subStr .. "."
	end;
	return subStr;
end

ToolKit.weakValues = {};
setmetatable(ToolKit.weakValues, {__mode="v"});

-- 提示登录
ToolKit.showDialog = function(_title,_msg,left,_leftCmd,right,_rightCmd,callback,own)
	if ToolKit.dialog then
		delete(ToolKit.dialog);
		ToolKit.dialog = nil;
	end;
	ToolKit.weakValues.dialogOwn = own;
	ToolKit.weakValues.dialogCallback = callback; 
	local data = {title=_title,leftStr=left,leftCmd=_leftCmd,rightStr=right,rightCmd=_rightCmd,msgStr=msg};
	ToolKit.dialog = new(Dialog,data);
	ToolKit.dialog:create();
	ToolKit.dialog:setCallBackClick(nil,ToolKit.dialogCallback);
end

ToolKit.dialogCallback = function(self,param)
	if ToolKit.dialog then
		delete(ToolKit.dialog);
		ToolKit.dialog = nil;
	end;
	if ToolKit.weakValues.dialogCallback then
		ToolKit.weakValues.dialogCallback(ToolKit.weakValues.Own, param);
	end;
end;


ToolKit.setDebugName = function( obj , name)
   if obj then
        obj:setDebugName(name);
   end 
end


--获取从头开始的指定长度的子字符串，可以避免子字符串末尾处中文乱码问题
--str：源字符串
--count：子字符串长度
--return：子字符串，无需进行转码，即可显示
ToolKit.getSubStr = function ( str,count )
    if str=="" then
        return str;
    end
    local s=GameString.convert2UTF8(str);
    local i=1;
    local cn={};
    while i<=string.len(s) do
        local ss=string.sub(s,1,i);
        local len=string.lenutf8(ss);
        if len+#cn*2<i then
            table.insert(cn,i);
            i=i+3;
        else
            i=i+1;
        end
    end
    for i=1,#cn do
        cn[i]=cn[i]-(i-1);
        if cn[i]==count then
            count=count-1;
            break;
        end
    end
    return string.sub(GameString.convert(s),1,count);
end

ToolKit.getNumFromJsonTable = function(tb,key,default)
    local ret = default;
    if tb[key] ~= nil then
        if tb[key]:get_value() ~= nil then
            ret = tonumber(tb[key]:get_value());
            if ret == nil then
                ret = default;
            end
        end
    end
    return ret;
end

ToolKit.getStrFromJsonTable = function(tb,key,default)
    local ret;
    if tb[key] ~= nil then
        if tb[key]:get_value() ~= nil then
            ret = tb[key]:get_value();
            if string.len(ret)  == 0 then
                ret = default;
            end
        end
    end
    return ret;
end

ToolKit.copyTable = function(tb)
    local t = {};
    
    for key,value in pairs(tb) do
        t[key] = value
    end

    return t;
end


ToolKit.getSubUtf8String = function(inputStr,subLen)
    if inputStr then
        return string.subutf8(inputStr,1,subLen) .. "...";  --英文
    else
        return inputStr;
    end
     
    -- return (self.m_name == nil or self.m_name == "") and  or string.sub(self.m_name,1,8);
end

ToolKit.isStrAllEnglish = function(inputStr)
    if inputStr then
        local len = string.len(inputStr);
        local lenutf8 = string.lenutf8(inputStr);
        if len == lenutf8 then
            return true;
        else
            return false;
        end
    end

    return false;
end

--判断是否包含特殊字符 返回true则包含
ToolKit.isContainSpecialChar = function(inputStr)
    local charStr = "~@#%+-=\/\(_\)\*\&\<\>\[\"\;\'\|\$\^\?\!.\{\}\`/\, ";
    local len = string.len(charStr);

    for i=1,len do
        local str = string.sub(charStr, i, i)--取出每一个特殊字符
        local k, j = string.find(inputStr, "%"..str);
        if k~=nil and j~=nil then
            return true
        end
    end
    return false;
end

ToolKit.getCacheGoodsList = function(isMallGetProp)
    local dataList = {};

    local Prop_List = GameCacheData.PROP_LIST;
    if PhpInfo.getBid() then
        Prop_List = Prop_List..PhpInfo.getBid();
    end

    local propsListStr =  GameCacheData.getInstance():getString(Prop_List,"");
    dataList = json.decode(propsListStr);
    return dataList;
end

ToolKit.getExchangePropList = function()
    local dataList = {};

    local exchange_prop_List = GameCacheData.NEW_PROP_LIST;
    if PhpInfo.getBid() then
        exchange_prop_List = exchange_prop_List..PhpInfo.getBid();
    end
    local propsListStr = GameCacheData.getInstance():getString(exchange_prop_List,"");

    local goodsData = json.decode(propsListStr);

    if goodsData then

        for _,v in pairs(goodsData) do 
        
            local prop  = {};
            prop.id                         = v.id or 0;
            prop.desc                       = v.desc or "";
            prop.goods_type                 = v.goods_type or 0
            prop.exchange_type              = v.exchange_type or 0;
            prop.name                       = v.name or "";
            prop.goods_num                  = v.goods_num or 0;
            prop.exchange_num               = v.exchange_num or 0;

            -- print_string("========prop.id====="..prop.id);      
            -- print_string("========prop.desc====="..prop.desc);
            -- print_string("========prop.goods_type====="..prop.goods_type);
            -- print_string("========prop.exchange_type====="..prop.exchange_type);
            -- print_string("========prop.name====="..prop.name);
            -- print_string("========prop.goods_num====="..prop.goods_num);
            -- print_string("========prop.exchange_num====="..prop.exchange_num);

            table.insert(dataList,prop);
        end
    end


    return dataList;
end

ToolKit.getModelistItemKV = function(modelist,root_view)
    local itemKV = ToolKit.split(modelist,"|"); 
    local itemsKV ={};

    if table.maxn(itemKV)<=0 then
        local message = "获取商品信息失败！"
        ShowMessageAnim.play(root_view,message);
        
        local Prop_Version = GameCacheData.PROP_LIST_VERSION;
        if PhpInfo.getBid() then
            Prop_Version = Prop_Version..PhpInfo.getBid();
        end
        GameCacheData.getInstance():saveInt(Prop_Version,0);
        PHPInterface.getPropList();
        return;
    end

    for i,v in ipairs(itemKV) do
        local itemV = ToolKit.split(v,":");
        local temp = {};
        temp.mode = tonumber(itemV[1]);
        temp.goodId = itemV[2];
        table.insert(itemsKV,temp);
    end

    return itemsKV;
end

ToolKit.getCacheOnlineUndoList = function()
    local dataList = {};

    local undo_List = GameCacheData.ONLINE_UNDOSS_LIST;
    if PhpInfo.getBid() then
        undo_List = undo_List..PhpInfo.getBid();
    end

    local undo_list_str =  GameCacheData.getInstance():getString(undo_List,"");
    local undoListTB = ToolKit.split(undo_list_str,","); 
    
    for i,v in ipairs(undoListTB) do
        local undo = {};
        undo =  value;
        table.insert(dataList,undo);
    end

    return dataList;
end
--清理每日任务数据
ToolKit.clearDailyWorkLog = function()
    local dateText = os.date("%d"); 
    local  uid = UserInfo.getInstance():getUid();

    local logdate = GameCacheData.getInstance():getInt(GameCacheData.DAILY_WORK_LOG_DATE..uid,0);
    local date = tonumber(dateText);

    if date ~= logdate then
          GameCacheData.getInstance():saveInt(GameCacheData.DAILY_WORK_LOG_DATE..uid,date);
          GameCacheData.getInstance():saveInt(GameCacheData.ENDGATE_PLAY_COUNT..uid,0);
          GameCacheData.getInstance():saveInt(GameCacheData.ONLINE_GAME_PLAY_COUNT..uid,0);

          GameCacheData.getInstance():saveBoolean(GameCacheData.IS_ENDGATE_PLAY_REWARD..uid,false);
          GameCacheData.getInstance():saveBoolean(GameCacheData.IS_ONLINE_GAME_PLAY_REWARD..uid,false);
    end
end

ToolKit.saveEngateLogCount = function(progress)
    local dateText = os.date("%d"); 
    local uid = UserInfo.getInstance():getUid();
    local date = tonumber(dateText);
    GameCacheData.getInstance():saveInt(GameCacheData.DAILY_WORK_LOG_DATE..uid,date);

    GameCacheData.getInstance():saveBoolean(GameCacheData.IS_ENDGATE_PLAY_REWARD..uid,false);
    GameCacheData.getInstance():saveInt(GameCacheData.ENDGATE_PLAY_COUNT..uid,progress);
end

ToolKit.saveOnlineGameLogCount = function(progress)
    local dateText = os.date("%d"); 
    local uid = UserInfo.getInstance():getUid();
    local date = tonumber(dateText);
    GameCacheData.getInstance():saveInt(GameCacheData.DAILY_WORK_LOG_DATE..uid,date);

    GameCacheData.getInstance():saveBoolean(GameCacheData.IS_ONLINE_GAME_PLAY_REWARD..uid,false);
    GameCacheData.getInstance():saveInt(GameCacheData.ONLINE_GAME_PLAY_COUNT..uid,progress);
end

ToolKit.addEngateLogCount = function(root_view)

    ToolKit.clearDailyWorkLog();
    local  uid = UserInfo.getInstance():getUid();
    local engateCount = GameCacheData.getInstance():getInt(GameCacheData.ENDGATE_PLAY_COUNT..uid,0);
    local workNum = EndGateConfig.getInstance():getEngateDailyWork();

    GameCacheData.getInstance():saveInt(GameCacheData.ENDGATE_PLAY_COUNT..uid,engateCount+1);
    engateCount = engateCount+1;

    if engateCount >= workNum  and workNum ~= 0 then
        local is_reward =  GameCacheData.getInstance():getBoolean(GameCacheData.IS_ENDGATE_PLAY_REWARD..uid,true);
        if not is_reward then
            local message  = "你已玩了"..workNum.."关以上的残局，完成任务！请前往每日任务领取奖励";
            ChatMessageAnim.play(root_view,3,message);
        end
        
        return;
    end
end

ToolKit.addOnlineGameLogCount = function(root_view)
    ToolKit.clearDailyWorkLog();
    local  uid = UserInfo.getInstance():getUid();

    local onlineCount = GameCacheData.getInstance():getInt(GameCacheData.ONLINE_GAME_PLAY_COUNT..uid,0);
    local workNum = OnlineConfig.getInstance():getOnlineGameDailyWork();

    GameCacheData.getInstance():saveInt(GameCacheData.ONLINE_GAME_PLAY_COUNT..uid,onlineCount+1);
    onlineCount = onlineCount+1;

    local totalOnlineCount = GameCacheData.getInstance():getInt(GameCacheData.ONLINE_PLAY_TIMES,0);
    GameCacheData.getInstance():saveInt(GameCacheData.ONLINE_PLAY_TIMES,totalOnlineCount + 1);

    if onlineCount >= workNum and workNum ~= 0 then
        local is_reward =  GameCacheData.getInstance():getBoolean(GameCacheData.IS_ONLINE_GAME_PLAY_REWARD..uid,true);
        if not is_reward then
            local message  = "你已玩了"..workNum.."关以上的联网游戏，完成任务！请前往每日任务领取奖励";
            ChatMessageAnim.play(root_view,3,message);
        end
        return;
    end

end

require("animation/chatMessageAnim");
require("animation/showMessageAnim");
require("animation/broadcastMessageAnim");

ToolKit.removeAllTipsDialog = function()
    ShowMessageAnim.reset();
    ShowMessageAnim.deleteAll();
    ChatMessageAnim.deleteAll();    
    BroadcastMessageAnim.deleteAll(); 
    DaozhangMessageAnim.deleteAll();
  
end


ToolKit.getMoneyStr = function(num)
    if not num then return 0 end;
    num = tonumber(num);
    if not num then return "0.00" end
    if num > 100000 then
        if num > 100000000 then
            return string.format("%dW",math.floor(num/10000))
        end
        if num > 10000000 then
            return string.format("%.1fW",math.floor(num/1000)/10)
        end
        return string.format("%.2fW",math.floor(num/100)/100);
    end
    return num;
end


-- 数字(int)转换成对应数字图片
-- num:要转换的数字
-- img:数字后面接的img,例如：“金币”，“连胜”.
-- imgtype:目前只有“金币”，“连胜”两种;两者区别：图片资源位置不同；金币前有“+/-”号
-- return:num和img拼接的新img.如果img为nil,则只返回转换后的num
-- ps:针对animation/目录下的资源
ToolKit.int2img = function(num, img, showtype)
    if not tonumber(num) then return end; 
    local newImg = new(Node);
    local numStr = tostring(num);
    local digit = string.len(numStr);
    local newImgW = 0;
    if showtype == 1 then -- 1 N连胜，2 +/-金币,3 +/-积分, 4 纯数字
        local preImg = nil;
        while(digit > 0) do
            local tempNum = math.floor(num / math.pow(10,digit - 1));
            num = num % math.pow(10,digit - 1);
            local tempImg = new(Image,"animation/"..tempNum..".png");
            if not preImg then
                preImg = tempImg;
            else
                local w, h = preImg:getSize();
                newImgW = newImgW + w - 10;
                tempImg:setPos(newImgW,nil);
                preImg = tempImg;
            end;
            newImg:addChild(tempImg);
            digit = digit - 1;
        end; 
        newImgW = newImgW + 66;
        local imgW,imgH = 0,0;
        if img then
            img:setPos(newImgW);
            newImg:addChild(img);
            imgW,imgH = img:getSize();
        end;
        newImg:setSize(newImgW + imgW);
        return newImg;    
    elseif showtype == 2 then --金币
        local positive = true;--是否正数,默认是
        local preImg = nil;
        if string.sub(numStr,1,1) == "+" then
            digit = digit - 1;
            preImg = new(Image,"animation/account/+gold.png");
            positive = true;
        elseif string.sub(numStr,1,1) == "-" then
            digit = digit - 1;
            preImg = new(Image,"animation/account/_gray.png");
            positive = false;
            num = -num;
        else
            preImg = new(Image,"animation/account/+gold.png");
        end;
        newImg:addChild(preImg);
        while(digit > 0) do
            local tempNum = math.floor(num / math.pow(10,digit - 1));
            num = num % math.pow(10,digit - 1);
            local tempImg = nil;
            if positive then
                tempImg = new(Image,"animation/account/"..tempNum.."gold.png");
            else
                tempImg = new(Image,"animation/account/"..tempNum.."gray.png");
            end;
            if not preImg then
                preImg = tempImg;
            else
                local w, h = preImg:getSize();
                newImgW = newImgW + w + 2;
                tempImg:setPos(newImgW,nil);
                preImg = tempImg;
            end;
            newImg:addChild(tempImg);
            digit = digit - 1;
        end; 
        newImgW = newImgW + 33 + 2;--33数字资源的宽，2两数字图片之间可调节的距离
        local imgW,imgH = 0,0;
        if img then
            img:setPos(newImgW);
            newImg:addChild(img);
            imgW,imgH = img:getSize();
        end;
        newImg:setSize(newImgW + imgW);
        return newImg;  
    elseif showtype == 3 then -- 积分
        local positive = true;--是否正数,默认是
        local preImg = nil;
        if string.sub(numStr,1,1) == "+" then
            digit = digit - 1;
            preImg = new(Image,"animation/account/+yellow.png");
            positive = true;
        elseif string.sub(numStr,1,1) == "-" then
            digit = digit - 1;
            preImg = new(Image,"animation/account/_gray.png");
            positive = false;
            num = -num;
        else
            preImg = new(Image,"animation/account/+yellow.png");
        end;
        newImg:addChild(preImg);
        while(digit > 0) do
            local tempNum = math.floor(num / math.pow(10,digit - 1));
            num = num % math.pow(10,digit - 1);
            local tempImg = nil;
            if positive then
                tempImg = new(Image,"animation/account/"..tempNum.."yellow.png");
            else
                tempImg = new(Image,"animation/account/"..tempNum.."gray.png");
            end;
            if not preImg then
                preImg = tempImg;
            else
                local w, h = preImg:getSize();
                newImgW = newImgW + w + 2;
                tempImg:setPos(newImgW,nil);
                preImg = tempImg;
            end;
            newImg:addChild(tempImg);
            digit = digit - 1;
        end; 
        newImgW = newImgW + 33 + 2;--33数字资源的宽，2两数字图片之间可调节的距离
        local imgW,imgH = 0,0;
        if img then
            img:setPos(newImgW);
            newImg:addChild(img);
            imgW,imgH = img:getSize();
        end;
        newImg:setSize(newImgW + imgW);
        return newImg;
    elseif showtype == 4 then -- 纯数字
        local positive = true;--是否正数,默认是
        local preImg = nil;
        if string.sub(numStr,1,1) == "+" then
            digit = digit - 1;
            preImg = new(Image,"animation/account/+.png");
            newImg:addChild(preImg);
            positive = true;
        elseif string.sub(numStr,1,1) == "-" then
            digit = digit - 1;
            preImg = new(Image,"animation/account/_gray.png");
            newImg:addChild(preImg);
            positive = false;
            num = -num;
        end;
        while(digit > 0) do
            local tempNum = math.floor(num / math.pow(10,digit - 1));
            num = num % math.pow(10,digit - 1);
            local tempImg = nil;
            if positive then
                tempImg = new(Image,"animation/account/"..tempNum..".png");
            else
                tempImg = new(Image,"animation/account/"..tempNum.."gray.png");
            end;
            if not preImg then
                preImg = tempImg;
            else
                local w, h = preImg:getSize();
                newImgW = newImgW + w + 2;
                tempImg:setPos(newImgW,nil);
                preImg = tempImg;
            end;
            newImg:addChild(tempImg);
            digit = digit - 1;
        end; 
        newImgW = newImgW + 33 + 2;--33数字资源的宽，2两数字图片之间可调节的距离
        local imgW,imgH = 0,0;
        if img then
            img:setPos(newImgW);
            newImg:addChild(img);
            imgW,imgH = img:getSize();
        end;
        newImg:setSize(newImgW + imgW);
        return newImg;          
    else--后续可拓展其他的imgtype
        
    end;
end;

--- 获取utf8编码字符串正确长度的方法
-- @param str
-- @return number
ToolKit.utfstrlen = function(str)
    local len = #str;
    local left = len;
    local cnt = 0;
    local arr={0,0xc0,0xe0,0xf0,0xf8,0xfc};
    while left ~= 0 do
        local tmp=string.byte(str,-left);
        local i=#arr;
        while arr[i] do
            if tmp>=arr[i] then left=left-i;break;end
            i=i-1;
        end
    cnt=cnt+1;
    end
    return cnt;
end

--@brief 切割字符串，并用“...”替换尾部
--@param sName:要切割的字符串
--@return nMaxCount，字符串上限,中文字为2的倍数
--@param nShowCount：显示英文字个数，中文字为2的倍数,可为空
--@note         函数实现：截取字符串一部分，剩余用“...”替换
ToolKit.GetShortName = function(sName,nMaxCount,nShowCount)
    if sName == nil or nMaxCount == nil then
        return
    end
    local sStr = sName
    local tCode = {}
    local tName = {}
    local nLenInByte = #sStr
    local nWidth = 0
    if nShowCount == nil then
       nShowCount = nMaxCount - 3
    end
    for i=1,nLenInByte do
        local curByte = string.byte(sStr, i)
        local byteCount = 0;
        if curByte>0 and curByte<=127 then
            byteCount = 1
        elseif curByte>=192 and curByte<223 then
            byteCount = 2
        elseif curByte>=224 and curByte<239 then
            byteCount = 3
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4
        end
        local char = nil
        if byteCount > 0 then
            char = string.sub(sStr, i, i+byteCount-1)
            i = i + byteCount -1
        end
        if byteCount == 1 then
            nWidth = nWidth + 1
            table.insert(tName,char)
            table.insert(tCode,1)
            
        elseif byteCount > 1 then
            nWidth = nWidth + 2
            table.insert(tName,char)
            table.insert(tCode,2)
        end
    end
    
    if nWidth > nMaxCount then
        local _sN = ""
        local _len = 0
        for i=1,#tName do
            _sN = _sN .. tName[i]
            _len = _len + tCode[i]
            if _len >= nShowCount then
                break
            end
        end
        sName = _sN .. "..."
    end
    return sName
end