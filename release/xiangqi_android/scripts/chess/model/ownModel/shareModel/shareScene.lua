--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23

require(BASE_PATH.."chessScene");
require("util/lua_util_function");

ShareScene = class(ChessScene);

ShareScene.s_controls = 
{
    back_btn                    = 1;
    title_icon                  = 2;
    share_view                  = 3;
    teapot_dec                  = 4;
    version_text                = 5;
    qr_code                     = 6;
    sms_btn                     = 7;
    pyq_btn                     = 8;
    wechat_btn                  = 9;
    weibo_btn                   = 10;
    qq_btn                      = 11;
}

ShareScene.s_cmds = 
{
    update_share_view          = 1;
}

ShareScene.DEFAULT_TEXT = "我和小伙伴都在玩博雅中国象棋，来加入我们吧"; --我的游戏id是1234567890，快来和我一起对弈吧

ShareScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = ShareScene.s_controls;
    self:create();
end 

ShareScene.resume = function(self)
    ChessScene.resume(self);
--    self:removeAnimProp();
--    self:resumeAnimStart();
    if self.m_qr_code_url then
        self.m_qr_code:setUrlImage(self.m_qr_code_url);
    end
end

ShareScene.pause = function(self)
	ChessScene.pause(self);
    self:removeAnimProp();
--    self:pauseAnimStart();
end 

ShareScene.dtor = function(self)
    delete(self.anim_start);
    delete(self.anim_end);

end 

ShareScene.removeAnimProp = function(self)
    if self.m_anim_prop_need_remove then
--        self.m_share_view:removeProp(1);
        self.m_title_icon:removeProp(1);
--        self.m_back_btn:removeProp(1);
        self.m_leaf_left:removeProp(1);
        self.m_anim_prop_need_remove = false;
    end
--    self.m_top_view:removeProp(1);
--    self.m_more_btn:removeProp(1);
--    self.m_bottom_view:removeProp(1);
end

ShareScene.setAnimItemEnVisible = function(self,ret)
    self.m_leaf_left:setVisible(ret);
--    self.right_leaf:setVisible(ret);
end

ShareScene.resumeAnimStart = function(self,lastStateObj,timer)
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;
    delete(self.anim_start);
    self.anim_start = new(AnimInt,kAnimNormal,0,1,delay,-1);
    if self.anim_start then
        self.anim_start:setEvent(self,function()
            self:setAnimItemEnVisible(true);
            delete(self.anim_start);
        end);
    end
--    self.m_share_view:addPropTransparency(1,kAnimNormal,duration,delay,0,1);
    local lw,lh = self.m_leaf_left:getSize();
    self.m_leaf_left:addPropTranslate(1, kAnimNormal, waitTime, delay, -lw, 0, -10, 0);
    local tw,th = self.m_title_icon:getSize();
    local anim = self.m_title_icon:addPropTranslate(1, kAnimNormal, waitTime, delay, 0, 0, -th, 0);
    if anim then
        anim:setEvent(self,function()
            self.m_anim_prop_need_remove = true;
            self:removeAnimProp();
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end  
        end);   
    end
end

ShareScene.pauseAnimStart = function(self,newStateObj,timer)
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;
    delete(self.anim_end);
    self.anim_end = new(AnimInt,kAnimNormal,0,1,delay,-1);
    if self.anim_end then
        self.anim_end:setEvent(self,function()
            self.m_anim_prop_need_remove = true;
            self:removeAnimProp();
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end  
            delete(self.anim_end);
        end);
    end

    local lw,lh = self.m_leaf_left:getSize();
    self.m_leaf_left:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, -lw, 0, -10);
    local w,h = self.m_title_icon:getSize();
    local anim = self.m_title_icon:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, 0, 0, -h);
    if anim then
        anim:setEvent(self,function()
            self:setAnimItemEnVisible(false);
        end);
    end
end

---------------------- func --------------------
ShareScene.create = function(self)
	self.m_back_btn = self:findViewById(self.m_ctrls.back_btn);
	self.m_title_icon = self:findViewById(self.m_ctrls.title_icon);
    self.m_share_view = self:findViewById(self.m_ctrls.share_view);
    self.m_version_text = self:findViewById(self.m_ctrls.version_text);
    self.m_version_text:setText("版本号："..kLuaVersion);
    self.m_qr_code = self:findViewById(self.m_ctrls.qr_code);
    self.m_leaf_left = self.m_root:getChildByName("bamboo_left");
    self.m_qr_code_url,self.m_qr_download_url = UserInfo.getInstance():getGameShareUrl();

    self.share_tab = {};
    local tab = {};
    if not self.m_qr_download_url then return end
    tab.download_url = self.m_qr_download_url;
    tab.description = ShareScene.DEFAULT_TEXT;
    self.share_tab = tab;

