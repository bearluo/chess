--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require(VIEW_PATH .. "forestall_dialog_view_320");
require(BASE_PATH.."chessDialogScene")
require("ui/scrollViewEx");

ForestallDialog320 = class(ChessDialogScene,false)

ForestallDialog320.s_controls = 
{
    btn_1 = 1;
    btn_2 = 2;
    btn_1_text = 3;
    btn_2_text = 4;
    no_fore_btn = 5;
    basechip = 6;
    anim_text = 7;
    rent = 8;
    my_add_money = 9;
    opp_add_money = 10;
};

ForestallDialog320.s_controlConfig = 
{
	[ForestallDialog320.s_controls.btn_1] = {"bg","btn_1"};
	[ForestallDialog320.s_controls.btn_2] = {"bg","btn_2"};
	[ForestallDialog320.s_controls.btn_1_text] = {"bg","btn_1","btn_1_text"};
    [ForestallDialog320.s_controls.btn_2_text] = {"bg","btn_2","btn_2_text"};
    [ForestallDialog320.s_controls.no_fore_btn] = {"bg","no_fore_btn"};
    [ForestallDialog320.s_controls.my_add_money] = {"bg","my_add_money"};
    [ForestallDialog320.s_controls.opp_add_money] = {"bg","opp_add_money"};
    [ForestallDialog320.s_controls.anim_text] = {"bg","no_fore_btn","no_fore_btn_text"};
};

ForestallDialog320.ctor = function(self)
    super(self,forestall_dialog_view_320);
    self.m_ctrls = ForestallDialog320.s_controls;
    self.m_btn_1 = self:findViewById(self.m_ctrls.btn_1);
    self.m_btn_1:setOnClick(self,self.onBtn1Click);
    self.m_btn_2 = self:findViewById(self.m_ctrls.btn_2);
    self.m_btn_2:setOnClick(self,self.onBtn2Click);
    self.m_noForeBtn = self:findViewById(self.m_ctrls.no_fore_btn);
    self.m_noForeBtn:setOnClick(self,self.onNoForeBtnClick);

    self.m_btnText1 = self:findViewById(self.m_ctrls.btn_1_text);
    self.m_btnText2 = self:findViewById(self.m_ctrls.btn_2_text);

    self.m_my_add_money = self:findViewById(self.m_ctrls.my_add_money);
    self.m_opp_add_money = self:findViewById(self.m_ctrls.opp_add_money);

    self.mTitleView = self.m_root:getChildByName("bg"):getChildByName("title_view")
    self.mFirstIcon = self.m_root:getChildByName("bg"):getChildByName("first_icon")
    
    self.m_animText = self:findViewById(self.m_ctrls.anim_text);
    self:setNeedBackEvent(false)
    self:setNeedMask(false)
    self.mDialogAnim = AnimDialogFactory.createMoveUpAnim(self)
end

function ForestallDialog320:dtor()
    self.mDialogAnim.stopAnim()
    self:stopAddMoneyAnim()
end

function ForestallDialog320:updateTitleView(num)
    num = tonumber(num) or 0
    self.mTitleView:removeAllChildren()
    local startPos = 0
    local txt1 = new(Text,"剩", width, height, align, fontName, 36, 240, 230, 210)
    txt1:setPos(startPos)
    startPos = txt1:getSize() + startPos
    self.mTitleView:addChild(txt1)
    local txt2 = new(Text,num .. "次", width, height, align, fontName, 36, 40, 200, 65)
    txt2:setPos(startPos)
    startPos = txt2:getSize() + startPos
    self.mTitleView:addChild(txt2)
    local txt3 = new(Text,"加注机会,加注多者抢", width, height, align, fontName, 36, 240, 230, 210)
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

ForestallDialog320.show = function(self,data)
    if not data then
        return;
    end
    self.m_data = data;
    self:setVisible(true);
    self.super.show(self,self.mDialogAnim.showAnim);

    self.m_btnText1:setText("加" .. data.opt_add_money1);
    self.m_btnText2:setText("加" .. data.opt_add_money2);
    if data.curr_uid == UserInfo.getInstance():getUid() then
        self.m_my_add_money:setText(data.cur_upraise)
        self.m_opp_add_money:setText(data.opp_upraise)
    else
        self.m_my_add_money:setText(data.opp_upraise)
        self.m_opp_add_money:setText(data.cur_upraise)
    end
    self:updateTitleView(data.surplus_cnt)

    local roomConfig = RoomProxy.getInstance():getCurRoomConfig();
    -- 获取按钮状态

    if self.m_data and self.m_data.byMultiplyBtn and roomConfig and roomConfig.beishu_level then
        self:initBtnStatus(self.m_data.byMultiplyBtn,roomConfig.beishu_level,self.m_data.pre_call_uid == 0)
    else
        self.m_btn_1:setOnClick(self,self.onBtn1Click);
        self.m_btn_2:setOnClick(self,self.onBtn2Click);
        self.m_btn_1:setGray(false);
        self.m_btn_2:setGray(false);
    end


    if data.timeout and (data.timeout == 0 or data.timeout < 0 )then
        data.timeout = 10;
    end
    self.m_time_out = data.timeout + os.time();
    self.m_animText:setText("不加注("..(self.m_time_out - os.time()).."s)");
    self.timeOutAnim = new(AnimInt,kAnimRepeat,0,1,1000,-1);
    self.timeOutAnim:setEvent(self,self.onAnimTime);
