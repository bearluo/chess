
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

-- 将long转换成:xx月xx日xx:xx:xx格式
ToolKit.getTimeMDHMS = function(time)
    local days = "";
    if time and tonumber(time) then
        local timeNum = tonumber(time/1000);
        timeNum = math.abs(timeNum);
        local str = "%Y.%m.%d %H:%M";
        days = os.date(str,timeNum);
    end
    return days;
end

-- 拆分时间：00时:00分:00秒
ToolKit.skipTime = function(time)
    local times = nil;
    if time then
        local timeNum = tonumber(time);
        if timeNum then
            local sec  = timeNum%60
            timeNum = (timeNum - sec)/60
            local min  = timeNum%60
            timeNum = (timeNum - min)/60
            local hour = timeNum

            hour = string.format("%02d",hour);
            min = string.format("%02d",min);
            sec = string.format("%02d",sec);
            times = hour .. ":" .. min .. ":" .. sec;
        end
    end
    return times or "" or string_get("initTimeStr") ;
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
ToolKit.isSecondDay = function(time,currentTime)
    if not time then
        return true;
    end;
    local currentTime = currentTime or os.time();
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

-- 是否是隔周
ToolKit.isSevenDay = function(time,currentTime)
    if not time then
        return true;
    end;
    local currentTime = currentTime or os.time();
    local lastSendTime = time;
    if tonumber(currentTime) > tonumber(lastSendTime) then
        if tonumber(currentTime) -  tonumber(lastSendTime) >= 7 * 24 * 3600 then
            return true;
        else
            return false;
        end;
    else
        return false;
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

-- 与当前时间比较，获得易识别的时间格式，如“50分钟以前”
ToolKit.getEasyTime = function(time)
    if not time or not tonumber(time) then return end;
    local diffTime = os.time() - time;
    if diffTime <= 10 * 60 then
        return "刚刚";
    elseif diffTime < 60 * 60 then
        return math.floor(diffTime / 60) .."分钟以前";
    elseif diffTime < 24 * 60 * 60 then
        return math.floor(diffTime / (60 * 60)) .."小时以前";
    else
        return os.date("%Y-%m-%d",time);
    end;    
end;

-- 与当天时间比较，获得易识别的时间格式2
-- 今天:显示时分
-- 昨天:显示'昨天'
-- 本周内:显示星期几
-- 本周外:显示年月日
ToolKit.getEasyTime2 = function(time)
    if not time or not tonumber(time) then return end;
    local currentTime = os.time();
    local curYear = tonumber(os.date("%Y",currentTime));
    local curMonth = tonumber(os.date("%m",currentTime));
    local curDay = tonumber(os.date("%d",currentTime));
    local currentDaytime = os.time({year= curYear, month=curMonth, day=curDay, hour=0,min=0, sec=0});
    if currentDaytime <= tonumber(time) then
        return os.date("%H:%M",time);
    elseif (currentDaytime - tonumber(time)) < 24 * 60 * 60 then
        return "昨天";
    elseif (currentDaytime - tonumber(time)) < 7 * 24 * 60 * 60 then
        local curWeekday = tonumber(os.date("%w",currentDaytime));
        if curWeekday == 0 then curWeekday = 7 end;
        local curWeekFirstDayTime;
        if curWeekday == 1 then
            curWeekFirstDayTime = currentDaytime;
        elseif curWeekday == 2 then
            curWeekFirstDayTime = currentDaytime - 1 * 24 * 60 * 60;
        elseif curWeekday == 3 then
            curWeekFirstDayTime = currentDaytime - 2 * 24 * 60 * 60;
        elseif curWeekday == 4 then
            curWeekFirstDayTime = currentDaytime - 3 * 24 * 60 * 60;
        elseif curWeekday == 5 then
            curWeekFirstDayTime = currentDaytime - 4 * 24 * 60 * 60;
        elseif curWeekday == 6 then
            curWeekFirstDayTime = currentDaytime - 5 * 24 * 60 * 60;
        elseif curWeekday == 7 then
            curWeekFirstDayTime = currentDaytime - 6 * 24 * 60 * 60;
        end;
        if tonumber(time) >= curWeekFirstDayTime then
            local weekday = tonumber(os.date("%w",time));
            if weekday == 0 then weekday = 7 end; 
            if weekday == 1 then
                return "星期一";
            elseif weekday == 2 then
                return "星期二";
            elseif weekday == 3 then
                return "星期三";
            elseif weekday == 4 then
                return "星期四";
            elseif weekday == 5 then
                return "星期五";
            elseif weekday == 6 then
                return "星期六";
            elseif weekday == 7 then
                return "星期日";
            end;         
        else
            return os.date("%Y-%m-%d",time);
        end;
    else
        return os.date("%Y-%m-%d",time);
    end;
