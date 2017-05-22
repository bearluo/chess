--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require(VIEW_PATH .. "forestall_wait_dialog_view_320");
require(BASE_PATH.."chessDialogScene")
require("ui/scrollViewEx");

ForestallWaitDialog320 = class(ChessDialogScene,false)

ForestallWaitDialog320.s_controls = 
{
    my_add_money = 1;
    opp_add_money = 2;
};

ForestallWaitDialog320.s_controlConfig = 
{
    [ForestallWaitDialog320.s_controls.my_add_money] = {"bg","my_add_money"};
    [ForestallWaitDialog320.s_controls.opp_add_money] = {"bg","opp_add_money"};
};

ForestallWaitDialog320.ctor = function(self)
    super(self,forestall_wait_dialog_view_320);
    self.m_ctrls = ForestallWaitDialog320.s_controls;


    self.m_my_add_money = self:findViewById(self.m_ctrls.my_add_money);
    self.m_opp_add_money = self:findViewById(self.m_ctrls.opp_add_money);

    self.mTitleView = self.m_root:getChildByName("bg"):getChildByName("title_view")
    self.mFirstIcon = self.m_root:getChildByName("bg"):getChildByName("first_icon")

    self:setNeedBackEvent(false)
    self:setNeedMask(false)
    self.mDialogAnim = AnimDialogFactory.createMoveUpAnim(self)
end

function ForestallWaitDialog320:dtor()
    self.mDialogAnim.stopAnim()
    self:stopAddMoneyAnim()
end

function ForestallWaitDialog320:updateTitleView(second)
    second = tonumber(second) or 0
    self.mTitleView:removeAllChildren()
    local startPos = 0
    local txt1 = new(Text,"对方加注(", width, height, align, fontName, 36, 240, 230, 210)
    txt1:setPos(startPos)
    startPos = txt1:getSize() + startPos
    self.mTitleView:addChild(txt1)
    local txt2 = new(Text,second .. "s", width, height, align, fontName, 36, 40, 200, 65)
    txt2:setPos(startPos)
    startPos = txt2:getSize() + startPos
    self.mTitleView:addChild(txt2)
    local txt3 = new(Text,"),加注多者抢", width, height, align, fontName, 36, 240, 230, 210)
    txt3:setPos(startPos)
    startPos = txt3:getSize() + startPos
    self.mTitleView:addChild(txt3)
    local img = new(Image,"common/icon/first_icon.png")
    img:setPos(startPos)
    startPos = img:getSize() + startPos
    self.mTitleView:addChild(img)
    local txt4 = new(Text,"下棋", width, height, align, fontName, 36, 240, 230, 210)
    txt4:setPos(startPos)
    startPos = txt4:getSize() + startPos
    self.mTitleView:addChild(txt4)
    self.mTitleView:setSize(startPos)
end

ForestallWaitDialog320.show = function(self,data)
    if not data then
        return;
    end
    self.m_data = data;
    self:setVisible(true);
    self.super.show(self,self.mDialogAnim.showAnim);

    if data.curr_uid == UserInfo.getInstance():getUid() then
        self.m_my_add_money:setText(data.cur_upraise)
        self.m_opp_add_money:setText(data.opp_upraise)
    else
        self.m_my_add_money:setText(data.opp_upraise)
        self.m_opp_add_money:setText(data.cur_upraise)
    end

    

    if data.timeout and (data.timeout == 0 or data.timeout < 0 )then
        data.timeout = 10;
    end
    self.m_time_out = data.timeout + os.time();
    
    self:updateTitleView(self.m_time_out - os.time())
    self.timeOutAnim = new(AnimInt,kAnimRepeat,0,1,1000,-1);
    self.timeOutAnim:setEvent(self,self.onAnimTime);
end

ForestallWaitDialog320.onAnimTime = function(self)
    if self.m_time_out and self.m_time_out > os.time() then
        self:updateTitleView(self.m_time_out - os.time())
    else
        if self.timeOutAnim then
            delete(self.timeOutAnim);
            self.timeOutAnim = nil;
        end
    end
end

ForestallWaitDialog320.dismiss = function(self,flag)
    if self.timeOutAnim then
        delete(self.timeOutAnim);
        self.timeOutAnim = nil;
    end
    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
end

ForestallWaitDialog320.dtor = function(self)
	if self.timeOutAnim then
        delete(self.timeOutAnim);
        self.timeOutAnim = nil;
    end
    self.mDialogAnim.stopAnim()
end

function ForestallWaitDialog320:startAddMoneyAnim(uid,add_money)
    add_money = tonumber(add_money)
    uid = tonumber(uid)
    if not uid or not add_money then return end
    self:stopAddMoneyAnim()
    local x
    if uid == UserInfo.getInstance():getUid() then
        x = -147
    else
        x = 147
    end
    self.mAddMoneyAnim = new(Text,"+"..add_money,width, height, align, fontName, 34, 255, 220, 115)
    self.mAddMoneyAnim:setAlign(kAlignTop)
    self.mAddMoneyAnim:addPropTranslate(1, kAnimNormal, 1000, -1, x, x, 115, 86)
    local anim = self.mAddMoneyAnim:addPropTransparency(2, kAnimNormal, 200, 1000, 1, 0)
    if anim then
        anim:setEvent(self,function()
            self:stopAddMoneyAnim()
        end)
    end
    self.m_root:getChildByName("bg"):addChild(self.mAddMoneyAnim)
end

function ForestallWaitDialog320:stopAddMoneyAnim()
    if self.mAddMoneyAnim then
        delete(self.mAddMoneyAnim)
        self.mAddMoneyAnim = nil
    end
end
--endregion
