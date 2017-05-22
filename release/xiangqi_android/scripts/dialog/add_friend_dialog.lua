--region NewFile_1.lua
--Author : FordFan
--Date   : 2015/11/13
--添加好友弹窗
--endregion

require(VIEW_PATH .. "addfriends_view");
require(BASE_PATH .. "chessDialogScene");
--require("dialog/chioce_dialog");
require("dialog/maillist_dialog");
--require("dialog/exitguanzhu_dialog");

AddFriendDialog = class(ChessDialogScene,false);

AddFriendDialog.ctor = function(self)
    super(self,addfriends_view);

    self.m_root_view = self.m_root;
    self.black_img = self.m_root_view:getChildByName("Image1");
    self.black_img:setTransparency(0.5);
    self.m_bg = self.m_root_view:getChildByName("bg");
    self.m_bg:setEventTouch(self.m_bg,function() end);

    self.search_btn = self.m_bg:getChildByName("search_btn");
    self.search_img = self.m_bg:getChildByName("search_btn"):getChildByName("search_bg");
    self.search_edit_text = self.m_bg:getChildByName("edit_bg"):getChildByName("search_edit");
    self.m_close_btn = self.m_bg:getChildByName("close_btn");
    self.m_close_btn:setOnClick(self,self.dismiss);
    self.add_phone_friend = self.m_bg:getChildByName("add_phone_friend");

    self.friendsView = self.m_bg:getChildByName("view_frame"):getChildByName("friends_list_view");
    self.recent_list_view = self.m_bg:getChildByName("view_frame"):getChildByName("recent_list_view");

    self.search_edit_text:setHintText("请输入昵称或游戏ID",165,145,125);
    local edit_w,edit_h = self.search_edit_text:getSize();
    local edit_x,edit_y = self.search_edit_text:getPos();
    self.search_edit_text:setClip(edit_x,edit_y,edit_w,edit_h);

    self.add_phone_friend:setOnClick(self,self.onGetPhoneFriend);
    if "ios"==System.getPlatform() then
	if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
	    self.add_phone_friend:setVisible(true);
	else
	    self.add_phone_friend:setVisible(false);
	end;
    end;
    self.search_btn:setOnClick(self,self.onSearch);
    
    self.m_default_text_view = self.m_bg:getChildByName("view_frame"):getChildByName("TextView1");
    self:setShieldClick(self,self.dismiss);

    self:setVisible(false);
end

AddFriendDialog.dtor = function(self)
    delete(self.FriendsloadingDialog);
    delete(self.m_chioce_dialog);
    delete(self.m_bangdinDialog);
    delete(self.m_exit_dialog);
    self.m_root_view = nil;
end

AddFriendDialog.isShowing = function(self)
    return self:getVisible();
end

AddFriendDialog.show = function(self,data)
    kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
	self:setVisible(true);
    self.super.show(self,false);

    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
    EventDispatcher.getInstance():register(Event.Call,self,self.onNativeCallDone);
    
    self:startAnim();
    self:initData(data);
end

AddFriendDialog.initData = function(self, datas)
    if datas and next(datas) then
    	self.m_default_text_view:setVisible(false);
        self.add_phone_friend:setVisible(false);
        self.friendsView:setVisible(true);
    
        self.m_adapter = new(CacheAdapter,AddFriendsItem,datas);
        self.friendsView:setAdapter(self.m_adapter);
    else
    	self.m_default_text_view:setVisible(true);
    	self.friendsView:setVisible(false);
        return;
    end;
end;

----------开始动画
AddFriendDialog.startAnim = function(self)
	print_string("ChatDialog.startAnim");
    for i = 1,4 do 
        if not self.m_bg:checkAddProp(i) then
            self.m_bg:removeProp(i);
        end 
    end
    local w,h = self.m_bg:getSize();
    local anim = self.m_bg:addPropTranslate(1,kAnimNormal,400,-1,0,0,h+25,0);
    if anim then
        anim:setEvent(self,function()
            self.m_bg:addPropTranslate(4,kAnimNormal,200,-1,0,0,0,-25);
            delete(anim);
            anim = nil;
        end);
    end

--    self.m_animGameTranslate = self.m_bg:addPropTranslateWithEasing(1,kAnimNormal, 600, -1, nil, "easeOutBounce", 0,0, h, -hs);
    self.m_animGameTranslate = new(AnimInt,kAnimNormal,0,1,600,-1);
    self.m_animGameTranslate:setEvent(self,self.onGameTranslateFinish);
    self.m_animGameTranslate:setDebugName("AnimInt|ChatDialog.startAnim");
end

AddFriendDialog.onGameTranslateFinish = function(self)
	for i = 1,4 do 
        if not self.m_bg:checkAddProp(i) then
            self.m_bg:removeProp(i);
        end 
    end
    delete(self.m_animGameTranslate);
