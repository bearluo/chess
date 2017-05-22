
require(BASE_PATH.."chessScene");


PrivateScene = class(ChessScene);

PrivateScene.s_controls = 
{
    back_btn            = 1;
    refresh_btn         = 2;
    top_view            = 3;
    stone_dec           = 4;
    teapot_dec          = 5;
    content_view        = 6;
    input               = 7;
    private_room_list   = 8;
    create_room_btn     = 9;
    search_btn          = 10;
    challenge_btn       = 11;
    total_num_tx = 12;
    free_num_tx = 13;
}

PrivateScene.s_cmds = 
{
    get_custom_list     = 1;
    show_input_pwd_dialog  = 2;
    startLoading        = 3;
    stopLoading         = 4;
    setRoomNum = 5;
}

PrivateScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = PrivateScene.s_controls;
    self:initView();
end 

PrivateScene.resume = function(self)
    ChessScene.resume(self);
--    self:removeAnimProp();
--    self:resumeAnimStart();
    if PrivateScene.challengeFriends then
        PrivateScene.challengeFriends= false;
        self:onChallengeBtnClick();
    end
    if PrivateScene.M_GOTO_ROOM_TID and PrivateScene.M_GOTO_ROOM_TID ~= 0 then
        RoomProxy.getInstance():setTid(PrivateScene.M_GOTO_ROOM_TID);
        self:loginStartCustomRoom(PrivateScene.M_GOTO_ROOM_PWD);
    end
    PrivateScene.clearGotoRoom();
end
PrivateScene.pause = function(self)
	ChessScene.pause(self);
    self:removeAnimProp();
--    self:pauseAnimStart();
end 


PrivateScene.dtor = function(self)
    delete(self.m_chioce_dialog);
    delete(self.m_createroom_dialog);
    delete(self.m_inputPwdDialog);
    delete(self.anim_end);
    delete(self.anim_start);
    delete(self.mLoadAnim)
end 

function PrivateScene.setGotoRoom(tid,pwd)
    PrivateScene.M_GOTO_ROOM_TID = tid;
    PrivateScene.M_GOTO_ROOM_PWD = pwd or "";
end

function PrivateScene.clearGotoRoom()
    PrivateScene.M_GOTO_ROOM_TID = 0;
    PrivateScene.M_GOTO_ROOM_PWD = "";
end
------------------------------anim----------------------------------
PrivateScene.removeAnimProp = function(self)
    if self.m_anim_prop_need_remove then
--        self.m_top_view:removeProp(1);
--        self.m_stone_dec:removeProp(1);
--        self.m_teapot_dec:removeProp(1);
--        self.m_back_btn:removeProp(1);
--        self.m_refresh_btn:removeProp(1);
--        self.m_create_room_btn:removeProp(1);
        self.m_title:removeProp(1);
        self.m_title:removeProp(2);
        self.m_left_leaf:removeProp(1);
        self.m_right_leaf:removeProp(1);
        self.m_content_view:removeProp(1);
        self.m_anim_prop_need_remove = false;
    end
end

PrivateScene.setAnimItemEnVisible = function(self,ret)
    self.m_left_leaf:setVisible(ret);
    self.m_right_leaf:setVisible(ret);
end

PrivateScene.resumeAnimStart = function(self,lastStateObj,timer,func)
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = timer.duration + duration;

--   local w,h = self:getSize();
--   if not typeof(lastStateObj,OnlineState) then
--        self.m_root:removeProp(1);
--        self.m_root:addPropTranslate(1,kAnimNormal,duration,waitTime,-w,0,nil,nil);
--   end
    delete(self.anim_start);
    self.anim_start = new(AnimInt,kAnimNormal,0,1,delay,-1);
   if self.anim_start then
        self.anim_start:setEvent(self,function()
            self:setAnimItemEnVisible(true);
            delete(self.anim_start);
        end);
   end

    self.m_content_view:addPropTransparency(1,kAnimNormal,waitTime,delay,0,1);
    self.m_title:addPropTransparency(2,kAnimNormal,waitTime,delay,0,1);
    self.m_title:addPropScale(1,kAnimNormal,waitTime,delay,0.8,1,0.6,1,kCenterXY,75,30);
    local lw,lh = self.m_left_leaf:getSize();
   self.m_left_leaf:addPropTranslate(1,kAnimNormal,waitTime,delay,-lw,0,-10,0);
   local rw,rh = self.m_right_leaf:getSize();
   local anim = self.m_right_leaf:addPropTranslate(1,kAnimNormal,waitTime,delay,rw,0,-10,0);
   if anim then
        anim:setEvent(self,function()
            self.m_anim_prop_need_remove = true;
            self:removeAnimProp();
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end
        end);
   end

   -- 上部动画
