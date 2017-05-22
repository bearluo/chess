require(BASE_PATH.."chessScene");
require("view/selectButton");
require("dialog/chioce_dialog");
require("dialog/maillist_dialog");
require("dialog/exitguanzhu_dialog");
require("dialog/bangdin_dialog");

AddFriendsScene = class(ChessScene);
AddFriendsScene.s_changeState = true;

AddFriendsScene.s_controls = 
{
	friends_back_btn = 1; --返回
    phone_addfriends_btn = 2; -- 添加手机好友

    search_btn = 3;--搜索
    search_view_edittext = 4;--输入内容
    friendsView = 5;--好友列表
    phone_text = 6; 
    yourid = 7;

    add_phone_toggle_bg = 8;
    add_recent_toggle_bg = 9;
    addfriends_custom_view =10;
    recent_list_view = 11;
} 

AddFriendsScene.s_cmds = 
{
    changeState = 1;
    addFriends = 2;
    changeAtt = 3;
    addPhoneFriends = 4;
    change_userIcon = 5;
    getRecentGamer = 6;
}

AddFriendsScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = AddFriendsScene.s_controls;
    self.m_FriendsDatas = controller.m_state.m_datas;
    self.isPhoneFriendsList = true;
    self:init();

end 

AddFriendsScene.resume = function(self)
    ChessScene.resume(self);
    self:reset();
end;


AddFriendsScene.pause = function(self)
	ChessScene.pause(self);
end 

AddFriendsScene.dtor = function(self)
    delete(self.leaveTipsDialog);
end 

----------------------------------- function ----------------------------
AddFriendsScene.init = function(self)
    self.friendsView = self:findViewById(self.m_ctrls.friendsView);
    self.search_view_edittext = self:findViewById(self.m_ctrls.search_view_edittext);
    self.phone_addfriends_btn = self:findViewById(self.m_ctrls.phone_addfriends_btn);
    self.phone_text = self:findViewById(self.m_ctrls.phone_text);
    self.yourid = self:findViewById(self.m_ctrls.yourid);
    local str = "你的ID："..UserInfo.getInstance():getUid().."";
    self.yourid.setText(self.yourid,str);
    self.search_view_edittext:setHintText(GameString.convert2UTF8("在此输入昵称或ID"),165,145,120);
    _,bottom_posY = self:getSize();
    self.friendsView:setSize(480,570+bottom_posY-800);

    self.phone_view_list = self:findViewById(self.m_ctrls.addfriends_custom_view);
    self.recent_gamer_view = self:findViewById(self.m_ctrls.recent_list_view);
    self.recent_gamer_list = self.recent_gamer_view:getChildByName("recent_list_view");


    self.add_phone_bg = self:findViewById(self.m_ctrls.add_phone_toggle_bg);
    self.add_phone_type_btn = new(SelectButton,{"friends/charmlist.png","friends/charmlist_press.png"},SelectButton.MODE_LEFT);
    if self.add_phone_type_btn.m_texture then
        local lx,ly = self.add_phone_type_btn.m_texture:getPos();
        self.add_phone_type_btn.m_texture:setPos(lx + 3,ly - 5);
    end
    self.add_phone_bg:addChild(self.add_phone_type_btn);
    self.add_phone_type_btn:setOnChange(self,self.selectAddPhoneFriends);

    self.add_recent_bg = self:findViewById(self.m_ctrls.add_recent_toggle_bg);
    self.add_recent_type_btn = new(SelectButton,{"friends/friendslist.png","friends/friendslist_press.png"});
    if self.add_recent_type_btn.m_texture then
        local lx,ly = self.add_recent_type_btn.m_texture:getPos();
        self.add_recent_type_btn.m_texture:setPos(lx - 3,ly - 5);
    end
    self.add_recent_bg:addChild(self.add_recent_type_btn);
    self.add_recent_type_btn:setOnChange(self,self.selectAddRecentFriends);

    self:setSelectBtn();

    local kind = kGameCacheData:getBoolean(GameCacheData.TONG_XUN_LU);
    if kind~= nil then
       if kind then
          Log.d("ZY onFriendsAddClick11");
          self.phone_addfriends_btn:setVisible(false);
       end
    end

    if self.m_FriendsDatas ~= nil then
        self:addPhoneFriendsCall();
    end 
    
