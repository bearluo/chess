--region common_msg_dialog.lua
--Author : BearLuo
--Date   : 2014/12/22
--此文件由[BabeLua]插件自动生成
require("core/scene");
require(VIEW_PATH .. "buy_level_msg_dialog");

BuyLevelMsgDialog = class();

BuyLevelMsgDialog.ctor = function(self)
    self.m_scene = new(Scene,buy_level_msg_dialog);
	self.m_root_view = self.m_scene:getRoot();
	self.m_dialog_bg = self.m_root_view:getChildByName("msg_dialog_bg");
    self.m_close_btn = self.m_dialog_bg:getChildByName("msg_dialog_close");
    self.m_content = self.m_dialog_bg:getChildByName("msg_dialog_content");
    self.m_fisrt_btn = self.m_dialog_bg:getChildByName("msg_first_btn");
    self.m_second_btn = self.m_dialog_bg:getChildByName("msg_second_btn");
    self.m_single_btn = self.m_dialog_bg:getChildByName("msg_single_btn");
    self.m_close_btn:setOnClick(self,self.onCloseClick);
    self.m_root_view:setVisible(false);
end

BuyLevelMsgDialog.setCloseOnClick = function(self,closeSelf,closeFun)
    self.m_closeSelf = closeSelf;
    self.m_closeFun = closeFun;
end

BuyLevelMsgDialog.init = function(self,fisrtSelf,firstFun,secondSelf,secondFun)
    if fisrtSelf and firstFun then
        self.m_fisrt_btn:setOnClick(fisrtSelf,firstFun);
    else
        self.m_fisrt_btn:setVisible(false);
    end

    if secondSelf and secondFun then
        self.m_second_btn:setOnClick(secondSelf,secondFun);
    else
        if fisrtSelf and firstFun then
            self.m_single_btn:setOnClick(fisrtSelf,firstFun);
            self.m_single_btn:setVisible(true);
        end
        self.m_fisrt_btn:setVisible(false);
        self.m_second_btn:setVisible(false);
    end
end

BuyLevelMsgDialog.isShowing = function(self)
    return self.m_root_view:getVisible();
end

BuyLevelMsgDialog.setVisible = function(self,isVisible)
    self.m_root_view:setVisible(isVisible);
end

BuyLevelMsgDialog.setMoney = function(self,money)
    self.m_content:setText(string.format("开通本层关卡，更多精彩内容等你来体验！%d金币可直接开通，金币不足点击获取金币可免费赚金币。",money));
end

BuyLevelMsgDialog.onCloseClick = function(self)
    self.m_root_view:setVisible(false);
    if self.m_closeSelf and self.m_closeFun then
        self.m_closeFun(self.m_closeSelf);
    end
end

BuyLevelMsgDialog.dtor = function(self)
    delete(self.m_scene);
	self.m_root_view = nil;
end

BuyLevelMsgDialog.getInstance = function()
    if not BuyLevelMsgDialog.instance then
        BuyLevelMsgDialog.instance = new(BuyLevelMsgDialog);
    end
    return BuyLevelMsgDialog.instance;
end

BuyLevelMsgDialog.hide = function(self)
    if BuyLevelMsgDialog.instance then
        BuyLevelMsgDialog.instance:setVisible(false);
    end
end

BuyLevelMsgDialog.show = function(fisrtSelf,firstFun,secondSelf,secondFun,closeSelf,closeFun)
    if BuyLevelMsgDialog.instance then
        delete(BuyLevelMsgDialog.instance);
        BuyLevelMsgDialog.instance = nil;
    end
    BuyLevelMsgDialog.getInstance():init(fisrtSelf,firstFun,secondSelf,secondFun);
    BuyLevelMsgDialog.getInstance():setCloseOnClick(closeSelf,closeFun);
    BuyLevelMsgDialog.getInstance():setVisible(true);
end


--endregion
