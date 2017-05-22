--region NewFile_1.lua
--Author : FordFan
--Date   : 2015/11/7
--endregion

require(BASE_PATH.."chessScene");
require("dialog/chioce_dialog");
require("dialog/http_loading_dialog");
--require("dialog/add_friend_dialog");
--require("dialog/union_dialog");
--require("dialog/common_share_dialog");
require("dialog/common_help_dialog");

require(MODEL_PATH.."friendsInfo/friendsInfoController");
require(MODEL_PATH.."chessSociatyModule/chessSociatyModuleView");
require(MODEL_PATH.."chessSociatyModule/chessSociatyModuleController");
require(MODEL_PATH.."friendsModule/friendsModuleView");
require(MODEL_PATH.."unionModule/unionModuleController");
require(MODEL_PATH.."unionModule/unionModuleView");

FriendsScene = class(ChessScene);

FriendsScene.itemType = 0;

FriendsScene.DEFAULT_TIPS = 
{
    "和棋友互相关注可以成为好友哦",
    "大侠，您还没有关注棋友，关注棋友可与棋友互动哦",
    "大侠，您还没有粉丝",
}

FriendsScene.default_icon = "userinfo/women_head02.png";

FriendsScene.s_controls = 
{
	back_btn            = 1;
    leaf_right          = 2;
    leaf_left           = 3;
    teapot_dec          = 4;

    content_view        = 5;
    icon_mask           = 6;
    game_id             = 7;

    friends_btn         = 8;
    guanzhu_btn         = 9;
    fans_btn            = 10;

    friend_view         = 11;
    fans_view           = 12;
    guanzhu_view        = 13;

    add_btn             = 14;--添加好友按钮
    add_btn_tip         = 15;--通讯录有好友提示
    help_btn            = 16;
--    invite_btn   = 16;--邀请好友按钮
    union_btn           = 17;--同城按钮
    bottom_menu         = 18;

    sociaty_view        = 19;
    friend_module_view  = 20;
    city_module_view    = 21

} 

FriendsScene.s_cmds = 
{
    changeFriendsList   = 1;
    changeFollowList    = 2;
    changeFansList      = 3;
    
    changeFriendsData   = 4;
    changeFriendstatus  = 5;
    change_userIcon     = 6; -- 更新用户头像
    newfriendsNum       = 7;
    friends_num         = 8;
    follow_num          = 9;
    fans_num            = 10;
    change_myHead       = 12;
    closeShareDialog    = 13;
    updata_union_dialog = 14;
    updata_union_member = 15;
}

FriendsScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = FriendsScene.s_controls;

    --好友
    self.friend_check = true
    self.sociaty_check = false
    self.city_check = false
    self:init();
end 

FriendsScene.resume = function(self)
    ChessScene.resume(self);
--    self:removeAnimProp();
--    self:resumeAnimStart();
    self.mFriendsModule:resume()
--    self.mSocaityModule:resume()
--    self.mCityModule:resume()
end

FriendsScene.pause = function(self)
    self.mFriendsModule:pause()
    if self.mSocaityModule then
        self.mSocaityModule:pause()
    end
    if self.mCityModule then
        self.mCityModule:pause()
    end
    if self.mFriendsModule then
        self.mFriendsModule:pause()
    end
--    self.mSocaityModule:pause()
--    self.mCityModule:pause()
	ChessScene.pause(self);
    self:removeAnimProp();
end 

FriendsScene.dtor = function(self)
    delete(self.anim_start);
    delete(self.anim_end);
    delete(self.mSocaityModule);
    delete(self.mFriendsModule);
    delete(self.mCityModule);
    delete(self.m_help_dialog);
end