end


AddFriendsScene.reset = function(self)
    
end


AddFriendsScene.callsCallBack = function(self)
	StateMachine.getInstance():pushState(States.Exchange,StateMachine.STYPE_CUSTOM_WAIT);
end

AddFriendsScene.coinsCallBack = function(self)
end

AddFriendsScene.changeState = function(self,state)
    if state then
        self.friendsback_select_btn:setChecked(true);
    else
        self.rule_select_btn:setChecked(true);
    end
end

AddFriendsScene.addFriendsCall = function(self,list)
    if not list or #list < 1 then return ; end

    local ranks  = {};
	for _,value in pairs(list) do 
		local user = {};
		user.mid     = tonumber(value.mid:get_value()) or 0;
		user.score    = tonumber(value.score:get_value()) or 0;
        user.mnick     = ToolKit.subString(value.mnick:get_value(),16);
        user.icon_url = value.icon_url:get_value();
		user.money = tonumber(value.money:get_value()) or 0;
		user.iconType     = value.iconType:get_value();
		user.mactivetime  = tonumber(value.mactivetime:get_value()) or 0;
        table.insert(ranks,user);
	end
    if #ranks > 0 then
        self.phone_addfriends_btn:setVisible(false);
        self.friendsView:setVisible(true);
        self.phone_text.setText(self.phone_text,"搜索好友");

        self.m_adapter = new(CacheAdapter,AddFriendsItem,ranks);
        self.friendsView:setAdapter(self.m_adapter);
    end 

end

AddFriendsScene.changePhoneCall = function(self,message)
    Log.d("ZY changePhoneCall"..json.encode(message));
    Log.d("ZY changePhoneCall"..json.encode(message.data.list));
    local list_data = message.data.list;
    if not list_data then return ; end

    local ranks  = {};
	for _,value in pairs(list_data) do 
		local user = {};
		user.mid     = tonumber(value.mid:get_value()) or 0;
		user.score    = tonumber(value.score:get_value()) or 0;
        user.mnick     = ToolKit.subString(value.mnick:get_value(),16);
        user.icon_url = value.icon_url:get_value();
		user.money = tonumber(value.money:get_value()) or 0;
		user.iconType     = value.iconType:get_value();
		user.mactivetime  = tonumber(value.mactivetime:get_value()) or 0;
        table.insert(ranks,user);
	end

    Log.d("ZY changePhoneCall2222");

    if #ranks > 0 then

        self.phone_addfriends_btn:setVisible(false);
        self.friendsView:setVisible(true);
    
        self.m_adapter = new(CacheAdapter,AddFriendsItem,ranks);
        self.friendsView:setAdapter(self.m_adapter);
    end

    Log.d("ZY changePhoneCall3333");

end


AddFriendsScene.addPhoneFriendsCall = function(self)
    Log.d("ZY addPhoneFriendsCall");

    if not self.m_FriendsDatas or #self.m_FriendsDatas < 1 then 
        Log.d("ZY m_FriendsDatas nil");
        return ;
    end

    local ranks  = {};
	for _,value in pairs(self.m_FriendsDatas) do 
		local user = {};
		user.drawtimes    = value.drawtimes;
        user.mid     = value.mid;
        user.score     = value.score;
        user.losetimes = value.losetimes;
		user.iconType = value.iconType;
		user.mnick     = value.name;
		user.rank  = value.rank;
        user.money  = value.money;
        user.wintimes  = value.wintimes;
        user.mactivetime  = value.mactivetime;

        table.insert(ranks,user);
	end
    if #ranks > 0 then

        self.phone_addfriends_btn:setVisible(false);
        self.friendsView:setVisible(true);

        self.m_adapter = new(CacheAdapter,AddFriendsItem,ranks);
        self.friendsView:setAdapter(self.m_adapter);
    end

end

