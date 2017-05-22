--region NewFile_1.lua
--Author : FordFan
--Date   : 2015/11/4
--排行榜
--endregion
require(BASE_PATH.."chessScene");
require("dialog/chioce_dialog");
require("dialog/http_loading_dialog");
require("dialog/create_and_check_sociaty_dialog");
require("dialog/common_help_dialog");
require(MODEL_PATH.."friendsInfo/friendsInfoController");
require(MODEL_PATH .. "chessSociatyModule/chessSociatyModuleConstant")
require(VIEW_PATH .. "rank_view_node");


NewRankScene = class(ChessScene);

NewRankScene.s_friend_mode = 1; --好友排行
NewRankScene.s_world_mode  = 2; --世界排行

NewRankScene.s_controls = 
{
    back_btn            = 1;
    sociaty_rank_btn    = 2;
    charm_rank_btn      = 3;
    master_rank_btn     = 4;

--    friend_rank_view    = 5;   -- 好友榜
--    charm_rank_view     = 6;   -- 魅力榜
--    master_rank_view    = 7;   -- 大师榜

    my_rank_view        = 8;   -- 我的排行
    my_rank_mask        = 9;
    my_rank_name        = 10;
    my_rank_type        = 11;
    my_rank             = 12;

    rank_view           = 13;
    teapot_dec          = 14;  -- 茶壶
    book_mark           = 15;  -- 右标签
--    top_btn_view        = 15;  -- 排行榜切换view
    friend_rank_btn     = 16;
    help_btn            = 17;
}

NewRankScene.s_cmds = 
{
    change_friends_master     = 1; --好友积分榜
    change_world_master       = 2; --世界积分榜
--    change_friends_charm      = 3; --好友魅力榜
    change_world_charm        = 4; --世界魅力榜
--    change_friends_money      = 5; --好友财富榜
    change_world_sociaty      = 6; --世界棋社榜
    change_userIcon           = 7; -- 更新用户头像
    my_friend_rank            = 8;
    my_charm_rank             = 9;
    my_master_rank            = 10;
    my_sociaty_rank           = 13;
    my_money_rank             = 14;
    changeFriendstatus        = 11;
    changeFriendsData         = 12;
    dismissLoading            = 13;
}

NewRankScene.rank_type = {
    master_rank = 1,
    charm_rank = 2,
    sociaty_rank = 3,
    friend_rank = 4,
}

NewRankScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = NewRankScene.s_controls;
    self.m_rankType = controller.m_state.rankType;
    --排行榜
    self.friendsMasterlist_check = false;   
--    self.friendsCharmlist_check = false;
----    self.friendsMoneylist_check = false;
    self.worldMasterlist_check   = false;   
    self.worldCharmlist_check   = true;
    self.worldSociatylist_check   = false;

--    self.rank_status = NewRankScene.s_world_mode; --好友榜或者世界榜

    if self.m_rankType == NewRankScene.rank_type.master_rank then
        self.worldMasterlist_check = true;
    elseif self.m_rankType == NewRankScene.rank_type.charm_rank then
        self.worldCharmlist_check = true;
    elseif self.m_rankType == NewRankScene.rank_type.sociaty_rank then
        self.worldSociatylist_check = true;
    elseif self.m_rankType == NewRankScene.rank_type.friend_rank then
        self.friendsMasterlist_check = true;
    end
    self:setUpdateDataLock()
    self:setHasData()
    self:initView();
end 

NewRankScene.resume = function(self)
    ChessScene.resume(self);
    EventDispatcher.getInstance():register(Event.Call,self,self.onNativeCallDone);
end;


NewRankScene.pause = function(self)
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeCallDone);
	ChessScene.pause(self);
    self:removeAnimProp();
    self:loadingTileExit()
end 


NewRankScene.dtor = function(self)
    delete(self.loading_view);
    delete(self.anim_start);
    delete(self.anim_end);
end 

NewRankScene.removeAnimProp = function(self)
    self.rank_view:removeProp(1);
    self.book_mark:removeProp(1);
    self.m_leaf_left:removeProp(1);
end

NewRankScene.setAnimItemEnVisible = function(self,ret)
    self.m_leaf_left:setVisible(ret);
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
    self:requestCtrlCmd(NewRankController.s_cmds.back_action);
end

--给4个榜单的数据请求设置锁，true表示已锁上，无法请求数据；false为解锁，可以请求数据
NewRankScene.setUpdateDataLock = function (self)
    self.updateMasterRankDataLock = false 
    self.updateCharmRankDataLock = false 
    self.updateSociatyRankDataLock = false 
    self.updateFriendsRankDataLock = false 
end

NewRankScene.setHasData = function (self)
    self.hasMasterRankData = false 
    self.hasCharmRankData = false 
    self.hasSociatyRankData = false 
    self.hasFriendsRankData = false 
end
NewRankScene.initView = function(self)

    self.rank_view               = self:findViewById(self.m_ctrls.rank_view);
    self.m_teapot_dec            = self:findViewById(self.m_ctrls.teapot_dec);
    self.m_back_btn              = self:findViewById(self.m_ctrls.back_btn);
    self.book_mark               = self:findViewById(self.m_ctrls.book_mark);

    self.charmlist_btn           = self:findViewById(self.m_ctrls.charm_rank_btn);
    self.masterlist_btn          = self:findViewById(self.m_ctrls.master_rank_btn);
    self.sociatyAndMoneylist_btn = self:findViewById(self.m_ctrls.sociaty_rank_btn);
    self.friendlist_btn          = self:findViewById(self.m_ctrls.friend_rank_btn);
    self.help_btn                = self:findViewById(self.m_ctrls.help_btn);

    self.charmlist_text          = self.charmlist_btn:getChildByName("Text1");
    self.masterlist_text         = self.masterlist_btn:getChildByName("Text1");
    self.sociatyAndMoneylist_text= self.sociatyAndMoneylist_btn:getChildByName("Text1");
    self.friendlist_text         = self.friendlist_btn:getChildByName("Text1");