end;

-- 获取当前时间到历史时间月份数组
ToolKit.getMonthArray = function(curTime, hisTime)
    if not curTime or not hisTime or hisTime >= curTime then return end;
    local curYear = tonumber(os.date("%Y",curTime));
    local hisYear = tonumber(os.date("%Y",hisTime));
    local curMonth = tonumber(os.date("%m",curTime));
    local hisMonth = tonumber(os.date("%m",hisTime));
    local years = 0;
    local months = 0;
    if curYear > hisYear then
        years = curYear - hisYear;
        months = 12 * (years - 1) + curMonth + (12 - hisMonth);
    else
        months = curMonth - hisMonth;
    end;
    local monthArray = {};
    for i = 0, months do
        local yStep = 0;
        local mStep = 0;
        if (hisMonth + i) / 12 > 1 then
            yStep = math.floor((hisMonth + i)/12);
            mStep = (hisMonth + i)%12;
        else
            yStep = 0;
            mStep = hisMonth + i;            
        end;
        table.insert(monthArray,1,os.time({year= hisYear + yStep, month=mStep, day=1, hour=0, sec=0}));
    end;
    return monthArray;
end;

-- 返回周数组 2016/08/29 ~ 2016/09/04
-- dates:table表数组（元素是每月第一天时间戳:例如2016/08/01/0:0:0）
ToolKit.getWeekArray = function(dates)
    if not dates or not next(dates) then return end;
    local weekArray = {};
    for i = 1, #dates do
        -- 下一个月第一天时间戳
        local afterMonth;
        if i == 1 then
            local curYear = tonumber(os.date("%Y",dates[i]));
            local curMonth = tonumber(os.date("%m",dates[i]));
            if curMonth < 12 then
                afterMonth = os.time({year= curYear, month=curMonth+1, day=1, hour=0, sec=0});
            else
                afterMonth = os.time({year= curYear+1, month=1, day=1, hour=0, sec=0});
            end;
        elseif i > 1 then
            afterMonth = dates[i - 1];
        end;
        -- 当前日期星期几
        local curWeekday = tonumber(os.date("%w",dates[i]));
        if curWeekday == 0 then curWeekday = 7 end;
        -- 当前日期第一周第一天时间戳
        local firtWeek;
        if curWeekday > 1 then
            -- 不是最后一个月，延长到本周末
            if i ~= #dates then
                firtWeek = dates[i] + (7 - curWeekday + 1) * 24 * 3600;
            else
                firtWeek = dates[i]; 
            end;
        else
            firtWeek = dates[i];
        end;

        while(afterMonth > firtWeek) do
            local lastWeekandStart;
            local lastWeekandEnd;
            local lastWeek = {};
            local weekday = tonumber(os.date("%w",afterMonth));
            if weekday == 0 then weekday = 7 end;
            if weekday > 1 then
                -- 2016/08/29/0:0:0
                lastWeekandStart = afterMonth - (weekday-1) * 24 * 3600; 
                -- 2016/09/04/23:59:59
                lastWeekandEnd = afterMonth + (7 - weekday) * 24 * 3600 + 24 * 3600 - 1;
            else
                lastWeekandStart = afterMonth - 7 * 24 * 3600; 
                lastWeekandEnd = afterMonth - 1;
            end;
            table.insert(lastWeek,1,lastWeekandStart);
            table.insert(lastWeek,2,lastWeekandEnd);
            table.insert(lastWeek,3,os.date("%Y/%m/%d",lastWeekandStart).." ～ "..os.date("%Y/%m/%d",lastWeekandEnd));
            table.insert(weekArray,lastWeek);
            afterMonth = lastWeekandStart ;
        end;
    end;
    return weekArray;
end;