end
require("libs/bit");
--[Comment]
-- status ：金币不足配置
-- status1 : 允许点击配置
-- isFirst ： 是否是第一次抢先
function ForestallDialog320:initBtnStatus(status,status1,isFirst)
    
    local bits = bit.tobits(status);
    local bits2 = bit.tobits(status1)
    local offset = ( isFirst and 0 ) or 2;
    -- {0,0,0,0} 自1 别1 自2 别2
    self:initBtnStatusByData(self.m_btn_1,bits[1] or 0,bits[2] or 0,bits2[offset+2] or 0,self.onBtn1Click);
    self:initBtnStatusByData(self.m_btn_2,bits[3] or 0,bits[4] or 0,bits2[offset+1] or 0,self.onBtn2Click);
end
--[Comment]
-- btn 按钮 mbtn 我的状态 obtn 对手状态 cbtn 是否可以点击
function ForestallDialog320:initBtnStatusByData(btn,mbtn,obtn,cbtn,click)
    if cbtn ~= 1 then
        btn:setOnClick(self,function()
            ChessToastManager.getInstance():showSingle("本场次不支持该功能");
        end);
        btn:setGray(true);
        return;   
    end
    if mbtn ~= 1 then
        btn:setOnClick(self,function()
            ChessToastManager.getInstance():showSingle("您的金币不足");
        end);
        btn:setGray(true);
    else
        btn:setOnClick(self,click);
        btn:setGray(false);
    end
end

ForestallDialog320.onAnimTime = function(self)
    if self.m_time_out and self.m_time_out > os.time() then
        self.m_animText:setText("不加注("..(self.m_time_out - os.time()).."s)");
    else
        if self.timeOutAnim then
            delete(self.timeOutAnim);
            self.timeOutAnim = nil;
            self:onNoForeBtnClick();
        end
    end
end

ForestallDialog320.dismiss = function(self,flag)
    if self.timeOutAnim then
        delete(self.timeOutAnim);
        self.timeOutAnim = nil;
    end
    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
end

ForestallDialog320.dtor = function(self)
	if self.timeOutAnim then
        delete(self.timeOutAnim);
        self.timeOutAnim = nil;
    end
    self.mDialogAnim.stopAnim()
end

ForestallDialog320.setBtn1Func = function(self,obj,func)
    self.m_btn1Func = func;
    self.m_btn1Obj = obj;
end

ForestallDialog320.setBtn2Func = function(self,obj,func)
    self.m_btn2Func = func;
    self.m_btn2Obj = obj;
end

ForestallDialog320.setNoForeBtnFunc = function(self,obj,func)
    self.m_noForeBtnFunc = func;
    self.m_noForeBtnObj = obj;
end

ForestallDialog320.onBtn1Click = function(self)
    self:dismiss();
    if self.timeOutAnim then
        delete(self.timeOutAnim);
        self.timeOutAnim = nil;
    end
    self:startAddMoneyAnim(UserInfo.getInstance():getUid(),self.m_data.opt_add_money1)
    if self.m_btn1Func and self.m_btn1Obj then
        self.m_btn1Func(self.m_btn1Obj,self.m_data.opt_add_money1);
    end
end

ForestallDialog320.onBtn2Click = function(self)
    self:dismiss();
    if self.timeOutAnim then
        delete(self.timeOutAnim);
        self.timeOutAnim = nil;
    end
    self:startAddMoneyAnim(UserInfo.getInstance():getUid(),self.m_data.opt_add_money2)
    if self.m_btn2Func and self.m_btn2Obj then
        self.m_btn2Func(self.m_btn2Obj,self.m_data.opt_add_money2);
    end
end

ForestallDialog320.onNoForeBtnClick = function(self)
    self:dismiss();
    if self.timeOutAnim then
        delete(self.timeOutAnim);
        self.timeOutAnim = nil;
    end
    if self.m_noForeBtnFunc and self.m_noForeBtnObj then
        self.m_noForeBtnFunc(self.m_noForeBtnObj);
    end
end

function ForestallDialog320:startAddMoneyAnim(uid,add_money)
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

function ForestallDialog320:stopAddMoneyAnim()
    if self.mAddMoneyAnim then
        delete(self.mAddMoneyAnim)
        self.mAddMoneyAnim = nil
    end
end
--endregion