FriendsScene.init = function(self)
--    Log.i("FriendsScene.init");
    FriendsScene.itemType = 1;
    --界面动画控件
    self.m_back_btn = self:findViewById(self.m_ctrls.back_btn);
    self.m_contentView = self:findViewById(self.m_ctrls.content_view);
    self.m_leaf_left = self:findViewById(self.m_ctrls.leaf_left);
    self.m_leaf_right = self:findViewById(self.m_ctrls.leaf_right);
    self.m_leaf_left:setFile("common/decoration/left_leaf.png")
    self.m_leaf_right:setFile("common/decoration/right_leaf.png")
    self.m_teapot_dec = self:findViewById(self.m_ctrls.teapot_dec);
    self.m_union_btn = self:findViewById(self.m_ctrls.union_btn);
    self.m_bottom_menu = self:findViewById(self.m_ctrls.bottom_menu);
    self.m_help_btn = self:findViewById(self.m_ctrls.help_btn);

    -- 通讯录有好友提示
    self.m_friend_btn = self.m_contentView:getChildByName("up_btn_view"):getChildByName("friend_btn");
    self.m_sociaty_btn = self.m_contentView:getChildByName("up_btn_view"):getChildByName("sociaty_btn");
    self.m_city_btn = self.m_contentView:getChildByName("up_btn_view"):getChildByName("city_btn");
    self:setBtnStatus();

    self.m_friend_btn:setOnClick(self,self.onFriendsBtnClick);
    self.m_sociaty_btn:setOnClick(self,self.onSociatyBtnClick);
    self.m_city_btn:setOnClick(self,self.onCityBtnClick);

    self.m_sociaty_view = self:findViewById(self.m_ctrls.sociaty_view);
    self.m_friend_view = self:findViewById(self.m_ctrls.friend_module_view);
    self.m_city_view = self:findViewById(self.m_ctrls.city_module_view);
    self.m_sociaty_view:setVisible(false);
    self.m_friend_view:setVisible(true);
    self.m_city_view:setVisible(false);
--    self.mSocaityModule = new(ChessSociatyModuleView,self)
    self.mFriendsModule = new(FriendsModuleView,self)
--    self.mCityModule = new(UnionModuleView,self)

end

--------------进入和退出界面动画相关---------------
FriendsScene.removeAnimProp = function(self)
    self.m_contentView:removeProp(1);
    self.m_back_btn:removeProp(1);
    self.m_leaf_left:removeProp(1);
    self.m_leaf_right:removeProp(1);
    self.m_union_btn:removeProp(1);
end

FriendsScene.setAnimItemEnVisible = function(self,ret)
    self.m_leaf_left:setVisible(ret);
    self.m_leaf_right:setVisible(ret);
end

FriendsScene.resumeAnimStart = function(self,lastStateObj,timer,changeStyle)
    self.m_anim_prop_need_remove = true;
    self:setAnimItemEnVisible(false);
    self:removeAnimProp();
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;

--    local w,h = self:getSize();
--    if not typeof(lastStateObj,OwnState) then
--        self.m_root:removeProp(1);
--        self.m_root:addPropTranslate(1,kAnimNormal,duration,waitTime,-w,0,nil,nil);
--    end
    delete(self.anim_start);
    self.anim_start = new(AnimInt,kAnimNormal,0,1,delay,-1);
    if self.anim_start then
        self.anim_start:setEvent(self,function()
            self:setAnimItemEnVisible(true);
            delete(self.anim_start);
        end);
    end

    self.m_union_btn:addPropTransparency(1,kAnimNormal,waitTime,delay,0,1);
    self.m_contentView:addPropTransparency(1,kAnimNormal,waitTime,delay,0,1);
    local lw,lh = self.m_leaf_left:getSize();
    self.m_leaf_left:addPropTranslate(1, kAnimNormal, waitTime, delay, -lw, 0, -10, 0);
    local tw,th = self.m_leaf_right:getSize();
    local anim = self.m_leaf_right:addPropTranslate(1, kAnimNormal, waitTime, delay, tw, 0, -10, 0);
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

FriendsScene.pauseAnimStart = function(self,newStateObj,timer,changeStyle)
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;

    local w,h = self:getSize();
