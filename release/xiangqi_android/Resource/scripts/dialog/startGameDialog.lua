--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require(VIEW_PATH .. "start_game_dialog");
require(BASE_PATH.."chessDialogScene")
require("ui/scrollViewEx");

StartGameDialog = class(ChessDialogScene,false)

StartGameDialog.ctor = function(self)
    super(self,start_game_dialog)
    self.mBg = self.m_root:getChildByName("bg")
    self.mTitleView = self.mBg:getChildByName("dec_txt_view")
    self.mTxt = self.mBg:getChildByName("money_bg"):getChildByName("txt")
    self.mMessage = ""
    self:updateTitleView()
    self:setNeedBackEvent(false)
end

function StartGameDialog:updateTitleView(second)
    second = tonumber(second) or 0
    self.mTitleView:removeAllChildren()
    local startPos = 0
    local txt1 = new(Text,"下注结束,", width, height, align, fontName, 44, 240, 230, 210)
    txt1:setPos(startPos)
    startPos = txt1:getSize() + startPos
    self.mTitleView:addChild(txt1)
    local txt2 = new(Text,self.mMessage, width, height, align, fontName, 44, 40, 200, 65)
    txt2:setPos(startPos)
    startPos = txt2:getSize() + startPos
    self.mTitleView:addChild(txt2)
    local txt3 = new(Text, string.format("先下棋(%ds)...",second), width, height, align, fontName, 44, 240, 230, 210)
    txt3:setPos(startPos)
    startPos = txt3:getSize() + startPos
    self.mTitleView:addChild(txt3)
    self.mTitleView:setSize(startPos)
end

StartGameDialog.show = function(self,time_out)
    self.super.show(self)
    time_out = tonumber(time_out)
    if not time_out or (time_out == 0 or time_out < 0 )then
        time_out = 30;
    end
    self.m_time_out = time_out + os.time();
    self:updateTitleView(self.m_time_out - os.time())
    self.timeOutAnim = new(AnimInt,kAnimRepeat,0,1,1000,-1);
    self.timeOutAnim:setEvent(self,self.onAnimTime);
end

StartGameDialog.setMessage = function(self,message)
    self.mMessage = message or ""
    self:updateTitleView(self.m_time_out - os.time())
end

function StartGameDialog:setData(data)
    if not data then return end
    local raise = tonumber(data.raise) or 0
    if raise > 10000 then
        raise = string.format("%d.%d万", math.floor(raise/10000), math.floor((raise%10000)/1000))
    end
    self.mTxt:setText( string.format("总奖池:%s金币",raise))
    if data.red_uid == UserInfo.getInstance():getUid() then
        self.mMessage = "您"
    else
        self.mMessage = "对手"
    end
    if self.m_time_out then
        self:updateTitleView(self.m_time_out - os.time())
    end
end 

StartGameDialog.onAnimTime = function(self)
    if self.m_time_out and self.m_time_out > os.time() then
        self:updateTitleView(self.m_time_out - os.time())
    else
        self:dismiss()
        if self.timeOutAnim then
            delete(self.timeOutAnim);
            self.timeOutAnim = nil;
        end
    end
end

StartGameDialog.dismiss = function(self)
    if self.timeOutAnim then
        delete(self.timeOutAnim);
        self.timeOutAnim = nil;
    end
    self.super.dismiss(self);
end

StartGameDialog.dtor = function(self)
    if self.timeOutAnim then
        delete(self.timeOutAnim);
        self.timeOutAnim = nil;
    end
end

StartGameDialog.checkTime = function(self,time,text0)
    if time and time < 60 and time > 0 then
        return time .. "秒";
    elseif time and time >= 60 then
        return time/60 .. "分"
    elseif time and time <= 0 then
        return text0 or "不限时"
    end
end