--    self.top_btn_view            = self:findViewById(self.m_ctrls.top_btn_view);
--    self.friend_rank_btn         = self.top_btn_view:getChildByName("friend_btn");
--    self.friend_text             = self.friend_rank_btn:getChildByName("text");
--    self.world_rank_btn          = self.top_btn_view:getChildByName("world_btn");
--    self.world_text              = self.world_rank_btn:getChildByName("text");
--    self.btn_line                = self.top_btn_view:getChildByName("btn_line");
--    self.world_text:setColor(215,75,45)
--    self.friend_text:setColor(135,100,95)

--    self.friend_view             = self.rank_view:getChildByName("friend_view");
    self.world_view              = self.rank_view:getChildByName("world_view");
    self.friend_master_view      = self.world_view:getChildByName("friend_master_rank_view");
--    self.friend_money_view       = self.friend_view:getChildByName("friend_money_rank_view");
--    self.friend_charm_view       = self.friend_view:getChildByName("friend_charm_rank_view");
    self.world_master_view       = self.world_view:getChildByName("world_master_rank_view");
    self.world_charm_view        = self.world_view:getChildByName("world_charm_rank_view");
    self.world_sociaty_view      = self.world_view:getChildByName("world_sociaty_rank_view");

    self.master_tips             = self.rank_view:getChildByName("master_tips");
    self.charm_tips              = self.rank_view:getChildByName("charm_tips");
    self.sociaty_tips            = self.rank_view:getChildByName("sociaty_tips");
    self.friends_tips            = self.rank_view:getChildByName("friend_tips");


--    self.friend_rank_btn:setOnClick(self,self.onFriendRankClick);
--    self.world_rank_btn:setOnClick(self,self.onWorldRankClick);
    self.charmlist_btn:setOnClick(self,self.onRankingCharmBtnClick);
    self.masterlist_btn:setOnClick(self,self.onRankingMasterBtnClick);
    self.sociatyAndMoneylist_btn:setOnClick(self,self.onRankingOtherBtnClick);
    self.friendlist_btn:setOnClick(self,self.onRankingFriendBtnClick);
    self.help_btn:setOnClick(self,self.onGetHelp);

    

    self.m_leaf_left = self.m_root:getChildByName("leaf_left");
    self.m_leaf_left:setFile("common/decoration/left_leaf.png")

    self.bottom_line             = self.rank_view:getChildByName("bottom_line"); --正常使用
    --我的排行
    self.m_MyRankView    = self:findViewById(self.m_ctrls.my_rank_view);
    self.m_myRankMask    = self.m_MyRankView:getChildByName("icon_frame"):getChildByName("icon_mask");
    self.m_vip_frame     = self.m_MyRankView:getChildByName("icon_frame"):getChildByName("vip_frame"); 
    self.my_level        = self.m_MyRankView:getChildByName("icon_frame"):getChildByName("level");
    self.m_myRankName    = self.m_MyRankView:getChildByName("name"); 
    self.m_vip_logo      = self.m_MyRankView:getChildByName("vip_logo"); 
    self.m_myRankType    = self.m_MyRankView:getChildByName("type"); 
    self.m_myRankNum     = self.m_MyRankView:getChildByName("num"); 
    self.m_MyRankMedal   = self.m_MyRankView:getChildByName("rank_medal");
    self.m_outRank       = self.m_MyRankMedal:getChildByName("out_rank");
    self.m_label         = self.m_MyRankView:getChildByName("Image5");
    self.rankImg = {};
    -- 1代表百位 2代表十位 3代表个位
    for i = 1,3 do 
        self.rankImg[i] = self.m_MyRankMedal:getChildByName("Image" .. i);
    end
    self.m_myRankNum:setText(UserInfo.getInstance():getScore());
    self.m_myRankName:setText(UserInfo.getInstance():getName());

    self:setVipLogo()
    local frameRes = UserSetInfo.getInstance():getFrameRes();
    self.m_vip_frame:setVisible(frameRes.visible);
    local fw,fh = self.m_vip_frame:getSize();
    if frameRes.frame_res then
        self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
    end

    self:updateHeadIcon();

    self.switch = {
        [1] = function()
            --大师榜
            self.bottom_line:setPos(-77,212)
            self.masterlist_text:setColor(215,75,45)
            self.charmlist_text:setColor(135,100,95)
            self.sociatyAndMoneylist_text:setColor(135,100,95)
            self.friendlist_text:setColor(135,100,95)
        end,
        [2] = function()
            --魅力榜
            self.bottom_line:setPos(-232,212)
            self.masterlist_text:setColor(135,100,95)
            self.charmlist_text:setColor(215,75,45)
            self.sociatyAndMoneylist_text:setColor(135,100,95)
            self.friendlist_text:setColor(135,100,95)
        end,
        [3] = function()
            --棋社榜
            self.bottom_line:setPos(77,212)
            self.masterlist_text:setColor(135,100,95)
            self.charmlist_text:setColor(135,100,95)
            self.sociatyAndMoneylist_text:setColor(215,75,45)
            self.friendlist_text:setColor(135,100,95)
        end,
        [4] = function()
            --好友榜
            self.bottom_line:setPos(232,212)
            self.masterlist_text:setColor(135,100,95)
            self.charmlist_text:setColor(135,100,95)
            self.sociatyAndMoneylist_text:setColor(135,100,95)
            self.friendlist_text:setColor(215,75,45)
        end,
    }
    local f = self.switch[NewRankScene.rank_type.charm_rank]
    if f then
        f();
    end
    self:loadingTile();