-- date:每月第一天时间戳:例如2016/08/01/0:0:0
-- 返回周数组 例如2016/08/29 ~ 2016/09/04
ToolKit.getOneMonthWeekArray = function(date)
    if not date then return end;
    local weekArray = {};
    local afterMonth;
    local curYear = tonumber(os.date("%Y",date));
    local curMonth = tonumber(os.date("%m",date));
    if curMonth < 12 then
        afterMonth = os.time({year= curYear, month=curMonth+1, day=1, hour=0, sec=0});
    else
        afterMonth = os.time({year= curYear+1, month=1, day=1, hour=0, sec=0});
    end;
    -- 当前日期星期几
    local curWeekday = tonumber(os.date("%w",date));
    if curWeekday == 0 then curWeekday = 7 end;
    -- 当前日期第一周第一天时间戳
    local firtWeek;
    if curWeekday > 1 then
        firtWeek = date + (7 - curWeekday) * 24 * 3600;
    else
        firtWeek = date;
    end;
    while(afterMonth > firtWeek) do
        local lastWeekandStart;
        local lastWeekandEnd;
        local lastWeek = {};
        local weekday = tonumber(os.date("%w",afterMonth));
        if weekday == 0 then weekday = 7 end;
        if weekday > 1 then
            -- 2016/08/29/0:0:0
            lastWeekandStart = afterMonth - (weekday-1) * 24 * 3600; 
            -- 2016/09/04/23:59:59
            lastWeekandEnd = afterMonth + (7 - weekday) * 24 * 3600 + 24 * 3600 - 1;
        else
            lastWeekandStart = afterMonth - 7 * 24 * 3600; 
            lastWeekandEnd = afterMonth - 1;
        end;
        table.insert(lastWeek,1,lastWeekandStart);
        table.insert(lastWeek,2,lastWeekandEnd);
        table.insert(lastWeek,3,os.date("%Y/%m/%d",lastWeekandStart).." ～ "..os.date("%Y/%m/%d",lastWeekandEnd));
        table.insert(weekArray,lastWeek);
        afterMonth = lastWeekandStart ;
    end;
    return weekArray;
end

-- date:每月第一天时间戳:例如2016/08/01/0:0:0
-- 返回周数组 例如2016/08/01 ~ 2016/08/31
ToolKit.getOneMonth = function(date)
    if not date then return end;
    local month = {};
    local afterMonth;
    local curYear = tonumber(os.date("%Y",date));
    local curMonth = tonumber(os.date("%m",date));
    if curMonth < 12 then
        afterMonth = os.time({year= curYear, month=curMonth+1, day=1, hour=0, sec=0});
    else
        afterMonth = os.time({year= curYear+1, month=1, day=1, hour=0, sec=0});
    end;
    table.insert(month,1,date);
    table.insert(month,2,afterMonth - 1);
    return month;
end

-- 获取本月最后一周星期一的时间
ToolKit.getWeekLastDay = function(time)
    if not time then return end;
    local afterMonth;
    local curYear = tonumber(os.date("%Y",time));
    local curMonth = tonumber(os.date("%m",time));
    if curMonth < 12 then
        afterMonth = os.time({year= curYear, month=curMonth+1, day=1, hour=0, sec=0});
    else
        afterMonth = os.time({year= curYear+1, month=1, day=1, hour=0, sec=0});
    end;
    local weekday = tonumber(os.date("%w",afterMonth));
    if weekday == 0 then weekday = 7 end;
    local lastWeekandStart;
    if weekday > 1 then
        lastWeekandStart = afterMonth - (weekday-1) * 24 * 3600; 
    else
        lastWeekandStart = afterMonth - 7 * 24 * 3600; 
    end;
    return lastWeekandStart;
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

--[Comment]
--去除字符串前后空格 参数：字符串
ToolKit.delStrBlank = function(str)
    assert(type(str)=="string")
    return (str:match("^%s*(.-)%s*$"))
end

--[Comment]
--是否数字
ToolKit.islegal = function(str)
	local date = "%D"
	if not string.find(str, date) then --非数字
		return true;
	else
		return false;
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
            return string.format("%d万",math.floor(num/10000))
        end
        if num > 10000000 then
            return string.format("%.1f万",math.floor(num/1000)/10)
        end
        return string.format("%.2f万",math.floor(num/100)/100);
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
    str = str .. ""
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

