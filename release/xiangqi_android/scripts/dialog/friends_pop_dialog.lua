--region friends_pop_dialog.lua
--Author : LeoLi
--Date   : 2015/7/15

require(VIEW_PATH .. "friends_pop_dialog_view");
require(BASE_PATH.."chessDialogScene")
FriendPopDialog = class(ChessDialogScene,false);

FriendPopDialog.MODE_MSG = 1;--发起聊天
FriendPopDialog.MODE_FIGHT = 2;--挑战好友

FriendPopDialog.ctor = function(self, room)
    super(self,friends_pop_dialog_view);
	self.m_root_view = self.m_root;
    self.m_room = room;
    self.m_bg = self.m_root_view:getChildByName("bg");
    --tittle
    self.m_tittle_view = self.m_bg:getChildByName("tittle_view");
    self.m_tittle_text = self.m_tittle_view:getChildByName("tittle");
--    self.m_tittle_cancel_btn = self.m_tittle_view:getChildByName("cancel");
--    self.m_tittle_cancel_btn:setOnClick(self, self.cancel);
--    self.m_tittle_sure_btn = self.m_tittle_view:getChildByName("sure");
--    self.m_tittle_sure_btn:setOnClick(self, self.sure);


    --search
    self.m_search_view = self.m_bg:getChildByName("search_view");
    self.m_search_bg = self.m_search_view:getChildByName("search_bg");
    self.m_search_text = self.m_search_bg:getChildByName("search_content");
    self.m_search_text:setHintText(GameString.convert2UTF8("点此输入好友昵称"),165,145,120);
    self.m_search_btn = self.m_search_view:getChildByName("search");
    self.m_search_btn:setOnClick(self, self.showSearchResult);

    --content
    self.m_content_view = self.m_bg:getChildByName("content_view");
    self.m_search_friend_view = self.m_bg:getChildByName("search_friend_view");
    
    self.m_no_friend_tips = self.m_bg:getChildByName("TextView1");
    self.m_add_friend = self.m_bg:getChildByName("add_friend");
    self.m_add_friend:setOnClick(self,self.toFirendsView);
    -- 拦截ShieldClick事件
    self.m_bg:setEventTouch(self,self.doNothing);
    -- 点击弹窗外 收回弹窗
    self:setShieldClick(self, self.dismiss);
    EventDispatcher.getInstance():register(Event.Call,self,self.onEventResponse);
    self.m_close_btn = self.m_bg:getChildByName("close_btn");
    self.m_close_btn:setOnClick(self,self.dismiss);
end;


FriendPopDialog.doNothing = function(self)
    Log.i("FriendPopDialog.doNothing");
end;

FriendPopDialog.toFirendsView = function(self)
    self:dismiss();
    local anim = new(AnimInt, kAnimNormal,0,1, 300, -1);
    if anim then
        anim:setEvent(self, function() 
	        if self.m_jumpFunc and self.m_jumpObj then 
                self.m_jumpFunc(self.m_jumpObj);
            end
        end)
    end
end



FriendPopDialog.dtor = function(self)
    delete(self.m_root_view);
	self.m_root_view = nil;
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onEventResponse);
end