AddFriendsScene.changeAttCall = function(self,list)
    if list then
        if self.m_adapter ~= nil then
            local datas = self.m_adapter:getData();
            for i,uid in pairs(datas) do
                if tonumber(uid.mid) == list.target_uid and self.m_adapter:isHasView(i) then
                    local view = self.m_adapter:getTmpView(i);
                    self:changeFriendsView(view);
                end
            end
        end
   end
end

AddFriendsScene.changeFriendsView = function(self,view)
    if view ~= nil then
        if view.guanzhu == true then
            view.m_addtile.setText(view.m_addtile,"已关注");
            view.guanzhu = false;
        else
            view.m_addtile:setText("关注");
            view.guanzhu = true;
        end
    end
end

AddFriendsScene.setSelectBtn = function(self)
    self.add_phone_type_btn:setState(self.isPhoneFriendsList);
    self.add_recent_type_btn:setState(not self.isPhoneFriendsList);
end

AddFriendsScene.selectAddPhoneFriends = function(self,checked)
    print_string("selectAddPhoneFriends...");
    if checked then
        self.add_recent_type_btn:setState(false);
        self.isPhoneFriendsList = true;
        self.phone_view_list:setVisible(true);
--        self.recent_gamer_list:setVisible(false);
--        self.recent_gamer_view:setVisible(false);
--        self:showAddPhoneView();
    end
end

AddFriendsScene.selectAddRecentFriends = function(self,checked)
    print_string("selectAddRecentFriends");
    if checked then
        self.add_phone_type_btn:setState(false);
        self.isPhoneFriendsList = false;
        self.phone_view_list:setVisible(false);
        self.recent_gamer_list:setVisible(true);
--        self.recent_gamer_view:setVisible(true);
        self:requestCtrlCmd(AddFriendsController.s_cmds.get_recent_player);
    end
end

----------------------------------- onClick -------------------------------------

AddFriendsScene.onFriendsBackBtnClick = function(self) --返回
    self:requestCtrlCmd(AddFriendsController.s_cmds.back_action);
end

AddFriendsScene.onFriendsAddClick = function(self) --添加手机好友
    
    local sid = UserInfo.getInstance():findBindAccountBySid(1);
    if sid ~= nil then
       if not self.m_chioce_dialog then
		   self.m_chioce_dialog = new(MailListDialog);
	   end
       self.m_chioce_dialog:setPositiveListener(self,self.onFriendsAddClickCall);
	   self.m_chioce_dialog:show(self.m_root_view);
    else -- 绑定手机
        delete(self.m_bangdinDialog);
        self.m_bangdinDialog = nil;
        self.m_bangdinDialog = new(BangDinDialog);
        self.m_bangdinDialog:setHandler(self);
        self.m_bangdinDialog:show();
    end

end

AddFriendsScene.onFriendsAddClickCall = function(self) --添加手机好友
    Log.d("ZY onFriendsAddClickCall");

    --kGameCacheData:saveBoolean(GameCacheData.TONG_XUN_LU,true);
    self:requestCtrlCmd(AddFriendsController.s_cmds.tongxunlu_tishi);
    self:requestCtrlCmd(AddFriendsController.s_cmds.phone_addfriends_btn);
end


AddFriendsScene.onSearchClick = function(self) --搜索
    local strdata = self.search_view_edittext:getText();
    self:requestCtrlCmd(AddFriendsController.s_cmds.search_btn,strdata);
end

AddFriendsScene.changeUserIconCall = function(self,data)
    if data and self.m_adapter then
        local datas = self.m_adapter:getData() or {};
        for i,v in pairs(datas) do
            if self.m_adapter:isHasView(i) then
                local view = self.m_adapter:getTmpView(i);
                view:updateUserIcon(data);
            end
        end
   end
end

AddFriendsScene.getRecentGamerList = function(self,data)
--    self.recent_gamer_list:releaseAllViews();
    if self.m_recentAdapter then
       delete(self.m_recentAdapter); 
       self.m_recentAdapter = nil;
    end
    local list = data.list;
    self.m_recentAdapter = new(CacheAdapter,AddFriendsItem,list);
    self.recent_gamer_list:setAdapter(self.m_recentAdapter);
