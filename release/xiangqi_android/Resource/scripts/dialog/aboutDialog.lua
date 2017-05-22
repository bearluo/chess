require(VIEW_PATH .. "about_dialog_view");
require(BASE_PATH.."chessDialogScene")

AboutDialog = class(ChessDialogScene,false)

function AboutDialog:ctor()
    super(self,about_dialog_view);

    self.m_root:getChildByName("cancel_btn"):setOnClick(self,self.dismiss)

    local contentBg = self.m_root:getChildByName("content_bg")

    self.mVersionName = contentBg:getChildByName("version_name")
    self.mVersionName:setText("版本号:" .. kLuaVersion)

    self.mBoyaaCom = contentBg:getChildByName("boyaa_com")
    self.mBoyaaCom:setEventTouch(self,function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
        if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
            self:gotoWebBoyaaCom()
        end
    end)
    
    self.mWechatBoyaaCom = contentBg:getChildByName("wechat_boyaa_com")
    self.mWechatBoyaaCom:setEventTouch(self,function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
        if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
            self:gotoWebWechatBoyaaCom()
        end
    end)
    
    self.mWeiboBoyaaCom = contentBg:getChildByName("weibo_boyaa_com")
    self.mWeiboBoyaaCom:setEventTouch(self,function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
        if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
            self:gotoWebWeiboBoyaaCom()
        end
    end)


    local shareView = contentBg:getChildByName("share_view")
    shareView:getChildByName("wechat"):setOnClick(self,self.onWechatBtnClick)
    shareView:getChildByName("pyq"):setOnClick(self,self.onPyqBtnClick)
    shareView:getChildByName("qq"):setOnClick(self,self.onQQBtnClick)
    shareView:getChildByName("weibo"):setOnClick(self,self.onWeiboBtnClick)
    shareView:getChildByName("sms"):setOnClick(self,self.onSmsBtnClick)
end

function AboutDialog:gotoWebBoyaaCom()
	local url = "https://www.boyaa.com";
	to_web_page(url);
end

function AboutDialog:gotoWebWechatBoyaaCom()
--    local url = "https://mp.weixin.qq.com/mp/profile_ext?action=home&__biz=MzAxMDY2NDY2Mg==&scene=110#wechat_redirect"
--    dict_set_string(TO_WECHAT_WEB_PAGE , TO_WECHAT_WEB_PAGE .. kparmPostfix , url);
--    call_native(TO_WECHAT_WEB_PAGE);
end

function AboutDialog:gotoWebWeiboBoyaaCom()
	local url = "http://weibo.com/2854338544";
	to_web_page(url);
end

function AboutDialog:getShareTab()
    local qr_code_url,qr_download_url = UserInfo.getInstance():getGameShareUrl()
    if not qr_download_url then return nil end
    local share_tab = {}
    share_tab.url = qr_download_url
    share_tab.title = "博雅中国象棋"
    share_tab.description = "我和小伙伴都在玩博雅中国象棋，来加入我们吧"
    return share_tab
end

AboutDialog.onSmsBtnClick = function(self)
    local tab = self:getShareTab()
    if tab then
        StatisticsManager.getInstance():onCountInviteFriends(StatisticsManager.SHARE_WAY_SMS);
        CommonShareDialog.shareShortUrl(tab,"sms",function(data)
            dict_set_string(SHARE_TEXT_TO_SMS_MSG , SHARE_TEXT_TO_SMS_MSG .. kparmPostfix , json.encode(data));
            call_native(SHARE_TEXT_TO_SMS_MSG);
        end)
    end
end

AboutDialog.onPyqBtnClick = function(self)
    local tab = self:getShareTab()
    if tab then
        StatisticsManager.getInstance():onCountInviteFriends(StatisticsManager.SHARE_WAY_PYQ);
        CommonShareDialog.shareShortUrl(tab,"pyq",function(data)
            dict_set_string(SHARE_TEXT_TO_PYQ_MSG , SHARE_TEXT_TO_PYQ_MSG .. kparmPostfix , json.encode(data));
            call_native(SHARE_TEXT_TO_PYQ_MSG);
        end)
    end
end

AboutDialog.onWechatBtnClick = function(self)
    local tab = self:getShareTab()
    if tab then
        StatisticsManager.getInstance():onCountInviteFriends(StatisticsManager.SHARE_WAY_WECHAT);
        CommonShareDialog.shareShortUrl(tab,"wechat",function(data)
            dict_set_string(SHARE_TEXT_TO_WEICHAT_MSG , SHARE_TEXT_TO_WEICHAT_MSG .. kparmPostfix , json.encode(data));
            call_native(SHARE_TEXT_TO_WEICHAT_MSG);
        end)
    end
end

AboutDialog.onWeiboBtnClick = function(self)
    local tab = self:getShareTab()
    if tab then
        StatisticsManager.getInstance():onCountInviteFriends(StatisticsManager.SHARE_WAY_WEIBO);
        CommonShareDialog.shareShortUrl(tab,"weibo",function(data)
            dict_set_string(SHARE_TEXT_TO_WEIBO_MSG , SHARE_TEXT_TO_WEIBO_MSG .. kparmPostfix , json.encode(data));
            call_native(SHARE_TEXT_TO_WEIBO_MSG);
        end)
    end
end

AboutDialog.onQQBtnClick = function(self)
    local tab = self:getShareTab()
    if tab then
        StatisticsManager.getInstance():onCountInviteFriends(StatisticsManager.SHARE_WAY_QQ);
        CommonShareDialog.shareShortUrl(tab,"QQ",function(data)
            dict_set_string(SHARE_TEXT_TO_QQ_MSG , SHARE_TEXT_TO_QQ_MSG .. kparmPostfix , json.encode(data));     
            call_native(SHARE_TEXT_TO_QQ_MSG);
        end)
    end
end