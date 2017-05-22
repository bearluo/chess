---只能在 userinfo 场景调用
require(VIEW_PATH .. "change_head_icon_dialog");
require(BASE_PATH.."chessDialogScene");

ChangeHeadIconDialog = class(ChessDialogScene,false);

ChangeHeadIconDialog.ctor = function(self)
    super(self,change_head_icon_dialog);
	self.m_root_view = self.m_root;
    self.m_bg = self.m_root_view:getChildByName("bg");
    self.m_headIcon_bg = self.m_root_view:getChildByName("bg"):getChildByName("headIconBg");
    self.m_headIcon = new(Mask,"common/background/head_mask_bg_200.png","common/background/head_mask_bg_200.png");
    self.m_headIcon:setAlign(kAlignCenter);
    self.m_headIcon_bg:addChild(self.m_headIcon);
    self.m_defaultIconGroup = self.m_root_view:getChildByName("bg"):getChildByName("defaultIconGroup");
    self.m_confirm = self.m_root_view:getChildByName("bg"):getChildByName("confirm");
    self.m_customBtn = self.m_root_view:getChildByName("bg"):getChildByName("customBtn");
    self.m_close_btn = self.m_root_view:getChildByName("bg"):getChildByName("close_btn");

    self.m_confirm:setOnClick(self,self.onConfirmClick);
    self.m_customBtn:setOnClick(self,self.onCustomBtnClick);
    self.m_close_btn:setOnClick(self,self.dismiss);
    self:createDefaultIconGroup();
end

ChangeHeadIconDialog.setConfirmClick  = function(self,obj,func)
    self.m_confirmCLickObj = obj;
    self.m_confirmCLickFunc = func;
end

ChangeHeadIconDialog.onCancelClick = function(self)
    self:dismiss();
end

ChangeHeadIconDialog.onCustomBtnClick = function(self)
	print_string("ChangeHeadIconDialog.onCustomBtnClick in");
    local post_data = {};
    if UserInfo.getInstance():getLoginType() == LOGIN_TYPE_BOYAA then
        post_data.ImageName = UserInfo.ICON..PhpConfig.TYPE_BOYAA;

    elseif UserInfo.getInstance():getLoginType() == LOGIN_TYPE_YOUKE then

        post_data.ImageName = UserInfo.ICON..PhpConfig.TYPE_YOUKE;

    elseif UserInfo.getInstance():getLoginType() == LOGIN_TYPE_weibo then

        post_data.ImageName = UserInfo.ICON..PhpConfig.TYPE_WEIBO;

    end;
	--post_data.ImageName = UserInfo.ICON;
	post_data.Url = PhpConfig.UPLOAD_IMAGE_URL;
	post_data.Api = HttpManager.getMethodData(PhpConfig.METHOD_VISITOR_UPLOADICON,PhpConfig.METHOD_VISITOR_UPLOADICON);
	local dataStr = json.encode(post_data);
	dict_set_string(kUpLoadImage,kUpLoadImage..kparmPostfix,dataStr);
	call_native(kUpLoadImage);
    self:dismiss();
end

ChangeHeadIconDialog.onConfirmClick = function(self)
    if self.m_confirmCLickFunc then
        self.m_confirmCLickFunc(self.m_confirmCLickObj,self.m_iconType,self.m_iconName);
    end
    self:dismiss();
end

ChangeHeadIconDialog.createDefaultIconGroup = function(self)
    self.m_headIcon_scrollview = new(ScrollView,0,0,600,138,true);
    self.m_headIcon_scrollview:setDirection(kHorizontal);
    self.m_defaultIconGroup:addChild(self.m_headIcon_scrollview);
    self.m_headBtns = {};
    for i,v in pairs(UserInfoScene.s_headIconFile) do
        self.m_headBtns[i] = new(ChangeHeadIconDialogItem, i, v, self);
        self.m_headIcon_scrollview:addChild(self.m_headBtns[i]);
    end;
    HttpModule.getInstance():execute(HttpModule.s_cmds.getConsoleProgress);
end