--    local w,h = self:getSize();
--    if not typeof(newStateObj,OwnState) then
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
    self.m_union_btn:addPropTransparency(1,kAnimNormal,waitTime,-1,1,0);
    self.m_contentView:addPropTransparency(1,kAnimNormal,waitTime,-1,1,0);
    local lw,lh = self.m_leaf_left:getSize();
    self.m_leaf_left:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, -lw, 0, -10);
    local w,h = self.m_leaf_right:getSize();
    local anim = self.m_leaf_right:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, w, 0, -10);
    if anim then
        anim:setEvent(self,function()
            self:setAnimItemEnVisible(false);
        end);
    end
end

--[Comment]
--设置按钮新状态
function FriendsScene.setBtnStatus(self)
    self.m_friend_btn:setEnable(not self.friend_check)
    self.m_sociaty_btn:setEnable(not self.sociaty_check)
    self.m_city_btn:setEnable(not self.city_check)
end

--[Comment]
--点击按钮后切换状态
function FriendsScene.switchStatus(self)
    self:setBtnStatus();
    self:playSwitchAnim();
end

--FriendsScene.changeMyHead = function(self,data)
--    if data.iconType == -1 then
--        self.m_icon:setUrlImage(data.iconUrl);
--    else
--        self.m_icon:setFile(UserInfo.DEFAULT_ICON[data.iconType] or UserInfo.DEFAULT_ICON[1]);
--    end
--end


--function FriendsScene:closeShareDialog()
--    if self.m_share_invite_dialog and not self.m_share_invite_dialog.is_dismissing and self.m_share_invite_dialog:isShowing() then
--        self.m_share_invite_dialog:dismiss();
--        return true;
--    end
--    return false;
--end

--function FriendsScene:showNoLisTip(listType)
--    if not listType or listType < 1 or listType > 3 then 
--        self.m_no_friend_tip:setVisible(false);
--        return 
--    end
--    local msg = FriendsScene.DEFAULT_TIPS[listType];
--    self.m_no_friend_tip:setText(msg);
--    self.m_no_friend_tip:setVisible(true);
--end
------------更新头像相关----------------------------------
--FriendsScene.changeUserIconCall = function(self,data)
--    Log.i("changeUserIconCall");
--      --好友
--      self:changeListUserIconCall(data,self.m_friend_items,self.m_friendListData);
--      -- 关注
--      self:changeListUserIconCall(data,self.m_adapter_attention,self.m_attentionListData);
--      -- 粉丝
--      self:changeListUserIconCall(data,self.m_adapter_fans,self.m_fansListData);
--end

----------用户头像更新实现方法
--FriendsScene.changeListUserIconCall = function(self,data,items,datas)
----   Log.i("changeListUserIconCall");
----   if not datas then
----       return;
----   end
----   if data and items then
----       for i,v in pairs(items) do
----           if v.dataid == tonumber(data.what) and items:isHasView(i) then
----               local view = m_adapte:getTmpView(i);
----               view:updateUserIcon(data.ImageName);
----           end
----       end
----   end
--end

------------------------Click 事件--------------------------------

function FriendsScene.onHelpBtnClick(self)
    if not self.m_help_dialog then
        self.m_help_dialog = new(CommonHelpDialog)
        self.m_help_dialog:setMode(CommonHelpDialog.sociaty_mode)
    end 
    self.m_help_dialog:show()
end


function FriendsScene.onBack(self)
    self:requestCtrlCmd(FriendsController.s_cmds.back_action);
end

--[Comment]
--好友按钮点击事件
function FriendsScene.onFriendsBtnClick(self) -- 切换好友
    if self.friend_check == false then
        if not self.mFriendsModule then
            self.mFriendsModule = new(FriendsModuleView,self)
        end
        if self.mSocaityModule then
            self.mSocaityModule:pause()
        end
        if self.mCityModule then
            self.mCityModule:pause()
        end
        self.mFriendsModule:resume()
        self.friend_check = true
        self.sociaty_check = false
        self.city_check = false
        self:setBtnStatus();
        self.m_sociaty_view:setVisible(false);
        self.m_friend_view:setVisible(true);
        self.m_city_view:setVisible(false);
        if self.mFriendsModule then
            self.mFriendsModule:onSendUpdataNum()
        end
    end
end

