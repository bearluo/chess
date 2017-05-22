--region NewFile_1.lua
--Author : FordFan
--Date   : 2015/11/11
--房间内观战
--endregion

require("view/view_config");
require(VIEW_PATH.."watch_room_list");
require(BASE_PATH.."chessDialogScene");
require("ui/node");
require("ui/adapter");
require("ui/listView"); 

WatchListDialog = class(ChessDialogScene,false);

WatchListDialog.s_type = 
{
    GAMER = 1;        --对手观战
    WATCHER = 2;      --旁观者观战
}

WatchListDialog.ctor = function(self,id)
    super(self,watch_room_list);

    self.m_root_view = self.m_root;
    self.m_bg = self.m_root_view:getChildByName("bg");
    self.m_bg:setEventTouch(self,function()end);
    self.m_close_btn = self.m_bg:getChildByName("close_btn");
    self.m_close_btn:setOnClick(self,self.dismiss);

    self.game_player_view = self.m_bg:getChildByName("game_player");
    self.watch_player_view = self.m_bg:getChildByName("watch_player");
    self.watch_view = self.m_bg:getChildByName("watch_line");
    self.game_view = self.m_bg:getChildByName("game_line");

    self.m_watchListView = new(ListView,0,0);
    self.m_watchListView:setAlign(kAlignCenter);
    self.m_watchListView:setDirection(kVertical);

    self.m_blackData = WatchListDialog.s_blackData or nil;
    self.m_redData = WatchListDialog.s_redData or nil;
    self.m_data = nil;

    local dialogType = 0;
    if id == self.m_blackData.m_uid then
        self.m_data = self.m_redData;
        dialogType = WatchListDialog.s_type.GAMER;
    elseif id == self.m_redData.m_uid then
        self.m_data = self.m_blackData;
        dialogType = WatchListDialog.s_type.GAMER;
    else
        dialogType = WatchListDialog.s_type.WATCHER;
    end

--    if self.m_blackData.m_uid == id then
--        self.data = self.m_redData;
--    elseif self.m_redData.m_uid == id then
--        self.data = self.m_blackData;
--    end
    self.clickType = 0;
    self:initTopView(dialogType);
    self:setShieldClick(self, self.dismiss);
end

WatchListDialog.dtor = function(self)
    self.m_root_view = nil;
end

WatchListDialog.isShowing = function(self)
    return self:getVisible();
end

WatchListDialog.show = function(self)
    print_string("ChatDialog.show");

    --获得观战列表
    local info = {};
    info.tid = UserInfo.getInstance():getTid();
    OnlineSocketManager.getHallInstance():sendMsg(OB_CMD_GET_OB_LIST,info);

	self:setVisible(true);
    self.super.show(self,false);
    self:updataListView(WatchListDialog.s_data);
    OnlineSocketManager.getHallInstance():sendMsg(OB_CMD_GET_NUM,info);
    local w,h = self.m_bg:getSize();
    for i = 1,4 do 
        if not self.m_bg:checkAddProp(i) then
            self.m_bg:removeProp(i);
        end 
    end
--    local anim = self.m_bg:addPropTranslateWithEasing(1,kAnimNormal, 400, -1, nil, "easeOutBounce", 0,0, h, -h);
    local anim = self.m_bg:addPropTranslate(1,kAnimNormal,400,-1,0,0,h+25,0);
    if anim then
        anim:setEvent(self,function()
            self.m_bg:addPropTranslate(4,kAnimNormal,200,-1,0,0,0,-25);
            delete(anim);
            anim = nil;
        end);
    end
    local anim_end = new(AnimInt,kAnimNormal,0,1,600,-1);
    if anim_end then
        anim_end:setEvent(self,function()
            for i = 1,4 do 
                if not self.m_bg:checkAddProp(i) then
                    self.m_bg:removeProp(i);
                end 
            end
            delete(anim_end);
            anim_end = nil;
        end);
    end
--    if not anim then return end;
--    anim:setEvent(self,function() 
--            self.m_bg:removeProp(1);
--        end)
end