end
----------------------------------- config ------------------------------------------------------------
AddFriendsScene.s_controlConfig = 
{
	[AddFriendsScene.s_controls.friends_back_btn] = {"addfriends_title_view","addfriends_back_btn"};--返回
    [AddFriendsScene.s_controls.phone_addfriends_btn] = {"addfriends_custom_view","search_view","phone_addfriends_btn"};--添加手机好友
    [AddFriendsScene.s_controls.search_btn] = {"addfriends_custom_view","search_view","search_btn"};--搜索按钮
    [AddFriendsScene.s_controls.search_view_edittext] = {"addfriends_custom_view","search_view","search_view_edittext"};--输入内容
    [AddFriendsScene.s_controls.friendsView] = {"addfriends_custom_view","friendsView"};--好友列表
    [AddFriendsScene.s_controls.phone_text] = {"addfriends_custom_view","search_view","phone_text"};
    [AddFriendsScene.s_controls.yourid] = {"addfriends_custom_view","search_view","yourid"};
    [AddFriendsScene.s_controls.add_phone_toggle_bg] = {"addfriends_title_view","add_type_toggle_view","add_phone_toggle_bg"};
    [AddFriendsScene.s_controls.add_recent_toggle_bg] = {"addfriends_title_view","add_type_toggle_view","add_recent_toggle_bg"};
    [AddFriendsScene.s_controls.addfriends_custom_view] = {"addfriends_custom_view"};
    [AddFriendsScene.s_controls.recent_list_view] = {"add_recent_content_view"};
};

AddFriendsScene.s_controlFuncMap =
{
	[AddFriendsScene.s_controls.friends_back_btn] = AddFriendsScene.onFriendsBackBtnClick;
    [AddFriendsScene.s_controls.phone_addfriends_btn] = AddFriendsScene.onFriendsAddClick;
    [AddFriendsScene.s_controls.search_btn] = AddFriendsScene.onSearchClick;

};

AddFriendsScene.s_cmdConfig =
{
    [AddFriendsScene.s_cmds.changeState] = AddFriendsScene.changeState;
    [AddFriendsScene.s_cmds.addFriends] = AddFriendsScene.addFriendsCall;
    [AddFriendsScene.s_cmds.changeAtt] = AddFriendsScene.changeAttCall;
    [AddFriendsScene.s_cmds.addPhoneFriends] = AddFriendsScene.changePhoneCall;
    [AddFriendsScene.s_cmds.change_userIcon] = AddFriendsScene.changeUserIconCall;
    [AddFriendsScene.s_cmds.getRecentGamer] = AddFriendsScene.getRecentGamerList;
}

-------------------------------- private node --------------------------------------------------------

AddFriendsItem = class(Node)
AddFriendsItem.s_w = 450;
AddFriendsItem.s_h = 120;

AddFriendsItem.idToIcon = {
    [0] = "userinfo/userHead.png";
    [1] = "userinfo/women_head01.png";
    [2] = "userinfo/man_head02.png";
    [3] = "userinfo/man_head01.png";
    [4] = "userinfo/women_head02.png";
}

