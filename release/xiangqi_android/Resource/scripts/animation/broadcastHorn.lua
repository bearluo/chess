--broadcastHorn.lua
--Author LeoLi 
--Date 2016/8/4
--Description 
--小喇叭广播动画
require(VIEW_PATH.."broadcast_horn_view");
require("util/analysisNotice")
BroadCastHorn = class(GameLayer);

BroadCastHorn.instance = nil;
BroadCastHorn.ctor = function(self)
    self.m_root_view = SceneLoader.load(broadcast_horn_view);
    self.m_root_view:setAlign(kAlignTop);
    self.m_root_view:setVisible(false);
    self.m_root_view:setLevel(1);
    self.m_content = self.m_root_view:getChildByName("content");
    self.m_msg_bottom_view = self.m_content:getChildByName("bottom");
    self.m_msg_bottom = self.m_msg_bottom_view:getChildByName("bottom_msg");

    self.m_txt_bottom = new(RichText,"",nil,nil,kAlignLeft,nil,28,46,46,46);
    self.m_txt_bottom:setPos(0,0);
    self.m_txt_bottom:setVisible(false);
    self.m_msg_bottom:addChild(self.m_txt_bottom);

    self.m_msg_up_view = self.m_content:getChildByName("up");
    self.m_msg_up = self.m_msg_up_view:getChildByName("up_msg");
    self.m_msg_up_bg = self.m_msg_up_view:getChildByName("bg");
    self.m_msg_up_bg:setTransparency(0.4);

    self.m_txt_up = new(RichText,"",nil,nil,kAlignLeft,nil,28,46,46,46);
    self.m_txt_up:setPos(0,0);
    self.m_txt_up:setVisible(false);
    self.m_msg_up:addChild(self.m_txt_up);
    
    self.m_msg_bottom_view:getChildByName("bg"):setTransparency(0.3);
    self.horn_btn = self.m_msg_bottom_view:getChildByName("horn_btn")
    self.horn_btn:setOnClick(self,function()
        EventDispatcher.getInstance():dispatch(Event.Call,kShowHallChatDialog)
    end)
    self.horn_btn:setEnable(false)

    self.m_msg_up:addChild(self.m_msg);
    self.is_need_clip = true;
    self.m_msg_wait_queue = {};

end;

BroadCastHorn.dtor = function(self)

end;

BroadCastHorn.switchBtnStatus = function(self,ret)
    self.horn_btn:setEnable(ret)
end

BroadCastHorn.getInstance = function(self)
    if not BroadCastHorn.instance then
        BroadCastHorn.instance = new(BroadCastHorn);
    end;
    return BroadCastHorn.instance;
end;

--[Comment]
-- 返回消息类型：1，全局消息；2，棋局外消息
BroadCastHorn.getMsgType = function(self)
    if self.m_playing_data then
        return self.m_playing_data.horn_type;
    end;
end;

BroadCastHorn.isPlaying = function(self)
    return self.m_is_playing;
end;

BroadCastHorn.getDatas = function(self,data)
--    local msg      = data.horn_msg or "";
    local msg,title = AnalysisNotice.getAnalysisText(data)
    local speed    = data.speed or 8;
    local msgType  = data.horn_type;
    local times    = data.loop_num or 1;
    local len      = string.lenutf8(GameString.convert2UTF8(msg));  
    local time     = math.ceil((tonumber(len) + (sysW)/26)/speed);-- 滚动的时间（秒）,字体宽26
    return msg, time, times,title;
end;

BroadCastHorn.setMsgAlign = function(self, align)
    if align == 1 then -- 1:大厅显示小喇叭
        self.m_msg_up_view:setVisible(false);
        self.m_msg_bottom_view:setVisible(true);
        self.m_msg = self.m_txt_bottom;
        self.m_scroll_width = System.getLayoutWidth();
        self.is_need_clip = true;
        sysW = System.getLayoutWidth();
    elseif align == 2 then --2:其他场景显示小喇叭
        self.m_msg_up_view:setVisible(true);
        self.m_msg_bottom_view:setVisible(false);
        self.m_msg = self.m_txt_up;
        self.m_scroll_width = System.getScreenScaleWidth();
        self.is_need_clip = false;
        sysW = System.getScreenScaleWidth();
    end;