WatchListDialog.dismiss = function(self)
    
    self.super.dismiss(self,false);
   
    local w,h = self.m_bg:getSize();
    for i = 1,4 do 
        if not self.m_bg:checkAddProp(i) then
            self.m_bg:removeProp(i);
        end 
    end
    local anim = self.m_bg:addPropTranslate(3, kAnimNormal, 300, -1, 0, 0, 0, h);
    self.m_bg:addPropTransparency(2,kAnimNormal,200,-1,1,0);
    if not anim then return end;
    anim:setEvent(self,function() 
            self.m_bg:removeProp(2);
            self.m_bg:removeProp(3);
            self:setVisible(false);
            delete(anim);
        end)
end

WatchListDialog.initTopView = function(self,watchType)
--    local func = function(view,enable)
--        Log.i(enable);
--        local title = view:getChildByName("text");
--        if title then
--            if enable then
--                title:removeProp(1);
--            else
--                title:addPropScaleSolid(1,1.1,1.1,1);
--            end
--        end
--    end

    if watchType == 1 then
        
        local func = function(view,enable)
            Log.i(enable);
            local title = view:getChildByName("text");
            if title then
                if enable then
                    title:removeProp(1);
                else
                    title:addPropScaleSolid(1,1.1,1.1,1);
                end
            end
        end

        self.game_player_view:setVisible(true);
        self.watch_player_view:setVisible(false);
        self.watch_view:setVisible(false);
        self.game_view:setVisible(true);

        --对手信息
        self.icon_mask = self.game_player_view:getChildByName("icon_bg"):getChildByName("icon_mask");
        self.name = self.game_player_view:getChildByName("name");
        self.level = self.game_player_view:getChildByName("level");
        self.score = self.game_player_view:getChildByName("score");
        self.follow_btn = self.game_player_view:getChildByName("follow_btn");
        self.m_vip_frame = self.game_player_view:getChildByName("icon_bg"):getChildByName("vip_frame");
        self.m_vip_logo = self.game_player_view:getChildByName("vip_logo");
        self.follow_btn:setOnTuchProcess(self.follow_btn,func);
        local data = {};
        data.item = self;
        data.typeBtn = 0;
        self.follow_btn:setOnClick(data,self.onFollowClick);
        self.btn_text = self.follow_btn:getChildByName("text");

        --观战人数
        self.watch_num = self.game_player_view:getChildByName("num");
        self.left_text = self.game_player_view:getChildByName("Text1");
        self.right_text = self.game_player_view:getChildByName("Text2");

        self.m_watchListView:setSize(self.game_view:getSize());
        self.game_view:addChild(self.m_watchListView);
        self:initGamerData();
    else
        
        local func = function(view,enable)
            Log.i(enable);
            local title = view:getChildByName("text");
            if title then
                if enable then
                    title:removeProp(1);
                else
                    title:addPropScaleSolid(1,1.1,1.1,1);
                end
            end
        end

        self.game_player_view:setVisible(false);
        self.watch_player_view:setVisible(true);
        self.watch_view:setVisible(true);
        self.game_view:setVisible(false);
        --红方信息
        self.red_view = self.watch_player_view:getChildByName("red_player");
        self.red_name_view = self.red_view:getChildByName("name_view");
        self.red_name = self.red_view:getChildByName("name_view"):getChildByName("name");
        self.red_icon_mask = self.red_view:getChildByName("icon_bg"):getChildByName("icon_mask");
        self.red_level = self.red_view:getChildByName("level");
        self.red_score = self.red_view:getChildByName("score");
        self.red_follow_btn = self.red_view:getChildByName("follow_btn");
        self.red_follow_btn:setOnTuchProcess(self.follow_btn,func);
        self.red_vip_frame = self.red_view:getChildByName("icon_bg"):getChildByName("vip_frame");
        local reddata = {};
        reddata.item = self;
        reddata.typeBtn = 1; -- 红方按钮
        self.red_follow_btn:setOnClick(reddata,self.onFollowClick);
        self.red_text = self.red_follow_btn:getChildByName("text");
        --黑方信息
        self.black_view = self.watch_player_view:getChildByName("black_player");
        self.black_name_view = self.black_view:getChildByName("name_view");
        self.black_name = self.black_view:getChildByName("name_view"):getChildByName("name");
        self.black_icon_mask = self.black_view:getChildByName("icon_bg"):getChildByName("icon_mask");
        self.black_level = self.black_view:getChildByName("level");
        self.black_score = self.black_view:getChildByName("score");
        self.black_follow_btn = self.black_view:getChildByName("follow_btn");
        self.black_follow_btn:setOnTuchProcess(self.follow_btn,func);
        self.black_vip_frame = self.black_view:getChildByName("icon_bg"):getChildByName("vip_frame");
        local blackdata = {};
        blackdata.item = self;
        blackdata.typeBtn = 2;
        self.black_follow_btn:setOnClick(blackdata,self.onFollowClick);
        self.black_text = self.black_follow_btn:getChildByName("text");
        --观战人数
        self.watch_num = self.watch_player_view:getChildByName("num");
        self.left_text = self.watch_player_view:getChildByName("Text1");
        self.right_text = self.watch_player_view:getChildByName("Text2");

        self.m_watchListView:setSize(self.watch_view:getSize());
        self.watch_view:addChild(self.m_watchListView);
        self:initPlayerData();
    end
    