end

function NewRankScene.setVipLogo(self,label)
    if label and label == 3 then
        self.m_myRankName:setPos(224,-18);
        self.m_vip_logo:setVisible(false);
        return 
    end

    local is_vip = UserInfo.getInstance():getIsVip();
    local vw,vh = self.m_vip_logo:getSize();
    if is_vip and is_vip == 1 then
        self.m_myRankName:setPos(227+vw,-18);
        self.m_vip_logo:setVisible(true);
    else
        self.m_myRankName:setPos(224,-18);
        self.m_vip_logo:setVisible(false);
    end
end

--[Comment]
--更新我的排名
NewRankScene.updataMyRank = function(self,info,label)
    local pos = info.rank;
    self:setVipLogo(label)
    if label == NewRankScene.rank_type.master_rank or label == 0 then
        self.m_label:setFile("rank/my_rank.png")
        self.my_level:setVisible(true)
        self.m_myRankName:setText(UserInfo.getInstance():getName())
        self.m_myRankType:setText("积分: ");
        self.m_myRankNum:setText("" .. UserInfo.getInstance():getScore());
    end
    if label == NewRankScene.rank_type.charm_rank then
        self.m_label:setFile("rank/my_rank.png")
        self.my_level:setVisible(true)
        self.m_myRankName:setText(UserInfo.getInstance():getName())
        self.m_myRankType:setText("魅力: ");
        self.m_myRankNum:setText("" .. info.fans_num);
    end
    if label == NewRankScene.rank_type.sociaty_rank then
        self.m_label:setFile("rank/my_sociaty.png")
        self.my_level:setVisible(false)
        self.m_myRankType:setText("成员: ");
        local maxnum = info.max_mum or 30
        local member_num = info.member_num or 1
        self.m_myRankNum:setText(member_num .. "/" .. maxnum);
        local name = info.name
        self.m_myRankName:setText(name or"暂未加入棋社")
    end
    if label == NewRankScene.rank_type.friend_rank then
        self.m_label:setFile("rank/my_rank.png")
        self.my_level:setVisible(true)
        self.m_myRankName:setText(UserInfo.getInstance():getName())
        self.m_myRankType:setText("积分: ");
        self.m_myRankNum:setText("" .. UserInfo.getInstance():getScore());
--        local money = ToolKit.getMoneyStr(info.money or 0)
--        self.m_myRankNum:setText("" .. money);
    end
    
    self.m_MyRankMedal:setFile("rank/rank_medal.png");

    if not pos or pos >= 1000 or pos == 0 then
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
    if user_icon_type > 0 then
        self.my_head_icon = new(Mask,UserInfo.DEFAULT_ICON[user_icon_type] or UserInfo.DEFAULT_ICON[1],"common/background/head_mask_bg_86.png"); 
    elseif user_icon_type == 0 then
        self.my_head_icon = new(Mask,UserInfo.DEFAULT_ICON[1],"common/background/head_mask_bg_86.png");
    else
        self.my_head_icon = new(Mask,UserInfo.DEFAULT_ICON[1],"common/background/head_mask_bg_86.png");
        self.my_head_icon:setUrlImage(user_icon_url);
    end
    self.my_head_icon:setAlign(kAlignCenter);
    self.my_head_icon:setSize(self.m_myRankMask:getSize());
    self.m_myRankMask:addChild(self.my_head_icon);
    self.my_level:setFile("common/icon/level_".. 10 - UserInfo.getInstance():getDanGradingLevelByScore(UserInfo.getInstance():getScore())..".png");
end

--------用户头像更新接口
--NewRankScene.changeUserIconCall = function(self,data)
----    Log.i("changeUserIconCall");
--      -- 自己
--      self:changeMyRankIconCall(data);
--      -- 好友
--      self:changeListUserIconCall2(data,self.m_friends_adapter,self.changeFriendsData);
--      -- 魅力
--      self:changeListUserIconCall2(data,self.m_charm_adapter,self.changeCharmData);
--      -- 大师
--      self:changeListUserIconCall2(data,self.m_master_adapter,self.masterData);
--end
--------自己排行榜头像更新
--NewRankScene.changeMyRankIconCall = function(self,data)
----    Log.i("my icon data" .. json.encode(data));
--    if tonumber(data.what) ==  tonumber(UserInfo.getInstance():getUid()) then
--        self.my_head_icon:setFile(data.ImageName or "userinfo/userHead.png");
--    end
--end

--------用户头像更新实现方法 2 
--NewRankScene.changeListUserIconCall2 = function(self,data,m_adapte,datas)
----   Log.i("changeListUserIconCall");
--   if not datas then
--       return;
--   end
--   if data and m_adapte then
----        local datas = m_adapte:getData();
--        for i,v in pairs(datas) do
--            if v.mid == tonumber(data.what) and m_adapte:isHasView(i) then
--                local view = m_adapte:getTmpView(i);
--                view:updateUserIcon(data.ImageName);
--            end
--        end
--   end
--end

