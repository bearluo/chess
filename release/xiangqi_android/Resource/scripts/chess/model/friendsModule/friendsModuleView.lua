--friendsModuleView.lua
--Date 2016.8.23
--好友相关
--endregion
require("dialog/chioce_dialog");
require("dialog/http_loading_dialog");
require("dialog/add_friend_dialog");
require("dialog/common_share_dialog");

FriendsModuleView = class()



FriendsModuleView.DEFAULT_TIPS = 
{
    "和棋友互相关注可以成为好友哦",
    "大侠，您还没有关注棋友，关注棋友可与棋友互动哦",
    "大侠，您还没有粉丝",
}

FriendsModuleView.s_event = {
    UpdateView = EventDispatcher.getInstance():getUserEvent();
}

FriendsModuleView.s_cmds = 
{
    changeFriendstatus  = 1;
    changeFriendsData   = 2;
    changeFriendsList   = 3;
    changeFollowList    = 4;
    changeFansList      = 5;
    newfriendsNum       = 6;
    updataFriendsNum    = 7;
    updataFansNum       = 8;
    updataFollowNum     = 9;
    updataFriendsGames  = 10;
}

require(VIEW_PATH.."friend_module_view")
function FriendsModuleView.ctor(self,scene)
    FriendsModuleView.itemType = 1;
    self.mScene = scene
    self.m_root_node = SceneLoader.load(friend_module_view)
    self.mScene.m_friend_view:addChild(self.m_root_node);

    self.friends_list_check = true;
    self.attention_list_check = false;
    self.fans_list_check = false;

    self:initView()
end

function FriendsModuleView.dtor(self)
    delete(self.m_add_friends_dialog)
    self.m_add_friends_dialog = nil;
end

function FriendsModuleView.resume(self)
    EventDispatcher.getInstance():register(FriendsModuleView.s_event.UpdateView,self,self.refreshView);
    self:updataUserIcon()
--    self.m_icon:set
--    EventDispatcher.getInstance():register(Event.Call,self,self.onNativeCallDone);
end

function FriendsModuleView.pause(self)
    EventDispatcher.getInstance():unregister(FriendsModuleView.s_event.UpdateView,self,self.refreshView);
--    EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeCallDone);
end

function FriendsModuleView.initView(self)
    self.m_conetnt_view = self.m_root_node:getChildByName("content_view");
    self.m_no_friend_tip = self.m_conetnt_view:getChildByName("tips");
    self.m_no_friend_img = self.m_conetnt_view:getChildByName("img");
    --个人信息部分
    self.m_game_id = self.m_conetnt_view:getChildByName("my_id");
    self.m_icon_mask = self.m_conetnt_view:getChildByName("icon_frame"):getChildByName("icon_mask");
    self.m_vip_frame = self.m_conetnt_view:getChildByName("icon_frame"):getChildByName("vip_frame");
    self.m_game_id:setText(UserInfo.getInstance():getUid() .. "");
    self.m_icon = new(Mask,UserInfo.DEFAULT_ICON[1],"common/background/head_mask_bg_110.png");
    self.m_icon:setSize(self.m_icon_mask:getSize());
    self.m_icon:setAlign(kAlignCenter);
    self.m_icon_mask:addChild(self.m_icon);

    --切换按钮
    self.m_friends_btn = self.m_conetnt_view:getChildByName("friend_btn");
    self.m_friends_btn:setOnClick(self,self.onFriendsBtnClick);
    self.m_fans_btn = self.m_conetnt_view:getChildByName("fans_btn");
    self.m_fans_btn:setOnClick(self,self.onFriendsfansBtnClick);
    self.m_guanzhu_btn = self.m_conetnt_view:getChildByName("guanzhu_btn");
    self.m_guanzhu_btn:setOnClick(self,self.onFriendsattBtnClick);
    self.m_friends_btn_text = self.m_friends_btn:getChildByName("Text");
    self.m_fans_btn_text = self.m_fans_btn:getChildByName("Text");
    self.m_guanzhu_btn_text = self.m_guanzhu_btn:getChildByName("Text");
    self:setTextColor(); 

    --数量
    self.friendsNum = self.m_friends_btn:getChildByName("num");
    self.firendNewBg = self.m_friends_btn:getChildByName("new_bg");
    self.addFriendNum = self.firendNewBg:getChildByName("new_add_num"); -- 新增好友数量
    self.m_firend_btn_line = self.m_friends_btn:getChildByName("selet_line");

    self.guanzhuNum = self.m_guanzhu_btn:getChildByName("num");
    self.guanzhuNewBg = self.m_guanzhu_btn:getChildByName("new_bg");
    self.addGuanzhuNum = self.guanzhuNewBg:getChildByName("new_add_num"); -- 新增关注数量
    self.m_guanzhu_btn_line = self.m_guanzhu_btn:getChildByName("selet_line");

    self.fansNum = self.m_fans_btn:getChildByName("num");
    self.fansNewBg = self.m_fans_btn:getChildByName("new_bg");
    self.addFansNum = self.fansNewBg:getChildByName("new_add_num");  -- 新增粉丝数量
    self.m_fans_btn_line = self.m_fans_btn:getChildByName("selet_line");

    self.fansNewBg:setVisible(false);
    self.guanzhuNewBg:setVisible(false);
    self.firendNewBg:setVisible(false);

    --好友，粉丝，关注列表
    self.m_FriendsView = self.m_conetnt_view:getChildByName("friend_view");
    self.m_FansView = self.m_conetnt_view:getChildByName("fans_view");
    self.m_AttentionView = self.m_conetnt_view:getChildByName("guanzhu_view");
    self.m_FansView.m_autoPositionChildren = true;
    self.m_FriendsView.m_autoPositionChildren = true;
    self.m_AttentionView.m_autoPositionChildren = true;
    
    -- 通讯录有好友提示
    self.m_add_btn = self.m_conetnt_view:getChildByName("add_btn");
    self.m_add_btn:setOnClick(self,self.onAddFriendBtnClick);
    self.m_add_btn_tip = self.m_add_btn:getChildByName("red_img");

    local frameRes = UserSetInfo.getInstance():getFrameRes();
    self.m_vip_frame:setVisible(frameRes.visible);
    local fw,fh = self.m_vip_frame:getSize();
    if frameRes.frame_res then
        self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
    end