end

WatchListDialog.setListView = function(self,data)
    WatchListDialog.s_data = data;
    if self:isShowing() then
        self:updataListView(data);
    end
end

WatchListDialog.setRedData = function(data)
    WatchListDialog.s_redData = data;
end

WatchListDialog.setBlackData = function(data)
    WatchListDialog.s_blackData = data;
end

WatchListDialog.initGamerData = function(self)
    if not self.m_data then
        return
    end
    
    if FriendsData.getInstance():isYourFollow(self.m_data.m_uid) == -1 and FriendsData.getInstance():isYourFriend(self.m_data.m_uid) == -1 then
        self.btn_text:setText("关注");
        self.follow_btn:setFile({"common/button/dialog_btn_3_normal.png","common/button/dialog_btn_3_press.png"});
    else
        self.btn_text:setText("取消关注");
        self.follow_btn:setFile({"common/button/dialog_btn_7_normal.png","common/button/dialog_btn_7_press.png"});
    end  

    
    self.icon = new(Mask,UserInfo.DEFAULT_ICON[1],"common/background/head_mask_bg_86.png");
    self.icon:setSize(self.icon_mask:getSize());
    self.icon:setAlign(kAlignCenter);
    self.icon_mask:addChild(self.icon);

    self.icon:setFile(UserInfo.DEFAULT_ICON[1]);
    local iconType = tonumber(self.m_data:getIconType());
    if iconType and iconType > 0 then
        self.icon:setFile(UserInfo.DEFAULT_ICON[iconType] or UserInfo.DEFAULT_ICON[1]);
    else
        if iconType == -1 then --兼容1.7.5之前的版本的头像为""时显示默认头像。
            self.icon:setUrlImage(self.m_data:getIcon(),UserInfo.DEFAULT_ICON[1]);
        end
    end

    self.name:setText(self.m_data.m_name);
    self.level:setFile("common/icon/level_" ..10-UserInfo.getInstance():getDanGradingLevelByScore(self.m_data.m_score) .. ".png");
    self.score:setText("积分:" .. self.m_data.m_score);

    local vx,vy = self.m_vip_logo:getPos();
    local vw,vh = self.m_vip_logo:getSize();

    if self.m_data.m_vip and tonumber(self.m_data.m_vip) == 1 then --测试
        self.name:setPos(vx+vw+3,-44);
        self.m_vip_frame:setVisible(true);
        self.m_vip_logo:setVisible(true);
    else
        self.name:setPos(133,-44);
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