end;

--[Comment]
-- 播放（提供外部的接口）
-- @param data:展示的数据
-- node: 如果有消息正在播放，将新消息存入等待序列
--       否则播放消息
BroadCastHorn.play = function(self,data)
    if not data or not next(data) then return end;
    if not self.m_is_playing then
        local msg, time, times,name = self:getDatas(data);
        if msg == ""then 
        self.m_is_playing = false;
        self.is_quit_clip = true;        
        return end;
        self.m_playing_data = data;
        self.m_is_playing = true;
        self.is_quit_clip = false;
        self:fadeIn(self.m_content,self.startScrollMsgs,msg,time,times,name)
    else
        table.insert(self.m_msg_wait_queue,data);
    end;
end;

--[Comment]
-- 开始播放走马灯消息
-- @param time :播放时间
-- @param times:单条消息播放次数
-- @node :根据msg,time,times播放单条消息
--        如果times<=0,说明单条已经播完了
--        如果等待队列里有消息,继续走马灯
--        如果等待队列空了,播放上滑动画
BroadCastHorn.startScrollMsgs = function(self,msg,time,times,name)
    self.m_root_view:setVisible(true);
--    self.m_msg:setText(msg);
    self:setHornMsg(msg,name)
    self:scrollMsg(self.m_msg,self.m_scroll_width,time*1000,function() 
        times = times - 1;
        if times <= 0 then
            if #self.m_msg_wait_queue > 0 then
                local data = table.remove(self.m_msg_wait_queue,1);
                local msg, time, times,name = self:getDatas(data);
                if msg == ""then time = 0 end;
                self.m_playing_data = data;
                self:startScrollMsgs(msg,time,times,name);
            else
                self:fadeOut(self.m_content);
                self.m_is_playing = false;
                self.is_quit_clip = true;
                return;
            end;
        else
            self:startScrollMsgs(msg,time,times,name);
        end;
    end);
    self:schedule_repeat_time(function()
        if self.is_need_clip then
            local w,h = self.m_msg_bottom:getSize()
            local x,y = self.m_msg_bottom:getPos()
            self.m_msg_bottom:setClip(x,y,w,h);
        else
            self.m_msg_up:setClip(0,0,System.getScreenScaleWidth(),50);
        end;
    end,
    100,
    (time * 1000)/100);    
end;

function BroadCastHorn.setHornMsg(self,msg,name)
    local title = ""
    if name and name ~= "" then
        title = "#c507DBE" .. name .. ":#n"
    end
    self.m_msg:setText(title .. msg)
end

-- 消失
BroadCastHorn.dismiss = function(self)
    self.m_content:removeProp(0);
    self.m_content:removeProp(1);
    self.m_content:setVisible(false);
    self.m_msg_bottom_view:setVisible(false);
    self.m_msg_up_view:setVisible(false); 
    self.is_quit_clip = true;
    self.m_is_playing = false;
    self.m_msg_wait_queue = {};
end;

-- 定时器一次
BroadCastHorn.schedule_once = function(self,func,time,a,b,c)
    local anim = new(AnimInt, kAnimNormal, 0,1,time,0);
    if anim then
        anim:setEvent(self, function() 
                func(self,a,b,c);
                delete(anim);
                anim = nil;
            end
        );
    end;    
end;

