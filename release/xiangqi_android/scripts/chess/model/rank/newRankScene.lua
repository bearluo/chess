--region NewFile_1.lua
--Author : FordFan
--Date   : 2015/11/4
--此文件由[BabeLua]插件自动生成



--endregion
require(BASE_PATH.."chessScene");
require("dialog/chioce_dialog");
require("dialog/http_loading_dialog");

require(MODEL_PATH.."friendsInfo/friendsInfoController");

NewRankScene = class(ChessScene);

NewRankScene.idToIcon = {
    [0] = "userinfo/userHead.png";
    [1] = "userinfo/women_head01.png";
    [2] = "userinfo/man_head02.png";
    [3] = "userinfo/man_head01.png";
    [4] = "userinfo/women_head02.png";
}

NewRankScene.default_icon = UserInfo.DEFAULT_ICON[1];

NewRankScene.s_controls = 
{
    back_btn            = 1;
    friends_rank_btn    = 2;
    charm_rank_btn      = 3;
    master_rank_btn     = 4;
    friend_rank_view    = 5;   -- 好友榜
    charm_rank_view     = 6;   -- 魅力榜
    master_rank_view    = 7;   -- 大师榜

    my_rank_view        = 8;   -- 我的排行
    my_rank_mask        = 9;
    my_rank_name        = 10;
    my_rank_type        = 11;
    my_rank             = 12;

    rank_view           = 13;
    teapot_dec          = 14;  -- 茶壶
    book_mark           = 15;  -- 右标签
}

NewRankScene.s_cmds = 
{
    change_friends      = 1;--好友
    change_charm        = 2;--魅力
    change_master       = 3;--大师榜

    change_userIcon     = 4; -- 更新用户头像

    my_friend_rank      = 5;
    my_charm_rank       = 6;
    my_master_rank      = 7;

    changeFriendstatus  = 8;
    changeFriendsData   = 9;

}

NewRankScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = NewRankScene.s_controls;

    self.m_rankType = controller.m_state.rankType;
    --排行榜
    self.friendslist_check = false;   
    self.charmlistlist_check = false;
    self.masterlist_check = false;

    if self.m_rankType == 1 then
        self.friendslist_check = true;
    elseif self.m_rankType == 2 then
        self.charmlistlist_check = true;
    elseif self.m_rankType == 3 then
        self.masterlist_check = true;
    end

    self:initView();
end 
NewRankScene.resume = function(self)
    ChessScene.resume(self);
--    self:removeAnimProp();
--    self:resumeAnimStart();
end;


NewRankScene.pause = function(self)
	ChessScene.pause(self);
    self:removeAnimProp();
--    self:pauseAnimStart();
end 


NewRankScene.dtor = function(self)
    delete(self.RankloadingDialog);
    delete(self.anim_start);
    delete(self.anim_end);
end 

NewRankScene.removeAnimProp = function(self)
--    self.m_teapot_dec:removeProp(1);
--    self.m_back_btn:removeProp(1);
    self.rank_view:removeProp(1);
    self.book_mark:removeProp(1);
    self.m_leaf_left:removeProp(1);
end

NewRankScene.setAnimItemEnVisible = function(self,ret)
    self.m_leaf_left:setVisible(ret);
--    self.right_leaf:setVisible(ret);
end

NewRankScene.resumeAnimStart = function(self,lastStateObj,timer)
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

    self.rank_view:addPropTransparency(1,kAnimNormal,waitTime,delay,0,1);
    local lw,lh = self.m_leaf_left:getSize();
    self.m_leaf_left:addPropTranslate(1, kAnimNormal, waitTime, delay, -lw, 0, -10, 0);
    local tw,th = self.book_mark:getSize();
    local anim = self.book_mark:addPropTranslate(1, kAnimNormal, waitTime, delay, 0, 0, -th, 0);
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

NewRankScene.pauseAnimStart = function(self,newStateObj,timer)
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;
    delete(self.anim_end)
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

    self.rank_view:addPropTransparency(1,kAnimNormal,waitTime,-1,1,0);
    local lw,lh = self.m_leaf_left:getSize();
    self.m_leaf_left:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, -lw, 0, -10);
    local tw,th = self.book_mark:getSize();
    local anim = self.book_mark:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, 0, 0, -th);
    if anim then
        anim:setEvent(self,function()
            self:setAnimItemEnVisible(false);
        end);
    end
end

NewRankScene.onBack = function(self)
    print_string("back...");
    self:requestCtrlCmd(NewRankController.s_cmds.back_action);
end

--界面初始化
NewRankScene.initView = function(self)
    Log.d("NewRankScene.init......");
    NewRankScene.itemPaiHangType = 1;
    self.rank_view = self:findViewById(self.m_ctrls.rank_view);
    self.m_teapot_dec = self:findViewById(self.m_ctrls.teapot_dec);
    self.m_back_btn = self:findViewById(self.m_ctrls.back_btn);
    self.book_mark = self:findViewById(self.m_ctrls.book_mark);

    self.charmlist_btn = self:findViewById(self.m_ctrls.charm_rank_btn);
    self.friendslist_btn = self:findViewById(self.m_ctrls.friends_rank_btn);
    self.masterlist_btn = self:findViewById(self.m_ctrls.master_rank_btn);

    self.m_FriendslistView = self:findViewById(self.m_ctrls.friend_rank_view); 
    self.m_CharmlistView = self:findViewById(self.m_ctrls.charm_rank_view);
    self.m_MasterlistView = self:findViewById(self.m_ctrls.master_rank_view);

    self.charmList_line = self.charmlist_btn:getChildByName("label");
    self.friendslist_line = self.friendslist_btn:getChildByName("label");
    self.masterlist_line = self.masterlist_btn:getChildByName("label");

    self.charmlist_btn:setOnClick(self,self.onRankingCharmBtnClick);
    self.friendslist_btn:setOnClick(self,self.onRankingFriendsBtnClick);
    self.masterlist_btn:setOnClick(self,self.onRankingMasterBtnClick);
    self.m_leaf_left = self.m_root:getChildByName("leaf_left");
    
    --我的排行
    self.m_MyRankView = self:findViewById(self.m_ctrls.my_rank_view);
    self.m_myRankMask = self.m_MyRankView:getChildByName("icon_frame"):getChildByName("icon_mask");
    self.m_vip_frame = self.m_MyRankView:getChildByName("icon_frame"):getChildByName("vip_frame"); 
    self.my_level = self.m_MyRankView:getChildByName("icon_frame"):getChildByName("level");
    self.m_myRankName = self.m_MyRankView:getChildByName("name"); 
    self.m_vip_logo = self.m_MyRankView:getChildByName("vip_logo"); 
    self.m_myRankType = self.m_MyRankView:getChildByName("type"); 
    self.m_myRankNum  = self.m_MyRankView:getChildByName("num"); 
    self.m_MyRankMedal = self.m_MyRankView:getChildByName("rank_medal");
    self.m_outRank = self.m_MyRankMedal:getChildByName("out_rank");
    self.rankImg = {};
    -- 1代表百位 2代表十位 3代表个位
    for i = 1,3 do 
        self.rankImg[i] = self.m_MyRankMedal:getChildByName("Image" .. i);
    end
    self.m_myRankNum:setText(UserInfo.getInstance():getScore());
    self.m_myRankName:setText(UserInfo.getInstance():getName());
    local is_vip = UserInfo.getInstance():getIsVip();
    local vw,vh = self.m_vip_logo:getSize();
    if is_vip and is_vip == 1 then
        self.m_myRankName:setPos(227+vw,-18);
--        self.m_vip_frame:setVisible(true);
        self.m_vip_logo:setVisible(true);
    else
        self.m_myRankName:setPos(224,-18);