WatchListDialog.initPlayerData = function(self)

   local func = function(view,enable)
        Log.i(enable);
        local title = view:getChildByName("text");
        if title then
            if enable then
                title:removeProp(1);
            else
                title:addPropScaleSolid(1,1.1,1.1,1);
            end
        end
    end  
    if self.m_redData then
    --红方
        if FriendsData.getInstance():isYourFollow(self.m_redData.m_uid) == -1 and FriendsData.getInstance():isYourFriend(self.m_redData.m_uid) == -1 then
            self.red_text:setText("关注");
            self.red_follow_btn:setFile({"common/button/dialog_btn_3_normal.png","common/button/dialog_btn_3_press.png"});
        else
            self.red_text:setText("取消关注");
            self.red_follow_btn:setFile({"common/button/dialog_btn_7_normal.png","common/button/dialog_btn_7_press.png"});
        end
        self.red_icon = new(Mask,UserInfo.DEFAULT_ICON[1],"common/background/head_mask_bg_86.png");
        self.red_icon:setSize(self.red_icon_mask:getSize());
        self.red_icon:setAlign(kAlignCenter);
        self.red_icon_mask:addChild(self.red_icon);

        self.red_icon:setFile(UserInfo.DEFAULT_ICON[1]);
        local iconType = tonumber(self.m_redData:getIconType());
        if iconType and iconType > 0 then
            self.red_icon:setFile(UserInfo.DEFAULT_ICON[iconType] or UserInfo.DEFAULT_ICON[1]);
        else
            if iconType == -1 then --兼容1.7.5之前的版本的头像为""时显示默认头像。
                self.red_icon:setUrlImage(self.m_redData:getIcon(),UserInfo.DEFAULT_ICON[1]);
            end
        end

        self.red_name:setText(self.m_redData.m_name,0,0);
        local width = self.red_name:getSize();
        local w = self.red_name_view:getChildByName("red"):getSize();
        self.red_name_view:setSize(width+w,nil);
        self.red_level:setFile("common/icon/big_level_"..10 - UserInfo.getInstance():getDanGradingLevelByScore(tonumber(self.m_redData.m_score))..".png");
        self.red_score:setText("积分:" .. self.m_redData.m_score);

        if self.m_redData.m_vip and tonumber(self.m_redData.m_vip) == 1 then
             self.red_vip_frame:setVisible(true);
        else
             self.red_vip_frame:setVisible(false);
        end
    end
    --黑方
    if self.m_blackData then
        if FriendsData.getInstance():isYourFollow(self.m_blackData.m_uid) == -1 and FriendsData.getInstance():isYourFriend(self.m_blackData.m_uid) == -1 then
            self.black_text:setText("关注");
            self.black_follow_btn:setFile({"common/button/dialog_btn_3_normal.png","common/button/dialog_btn_3_press.png"});
        else
            self.black_text:setText("取消关注");
            self.black_follow_btn:setFile({"common/button/dialog_btn_7_normal.png","common/button/dialog_btn_7_press.png"});
        end
        self.black_icon = new(Mask,UserInfo.DEFAULT_ICON[1],"common/background/head_mask_bg_86.png");
        self.black_icon:setSize(self.black_icon_mask:getSize());
        self.black_icon:setAlign(kAlignCenter);
        self.black_icon_mask:addChild(self.black_icon);

        self.black_icon:setFile(UserInfo.DEFAULT_ICON[1]);
        local iconType = tonumber(self.m_blackData:getIconType());
        if iconType and iconType > 0 then
            self.black_icon:setFile(UserInfo.DEFAULT_ICON[iconType] or UserInfo.DEFAULT_ICON[1]);
        else
            if iconType == -1 then --兼容1.7.5之前的版本的头像为""时显示默认头像。
                self.black_icon:setUrlImage(self.m_blackData:getIcon(),UserInfo.DEFAULT_ICON[1]);
            end
        end

        self.black_name:setText(self.m_blackData.m_name,0,0);
        local width = self.black_name:getSize();
        local w = self.black_name_view:getChildByName("black"):getSize();
        self.black_name_view:setSize(width+w,nil);
        self.black_level:setFile("common/icon/big_level_"..10 - UserInfo.getInstance():getDanGradingLevelByScore(tonumber(self.m_blackData.m_score))..".png");
        self.black_score:setText("积分:" .. self.m_blackData.m_score);

        if self.m_blackData.m_vip and tonumber(self.m_blackData.m_vip) == 1 then
             self.black_vip_frame:setVisible(true);
        else
             self.black_vip_frame:setVisible(false);
        end
    end

end

WatchListDialog.updataListView = function(self,data)
    if not data or #data == 0 then return end
    for _,v in pairs(data) do
        v.room = self;
    end

    self.m_obAdapter = new(CacheAdapter,ObListItem,data);
    self.m_watchListView:setAdapter(self.m_obAdapter);
end

WatchListDialog.onFollowClick = function(data)
   self = data.item;
   if data.typeBtn == 0 then 
        self.clickType = 0;
        if FriendsData.getInstance():isYourFollow(self.m_data.m_uid) == -1 and FriendsData.getInstance():isYourFriend(self.m_data.m_uid) == -1 then
            self:follow(self.m_data);
        else
            self:unFollow(self.m_data);
        end
   elseif data.typeBtn == 1 then
        self.clickType = 1;
        if FriendsData.getInstance():isYourFollow(self.m_redData.m_uid) == -1 and FriendsData.getInstance():isYourFriend(self.m_redData.m_uid) == -1 then
            self:follow(self.m_redData);
        else
            self:unFollow(self.m_redData);
        end
   elseif data.typeBtn == 2 then
        self.clickType = 2;
        if FriendsData.getInstance():isYourFollow(self.m_blackData.m_uid) == -1 and FriendsData.getInstance():isYourFriend(self.m_blackData.m_uid) == -1 then
            self:follow(self.m_blackData);
        else
            self:unFollow(self.m_blackData);
        end
   end
