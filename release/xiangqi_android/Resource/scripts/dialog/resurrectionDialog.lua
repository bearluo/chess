require(VIEW_PATH .. "resurrection_dialog")

ResurrectionDialog = class(ChessDialogScene,false)

function ResurrectionDialog:ctor()
    super(self,resurrection_dialog)
    self.mBg = self.m_root:getChildByName("bg")
    self.mSureBtn  = self.mBg:getChildByName("sure_btn")
    self.mSureBtn:setOnClick(self,self.onCountDownBtn)
    self.mCloseBtn  = self.mBg:getChildByName("close_btn")
    self.mCloseBtn:setOnClick(self,self.cancel)
    self.mMsg  = self.mBg:getChildByName("msg")
    self.mCountDownTimeTxt  = self.mSureBtn:getChildByName("time")
    self.mCountDownTime = 0 
    self:setNeedBackEvent(false)
    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.httpEventCallBack)
end

function ResurrectionDialog:dtor()
    self:stopCountDownAnim()
    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.httpEventCallBack)
end

function ResurrectionDialog:show()
    self.super.show(self)
    self:startCountDownAnim()
end

function ResurrectionDialog:dismiss()
    self.super.dismiss(self)
    self:stopCountDownAnim()
end

function ResurrectionDialog:startCountDownAnim()
    self:stopCountDownAnim()
    self.mAnim = AnimFactory.createAnimInt(kAnimLoop, 0, 1, 1000, -1)
    self.mAnim:setEvent(self,self.onCountDownEvent)
    self.mCountDownTimeTxt:setText( string.format("(%ds)",self.mCountDownTime))
end

function ResurrectionDialog:stopCountDownAnim()
    delete(self.mAnim)
end

function ResurrectionDialog:onCountDownEvent()
    if self.mCountDownTime == 0 then
        self:cancel()
        self:stopCountDownAnim()
        return 
    end
    self.mCountDownTime = self.mCountDownTime - 1
    if self.mCountDownTime < 0 then self.mCountDownTime = 0 end
    self.mCountDownTimeTxt:setText( string.format("(%ds)",self.mCountDownTime))
    
    if self.mCountDownTime == 0 then
        self:cancel()
        self:stopCountDownAnim()
        return 
    end
end

function ResurrectionDialog:setCancelEvent(obj,func)
    self.mCancelEventObj = obj;
    self.mCancelEventFunc = func;
end

function ResurrectionDialog:setCountDownBtnEvent(obj,func)
    self.mCountDownBtnEventObj = obj;
    self.mCountDownBtnEventFunc = func;
end

function ResurrectionDialog:onCountDownBtn()
    if self.mCountDownBtnClickTime and os.time() - self.mCountDownBtnClickTime < 1 then return end
    if type(self.mCountDownBtnEventFunc) == "function" then
        self.mCountDownBtnEventFunc(self.mCountDownBtnEventObj)
    end
    self.mCountDownBtnClickTime = os.time()
end

function ResurrectionDialog:cancel()
    if self.mCancelClickTime and os.time() - self.mCancelClickTime < 1 then return end
    if type(self.mCancelEventFunc) == "function" then
        self.mCancelEventFunc(self.mCancelEventObj)
    end
    self.mCancelClickTime = os.time()
end

function ResurrectionDialog:setMessage(msg)
    self.mMsg:setText(msg)
end

function ResurrectionDialog:setCountDownTime(time)
    self.mCountDownTime = tonumber(time) or 0
    if self.mCountDownTime < 0 then
        self.mCountDownTime = 0
    end
end
--[[
    info.matchId    = self.m_socket:readString(packetId,ERROR_STRING);
    info.canReviveTime = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.maxScore   = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.countDown  = self.m_socket:readInt(packetId,ERROR_NUMBER);
]]--
function ResurrectionDialog:setReviveViewData(info)
    self:stopCountDownAnim()
    local title = self.mSureBtn:getChildByName("title")
    self:setCountDownTime(info.countDown)
    self.mSureBtn:setPickable(true)
    self.mSureBtn:setGray(false)
    self.mCountDownTimeTxt:setVisible(true)
    title:setPos(-27)
    if info.canReviveTime <= 0 then
        title:setText("无法复活")
        title:setPos(0)
        self.mSureBtn:setPickable(false)
        self.mSureBtn:setGray(true)
        self.mCountDownTimeTxt:setText("")
        self.mCountDownTimeTxt:setVisible(false)
--    elseif info.canReviveTime <= 10 then
--        title:setText( string.format("(复活剩余次数:%d)") )
    else
        title:setText( "立即复活" )
        self:startCountDownAnim()
    end
    self:setMessage("拉取数据中...")

    local params = {}
    params.param = {}
    params.param.match_id = RoomProxy.getInstance():getMatchId()
    HttpModule.getInstance():execute(HttpModule.s_cmds.MatchGetRebuyMoney,params)
end

function ResurrectionDialog:httpEventCallBack(cmd,isSuccess,message)
    if cmd == HttpModule.s_cmds.MatchGetRebuyMoney then
        if HttpModule.explainPHPMessage(isSuccess,message,"复活提示文本拉取失败") then
            self:setMessage("拉取数据失败")
            return
        end
        self:setMessage(message.data.tip_text:get_value())
    end
end