--        self.m_vip_frame:setVisible(false);
        self.m_vip_logo:setVisible(false);
    end
    local frameRes = UserSetInfo.getInstance():getFrameRes();
    self.m_vip_frame:setVisible(frameRes.visible);
    local fw,fh = self.m_vip_frame:getSize();
    if frameRes.frame_res then
        self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
    end

    self:updateHeadIcon();

    local str = "";
    if self.m_rankType == 1 then
        str = "搜索好友榜信息";
        self.friendslist_line:setVisible(true);
    elseif self.m_rankType == 2 then
        str = "搜索好魅力榜信息";
        self.charmList_line:setVisible(true);
    elseif self.m_rankType == 3 then
        str = "搜索大师榜榜信息";
        self.masterlist_line:setVisible(true);
    end
    self:loadingTile(str);
end

--更新我的排名
NewRankScene.updataMyRank = function(self,info,label)
    print_string("更新我的排名...");

    local temp_pos = "";
    local pos = info.rank;
    if label == 1 then
        self.m_myRankType:setText("积分:");
        self.m_myRankNum:setText("" .. UserInfo.getInstance():getScore());
    end
    if label == 2 then
        print_string("更新我的魅力排名...");
        self.m_myRankType:setText("粉丝:");
        self.m_myRankNum:setText("" .. info.fans_num);
    end
    if label == 0 then
        print_string("更新我的大师排名...");
        self.m_myRankType:setText("积分:");
        self.m_myRankNum:setText("" .. UserInfo.getInstance():getScore());
    end
    self.m_MyRankMedal:setFile("rank/rank_medal.png");

    if pos >= 1000 or pos == 0 then
        self.m_outRank:setVisible(true);
        for i,v in pairs(self.rankImg) do
            v:setVisible(false);
        end
        return;
    end

    local num = {};
    local tempNum = pos;
    num[3] = tempNum%10; -- 个位
    tempNum = (tempNum - num[3])/10;
    num[2] = tempNum%10;--十位
    tempNum = (tempNum - num[2])/10;
    num[1] = tempNum%10; --百位
    tempNum = (tempNum - num[1])/10;

--    num[1],tempNum = math.modf(pos/100); --百位
--    num[2],tempNum = math.modf(tempNum*10/1); --十位
--    num[3] = tempNum * 10; -- 个位
    self.m_outRank:setVisible(false);
    if num[1] ~= 0 then
        for i = 1,3 do 
            self.rankImg[i]:setFile(string.format("rank/number_%d.png",num[i]));
            self.rankImg[i]:setVisible(true);
            self.rankImg[i]:setPos(42,0);
        end
        self.rankImg[2]:setPos(18,0);
    elseif num[2] ~= 0 then
        for i = 2,3 do 
            self.rankImg[i]:setFile(string.format("rank/number_%d.png",num[i]));
            self.rankImg[i]:setVisible(true);
            self.rankImg[i]:setPos(30,0);
        end
        self.rankImg[1]:setVisible(false);
    elseif num[3] ~= 0 then
        self.rankImg[1]:setVisible(false);
        self.rankImg[2]:setVisible(false);
        if num[3] > 3 then
            self.rankImg[3]:setFile(string.format("rank/number_%d.png",num[3]));
            self.rankImg[3]:setVisible(true);
            self.rankImg[3]:setPos(18,0);
        elseif num[3] < 4 and num[3] > 0 then
            self.rankImg[3]:setVisible(false);
            self.m_MyRankMedal:setFile(string.format("rank/rank_medal%d.png",num[3]));
        end
    end

end

NewRankScene.updateHeadIcon = function(self)
    local user_icon_type = UserInfo.getInstance():getIconType();
    local user_icon_url = UserInfo.getInstance():getIcon();
    print_string("更新头像...");
    if user_icon_type > 0 then
        self.my_head_icon = new(Mask,UserInfo.DEFAULT_ICON[user_icon_type] or UserInfo.DEFAULT_ICON[1],"common/background/head_mask_bg_86.png"); 
    elseif user_icon_type == 0 then
        self.my_head_icon = new(Mask,NewRankScene.default_icon,"common/background/head_mask_bg_86.png");
    else
        self.my_head_icon = new(Mask,UserInfo.DEFAULT_ICON[1],"common/background/head_mask_bg_86.png");
        self.my_head_icon:setUrlImage(user_icon_url);
    end
    self.my_head_icon:setAlign(kAlignCenter);
    self.my_head_icon:setSize(self.m_myRankMask:getSize());
    self.m_myRankMask:addChild(self.my_head_icon);

--    self.my_level = new(Image,"common/icon/level_9.png");
--    self.my_level:setAlign(kAlignBottom);
--    self.my_level:setPos(0,-11);
--    self.my_head_icon:addChild(self.my_level);
    self.my_level:setFile("common/icon/level_".. 10 - UserInfo.getInstance():getDanGradingLevelByScore(UserInfo.getInstance():getScore())..".png");
end

--------用户头像更新接口
NewRankScene.changeUserIconCall = function(self,data)
    Log.i("changeUserIconCall");
      -- 自己
      self:changeMyRankIconCall(data);
      -- 好友
      self:changeListUserIconCall2(data,self.m_friends_adapter,self.changeFriendsData);
      -- 魅力
      self:changeListUserIconCall2(data,self.m_charm_adapter,self.changeCharmData);
      -- 大师
      self:changeListUserIconCall2(data,self.m_master_adapter,self.masterData);
end
--------自己排行榜头像更新
NewRankScene.changeMyRankIconCall = function(self,data)
    Log.i("my icon data" .. json.encode(data));
    if tonumber(data.what) ==  tonumber(UserInfo.getInstance():getUid()) then
        self.my_head_icon:setFile(data.ImageName or "userinfo/userHead.png");
    end
end

--------用户头像更新实现方法 2 
NewRankScene.changeListUserIconCall2 = function(self,data,m_adapte,datas)
   Log.i("changeListUserIconCall");
   if not datas then
       return;
   end
   if data and m_adapte then
--        local datas = m_adapte:getData();
        for i,v in pairs(datas) do
            if v.mid == tonumber(data.what) and m_adapte:isHasView(i) then
                local view = m_adapte:getTmpView(i);
                view:updateUserIcon(data.ImageName);
            end
        end
   end
end

--loading界面
NewRankScene.loadingTile = function(self,string)
    delete(self.RankloadingDialog);
    self.RankloadingDialog = new(HttpLoadingDialog);
    ChessDialogScene.setBgOnTouchClick(self.RankloadingDialog,nil);

    self.RankloadingDialog:setType(HttpLoadingDialog.s_type.Normel,string,false);
    self.RankloadingDialog:show(nil,false);

end

NewRankScene.loadingTileExit = function(self)
    if self.RankloadingDialog~= nil then
        self.RankloadingDialog:dismiss();
    end
end

-----------------排行榜--------------------------------
NewRankScene.onRankingFriendsBtnClick = function(self)  --切换好友榜
    Log.d("NewRankScene.onRankingFriendsBtnClick");

    if self.friendslist_check == false then
        self.friendslist_check = true;
        self.charmlistlist_check = false;
        self.masterlist_check = false;

        self.charmList_line:setVisible(false); 
        self.friendslist_line:setVisible(true); 
        self.masterlist_line:setVisible(false); 


        self:loadingTileExit();
        self:loadingTile("搜索好友榜信息");
        
        NewRankScene.itemPaiHangType = 1;
        self:requestCtrlCmd(NewRankController.s_cmds.change_friends);
    end

end


NewRankScene.onRankingCharmBtnClick = function(self)  --切换魅力榜
    Log.d("NewRankScene.onRankingCharmBtnClick");

    if self.charmlistlist_check == false then
        self.friendslist_check = false;
        self.charmlistlist_check = true;
        self.masterlist_check = false;

        self.charmList_line:setVisible(true); 
        self.friendslist_line:setVisible(false); 
        self.masterlist_line:setVisible(false); 

        self:loadingTileExit();
        self:loadingTile("搜索魅力榜信息");
        
        NewRankScene.itemPaiHangType = 2;
        self:requestCtrlCmd(NewRankController.s_cmds.change_charm);
    end
    
