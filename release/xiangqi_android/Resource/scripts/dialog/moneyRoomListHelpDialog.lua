require(VIEW_PATH .. "money_room_list_help_dialog_view")

MoneyRoomListHelpDialog = class(ChessDialogScene,false)

function MoneyRoomListHelpDialog:ctor()
    super(self,money_room_list_help_dialog_view)
    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)
    self.mCloseBtn = self.m_root:getChildByName("close_btn")
    self.mCloseBtn:setOnClick(self,self.dismiss)
    self.mScrollView = self.m_root:getChildByName("scroll_view")
end

function MoneyRoomListHelpDialog:dtor()
    self.mDialogAnim.stopAnim()
end

function MoneyRoomListHelpDialog:show()
    self.super.show(self,self.mDialogAnim.showAnim)
    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
    local param = {}
    param.param = {}
    param.param.help_key = "MoneyRoomListHelpDialog"
    HttpModule.getInstance():execute(HttpModule.s_cmds.IndexGameHelp,param)
end

function MoneyRoomListHelpDialog:dismiss()
    self.super.dismiss(self,self.mDialogAnim.dismissAnim)
    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpRequestsCallBack);
end

function MoneyRoomListHelpDialog:onIndexGameHelpResponse(isSuccess,message)
    if not isSuccess then return end
    local help_text = message.data.help_text:get_value()
    if not help_text then return end
    self.mScrollView:removeAllChildren()
    local w,h = self.mScrollView:getSize()
    local richText = new(RichText,help_text, w, h, kAlignTopLeft, fontName, 28, 80, 80, 80, true,10)
    self.mScrollView:addChild(richText)
end

function MoneyRoomListHelpDialog.onHttpRequestsCallBack(self,command,...)
	Log.i("NewDailyTaskDialog.onHttpRequestsCallBack");
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self,...);
	end 
end

MoneyRoomListHelpDialog.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.IndexGameHelp] = MoneyRoomListHelpDialog.onIndexGameHelpResponse;
};