--ChangeHeadIconDialog.createDefaultIconGroup = function(self)
--    self.m_selected = self.m_defaultIconGroup:getChildByName("seleted");
--    self.m_selected:setVisible(false);
--    self.m_selectBtn = {};
--    for i,v in pairs(UserInfoScene.s_headIconFile) do
--        local view = self.m_defaultIconGroup:getChildByName("item"..i);
--        self.m_selectBtn[i] = new(Mask,"common/background/head_mask_bg_122.png","common/background/head_mask_bg_122.png");
--        self.m_selectBtn[i]:setAlign(kAlignCenter);
--        self.m_selectBtn[i]:setFile(v);
--        view:addChild(self.m_selectBtn[i]);
--        local data = {}
--        data.index = i;
--        data.obj = self;
--        view:setEventTouch(data,self.onDefaultIconItemClick);
--    end
--    self:updateDefaultIconGroup(UserInfo.getInstance():getIconType());
--end

ChangeHeadIconDialog.onDefaultIconItemClick = function(data,finger_action, x, y, drawing_id_first, drawing_id_current)
    if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
        data.obj:updateDefaultIconGroup(data.index);
    end
end

--ChangeHeadIconDialog.updateDefaultIconGroup = function(self,index)
--    if not index then index = 1 end
--    self.m_selected:setVisible(false);
--    if index > 0 then
--        if UserInfoScene.s_headIconFile[index] then
--            self.m_headIcon:setFile(UserInfoScene.s_headIconFile[index]);
--        else
--            self.m_headIcon:setFile(UserInfoScene.s_headIconFile[1]);
--        end
--        if self.m_selectBtn[index] then
--            self.m_selected:setPos(self.m_selectBtn[index]:getParent():getPos());
--            self.m_selected:setVisible(true);
--        end
--    elseif index == -1 then
--        local file = UserInfo.getInstance():getIcon();
--        Log.i("....................."..file);
--        self.m_headIcon:setUrlImage(file,UserInfoScene.s_headIconFile[1]);
--    elseif index == 0 then
--        self.m_headIcon:setFile(UserInfoScene.s_headIconFile[1]);
--    end
--    self.m_iconType = index;
--end
ChangeHeadIconDialog.updateDefaultIconGroup = function(self,index)
    if not index then index = 1 end
    self:setHeadIconSelected();
    if index >= 0 then
        if UserInfoScene.s_headIconFile[index] then
            self.m_headIcon:setFile(UserInfoScene.s_headIconFile[index]);
        else
            self.m_headIcon:setFile(UserInfoScene.s_headIconFile[1]);
        end
        if self.m_headBtns[index] then
            self:setHeadIconSelected(index);
        end
    elseif index == -1 then
        local file = UserInfo.getInstance():getIcon();
        Log.i("....................."..file);
        self.m_headIcon:setUrlImage(file,UserInfoScene.s_headIconFile[1]);
    end
    self.m_iconType = -1;-- 2.1.5之后默认系统头像都走php
    self.m_iconName = UserInfo.DEFAULT_ICONNAME[index];
end


ChangeHeadIconDialog.setHeadIconSelected = function(self, index)
    if not index then
        for i = 1, #self.m_headBtns do
            self.m_headBtns[i]:setSelected(false);
        end;
    elseif type(index) == "number" then
        for i = 1, #self.m_headBtns do
            self.m_headBtns[i]:setSelected(false);
        end;
        self.m_headBtns[index]:setSelected(true);
    end;
end;


ChangeHeadIconDialog.setHeadIconEnabled = function(self, progress)
    for index = 1, #self.m_headBtns do
        self.m_headBtns[index]:setItemEnable(false);
    end;
    if progress and progress > 3 then
        for index = 1, progress + 4 do
            self.m_headBtns[index]:setItemEnable(true);
        end;         
    else
        for index = 1, 7 do
            self.m_headBtns[index]:setItemEnable(true);
        end;         
    end;
end;


ChangeHeadIconDialog.dtor = function(self)
    self:dismiss();
end

ChangeHeadIconDialog.onHttpRequestsCallBack = function(self,command,...)
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self,...);
	end 
end

ChangeHeadIconDialog.show = function(self)
    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
    self:updateDefaultIconGroup(UserInfo.getInstance():getIconType());
    
    local w,h = self.m_bg:getSize();
    local anim = self.m_bg:addPropTranslate(1,kAnimNormal,400,-1,0,0,h,0);
    if anim then
        anim:setEvent(self,function()
            self.m_bg:removeProp(1);
        end);
    end
    self:setVisible(true);
    self.super.show(self,false);
end