end

NewRankScene.onRankingMasterBtnClick = function(self)  --切换大师榜
    Log.d("NewRankScene.onRankingMasterBtnClick");

    if self.masterlist_check == false then
        self.friendslist_check = false;
        self.charmlistlist_check = false;
        self.masterlist_check = true;

        self.charmList_line:setVisible(false); 
        self.friendslist_line:setVisible(false); 
        self.masterlist_line:setVisible(true); 

        self:loadingTileExit();
        self:loadingTile("搜索大师榜信息");
       
        NewRankScene.itemPaiHangType = 3;
        self:requestCtrlCmd(NewRankController.s_cmds.change_master);
    end

end

---魅力榜
NewRankScene.changeCharmCall = function(self,datas)
    Log.d("ZY changeCharmCall");
    self:loadingTileExit();
    self.m_CharmlistView:releaseAllViews();
    delete(self.m_charm_adapter);
    self.m_charm_adapter = nil;
    if not datas or #datas < 2 then 
        self.changeCharmData = datas;
        ChessToastManager.getInstance():show("暂无魅力榜!",500);   
        self.m_MasterlistView:removeProp(1);
        self.m_FriendslistView:removeProp(1);
        self.m_FriendslistView:setVisible(false);
        self.m_MasterlistView:setVisible(false);
        return;  
    end
    for k,v in pairs(datas) do 
        v.rankType = 2;
    end
    self.changeCharmData = datas;
    self.m_charm_adapter = new(CacheAdapter,RankItem,datas);
    self.m_CharmlistView:setAdapter(self.m_charm_adapter);

    self.m_MasterlistView:removeProp(1);
    self.m_FriendslistView:removeProp(1);
    self.m_FriendslistView:setVisible(false);
    self.m_MasterlistView:setVisible(false);
    self.m_CharmlistView:addPropTransparency(1,kAnimNormal,300,150,0,1);
    self.m_CharmlistView:setVisible(true);

end

--大师榜
NewRankScene.changeMasterCall = function(self,datas)
    Log.d("ZY changeMasterCall");
    self:loadingTileExit();
    self.m_MasterlistView:releaseAllViews();
    delete(self.m_master_adapter);
    self.m_master_adapter = nil;
    if not datas or #datas < 1 then 
        self.masterData = datas;
        ChessToastManager.getInstance():show("暂无大师榜!",500);
        self.m_FriendslistView:removeProp(1);
        self.m_CharmlistView:removeProp(1);
        self.m_CharmlistView:setVisible(false);
        self.m_FriendslistView:setVisible(false);
        return;
    end
    
    for k,v in pairs(datas) do
        v.rankType = 3;
    end
    self.masterData = datas;
    self.m_master_adapter = new(CacheAdapter,RankItem,datas);
    self.m_MasterlistView:setAdapter(self.m_master_adapter);

    self.m_FriendslistView:removeProp(1);
    self.m_CharmlistView:removeProp(1);
    self.m_CharmlistView:setVisible(false);
    self.m_FriendslistView:setVisible(false);
    self.m_MasterlistView:addPropTransparency(1,kAnimNormal,300,150,0,1);
    self.m_MasterlistView:setVisible(true);
end

--好友榜
NewRankScene.changeFriendsCall = function(self,datas)
    Log.d("ZY changeFriendsCall");
    self:loadingTileExit();
    self.m_FriendslistView:releaseAllViews();
    delete(self.m_friends_adapter);
    self.m_friends_adapter = nil;
    if not datas or #datas < 1 then
        self.changeFriendsData = datas; 
        ChessToastManager.getInstance():show("暂无好友榜!",500);
        self.m_MasterlistView:removeProp(1);
        self.m_CharmlistView:removeProp(1);
        self.m_CharmlistView:setVisible(false);
        self.m_MasterlistView:setVisible(false);
        return;
    end

    local ranks  = {};
    local ranktd  = {};
	for i,value in pairs(datas) do 
        local user = {};
		user.mid     = value.uid;
		user.score    = value.score;
        user.rank     = i;
        user.rankType = 1;
        table.insert(ranks,user);
        table.insert(ranktd,user);
	end

    NewRankScene.paiHangRank = {};
    NewRankScene.paiHangRank = ranktd;
    self.changeFriendsData = datas; 
    self.m_friends_adapter = new(CacheAdapter,RankItem,ranks);
    self.m_FriendslistView:setAdapter(self.m_friends_adapter);

    self.m_MasterlistView:removeProp(1);
    self.m_CharmlistView:removeProp(1);
    self.m_CharmlistView:setVisible(false);
    self.m_MasterlistView:setVisible(false);
    self.m_FriendslistView:addPropTransparency(1,kAnimNormal,300,150,0,1);
    self.m_FriendslistView:setVisible(true);

end

NewRankScene.getTime = function(time)
    if ToolKit.isSecondDay(time) then
        return os.date("%m-%d %H:%M",time);-- 08-07格式
    else
        return os.date("%H:%M",time);--%Y/%m/%d %X
    end;
end

NewRankScene.onGetScreenings = function(level)
    local room_list = UserInfo.getInstance():getRoomConfig();

    for i,list in pairs(room_list) do
       if level == list.level then
           return list.name;
       end
    end

    return nil;
end

NewRankScene.changeStatusCall = function(self,status)
    self:changePaiHangStatusCall(status,self.m_charm_adapter); --魅力
    self:changePaiHangStatusCall(status,self.m_master_adapter); --大师
    self:changePaiHangStatusCall(status,self.m_friends_adapter); --好友
    
end

NewRankScene.changePaiHangStatusCall = function(self,status,m_adapte)

    if status and m_adapte then
        local datas = m_adapte:getData();
        for i,uid in pairs(datas) do
            for _,sdata in pairs(status) do
                if uid == sdata.uid and m_adapte:isHasView(i) then
                    local view = m_adapte:getTmpView(i);
                    self:changePaiHangView(view);
                end
            end
        end
    end

end

NewRankScene.changePaiHangView = function(self,view)
    view:changeStatus();
end

NewRankScene.s_controlConfig = 
{
    [NewRankScene.s_controls.rank_view]            = {"rank_view"};
    [NewRankScene.s_controls.back_btn]             = {"back_btn"};
    [NewRankScene.s_controls.teapot_dec]           = {"teapot_dec"};
    [NewRankScene.s_controls.book_mark]            = {"bookMark"}; 
    [NewRankScene.s_controls.friends_rank_btn]     = {"rank_view","friends_rank_btn"};
    [NewRankScene.s_controls.charm_rank_btn]       = {"rank_view","charm_rank_btn"};
    [NewRankScene.s_controls.master_rank_btn]      = {"rank_view","master_rank_btn"};
    [NewRankScene.s_controls.my_rank_view]         = {"rank_view","my_rank_bg"};

    [NewRankScene.s_controls.charm_rank_view]       = {"rank_view","charm_rank_view"};
    [NewRankScene.s_controls.master_rank_view]      = {"rank_view","master_rank_view"};
    [NewRankScene.s_controls.friend_rank_view]      = {"rank_view","friend_rank_view"};
}

NewRankScene.s_controlFuncMap = 
{
    [NewRankScene.s_controls.back_btn]             = NewRankScene.onBack;
    
}