--   local w,h = self.m_top_view:getSize();
--   local anim = self.m_top_view:addPropTranslate(1, kAnimNormal, duration, delay, 0, 0, -h, 0);
--   anim:setEvent(self,self.removeAnimProp);

--   local w,h = self.m_refresh_btn:getSize();
--   self.m_refresh_btn:addPropTranslate(1, kAnimNormal, duration, delay, 0, 0, -h, 0);

--   -- 下部动画

--   -- 茶壶 石子 后退按钮动画
--   local w,h = self.m_stone_dec:getSize();
--   self.m_stone_dec:addPropTranslate(1, kAnimNormal, duration, delay, w, 0, 0, 0);

--   local w,h = self.m_teapot_dec:getSize();
--   self.m_teapot_dec:addPropTranslate(1, kAnimNormal, duration, delay, -w, 0, 0, 0);

--   self.m_back_btn:addPropTransparency(1,kAnimNormal,duration,delay,0,1);

--   -- 


--   self.m_create_room_btn:addPropTransparency(1,kAnimNormal,duration,delay,0,1);
end

PrivateScene.pauseAnimStart = function(self,newStateObj,timer)
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = duration + waitTime;

    self.m_content_view:addPropTransparency(1,kAnimNormal,waitTime,-1,1,0);
    local lw,lh = self.m_left_leaf:getSize();
   self.m_left_leaf:addPropTranslate(1,kAnimNormal,waitTime,-1,0,-lw,0,-10);
   local rw,rh = self.m_right_leaf:getSize();
   local anim = self.m_right_leaf:addPropTranslate(1,kAnimNormal,waitTime,-1,0,rw,0,-10);
   if anim then
        anim:setEvent(self,function()
            self:setAnimItemEnVisible(false);
        end);
   end
--   local w,h = self:getSize();
--    if not typeof(newStateObj,OnlineState) then
--        self.m_root:removeProp(1);
--        self.m_root:addPropTranslate(1,kAnimNormal,duration,waitTime,0,-w,nil,nil);
--    end
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

   -- 上部动画
--   local w,h = self.m_top_view:getSize();
--   local anim = self.m_top_view:addPropTranslate(1, kAnimNormal, duration, delay, 0, 0, 0, -h);
--   anim:setEvent(self,self.removeAnimProp);

--   local w,h = self.m_refresh_btn:getSize();
--   self.m_refresh_btn:addPropTranslate(1, kAnimNormal, duration, delay, 0, 0, 0, -h);
--   -- 下部动画

--   -- 茶壶 石子 后退按钮动画
--   local w,h = self.m_stone_dec:getSize();
--   self.m_stone_dec:addPropTranslate(1, kAnimNormal, duration, delay, 0, w, 0, 0);

--   local w,h = self.m_teapot_dec:getSize();
--   self.m_teapot_dec:addPropTranslate(1, kAnimNormal, duration, delay, 0, -w, 0, 0);

--   self.m_back_btn:addPropTransparency(1,kAnimNormal,duration,delay,1,0);

--   -- 


--   self.m_create_room_btn:addPropTransparency(1,kAnimNormal,duration,delay,1,0);
end

------------------------------function------------------------------

PrivateScene.initView = function(self)
    self.m_top_view = self:findViewById(self.m_ctrls.top_view);
