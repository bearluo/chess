--region NewFile_1.lua
--Author : FordFan
--Date   : 2016/4/26
--好友邀请分享弹窗

ShareInviteDialog = class();

require(VIEW_PATH .. "share_dailog_view");
require("gameBase/gameLayer");
require("chess/util/statisticsManager");


ShareInviteDialog = class(GameLayer,false);

ShareInviteDialog.ANIM_TIME = 320; -- 单位毫秒
ShareInviteDialog.s_dialogLayer = nil;
ShareInviteDialog.DEFAULT_TEXT = "我的游戏id是" .. UserInfo.getInstance():getUid() .. "，快来和我一起对弈吧";


function ShareInviteDialog.getInstance()
    if not ShareInviteDialog.s_instance then
        ShareInviteDialog.s_instance = new(ShareInviteDialog);
    end
    return ShareInviteDialog.s_instance;
end

function ShareInviteDialog:ctor()
    super(self,share_dailog_view);
    if not ShareInviteDialog.s_dialogLayer then
        ShareInviteDialog.s_dialogLayer = new(Node);
        ShareInviteDialog.s_dialogLayer:addToRoot();
        ShareInviteDialog.s_dialogLayer:setLevel(1);     
        ShareInviteDialog.s_dialogLayer:setFillParent(true,true);
    end
    ShareInviteDialog.s_dialogLayer:addChild(self);
    self:setFillParent(true,true);
    self.m_root:setLevel(1);
    self.m_root_view = self.m_root;
    self.is_dismissing = false;
    self:initView();
    self:setVisible(false);
end

function ShareInviteDialog:dtor()
    delete(self.m_root_view);
    self.m_root_view = nil;
end

function ShareInviteDialog:isShowing()
    return self:getVisible();
end

function ShareInviteDialog:show()
    self.is_dismissing = false;
    self:removeViewProp();
    local w,h = self.m_dialog_view:getSize();
    
    local anim_start = self.m_dialog_view:addPropTranslate(1,kAnimNormal,ShareInviteDialog.ANIM_TIME,-1,0,0,h,0);
    self:setVisible(true);
    if anim_start then
        anim_start:setEvent(self,function()
            self.m_dialog_view:removeProp(1);
        end);
    end
end

function ShareInviteDialog:dismiss()
    --防止多次点击显示多次动画
    if self.is_dismissing then
        return;
    end
    self.is_dismissing = true;
    self:removeViewProp();
    local w,h = self.m_dialog_view:getSize();
    local anim_end = self.m_dialog_view:addPropTranslate(1,kAnimNormal,ShareInviteDialog.ANIM_TIME,-1,0,0,0,h);
    self.m_root_view:addPropTransparency(1,kAnimNormal,ShareInviteDialog.ANIM_TIME,-1,1,0);
    if anim_end then
        anim_end:setEvent(self,function()
            self:setVisible(false);
            self.m_dialog_view:removeProp(1);
            self.m_root_view:removeProp(1);
        end);
    end
end

function ShareInviteDialog:initView()
    -- 灰色背景
    self.m_bg_black = self.m_root_view:getChildByName("bg_black");
    self.m_bg_black:setEventTouch(self,self.dismiss);

    self.m_dialog_view = self.m_root_view:getChildByName("bg");
    self.m_dialog_view:setEventTouch(nil,function() end);

    self.m_share_view = self.m_dialog_view:getChildByName("share_view");
    self.m_wechat_btn = self.m_share_view:getChildByName("wechat"):getChildByName("btn");
    self.m_pyq_btn    = self.m_share_view:getChildByName("pyq"):getChildByName("btn");
    self.m_qq_btn     = self.m_share_view:getChildByName("qq"):getChildByName("btn");
    self.m_weibo_btn  = self.m_share_view:getChildByName("weibo"):getChildByName("btn");
    self.m_sms_btn    = self.m_share_view:getChildByName("sms"):getChildByName("btn");

    self.m_wechat_btn:setOnClick(self,self.onWechatBtnClick);
    self.m_pyq_btn:setOnClick(self,self.onPyqBtnClick);
    self.m_qq_btn:setOnClick(self,self.onQQBtnClick);
    self.m_weibo_btn:setOnClick(self,self.onWeiboBtnClick);
    self.m_sms_btn:setOnClick(self,self.onSmsBtnClick);


    self.m_qr_code_url,self.m_qr_download_url = UserInfo.getInstance():getGameShareUrl();
    self.share_tab = {};
    local tab = {};
    if not self.m_qr_download_url then return end
    if kPlatform == kPlatformIOS then 
        tab.url = self.m_qr_download_url;
        tab.title = "博雅中国象棋";
        tab.description = ShareInviteDialog.DEFAULT_TEXT;
    else
        tab.download_url = self.m_qr_download_url;
        tab.description = ShareInviteDialog.DEFAULT_TEXT;
    end
 
    self.share_tab = tab;
end

--移除控件属性
function ShareInviteDialog:removeViewProp()

    if not self.m_dialog_view:checkAddProp(1) then
        self.m_dialog_view:removeProp(1);
    end

    if not self.m_root_view:checkAddProp(1) then
        self.m_root_view:removeProp(1);
    end
end

function ShareInviteDialog:onSmsBtnClick()
    self:dismiss();
    if self.m_qr_download_url then
        self:onEventStat(StatisticsManager.SHARE_WAY_SMS);
        dict_set_string(SHARE_TEXT_TO_SMS_MSG , SHARE_TEXT_TO_SMS_MSG .. kparmPostfix , json.encode(self.share_tab));
        call_native(SHARE_TEXT_TO_SMS_MSG);
    end
end

function ShareInviteDialog:onPyqBtnClick()
    self:dismiss();
    if self.m_qr_download_url then
        self:onEventStat(StatisticsManager.SHARE_WAY_PYQ);
        dict_set_string(SHARE_TEXT_TO_PYQ_MSG , SHARE_TEXT_TO_PYQ_MSG .. kparmPostfix , json.encode(self.share_tab));
        call_native(SHARE_TEXT_TO_PYQ_MSG);
    end
end

function ShareInviteDialog:onWechatBtnClick()
    self:dismiss();
    if self.m_qr_download_url then
        self:onEventStat(StatisticsManager.SHARE_WAY_WECHAT);
        dict_set_string(SHARE_TEXT_TO_WEICHAT_MSG , SHARE_TEXT_TO_WEICHAT_MSG .. kparmPostfix , json.encode(self.share_tab));
        call_native(SHARE_TEXT_TO_WEICHAT_MSG);
    end
end

function ShareInviteDialog:onWeiboBtnClick()
    self:dismiss();
    if self.m_qr_download_url then
        self:onEventStat(StatisticsManager.SHARE_WAY_WEIBO);
        dict_set_string(SHARE_TEXT_TO_WEIBO_MSG , SHARE_TEXT_TO_WEIBO_MSG .. kparmPostfix , json.encode(self.share_tab));
        call_native(SHARE_TEXT_TO_WEIBO_MSG);
    end
end

function ShareInviteDialog:onQQBtnClick()
    self:dismiss();
    if self.m_qr_download_url then
        self:onEventStat(StatisticsManager.SHARE_WAY_QQ);
        dict_set_string(SHARE_TEXT_TO_QQ_MSG , SHARE_TEXT_TO_QQ_MSG .. kparmPostfix , json.encode(self.share_tab));     
        call_native(SHARE_TEXT_TO_QQ_MSG);
    end
end

function ShareInviteDialog:onEventStat(way)
    StatisticsManager.getInstance():onCountInviteFriends(way);
end