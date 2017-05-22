require(VIEW_PATH .. "evaluation_help_dialog_view");
require(BASE_PATH.."chessDialogScene")

EvaluationTipsDialog = class(ChessDialogScene,false);

EvaluationTipsDialog.ctor = function(self)
    super(self,evaluation_help_dialog_view);
    
    self.mRootView  = self.m_root;
    self.mBg        = self.mRootView:getChildByName("bg");
    self.mTime1     = self.mBg:getChildByName("time1"):getChildByName("num");
    self.mTime2     = self.mBg:getChildByName("time2"):getChildByName("num");
    self.mTime3     = self.mBg:getChildByName("time3"):getChildByName("num");
    self.mRichTextHandler = self.mBg:getChildByName("rich_text_handler");
    self.mBg:setEventTouch(self,function()end)
    self:setShieldClick(self,self.dismiss)
    self:setNeedMask(false)
    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)
end

EvaluationTipsDialog.dtor = function(self)
    self.mDialogAnim.stopAnim()
end

function EvaluationTipsDialog.show(self,params)
    self.super.show(self,self.mDialogAnim.showAnim);
    self.mTime1:setText(self:getTimeTxt(params.time1,"0秒"));
    self.mTime2:setText(self:getTimeTxt(params.time2,"0秒"));
    self.mTime3:setText(self:getTimeTxt(params.time3,"不读秒"));
    self.mRichTextHandler:removeAllChildren(true);
    local width,height = self.mRichTextHandler:getSize();
    local str = "棋力评测采用统一的棋局时间规则，超时算负。测评时测评官执黑方，对弈过程中不可暂停。"
    local richText = new(RichText, str, width-10, height, kAlignTopLeft, fontName, 28, 85, 70, 40, true,10);

    self.mRichTextHandler:addChild(richText);
end

function EvaluationTipsDialog.dismiss(self)
    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
    if self.mCallbackEvent and type(self.mCallbackEvent.func) == "function" then
        self.mCallbackEvent.func(self.mCallbackEvent.obj)
    end
end

function EvaluationTipsDialog:setDismissCallBack(obj,func)
    self.mCallbackEvent = {}
    self.mCallbackEvent.obj = obj
    self.mCallbackEvent.func = func
end

function EvaluationTipsDialog.getTimeTxt(self,time,def)
    if not time then return def end
    local ret = time .. "秒";
    time = tonumber(time);
    if time == 0 then return def end
    if not time then return ret end
    if time >= 60 then 
        time = time/60
        ret = time .. "分"
    end
    if time >= 60 then 
        time = time/60
        ret = time .. "时"
    end
    return ret;
end