--loading界面
NewRankScene.loadingTile = function(self,string)
    if not self.loading_view then
        self.loading_view = AnimLoadingFactory.createChessLoadingAnimView()
        self.loading_view:setAlign(kAlignCenter)
        self.loading_view:setPos(nil,-20)
        self:addChild(self.loading_view)
    end
    self.loading_view:start()
    self.loading_view:setVisible(true)
end

NewRankScene.loadingTileExit = function(self)
    if self.loading_view then
        self.loading_view:stop()
        self.loading_view:setVisible(false)
    end
end

-----------------排行榜--------------------------------
function NewRankScene.onFriendRankClick(self)  --切换好友榜
    if self.rank_status == 1 then return end
    self.sociatyAndMoneylist_text:setText("财富榜");
    self.rank_status = NewRankScene.s_friend_mode
    self.btn_line:setPos(230,10)
    self.friend_text:setColor(215,75,45)
    self.world_text:setColor(135,100,95)
    self.friend_view:setVisible(true)
    self.world_view:setVisible(false)
    self:switchBtn(2)
    self:resetView()
    local f = self.switch[2]
    if f then 
        f();
    end
    self:loadingTileExit();
    self:loadingTile("搜索好友 榜信息");
    self:requestCtrlCmd(NewRankController.s_cmds.change_friends_charm);
end

function NewRankScene.onWorldRankClick(self)  --切换世界榜
    if self.rank_status == 2 then return end
    self.sociatyAndMoneylist_text:setText("棋社榜");
    self.rank_status = NewRankScene.s_world_mode
    self.btn_line:setPos(1,10)  
    self.friend_text:setColor(135,100,95)
    self.world_text:setColor(215,75,45)
    self.world_view:setVisible(true)
    self.friend_view:setVisible(false)
    self:switchBtn(5)
    self:resetView()
    local f = self.switch[2]
    if f then 
        f();
    end
    self:loadingTileExit();
    self:loadingTile("搜索大师榜信息");
    self:requestCtrlCmd(NewRankController.s_cmds.change_world_charm);
end

function NewRankScene.onRankingMasterBtnClick(self)  --切换大师榜
--    if self.rank_status == 1 then
--        if not self.friendsMasterlist_check then
--            self:switchBtn(1)
--            self:resetView()
--            local f = self.switch[1]
--            if f then 
--                f();
--            end
--            self:loadingTileExit();
--            self:loadingTile("搜索好友积分榜信息");
--            self:requestCtrlCmd(NewRankController.s_cmds.change_friends_master);
--        end
--        return
--    end
--    if self.rank_status == 2 then
        if not self.worldMasterlist_check then
            self:switchBtn(NewRankScene.rank_type.master_rank)
            self:resetView()
            local f = self.switch[NewRankScene.rank_type.master_rank]
            if f then 
                f();
            end
            self:loadingTileExit(); 
            if self.hasMasterRankData then 
                self:switchTips()
            else
                self:switchTips(NewRankScene.rank_type.master_rank)    
            end       
            if not self.updateMasterRankDataLock then 
                self.updateMasterRankDataLock = true 
                self:loadingTile("搜索大师榜信息");
                self:requestCtrlCmd(NewRankController.s_cmds.change_world_master);
            end
        end
--        return
--    end
end


function NewRankScene.onRankingCharmBtnClick(self)  --切换魅力榜
--    if self.rank_status == 1 then
--        if not self.friendsCharmlist_check then
--            self:switchBtn(2)
--            self:resetView()
--            local f = self.switch[2]
--            if f then 
--                f();
--            end
--            self:loadingTileExit();
--            self:loadingTile("搜索魅力榜信息");
--            self:requestCtrlCmd(NewRankController.s_cmds.change_friends_charm);
--        end
--        return
--    end
--    if self.rank_status == 2 then
        if not self.worldCharmlist_check then
            self:switchBtn(NewRankScene.rank_type.charm_rank)
            self:resetView()
            local f = self.switch[NewRankScene.rank_type.charm_rank]
            if f then 
                f();
            end
            self:loadingTileExit();    
            if self.hasCharmRankData then 
                self:switchTips()
            else 
                self:switchTips(NewRankScene.rank_type.charm_rank)    
            end   
            if not self.updateCharmRankDataLock then 
                self.updateCharmRankDataLock = true 
                self:loadingTile("搜索魅力榜信息");
                self:requestCtrlCmd(NewRankController.s_cmds.change_world_charm);
            end
        end
--        return
--    end
end

function NewRankScene.onRankingOtherBtnClick(self)  --切换棋社榜
--    if self.rank_status == 1 then
--        if not self.friendsMoneylist_check then
--            self:switchBtn(3)
--            self:resetView()
--            local f = self.switch[3]
--            if f then 
--                f();
--            end
--            self:loadingTileExit();
--            self:loadingTile("搜索财富榜信息");
--            self:requestCtrlCmd(NewRankController.s_cmds.change_friends_money);
--        end
--        return
--    end
--    if self.rank_status == 2 then
        if not self.worldSociatylist_check then
            self:switchBtn(NewRankScene.rank_type.sociaty_rank)
            self:resetView()
            local f = self.switch[NewRankScene.rank_type.sociaty_rank]
            if f then 
                f();
            end
            self:loadingTileExit()      
            if self.hasSociatyRankData then 
                self:switchTips()
            else 
                self:switchTips(NewRankScene.rank_type.sociaty_rank)    
            end 
            if not self.updateSociatyRankDataLock then 
                self.updateSociatyRankDataLock = true 
                self:loadingTile("搜索棋社榜信息");
                self:requestCtrlCmd(NewRankController.s_cmds.change_world_sociaty);
            end
        end