FriendPopDialog.onEventResponse = function(self, cmd, status, data)
    
    if cmd == kFriend_UpdateStatus then
        if status then
            if self.m_friend_adapter then
                local datas = self.m_friend_adapter:getData();
                if datas then
                    for i,uid in pairs(datas) do
                        for _,sdata in pairs(status) do
                            if uid == tonumber(sdata.mid) and self.m_friend_adapter:isHasView(i) then
                                local view = self.m_friend_adapter:getTmpView(i);
                                self:changeFriendsView(view,sdata);
                            end
                        end
                    end
                end
            end
        end
    elseif cmd == kFriend_UpdateUserData then
        if self.m_friend_adapter and status then
            local datas = self.m_friend_adapter:getData();
            if datas then
                for i,uid in pairs(datas) do
                    for _,sdata in pairs(status) do
                        if uid == tonumber(sdata.mid) and self.m_friend_adapter:isHasView(i) then
                            local view = self.m_friend_adapter:getTmpView(i);
                            self:updateFriendsView(i,tonumber(sdata.mid),self.m_friend_adapter,view);
                            break;
                        end
                    end
                end
            end
        end
        
    elseif cmd == kFriend_UpdateFriendsList then
        self:loadFriendsList()
    elseif cmd == kCacheImageManager then
        if not status then 
            --下载失败
        end
        local info = json.analyzeJsonNode(data);
        for i,v in pairs(info) do
            Log.i(i ..":".. v );
        end
        if self.m_friend_adapter and status then
            local datas = self.m_friend_adapter:getData();
            if datas then
                for i,uid in pairs(datas) do
                    if uid == tonumber(info.what) and self.m_friend_adapter:isHasView(i) then
                        local view = self.m_friend_adapter:getTmpView(i);
                        self:updateFriendsIcon(i,info,self.m_friend_adapter,view);
                        break;
                    end
                end
            end
        end
    else

    end;
end;


FriendPopDialog.showSearchResult = function(self)
   local friendName = self.m_search_text:getText();
   if self.m_friend_adapter then
        local friendsUids = self.m_friend_adapter:getData();
        if friendsUids then
            local friendsData = FriendsData.getInstance():getUserData(friendsUids);
            local usr = {};
            for i, userData in ipairs(friendsData) do 
                if string.find(GameString.convert2UTF8(userData.mnick),friendName) then
                    table.insert(usr,tonumber(userData.mid));
                end;
            end;
            self:showFriends(usr);
        end;
   else
        ChessToastManager.getInstance():show(GameString.convert2UTF8("很抱歉，没有找到好友"),2000);
   end
end;




FriendPopDialog.showFriends = function(self, data)
    if #data == 0 then
        self.m_no_friend_tips:setVisible(true);
        ChessToastManager.getInstance():show(GameString.convert2UTF8("很抱歉，没有找到好友"),2000);
        return;
    end;
    if self.m_friends_list then
        self.m_content_view:removeChild(self.m_friends_list);
        self.m_content_view:removeAllChildren(true);
        self.m_friends_list:setVisible(false)
        delete(self.m_friends_list);
        self.m_friends_list = nil;
        self.m_friend_adapter = nil;
    end;
    self.m_friend_adapter = new(CacheAdapter, FriendsSceneItem, data);
    local w,h = self.m_content_view:getSize();
    self.m_friends_list = new(ListView,0,0,w,h);
    self.m_friends_list:setAdapter(self.m_friend_adapter);
    self.m_content_view:addChild(self.m_friends_list);
    self.m_friends_list:setOnItemClick(self, self.onItemClick)
end;



FriendPopDialog.changeFriendsView = function(self,view,status)
    local time = FriendsScene.getTime(status.last_time);
    if view ~= nil and status ~= nil then
        if status.hallid <=0 then --离线
            view.m_icon:setGray(true);
            view.m_title.setText(view.m_title,view.m_userData.user_name,nil,nil,100,100,100);
            view.m_contentText.setText(view.m_contentText,string.format("%d积分",view.m_userData.score),nil, nil,100,100,100);
            view.m_lasttimeTitle.setText(view.m_lasttimeTitle,"最近登陆:"..time,nil, nil,100,100,100);
        else --在线
            view.m_icon:setGray(false);
            view.m_title.setText(view.m_title,view.m_userData.user_name,nil,nil,80, 80, 80);
            view.m_contentText.setText(view.m_contentText,string.format("%d积分",view.m_userData.score),nil, nil,125, 80, 65);
            view.m_lasttimeTitle.setText(view.m_lasttimeTitle,"最近登陆:"..time,nil, nil,80, 80, 80);
        end 
    end     
end   