NewRankScene.s_cmdConfig =
{
 
    [NewRankScene.s_cmds.change_charm] = NewRankScene.changeCharmCall;  
    [NewRankScene.s_cmds.change_master] = NewRankScene.changeMasterCall;   
    [NewRankScene.s_cmds.change_friends] = NewRankScene.changeFriendsCall;  
    [NewRankScene.s_cmds.change_userIcon] = NewRankScene.changeUserIconCall;
    [NewRankScene.s_cmds.changeFriendstatus] = NewRankScene.changeStatusCall;
    
    [NewRankScene.s_cmds.my_friend_rank] = NewRankScene.updataMyRank;
    [NewRankScene.s_cmds.my_charm_rank] = NewRankScene.updataMyRank;
    [NewRankScene.s_cmds.my_master_rank] = NewRankScene.updataMyRank;

}

------------------------------------魅力榜
RankItem = class(Node)
--RankItem.s_w = 590;
--RankItem.s_h = 164;

RankItem.ctor = function(self,data) -- type排行类型
    if next(data) == nil then   
        return;
    end

    if data.rankType == 1 then
        -- 好友榜需要用到
        self.datas = FriendsData.getInstance():getUserData(data.mid);
        self.uid = data.mid;
        self.score = data.score;
        self.friendRank = data.rank;
    else
        self.datas = data;
    end
    self.rankType = data.rankType;
     
    require(VIEW_PATH .. "rank_view_node");
    self.status = FriendsData.getInstance():getUserStatus(data.mid);

    self.m_root_view = SceneLoader.load(rank_view_node);
    self.m_root_view:setAlign(kAlignCenter);
    self.m_node_view = self.m_root_view:getChildByName("node");
    self:addChild(self.m_root_view);
    self:setSize(self.m_root_view:getSize());
    self.m_bg_btn = self.m_node_view:getChildByName("bg_btn");
    self.m_bg_btn:setOnClick(self,self.onBtnClick);
    self.m_bg_btn:setSrollOnClick();
    self.m_bg = self.m_node_view:getChildByName("bg");
    --头像
    local iconFile = UserInfo.DEFAULT_ICON[1];
    self.m_head_mask = self.m_node_view:getChildByName("icon_bg"):getChildByName("icon_mask");
    self.m_vip_frame = self.m_node_view:getChildByName("icon_bg"):getChildByName("vip_frame");
    self.m_icon = new(Mask,iconFile,"common/background/head_mask_bg_86.png");
    self.m_icon:setAlign(kAlignCenter);
    self.m_icon:setSize(self.m_head_mask:getSize());
    self.m_head_mask:addChild(self.m_icon);
    --段位
    self.m_level = self.m_node_view:getChildByName("icon_bg"):getChildByName("level");
    --名字
    self.m_title = self.m_node_view:getChildByName("name");
    self.m_vip_logo = self.m_node_view:getChildByName("vip_logo");
     --积分
    self.m_rankType = self.m_node_view:getChildByName("type");
    self.m_num = self.m_node_view:getChildByName("num");
    --最近状态
    self.m_online = self.m_node_view:getChildByName("online");
    self.m_lastStatus = new(TextView,"",136,130,kAlignCenter,nil,24,120,120,120);
    self.m_lastStatus:setAlign(kAlignRight);
    self.m_lastStatus:setPos(20,0);
    self.m_node_view:addChild(self.m_lastStatus);

    self.rank_bg = self.m_node_view:getChildByName("rank_bg");
    self.out_rank = self.m_node_view:getChildByName("rank_bg"):getChildByName("Image1");

    if self.datas ~= nil then
        --修改自己的入榜背景
        if self.datas and self.datas.mid == UserInfo.getInstance():getUid() then
            self.m_bg:setFile("rank/bg.png");
        else
            self.m_bg:setFile("drawable/blank.png");
        end

        --头像
        --NewRankScene.idToIcon[0];
        if self.datas then
            if self.datas.iconType == -1 then
                self.m_icon:setUrlImage(self.datas.icon_url);
            else
                self.m_icon:setFile(UserInfo.DEFAULT_ICON[self.datas.iconType] or iconFile);
            end
        end

        if self.rankType == 1 and self.datas.mid == UserInfo.getInstance():getUid() then
            self.isMe = true;
            if UserInfo.getInstance():getIconType() == -1 then
                self.m_icon:setUrlImage(UserInfo.getInstance():getIcon());
            else
                self.m_icon:setFile(UserInfo.DEFAULT_ICON[UserInfo.getInstance():getIconType()] or iconFile);
            end
        end

        --段位 
        if self.datas.score then
            self.m_level:setFile("common/icon/level_"..10 - UserInfo.getInstance():getDanGradingLevelByScore(tonumber(self.datas.score))..".png"); 
        end

        --名字
        if self.rankType < 3 then
            if self.isMe then
                local name = UserInfo.getInstance():getName();
                if name then
                    local lenth = string.lenutf8(GameString.convert2UTF8(name));
                    if lenth > 10 then    
                        local str  = string.subutf8(name,1,7).."...";
                        self.m_title:setText(str);
                    else
                        self.m_title:setText(name);
                    end
                else
                    self.m_tittle:setText("未知");
                end
            else
                if self.datas.mnick and #self.datas.mnick > 1 then
                    local lenth = string.lenutf8(GameString.convert2UTF8(self.datas.mnick));
                    if lenth > 10 then    
                        local str  = string.subutf8(self.datas.mnick,1,7).."...";
                        self.m_title:setText(str);
                    else
                        self.m_title:setText(self.datas.mnick);
                    end
                else
                    self.m_title:setText("未知");
                end
            end
        elseif self.rankType == 3 then
            if self.datas.name and #self.datas.name > 1 then
                local lenth = string.lenutf8(GameString.convert2UTF8(self.datas.name));
                if lenth > 10 then    
                    local str  = string.subutf8(self.datas.name,1,7).."...";
                    self.m_title:setText(str);
                else
                    self.m_title:setText(self.datas.name);
                end
            else
                self.m_title:setText("未知");
            end
        end

        --rankType 1：好友榜   2：魅力榜  3：大师榜
        if self.rankType == 1 then
            self.m_rankType:setText("积分:");
            local fs = self.score.."";
            self.m_num:setText(fs);
        elseif self.rankType == 2 then
            self.m_rankType:setText("粉丝:");
            if self.datas.score ~= nil then
                local fs = self.datas.fans_num.."";
                self.m_num:setText(fs);
            else
                self.m_num:setText(0 .. "");
            end
        elseif self.rankType == 3 then
            self.m_rankType:setText("积分:");
            if self.datas.score ~= nil then
                local fs = self.datas.score.."";
                self.m_num:setText(fs);
            else
                self.m_num:setText(0 .. "");
            end
        end

        --最近登录状态
        if self.status~= nil then
            if self.status.hallid <=0 then
                self.last_login_time = NewRankScene.getTime(self.datas.mactivetime);
                local str = "最近登录\n"..self.last_login_time;
                self.m_lastStatus:setText(str);
                self.m_online:setVisible(false);
            else
                if self.status.tid >0 then -- 用户在下棋 
                    local strname = NewRankScene.onGetScreenings(self.status.level);
                    if strname == nil then
                        self.m_lastStatus:setVisible(false);
                        self.m_online:setVisible(true);
                    else
                        self.m_lastStatus:setVisible(true);
                        self.m_online:setVisible(false);
                        self.m_lastStatus:setText(strname);
                    end
                    self.m_lastStatus:setVisible(false);
                    self.m_online:setVisible(true);     
               else
                    self.m_lastStatus:setVisible(false);
                    self.m_online:setVisible(true);     
               end
            end
        else
            self.m_lastStatus:setVisible(false);
            self.m_online:setVisible(false);     
        end

        ---名次图标
        if self.datas.rank then
            local rank = self.datas.rank;
            if self.rankType == 1 then
                rank = self.friendRank;
            end
            self.out_rank:setVisible(false);
            local tempNum = 0;
            local num2 = rank%10; --個位
            tempNum = (rank - num2)/10; --十位
            local num1 = tempNum%10;