end
-------------
AddFriendDialog.dismiss = function(self)
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeCallDone);
    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpRequestsCallBack);
--    self:setVisible(false);
    self.super.dismiss(self,false);

    for i = 1,4 do 
        if not self.m_bg:checkAddProp(i) then
            self.m_bg:removeProp(i);
        end 
    end

    local w,h = self.m_bg:getSize();
    self.m_animGameTranslate = self.m_bg:addPropTranslate(3,kAnimNormal,300,-1,0,0,0,h);
    self.m_bg:addPropTransparency(2,kAnimNormal,200,-1,1,0);
    self.m_animGameTranslate:setEvent(self,function()
	    self:setVisible(false);
        self.m_bg:removeProp(2);
        self.m_bg:removeProp(3);
        delete(self.m_animGameTranslate);
    end);
--    self.m_animGameTranslate:setDebugName("AnimInt|ChatDialog.startAnim");
end

AddFriendDialog.onHttpRequestsCallBack = function(self,command,...)
    Log.i("AddFriendDialog.onHttpRequestsCallBack");
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self,...);
	end 
end

AddFriendDialog.onNativeCallDone = function(self ,param , ...)
	if self.s_nativeEventFuncMap[param] then
		self.s_nativeEventFuncMap[param](self,...);
	end
end

--native事件回调监听
AddFriendDialog.onUpdatePhoneFriends = function(self,flag,json_data)
    if not json_data then return end;
    self:loadingTileExit();
    if not flag or not json_data or not json_data.ret then 
        ChessToastManager.getInstance():show("获取通信录失败!");
        return;
    end
    local info = {};
    info.phone_list = json_data.ret:get_value();
    local str = md5_string(info.phone_list);
    local strmd5 = kGameCacheData:getString(GameCacheData.TONG_XUN_LUMD5);
    if strmd5~= nil then
        if strmd5 ~= str then
            Log.i("ZY onUpdatePhoneFriends1");
            kGameCacheData:saveString(GameCacheData.TONG_XUN_LUMD5,str);
            HttpModule.getInstance():execute(HttpModule.s_cmds.mailListCll,info,"查询中...");
        else
            ChessToastManager.getInstance():show("没有发现新的手机好友");
        end
    else
        Log.i("ZY onUpdatePhoneFriends3");
        kGameCacheData:saveString(GameCacheData.TONG_XUN_LUMD5,str);
        HttpModule.getInstance():execute(HttpModule.s_cmds.mailListCll,info,"查询中");
    end

end
--------------------cliak---------------------------------
---添加手机好友按钮点击事件
AddFriendDialog.onGetPhoneFriend = function(self) --获取手机好友
    self.m_default_text_view:setVisible(false);
    if self.m_bangdinDialog then
        delete(self.m_bangdinDialog);
        self.m_bangdinDialog = nil;
    end
    local sid = UserInfo.getInstance():findBindAccountBySid(1);
    if sid ~= nil then
       if not self.m_chioce_dialog then
		   self.m_chioce_dialog = new(MailListDialog);
	   end
       self.m_chioce_dialog:setPositiveListener(self,self.onFriendsAddClickCall);
	   self.m_chioce_dialog:show(self.m_root_view);
    else -- 绑定手机
        ChessToastManager.getInstance():showSingle("请先绑定手机");
        require("dialog/bangdin_dialog");
        self.m_bangdinDialog = new(BangDinDialog);
--        self.m_bangdinDialog:setShowType(BangDinDialog.s_TYPE_PHONE);

        self.m_bangdinDialog:setHandler(self);
        self.m_bangdinDialog:show();
    end
end
--搜索
AddFriendDialog.onSearch = function(self)
    self.m_default_text_view:setVisible(false);
    local strdata = self.search_edit_text:getText();
--    self:requestCtrlCmd(AddFriendsController.s_cmds.search_btn,strdata);
    local post_data = {};
	post_data.keyword = strdata;
    HttpModule.getInstance():execute(HttpModule.s_cmds.searchFriends,post_data,"搜索中");
--    self:sendHttpMsg(HttpModule.s_cmds.searchFriends,post_data,"搜索中");
end
-------------------------------------------------------------


AddFriendDialog.onFriendsAddClickCall = function(self)

    delete(self.FriendsloadingDialog);
    self.FriendsloadingDialog = nil;
    self.FriendsloadingDialog = new(HttpLoadingDialog);
    self.FriendsloadingDialog:setType(HttpLoadingDialog.s_type.Normel,"上传通讯录",false);
    self.FriendsloadingDialog:show(nil,false);

    -- 防止有时候通讯录数据量大，LoadingDialog没有加载出来
    local delayAnim = new(AnimInt,kAnimNormal,0,1,200,0);
    if delayAnim then
        delayAnim:setEvent(nil,function()
            call_native(kGetPhoneNumByPhoneAndSIM);
        end);
    end

