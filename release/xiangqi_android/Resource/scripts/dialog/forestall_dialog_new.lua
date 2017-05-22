--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require(VIEW_PATH .. "forestall_dialog_view_new");
require(BASE_PATH.."chessDialogScene")
require("ui/scrollViewEx");

ForestallDialogNew = class(ChessDialogScene,false)

ForestallDialogNew.s_controls = 
{
    btn_1 = 1;
    btn_2 = 2;
    btn_1_text = 3;
    btn_2_text = 4;
    no_fore_btn = 5;
    basechip = 6;
    anim_text = 7;
    rent = 8;
};

ForestallDialogNew.s_controlConfig = 
{
	[ForestallDialogNew.s_controls.btn_1] = {"bg","btn_1"};
	[ForestallDialogNew.s_controls.btn_2] = {"bg","btn_2"};
	[ForestallDialogNew.s_controls.btn_1_text] = {"bg","btn_1","btn_1_text"};
    [ForestallDialogNew.s_controls.btn_2_text] = {"bg","btn_2","btn_2_text"};
    [ForestallDialogNew.s_controls.no_fore_btn] = {"bg","no_fore_btn"};
    [ForestallDialogNew.s_controls.basechip] = {"bg","basechip"};
    [ForestallDialogNew.s_controls.anim_text] = {"bg","anim_text"};
    [ForestallDialogNew.s_controls.rent] = {"bg","rent"};
};

ForestallDialogNew.ctor = function(self)
    super(self,forestall_dialog_view_new);
    self.m_ctrls = ForestallDialogNew.s_controls;
    self.m_btn_1 = self:findViewById(self.m_ctrls.btn_1);
    self.m_btn_1:setOnClick(self,self.onBtn1Click);
    self.m_btn_2 = self:findViewById(self.m_ctrls.btn_2);
    self.m_btn_2:setOnClick(self,self.onBtn2Click);
    self.m_noForeBtn = self:findViewById(self.m_ctrls.no_fore_btn);
    self.m_noForeBtn:setOnClick(self,self.onNoForeBtnClick);

    self.m_btnText1 = self:findViewById(self.m_ctrls.btn_1_text);
    self.m_btnText2 = self:findViewById(self.m_ctrls.btn_2_text);
    self.m_basechip = self:findViewById(self.m_ctrls.basechip);
    self.m_rent = self:findViewById(self.m_ctrls.rent);

    
    self.m_animText = self:findViewById(self.m_ctrls.anim_text);
    self.noticeDialog = new(ChioceDialog);
    self:setNeedBackEvent(false);
    self.mDialogAnim = AnimDialogFactory.createMoveUpAnim(self)
end

function ForestallDialogNew:dtor()
    delete(self.noticeDialog);
    self.mDialogAnim.stopAnim()
end

ForestallDialogNew.show = function(self,data)
    if not data then
        return;
    end
    self.m_data = data;
    self:setVisible(true);
    self.super.show(self,self.mDialogAnim.showAnim);
	kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);

    self.m_btnText1:setText(data.opt_beishu1.."倍抢先");
    self.m_btnText2:setText(data.opt_beishu2.."倍抢先");
    self.m_basechip:setText(data.curr_beishu.."倍");
    
    local roomConfig = RoomProxy.getInstance():getCurRoomConfig();
    -- 获取按钮状态

    if roomConfig and roomConfig.money then
        local money = (tonumber(roomConfig.money) or 0) * (tonumber(data.curr_beishu) or 0)
        local str = ""
        if money > 10000 then
            if money % 10000 == 0 then
                str = string.format("%dW金币",money/10000)
            else
                str = string.format("%.1fW金币",money/10000)
            end
        else
            str = string.format("%d金币",money)
        end
        self.m_rent:setText(str);
    end

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
    self.m_animText:setText("是否抢先下棋? ("..(self.m_time_out - os.time()).."s)");
    self.timeOutAnim = new(AnimInt,kAnimRepeat,0,1,1000,-1);
    self.timeOutAnim:setEvent(self,self.onAnimTime);