end

function FriendsModuleView.updataUserIcon(self)
    if UserInfo.getInstance():getIconType() == -1 then
        self.m_icon:setUrlImage(UserInfo.getInstance():getIcon());
    else
        self.m_icon:setFile(UserInfo.DEFAULT_ICON[UserInfo.getInstance():getIconType()] or UserInfo.DEFAULT_ICON[1]);
    end
end

function FriendsModuleView.onSendUpdataNum(self)
    FriendsModuleController.getInstance():getFriendsNum()
    FriendsModuleController.getInstance():getFansNum()
    FriendsModuleController.getInstance():getFollowNum()
--    local friendsNum = FriendsData.getInstance():getFriendsNum()
--    local fansNum = FriendsData.getInstance():getFansNum()
--    local guanzhuNum = FriendsData.getInstance():getFollowNum()

--    self.friendsNum:setText(friendsNum);
--    self.guanzhuNum:setText(guanzhuNum); 
--    self.fansNum:setText(fansNum);
end

function FriendsModuleView.setTextColor(self)
    if self.friends_list_check then
        self.m_friends_btn_text:setColor(215,75,45);
        self.m_guanzhu_btn_text:setColor(135,100,95)
        self.m_fans_btn_text:setColor(135,100,95);
    elseif self.attention_list_check then
        self.m_friends_btn_text:setColor(135,100,95);
        self.m_guanzhu_btn_text:setColor(215,75,45)
        self.m_fans_btn_text:setColor(135,100,95);
    elseif self.fans_list_check then
        self.m_friends_btn_text:setColor(135,100,95);
        self.m_guanzhu_btn_text:setColor(135,100,95)
        self.m_fans_btn_text:setColor(215,75,45);
    end
end

function FriendsModuleView.onAddFriendBtnClick(self)
    if not self.m_add_friends_dialog  then
        self.m_add_friends_dialog = new(AddFriendDialog,false);
    end
    self.m_add_friends_dialog:show()--self.newFriendsDatas)
    self.m_add_btn_tip:setVisible(false);
end

--[Comment]
--更新界面
function FriendsModuleView.refreshView(self,cmd, ...)
    if not self.s_cmdConfig[cmd] then
		return;
	end

	return self.s_cmdConfig[cmd](self,...)
end

--[Comment]
---用户状态更新
function FriendsModuleView.onChangeStatusCall(self,status)
    self:filterFriendsRelation();
    self:changeFriendsStatusCall(status);
end

--[Comment]
--用户数据更新
function FriendsModuleView.onChangeDataCall(self,state) 
    self:filterFriendsRelation();
    self:changeFriendsDataCall(state);
end

function FriendsModuleView.filterFriendsRelation(self)
    if self.m_friend_items then
        for i,item in pairs(self.m_friend_items) do
            local uid = item:getUid();
            if FriendsData.getInstance():isYourFriend(uid) == -1 then
                table.remove(self.m_friend_items,i);
            end;
        end;
    end;
    if self.m_attention_items then
        for i,item in pairs(self.m_attention_items) do
            local uid = item:getUid();
            if FriendsData.getInstance():isYourFollow(uid) == -1 then
                table.remove(self.m_attention_items,i);
            end;
        end;
    end;
    if self.m_fans_items then
        for i,item in pairs(self.m_fans_items) do
            local uid = item:getUid();
            if FriendsData.getInstance():isYourFans(uid) == -1 then
                table.remove(self.m_fans_items,i);
            end;
        end;
    end;   
end;