--            local num1,num2 = math.modf(rank/10);
--            num2 = num2 * 10;
            if num1 == 0 then
                if num2 > 0 and num2 < 4 then
                    self.rank_bg:setFile("rank/rank_medal" .. num2 ..".png"); 
                elseif num2 > 3 then
                    self.rank_bg:setFile("rank/rank_medal.png");
                    local rank_pos = new(Image,"rank/number_" .. num2 ..".png");
                    rank_pos:setAlign(kAlignCenter);
		            self.rank_bg:addChild(rank_pos);
                end
            elseif num1 > 0 then
                self.rank_bg:setFile("rank/rank_medal.png");
                local rank_pos1 = new(Image,"rank/number_" .. num1 ..".png");--string.format("rank/number_%d.png",num1));
                local rank_pos2 = new(Image,"rank/number_" .. num2 ..".png");--string.format("rank/number_%d.png",num2));
                rank_pos1:setPos(-12,0);
                rank_pos2:setPos(7,0);
                rank_pos1:setAlign(kAlignCenter);
                rank_pos2:setAlign(kAlignCenter);
		        self.rank_bg:addChild(rank_pos1);
                self.rank_bg:addChild(rank_pos2);
            end
        else
            self.out_rank:setVisible(true);
        end

        if self.datas.mid and self.datas.mid == UserInfo.getInstance():getUid() then
            local frameRes = UserSetInfo.getInstance():getFrameRes();
            self.m_vip_frame:setVisible(frameRes.visible);
            local fw,fh = self.m_vip_frame:getSize();
            if frameRes.frame_res then
                self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
            end
        else
            if self.datas.is_vip and  self.datas.is_vip == 1 then
                local vx,vy = self.m_vip_logo:getPos();
                local vw,vh = self.m_vip_logo:getSize();
                self.m_title:setPos(vx + vw + 3,-24);
                self.m_vip_logo:setVisible(true);
                self.m_vip_frame:setVisible(true);
            else
                self.m_title:setPos(226,-24);
                self.m_vip_logo:setVisible(false);
                self.m_vip_frame:setVisible(false);
            end
        end

        

        
    else
        self.m_title:setText("未知");
        if self.rankType == 1 then
            self.m_rankType:setText("积分:");
        elseif self.rankType == 2 then
            self.m_rankType:setText("粉丝:");
        elseif self.rankType == 3 then
            self.m_rankType:setText("积分:");
        end
        self.m_title:setPos(226,-24);
        self.m_vip_logo:setVisible(false);
        self.m_vip_frame:setVisible(false);
        self.m_level:setFile("common/icon/level_9.png");
        self.m_online:setVisible(false);  
    end

end

RankItem.setOnBtnClick = function(self,obj,func)
    self.m_btn_obj = obj;
    self.m_btn_func = func;
end

RankItem.onBtnClick = function(self)
    Log.i("RankItem.onBtnClick");
    if self.datas and self.datas.mid then
        if tonumber(self.datas.mid) == UserInfo.getInstance():getUid() then
            StateMachine.getInstance():pushState(States.gradeModel,StateMachine.STYPE_CUSTOM_WAIT);
        else
            StateMachine.getInstance():pushState(States.FriendsInfo,StateMachine.STYPE_CUSTOM_WAIT,nil,tonumber(self.datas.mid));
        end
    end
end

RankItem.updateUserIcon = function(self,imageName)
    Log.i("FriendsItem.updateUserIcon: "..(imageName or "null"));
--    if imageName then
--        if self.rankType == 1 then
--            if self.uid == UserInfo.getInstance():getUid() then
--                self.m_icon:setFile(UserInfo.getInstance():getIconFile());
--            else
--                self.m_icon:setFile(imageName);
--            end
--            return;
--        end
--        self.m_icon:setFile(imageName);
--    end
end


RankItem.changeStatus = function(self)
    
    self.status = FriendsData.getInstance():getUserStatus(self.datas.mid);

    if self.status~= nil then
        if self.status.hallid <=0 then
            self.last_login_time = NewRankScene.getTime(self.datas.mactivetime);
            local str = "最近登录"..self.last_login_time;
            self.m_lastStatus:setText(str);
            self.m_online:setVisible(false);
        else
            if self.status.tid >0 then -- 用户在下棋 
                local strname = NewRankScene.onGetScreenings(self.status.level);
                if strname == nil then
                    self.m_lastStatus:setVisible(false);
                    self.m_online:setVisible(true);
                else
                    self.m_lastStatus:setVisible(true);
                    self.m_online:setVisible(false);
                    self.m_lastStatus:setText(strname);
                end
                self.m_lastStatus:setVisible(false);
                self.m_online:setVisible(true);     
           else
                self.m_lastStatus:setVisible(false);
                self.m_online:setVisible(true);     
           end
        end
    else
        self.m_lastStatus:setVisible(false);
        self.m_online:setVisible(true);     
    end
end

-------------------------------------------大师榜
--RankMasterItem = class(Node)
--RankMasterItem.s_w = 590;
--RankMasterItem.s_h = 164;

--RankMasterItem.ctor = function(self,data)

--    if next(data) == nil then   
--        return;
--    end

--    self.datas = data;
--    self.status = FriendsData.getInstance():getUserStatus(self.datas.mid);
--    self:setSize(RankMasterItem.s_w,RankMasterItem.s_h);

--    --修改自己的排行背景
--    if self.datas.mid == UserInfo.getInstance():getUid() then
--        self.m_bg = new(Button,"rank/bg.png");
--    else
--        self.m_bg = new(Button,"drawable/blank.png");
--    end
--    self.m_bg:setSize(590,163);
--    self.m_bg:setAlign(kAlignCenter);
--    self.m_bg:setOnClick(self,self.onBtnClick);
--    self.m_bg:setSrollOnClick();
--    self:addChild(self.m_bg);

--    self.m_icon_line = new(Image,"common/decoration/line_3.png");
--    self.m_icon_line:setAlign(kAlignLeft);
--    self.m_icon_line:setSize(2,80);
--    self.m_icon_line:setPos(107,0);
--    self.m_bg:addChild(self.m_icon_line);

--    --头像
--    local iconFile = NewRankScene.idToIcon[0];
--    if self.datas then
--        if self.datas.iconType == -1 then
--            local imageName = UserInfo.getCacheImageManager(self.datas.icon,self.datas.mid);
--            if imageName then
--                iconFile = imageName;
--            end
--        else
--            iconFile = NewRankScene.idToIcon[self.datas.iconType] or iconFile;
--        end
--    end
--    self.m_icon_bg = new(Image,"common/background/head_bg_92.png");
--    self.m_icon_bg:setAlign(kAlignLeft);
--    self.m_icon_bg:setPos(127,-8);
--    self.m_bg:addChild(self.m_icon_bg);

--    self.m_head_mask = new(Image,"common/background/head_mask_bg_86.png");
--    self.m_head_mask:setAlign(kAlignCenter);
--    self.m_icon_bg:addChild(self.m_head_mask);

--    self.m_icon = new(Mask,iconFile,"common/background/head_mask_bg_86.png");
--    self.m_icon:setAlign(kAlignCenter);
--    self.m_icon:setSize(self.m_head_mask:getSize());
--    self.m_icon_bg:addChild(self.m_icon);
--    --段位
--    self.m_level = new(Image,"common/icon/level_1.png");
--    self.m_level:setAlign(kAlignBottom);
--    self.m_level:setPos(0,-11);
--    self.m_icon:addChild(self.m_level);

--    if self.datas.score ~= nil then
--        self.m_level:setFile("common/icon/level_"..10 - UserInfo.getInstance():getDanGradingLevelByScore(tonumber(self.datas.score))..".png"); 
--    else
--        self.m_level:setFile("common/icon/level_1.png");
--    end