--    self.m_stone_dec = self:findViewById(self.m_ctrls.stone_dec);
--    self.m_teapot_dec = self:findViewById(self.m_ctrls.teapot_dec);
    self.m_title = self.m_top_view:getChildByName("top_board"):getChildByName("title");
    self.m_left_leaf = self.m_root:getChildByName("bamboo_left");
    self.m_right_leaf = self.m_root:getChildByName("bamboo_right");
    self.m_left_leaf:setFile("common/decoration/left_leaf.png")
    self.m_right_leaf:setFile("common/decoration/right_leaf.png")

    self.m_back_btn = self:findViewById(self.m_ctrls.back_btn);
    self.m_refresh_btn = self:findViewById(self.m_ctrls.refresh_btn);
    self.m_content_view = self:findViewById(self.m_ctrls.content_view);
    self.m_create_room_btn = self:findViewById(self.m_ctrls.create_room_btn);
    self.m_challenge_btn = self:findViewById(self.m_ctrls.challenge_btn);
    self.mLoadingAnim = self.m_content_view:getChildByName("loadingAnim");
    self.mLoadingAnim:setVisible(false)

    self.m_total_num_tx = self:findViewById(self.m_ctrls.total_num_tx)
    self.m_free_num_tx = self:findViewById(self.m_ctrls.free_num_tx)

    self:setRoomNum(0,0)

    local func = function(view,enable)
        if view then
            if enable then
                view:removeProp(1);
            else
                view:addPropScaleSolid(1,1.1,1.1,1);
            end
        end
    end
    self.m_create_room_btn:setOnTuchProcess(self.m_create_room_btn:getChildByName("create_text"),func);

    local func = function(view,enable)
        if view then
            if enable then
                view:removeProp(1);
            else
                view:addPropScaleSolid(1,1.1,1.1,1);
            end
        end
    end

    self.m_challenge_btn:setOnTuchProcess(self.m_challenge_btn:getChildByName("create_text"),func);

    
    self.m_private_room_list = self:findViewById(self.m_ctrls.private_room_list);
    local w,h = self:getSize();
    local mw,mh = self.m_private_room_list:getSize();
    self.m_private_room_list:setSize(mw,mh+h-System.getLayoutHeight());

    self.m_input = self:findViewById(self.m_ctrls.input);
    self.m_input:setHintText("输入房间ID",165,145,120);

end

PrivateScene.startLoading = function(self)
    delete(self.mLoadAnim);
    self.mLoadAnim = nil;
    self.mLoadAnim = AnimFactory.createAnimInt(kAnimLoop, 0, 1, 100, -1);
    self.mLoadIndex = 0;
    self.mLoadingAnim:setVisible(true)
    self.mLoadAnim:setEvent(self,function()
        self.mLoadIndex = self.mLoadIndex%8;

        if self.mLoadingAnim and self.mLoadingAnim:getVisible() then
            self.mLoadingAnim:setFile( string.format("animation/loading%d.png",self.mLoadIndex+1));
        end

        self.mLoadIndex = self.mLoadIndex + 1;
    end)
end

PrivateScene.stopLoading = function(self)
    delete(self.mLoadAnim);
    self.mLoadingAnim:setVisible(false)
end

PrivateScene.onGetCustomList = function(self, customlist)
    self.m_private_list_data = customlist;
    if not customlist or #customlist == 0 then
        self.m_private_room_list:setVisible(false);
        return ;
    end
    self.m_private_adapter = new(PrivateGameItemCacheAdapter,PrivateGameItem,self.m_private_list_data);
    self.m_private_adapter:setPrivateSceneHandler(self);
    self.m_private_room_list:setAdapter(self.m_private_adapter);
    self.m_private_room_list:setVisible(true);
end

require(DIALOG_PATH.."chioce_dialog");
PrivateScene.show_tips_action  = function(self,msg)
	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end

   	self.m_chioce_dialog:setMode(ChioceDialog.MODE_OK,"知道了");
	self.m_chioce_dialog:setMessage(msg);
	self.m_chioce_dialog:setPositiveListener(nil,nil);
	self.m_chioce_dialog:show();
end

PrivateScene.setRoomListOnItemClick = function(self,view)
    local data  = view:getData();

 	if data==nil then
 		return;
 	end
 	
 	local money = UserInfo.getInstance():getMoney();
    local config = RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_PRIVATE_ROOM)
    local minmoney = config.minmoney or 500
 	if  money < minmoney then
 		self:show_tips_action( string.format("您携带的金币不足%d，进入私人房间，请移步新手场或其他版块游戏。",minmoney));
 		return;
 	end

	if data.tableStatus == 0 or data.tableStatus == 1 then
		if data.tid~=nil and data.tid >0 then
            RoomProxy.getInstance():setTid(data.tid);
			if data.isPassword and data.isPassword == 1 then
                self:showInputPwdDialog(false)
            else
                self:loginStartCustomRoom("");
            end
		end
	else
	    if not self.m_chioce_dialog then
			self.m_chioce_dialog = new(ChioceDialog);
		end
		self.m_chioce_dialog:setMode(ChioceDialog.MODE_OK);
		local message="不能进入游戏";
		if data.tableStatus == -1 then
			message = "棋桌已关闭";
		elseif data.tableStatus == 5 then
			message = "棋桌已满";
		elseif data.tableStatus == 2 then 
			message = "红方走棋";
		elseif data.roomStatus == 3 then
			message = "黑方走棋";
		elseif data.tableStatus == 4 then
			message = "游戏结束";
		elseif data.tableStatus == 6 then
			message = "设置时间";
		end
		self.m_chioce_dialog:setMessage(message);
	    self.m_chioce_dialog:setPositiveListener(nil,nil);
		self.m_chioce_dialog:show();
	end