--        return
--    end
end

function NewRankScene.onRankingFriendBtnClick(self)  --切换好友榜
--    if self.rank_status == 1 then
--        if not self.friendsMoneylist_check then
--            self:switchBtn(3)
--            self:resetView()
--            local f = self.switch[3]
--            if f then 
--                f();
--            end
--            self:loadingTileExit();
--            self:loadingTile("搜索财富榜信息");
--            self:requestCtrlCmd(NewRankController.s_cmds.change_friends_money);
--        end
--        return
--    end
--    if self.rank_status == 2 then
        if not self.friendsMasterlist_check then
            self:switchBtn(NewRankScene.rank_type.friend_rank)
            self:resetView()
            local f = self.switch[NewRankScene.rank_type.friend_rank]
            if f then 
                f();
            end
            self:loadingTileExit();  
            if self.hasFriendsRankData then 
                self:switchTips()
            else 
                self:switchTips(NewRankScene.rank_type.friend_rank)   
            end       
            if not self.updateFriendsRankDataLock then 
                self.updateFriendsRankDataLock = true
                self:loadingTile("搜索好友榜信息");
                self:requestCtrlCmd(NewRankController.s_cmds.change_friends_master);
            end
        end
--        return
--    end
end

--[Comment]
--世界魅力榜
function NewRankScene.changeWorldCharmCall(self,datas)
    self:loadingTileExit();
    delete(self.world_charm_adapter);
    self.world_charm_adapter = nil;
    self.world_charm_view:removeAllChildren(true)
    if not datas or #datas < 2 then 
        self.hasCharmRankData = false 
        self:switchTips(NewRankScene.rank_type.charm_rank)
        return;  
    end
    self.hasCharmRankData =true
    self:switchTips()
    for k,v in pairs(datas) do 
        v.rankType = NewRankScene.rank_type.charm_rank;
    end
    self.world_charm_adapter = new(CacheAdapter,RankItem,datas);
    self.world_charm_view:setAdapter(self.world_charm_adapter);
    self:removeViewProp()
    self.world_charm_view:addPropTransparency(1,kAnimNormal,300,150,0,1);
    self:resetView()
end

--[Comment]
--世界大师榜
function NewRankScene.changeWorldMasterCall(self,datas)
    self:loadingTileExit();
    delete(self.world_master_adapter);
    self.world_master_adapter = nil;
    self.world_master_view:removeAllChildren(true)
    if not datas or #datas < 1 then 
        self.hasMasterRankData = false 
        self:switchTips(NewRankScene.rank_type.master_rank)
        return;
    end
    self.hasMasterRankData = true 
    self:switchTips()
    for k,v in pairs(datas) do
        v.rankType = NewRankScene.rank_type.master_rank;
    end
    self.world_master_adapter = new(CacheAdapter,RankItem,datas);
    self.world_master_view:setAdapter(self.world_master_adapter);
    self:removeViewProp()
    self.world_master_view:addPropTransparency(1,kAnimNormal,300,150,0,1);
    self:resetView()
end

--[Comment]
--世界棋社榜
function NewRankScene.changeWorldSociatyCall(self,datas)
    self:loadingTileExit();
    delete(self.world_sociaty_adapter);
    self.world_sociaty_adapter = nil;
    self.world_sociaty_view:removeAllChildren(true)
    if not datas or #datas < 1 then 
        self.hasSociatyRankData = false 
        self:switchTips(NewRankScene.rank_type.sociaty_rank)
        return;
    end
    self.hasSociatyRankData = true 
    self:switchTips()
    self.world_sociaty_adapter = new(CacheAdapter,SociatyItem,datas);
    self.world_sociaty_view:setAdapter(self.world_sociaty_adapter);
    self:removeViewProp()
    self.world_sociaty_view:addPropTransparency(1,kAnimNormal,300,150,0,1);
    self:resetView()
end

--[Comment]
--好友大师榜
function NewRankScene.changeFriendsMasterCall(self,datas)
    self:loadingTileExit();
    delete(self.friends_master_adapter);
    self.friends_master_adapter = nil;
    self.friend_master_view:removeAllChildren(true)
    if not datas or #datas < 1 then
        self.hasFriendsRankData = false
        self:switchTips(NewRankScene.rank_type.friend_rank)
        return;
    end
    self.hasFriendsRankData = true 
    self:switchTips()
    local ranks  = {};
	for i,value in pairs(datas) do 
        local user = {};
		user.mid         = value.mid;
		user.score       = value.score;
        user.rank        = i;
        user.rankType    = NewRankScene.rank_type.friend_rank;
        user.iconType    = value.iconType
        user.icon_url    = value.icon_url
        user.mnick       = value.mnick
        user.my_set      = json.decode(value.my_set) or {}
        user.mactivetime = value.mactivetime or 0
        table.insert(ranks,user);
	end
    self.friends_master_adapter = new(CacheAdapter,RankItem,ranks);
    self.friend_master_view:setAdapter(self.friends_master_adapter);
    self:removeViewProp()
    self.friend_master_view:addPropTransparency(1,kAnimNormal,300,150,0,1);
    self:resetView()
end