--    local sx = 160 + self.m_icon:getSize(); 
--    local sy = 0 ;

--    --名字
--    if self.datas.name and #self.datas.name > 1 then
--        local lenth = string.lenutf8(GameString.convert2UTF8(self.datas.name) or "");
--        if lenth > 10 then    
--            local str  = string.subutf8(self.datas.name,1,7).."...";
--            self.m_title = new(Text,str,nil, nil, nil, nil, 36, 80, 80, 80);
--        else
--            self.m_title = new(Text,self.datas.name,nil, nil, nil, nil,36, 80, 80, 80);   
--        end
--    else
--        self.m_title = new(Text,"未知",nil, nil, nil, nil,36, 80, 80, 80);
--    end

--    self.m_title:setAlign(kAlignLeft);
--    self.m_title:setPos(sx + 5,sy - 25);
--    self.m_bg:addChild(self.m_title);

--    self.m_rankType = new(Text,"积分:", nil, nil, nil, nil, 34,125, 80, 65);
--    self.m_rankType:setAlign(kAlignLeft);
--    self.m_rankType:setPos(sx + 5,sy + 20);
--    self.m_bg:addChild(self.m_rankType);

--    --积分
--    if self.datas.score ~= nil then
--        local fs = self.datas.score.."";
--        self.m_fs = new(Text,fs,nil, nil, nil, nil, 32,80,80,80);
--    else
--        self.m_fs = new(Text,0,nil, nil, nil, nil, 32,80,80,80);
--    end
--    self.m_fs:setAlign(kAlignLeft);
--    self.m_fs:setPos(sx + 90,sy + 22);
--    self.m_bg:addChild(self.m_fs);


--    --最近登录
--    if self.status~= nil then
--        if self.status.hallid <=0 then --离线
--           self.last_login_time = NewRankScene.getTime(self.datas.mactivetime);
--           self.m_lasttimeTitleNum = new(Text,self.last_login_time,nil, nil, nil, nil, 24, 120, 120, 120); 
--           self.m_lasttimeTitle = new(Text,"最近登陆",nil, nil, nil, nil, 24, 120, 120, 120);
--           self.m_lasttimeTitle:setPos(18,-15);
--           self.m_lasttimeTitleNum:setPos(32,12);
--        else
--           if self.status.tid >0 then -- 用户在下棋 
--                local strname = NewRankScene.onGetScreenings(self.status.level);
--                self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 24, 120, 120, 120); 
--                self.m_lasttimeTitleNum:setVisible(false);
--                self.m_lasttimeTitle = new(Text,"在线",nil, nil, nil, nil, 24, 120, 120, 120);
--                if strname == nil then
--                       self.m_lasttimeTitle.setText(self.m_lasttimeTitle,"在线",nil, nil,70,145,105);
--                       self.m_lasttimeTitle:setPos(18,0);
--                else
--                       self.m_lasttimeTitle.setText(self.m_lasttimeTitle,strname,nil, nil,70,145,105);
--                       self.m_lasttimeTitle:setPos(18,0);
--                end                    
--           else
--                self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 24, 120, 120, 120); 
--                self.m_lasttimeTitle = new(Text,"在线",nil, nil, nil, nil, 24, 120, 120, 120);
--                self.m_lasttimeTitle:setPos(18,0);
--                self.m_lasttimeTitleNum:setVisible(false);
--           end           
--        end
--    else
--        self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105); 
--        self.m_lasttimeTitle = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105);
--        self.m_lasttimeTitle:setPos(110,0);
--        self.m_lasttimeTitleNum:setPos(185,0);
--    end


--    ---名次图标
--    if self.datas.rank ~= nil then
--        local img_rank =  nil;
--	    if self.datas.rank  < 4 and self.datas.rank > 0 then 
--		    img_rank = new(Image,string.format("rank/rank_medal%d.png",self.datas.rank));
--	     elseif self.datas.rank > 3 and self.datas.rank < 10 then
--		    img_rank = new(Image,"rank/rank_medal.png");
--            local rank_pos = new(Image,string.format("rank/number_%d.png",self.datas.rank));
--            rank_pos:setAlign(kAlignCenter);
--		    img_rank:addChild(rank_pos);
--        elseif self.datas.rank > 9 and self.datas.rank < 20 then
--            img_rank = new(Image,"rank/rank_medal.png");
--            local rank_pos_forward = new(Image,"rank/number_1.png");  --两位排行前面的一张图片
--            local pos = self.datas.rank - 10;
--            local rank_pos_back = new(Image,string.format("rank/number_%d.png",pos)); --两位排行后面的一张图片
--            rank_pos_forward:setPos(-3,0);
--            rank_pos_back:setPos(3,0);
--            rank_pos_forward:setAlign(kAlignCenter);
--            rank_pos_back:setAlign(kAlignCenter);
--		    img_rank:addChild(rank_pos_forward);
--            img_rank:addChild(rank_pos_back);
--        else
--            img_rank = new(Image,"rank/rank_medal.png");
--            local rank_pos_forward = new(Image,"rank/number_2.png");  --两位排行前面的一张图片
--            local rank_pos_back = new(Image,"rank/number_2.png"); --两位排行后面的一张图片
--            rank_pos_forward:setPos(-3,0);
--            rank_pos_back:setPos(3,0);
--            rank_pos_forward:setAlign(kAlignCenter);
--            rank_pos_back:setAlign(kAlignCenter);
--		    img_rank:addChild(rank_pos_forward);
--            img_rank:addChild(rank_pos_back);
--	    end
--        img_rank:setAlign(kAlignLeft);
--        img_rank:setPos(20,-6);
--        self.m_bg:addChild(img_rank);
--    else
--        local img_rank = new(Image,"rank/medal_bg.png");
--        local text_rank =  new(Text,1,nil, nil, nil, nil, 24, 70, 145, 105);
--        text_rank:setAlign(kAlignCenter);
--        img_rank:addChild(text_rank);
--        img_rank:setAlign(kAlignLeft);
--        img_rank:setPos(20,-6);
--        self.m_bg:addChild(img_rank);
--    end

--    self.m_bottomLine = new(Image,"common/decoration/line_2.png");
--    self.m_bottomLine:setAlign(kAlignBottom);
--    self.m_bottomLine:setSize(560,2);
--    self.m_bg:addChild(self.m_bottomLine);

--    self.m_lasttimeTitle:setAlign(kAlignRight);
--    self.m_lasttimeTitleNum:setAlign(kAlignRight);
--    self.m_bg:addChild(self.m_lasttimeTitle);
--    self.m_bg:addChild(self.m_lasttimeTitleNum);

--end

--RankMasterItem.setOnBtnClick = function(self,obj,func)
--    self.m_btn_obj = obj;
--    self.m_btn_func = func;
--end

--RankMasterItem.onBtnClick = function(self)
--    Log.i("RankMasterItem.onBtnClick");
--    StateMachine.getInstance():pushState(States.FriendsInfo,StateMachine.STYPE_WAIT,nil,tonumber(self.datas.mid));
--end

--RankMasterItem.updateUserIcon = function(self,imageName)
--    Log.i("FriendsItem.updateUserIcon: "..(imageName or "null"));
--    if imageName then
--        self.m_icon:setFile(imageName);
--    end
--end

--RankMasterItem.changeStatus = function(self)