--新增通讯录好友数量
function FriendsModuleView.onChangeNewfriendsNumCall(self,datas)
    if datas == nil then 
        return; 
    end

    if self.newFriendsDatas == nil then
        self.m_add_btn_tip:setVisible(false);
    else
        if datas.total == 0 then
            self.m_add_btn_tip:setVisible(false);
        else
            self.m_add_btn_tip:setVisible(true);
        end
    end
end

function FriendsModuleView.onFriendsListCallBack(self,data)
    if self.friends_list_check and data and type(data) == "table" then --更新好友列表
        self:createFriendsListView(data);
    end
    --更新好友，粉丝新增数量
    self:updateNewNum();
end

--[Comment]
--更新好友列表
function FriendsModuleView.updateFriends_list(self)
    local datas = FriendsData.getInstance():getFrendsListData();
    self:createFriendsListView(datas);
end

function FriendsModuleView.createFriendsListView(self,datas)
    self.m_FriendsView:removeAllChildren(true);

    if not datas or #datas < 1 then 
        self:showNoLisTip(FriendsModuleView.itemType);
        self.m_AttentionView:removeProp(1);
        self.m_FansView:removeProp(1);
        self.m_FansView:setVisible(false);
        self.m_AttentionView:setVisible(false);
        return ; 
    end

    self.m_friendListData = datas;
    local friendOnline = {};
    local friendOffline = {};
    self.m_friend_items = {};

    for i,v in pairs(self.m_friendListData) do
        local temp = {};
        temp = new(FriendsItem,v,FriendsItem.s_friend_type);
        if not temp.status or temp.status.hallid <= 0 then
            table.insert(friendOffline,temp);
        else
            table.insert(friendOnline,temp);
        end
        temp:setOnClickCallBack(self,self.goToRoom);
        self.m_friend_items[i] = temp;
    end

--    self:refreshFriendsStatus();

    if #friendOnline > 0 then
        local node = new(LabelItem,1); --type 1：在线 2：离线
        self.m_FriendsView:addChild(node);
        for i,v in pairs(friendOnline) do 
            if i == #friendOnline then
                v.setBottomLine(v,false);
            end
            self.m_FriendsView:addChild(v);
        end
    end

    if #friendOffline > 0 then
        local node = new(LabelItem,2); --type 1：在线 2：离线
        self.m_FriendsView:addChild(node);
        for i,v in pairs(friendOffline) do 
            if i == #friendOnline then
                v.setBottomLine(v,false);
            end
            self.m_FriendsView:addChild(v);
        end
    end
    
    self:showNoLisTip();
    self.m_AttentionView:removeProp(1);
    self.m_FansView:removeProp(1);
    self.m_FansView:setVisible(false);
    self.m_AttentionView:setVisible(false);
    self.m_FriendsView:addPropTransparency(1,kAnimNormal,300,150,0,1);
    self.m_FriendsView:setVisible(true);
end

function FriendsModuleView.onFollowListCallBack(self,data)
    if self.attention_list_check and data and type(data) == "table" then --更新关注列表
        self:createAttentionListView(data);
    end
end

--[Comment]
--更新关注列表
function FriendsModuleView.updateAttention_list(self)
    local datas = FriendsData.getInstance():getFollowListData();
    self:createAttentionListView(datas);
end

function FriendsModuleView.createAttentionListView(self,datas)
    self.m_AttentionView:removeAllChildren(true);
    if not datas or #datas < 1 then
        self.m_FriendsView:removeProp(1);
        self.m_FansView:removeProp(1);
        self.m_FansView:setVisible(false);
        self.m_FriendsView:setVisible(false);
        return ; 
    end
    
    self.m_attentionListData = datas;
    local fellowOnline = {};
    local fellowOffline = {};
    self.m_attention_items = {};

    for i,v in pairs(self.m_attentionListData) do
        local temp = {};
        temp = new(FriendsItem,v,FriendsItem.s_follow_type);
        if not temp.status or temp.status.hallid <= 0 then
            table.insert(fellowOffline,temp);
        else
            table.insert(fellowOnline,temp);
        end
        self.m_attention_items[i] = temp;
    end

    if #fellowOnline > 0 then
        local node = new(LabelItem,1); --type 1：在线 2：离线
        self.m_AttentionView:addChild(node);
        for i,v in pairs(fellowOnline) do 
            if i == #fellowOnline then
                v.setBottomLine(v,false);
            end
            self.m_AttentionView:addChild(v);
        end
    end

    if #fellowOffline > 0 then
        local node = new(LabelItem,2); --type 1：在线 2：离线
        self.m_AttentionView:addChild(node);
        for i,v in pairs(fellowOffline) do 
            if i == #fellowOffline then
                v.setBottomLine(v,false);
            end
            self.m_AttentionView:addChild(v);
        end
    end

    self:showNoLisTip();
    self.m_FriendsView:removeProp(1);
    self.m_FansView:removeProp(1);
    self.m_FansView:setVisible(false);
    self.m_FriendsView:setVisible(false);
    self.m_AttentionView:addPropTransparency(1,kAnimNormal,300,150,0,1);
    self.m_AttentionView:setVisible(true);