--[Comment]
--好友魅力榜
function NewRankScene.changeFriendCharmCall(self,datas)
    self:loadingTileExit();
    delete(self.friends_charm_adapter);
    self.friends_charm_adapter = nil;
    self.friend_charm_view:removeAllChildren(true)
    if not datas or #datas < 1 then
        self:switchTips(4)
        return;
    end
    self:switchTips()
    local ranks  = {};
	for i,value in pairs(datas) do 
        local user = {};
		user.mid         = value.mid;
		user.score       = value.score;
        user.fans_num    = value.fans_num
        user.rank        = i;
        user.rankType    = 2;
        user.iconType    = value.iconType
        user.icon_url    = value.icon_url
        user.mnick       = value.mnick
        user.my_set      = json.decode(value.my_set) or {}
        user.mactivetime = value.mactivetime or 0
        table.insert(ranks,user);
	end
    self.friends_charm_adapter = new(CacheAdapter,RankItem,ranks);
    self.friend_charm_view:setAdapter(self.friends_charm_adapter);
    self:removeViewProp()
    self.friend_charm_view:addPropTransparency(1,kAnimNormal,300,150,0,1);
    self:resetView()
end

--[Comment]
--好友财富榜
function NewRankScene.changeFriendMoneyCall(self,datas)
    self:loadingTileExit();
    delete(self.friends_money_adapter);
    self.friends_money_adapter = nil;
    self.friend_money_view:removeAllChildren(true)
    if not datas or #datas < 1 then
        self:switchTips(4)
        return;
    end
    self:switchTips()
    local ranks  = {};
	for i,value in pairs(datas) do 
        local user = {};
		user.mid         = value.mid;
		user.score       = value.score;
        user.rank        = i;
        user.rankType    = 4;
        user.iconType    = value.iconType
        user.icon_url    = value.icon_url
        user.mnick       = value.mnick
        user.my_set      = json.decode(value.my_set) or {}
        user.mactivetime = value.mactivetime or 0
        user.money       = value.money or 0
        table.insert(ranks,user);
	end
    self.friends_money_adapter = new(CacheAdapter,RankItem,ranks);
    self.friend_money_view:setAdapter(self.friends_money_adapter);
    self:removeViewProp()
    self.friend_money_view:addPropTransparency(1,kAnimNormal,300,150,0,1);
    self:resetView()
end

NewRankScene.getTime = function(time)
    if ToolKit.isSecondDay(time) then
        return os.date("%m-%d %H:%M",time);-- 08-07格式
    else
        return os.date("%H:%M",time);--%Y/%m/%d %X
    end;
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

function NewRankScene.onGetSociatyInfoCall(self,data)
    if not data then
        return
    end
    if not self.m_sociaty_dialog then
        self.m_sociaty_dialog = new(CreateAndCheckSociatyDialog);
    end
    self.m_sociaty_dialog:setSociatyData(data)
    self.m_sociaty_dialog:setDialogStatus(CreateAndCheckSociatyDialog.s_check_mode);
    self.m_sociaty_dialog:show();
end

--[Comment]
--切换数据为空时提示
function NewRankScene.switchTips(self,index)
    if not index then index = 0 end
    self.master_tips:setVisible( (index == 1 and true or false))
    self.charm_tips:setVisible( (index == 2 and true or false))
    self.sociaty_tips:setVisible( (index == 3 and true or false))
    self.friends_tips:setVisible( (index == 4 and true or false))
end

--[Comment]
--切换排行榜
function NewRankScene.resetView(self)
--    if self.rank_status == 1 then
        self.friend_master_view:setVisible(self.friendsMasterlist_check)
--        self.friend_money_view:setVisible(self.friendsMoneylist_check)
--        self.friend_charm_view:setVisible(self.friendsCharmlist_check)
--    elseif self.rank_status == 2 then
        self.world_master_view:setVisible(self.worldMasterlist_check)
        self.world_charm_view:setVisible(self.worldCharmlist_check)
        self.world_sociaty_view:setVisible(self.worldSociatylist_check)
--    end
end

--[Comment]
--设置当前显示list状态
function NewRankScene.switchBtn(self,index)
    self.friendsMasterlist_check   = (index == 4 and true or false);   
--    self.friendsCharmlist_check    = (index == 2 and true or false);   
--    self.friendsMoneylist_check    = (index == 3 and true or false);   
    self.worldMasterlist_check     = (index == 1 and true or false);   
    self.worldCharmlist_check      = (index == 2 and true or false);   
    self.worldSociatylist_check    = (index == 3 and true or false);   
end

--[Comment]
--清除属性
function NewRankScene.removeViewProp(self)
    self.friend_master_view:removeProp(1);
--    self.friend_money_view:removeProp(1);
--    self.friend_charm_view:removeProp(1);
    self.world_master_view:removeProp(1);
    self.world_charm_view:removeProp(1);
    self.world_sociaty_view:removeProp(1);
end

function NewRankScene.onNativeCallDone(self ,param , ...)
	if self.s_nativeEventFuncMap[param] then
		self.s_nativeEventFuncMap[param](self,...);
	end
end

function NewRankScene.onGetHelp(self)
    if not self.m_help_dialog then
        self.m_help_dialog = new(CommonHelpDialog)
        self.m_help_dialog:setMode(CommonHelpDialog.rank_mode)
    end 
    self.m_help_dialog:show()

end