end
--关注
WatchListDialog.follow = function(self,data)
    local info = {};
    info.uid = UserInfo.getInstance():getUid();
    info.target_uid = data.m_uid;
    info.op = 1;
    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_ADD_FLLOW,info);
end

--取消关注
WatchListDialog.unFollow = function(self,data)
    local info = {};
    info.uid = UserInfo.getInstance():getUid();
    info.target_uid = data.m_uid;
    info.op = 0;
    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_ADD_FLLOW,info);
end
--更新状态
WatchListDialog.updataBtnText = function(self,info)
    if info.ret ~= 0 then
        ChessToastManager.getInstance():show("关注失败!");
        return ;
    end
    if self.clickType == 4 then
        local num =  #self.m_obAdapter:getData()
        if not self.m_obAdapter:getData() or num == 0 then
            return;
        end
        for i = 1,num do    
            local view = self.m_obAdapter:getView(i);
            if view.data.uid == info.target_uid then
                view:updataBtn(info);
                break;
            end
        end
        return;
    end
    if info.relation >= 2 then
        if self.clickType == 0 then
            self.btn_text:setText("取消关注");
            self.follow_btn:setFile({"common/button/dialog_btn_7_normal.png","common/button/dialog_btn_7_press.png"});
        elseif self.clickType == 1 then
            self.red_text:setText("取消关注");
            self.red_follow_btn:setFile({"common/button/dialog_btn_7_normal.png","common/button/dialog_btn_7_press.png"});
        elseif self.clickType == 2 then
            self.black_text:setText("取消关注");
            self.black_follow_btn:setFile({"common/button/dialog_btn_7_normal.png","common/button/dialog_btn_7_press.png"});
        end
    else
        if self.clickType == 0 then
            self.btn_text:setText("关注");
            self.follow_btn:setFile({"common/button/dialog_btn_3_normal.png","common/button/dialog_btn_3_press.png"});
        elseif self.clickType == 1 then
            self.red_text:setText("关注");
            self.red_follow_btn:setFile({"common/button/dialog_btn_3_normal.png","common/button/dialog_btn_3_press.png"});
        elseif self.clickType == 2 then
            self.black_text:setText("关注");
            self.black_follow_btn:setFile({"common/button/dialog_btn_3_normal.png","common/button/dialog_btn_3_press.png"});
        end
    end
end
--更新观战数量
WatchListDialog.updataWatchNum = function(self,info)
    if not info then return end

    self.watch_num:setText(info.ob_num);
    
    local pos_x,pos_y = self.watch_num:getPos();
    local w,h = self.watch_num:getSize();
    local lx = pos_x - w/2;
    local rx = pos_x + w/2
    self.left_text:setPos(lx - 53);
    self.right_text:setPos(rx + 70);

end

---------------private node-----------------------
ObListItem = class(Node);

ObListItem.idToIcon = UserInfo.DEFAULT_ICON;

