--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23

require(BASE_PATH.."chessScene");


AssetsScene = class(ChessScene);

AssetsScene.s_controls = 
{
    back_btn                    = 1;
    title_icon                  = 2;
    assets_view                 = 3;
    teapot_dec                  = 4;
}

AssetsScene.s_cmds = 
{
}




AssetsScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = AssetsScene.s_controls;
    self:create();
end 

AssetsScene.resume = function(self)
    ChessScene.resume(self);
    self:assetsUpdateView();
--    self:removeAnimProp();
--    self:resumeAnimStart();
end

AssetsScene.isShowBangdinDialog = false;

AssetsScene.pause = function(self)
	ChessScene.pause(self);
    self:removeAnimProp();
--    self:pauseAnimStart();
end 

AssetsScene.dtor = function(self)
    delete(self.anim_start);
    delete(self.anim_end);
end 

AssetsScene.removeAnimProp = function(self)

    if self.m_anim_prop_need_remove then
        self.m_assets_view:removeProp(1);
        self.m_title_icon:removeProp(1);
        self.m_leaf_left:removeProp(1);
--        self.m_back_btn:removeProp(1);
    --    self.m_top_view:removeProp(1);
    --    self.m_more_btn:removeProp(1);
    --    self.m_bottom_view:removeProp(1);
        self.m_anim_prop_need_remove = false;
    end
end

AssetsScene.setAnimItemEnVisible = function(self,ret)
    self.m_leaf_left:setVisible(ret);
--    self.right_leaf:setVisible(ret);
end


AssetsScene.resumeAnimStart = function(self,lastStateObj,timer)
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

    self.m_assets_view:addPropTransparency(1,kAnimNormal,waitTime,delay,0,1);
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
--   local w,h = self.m_scroll_view:getSize();
--   local x,y = self.m_scroll_view:getPos();
--   self.m_scroll_view:addPropTranslate(1, kAnimNormal, duration, delay, 0, 0, -h-y, 0);

   -- 下部动画
--   local w,h = self.m_bottom_menu:getSize();
--   self.m_bottom_menu:addPropTranslate(1, kAnimNormal, duration, delay, 0, 0, h, 0);
   -- 
   
--   self.m_back_btn:addPropTransparency(1,kAnimNormal,duration,delay,0,1);
--   self.m_bottom_view:addPropTransparency(1,kAnimNormal,duration,delay,0,1);
--   self.m_top_view:addPropTransparency(1,kAnimNormal,duration,delay,0,1);
end

AssetsScene.pauseAnimStart = function(self,newStateObj,timer)
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

    self.m_assets_view:addPropTransparency(1,kAnimNormal,waitTime,-1,1,0);
    local lw,lh = self.m_leaf_left:getSize();
    self.m_leaf_left:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, -lw, 0, -10);
    local w,h = self.m_title_icon:getSize();
    local anim = self.m_title_icon:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, 0, 0, -h);
    if anim then
        anim:setEvent(self,function()
            self:setAnimItemEnVisible(false);
        end);
    end
--   local w,h = self.m_scroll_view:getSize();
--   local x,y = self.m_scroll_view:getPos();
--   self.m_scroll_view:addPropTranslate(1, kAnimNormal, duration, delay, 0, 0, 0, -h-y);
   -- 下部动画
--   local w,h = self.m_bottom_menu:getSize();
--   self.m_bottom_menu:addPropTranslate(1, kAnimNormal, duration, delay, 0, 0, 0, h);
   -- 

--   self.m_back_btn:addPropTransparency(1,kAnimNormal,duration,delay,1,0);
--   self.m_bottom_view:addPropTransparency(1,kAnimNormal,duration,delay,1,0);
--   self.m_top_view:addPropTransparency(1,kAnimNormal,duration,delay,1,0);
end

---------------------- func --------------------
AssetsScene.create = function(self)
	self.m_back_btn = self:findViewById(self.m_ctrls.back_btn);
	self.m_title_icon = self:findViewById(self.m_ctrls.title_icon);
    self.m_leaf_left = self.m_root:getChildByName("bamboo_left");

    self.m_assets_view = self:findViewById(self.m_ctrls.assets_view);

    self.m_assets_mall_btn = self.m_assets_view:getChildByName("mall_btn");
    self.m_assets_mall_btn:setOnClick(self,self.onAssetsMallBtnClick);

    self.m_assets_content_view = self.m_assets_view:getChildByName("assets_content_view");
    --ios审核关闭元宝相关
    self.m_yuanbao_item = self.m_assets_content_view:getChildByName("yuanbao_item");
    self.m_soul_item = self.m_assets_content_view:getChildByName("soul_item");
    if kPlatform == kPlatformIOS then
        if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
            self.m_yuanbao_item:setVisible(true);
            self.m_soul_item:setAlign(kAlignBottomRight);
            self.m_soul_item:setPos(72,23);
        else
            self.m_yuanbao_item:setVisible(false);
            self.m_soul_item:setAlign(kAlignTopRight);
            self.m_soul_item:setPos(72,29);
        end;
        self.m_assets_bccoin_text = self.m_assets_content_view:getChildByName("yuanbao_item"):getChildByName("item_text");
    else
        self.m_yuanbao_item:setVisible(false);
        self.m_soul_item:setAlign(kAlignTopRight);
        self.m_soul_item:setPos(72,29);            
    end;
    self.m_assets_gold_text = self.m_assets_content_view:getChildByName("gold_item"):getChildByName("item_text");
    self.m_assets_soul_text = self.m_assets_content_view:getChildByName("soul_item"):getChildByName("item_text");
    self.m_assets_tips_text = self.m_assets_content_view:getChildByName("tips_item"):getChildByName("item_text");
    self.m_assets_undo_text = self.m_assets_content_view:getChildByName("undo_item"):getChildByName("item_text");
    self.m_assets_relive_text = self.m_assets_content_view:getChildByName("relive_item"):getChildByName("item_text");
end

AssetsScene.assetsUpdateView = function(self)
    self.m_assets_gold_text:setText(UserInfo.getInstance():getMoney());
    if kPlatform == kPlatformIOS then
        self.m_assets_bccoin_text:setText(UserInfo.getInstance():getBccoin());
    end;
    self.m_assets_soul_text:setText(UserInfo.getInstance():getSoulCount());
    self.m_assets_tips_text:setText("剩:"..UserInfo.getInstance():getTipsNum());
    self.m_assets_undo_text:setText("剩:"..UserInfo.getInstance():getUndoNum());
    self.m_assets_relive_text:setText("剩:"..UserInfo.getInstance():getReviveNum());
end

AssetsScene.onBackAction = function(self)
    self:requestCtrlCmd(AssetsController.s_cmds.onBack);
end

AssetsScene.onAssetsMallBtnClick = function(self)
    StateMachine.getInstance():pushState(States.Mall,StateMachine.STYPE_CUSTOM_WAIT);
end

---------------------- config ------------------
AssetsScene.s_controlConfig = {
    [AssetsScene.s_controls.back_btn]                          = {"back_btn"};
    [AssetsScene.s_controls.title_icon]                        = {"title_icon"};
    [AssetsScene.s_controls.assets_view]                       = {"assets_view"};
    [AssetsScene.s_controls.teapot_dec]                        = {"teapot_dec"};
}

AssetsScene.s_controlFuncMap = {
    [AssetsScene.s_controls.back_btn]                        = AssetsScene.onBackAction;
};

AssetsScene.s_cmdConfig =
{
}