FriendPopDialog.updateFriendsView = function(self,index,data,m_adapte,view)
    if m_adapte then
        m_adapte:updateData(index,data);
    end
--    local friend_item = m_adapte:getView(index);
--    --段位更新
--    if friend_item~= nil then
--        friend_item.m_level:setFile("userinfo/"..UserInfo.getInstance():getDanGradingLevelByScore(tonumber(friend_item.datas.score))..".png");
--    end
end


FriendPopDialog.updateFriendsIcon = function(self,index,data,m_adapte,view)
    if m_adapte:isHasView(index) then
        local friend_item = m_adapte:getTmpView(index);
        if friend_item~= nil and data then
            if data.ImageName then
                friend_item.m_icon:setFile(data.ImageName);
            end;
        end
    end
end;



FriendPopDialog.isShowing = function(self)
	return self:getVisible();
end

FriendPopDialog.show = function(self)
	print_string("FriendPopDialog.show ... ");
	kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
    self.m_no_friend_tips:setVisible(false);
--    self:setMaskTransPropAnim(1);
    ScrollAnim.scroll_time = 320;
    ScrollAnim.play(self.m_bg,ScrollAnim.MODE_UP);
    self:loadFriendsList();
    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
	self:setVisible(true);
    self.super.show(self,false);
end



FriendPopDialog.loadFriendsList = function(self,data) 
    if self.m_friends_list then
        delete(self.m_friends_list);
        self.m_friends_list = nil;
        self.m_friend_adapter = nil;
    end;
    self.m_no_friend_tips:setVisible(false);
    self.m_friendUids = FriendsData.getInstance():getFrendsListData();
    if not self.m_friendUids or #self.m_friendUids == 0 then
        self.m_no_friend_tips:setVisible(true);
        return;
    end;
    self.m_friend_adapter = new(CacheAdapter, FriendsSceneItem, self.m_friendUids);
    local w,h = self.m_content_view:getSize();
    self.m_friends_list = new(ListView,0,0,w,h);
    self.m_friends_list:setAdapter(self.m_friend_adapter);
    self.m_content_view:addChild(self.m_friends_list);
    self.m_friends_list:setOnItemClick(self, self.onItemClick)
end;
FriendPopDialog.onItemClick = function(self, adapter, view, index, viewX, viewY)
    Log.i("FriendPopDialog.onItemClick");
    self.m_checkeindex = index;
    if self.m_friend_adapter and self.m_friend_adapter:isHasView(index) then
        self:entryChallengeRoom();
--        for i = 1, self.m_friend_adapter:getCount() do
--            if self.m_friend_adapter:isHasView(i) then
--                self.m_friend_adapter:getTmpView(i):setFriendChecked(false);
--            end  
--        end;
--        if self.m_friend_adapter:isHasView(index) then
--            self.m_friend_adapter:getTmpView(index):setFriendChecked(true);
--        end
    end;
end;
--FriendPopDialog.cancel = function(self)
--	print_string("FriendPopDialog.cancel ");
--	self:dismiss();
--end
FriendPopDialog.setJumpFriendsCallBack = function(self,obj,func)
    self.m_jumpObj = obj;
    self.m_jumpFunc = func;
end


FriendPopDialog.entryChallengeRoom = function(self)
	print_string("FriendPopDialog.entryChallengeRoom ");
	self:dismiss();
    local anim = new(AnimInt, kAnimNormal,0,1, 300, -1);
    if anim then
        anim:setEvent(self, function() 
	        if self.m_posObj and self.m_posFunc then
                if self.m_friend_adapter then
                    self.m_posFunc(self.m_posObj, self.m_friend_adapter, nil, self.m_checkeindex);
                    self.m_checkeindex = nil;
                end;
	        end
        end)
    end
end

FriendPopDialog.setMessage = function(self,message)
 	self.m_message:setText(message);
end