ObListItem.ctor = function(self,data)
    if not data then return end
    
    self.room = data.room;
    self.data = json.decode(data.userInfo);
    require(VIEW_PATH.."watch_player_node");
    self.m_root_view = SceneLoader.load(watch_player_node);
    self.m_root_view:setAlign(kAlignCenter);
    
    self:setSize(self.m_root_view:getSize());
    self:setAlign(kAlignTop);

    self.bottom_line = new(Image,"common/decoration/cutline.png");
    self.bottom_line:setAlign(kAlignBottom);
    self.m_root_view:addChild(self.bottom_line);

    self.icon_mask = self.m_root_view:getChildByName("icon_bg"):getChildByName("icon_mask");
    self.m_name = self.m_root_view:getChildByName("name");
    self.m_level = self.m_root_view:getChildByName("level");
    self.m_score = self.m_root_view:getChildByName("score");
    self.m_followBtn = self.m_root_view:getChildByName("follow_btn");
    if UserInfo.getInstance():getUid() == data.uid then
        self.m_followBtn:setVisible(false);
    end
    self.m_btnText = self.m_followBtn:getChildByName("text");
    self.m_vip_frame = self.m_root_view:getChildByName("icon_bg"):getChildByName("vip_frame");
    self.m_vip_logo = self.m_root_view:getChildByName("vip_logo");
    self:addChild(self.m_root_view);
    
    local iconType = tonumber(self.data.icon);
        
    local iconFile = ObListItem.idToIcon[1];

    

    self.icon = new(Mask,iconFile,"common/background/head_mask_bg_86.png");
    if iconType then
        if 0 ~= iconType then
            iconFile = ObListItem.idToIcon[iconType] or iconFile;
            self.icon:setFile(iconFile);
        end;
    else
        if "" ~= self.data.icon then --兼容1.7.5之前的版本的头像为""时显示默认头像。
            self.icon:setUrlImage(self.data.icon);
        else
            self.icon:setFile(iconFile);
        end
    end
    self.icon:setSize(self.icon_mask:getSize());
    self.icon:setAlign(kAlignCenter);
    self.icon_mask:addChild(self.icon);

    self.m_name:setText(self.data.user_name);
    self.m_level:setFile("common/icon/level_"..10 - UserInfo.getInstance():getDanGradingLevelByScore(tonumber(self.data.score))..".png");
    self.m_score:setText("积分:"..self.data.score);
    if FriendsData.getInstance():isYourFollow(self.data.uid) == -1 and FriendsData.getInstance():isYourFriend(self.data.uid) == -1 then
        self.m_btnText:setText("关注");
        self.m_followBtn:setFile({"common/button/dialog_btn_3_normal.png","common/button/dialog_btn_3_press.png"});
    else
        self.m_btnText:setText("取消关注");
        self.m_followBtn:setFile({"common/button/dialog_btn_7_normal.png","common/button/dialog_btn_7_press.png"});
    end
    self.m_followBtn:setOnClick(self,self.onClick);

    local vx,vh = self.m_vip_logo:getPos();
    local vw,vh = self.m_vip_logo:getSize();
    local text = new(Text,self.data.user_name,nil,nil,nil,nil,32);
    local nw,nh = text:getSize();

    if self.data.is_vip and tonumber(self.data.is_vip) == 1 then
        self.m_name:setPos(vx + vw + 3,-16);
        self.m_vip_logo:setVisible(true);
        self.m_vip_frame:setVisible(true);
    else
        self.m_name:setPos(134,-16);
        self.m_vip_logo:setVisible(false);
        self.m_vip_frame:setVisible(false);
    end
--    local frameRes = UserSetInfo.getInstance():getFrameRes();
--    self.m_vip_frame:setVisible(frameRes.visible);
--    local fw,fh = self.m_vip_frame:getSize();
--    if frameRes.frame_res then
--        self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
--    end
    local func = function(view,enable)
        Log.i(enable);
        local title = view:getChildByName("text");
        if title then
            if enable then
                title:removeProp(1);
            else
                title:addPropScaleSolid(1,1.1,1.1,1);
            end
        end
    end

    self.m_followBtn:setOnTuchProcess(self.m_followBtn,func);


end

ObListItem.dtor = function(self)
    
end

ObListItem.onClick = function(self)
    self.room.clickType = 4;
    local info = {};
    info.uid = UserInfo.getInstance():getUid();
    info.target_uid = self.data.uid;
    if FriendsData.getInstance():isYourFollow(self.data.uid) == -1 and FriendsData.getInstance():isYourFriend(self.data.uid) == -1 then
        info.op = 1;
    else
        info.op = 0;
    end
    Log.i("info.op  "..info.op);
    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_ADD_FLLOW,info);
end

ObListItem.updataBtn = function(self,info)
    Log.i("info.relation  "..info.relation);
    if info.relation == 2 or info.relation == 3 then
        self.m_btnText:setText("取消关注");
        self.m_followBtn:setFile({"common/button/dialog_btn_7_normal.png","common/button/dialog_btn_7_press.png"});
    else
        self.m_btnText:setText("关注");
        self.m_followBtn:setFile({"common/button/dialog_btn_3_normal.png","common/button/dialog_btn_3_press.png"});
    end
end