--[Comment]
--棋社按钮点击事件
function FriendsScene.onSociatyBtnClick(self)
    FriendsData.getInstance():sendCheckUserData(UserInfo.getInstance():getUid())
    if self.sociaty_check == false then
        if not self.mSocaityModule then
            self.mSocaityModule = new(ChessSociatyModuleView,self)
        end
        if self.mFriendsModule then
            self.mFriendsModule:pause()
        end
        if self.mCityModule then
            self.mCityModule:pause()
        end
        self.mSocaityModule:resume()
        self.friend_check = false
        self.sociaty_check = true
        self.city_check = false
        self:setBtnStatus();
        self.m_sociaty_view:setVisible(true);
        self.m_friend_view:setVisible(false);
        self.m_city_view:setVisible(false);
        if self.mSocaityModule then
            self.mSocaityModule:switchView()
        end
    end
end

--[Comment]
--同城按钮点击事件
function FriendsScene.onCityBtnClick(self)
    if self.city_check == false then
        if not self.mCityModule then
            self.mCityModule = new(UnionModuleView,self)
        end
        if self.mSocaityModule then
            self.mSocaityModule:pause()
        end
        if self.mFriendsModule then
            self.mFriendsModule:pause()
        end
        self.mCityModule:resume()
        self.friend_check = false
        self.sociaty_check = false
        self.city_check = true
        self:setBtnStatus();
        self.m_sociaty_view:setVisible(false);
        self.m_friend_view:setVisible(false);
        self.m_city_view:setVisible(true);
        if self.mCityModule then
            self.mCityModule:getMember()
        end
    end
end
--------------------------config--------------------------------------
FriendsScene.s_controlConfig = 
{
    [FriendsScene.s_controls.back_btn]             = {"back_btn"};
    [FriendsScene.s_controls.leaf_left]            = {"leaf_left"};
    [FriendsScene.s_controls.leaf_right]           = {"leaf_right"};
    [FriendsScene.s_controls.teapot_dec]           = {"teapot_dec"};
    [FriendsScene.s_controls.content_view]         = {"content_view1"};
    [FriendsScene.s_controls.icon_mask]            = {"content_view","icon_frame","icon_mask"};
    [FriendsScene.s_controls.game_id]              = {"content_view","game_id"};
    [FriendsScene.s_controls.friends_btn]          = {"content_view","friend_btn"};
    [FriendsScene.s_controls.guanzhu_btn]          = {"content_view","guanzhu_btn"};
    [FriendsScene.s_controls.fans_btn]             = {"content_view","fans_btn"};
    [FriendsScene.s_controls.friend_view]          = {"content_view","friend_view"};
    [FriendsScene.s_controls.fans_view]            = {"content_view","fans_view"};
    [FriendsScene.s_controls.guanzhu_view]         = {"content_view","guanzhu_view"};
    [FriendsScene.s_controls.add_btn]              = {"content_view","add_btn"};
--    [FriendsScene.s_controls.invite_btn]           = {"content_view","invite_btn"};
    [FriendsScene.s_controls.add_btn_tip]          = {"content_view","add_btn","add_btn_txt","add_btn_tip"};
    [FriendsScene.s_controls.union_btn]            = {"union_btn"};
    [FriendsScene.s_controls.bottom_menu]          = {"bottom_menu"};

    [FriendsScene.s_controls.sociaty_view]         = {"content_view1","sociaty_view"};
    [FriendsScene.s_controls.friend_module_view]   = {"content_view1","friend_view"};
    [FriendsScene.s_controls.city_module_view]     = {"content_view1","city_view"};
    [FriendsScene.s_controls.help_btn]             = {"help_btn"};

}

FriendsScene.s_controlFuncMap = 
{
    [FriendsScene.s_controls.back_btn]              = FriendsScene.onBack;
--    [FriendsScene.s_controls.friends_btn]           = FriendsScene.onFriendsBtnClick;
--    [FriendsScene.s_controls.guanzhu_btn]           = FriendsScene.onFriendsattBtnClick;
--    [FriendsScene.s_controls.fans_btn]              = FriendsScene.onFriendsfansBtnClick;
--    [FriendsScene.s_controls.add_btn]               = FriendsScene.onAddFriendBtnClick;
--    [FriendsScene.s_controls.invite_btn]            = FriendsScene.onInviteFriendBtnClick;
--    [FriendsScene.s_controls.union_btn]             = FriendsScene.onUnionBtnClick;
        [FriendsScene.s_controls.help_btn]             = FriendsScene.onHelpBtnClick;
}