end

ShareScene.onBackAction = function(self)
    self:requestCtrlCmd(ShareController.s_cmds.onBack);
end


if kPlatform == kPlatformIOS then
    ShareScene.onSmsBtnClick = function(self)
        if self.m_qr_download_url then
            print_string("share_text_msg = " .. self.m_qr_download_url);
            dict_set_string(SHARE_TEXT_TO_SMS_MSG , SHARE_TEXT_TO_SMS_MSG .. kparmPostfix , self.m_qr_download_url);
            call_native(SHARE_TEXT_TO_SMS_MSG);
        end
    end

    ShareScene.onPyqBtnClick = function(self)
        if self.m_qr_download_url then
            print_string("share_text_msg = " .. self.m_qr_download_url);
            local post_data = {};
            if self.m_qr_code:getFile() then
                print_string("share_img_msg = " .. self.m_qr_code:getFile());
                post_data.img = self.m_qr_code:getFile();
            end
            post_data.url = self.m_qr_download_url;
            post_data.title = "博雅中国象棋";
            post_data.description = "给最好的朋友，推荐最好的象棋!";
            post_data.isToSession = false;      
            dict_set_string(SHARE_TEXT_TO_PYQ_MSG , SHARE_TEXT_TO_PYQ_MSG .. kparmPostfix , json.encode(post_data));
            call_native(SHARE_TEXT_TO_PYQ_MSG);
        end
    end

    ShareScene.onWechatBtnClick = function(self)
        if self.m_qr_download_url then
            print_string("share_text_msg = " .. self.m_qr_download_url);
            local post_data = {};
            if self.m_qr_code:getFile() then
                print_string("share_img_msg = " .. self.m_qr_code:getFile());
                post_data.img = self.m_qr_code:getFile();
            end
            post_data.url = self.m_qr_download_url;
            post_data.title = "博雅中国象棋";
            post_data.description = "给最好的朋友，推荐最好的象棋!";  
            post_data.isToSession = true;
            dict_set_string(SHARE_TEXT_TO_WEICHAT_MSG , SHARE_TEXT_TO_WEICHAT_MSG .. kparmPostfix , json.encode(post_data));
            call_native(SHARE_TEXT_TO_WEICHAT_MSG);
        end
    end
    ShareScene.onWeiboBtnClick = function(self)
        if self.m_qr_download_url then
            print_string("share_text_msg = " .. self.m_qr_download_url);
            local post_data = {};
            if self.m_qr_code:getFile() then
                print_string("share_img_msg = " .. self.m_qr_code:getFile());
                post_data.img = self.m_qr_code:getFile();
            end
            post_data.url = self.m_qr_download_url;
            dict_set_string(SHARE_TEXT_TO_WEIBO_MSG , SHARE_TEXT_TO_WEIBO_MSG .. kparmPostfix , json.encode(post_data));
            call_native(SHARE_TEXT_TO_WEIBO_MSG);
        end
    end

    ShareScene.onQQBtnClick = function(self)
        if self.m_qr_download_url then
            local post_data = {};
            if self.m_qr_code:getFile() then
                post_data.img = self.m_qr_code:getFile();
            end
            post_data.url = self.m_qr_download_url;
            post_data.title = "博雅中国象棋";
            post_data.description = "给最好的朋友，推荐最好的象棋!";  
            dict_set_string(SHARE_TEXT_TO_QQ_MSG , SHARE_TEXT_TO_QQ_MSG .. kparmPostfix , json.encode(post_data));
            call_native(SHARE_TEXT_TO_QQ_MSG);
        end
    end
else
    ShareScene.onSmsBtnClick = function(self)
        if self.m_qr_download_url then
            print_string("share_text_msg = " .. self.m_qr_download_url);
--            dict_set_string(SHARE_TEXT_MSG , SHARE_TEXT_MSG .. kparmPostfix , self.m_qr_download_url);
            dict_set_string(SHARE_TEXT_MSG , SHARE_TEXT_MSG .. kparmPostfix , json.encode(self.share_tab));
            call_native(SHARE_TEXT_TO_SMS_MSG);
        end
    end

    ShareScene.onPyqBtnClick = function(self)
        if self.m_qr_download_url then
            print_string("share_text_msg = " .. self.m_qr_download_url);