--[Comment]
-- 根据金币获取icon
ToolKit.getGoldIconFile = function(money)
    local golds = tonumber(money)
    if golds > 500000 then
        return "mall/mall_list_gold5.png"
    end
    if golds > 100000 then
        return "mall/mall_list_gold4.png"
    end
    if golds > 50000 then
        return "mall/mall_list_gold3.png"
    end
    if golds > 10000 then
        return "mall/mall_list_gold2.png"
    end
    return "mall/mall_list_gold1.png"
end

--[Comment]
--支付统计场景等数据
ToolKit.getBuyCoinsPhpConfig = function()
    local payData = {}
    --todo 国庆前获取联网房间类型有问题
    local roomConfig = RoomConfig.getInstance():getRoomConfigByType();

    local plist = { [0]  = {pay_scene = PayUtil.s_pay_scene.default_recommend,               pay_room = PayUtil.s_pay_room.other,            money = 0},
                    [1]  = {pay_scene = PayUtil.s_pay_scene.novice_room_recommend,           pay_room = PayUtil.s_pay_room.novice,           money = roomConfig[RoomConfig.ROOM_TYPE_NOVICE_ROOM].money or 0},
                    [2]  = {pay_scene = PayUtil.s_pay_scene.middle_room_recommend,           pay_room = PayUtil.s_pay_room.middle,           money = roomConfig[RoomConfig.ROOM_TYPE_INTERMEDIATE_ROOM].money or 0},
                    [3]  = {pay_scene = PayUtil.s_pay_scene.master_room_recommend,           pay_room = PayUtil.s_pay_room.master,           money = roomConfig[RoomConfig.ROOM_TYPE_MASTER_ROOM].money or 0},
                    [4]  = {pay_scene = PayUtil.s_pay_scene.private_room_recommend,          pay_room = PayUtil.s_pay_room.private,          money = roomConfig[RoomConfig.ROOM_TYPE_PRIVATE_ROOM].money or 0},
                    [5]  = {pay_scene = PayUtil.s_pay_scene.friend_room_recommend,           pay_room = PayUtil.s_pay_room.friend,           money = roomConfig[RoomConfig.ROOM_TYPE_FRIEND_ROOM].money or 0},
                    [6]  = {pay_scene = PayUtil.s_pay_scene.watch_room_recommend,            pay_room = PayUtil.s_pay_room.other,            money = 0},
                    [7]  = {pay_scene = PayUtil.s_pay_scene.alone_prop,                      pay_room = PayUtil.s_pay_room.console,          money = 0},
                    [8]  = {pay_scene = PayUtil.s_pay_scene.booth_prop,                      pay_room = PayUtil.s_pay_room.endgate,          money = 0},
                    [9]  = {pay_scene = PayUtil.s_pay_scene.default_recommend,               pay_room = PayUtil.s_pay_room.arena,            money = 0},
                    [12] = {pay_scene = PayUtil.s_pay_scene.watch_room_recommend,            pay_room = PayUtil.s_pay_room.arena,            money = 0},
                    [13] = {pay_scene = PayUtil.s_pay_scene.metier_room_recommend,           pay_room = PayUtil.s_pay_room.metier,           money = 0},
                    }
    local num = RoomProxy.getInstance():getCurRoomMultiple();
    local roomType = RoomProxy.getInstance():getCurRoomType();
    if not plist[roomType] then
        roomType = 0 -- 归为未定义
    end
    payData.pay_scene = plist[roomType].pay_scene
    payData.gameparty_subname = plist[roomType].pay_room
    local money = tonumber(plist[roomType].money)
    payData.gameparty_anto = money * num
    return payData
end
--[Comment]
-- 定时器多次
-- 注意释放问题
ToolKit.schedule_repeat_time = function(obj,func,time,loop_num,a,b,c)
    local schedule_repeat_anim = new(AnimInt, kAnimRepeat, 0,1,time,0);
    if schedule_repeat_anim then
        schedule_repeat_anim:setEvent(obj, function(a,b,c,repeat_or_loop_num) 
            func(obj,a,b,c,repeat_or_loop_num);
            if repeat_or_loop_num >= loop_num then
                delete(schedule_repeat_anim);
                schedule_repeat_anim = nil;
            end;
        end);
    end;    
    return schedule_repeat_anim