FriendsScene.s_cmdConfig =
{
--    [FriendsScene.s_cmds.change_userIcon]           = FriendsScene.changeUserIconCall;
--    [FriendsScene.s_cmds.changeFriendsList]         = FriendsScene.changeFriendsListCall;
--    [FriendsScene.s_cmds.changeFollowList]          = FriendsScene.changeFollowListCall;
--    [FriendsScene.s_cmds.changeFansList]            = FriendsScene.changeFansListCall;
--    [FriendsScene.s_cmds.changeFriendsData]         = FriendsScene.changeDataCall;
--    [FriendsScene.s_cmds.changeFriendstatus]        = FriendsScene.changeStatusCall;  
--    [FriendsScene.s_cmds.newfriendsNum]             = FriendsScene.changeNewfriendsNumCall;
--    [FriendsScene.s_cmds.friends_num]               = FriendsScene.changeFriendsNumCall;
--    [FriendsScene.s_cmds.follow_num]                = FriendsScene.changeFollowNumCall;
--    [FriendsScene.s_cmds.fans_num]                  = FriendsScene.changeFansNumCall;
--    [FriendsScene.s_cmds.change_myHead]             = FriendsScene.changeMyHead;
--    [FriendsScene.s_cmds.closeShareDialog]          = FriendsScene.closeShareDialog;
--    [FriendsScene.s_cmds.updata_union_dialog]       = FriendsScene.updataUnionDialog;
--    [FriendsScene.s_cmds.updata_union_member]       = FriendsScene.updataUnionMember;
}

--------------------label node---------------------------
--LabelItem = class(Node);
--LabelItem.s_w = 600;
--LabelItem.s_h = 36;

--LabelItem.ctor = function(self,typelabel)
--    self:setSize(LabelItem.s_w, LabelItem.s_h);
--    self.m_bg = new(Image,"common/decoration/line_4.png");
--    self.m_bg:setSize(527, 19);
--    self.m_bg:setAlign(kAlignCenter);
--    if typelabel == 1 then
--        self.m_text = new(Text,"在线",nil,nil,kAlignCenter,nil,36,100,100,100);
--    else
--        self.m_text = new(Text,"离线",nil,nil,kAlignCenter,nil,36,100,100,100);
--    end
--    self.m_text:setAlign(kAlignCenter);
--    self.m_bg:addChild(self.m_text);
--    self:addChild(self.m_bg);
--end


-------------------------private node-----------------------

--require(VIEW_PATH .. "friends_view_node");
--FriendsItem = class(Node)
--FriendsItem.s_w = 600;
--FriendsItem.s_h = 98;
--FriendsItem.s_friend_type = 1;
--FriendsItem.s_follow_type = 2;
--FriendsItem.s_fans_type = 3;
--FriendsItem.s_watch_room = 10;
--FriendsItem.s_challenge_room = 11;

--FriendsItem.ctor = function(self,dataid,itemType)
--    self.m_data = dataid;
--    if not dataid then return  end

--    self.datas = FriendsData.getInstance():getUserData(dataid);
--    self.status = FriendsData.getInstance():getUserStatus(dataid);

--    self.m_root_view = SceneLoader.load(friends_view_node);
--    self.m_root_view:setAlign(kAlignCenter);
--    self.m_node_view = self.m_root_view:getChildByName("node_view");
--    self:addChild(self.m_root_view);
--    self:setSize(self.m_root_view:getSize());
--    self.itemType = itemType;