NewRankScene.s_controlConfig = 
{
    [NewRankScene.s_controls.rank_view]            = {"rank_view"};
    [NewRankScene.s_controls.back_btn]             = {"back_btn"};
    [NewRankScene.s_controls.teapot_dec]           = {"teapot_dec"};
    [NewRankScene.s_controls.book_mark]            = {"bookMark"}; 
    [NewRankScene.s_controls.master_rank_btn]      = {"rank_view","master_rank_btn"};
    [NewRankScene.s_controls.charm_rank_btn]       = {"rank_view","charm_rank_btn"};
    [NewRankScene.s_controls.sociaty_rank_btn]     = {"rank_view","sociaty_rank_btn"};
    [NewRankScene.s_controls.friend_rank_btn ]     = {"rank_view","friend_rank_btn"};
    [NewRankScene.s_controls.my_rank_view]         = {"rank_view","my_rank_bg"};
    [NewRankScene.s_controls.help_btn]             = {"help_btn"};

    
--    [NewRankScene.s_controls.top_btn_view]         = {"rank_view","switch_btn_view"};  
}

NewRankScene.s_controlFuncMap = 
{
    [NewRankScene.s_controls.back_btn]             = NewRankScene.onBack;
    
}

NewRankScene.s_cmdConfig =
{    
    [NewRankScene.s_cmds.change_friends_master]  = NewRankScene.changeFriendsMasterCall;  
    [NewRankScene.s_cmds.change_world_master]    = NewRankScene.changeWorldMasterCall;  
--    [NewRankScene.s_cmds.change_friends_charm]   = NewRankScene.changeFriendCharmCall;  
    [NewRankScene.s_cmds.change_world_charm]     = NewRankScene.changeWorldCharmCall;  
--    [NewRankScene.s_cmds.change_friends_money]   = NewRankScene.changeFriendMoneyCall;  
    [NewRankScene.s_cmds.change_world_sociaty]   = NewRankScene.changeWorldSociatyCall;  

    [NewRankScene.s_cmds.change_userIcon]        = NewRankScene.changeUserIconCall;
    [NewRankScene.s_cmds.changeFriendstatus]     = NewRankScene.changeStatusCall;

    [NewRankScene.s_cmds.my_friend_rank]         = NewRankScene.updataMyRank;
    [NewRankScene.s_cmds.my_charm_rank]          = NewRankScene.updataMyRank;
    [NewRankScene.s_cmds.my_master_rank]         = NewRankScene.updataMyRank;
    [NewRankScene.s_cmds.my_sociaty_rank]        = NewRankScene.updataMyRank;
    [NewRankScene.s_cmds.my_money_rank]          = NewRankScene.updataMyRank; 

    [NewRankScene.s_cmds.dismissLoading]         = NewRankScene.loadingTileExit; 
}

NewRankScene.s_nativeEventFuncMap = {
    [kSociaty_updataSociatyData2]    = NewRankScene.onGetSociatyInfoCall;
}

------------------------------------排行榜
RankItem = class(Node)
--RankItem.s_w = 590;
--RankItem.s_h = 164;


RankItem.ctor = function(self,data) -- type排行类型
    if next(data) == nil then   
        return;
    end

    self.datas = data;
    self.rankType = data.rankType;     
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
    self.m_lastStatus:setPickable(false);
    self.m_node_view:addChild(self.m_lastStatus);

    self.rank_bg = self.m_node_view:getChildByName("rank_bg");
    self.out_rank = self.m_node_view:getChildByName("rank_bg"):getChildByName("Image1");

    if self.datas and tonumber(self.datas.mid) == UserInfo.getInstance():getUid() then
        self.isMe = true;
        self.m_bg:setFile("rank/bg.png");
    else
        self.m_bg:setFile("drawable/blank.png");
    end

    if self.datas ~= nil then
        --头像
        if self.datas.iconType == -1 then
            self.m_icon:setUrlImage(self.datas.icon_url);
        else
            self.m_icon:setFile(UserInfo.DEFAULT_ICON[self.datas.iconType] or iconFile);
        end
        --段位 
        if self.datas.score then
            self.m_level:setFile("common/icon/level_"..10 - UserInfo.getInstance():getDanGradingLevelByScore(tonumber(self.datas.score))..".png"); 
        end
        --名字
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
        elseif self.rankType ~= 3 then
            local str = self.datas.mnick
            if str then
                local lenth = string.lenutf8(GameString.convert2UTF8(str));
                if lenth > 10 then    
                    str  = string.subutf8(str,1,7).."...";
                end
                if str == "" then
                    str = self.datas.mid or "博雅象棋"
                end
            else
                str = self.datas.mid or "博雅象棋"
            end
            self.m_title:setText(str);
        elseif self.rankType == 3 then
            local str = self.datas.name
            if str then
                local lenth = string.lenutf8(GameString.convert2UTF8(str));
                if lenth > 10 then    
                    str  = string.subutf8(str,1,7).."...";
                end
                if str == "" then
                    str = self.datas.mid or "博雅象棋"
                end
            else
                str = self.datas.mid or "博雅象棋"
            end
            self.m_title:setText(str);
        end

        --rankType 1：大师榜   2：魅力榜  3：棋社榜  4：好友榜
        if self.rankType == 1 or self.rankType == 4  then
            self.m_rankType:setText("积分: ");
            local score = self.datas.score or 0
            self.m_num:setText(score .. "");
        elseif self.rankType == 2 then
            self.m_rankType:setText("魅力: ");
            local num = self.datas.fans_num or 0;
            self.m_num:setText(num .. "");