--    self.status = FriendsData.getInstance():getUserStatus(self.datas.mid);
--    --最近登录
--    if self.status~= nil then
--        if self.status.hallid <=0 then --离线
--           if self.last_login_time and self.last_login_time ~= "" then
--               self.m_lasttimeTitleNum = new(Text,self.last_login_time,nil, nil, nil, nil, 24, 120, 120, 120); 
--               self.m_lasttimeTitle = new(Text,"最近登陆",nil, nil, nil, nil, 24, 120, 120, 120);
--           else
--               self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 24, 120, 120, 120); 
--               self.m_lasttimeTitle = new(Text,"",nil, nil, nil, nil, 24, 120, 120, 120);
--           end
--        else
--           if self.status.tid >0 then -- 用户在下棋 
--                local strname = NewRankScene.onGetScreenings(self.status.level);
--                self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 24, 120, 120, 120); 
--                self.m_lasttimeTitleNum:setVisible(false);
--                self.m_lasttimeTitle = new(Text,"在线",nil, nil, nil, nil, 24, 120, 120, 120);
--                if strname == nil then
--                       self.m_lasttimeTitle.setText(self.m_lasttimeTitle,"",nil, nil,70,145,105);
--                else
--                       self.m_lasttimeTitle.setText(self.m_lasttimeTitle,strname,nil, nil,70,145,105);
--                end            
--           else
--                self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 24, 120, 120, 120); 
--                self.m_lasttimeTitleNum:setVisible(false);
--                self.m_lasttimeTitle = new(Text,"在线",nil, nil, nil, nil, 24, 120, 120, 120);
--           end
--        end
--    else
--        self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105); 
--        self.m_lasttimeTitle = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105);
--    end

--end

----------------------------------------好友榜
--RankFriendsItem = class(Node)
--RankFriendsItem.s_w = 580;
--RankFriendsItem.s_h = 164;

--RankFriendsItem.ctor = function(self,data)

--    if next(data) == nil then   
--        return;
--    end

--    self.uid = data.mid;
--    self.score = data.score;
--    self.datas = FriendsData.getInstance():getUserData(data.mid);
--    self.status = FriendsData.getInstance():getUserStatus(data.mid);

--    self:setSize(RankFriendsItem.s_w,RankFriendsItem.s_h);
--    --修改自己的排行背景
--    if self.uid == UserInfo.getInstance():getUid() then
--        self.m_bg = new(Button,"rank/bg.png");
--    else
--        self.m_bg = new(Button,"drawable/blank.png");
--    end
--    self.m_bg:setSize(590,163);
--    self.m_bg:setAlign(kAlignCenter);
--    self.m_bg:setOnClick(self,self.onBtnClick);
--    self.m_bg:setSrollOnClick();
--    self:addChild(self.m_bg);

--    self.m_icon_line = new(Image,"common/decoration/line_3.png");
--    self.m_icon_line:setAlign(kAlignLeft);
--    self.m_icon_line:setSize(2,80);
--    self.m_icon_line:setPos(107,0);
--    self.m_bg:addChild(self.m_icon_line);

--    self.m_icon_bg = new(Image,"common/background/head_bg_92.png");
--    self.m_icon_bg:setAlign(kAlignLeft);
--    self.m_icon_bg:setPos(127,-8);
--    self.m_bg:addChild(self.m_icon_bg);

--    self.m_icon_mask = new(Image,"common/background/head_mask_bg_86.png");
--    self.m_icon_mask:setAlign(kAlignCenter);
--    self.m_icon_bg:addChild(self.m_icon_mask);

--    --头像
--    self.m_icon = new(Mask,"userinfo/userHead.png","common/background/head_mask_bg_86.png");
--    self.m_icon:setAlign(kAlignCenter);
--    self.m_icon:setSize(self.m_icon_mask:getSize());
--    self.m_icon_mask:addChild(self.m_icon);

--    --段位
--    self.m_level = new(Image,"common/icon/level_1.png");
--    self.m_level:setAlign(kAlignBottom);
--    self.m_level:setSize(0,-11);
--    self.m_icon:addChild(self.m_level);

--    local sx = 160 + self.m_icon:getSize(); 
--    local sy = 0 ;

--    if self.datas~= nil then
--        --头像
--        local iconFile = NewRankScene.idToIcon[0];
--        if self.datas then
--            if self.datas.iconType == -1 then
--                local imageName = UserInfo.getCacheImageManager(self.datas.icon_url,self.datas.mid);
--                if imageName then
--                    iconFile = imageName;
--                end
--            else
--                iconFile = NewRankScene.idToIcon[self.datas.iconType] or iconFile;
--            end
--        end

--        if self.uid == UserInfo.getInstance():getUid() then
--            self.m_icon:setFile(UserInfo.getInstance():getIconFile());
--        else
--            self.m_icon:setFile(iconFile);
--        end

--        if self.datas.score ~= nil then
--            self.m_level:setFile("common/icon/level_"..UserInfo.getInstance():getDanGradingLevelByScore(tonumber(self.datas.score))..".png"); 
--        else
--            self.m_level:setFile("common/icon/level_1.png");
--        end

--        --名字
--        if self.datas.mnick and #self.datas.mnick > 1 then
--            local lenth = string.lenutf8(GameString.convert2UTF8(self.datas.mnick));
--            if lenth > 10 then    
--                local str  = string.subutf8(self.datas.mnick,1,7).."...";
--                self.m_title = new(Text,str,nil, nil, nil, nil,36, 80, 80, 80);
--            else
--                self.m_title = new(Text,self.datas.mnick,nil, nil, nil, nil,36, 80, 80, 80);   
--            end
--        else
--            self.m_title = new(Text,"未知",nil, nil, nil, nil,36, 80, 80, 80);
--        end

--        self.m_title:setAlign(kAlignLeft);
--        self.m_title:setPos(sx + 5,sy - 25);
--        self.m_bg:addChild(self.m_title);

--        self.m_rankType = new(Text,"积分:", nil, nil, nil, nil, 34,125, 80, 65);
--        self.m_rankType:setAlign(kAlignLeft);
--        self.m_rankType:setPos(sx + 5,sy + 20);
--        self.m_bg:addChild(self.m_rankType);

--        --积分
--        local fs = self.score.."";
--        self.m_fs = new(Text,fs,nil, nil, nil, nil, 32,80,80,80);
--        self.m_fs:setAlign(kAlignLeft);
--        self.m_fs:setPos(sx + 90,sy + 22);
--        self.m_bg:addChild(self.m_fs);

--        --最近登录
--        if self.status~= nil then
--            if self.status.hallid <=0 then --离线
--               self.last_login_time = NewRankScene.getTime(self.datas.mactivetime);
--                self.m_lasttimeTitleNum = new(Text,self.last_login_time,nil, nil, nil, nil, 24, 120, 120, 120); 
--                self.m_lasttimeTitle = new(Text,"最近登陆",nil, nil, nil, nil, 24, 120, 120, 120);
--                self.m_lasttimeTitle:setPos(18,-15);
--                self.m_lasttimeTitleNum:setPos(32,12);
--            else
--               if self.status.tid >0 then -- 用户在下棋 
--                    local strname = NewRankScene.onGetScreenings(self.status.level);
--                    self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 24, 120, 120, 120); 
--                    self.m_lasttimeTitleNum:setVisible(false);
--                    self.m_lasttimeTitle = new(Text,"在线",nil, nil, nil, nil, 24, 120, 120, 120);
--                    if strname == nil then
--                           self.m_lasttimeTitle.setText(self.m_lasttimeTitle,"",nil, nil,70,145,105);
--                           self.m_lasttimeTitle:setPos(18,0);
--                    else
--                           self.m_lasttimeTitle.setText(self.m_lasttimeTitle,strname,nil, nil,70,145,105);
--                            self.m_lasttimeTitle:setPos(18,0);
--                    end            
--               else
--                    self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 24, 120, 120, 120); 
--                    self.m_lasttimeTitleNum:setVisible(false);
--                    self.m_lasttimeTitle = new(Text,"在线",nil, nil, nil, nil, 24, 120, 120, 120);
--                    self.m_lasttimeTitle:setPos(18,0);
--               end
--            end
--        else
--            self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105); 
--            self.m_lasttimeTitle = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105);
--            self.m_lasttimeTitle:setPos(110,0);
--            self.m_lasttimeTitleNum:setPos(185,0);
--        end