end


function FriendsModuleView.onFansListCallBack(self,data)
    if self.fans_list_check and data and type(data) == "table" then --更新粉丝列表
        self:createFansListView(data);
    end
    --更新好友，粉丝新增数量
    self:updateNewNum();
end

--[Comment]
--更新粉丝列表
function FriendsModuleView.updateFans_list(self)
    local datas = FriendsData.getInstance():getFansListData();
    self:createFansListView(datas);
end

function FriendsModuleView.createFansListView(self,datas)
    self.m_FansView:removeAllChildren(true);
    if not datas or #datas < 1 then
        self.m_FriendsView:removeProp(1);
        self.m_AttentionView:removeProp(1);
        self.m_AttentionView:setVisible(false);
        self.m_FriendsView:setVisible(false);
        return ; 
    end
    
    self.m_fansListData = datas;
    local fansOnline = {};
    local fansOffline = {};
    self.m_fans_items = {};

    for i,v in pairs(self.m_fansListData) do 
        local temp = {};
        temp = new(FriendsItem,v,FriendsItem.s_fans_type);
        if not temp.status or temp.status.hallid <= 0 then
            table.insert(fansOffline,temp);
        else
            table.insert(fansOnline,temp);
        end
        self.m_fans_items[i] = temp;
    end
    
    if #fansOnline > 0 then
        local node = new(LabelItem,1); --type 1：在线 2：离线
        self.m_FansView:addChild(node);
        for i,v in pairs(fansOnline) do
            if i == #fansOnline then
                v.setBottomLine(v,false);
            end 
            self.m_FansView:addChild(v);
        end
    end

    if #fansOffline > 0 then
        local node = new(LabelItem,2); --type 1：在线 2：离线
        self.m_FansView:addChild(node);
        for i,v in pairs(fansOffline) do
            if i == #fansOffline then
                v.setBottomLine(v,false);
            end 
            self.m_FansView:addChild(v);
        end
    end

    self:showNoLisTip();
    self.m_FriendsView:removeProp(1);
    self.m_AttentionView:removeProp(1);
    self.m_AttentionView:setVisible(false);
    self.m_FriendsView:setVisible(false);
    self.m_FansView:addPropTransparency(1,kAnimNormal,300,150,0,1);
    self.m_FansView:setVisible(true);
end


function FriendsModuleView:showNoLisTip(listType)
    if not listType or listType < 1 or listType > 3 then 
        self.m_no_friend_tip:setVisible(false);
        self.m_no_friend_img:setVisible(false);
        return 
    end
    local msg = FriendsModuleView.DEFAULT_TIPS[listType];
    self.m_no_friend_tip:setText(msg);
    self.m_no_friend_tip:setVisible(true);
    self.m_no_friend_img:setVisible(true);
end

function FriendsModuleView.updateNewNum(self)
    local friendsNum = 0;
    local fansNum = 0;
    local friendsList = FriendsData.getInstance():getFrendsListData();
    local fansList = FriendsData.getInstance():getFansListData();

    if friendsList~= nil then
        for i,uid in pairs(friendsList) do
            if FriendsData.getInstance():isNewFriends(uid) == 1 then
                friendsNum = friendsNum + 1;
            end
        end
    end

    if fansList~= nil then
        for i,uid in pairs(fansList) do
            if FriendsData.getInstance():isNewFans(uid) == 1 then
                fansNum = fansNum + 1;
            end
        end
    end

    --好友和粉丝后面要显示新增加的好友和粉丝的数量
    if friendsNum <= 0 then
        self.firendNewBg:setVisible(false);
    else
        self.firendNewBg:setVisible(true);
        self.addFriendNum:setText("+"..friendsNum);--新增好友数量
    end

    if fansNum <= 0 then
        self.fansNewBg:setVisible(false);
    else
        self.fansNewBg:setVisible(true);
        self.addFansNum:setText("+"..fansNum);--新增粉丝数量
    end
end

--[Comment]
--好友按钮点击事件
function FriendsModuleView.onFriendsBtnClick(self) -- 切换好友
    if self.friends_list_check == false then
        self.friends_list_check = true;
        self.attention_list_check = false;
        self.fans_list_check = false;

        --文字颜色
        self:setTextColor();
        --按钮下红线
        self.m_firend_btn_line:setVisible(true);
        self.m_guanzhu_btn_line:setVisible(false);
        self.m_fans_btn_line:setVisible(false);
        --好友,关注,粉丝列表
        FriendsModuleView.itemType = 1;
        self.m_no_friend_tip:setVisible(false);
        self.m_no_friend_img:setVisible(false);
--        local datas = FriendsData.getInstance():getFrendsListData();
--        if not datas or #datas < 1 then 
--            self:showNoLisTip(FriendsModuleView.itemType);
--        end
        self:updateFriends_list();
--        self:exitNewTile2();
        self.firendNewBg:setVisible(false);
        self.fansNewBg:setVisible(false);