-- 定时器多次
BroadCastHorn.schedule_repeat_time = function(self,func,time,loop_num,a,b,c)
    local anim = new(AnimInt, kAnimRepeat, 0,1,time,0);
    if anim then
        anim:setEvent(self, function(a,b,c,repeat_or_loop_num) 
            func(self,a,b,c);
            if repeat_or_loop_num == loop_num or self.is_quit_clip then
                delete(anim);
                anim = nil;
            end;
        end);
    end;    
end;

-- 下滑动画
BroadCastHorn.scrollDown = function(self,scrollDownView,callBackFun,var1,var2,var3)
    if scrollDownView then 
        scrollDownView:setVisible(true);
        local scrollW,scrollH = scrollDownView:getSize();
        local scrollDownAnim = scrollDownView:addPropTranslate(0,kAnimNormal,300,0,0,0,-scrollH,0);
        if not scrollDownAnim then return end;
        scrollDownAnim:setEvent(self, function() 
             scrollDownView:removeProp(0);  
             if callBackFun then
                callBackFun(self,var1,var2,var3);
             end;     
        end)
        -- leftTransparency
        local scrollDownTransparency = scrollDownView:addPropTransparency(1,kAnimNormal,300,0,0,1);
        if not scrollDownTransparency then return end;
        scrollDownTransparency:setEvent(nil, function() 
            scrollDownView:removeProp(1);
        end);
    end;
end;

-- 上滑动画
BroadCastHorn.scrollUp = function(self,scrollUpView,callBackFun,var)
    if scrollUpView then 
        scrollUpView:setVisible(true);
        local scrollW,scrollH = scrollUpView:getSize();
        local scrollUpAnim = scrollUpView:addPropTranslate(0,kAnimNormal,300,0,0,0,0,-scrollH);
        if not scrollUpAnim then return end;
        scrollUpAnim:setEvent(self, function() 
             scrollUpView:removeProp(0);  
             if callBackFun then
                callBackFun(self,var);
             end;     
        end)
        -- leftTransparency
        local scrollUpTransparency = scrollUpView:addPropTransparency(1,kAnimNormal,300,0,1,0);
        if not scrollUpTransparency then return end;
        scrollUpTransparency:setEvent(nil, function() 
            scrollUpView:removeProp(1);
            scrollUpView:setVisible(false);
        end);
    end;
end;

-- 淡入动画
BroadCastHorn.fadeIn = function(self,fadeInView,callBackFun,var1,var2,var3,var4)
    if fadeInView then 
        fadeInView:setVisible(false);
        local fadeInTransparency = fadeInView:addPropTransparency(1,kAnimNormal,300,0,0,1);
        if not fadeInTransparency then return end;
        fadeInTransparency:setEvent(nil, function() 
            fadeInView:removeProp(1);
            fadeInView:setVisible(true);
            if callBackFun then
                callBackFun(self,var1,var2,var3,var4);
            end;    
        end);
    end;
end;


-- 淡出动画
BroadCastHorn.fadeOut = function(self,fadeOutView,callBackFun,var)
    if fadeOutView then 
        fadeOutView:setVisible(true);
        local fadeOutTransparency = fadeOutView:addPropTransparency(1,kAnimNormal,300,0,1,0);
        if not fadeOutTransparency then return end;
        fadeOutTransparency:setEvent(nil, function() 
            fadeOutView:removeProp(1);
            fadeOutView:setVisible(false);
            if callBackFun then
               callBackFun(self,var);
            end;    
        end);
    end;
end;

-- 走马灯
BroadCastHorn.scrollMsg = function(self,scrollView,width,time,callBackFun)
    if scrollView then 
        scrollView:setVisible(true);
        local scrollW,scrollH = scrollView:getSize();
        local scrollAnim = scrollView:addPropTranslate(0,kAnimNormal,time,0,width or 720,-scrollW,0,0);
        if not scrollAnim then return end;
        scrollAnim:setEvent(self, function() 
             scrollView:setVisible(false);
             scrollView:removeProp(0);  
             if callBackFun then
                callBackFun(self);
             end;     
        end)
    end;
end;