--    --头像
--    self.m_vip_frame = self.m_node_view:getChildByName("icon_bg"):getChildByName("vip_frame");
--    local iconFile = UserInfo.DEFAULT_ICON[1]; --FriendsItem.idToIcon[0]; 
--    self.m_icon_mask = self.m_node_view:getChildByName("icon_bg"):getChildByName("icon_mask");
--    self.m_icon = new(Mask, iconFile, "common/background/head_mask_bg_86.png");
--    self.m_icon:setAlign(kAlignCenter);
--    self.m_icon:setSize(self.m_icon_mask:getSize());
--    self.m_icon_mask:addChild(self.m_icon);
--    if self.datas then
--        if self.datas.iconType == -1 then
--            self.m_icon:setUrlImage(self.datas.icon_url);
--        else
--            self.m_icon:setFile(UserInfo.DEFAULT_ICON[self.datas.iconType] or iconFile);
--        end
--    end
--    --段位
--    self.m_level = self.m_node_view:getChildByName("level");
--    self.m_level:setFile("common/icon/level_9.png");
--    --名字
--    self.m_title = self.m_node_view:getChildByName("name");
--    self.m_vip_logo = self.m_node_view:getChildByName("vip_logo");
--    --积分
--    self.m_contentText = self.m_node_view:getChildByName("score");
--    --状态
----    self.m_onlineRoomType = self.m_node_view:getChildByName("room_type");
----    self.m_onlineStatus = self.m_node_view:getChildByName("online_status");
--    self.m_offline = self.m_node_view:getChildByName("offline");
--    self.m_statusButton = self.m_node_view:getChildByName("button");
--    self.m_buttonText = self.m_statusButton:getChildByName("text");

--    --详细信息按钮
--    self.m_infoBtn = self.m_node_view:getChildByName("check_info");
--    self.m_infoBtn:setOnClick(self,self.onBtnClick);
--    self.m_infoBtn:setSrollOnClick();

--    --底部装饰线
--    self.m_bottomLine = self.m_node_view:getChildByName("item_line");
--    self.m_bottomLine:setVisible(true);

--    self:setOnlineStatus(self.status);
--    self:setItemUserInfo();
--    self:setVipIconStatus();
--end

--FriendsItem.dtor = function(self)
--    if self.m_statusButton then
--        delete(self.m_statusButton);
--        self.m_statusButton = nil;
--    end;
--end;


--FriendsItem.setOnBtnClick = function(self,obj,func)
--    self.m_btn_obj = obj;
--    self.m_btn_func = func;
--end

--FriendsItem.onBtnClick = function(self)
--    Log.d("FriendsItem.onBtnClick");
--    StateMachine.getInstance():pushState(States.FriendsInfo,StateMachine.STYPE_CUSTOM_WAIT,nil,tonumber(self.m_data));
--end

--FriendsItem.updateUserIcon = function(self,imageName)
--    Log.i("FriendsItem.updateUserIcon: "..(imageName or "null"));
--    if imageName then
--        self.m_icon:setFile(imageName);
--    end
--end

--FriendsItem.getUid = function(self)
--    return self.m_data or 0;
--end

--FriendsItem.updataItem = function(self,data)
--    self.datas = data;
--    if self.datas then
--        if self.datas.iconType == -1 then
--            self.m_icon:setUrlImage(self.datas.icon_url);
--        else
--            self.m_icon:setFile(UserInfo.DEFAULT_ICON[self.datas.iconType] or UserInfo.DEFAULT_ICON[1]);
--        end
--    end

--    self.m_level:setFile("common/icon/level_"..10 - UserInfo.getInstance():getDanGradingLevelByScore(tonumber(self.datas.score))..".png");
--    self.m_title:setText(self.datas.mnick);
--    self.m_contentText:setText("积分:"..self.datas.score);
--end

--FriendsItem.setBottomLine = function(self,ret)
--    if not ret then
--        self.m_bottomLine:setVisible(ret);
--    end
--end

----[Comment]
----设置item中联网状态，status: 好友状态数据
--function FriendsItem.setOnlineStatus(self,status)
--    self.status = status;
--    --离线状态
--    if not status or status.hallid <=0 then
--        self.m_offline:setText("离线",nil,nil,125,80,65);
--        self.m_offline:setPos(400,46);
--        self.m_statusButton:setVisible(false);
--        self.m_icon:setGray(true);
--        return
--    end