--        ---名次图标
--        if NewRankScene.paiHangRank ~= nil then
--            for _,sdata in pairs(NewRankScene.paiHangRank) do
--               if self.uid == sdata.mid then
--                    local img_rank = nil;
--                    if sdata.rank  < 4 and sdata.rank > 0 then 
--		                img_rank = new(Image,string.format("rank/rank_medal%d.png",sdata.rank));
--	                elseif sdata.rank > 3 and sdata.rank < 10 then
--		                img_rank = new(Image,"rank/rank_medal.png");
--                        local rank_pos = new(Image,string.format("rank/number_%d.png",sdata.rank));
--                        rank_pos:setAlign(kAlignCenter);
--		               img_rank:addChild(rank_pos);
--                    elseif sdata.rank > 9 and sdata.rank < 20 then
--                        img_rank = new(Image,"rank/rank_medal.png");
--                        local rank_pos_forward = new(Image,"rank/number_1.png");  --两位排行前面的一张图片
--                        local pos = sdata.rank - 10;
--                        local rank_pos_back = new(Image,string.format("rank/number_%d.png",pos)); --两位排行后面的一张图片
--                        rank_pos_forward:setPos(-3,0);
--                        rank_pos_back:setPos(3,0);
--                        rank_pos_forward:setAlign(kAlignCenter);
--                        rank_pos_back:setAlign(kAlignCenter);
--		                img_rank:addChild(rank_pos_forward);
--                        img_rank:addChild(rank_pos_back);
--                    else
--                        img_rank = new(Image,"rank/rank_medal.png");
--                        local rank_pos_forward = new(Image,"rank/number_2.png");  --两位排行前面的一张图片
--                        local rank_pos_back = new(Image,"rank/number_2.png"); --两位排行后面的一张图片
--                        rank_pos_forward:setPos(-3,0);
--                        rank_pos_back:setPos(3,0);
--                        rank_pos_forward:setAlign(kAlignCenter);
--                        rank_pos_back:setAlign(kAlignCenter);
--		                img_rank:addChild(rank_pos_forward);
--                        img_rank:addChild(rank_pos_back)
--	                end
--                        img_rank:setAlign(kAlignLeft);
--                        img_rank:setPos(10,-6);
--                        self.m_bg:addChild(img_rank);
--                  break;
--               end
--            end
--        else
--            self.img_rank = new(Image,"rank/rank_medal.png");
--            self.text_rank =  new(Text,1,nil, nil, nil, nil, 24, 70, 145, 105);
--            self.text_rank:setAlign(kAlignCenter);
--            self.img_rank:addChild(self.text_rank);
--            self.img_rank:setAlign(kAlignLeft);
--            self.img_rank:setPos(10,-6);
--            self.m_bg:addChild(self.img_rank);
--        end

--    else

--        if data.rank ~= nil then
--	    if data.rank  < 4 and data.rank > 0 then 
--		    self.img_rank = new(Image,string.format("friends/rank_medal%d.png",data.rank));
--	    else
--		    self.img_rank = new(Image,"friends/medal_bg.png");
--		    self.text_rank =  new(Text,data.rank,nil, nil, nil, nil, 24, 70, 145, 105);
--            self.text_rank:setAlign(kAlignCenter);
--		    self.img_rank:addChild(self.text_rank);
--	    end
--        self.img_rank:setPos(sx - 125,sy + 5);
--        self.m_bg:addChild(self.img_rank);
--        else
--        self.img_rank = new(Image,"friends/medal_bg.png");
--        self.text_rank =  new(Text,1,nil, nil, nil, nil, 24, 70, 145, 105);
--        self.text_rank:setAlign(kAlignCenter);
--        self.img_rank:addChild(self.text_rank);
--        self.img_rank:setPos(sx - 125,sy + 5);
--        self.m_bg:addChild(self.img_rank);
--        end


--        self.m_title = new(Text,"未知",nil, nil, nil, nil,28,250,230,180);
--        self.m_fs = new(Text,"积分：",nil, nil, nil, nil, 20,185,155,110);
--        self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105);
--        self.m_lasttimeTitle = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105);

--        self.m_title:setAlign(kAlignLeft);
--        self.m_title:setPos(sx,sy - 40);
--        self.m_bg:addChild(self.m_title);
--        self.m_fs:setAlign(kAlignLeft);
--        self.m_fs:setPos(sx,sy - 10);
--        self.m_bg:addChild(self.m_fs);


--        self.m_lasttimeTitle:setPos(110,0);
--        self.m_lasttimeTitleNum:setPos(185,0);
--    end

--        self.m_lasttimeTitle:setAlign(kAlignRight);
--        self.m_lasttimeTitleNum:setAlign(kAlignRight);
--        self.m_bg:addChild(self.m_lasttimeTitle);
--        self.m_bg:addChild(self.m_lasttimeTitleNum);

--end

--RankFriendsItem.setOnBtnClick = function(self,obj,func)
--    self.m_btn_obj = obj;
--    self.m_btn_func = func;
--end

--RankFriendsItem.onBtnClick = function(self)
--    --FriendsInfoController.friendsID = self.datas.uid;
--    Log.i("RankFriendsItem.onBtnClick");
--    StateMachine.getInstance():pushState(States.FriendsInfo,StateMachine.STYPE_WAIT,nil,tonumber(self.uid));
--end

--RankFriendsItem.updateUserIcon = function(self,imageName)
--    Log.i("FriendsItem.updateUserIcon: "..(imageName or "null"));
--    if imageName then
--        if self.uid == UserInfo.getInstance():getUid() then
--            self.m_icon:setFile(UserInfo.getInstance():getIconFile());
--        else
--            self.m_icon:setFile(imageName);
--        end
--    end

--end

--RankFriendsItem.changeStatus = function(self)

--    self.status = FriendsData.getInstance():getUserStatus(self.uid);

--    --最近登录
--    if self.status~= nil then
--        if self.status.hallid <=0 then --离线
--           if self.last_login_time and self.last_login_time ~= "" then
--               self.m_lasttimeTitleNum = new(Text,self.last_login_time,nil, nil, nil, nil, 24, 120, 120, 120); 
--               self.m_lasttimeTitle = new(Text,"最近登陆:",nil, nil, nil, nil,24, 120, 120, 120);
--                self.m_lasttimeTitle:setPos(18,-15);
--                self.m_lasttimeTitleNum:setPos(32,12);
--           else
--               self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 24, 120, 120, 120); 
--               self.m_lasttimeTitle = new(Text,"",nil, nil, nil, nil, 24, 120, 120, 120)
--           end
--        else
--           if self.status.tid >0 then -- 用户在下棋 
--                local strname = NewRankScene.onGetScreenings(self.status.level);
--                self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 24, 120, 120, 120); 
--                self.m_lasttimeTitleNum:setVisible(false);
--                self.m_lasttimeTitle = new(Text,"在线",nil, nil, nil, nil, 24, 120, 120, 120);
--                if strname == nil then
--                       self.m_lasttimeTitle.setText(self.m_lasttimeTitle,"在线",nil, nil,70,145,105);
--                       self.m_lasttimeTitle:setPos(18,0);
--                else
--                       self.m_lasttimeTitle.setText(self.m_lasttimeTitle,strname,nil, nil,70,145,105);
--                       self.m_lasttimeTitle:setPos(18,0);
--                end              
--           else
--                self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 24, 120, 120, 120); 
--                self.m_lasttimeTitleNum:setVisible(false);
--                self.m_lasttimeTitle = new(Text,"在线",nil, nil, nil, nil, 24, 120, 120, 120);
--           end
--        end
--    else
--        self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105); 
--        self.m_lasttimeTitle = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105);
--    end

--end