--        self:updateNewNum();
    end
end

function FriendsModuleView.onFriendsattBtnClick(self) --切换关注列表
    if self.attention_list_check == false then
        self.friends_list_check = false;
        self.attention_list_check = true;
        self.fans_list_check = false;
        --文字颜色
        self:setTextColor();
        --按钮下红线
        self.m_firend_btn_line:setVisible(false);
        self.m_guanzhu_btn_line:setVisible(true);
        self.m_fans_btn_line:setVisible(false);
        --好友,关注,粉丝列表
        FriendsModuleView.itemType = 2;
        self.m_no_friend_tip:setVisible(false);
        self.m_no_friend_img:setVisible(false);
--        local datas = FriendsData.getInstance():getFollowListData();
--        if not datas or #datas < 1 then
--            self:showNoLisTip(FriendsModuleView.itemType);
--        end
        self:updateAttention_list();
--        self:exitNewTile1();
--        self:exitNewTile2();
        self.firendNewBg:setVisible(false);
        self.fansNewBg:setVisible(false);
--        self:updateNewNum();
    end
end


function FriendsModuleView.onFriendsfansBtnClick(self)  --切换粉丝列表
    if self.fans_list_check == false then
        self.friends_list_check = false;
        self.attention_list_check = false;
        self.fans_list_check = true;
        --文字颜色
        self:setTextColor();
        --按钮下红线
        self.m_firend_btn_line:setVisible(false);
        self.m_guanzhu_btn_line:setVisible(false);
        self.m_fans_btn_line:setVisible(true);
        --好友,关注,粉丝列表
        FriendsModuleView.itemType = 3;
        self.m_no_friend_tip:setVisible(false);
        self.m_no_friend_img:setVisible(false);
--        local datas = FriendsData.getInstance():getFansListData();
--        if not datas or #datas < 1 then 
--            self:showNoLisTip(FriendsModuleView.itemType);   
--        end
        self:updateFans_list();
--        self:exitNewTile1();
        self.firendNewBg:setVisible(false);
        self.fansNewBg:setVisible(false);
--        self:updateNewNum();
    end
end

function FriendsModuleView.exitNewTile2(self)
    local datas2 = FriendsData.getInstance():getFansListData();
    if datas2 then
        for i,v_uid in pairs(datas2) do
            if FriendsData.getInstance():isNewFans(v_uid) == 1 then
                FriendsData.getInstance():setIsNewFans(v_uid,0);
            end
        end
    end
end

function FriendsModuleView.exitNewTile1(self)
    local datas1 = FriendsData.getInstance():getFrendsListData();
    if datas1 then
        for i,v_uid in pairs(datas1) do
            if FriendsData.getInstance():isNewFriends(v_uid) == 1 then
                FriendsData.getInstance():setIsNewFriends(v_uid,0);
            end
        end
    end
end

----------------func----------------------------

function FriendsModuleView.changeFriendsDataCall(self,data)
    if data then
        if self.m_friend_items then
            for i,item in pairs(self.m_friend_items) do
                local uid = item:getUid();
                for _,sdata in pairs(data) do
                    if uid == tonumber(sdata.mid) then
                        self:updateFriendsView(i,sdata,items);
                        break;
                    end
                end
            end;
        end;
        if self.m_attention_items then
            for i,item in pairs(self.m_attention_items) do
                local uid = item:getUid();
                for _,sdata in pairs(data) do
                    if uid == tonumber(sdata.mid) then
                        self:updateFriendsView(i,sdata,items);
                        break;
                    end
                end
            end;
        end;
        if self.m_fans_items then
            for i,item in pairs(self.m_fans_items) do
                local uid = item:getUid();
                for _,sdata in pairs(data) do
                    if uid == tonumber(sdata.mid) then
                        self:updateFriendsView(i,sdata,items);
                        break;
                    end
                end
            end;
        end;   
    end

end

function FriendsModuleView.changeFriendsStatusCall(self,status)
    if status then
        if self.m_friend_items then
            for i,item in pairs(self.m_friend_items) do
                local uid = item:getUid();
                for _,sdata in pairs(status) do
                    if uid == tonumber(sdata.mid) then
                        self:changeFriendsView(item,sdata);
                        break;
                    end
                end
            end;
        end;
        if self.m_attention_items then
            for i,item in pairs(self.m_attention_items) do
                local uid = item:getUid();
                for _,sdata in pairs(status) do
                    if uid == tonumber(sdata.mid) then
                        self:changeFriendsView(item,sdata);
                        break;
                    end
                end
            end;
        end;
        if self.m_fans_items then
            for i,item in pairs(self.m_fans_items) do
                local uid = item:getUid();
                for _,sdata in pairs(status) do
                    if uid == tonumber(sdata.mid) then
                        self:changeFriendsView(item,sdata);
                        break;
                    end
                end
            end;
        end;   
    end
end

