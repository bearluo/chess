--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23

require(BASE_PATH.."chessScene");


AboutScene = class(ChessScene);

AboutScene.step = 0.1;   --每次加减声音的大小
AboutScene.max  = 1.0;   --最大音量
AboutScene.min  = 0.0;    -- 最小音量

AboutScene.s_controls = 
{
    content_view                = 1;
    back_btn                    = 2;
    title_icon                  = 3;
    top_view                    = 4;
    version_text                = 5;
    privacy_policy_btn          = 6;
    terms_of_service_btn        = 7;
    bottom_view                 = 8;
    content_text                = 9;
}

AboutScene.s_cmds = 
{
}

AboutScene.s_about_text = {
"博雅互动国际有限公司及/或其附属公司竭力确保所提供之资料绝对准确可靠。亦不对由于资料不准确或疏漏而引致之损失或损害承担任何直接和间接责任（不论是民事侵权行为或合约责任或其他）。任何情况下博雅互动国际有限公司或其附属公司均不对因使用本网站资料而引致之损失或损害承担任何直接和间接责任。",
"博雅互动国际有限公司及/或其附属公司事先书面同意，不得更改、抄袭、传送、分发或复制本网站所载之资料；本公司保留透过法律途径追究因更改、抄袭、传送、分发及/或复制本网站所载之资料而引致任何损失或法律责任。"
}



AboutScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = AboutScene.s_controls;
    self:create();
end 

AboutScene.resume = function(self)
    ChessScene.resume(self);
--    self:removeAnimProp();
--    self:resumeAnimStart();
end

AboutScene.isShowBangdinDialog = false;

AboutScene.pause = function(self)
	ChessScene.pause(self);
    self:removeAnimProp();
--    self:pauseAnimStart();
end 

AboutScene.dtor = function(self)
    delete(self.anim_start);
    delete(self.anim_end);
end 

AboutScene.removeAnimProp = function(self)
    if self.m_anim_prop_need_remove then
--        self.m_content_view:removeProp(1);
        self.m_title_icon:removeProp(1);
--        self.m_back_btn:removeProp(1);
--        self.m_top_view:removeProp(1);
    --    self.m_more_btn:removeProp(1);
--        self.m_bottom_view:removeProp(1);
        self.m_leaf_left:removeProp(1);
        self.m_anim_prop_need_remove = false;
    end
end

AboutScene.setAnimItemEnVisible = function(self,ret)
    self.m_leaf_left:setVisible(ret);
end

AboutScene.resumeAnimStart = function(self,lastStateObj,timer)
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

AboutScene.pauseAnimStart = function(self,newStateObj,timer)
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
AboutScene.create = function(self)
	self.m_back_btn = self:findViewById(self.m_ctrls.back_btn);
	self.m_title_icon = self:findViewById(self.m_ctrls.title_icon);
	self.m_content_view = self:findViewById(self.m_ctrls.content_view);
	self.m_top_view = self:findViewById(self.m_ctrls.top_view);
    self.m_version_text = self.m_top_view:getChildByName("version_text");
	if kPlatform == kPlatformIOS then
        if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
            self.m_version_text:setVisible(true); 
            self.m_version_text:setText("版本号:"..kLuaVersion);
        else
            self.m_version_text:setVisible(false);
        end;
    else
        self.m_version_text:setVisible(true);
        self.m_version_text:setText("版本号:"..kLuaVersion);
    end;
    
	self.m_bottom_view = self:findViewById(self.m_ctrls.bottom_view);
    self.m_leaf_left = self.m_root:getChildByName("bamboo_left");
    local str = "";
    for i,v in ipairs(AboutScene.s_about_text) do
        str = str .. "    " .. v .."#l#l";
    end
    str = string.sub(str,1,-5);
--    str, width, height, align, fontName, fontSize, r, g, b, bAutoNewLine,lineSpace
    self.m_rich_context_text = new(RichText,str,572,669,kAlignTopLeft,nil,28,135,100,95,true,15);
    self.m_rich_context_text:setPos(0,51);
    self.m_content_view:getChildByName("scroll_view"):addChild(self.m_rich_context_text);
end


AboutScene.onBackAction = function(self)
    self:requestCtrlCmd(AboutController.s_cmds.onBack);
end

AboutScene.toPriPage = function(self)
	local url = "http://www.boyaa.com/mobile/PrivacyPolicy1.html";
	to_web_page(url);
end

AboutScene.toSerPage = function(self)
	local url = "http://www.boyaa.com/mobile/termsofservice1.html";
	to_web_page(url);
end

---------------------- config ------------------
AboutScene.s_controlConfig = {
    [AboutScene.s_controls.content_view]                      = {"content_view"};
    [AboutScene.s_controls.content_text]                      = {"content_view","content_text"};
    [AboutScene.s_controls.back_btn]                          = {"back_btn"};
    [AboutScene.s_controls.title_icon]                        = {"title_icon"};
    [AboutScene.s_controls.top_view]                          = {"top_view"};
    [AboutScene.s_controls.version_text]                      = {"top_view","version_text"};
    [AboutScene.s_controls.bottom_view]                       = {"bottom_view"};
    [AboutScene.s_controls.privacy_policy_btn]                = {"bottom_view","privacy_policy_btn"};
    [AboutScene.s_controls.terms_of_service_btn]              = {"bottom_view","terms_of_service_btn"};

}

AboutScene.s_controlFuncMap = {
    [AboutScene.s_controls.back_btn]                        = AboutScene.onBackAction;
    [AboutScene.s_controls.privacy_policy_btn]              = AboutScene.toPriPage;
    [AboutScene.s_controls.terms_of_service_btn]            = AboutScene.toSerPage;
};

AboutScene.s_cmdConfig =
{
}