--        elseif self.rankType == 4 then
--            self.m_rankType:setText("积分: ");
--            local num = self.datas.money or 0;
--            local text = ToolKit.getMoneyStr(num)
--            self.m_num:setText(text .. "");
        end

        --最近登录状态
        if self.isMe then
            self.m_lastStatus:setVisible(false);
            self.m_online:setVisible(true);
        elseif self.status~= nil then
            if self.status.hallid <=0 then
                self.last_login_time = NewRankScene.getTime(self.datas.mactivetime);
                local str = "最近登录\n"..self.last_login_time;
                self.m_lastStatus:setText(str);
                self.m_online:setVisible(false);
            else
                if RoomConfig.getInstance():isPlaying(self.status) then -- 用户在下棋 
                    local strname = RoomConfig.getInstance():onGetScreenings(self.status);
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
            self.out_rank:setVisible(false);
            local tempNum = 0;
            local num2 = rank%10; --個位
            tempNum = (rank - num2)/10; --十位
            local num1 = tempNum%10;
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

        if self.isMe then
            local frameRes = UserSetInfo.getInstance():getFrameRes();
            self.m_vip_frame:setVisible(frameRes.visible);
            local fw,fh = self.m_vip_frame:getSize();
            if frameRes.frame_res then
                self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
            end
        else
            if self.datas.my_set then
                local frameRes = UserSetInfo.getInstance():getFrameRes(self.datas.my_set.picture_frame or "sys");
                local fw,fh = self.m_vip_frame:getSize();
                if frameRes.frame_res then
                    self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
                end
                self.m_vip_frame:setVisible(frameRes.visible);
            end
        end    
    else
        self.m_title:setText("博雅象棋");
        if self.rankType == 1 then
            self.m_rankType:setText("积分: ");
        elseif self.rankType == 2 then
            self.m_rankType:setText("魅力: ");
        elseif self.rankType == 4 then
            self.m_rankType:setText("积分: ");
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
    if self.datas and self.datas.mid then
--        if tonumber(self.datas.mid) == UserInfo.getInstance():getUid() then
--            StateMachine.getInstance():pushState(States.gradeModel,StateMachine.STYPE_CUSTOM_WAIT);
--        else
            StateMachine.getInstance():pushState(States.FriendsInfo,StateMachine.STYPE_CUSTOM_WAIT,nil,tonumber(self.datas.mid));
--        end
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
            if RoomConfig.getInstance():isPlaying(self.status) then -- 用户在下棋 
                local strname = RoomConfig.getInstance():onGetScreenings(self.status);
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

-----------棋社---------------
SociatyItem = class(Node)

function SociatyItem.ctor(self,data)
    if not data then return end
    self.datas = data 
    --data {mark="1" name="啊哈哈" total_active="0" id="1004" gm_mnick="" week_active=0 rank=1 }
    self.m_root_view = SceneLoader.load(rank_view_node);
    self.m_root_view:setAlign(kAlignCenter);
    self.m_node_view = self.m_root_view:getChildByName("node");
    self:addChild(self.m_root_view);
    self:setSize(self.m_root_view:getSize());
    --段位
    local level = self.m_node_view:getChildByName("icon_bg"):getChildByName("level");
    level:setVisible(false);
    --名字
    self.sociaty_title = self.m_node_view:getChildByName("name");
    self.sociaty_title:setEllipsis(select(1,self.sociaty_title:getSize()))
    --成员
    self.sociaty_rankType = self.m_node_view:getChildByName("type");
    self.member_num = self.m_node_view:getChildByName("num");
    --棋社徽章
    self.sociaty_icon = self.m_node_view:getChildByName("icon_bg"):getChildByName("icon_mask");
    --活跃
    self.sociaty_active = new(TextView,"",136,130,kAlignCenter,nil,24,120,120,120);
    self.sociaty_active:setAlign(kAlignRight);
    self.sociaty_active:setPos(20,0);
    self.m_node_view:addChild(self.sociaty_active);
    --排名
    self.rank_bg = self.m_node_view:getChildByName("rank_bg");
    self.out_rank = self.m_node_view:getChildByName("rank_bg"):getChildByName("Image1");

    self.bg_btn = self.m_node_view:getChildByName("bg_btn");
    self.bg_btn:setOnClick(self,self.onBtnClick);
    self.bg_btn:setSrollOnClick();

    self:updataItem()
end

function SociatyItem.dtor(self)

end

function SociatyItem.updataItem(self)
    if not self.datas then return end
    --棋社名字
    self.sociaty_title:setText(self.datas.name or "博雅棋社哈哈哈哈");
    --棋社成员数量
    self.sociaty_rankType:setText("成员: ");
    local member_num = self.datas.member_num or 1
    local max_num = self.datas.max_num or 30
    self.member_num:setText(member_num .. "/" .. max_num)
    --棋社周活跃
    local active = self.datas.week_active or 0
    self.sociaty_active:setText("本周活跃\n" .. active)
    --棋社徽章
    local iconType = tonumber(self.datas.mark) or 10
    self.sociaty_icon:setFile(ChesssociatyModuleConstant.sociaty_icon[iconType] or "sociaty_about/r_scholar.png")
    --棋社排名
    if self.datas.rank then
        local rank = tonumber(self.datas.rank);
        if not rank then
            self.out_rank:setVisible(true);
            return
        end
        self.out_rank:setVisible(false);
        local tempNum = 0;
        local num2 = rank%10; --個位
        tempNum = (rank - num2)/10; --十位
        local num1 = tempNum%10;
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
end

function SociatyItem.onBtnClick(self)
    local id = tonumber(self.datas.id) or 0
    SociatyModuleData.getInstance():onCheckSociatyData2(id)
end