end

require(DIALOG_PATH.."custom_input_pwd_dialog");
PrivateScene.showInputPwdDialog = function(self,isAnother)
    delete(self.m_inputPwdDialog);
	self.m_inputPwdDialog = new(InputPwdDialog,50,260,370,286,self);
	self.m_inputPwdDialog:setPositiveListener(self,self.loginStartCustomRoom);
	self.m_inputPwdDialog:setNegativeListener(nil,nil)
    self.m_inputPwdDialog:show(isAnother);
end

PrivateScene.loginStartCustomRoom = function(self,pwd)
    RoomProxy.getInstance():setSelfRoomPassword(pwd)
    self:requestCtrlCmd(PrivateController.s_cmds.login_private_room,pwd);
end

PrivateScene.onActionBtnClick = function(self)
    self:requestCtrlCmd(PrivateController.s_cmds.back_action);
end

PrivateScene.onRefreshBtnClick = function(self)
    self:requestCtrlCmd(PrivateController.s_cmds.get_sever_room_num);
    self:requestCtrlCmd(PrivateController.s_cmds.get_custom_list);
end

require(DIALOG_PATH.."create_room_dialog");
PrivateScene.onCreateRoomBtnClick = function(self)
    local money = UserInfo.getInstance():getMoney();
    local config = RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_PRIVATE_ROOM)
    local minmoney = config.minmoney or 500
 	if  money < minmoney then
 		self:show_tips_action( string.format("您携带的金币不足%d，无法创建房间，请移步新手场或其他版块游戏。",minmoney));
 		return;
 	end
    UserInfo.getInstance():setCustomRoomType(0);
    delete(self.m_createroom_dialog);
	self.m_createroom_dialog = new(CreateRoomDialog,50,260,370,286,self);
    self.m_createroom_dialog:show();
end

PrivateScene.customCreateRoom = function(self, data)
    self:requestCtrlCmd(PrivateController.s_cmds.create_custom_room, data);
end;

PrivateScene.onSearchBtnClick = function(self)
    local roomIdStr = self.m_input:getText();

    if roomIdStr ~= nil and roomIdStr ~= "" then
    	local result = string.find(roomIdStr, "%D")

    	if result~=nil then
    		self:show_tips_action("请输入合法的房间ID");
    		return;
    	end

    	local  roomId = tonumber(roomIdStr);
        if roomId and self.m_private_list_data then
            local data = self.m_private_list_data;
            for i,v in ipairs(data) do
                if v.tid == roomId then
                    self:onHallMsgSearchroom(v);
                    return ;
                end
            end
        end
        self:onHallMsgSearchroom();
	else
		return;
    end
end

require(DIALOG_PATH.."chioce_dialog");
PrivateScene.onHallMsgSearchroom = function(self, data)
    if not data then
		if not self.m_chioce_dialog then
			self.m_chioce_dialog = new(ChioceDialog);
		end

		self.m_chioce_dialog:setMode(ChioceDialog.MODE_OK);
		local message="房间不存在，请重新刷新列表";
		self.m_chioce_dialog:setMessage(message);
		self.m_chioce_dialog:setPositiveListener(self,self.onRefreshBtnClick);
		self.m_chioce_dialog:show();        
        return;
    end
	local roomList = {};
	table.insert(roomList,data);
	self:updateCustomRoomsData(roomList);
end