function FriendsModuleView.changeFriendsView(self,view,status)
    if view ~= nil and status ~= nil then
        view.status = status;
        view.setOnlineStatus(view,status);
        view.m_title.setText(view.m_title,view.m_title.m_str);
        view.m_contentText.setText(view.m_contentText,view.m_contentText.m_str);
    end     
end

function FriendsModuleView.updateFriendsView(self,index,data,items)
    if items then
        items[index].updataItem(items[index],data);
    end
end

--[Comment]
--跳转房间，roomType: 房间类型  data: 好友数据
function FriendsModuleView.goToRoom(self,roomType,data)
    if not roomType or not data then return end
    if UserInfo.getInstance():isFreezeUser() then return end;

    if roomType == FriendsItem.s_challenge_room then
        UserInfo.getInstance():setTargetUid(data.mid);
        local post_data = {};
        post_data.uid = tonumber(UserInfo.getInstance():getUid());
        post_data.level = 320;
        local isCanCreate = RoomProxy.getInstance():canAccessRoom(RoomConfig.ROOM_TYPE_FRIEND_ROOM,UserInfo.getInstance():getMoney());
        if not isCanCreate then
            ChessToastManager.getInstance():show("金币不足或超出上限，发起挑战失败", 1000);
            return;
        end
        OnlineSocketManager.getHallInstance():sendMsg(CLIENT_HALL_CREATE_FRIENDROOM,post_data,nil,1);
    elseif roomType == FriendsItem.s_watch_room then
        --观战
        local isSuccess,msg = RoomProxy.getInstance():followUserByStatus(data.UserStatus)
        if not isSuccess then
            ChessToastManager.getInstance():showSingle(msg)
        end
    end
end

--[Comment]
--更新好友状态信息
function FriendsModuleView.refreshFriendsStatus(self)
    if not self.m_friend_items or not self.m_friendListData then return end
    FriendsData.getInstance():sendCheckUserStatus(self.m_friendListData);
end

function FriendsModuleView.onChangeFriendsNum(self,info)
    if info == nil then return end 
    local number = info.num.."";
    self.friendsNum:setText(number);
end

function FriendsModuleView.onChangeFansNum(self,info)
    if info == nil then return end
    local number = info.num.."";
    self.fansNum:setText(number);
end

function FriendsModuleView.onChangeFollowNum(self,info)
    if info == nil then return end 
    local number = info.num..""; 
    self.guanzhuNum:setText(number); 
end

function FriendsModuleView.onChangeFriendsGames(self,data)
    if self.m_friend_items then
        for i,item in pairs(self.m_friend_items) do
            local uid = item:getUid();
            for _,sdata in pairs(data) do
                if uid == tonumber(sdata.target_mid) then
                    item:updateFriendsComcat(sdata);
                    break
                end
            end
        end
    end

--    if self.m_friend_adapter and info then
--        local datas = self.m_friend_adapter:getData();
--        if datas then
--            for i,uid in pairs(datas) do
--                for _,sdata in pairs(status) do
--                    if uid == tonumber(sdata.target_mid) and self.m_friend_adapter:isHasView(i) then
--                        local view = self.m_friend_adapter:getTmpView(i);
--                        self:updateFriendsComcat(i,sdata,self.m_friend_adapter,view);
--                        break;
--                    end
--                end
--            end
--        end
--    end
end
------------------------------------------------


FriendsModuleView.s_cmdConfig = 
{
    [FriendsModuleView.s_cmds.changeFriendstatus]       = FriendsModuleView.onChangeStatusCall;
    [FriendsModuleView.s_cmds.changeFriendsData]        = FriendsModuleView.onChangeDataCall;
--    [FriendsModuleView.s_cmds.changeFriendsList]        = FriendsModuleView.onChangeFriendsListCall;
--    [FriendsModuleView.s_cmds.changeFollowList]         = FriendsModuleView.onChangeFollowListCall;
--    [FriendsModuleView.s_cmds.changeFansList]           = FriendsModuleView.onChangeFansListCall;
    [FriendsModuleView.s_cmds.changeFriendsList]        = FriendsModuleView.onFriendsListCallBack;
    [FriendsModuleView.s_cmds.changeFollowList]         = FriendsModuleView.onFollowListCallBack;
    [FriendsModuleView.s_cmds.changeFansList]           = FriendsModuleView.onFansListCallBack;
    [FriendsModuleView.s_cmds.newfriendsNum]            = FriendsModuleView.onChangeNewfriendsNumCall;
    [FriendsModuleView.s_cmds.updataFriendsNum]         = FriendsModuleView.onChangeFriendsNum;
    [FriendsModuleView.s_cmds.updataFansNum]            = FriendsModuleView.onChangeFansNum;
    [FriendsModuleView.s_cmds.updataFollowNum]          = FriendsModuleView.onChangeFollowNum;
    [FriendsModuleView.s_cmds.updataFriendsGames]       = FriendsModuleView.onChangeFriendsGames;

}