end

AddFriendDialog.loadingTileExit = function(self)
    if self.FriendsloadingDialog~= nil then
        self.FriendsloadingDialog:dismiss();
    end
end



---------------------http 响应-----------------------
--响应绑定事件
--AddFriendDialog.onBindUidResponse = function(self,isSuccess,message)
--    if not isSuccess then
--        ChessToastManager.getInstance():show( message or "请求失败!");
--        return ;
--    end
--    ChessToastManager.getInstance():show("绑定成功!");
----    self:updateView(UserInfoScene.s_cmds.updateUserInfoView);
--    if self.m_bangdinDialog then
--        self.m_bangdinDialog:dismiss();
--    end
----    self:updateView(UserInfoScene.s_cmds.dismissBindPhoneDialog);
--end

--搜索好友回调
AddFriendDialog.onGetSearchFriendsResponse = function(self,isSuccess,message)
    if not isSuccess then
        return;
    end
    local message = message.data;

--    self:updateView(AddFriendsScene.s_cmds.addFriends,message.list);

    if not message.list or #message.list < 1 then return ; end

    local ranks  = {};
	for _,value in pairs(message.list) do 
		local user = {};
		user.mid     = tonumber(value.mid:get_value()) or 0;
		user.score    = tonumber(value.score:get_value()) or 0;
        user.mnick     = ToolKit.subString(value.mnick:get_value(),16);
        user.icon_url = value.icon_url:get_value() or "";
		user.money = tonumber(value.money:get_value()) or 0;
		user.iconType     = value.iconType:get_value();
		user.mactivetime  = tonumber(value.mactivetime:get_value()) or 0;
        user.is_vip = tonumber(value.is_vip:get_value()) or 0;
        user.concat_name = value.concat_name:get_value() or "";
        table.insert(ranks,user);
	end
    if #ranks > 0 then
        self.add_phone_friend:setVisible(false);
        self.friendsView:setVisible(true);
--        self.phone_text.setText(self.phone_text,"搜索好友");
        
        self.m_adapter = new(CacheAdapter,AddFriendsItem,ranks);
        self.friendsView:setAdapter(self.m_adapter);
    end 
end
--手机好友回调
AddFriendDialog.onmailListResponse = function(self,isSuccess,message)
    if not isSuccess then
        if type(message) == "number" then
            return; 
        elseif message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value(),2000);
            return;
        end;        
    end;
    
    kGameCacheData:saveBoolean(GameCacheData.TONG_XUN_LU,true);

    local list_data = message.data.list;
    local list_total = message.data.total:get_value();
    if tonumber(list_total) == 0 then
        ChessToastManager.getInstance():show("没有发现新的手机好友");
        return;
    end;
    if not list_data then return ; end

    local ranks  = {};
	for _,value in pairs(list_data) do 
		local user = {};
		user.mid     = tonumber(value.mid:get_value()) or 0;
		user.score    = tonumber(value.score:get_value()) or 0;
        user.mnick     = ToolKit.subString(value.mnick:get_value(),16);
        user.icon_url = value.icon_url:get_value() or "";
		user.money = tonumber(value.money:get_value()) or 0;
		user.iconType     = value.iconType:get_value();
		user.mactivetime  = tonumber(value.mactivetime:get_value()) or 0;
        user.concat_name = value.concat_name:get_value() or "";
        table.insert(ranks,user);
	end

    if #ranks > 0 then

        self.add_phone_friend:setVisible(false);
        self.friendsView:setVisible(true);
    
        self.m_adapter = new(CacheAdapter,AddFriendsItem,ranks);
        self.friendsView:setAdapter(self.m_adapter);
    end

end


AddFriendDialog.updataFollowStatus = function(self,info)
    if info then
        if self.m_adapter ~= nil then
            local datas = self.m_adapter:getData();
            for i,uid in pairs(datas) do
                if tonumber(uid.mid) == info.target_uid and self.m_adapter:isHasView(i) then
                    local view = self.m_adapter:getTmpView(i);
                    self:changeFriendsView(view,info);
                end
            end
        end
   end

end

AddFriendDialog.changeFriendsView = function(self,view,info)
    if view ~= nil then
         --0,陌生人,=1粉丝，=2关注，=3好友
        if info.relation == 2 or info.relation == 3 then
            view.m_addtile.setText(view.m_addtile,"已关注");
            view.guanzhu = false;
        else
            view.m_addtile:setText("关注");
            view.guanzhu = true;
        end
    end
end

AddFriendDialog.s_nativeEventFuncMap = {
    [kGetPhoneNumByPhoneAndSIM] = AddFriendDialog.onUpdatePhoneFriends;
}