PrivateScene.updateCustomRoomsData = function(self, customlist)
    if not customlist and #customlist == 0 then
        self.m_private_room_list:setVisible(false);
        return ;
    end
    self.m_private_adapter = new(PrivateGameItemCacheAdapter,PrivateGameItem,customlist);
    self.m_private_adapter:setPrivateSceneHandler(self);
    self.m_private_room_list:setAdapter(self.m_private_adapter);
    self.m_private_room_list:setVisible(true);
end;

function PrivateScene.setRoomNum(self,totalNum,freeNum)
    self.m_total_num_tx:setText("全部："..tonumber(totalNum) or 0 .."间")
    self.m_free_num_tx:setText("空闲："..tonumber(freeNum) or 0 .."间")
end 
require("dialog/friends_pop_dialog");
function PrivateScene.onChallengeBtnClick(self)
    if not self.m_challenge_dialog then
        self.m_challenge_dialog = new(FriendPopDialog,self);
    end
    self.m_challenge_dialog:setMode(FriendPopDialog.MODE_FIGHT);
--    self.m_challenge_dialog:setJumpFriendsCallBack(self,self.gotoFriendsScene);
--    self.m_challenge_dialog:setPositiveListener(self, self.onPopDialogSureBtnClick);
    self.m_challenge_dialog:show();
end

---------------------------------config-------------------------------
PrivateScene.s_controlConfig = 
{
    [PrivateScene.s_controls.back_btn]              = {"back_btn"};
    [PrivateScene.s_controls.refresh_btn]           = {"refresh_bg","refresh_btn"};
    [PrivateScene.s_controls.top_view]              = {"top_view"};
    [PrivateScene.s_controls.stone_dec]             = {"stone_dec"};
    [PrivateScene.s_controls.teapot_dec]            = {"teapot_dec"};
    [PrivateScene.s_controls.content_view]          = {"content_view"};
    [PrivateScene.s_controls.input]                 = {"content_view","input_bg","input"};
    [PrivateScene.s_controls.private_room_list]     = {"content_view","private_room_list"};
    [PrivateScene.s_controls.create_room_btn]       = {"bottom_btn_view","create_room_btn"};
    [PrivateScene.s_controls.search_btn]            = {"content_view","input_bg","search_btn"};
    [PrivateScene.s_controls.challenge_btn]         = {"bottom_btn_view","challenge_btn"};
    [PrivateScene.s_controls.total_num_tx] = {"top_view","num_info_node","total_num_tx"};
    [PrivateScene.s_controls.free_num_tx] = {"top_view","num_info_node","free_num_tx"};

};
--定义控件的触摸响应函数
PrivateScene.s_controlFuncMap =
{
    [PrivateScene.s_controls.back_btn]              = PrivateScene.onActionBtnClick;
    [PrivateScene.s_controls.refresh_btn]           = PrivateScene.onRefreshBtnClick;
    [PrivateScene.s_controls.create_room_btn]       = PrivateScene.onCreateRoomBtnClick;
    [PrivateScene.s_controls.search_btn]            = PrivateScene.onSearchBtnClick;
    [PrivateScene.s_controls.challenge_btn]         = PrivateScene.onChallengeBtnClick;
};
PrivateScene.s_cmdConfig = 
{
    [PrivateScene.s_cmds.get_custom_list]           = PrivateScene.onGetCustomList;
    [PrivateScene.s_cmds.show_input_pwd_dialog]     = PrivateScene.showInputPwdDialog;
    [PrivateScene.s_cmds.startLoading]              = PrivateScene.startLoading;
    [PrivateScene.s_cmds.stopLoading]               = PrivateScene.stopLoading;
    [PrivateScene.s_cmds.setRoomNum] =  PrivateScene.setRoomNum;
}





-------------------------------PrivateGameItem---------------------------

PrivateGameItemCacheAdapter = class(CacheAdapter);

PrivateGameItemCacheAdapter.setPrivateSceneHandler = function(self,handler)
    self.m_handler = handler;
end

PrivateGameItemCacheAdapter.getView = function(self,index)
    local view = self.m_views[index];

	if view and self.m_changedItems[view] then
		self.m_changedItems[view] = nil;
		delete(view);
		self.m_views[index] = nil
	end

    if self.m_views[index] then 
        self.m_views[index]:setVisible(true);
    else
		self.m_views[index] =  Adapter.getView(self,index);
        if self.m_views[index].setPrivateSceneHandler then
            self.m_views[index]:setPrivateSceneHandler(self.m_handler);
        end
	end

	return self.m_views[index];    
