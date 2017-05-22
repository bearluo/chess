--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require(VIEW_PATH .. "handicap_confirm_dialog_view");
require(BASE_PATH.."chessDialogScene")
require("ui/scrollViewEx");

HandicapConfirmDialog = class(ChessDialogScene,false)

HandicapConfirmDialog.s_controls = 
{
    base_money = 1;
    opp_add_money = 2;
    me_add_money = 3;
    mulpity_txt = 4;
    anim_txt = 5;
    sure_btn = 6;
    cancel_btn = 7;
};

HandicapConfirmDialog.s_controlConfig = 
{
    [HandicapConfirmDialog.s_controls.base_money] = {"bg","base_money"};
    [HandicapConfirmDialog.s_controls.opp_add_money] = {"bg","opp_add_money"};
    [HandicapConfirmDialog.s_controls.me_add_money] = {"bg","me_add_money"};
    [HandicapConfirmDialog.s_controls.mulpity_txt] = {"bg","mulpity_txt"};
    [HandicapConfirmDialog.s_controls.anim_txt] = {"bg","cancel_btn","txt"};
    [HandicapConfirmDialog.s_controls.sure_btn] = {"bg","sure_btn"};
    [HandicapConfirmDialog.s_controls.cancel_btn] = {"bg","cancel_btn"};
    
};

HandicapConfirmDialog.ctor = function(self)
    super(self,handicap_confirm_dialog_view);
    self.m_ctrls = HandicapConfirmDialog.s_controls;


    self.m_me_add_money = self:findViewById(self.m_ctrls.me_add_money);
    self.m_opp_add_money = self:findViewById(self.m_ctrls.opp_add_money);
    self.m_base_money  = self:findViewById(self.m_ctrls.base_money);
    self.m_mulpity_txt = self:findViewById(self.m_ctrls.mulpity_txt);
    self.m_anim_txt = self:findViewById(self.m_ctrls.anim_txt);

    self:findViewById(self.m_ctrls.sure_btn):setOnClick(self,self.onSureBtnClick)
    self:findViewById(self.m_ctrls.cancel_btn):setOnClick(self,self.onCancleBtnClick)

    self:setNeedBackEvent(false)
    self:setNeedMask(false)
    self.mDialogAnim = AnimDialogFactory.createMoveUpAnim(self)
end

function HandicapConfirmDialog:dtor()
    self.mDialogAnim.stopAnim()
    self:stopAddMoneyAnim()
end

function HandicapConfirmDialog:updateTitleView(second)
    second = tonumber(second) or 0
    self.m_anim_txt:setText( string.format("不同意(%d)",second))
end

HandicapConfirmDialog.show = function(self,data)
    if not data then
        return;
    end
    self.m_data = data;
    self.super.show(self,self.mDialogAnim.showAnim);

    self.m_me_add_money:setText(data.cur_upraise)
    self.m_opp_add_money:setText(data.opp_upraise)
    self.m_base_money:setText(data.basechip)
    self.m_mulpity_txt:setText(data.mulpity.."倍")

    if data.timeout and (data.timeout == 0 or data.timeout < 0 )then
        data.timeout = 10;
    end
    self.m_time_out = data.timeout + os.time();
    
    self:updateTitleView(self.m_time_out - os.time())
    self.timeOutAnim = new(AnimInt,kAnimRepeat,0,1,1000,-1);
    self.timeOutAnim:setEvent(self,self.onAnimTime);
end

HandicapConfirmDialog.onAnimTime = function(self)
    if self.m_time_out and self.m_time_out > os.time() then
        self:updateTitleView(self.m_time_out - os.time())
    else
        if self.timeOutAnim then
            delete(self.timeOutAnim);
            self.timeOutAnim = nil;
            self:onCancleBtnClick();
        end
    end
end

HandicapConfirmDialog.dismiss = function(self,flag)
    if self.timeOutAnim then
        delete(self.timeOutAnim);
        self.timeOutAnim = nil;
    end
    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
end

HandicapConfirmDialog.dtor = function(self)
	if self.timeOutAnim then
        delete(self.timeOutAnim);
        self.timeOutAnim = nil;
    end
    self.mDialogAnim.stopAnim()
end


HandicapConfirmDialog.onSureFunc = function(self,obj,func)
    self.m_sureFunc = func;
    self.m_sureObj = obj;
end

HandicapConfirmDialog.onCancleFunc = function(self,obj,func)
    self.m_cancleFunc = func;
    self.m_cancleObj = obj;
end

HandicapConfirmDialog.onSureBtnClick = function(self)
    self:dismiss();
    if self.timeOutAnim then
        delete(self.timeOutAnim);
        self.timeOutAnim = nil;
    end
    if self.m_sureFunc and self.m_sureObj then
        self.m_sureFunc(self.m_sureObj,self.m_data.mulpity);
    end
end

HandicapConfirmDialog.onCancleBtnClick = function(self)
    self:dismiss();
    if self.timeOutAnim then
        delete(self.timeOutAnim);
        self.timeOutAnim = nil;
    end
    if self.m_cancleFunc and self.m_cancleObj then
        self.m_cancleFunc(self.m_cancleObj);
    end
end
--endregion