--------------------label node---------------------------
LabelItem = class(Node);
LabelItem.s_w = 600;
LabelItem.s_h = 40;

LabelItem.ctor = function(self,typelabel)
    self:setSize(LabelItem.s_w, LabelItem.s_h);
    self.m_bg = new(Image,"common/decoration/line_4.png");
    self.m_bg:setSize(527, 19);
    self.m_bg:setAlign(kAlignCenter);
    if typelabel == 1 then
        self.m_text = new(Text,"在线",nil,nil,kAlignCenter,nil,32,100,100,100);
    else
        self.m_text = new(Text,"离线",nil,nil,kAlignCenter,nil,32,100,100,100);
    end
    self.m_text:setAlign(kAlignCenter);
    self.m_bg:addChild(self.m_text);
    self:addChild(self.m_bg);
end


-----------------------private node-----------------------

require(VIEW_PATH .. "friends_view_node");
FriendsItem = class(Node)
FriendsItem.s_w = 600;
FriendsItem.s_h = 130;
FriendsItem.s_friend_type = 1;
FriendsItem.s_follow_type = 2;
FriendsItem.s_fans_type = 3;
FriendsItem.s_watch_room = 10;
FriendsItem.s_challenge_room = 11;

FriendsItem.ctor = function(self,dataid,itemType)
    self.m_data = dataid;
    if not dataid then return  end
        
    self.datas = FriendsData.getInstance():getUserData(dataid);
    self.status = FriendsData.getInstance():getUserStatus(dataid);
    if itemType and itemType ==FriendsItem.s_friend_type then
        self.comcat = FriendsData.getInstance():getUserCombat(dataid)
    end

    self.m_root_view = SceneLoader.load(friends_view_node);
    self.m_root_view:setAlign(kAlignCenter);
    self.m_node_view = self.m_root_view:getChildByName("node_view");
    self:addChild(self.m_root_view);
    local w,h = self.m_root_view:getSize()
    if itemType and itemType ==FriendsItem.s_friend_type then
        h = h + 22
    end
    self:setSize(w,h);
    self.itemType = itemType;
   
    --头像
    self.m_vip_frame = self.m_node_view:getChildByName("icon_bg"):getChildByName("vip_frame");
    local iconFile = UserInfo.DEFAULT_ICON[1];
    self.m_icon_mask = self.m_node_view:getChildByName("icon_bg"):getChildByName("icon_mask");
    self.m_icon = new(Mask, iconFile, "common/background/head_mask_bg_86.png");
    self.m_icon:setAlign(kAlignCenter);
    self.m_icon:setSize(self.m_icon_mask:getSize());
    self.m_icon_mask:addChild(self.m_icon);
    if self.datas then
        if self.datas.iconType == -1 then
            self.m_icon:setUrlImage(self.datas.icon_url);
        else
            self.m_icon:setFile(UserInfo.DEFAULT_ICON[self.datas.iconType] or iconFile);
        end
    end
    --段位
    self.m_level = self.m_node_view:getChildByName("level");
    self.m_level:setFile("common/icon/level_9.png");
    --名字
    self.m_title = self.m_node_view:getChildByName("name");
    self.m_vip_logo = self.m_node_view:getChildByName("vip_logo");
    --积分
    self.m_contentText = self.m_node_view:getChildByName("score");
    --状态
    self.m_offline = self.m_node_view:getChildByName("offline");
    self.m_statusButton = self.m_node_view:getChildByName("button");
    self.m_buttonText = self.m_statusButton:getChildByName("text");

    --详细信息按钮
    self.m_infoBtn = self.m_node_view:getChildByName("check_info");
    self.m_infoBtn:setOnClick(self,self.onBtnClick);
    self.m_infoBtn:setSrollOnClick();

    self.text = self.m_node_view:getChildByName("text")
    if self.itemType == 1 then
        self:updateFriendsComcat(self.comcat)
    else
        self.text:setVisible(false)
    end
    --底部装饰线
    self.m_bottomLine = self.m_node_view:getChildByName("item_line");
    self.m_bottomLine:setVisible(true);
    if itemType and itemType ==FriendsItem.s_friend_type then
        local x,y = self.m_bottomLine:getPos()
        self.m_bottomLine:setPos(x,y - 13)
    end

    self:setOnlineStatus(self.status);
    self:setItemUserInfo();
    self:setVipIconStatus();
end

FriendsItem.dtor = function(self)
    if self.m_statusButton then
        delete(self.m_statusButton);
        self.m_statusButton = nil;
    end;
end;


FriendsItem.setOnBtnClick = function(self,obj,func)
    self.m_btn_obj = obj;
    self.m_btn_func = func;
end

FriendsItem.onBtnClick = function(self)
    StateMachine.getInstance():pushState(States.FriendsInfo,StateMachine.STYPE_CUSTOM_WAIT,nil,tonumber(self.m_data));
end

FriendsItem.getUid = function(self)
    return self.m_data or 0;
end