end
------观战列表Item
require(VIEW_PATH.."private_view_list_item");
PrivateGameItem = class(Node);
PrivateGameItem.ICON_PRE = "record";

PrivateGameItem.ctor = function(self,room)
    self.m_data = room;

    if self.m_data and self.m_data.ownerId then
        self.ownerData = FriendsData.getInstance():getUserData(self.m_data.ownerId);
    end
    self.m_root_view = SceneLoader.load(private_view_list_item);
    self.m_root_view:setAlign(kAlignCenter);
    self:addChild(self.m_root_view);
    local w,h = self.m_root_view:getSize();
    self:setSize(w,h*1.2);
    
    self.m_item_btn = self.m_root_view:getChildByName("item_btn");
    self.m_item_btn:setOnClick(self,self.onClick);
    self.m_item_btn:setSrollOnClick();

--    self.m_vip_logo = self.m_item_btn:getChildByName("vip_logo");
    self.m_room_name = self.m_item_btn:getChildByName("room_name");
    self.m_room_name:setText(room.name or "博雅象棋");
    --是否需要密码
    self.m_lock_icon = self.m_item_btn:getChildByName("lock_icon");
    if room.isPassword~=nil and room.isPassword==1 then
        self.m_lock_icon:setVisible(true);
    else
        self.m_lock_icon:setVisible(false);
	end
    -- 房间人数
    self.m_player_num = self.m_item_btn:getChildByName("info_bg"):getChildByName("player_num");
    local roomPersonCount;
    if room.tableStatus == 1 then
        roomPersonCount = 1;
    elseif room.tableStatus == 0 then
		roomPersonCount = 0;
	elseif room.tableStatus == 4 then
		roomPersonCount = 0;
	elseif room.tableStatus == -1 then
		roomPersonCount = 0;
	else
		roomPersonCount = 2;
	end
	local lownCoinStr = roomPersonCount.."/2";
    self.m_player_num:setText(lownCoinStr);
    -- 游戏状态
    self.m_status_text = self.m_item_btn:getChildByName("info_bg"):getChildByName("status_text");
    local statusStr = "游戏中";
	if room.tableStatus == 1 or room.tableStatus == 0 then
		statusStr = "等待中";
	elseif room.tableStatus == 4 then
		statusStr = "游戏结束";
	elseif room.tableStatus == 6 then
		statusStr = "设置时间";
	elseif room.tableStatus == -1 then
		statusStr = "棋桌关闭";
	else
	    statusStr = "游戏中";
	end
    self.m_status_text:setText(statusStr);
    -- 房间 tid 
    self.m_room_tid = self.m_item_btn:getChildByName("room_tid");
    self.m_room_tid:setText("ID:  "..( room.tid or 0 ));

    self.m_bottom_note_num = self.m_item_btn:getChildByName("bottom_note_num");
 	local lownCoinStr = room.basechip or "";
    self.m_bottom_note_num:setText(lownCoinStr);
    -- 房间类型
    self.m_room_time = self.m_item_btn:getChildByName("room_time");
    local  gameType = "普通场"
    if room.round_time then
        gameType = string.format("%d分钟场",room.round_time/60);
    end
    self.m_room_time:setText(gameType);
    -- vip_logo
--    local vx,vy = self.m_vip_logo:getPos();
--    local vw,vh = self.m_vip_logo:getSize();

--    if self.ownerData and self.ownerData.is_vip == 1 then
--        self.m_room_name:setPos(vx+vw+3,35);
--        self.m_vip_logo:setVisible(true); 
--    else
--        self.m_room_name:setPos(59,35);
--        self.m_vip_logo:setVisible(false); 
--    end

end

PrivateGameItem.updateHeadImg = function(self,imageName,uid)
    local uid = tonumber(uid);
    if uid == self.m_red_player.uid then
        self.m_red_user_head:setFile(imageName);
    end
    if uid == self.m_black_player.uid then
        self.m_black_user_head:setFile(imageName);
    end
end

PrivateGameItem.onClick = function(self)
    if self.m_handler then
        PrivateScene.setRoomListOnItemClick(self.m_handler,self);
    end
end

PrivateGameItem.setPrivateSceneHandler = function(self,handler)
    self.m_handler = handler;
end

PrivateGameItem.getData = function(self)
	return self.m_data;
end


PrivateGameItem.dtor = function(self)
	
end