AddFriendDialog.s_httpRequestsCallBackFuncMap  = {
    
    [HttpModule.s_cmds.mailListCll]   = AddFriendDialog.onmailListResponse;
    [HttpModule.s_cmds.searchFriends] = AddFriendDialog.onGetSearchFriendsResponse;
--    [HttpModule.s_cmds.bindUid]       = AddFriendDialog.onBindUidResponse;
};

----------------private node---------------------------
AddFriendsItem = class(Node)
AddFriendsItem.s_w = 618;
AddFriendsItem.s_h = 131;

AddFriendsItem.idToIcon = UserInfo.DEFAULT_ICON;

AddFriendsItem.ctor = function(self,data)
    if next(data) == nil then   
        return;
    end

    self.datas = data;

    require(VIEW_PATH .."addfriend_node");
    self.m_root_view = SceneLoader.load(addfriend_node);
    self.m_root_view:setAlign(kAlignCenter);
    self:setSize(AddFriendsItem.s_w,AddFriendsItem.s_h);
    self:addChild(self.m_root_view);
    self.m_icon_mask = self.m_root_view:getChildByName("icon_bg"):getChildByName("icon_mask");
    self.m_vip_frame = self.m_root_view:getChildByName("icon_bg"):getChildByName("vip_frame");
    self.m_vip_logo = self.m_root_view:getChildByName("vip_logo");

    --头像
    local iconFile = AddFriendsItem.idToIcon[1];
   

    self.m_icon = new(Mask,iconFile,"common/background/head_mask_bg_86.png");
    if self.datas then
        if self.datas.iconType == -1 then
            self.m_icon:setUrlImage(self.datas.icon_url);
        else
            iconFile = AddFriendsItem.idToIcon[self.datas.iconType] or iconFile;
            self.m_icon:setUrlImage(iconFile);
        end
    end
    self.m_icon:setAlign(kAlignCenter);
    self.m_icon:setSize(self.m_icon_mask:getSize());
    self.m_icon_mask:addChild(self.m_icon);

    --段位
    self.m_level = self.m_root_view:getChildByName("level");
    self.m_level:setFile("common/icon/level_".. 10 - UserInfo.getInstance():getDanGradingLevelByScore(tonumber(self.datas.score))..".png"); 

    --名字
    self.m_tittle = self.m_root_view:getChildByName("name");
    self.m_tittle:setText(self.datas.mnick);

    --通讯录名字
    self.m_concat_name = self.m_root_view:getChildByName("concat_name");
    self.m_concat_name:setVisible(true);
    -- 通讯录名字显示
    if self.datas.concat_name and self.datas.concat_name ~= "" then
        local str_concat_name = "通讯录："..self.datas.concat_name;
        local lens = string.lenutf8(GameString.convert2UTF8(str_concat_name) or "");    
        if lens > 9 then--限制9字
            local str = GameString.convert2UTF8(string.subutf8(str_concat_name,1,9));
            self.m_concat_name:setText(str.."...");
        else
            self.m_concat_name:setText(str_concat_name);
        end;
    else
        self.m_concat_name:setText("");
    end;

    --ID
    local id = "ID: "..self.datas.mid.."";
    self.m_id = self.m_root_view:getChildByName("id");
    self.m_id:setText(id);

    --关注按钮
    self.m_add = self.m_root_view:getChildByName("follow");
    self.m_addtile = self.m_root_view:getChildByName("follow"):getChildByName("text");
    local kind = self:friendsMarkCall(tonumber(self.datas.mid));  
    if kind == 1 then
        self.m_add:setOnClick(self,self.onBtnClick);
        self.m_addtile:setText("关注");
        self.guanzhu = true;
    else
        self.m_add:setOnClick(self,self.onBtnClick);
        self.m_addtile:setText("已关注");
        self.guanzhu = false;
    end

    --vip头像相关
    local vx,vy = self.m_vip_logo:getPos();
    local vw,vh = self.m_vip_logo:getSize();
    if self.datas and self.datas.is_vip and self.datas.is_vip == 1 then
        self.m_tittle:setPos(vx+vw+3,vy);
        self.m_vip_frame:setVisible(true);
        self.m_vip_logo:setVisible(true);
    else
        self.m_tittle:setPos(138,-32);                   
        self.m_vip_frame:setVisible(false);
        self.m_vip_logo:setVisible(false);
    end

--    local frameRes = UserSetInfo.getInstance():getFrameRes();
--    self.m_vip_frame:setVisible(frameRes.visible);
--    local fw,fh = self.m_vip_frame:getSize();
--    if frameRes.frame_res then
--        self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
--    end

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
		   self.m_exit_dialog = new(ChioceDialog);
	   end
       self.m_exit_dialog:setMessage("是否取消关注?");
       self.m_exit_dialog:setPositiveListener(self,self.onExitGuanzhuClickCall);
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