FriendsItem.updataItem = function(self,data)
    self.datas = data;
    if self.datas then
        if self.datas.iconType == -1 then
            self.m_icon:setUrlImage(self.datas.icon_url);
        else
            self.m_icon:setFile(UserInfo.DEFAULT_ICON[self.datas.iconType] or UserInfo.DEFAULT_ICON[1]);
        end
    end

    self.m_level:setFile("common/icon/level_"..10 - UserInfo.getInstance():getDanGradingLevelByScore(tonumber(self.datas.score))..".png");
    self.m_title:setText(self.datas.mnick);
    self.m_contentText:setText("积分:"..self.datas.score);
end

FriendsItem.setBottomLine = function(self,ret)
    if not ret then
        self.m_bottomLine:setVisible(ret);
    end
end

--[Comment]
--设置item中联网状态，status: 好友状态数据
function FriendsItem.setOnlineStatus(self,status)
    self.status = status;
    --离线状态
    if not status or status.hallid <=0 then
        self.m_offline:setText("离线",nil,nil,125,80,65);
        self.m_offline:setPos(400,46);
        self.m_statusButton:setVisible(false);
        self.m_icon:setGray(true);
        return
    end

    --item类型
    if not self.itemType or self.itemType > 1 then
        self.m_offline:setPos(400,46);
        self.m_statusButton:setVisible(false);
    else
        self.m_offline:setPos(299,46);
        self.m_statusButton:setVisible(true);
    end

    --在线状态
    self.m_icon:setGray(false);
    if RoomConfig.getInstance():isPlaying(self.status) then
        local strname = RoomConfig.getInstance():onGetScreenings(status);
        self.m_offline:setText(strname or "游戏中",nil,nil,125,80,65); 
        self.m_buttonText:setText("观战");
        self.m_statusButton:setFile({"common/button/dialog_btn_7_normal.png","common/button/dialog_btn_7_press.png"});
        self.m_statusButton:setOnClick(self,function()
            self:gotoRoom(FriendsItem.s_watch_room,status);
        end);
    else
        self.m_offline:setText("闲逛中",nil,nil,25,115,40);
        self.m_buttonText:setText("挑战");
        self.m_statusButton:setFile({"common/button/dialog_btn_3_normal.png","common/button/dialog_btn_3_press.png"});
        self.m_statusButton:setOnClick(self,function()
            self:gotoRoom(FriendsItem.s_challenge_room);
        end);
    end
end

--[Comment]
--设置item中，名字和积分 
function FriendsItem.setItemUserInfo(self)
    --存在好友数据
    if self.datas then
        if self.datas.mnick then
            local lenth = string.lenutf8(GameString.convert2UTF8(self.datas.mnick));
            if lenth > 10 then    
                local str  = string.subutf8(self.datas.mnick,1,7).."...";
                self.m_title.setText(self.m_title,str);
            else
                self.m_title.setText(self.m_title,self.datas.mnick);    
            end
        else
            self.m_title.setText(self.m_title,self.m_data or "博雅象棋");
        end
        local  str = "积分:"..self.datas.score;
        self.m_contentText.setText(self.m_contentText,str);  
        self.m_level:setFile("common/icon/level_"..10 - UserInfo.getInstance():getDanGradingLevelByScore(tonumber(self.datas.score))..".png");  
        return
    end
    --好友数据为空
    local  str = "积分:0";
    self.m_title.setText(self.m_title,self.m_data or "博雅象棋");
    self.m_contentText.setText(self.m_contentText,str);  

end

--[Comment]
--设置item中，vip头像
function FriendsItem.setVipIconStatus(self)
    if self.datas and self.datas.my_set then
        local frameRes = UserSetInfo.getInstance():getFrameRes(self.datas.my_set.picture_frame or "sys");
        local fw,fh = self.m_vip_frame:getSize();
        if frameRes.frame_res then
            self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
        end
        self.m_vip_frame:setVisible(frameRes.visible);
    end
    local vw,vh = self.m_vip_logo:getSize();
    if self.datas and self.datas.is_vip == 1 then
        self.m_title:setPos(130+vw,25);
        self.m_vip_logo:setVisible(true);
    else
        self.m_title:setPos(130,25);
        self.m_vip_logo:setVisible(false);
    end
end

function FriendsItem.setOnClickCallBack(self,obj,func)
    self.callBackObj = obj;
    self.callBackFunc = func;
end

--[Comment]
--跳转房间，roomType: 好友游戏房间类型，status: 玩家状态
function FriendsItem.gotoRoom(self,roomType,status) 
    if self.callBackObj and self.callBackFunc then
        if not roomType then return end
        if not self.datas then return end
        local data = self.datas;
        data.UserStatus = status;
        self.callBackFunc(self.callBackObj,roomType,data);
    end
end


function FriendsItem.updateFriendsComcat(self, comcat)
    if comcat then
        local str = string.format("与TA对局:%d胜%d负%d和",comcat.wintimes,comcat.losetimes,comcat.drawtimes)
        self.text:setText(str)
    end
end