end;

-- 定时器一次(唯一定时器)
ToolKit.schedule_union_once = function(obj,func,time,a,b,c,d)
    ToolKit.schedule_once_anim = new(AnimInt, kAnimNormal, 0,1,time,0);
    if ToolKit.schedule_once_anim then
        ToolKit.schedule_once_anim:setEvent(obj, function(obj) 
            func(obj,a,b,c,d);
            delete(ToolKit.schedule_once_anim);
            ToolKit.schedule_once_anim = nil;
        end);
    end;    
end;

-- 定时器一次
ToolKit.schedule_once = function(obj,func,time,a,b,c,d)
    local anim = new(AnimInt, kAnimNormal, 0,1,time,0);
    if anim then
        anim:setEvent(obj, function(obj) 
            func(obj,a,b,c,d);
            delete(anim);
            anim = nil;
        end);
    end;    
end;


-- @param drawing的ID
-- @param path 保存文件的全路径 
-- @param w,h 宽高 图片保存后的宽高
ToolKit.saveDrawing = function ( drawingId, path, w, h )
    local size = drawing_get_size(drawingId);
    if (w and h) then
        size = {w,h};
    end
    local resId = res_alloc_id();

    res_create_dynamic_image(0, resId, size[1], size[2], 0);
    res_set_image_from_drawing( resId, drawingId, 0);
    res_image_save( resId , path);
    
    res_delete ( resId );
    res_free_id ( resId );
end

-- 截屏
-- 如果传入drawingId和path 截drawing
-- 否则截全屏
ToolKit.takeShot = function(drawingId, path)
    if drawingId and path then
        ToolKit.saveDrawing(drawingId, path);
    else
        dict_set_string(kTakeScreenShot , kTakeScreenShot .. kparmPostfix , "egame_share");
        call_native(kTakeScreenShot);
    end;
end;

-- ios屏蔽
ToolKit.iosAuditStatus = function(openFunc,hideFunc)
    if kPlatform == kPlatformIOS then	
        if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then 
            openFunc();
        else
            hideFunc();
        end;
    end;
end;

function ToolKit.get_timezone()
  local now = os.time()
  return os.difftime(now, os.time(os.date("!*t", now)))
end

function ToolKit.getDate(time)
    time = tonumber(time) or 0
    local localTimeZone = ToolKit.get_timezone()
    local serverTimeZone = 28800
    local timeZoneD = serverTimeZone - localTimeZone
    return os.date("*t",time+timeZoneD)
end

function ToolKit.get_match_time_str_prefix(time)
    time = tonumber(time)
    if not time then return "" end
    local localTimeZone = ToolKit.get_timezone()
    local serverTimeZone = 28800
    local timeZoneD = serverTimeZone - localTimeZone
    local localTime = os.time()
    -- 判断是不是同一天
    local obTime = os.date("*t",time+timeZoneD)
    local time1 = os.date("*t",localTime+timeZoneD)
    local prefix
    -- 今天
    if not prefix and time1.year == obTime.year and time1.month == obTime.month and time1.day == obTime.day then
        prefix = "今天"
    end
    -- 明天
    local timeTmp = os.date("*t",localTime+timeZoneD+86400)
    if not prefix and timeTmp.year == obTime.year and timeTmp.month == obTime.month and timeTmp.day == obTime.day then
        prefix = "明天"
    end
    -- 本周
    if not prefix and localTime < time and time - localTime < 604800 and time1.wday ~= 1 and (time1.wday < obTime.wday or obTime.wday == 1) then
        prefix = "本周"
        if obTime.wday == 1 then
            prefix = "周天"
        elseif obTime.wday == 2 then
            prefix = "周一"
        elseif obTime.wday == 3 then
            prefix = "周二"
        elseif obTime.wday == 4 then
            prefix = "周三"
        elseif obTime.wday == 5 then
            prefix = "周四"
        elseif obTime.wday == 6 then
            prefix = "周五"
        elseif obTime.wday == 7 then
            prefix = "周六"
        end
    end
    -- 日期
    if not prefix then
        prefix = string.format("%02d-%02d",obTime.month,obTime.day)
    end
    return prefix or ""
end