FriendPopDialog.setMode = function(self,mode)
	self.m_mode = mode;	
	if self.m_mode == FriendPopDialog.MODE_MSG then
        self.m_tittle_text:setText("发起聊天");
	elseif self.m_mode == FriendPopDialog.MODE_FIGHT then
        self.m_tittle_text:setText("选择好友");
	end
end

FriendPopDialog.setPositiveListener = function(self,obj,func)
	self.m_posObj = obj;
	self.m_posFunc = func;
end


FriendPopDialog.setNegativeListener = function(self,obj,func)
	self.m_negObj = obj;
	self.m_negFunc = func;
end


FriendPopDialog.dismiss = function(self)
    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpRequestsCallBack);
--    self:setMaskTransPropAnim(2);
    ScrollAnim.scroll_time = 320;
    ScrollAnim.play(self.m_bg,ScrollAnim.MODE_DOWN,false, self, self.setRootUnVisible);
    self.m_search_text:setText(nil);
    self.super.dismiss(self,false);
end

FriendPopDialog.setRootUnVisible = function(self)
    self:setVisible(false);
end;




----------------------------------FriendItem--------------------------------
FriendsSceneItem = class(Node)
FriendsSceneItem.s_w = 640;
FriendsSceneItem.s_h = 135;

FriendsSceneItem.idToIcon = UserInfo.DEFAULT_ICON;


FriendsSceneItem.ctor = function(self,dataid)
    self.m_data = dataid;
    if not dataid then return ; end
  
    self.datas = FriendsData.getInstance():getUserData(dataid);
    self.status = FriendsData.getInstance():getUserStatus(dataid);

    self:setSize(FriendsSceneItem.s_w,FriendsSceneItem.s_h);

    self.m_bg = new(Button,"drawable/blank.png","drawable/blank_press.png");
    self.m_bg:setPos(0,0);
    self.m_bg:setSize(640,135);
    self.m_bg:setAlign(kAlignLeft);
--    self.m_bg:setOnClick(self,self.onBtnClick);
    self.m_bg_line = new(Image,"common/decoration/name_line.png");
    self.m_bg_line:setSize(640,nil);
    self.m_bg_line:setAlign(kAlignBottom);
    self.m_bg:addChild(self.m_bg_line);
    
    self:addChild(self.m_bg);
   
    --头像
    local iconFile = FriendsSceneItem.idToIcon[1];
    
    self.m_icon_bg = new(Image,"userinfo/icon_9090_frame.png");
    self.m_icon_bg:setAlign(kAlignLeft);
    self.m_icon_bg:setPos(30,nil);
    self.m_bg:addChild(self.m_icon_bg);

    if not self.m_icon then
        self.m_icon = new(Mask,iconFile,"userinfo/icon_8484_mask.png");
        self.m_icon:setSize(84,84);
        self.m_icon:setAlign(kAlignCenter);
        self.m_icon_bg:addChild(self.m_icon)
    else
        self.m_icon:setFile(iconFile);
    end
    if self.datas then
        if self.datas.iconType == -1 then
            self.m_icon:setUrlImage(self.datas.icon_url);
        else
            iconFile = FriendsSceneItem.idToIcon[self.datas.iconType] or iconFile;
            self.m_icon:setFile(iconFile);
        end
    end
    self.m_vip_frame = new(Image,"vip/vip_90.png");
    local vw,vh = self.m_icon_bg:getSize();
    self.m_vip_frame:setSize(vw,vh);
    self.m_vip_frame:setAlign(kAlignCenter);
    self.m_icon_bg:addChild(self.m_vip_frame);
    --段位
    self.m_level = new(Image,"common/icon/level_9.png");
    self.m_level:setAlign(kAlignLeft);
    self.m_level:setPos(145,25);
    self.m_bg:addChild(self.m_level);

    local sx = 30 + self.m_icon:getSize(); 
    local sy = 25;

    if self.datas ~= nil then
        self.m_userData = self.datas;
        --名字
        self.m_title = new(Text,self.m_userData.mnick,nil, nil, nil, nil, 32, 80, 80, 80);