AddFriendsItem.ctor = function(self,data)

    if next(data) == nil then   
        return;
    end

    self.datas = data;
    self:setSize(AddFriendsItem.s_w,AddFriendsItem.s_h);
    self.m_bg = new(Button,"friends/friends_new_item_bg.png");
    self.m_bg:setAlign(kAlignCenter);
    self:addChild(self.m_bg);

    --头像
    local iconFile = AddFriendsItem.idToIcon[0];
    
    self.m_icon_bg = new(Image,"friends/friend_icon_frame.png");
    self.m_icon_bg:setAlign(kAlignLeft);
    self.m_icon_bg:setPos(20,-5);
    self.m_bg:addChild(self.m_icon_bg);

    self.m_icon = new(Image,iconFile);
    if self.datas then
        if self.datas.iconType == -1 then
            self.m_icon:setUrlImage(self.datas.icon_url);
        else
            iconFile = AddFriendsItem.idToIcon[self.datas.iconType] or iconFile;
            self.m_icon:setFile(iconFile);
        end
    end
    self.m_icon:setAlign(kAlignCenter);
    self.m_icon:setSize(64,64);
    self.m_icon_bg:addChild(self.m_icon);
    --段位
    self.m_level = new(Image,"userinfo/1.png");
    self.m_level:setAlign(kAlignBottomRight);
    self.m_level:setPos(-8,-10);
    self.m_icon:addChild(self.m_level);
    self.m_level:setFile("userinfo/"..UserInfo.getInstance():getDanGradingLevelByScore(tonumber(self.datas.score))..".png"); 

    local sx = 35 + self.m_icon:getSize(); 
    local sy = 25;

    --名字
    self.m_title = new(Text,self.datas.mnick,nil, nil, nil, nil,28,70,25,0);
    self.m_title:setPos(sx,sy);
    self.m_bg:addChild(self.m_title);

    --ID
    local id = "ID: "..self.datas.mid.."";
    self.m_id = new(Text,id,nil, nil, nil, nil, 20,150,100,50);
    self.m_id:setPos(sx,sy + 40);
    self.m_bg:addChild(self.m_id);

    --关注按钮
    local kind = self:friendsMarkCall(tonumber(self.datas.mid));  
    if kind == 1 then
        self.m_add = new(Button,"friends/guanzhu_bg.png");
        self.m_add:setAlign(kAlignCenter);
        self.m_add:setPos(sx + 50,0);
        self.m_add:setOnClick(self,self.onBtnClick);
        self.m_addtile = new(Text,"关注",106, 38, kAlignCenter, nil,24,255,230,180);
        self.guanzhu = true;
    else
        self.m_add = new(Button,"friends/guanzhu_bg.png");
        self.m_add:setAlign(kAlignCenter);
        self.m_add:setPos(sx + 50,0);
        self.m_add:setOnClick(self,self.onBtnClick);
        self.m_addtile = new(Text,"已关注",106, 38, kAlignCenter, nil,24,255,230,180);
        self.guanzhu = false;
    end
    
    self.m_addtile:setPos(0,0);
    self.m_bg:addChild(self.m_add);
    self.m_add:addChild(self.m_addtile);

end

AddFriendsItem.updateUserIcon = function(self,data)
    if tonumber(data.what) ~= self.datas.mid then return false end
    self.m_icon:setFile(data.ImageName);
end

AddFriendsItem.setOnBtnClick = function(self,obj,func)
    self.m_btn_obj = obj;
    self.m_btn_func = func;
end

AddFriendsItem.onBtnClick = function(self)
    local info = {};
    if self.guanzhu == true then
        info.uid = UserInfo.getInstance():getUid();
        info.target_uid = self.datas.mid;
        info.op = 1;
        OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_ADD_FLLOW,info);
    else
       if not self.m_exit_dialog then
		   self.m_exit_dialog = new(ExitGuanzhuDialog);
	   end
       self.m_exit_dialog:setNegativeListener(self,self.onExitGuanzhuClickCall);
	   self.m_exit_dialog:show(self.m_root_view);

    end
end

AddFriendsItem.onExitGuanzhuClickCall = function(self) --取消关注
   Log.d("ZY onExitGuanzhuClickCall");
   local info = {};
   info.uid = UserInfo.getInstance():getUid();
   info.target_uid = self.datas.mid;
   info.op = 0;
   OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_ADD_FLLOW,info);
end

AddFriendsItem.friendsMarkCall = function(self,friendsid)

   local friend = FriendsData.getInstance():isYourFriend(friendsid);
   local follow = FriendsData.getInstance():isYourFollow(friendsid);
   local fans = FriendsData.getInstance():isYourFans(friendsid);

   if friend ~= -1 then --好友
        return 0;
   elseif follow ~= -1 then --已关注
        return 0;
   elseif fans ~= -1 then --粉丝
        return 1;
   else -- 关注
        return 1;
   end
   
end