ChangeHeadIconDialog.dismiss = function(self)

    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpRequestsCallBack);

    local w,h = self.m_bg:getSize();
    local anim = self.m_bg:addPropTranslate(2,kAnimNormal,400,-1,0,0,0,h);
    if anim then
        anim:setEvent(self,
        function()
            self:setVisible(false);
            self.m_bg:removeProp(2);
        end);
    end
    self.super.dismiss(self,false);
end

ChangeHeadIconDialog.isShowing = function(self)
    return self:getVisible();
end

-- 根据单机进度显示单机头像
ChangeHeadIconDialog.onGetConsoleProgressCallBack = function(self, flag, message)
    if not flag then
        if type(message) == "number" then
            if tonumber(message) == 2 then
                ChessToastManager.getInstance():showSingle("请求超时");
            elseif tonumber(message) == 3 then
                ChessToastManager.getInstance():showSingle("网络异常");
            end;
        elseif message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value(),2000);
        end;    
        self:setHeadIconEnabled(nil); 
        return;  
    else
        if not HttpModule.explainPHPFlag(message) then
		    return;
	    end  
        local progress = message.data.progress["1"]:get_value();
        local zhanji = {};
        if message.data.combat_gains:get_value() then 
            for index = 1 , COSOLE_MODEL_GATE_NUM do 
                zhanji[index] = {};
                local item = message.data.combat_gains[index ..""];
                zhanji[index].wintimes = ((not item.wintimes and 0) or item.wintimes:get_value());
                zhanji[index].losetimes = ((not item.losetimes and 0) or item.losetimes:get_value());
            end;
            GameCacheData.getInstance():saveString(GameCacheData.CONSOLE_ZHANJI..UserInfo.getInstance():getUid(),json.encode(zhanji));
        end;
        self:setHeadIconEnabled(progress);
    end;
end;


ChangeHeadIconDialog.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.getConsoleProgress]            = ChangeHeadIconDialog.onGetConsoleProgressCallBack;
};











------------------------ ChangeHeadIconDialogItem ------------------------

ChangeHeadIconDialogItem = class(Button,false)


ChangeHeadIconDialogItem.ctor = function(self,index, file, room)
    super(self,"drawable/blank.png","drawable/blank.png");
    self.m_index = index;
    self.m_file = file;
    self.m_room = room;
    self.m_btn = new(Mask,"common/background/head_mask_bg_122.png","common/background/head_mask_bg_122.png");
    self.m_btn:setAlign(kAlignCenter);
    self.m_btn:setFile(file);
    self:addChild(self.m_btn);

    self.m_selected = new(Image,"common/decoration/select_chose.png");
    self.m_selected:setAlign(kAlignCenter);
    self:addChild(self.m_selected);
    self.m_selected:setVisible(false);




    self:setOnClick(self, self.onItemClick);
    self:setItemEnable(false);
    self:setSize(160,140);
end;


ChangeHeadIconDialogItem.dtor = function(self)


end;

ChangeHeadIconDialogItem.setItemEnable = function(self, flag)
    if flag then
        self.m_btn:setGray(false);
        self.m_item_enable = true;
    else
        self.m_btn:setGray(true);
        self.m_item_enable = false;
    end;
end;



ChangeHeadIconDialogItem.onItemClick = function(self)
    if self.m_item_enable then
        self.m_selected:setVisible(true);
        self.m_room:updateDefaultIconGroup(self.m_index);
    else
        ChessToastManager.getInstance():showSingle("想解锁？立刻来单机挑战",2000);
    end;
end;


ChangeHeadIconDialogItem.setSelected = function(self, isSelected)
    if isSelected then
        self.m_selected:setVisible(true);
    else
        self.m_selected:setVisible(false);
    end;
end;



ChangeHeadIconDialogItem.onClick = function(self,finger_action, x, y, drawing_id_first, drawing_id_current)
    Log.i("ChangeHeadIconDialogItem.onClick");
    if finger_action == kFingerDown then
        self.m_downX = x;
        self.m_downY = y;
	elseif finger_action == kFingerMove then
--        self.m_curX = x;
--        self.m_curY = y;
	elseif finger_action == kFingerUp then
        self.m_curX = x;
        self.m_curY = y;
        if not self.m_curX or math.abs(self.m_downX - self.m_curX) < 5 then
            self:onItemClick();
        end;
	elseif finger_action==kFingerCancel then

	end
end;