--        self.m_title:setPos(sx + 25,sy);
        --积分
        self.m_contentText = new(Text,string.format("%d积分",self.m_userData.score),nil, nil, nil, nil, 24, 125, 80, 65);
        self.m_contentText:setPos(sx + 95,sy + 55);
        if self.status ~= nil then
            local time = self:getTime(self.status.last_time);
            if self.status.hallid <=0 then --离线
                self.m_icon:setGray(true);
                self.m_title.setText(self.m_title,self.m_userData.mnick,nil,nil,100,100,100);
                self.m_contentText:setColor(100,100,100);
                self.m_lasttimeTitle = new(Text,"最近登陆:"..time,nil, nil, nil, nil, 24, 100, 100, 100);          
            else -- 在线
                self.m_title.setText(self.m_title,self.m_userData.mnick,nil,nil,80, 80, 80);
                self.m_contentText:setColor(125, 80, 65); 
                self.m_lasttimeTitle = new(Text,"最近登陆:"..time,nil, nil, nil, nil, 24, 80, 80, 80);
            end
            self.m_lasttimeTitle:setAlign(kAlignRight);
            self.m_lasttimeTitle:setPos(20,26);
        end
        self.m_level:setFile("common/icon/level_"..(10 - UserInfo.getInstance():getDanGradingLevelByScore(tonumber(self.datas.score)))..".png");
    else
        --名字
        self.m_title = new(Text,"未知",nil, nil, nil, nil, 32, 80, 80, 80);
--        self.m_title:setPos(sx + 25,sy);
        self.m_contentText = new(Text,string.format("%d积分",0),nil, nil, nil, nil, 24, 125, 80, 65);
        self.m_contentText:setPos(sx + 95,sy + 55);
    end

    --VIP
    self.m_vip_logo = new(Image,"vip/vip_logo.png");
--    self.m_vip_logo:setPos(sx + 25,sy);
    
    self.m_is_vip = nil;
    if self.datas then
        self.m_is_vip = self.datas.is_vip;
    end
    self.m_name_view = new(Node);
    local logow,logoh = self.m_vip_logo:getSize();
    local namew,nameh = self.m_title:getSize();
    self.m_name_view:setSize(logow + namew + 10,nameh);
    self.m_name_view:setPos(sx + 30,sy+5);
    self.m_name_view:addChild(self.m_vip_logo);
    self.m_name_view:addChild(self.m_title);
    self.m_vip_logo:setAlign(kAlignLeft);
    

    if self.m_is_vip and self.m_is_vip == 1 then
        self.m_vip_frame:setVisible(true);
        self.m_vip_logo:setVisible(true);
        self.m_title:setAlign(kAlignRight);
    else
        self.m_vip_frame:setVisible(false);
        self.m_vip_logo:setVisible(false);
        self.m_title:setAlign(kAlignLeft);
    end

--    local frameRes = UserSetInfo.getInstance():getFrameRes();
--    self.m_vip_frame:setVisible(frameRes.visible);
--    local fw,fh = self.m_vip_frame:getSize();
--    if frameRes.frame_res then
--        self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
--    end

    self.m_bg:addChild(self.m_lasttimeTitle);
    self.m_bg:addChild(self.m_name_view);
    self.m_bg:addChild(self.m_contentText);
end

FriendsSceneItem.setOnBtnClick = function(self,obj,func)
    self.m_btn_obj = obj;
    self.m_btn_func = func;
end

FriendsSceneItem.onBtnClick = function(self)
    Log.d("FriendsSceneItem.onBtnClick");
end

FriendsSceneItem.setFriendChecked = function(self, isChecked)
    if isChecked then
        self:setColor(100, 100, 100);
    else
        self:setColor(255, 255, 255);
    end;

end;

FriendsSceneItem.getTime = function(self, time)
	if time < 0 then
		return "7+";
	end
	return os.date("%H:%M",time);--%Y/%m/%d %X
end