end
require("libs/bit");
--[Comment]
-- status ：金币不足配置
-- status1 : 允许点击配置
-- isFirst ： 是否是第一次抢先
function ForestallDialogNew:initBtnStatus(status,status1,isFirst)
    
    local bits = bit.tobits(status);
    local bits2 = bit.tobits(status1)
    local offset = ( isFirst and 0 ) or 2;
    -- {0,0,0,0} 自1 别1 自2 别2
    self:initBtnStatusByData(self.m_btn_1,bits[1] or 0,bits[2] or 0,bits2[offset+2] or 0,self.onBtn1Click);
    self:initBtnStatusByData(self.m_btn_2,bits[3] or 0,bits[4] or 0,bits2[offset+1] or 0,self.onBtn2Click);
end
--[Comment]
-- btn 按钮 mbtn 我的状态 obtn 对手状态 cbtn 是否可以点击
function ForestallDialogNew:initBtnStatusByData(btn,mbtn,obtn,cbtn,click)
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
    elseif obtn ~= 1 then
        btn:setOnClick(self,function(self)
            local message = "对方金币不足以支付该倍数金额，如胜利，实际所获金币将少于所应获得，是否继续抢先？"
	        self.noticeDialog:setMode(ChioceDialog.MODE_SURE);
	        self.noticeDialog:setPositiveListener(self,click);
            self.noticeDialog:setNegativeListener(nil);
	        self.noticeDialog:setMessage(message);
	        self.noticeDialog:show();
        end);
        btn:setGray(false);
    else
        btn:setOnClick(self,click);
        btn:setGray(false);
    end
end

ForestallDialogNew.onAnimTime = function(self)
    if self.m_time_out and self.m_time_out > os.time() then
        self.m_animText:setText("是否抢先下棋? ("..(self.m_time_out - os.time()).."s)");
    else
        if self.timeOutAnim then
            delete(self.timeOutAnim);
            self.timeOutAnim = nil;
            self:onNoForeBtnClick();
        end
    end
end

ForestallDialogNew.dismiss = function(self,flag)
    if self.timeOutAnim then
        delete(self.timeOutAnim);
        self.timeOutAnim = nil;
    end
--    self:setVisible(false);
    self.noticeDialog:dismiss();
    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
end

ForestallDialogNew.dtor = function(self)
	if self.timeOutAnim then
        delete(self.timeOutAnim);
        self.timeOutAnim = nil;
    end
    self.mDialogAnim.stopAnim()
end

ForestallDialogNew.setBtn1Func = function(self,obj,func)
    self.m_btn1Func = func;
    self.m_btn1Obj = obj;
end

ForestallDialogNew.setBtn2Func = function(self,obj,func)
    self.m_btn2Func = func;
    self.m_btn2Obj = obj;
end

ForestallDialogNew.setNoForeBtnFunc = function(self,obj,func)
    self.m_noForeBtnFunc = func;
    self.m_noForeBtnObj = obj;
end

ForestallDialogNew.onBtn1Click = function(self)
    self:dismiss();
    if self.timeOutAnim then
        delete(self.timeOutAnim);
        self.timeOutAnim = nil;
    end
    if self.m_btn1Func and self.m_btn1Obj then
        self.m_btn1Func(self.m_btn1Obj,self.m_data.opt_beishu1);
    end
end

ForestallDialogNew.onBtn2Click = function(self)
    self:dismiss();
    if self.timeOutAnim then
        delete(self.timeOutAnim);
        self.timeOutAnim = nil;
    end
    if self.m_btn2Func and self.m_btn2Obj then
        self.m_btn2Func(self.m_btn2Obj,self.m_data.opt_beishu2);
    end
end

ForestallDialogNew.onNoForeBtnClick = function(self)
    self:dismiss();
    if self.timeOutAnim then
        delete(self.timeOutAnim);
        self.timeOutAnim = nil;
    end
    if self.m_noForeBtnFunc and self.m_noForeBtnObj then
        self.m_noForeBtnFunc(self.m_noForeBtnObj);
    end
end

--endregion