--    --item类型
--    if not self.itemType or self.itemType > 1 then
--        self.m_offline:setPos(400,46);
--        self.m_statusButton:setVisible(false);
--    else
--        self.m_offline:setPos(299,46);
--        self.m_statusButton:setVisible(true);
--    end

--    --在线状态
--    self.m_icon:setGray(false);
--    if status.tid and status.tid >0 then
--        local strname = FriendsScene.onGetScreenings(status.level);
--        self.m_offline:setText(strname or "游戏中",nil,nil,125,80,65); 
--        self.m_buttonText:setText("观战");
--        self.m_statusButton:setFile({"common/button/dialog_btn_7_normal.png","common/button/dialog_btn_7_press.png"});
--        self.m_statusButton:setOnClick(self,function()
--            self:gotoRoom(FriendsItem.s_watch_room,status.tid);
--        end);
--    else
--        self.m_offline:setText("闲逛中",nil,nil,25,115,40);
--        self.m_buttonText:setText("挑战");
--        self.m_statusButton:setFile({"common/button/dialog_btn_3_normal.png","common/button/dialog_btn_3_press.png"});
--        self.m_statusButton:setOnClick(self,function()
--            self:gotoRoom(FriendsItem.s_challenge_room);
--        end);
--    end
--end

----[Comment]
----设置item中，名字和积分 
--function FriendsItem.setItemUserInfo(self)
--    --存在好友数据
--    if self.datas then
--        if self.datas.mnick then
--            local lenth = string.lenutf8(GameString.convert2UTF8(self.datas.mnick));
--            if lenth > 10 then    
--                local str  = string.subutf8(self.datas.mnick,1,7).."...";
--                self.m_title.setText(self.m_title,str);
--            else
--                self.m_title.setText(self.m_title,self.datas.mnick);    
--            end
--        else
--            self.m_title.setText(self.m_title,self.m_data or "博雅象棋");
--        end
--        local  str = "积分:"..self.datas.score;
--        self.m_contentText.setText(self.m_contentText,str);  
--        self.m_level:setFile("common/icon/level_"..10 - UserInfo.getInstance():getDanGradingLevelByScore(tonumber(self.datas.score))..".png");  
--        return
--    end
--    --好友数据为空
--    local  str = "积分:0";
--    self.m_title.setText(self.m_title,self.m_data or "博雅象棋");
--    self.m_contentText.setText(self.m_contentText,str);  

--end

----[Comment]
----设置item中，vip头像
--function FriendsItem.setVipIconStatus(self)
--    if self.datas and self.datas.my_set then
--        local frameRes = UserSetInfo.getInstance():getFrameRes(self.datas.my_set.picture_frame or "sys");
--        local fw,fh = self.m_vip_frame:getSize();
--        if frameRes.frame_res then
--            self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
--        end
--        self.m_vip_frame:setVisible(frameRes.visible);
--    end
--    local vw,vh = self.m_vip_logo:getSize();
--    if self.datas and self.datas.is_vip == 1 then
--        self.m_title:setPos(130+vw,25);
----        self.m_vip_frame:setVisible(true);
--        self.m_vip_logo:setVisible(true);
--    else
--        self.m_title:setPos(130,25);
----        self.m_vip_frame:setVisible(false);
--        self.m_vip_logo:setVisible(false);
--    end
--end

--function FriendsItem.setOnClickCallBack(self,obj,func)
--    self.callBackObj = obj;
--    self.callBackFunc = func;
--end

----[Comment]
----跳转房间，roomType: 好友游戏房间类型，tid: 房间桌子号
--function FriendsItem.gotoRoom(self,roomType,tid) 
--    if self.callBackObj and self.callBackFunc then
--        if not roomType then return end
--        local data = self.datas;
--        data.tid = tid;
--        self.callBackFunc(self.callBackObj,roomType,data);
--    end
--end

--function FriendsItem.refreshStatus(self)
--    local status = FriendsData.getInstance():getUserStatus(self.m_data);
--    self:setOnlineStatus(status);
--end