--            if self.m_qr_code:getFile() then
--                print_string("share_img_msg = " .. self.m_qr_code:getFile());
--                dict_set_string(SHARE_IMG_MSG , SHARE_IMG_MSG .. kparmPostfix , self.m_qr_code:getFile());
--            end
--            dict_set_string(SHARE_TEXT_MSG , SHARE_TEXT_MSG .. kparmPostfix , self.m_qr_download_url);
            dict_set_string(SHARE_TEXT_MSG , SHARE_TEXT_MSG .. kparmPostfix , json.encode(self.share_tab));
            call_native(SHARE_TEXT_TO_PYQ_MSG);
        end
    end

    ShareScene.onWechatBtnClick = function(self)
        if self.m_qr_download_url then
            print_string("share_text_msg = " .. self.m_qr_download_url);
--            if self.m_qr_code:getFile() then
--                print_string("share_img_msg = " .. self.m_qr_code:getFile());
--                dict_set_string(SHARE_IMG_MSG , SHARE_IMG_MSG .. kparmPostfix , self.m_qr_code:getFile());
--            end
--            dict_set_string(SHARE_TEXT_MSG , SHARE_TEXT_MSG .. kparmPostfix , self.m_qr_download_url);
            dict_set_string(SHARE_TEXT_MSG , SHARE_TEXT_MSG .. kparmPostfix , json.encode(self.share_tab));
            call_native(SHARE_TEXT_TO_WEICHAT_MSG);
        end
    end

    ShareScene.onWeiboBtnClick = function(self)
        if self.m_qr_download_url then
            print_string("share_text_msg = " .. self.m_qr_download_url);
--            dict_set_string(SHARE_TEXT_MSG , SHARE_TEXT_MSG .. kparmPostfix , self.m_qr_download_url);
            dict_set_string(SHARE_TEXT_MSG , SHARE_TEXT_MSG .. kparmPostfix , json.encode(self.share_tab));
            call_native(SHARE_TEXT_TO_WEIBO_MSG);
        end
    end

    ShareScene.onQQBtnClick = function(self)
        if self.m_qr_download_url then
            print_string("share_text_msg = " .. self.m_qr_download_url);
--            if self.m_qr_code:getFile() then
--                print_string("share_img_msg = " .. self.m_qr_code:getFile());
--                dict_set_string(SHARE_IMG_MSG , SHARE_IMG_MSG .. kparmPostfix , self.m_qr_code:getFile());
--            end
--            dict_set_string(SHARE_TEXT_MSG , SHARE_TEXT_MSG .. kparmPostfix , self.m_qr_download_url);
            dict_set_string(SHARE_TEXT_MSG , SHARE_TEXT_MSG .. kparmPostfix , json.encode(self.share_tab));
            call_native(SHARE_TEXT_TO_QQ_MSG);
        end
    end
end;

---------------------- config ------------------
ShareScene.s_controlConfig = {
    [ShareScene.s_controls.back_btn]                          = {"back_btn"};
    [ShareScene.s_controls.title_icon]                        = {"title_icon"};
    [ShareScene.s_controls.share_view]                        = {"share_view"};
    [ShareScene.s_controls.teapot_dec]                        = {"teapot_dec"};
    [ShareScene.s_controls.version_text]                      = {"share_view","version_text"};
    [ShareScene.s_controls.qr_code]                           = {"share_view","qr_code_bg","qr_code"};
    [ShareScene.s_controls.sms_btn]                           = {"share_view","share_item","sms_btn"};
    [ShareScene.s_controls.pyq_btn]                           = {"share_view","share_item","pyq_btn"};
    [ShareScene.s_controls.wechat_btn]                        = {"share_view","share_item","wechat_btn"};
    [ShareScene.s_controls.weibo_btn]                         = {"share_view","share_item","weibo_btn"};
    [ShareScene.s_controls.qq_btn]                            = {"share_view","share_item","qq_btn"};

}

ShareScene.s_controlFuncMap = {
    [ShareScene.s_controls.back_btn]                        = ShareScene.onBackAction;
    [ShareScene.s_controls.sms_btn]                         = ShareScene.onSmsBtnClick;
    [ShareScene.s_controls.pyq_btn]                         = ShareScene.onPyqBtnClick;
    [ShareScene.s_controls.wechat_btn]                      = ShareScene.onWechatBtnClick;
    [ShareScene.s_controls.weibo_btn]                       = ShareScene.onWeiboBtnClick;
    [ShareScene.s_controls.qq_btn]                          = ShareScene.onQQBtnClick;

};

ShareScene.s_cmdConfig =
{
}