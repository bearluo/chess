--region NewFile_1.lua
--Author : FordFan
--Date   : 2015/11/13
--添加好友弹窗
--endregion

require(VIEW_PATH .. "addfriends_view");
require(BASE_PATH .. "chessDialogScene");

AddFriendDialog = class(ChessDialogScene,false);

function AddFriendDialog.ctor(self)
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
    self.add_phone_friend:setOnClick(self,self.onGetPhoneFriend);
    self.invite_friend_btn = self.m_bg:getChildByName("invite_btn");

    self.friendsView = self.m_bg:getChildByName("view_frame"):getChildByName("friends_list_view");
    
    self.search_edit_text:setHintText("请输入昵称或游戏ID",165,145,125);
    local edit_w,edit_h = self.search_edit_text:getSize();
    local edit_x,edit_y = self.search_edit_text:getPos();
    self.search_edit_text:setClip(edit_x,edit_y,edit_w,edit_h);

    if "ios"==System.getPlatform() then
	    if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
	        self.add_phone_friend:setVisible(true);
            self.invite_friend_btn:setVisible(true);
	    else
	        self.add_phone_friend:setVisible(false);
            self.invite_friend_btn:setVisible(false);
	    end;
    end;

    self.search_btn:setOnClick(self,self.onSearch);
    self.invite_friend_btn:setOnClick(self,self.showShareDialog);

    self.m_default_text_view = self.m_bg:getChildByName("view_frame"):getChildByName("TextView1");
    self.m_default_text_view:setVisible(false)
    self:setShieldClick(self,self.dismiss);
    self.mDialogAnim = AnimDialogFactory.createMoveUpAnim(self)
end 

function AddFriendDialog.dtor(self)
    delete(self.FriendsloadingDialog);
    delete(self.m_chioce_dialog);
    delete(self.m_bangdinDialog);
    delete(self.m_exit_dialog);
    delete(self.commonShareDialog);
    self.m_root_view = nil;
    self.mDialogAnim.stopAnim()
    delete(RelationshipDialog.m_up_user_info_dialog)
end

function AddFriendDialog.isShowing(self)
    return self:getVisible();
end

function AddFriendDialog.show(self)--,data)
    self.super.show(self,self.mDialogAnim.showAnim);

    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
    EventDispatcher.getInstance():register(Event.Call,self,self.onNativeCallDone);
    AddFriendDialogController.getInstance():setHandler(self)
    AddFriendDialogController.getInstance():getNewRecommendList();
    self:initData(self._list_data);
end

function AddFriendDialog.initData(self, datas)
    if datas and next(datas) then
        self:updateUserList(datas);
    else
    	self.m_default_text_view:setVisible(true);
    	self.friendsView:setVisible(false);
        return
    end
end

function AddFriendDialog.dismiss(self)
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeCallDone);
    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpRequestsCallBack);
    AddFriendDialogController.releaseInstance();
    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
end

--AddFriendDialog.onHttpRequestsCallBack = function(self,command,...)
--    Log.i("AddFriendDialog.onHttpRequestsCallBack");
--	if self.s_httpRequestsCallBackFuncMap[command] then
--     	self.s_httpRequestsCallBackFuncMap[command](self,...);
--	end 
--end

--AddFriendDialog.onNativeCallDone = function(self ,param , ...)
--	if self.s_nativeEventFuncMap[param] then
--		self.s_nativeEventFuncMap[param](self,...);
--	end
--end

--native事件回调监听
--AddFriendDialog.onUpdatePhoneFriends = function(self,flag,json_data)
--    if not json_data then return end;
--    self:loadingTileExit();
--    if not flag or not json_data or not json_data.ret then 
--        ChessToastManager.getInstance():show("获取通信录失败!");
--        return;
--    end
--    local info = {};
--    info.phone_list = json_data.ret:get_value();
--    local str = md5_string(info.phone_list);
--    local strmd5 = kGameCacheData:getString(GameCacheData.TONG_XUN_LUMD5);
--    if strmd5~= nil then
--        if strmd5 ~= str then
--            Log.i("ZY onUpdatePhoneFriends1");
--            kGameCacheData:saveString(GameCacheData.TONG_XUN_LUMD5,str);
--            HttpModule.getInstance():execute(HttpModule.s_cmds.mailListCll,info,"查询中...");
--        else
--            ChessToastManager.getInstance():show("没有发现新的手机好友");
--        end
--    else
--        Log.i("ZY onUpdatePhoneFriends3");
--        kGameCacheData:saveString(GameCacheData.TONG_XUN_LUMD5,str);
--        HttpModule.getInstance():execute(HttpModule.s_cmds.mailListCll,info,"查询中");
--    end

--end
--------------------cliak---------------------------------
require("dialog/maillist_dialog");
require("dialog/bangdin_dialog");
--[Comment]
--添加手机好友按钮点击事件
--获取手机好友
function AddFriendDialog.onGetPhoneFriend(self) 
    local sid = UserInfo.getInstance():findBindAccountBySid(1);
    if sid ~= nil then
        if not self.m_chioce_dialog then
	        self.m_chioce_dialog = new(MailListDialog);
        end
        self.m_chioce_dialog:setPositiveListener(self,self.onFriendsAddClickCall);
        self.m_chioce_dialog:show(self.m_root_view);
    else -- 绑定手机
        ChessToastManager.getInstance():showSingle("请先绑定手机");
        
        if self.m_bangdinDialog then
            delete(self.m_bangdinDialog);
            self.m_bangdinDialog = nil;
        end
        self.m_bangdinDialog = new(BangDinDialog);
        self.m_bangdinDialog:setHandler(self);
        self.m_bangdinDialog:show();
    end
end

--[Comment]
--搜索按钮点击事件
function AddFriendDialog.onSearch(self)
    local strdata = self.search_edit_text:getText();
    AddFriendDialogController.getInstance():searchUser(strdata);
end

--[Comment]
--查询用户后更新列表用户，list: 用户信息
function AddFriendDialog.updateUserList(self,list)
    if not list or type(list) ~= "table" or table.maxn(list) == 0 then
        self.m_default_text_view:setVisible(true);
        self.friendsView:setAdapter();
        return;
    end
    self._list_data = list;
    self.friendsView:setVisible(true);
    self.m_default_text_view:setVisible(false);
--    delete(self.m_adapter);
--    self.friendsView:removeAllChildren(true);
    --测试，记得删掉
    --NoviceBootProxy.getInstance():clearGuideTipViewShowTime(NoviceBootProxy.s_constant.FOLLOW_EACH_OTHER)
    self.m_adapter = new(CacheAdapter,AddFriendsItem,list);
    self.friendsView:setAdapter(self.m_adapter);
    --提高有新手引导的item的层级
    self:showFollowEachOtherGuideTip()
end

require("dialog/common_share_dialog");
--[Comment]
--显示分享弹窗
function AddFriendDialog.showShareDialog(self)
    local m_qr_code_url,m_qr_download_url = UserInfo.getInstance():getGameShareUrl();
    local tab = {};
    if not m_qr_download_url then return end
    tab.url = m_qr_download_url;
    tab.title = "博雅中国象棋";
    tab.description = "我的游戏id是" .. UserInfo.getInstance():getUid() .. "，快来和我一起对弈吧";
    if not self.commonShareDialog then
        self.commonShareDialog = new(CommonShareDialog);
    end
    self.commonShareDialog:setShareDate(tab,"game_share");
    self.commonShareDialog:show();
end

--[Comment]
--上传通讯录
function AddFriendDialog.onFriendsAddClickCall(self)
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

--[Comment]
--关闭loading弹窗
function AddFriendDialog.loadingTileExit(self)
    if self.FriendsloadingDialog~= nil then
        self.FriendsloadingDialog:dismiss();
    end
end


--[Comment]
--更新列表关注状态
--info: server返回信息
function AddFriendDialog.updataFollowStatus(self,info)
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

--[Comment]
--更新item 关注状态
--view: item info:用户信息
function AddFriendDialog.changeFriendsView(self,view,info)
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

--提升需要显示新手引导的item的层级
function AddFriendDialog.showFollowEachOtherGuideTip(self)
    if self.m_adapter then 
        if self.m_adapter:getViews() then 
            for i,v in pairs(self.m_adapter:getViews()) do
                if v:isNeedGuideTip() then 
                    NoviceBootProxy.getInstance():clearGuideTipViewShowTime(NoviceBootProxy.s_constant.FOLLOW_EACH_OTHER)
                    self.m_adapter:updateData(i,self.m_adapter:getData()[i])
                end 
            end 
        end 
    end 
end 

function AddFriendDialog.showUserInfoDialog(uid)
    uid = tonumber(uid)
    if not uid then return end
    delete(RelationshipDialog.m_up_user_info_dialog)
    RelationshipDialog.m_up_user_info_dialog = new(UserInfoDialog2);

    if UserInfo.getInstance():getUid() == uid then
        RelationshipDialog.m_up_user_info_dialog:setShowType(UserInfoDialog2.SHOW_TYPE.OTHER)
    else
        RelationshipDialog.m_up_user_info_dialog:setShowType(UserInfoDialog2.SHOW_TYPE.UNION)
    end

    FriendsData.getInstance():sendCheckUserData(uid)
    RelationshipDialog.m_up_user_info_dialog:show(nil,uid);
end

----AddFriendDialog.s_nativeEventFuncMap = {
--    [kGetPhoneNumByPhoneAndSIM] = AddFriendDialog.onUpdatePhoneFriends;
--}

--AddFriendDialog.s_httpRequestsCallBackFuncMap  = {
    
--    [HttpModule.s_cmds.mailListCll]   = AddFriendDialog.onmailListResponse;
--    [HttpModule.s_cmds.searchFriends] = AddFriendDialog.onGetSearchFriendsResponse;
--    [HttpModule.s_cmds.bindUid]       = AddFriendDialog.onBindUidResponse;
--};

----------------private node---------------------------
AddFriendsItem = class(Node)
AddFriendsItem.s_w = 618;
AddFriendsItem.s_h = 131;

--0,陌生人,=1粉丝，=2关注，=3好友
--我跟其他棋友的关系,跟后台定义好的数值关系统一
AddFriendsItem.relationKind = {
    STRANGER = 0;  --我没有关注对方，对方也没关注我
    FOLLOW = 2;    --我关注了对方，对方没关注我
    FRIEND = 3;  --我关注了对方，对方也关注了我
    FANS = 1;    --我没关注对方，对方关注了我
}
AddFriendsItem.addTitleContent = {
    FOLLOWED = "已关注";
    NOT_FOLLOW = "关注";
    FOLLOW_EACH_OTHER = "互相关注";
}
AddFriendsItem.FOLLOW_EACH_OTHER_GUIDE_TIP =  "对方已关注您，#c4bff4b互相#l关注#n即可成好友！"
--AddFriendsItem.idToIcon = UserInfo.DEFAULT_ICON;
require(VIEW_PATH .."addfriend_node");
function AddFriendsItem.ctor(self,data)
    if next(data) == nil then   
        return;
    end
    self.datas = data;

    
    self.m_root_view = SceneLoader.load(addfriend_node);
    self.m_root_view:setAlign(kAlignCenter);
    self:setSize(AddFriendsItem.s_w,AddFriendsItem.s_h);
    self:setEventTouch(self,self.onEventTouch)
    self:addChild(self.m_root_view);
    self.m_icon_mask = self.m_root_view:getChildByName("icon_bg"):getChildByName("icon_mask");
    self.m_vip_frame = self.m_root_view:getChildByName("icon_bg"):getChildByName("vip_frame");
    self.m_vip_logo = self.m_root_view:getChildByName("vip_logo");
    self.m_fans_tip = self.m_root_view:getChildByName("fans_tip");
    --头像
    local iconFile = UserInfo.DEFAULT_ICON[1];
    self.m_icon = new(Mask,iconFile,"common/background/head_mask_bg_86.png");
    if self.datas then
        if self.datas.iconType == -1 then
            self.m_icon:setUrlImage(self.datas.icon_url);
        else
            iconFile = UserInfo.DEFAULT_ICON[self.datas.iconType] or iconFile;
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

    --新手引导的标识,true表示需要新手引导，false为不需要，默认是不需要的
    self.mGuideTipStatus = false  

    --关注按钮
    self.m_add = self.m_root_view:getChildByName("follow")
    self.m_add:setOnClick(self,self.onBtnClick);
    self.m_add_handler = self.m_root_view:getChildByName("follow_handler")
    self.m_addtile = self.m_root_view:getChildByName("follow"):getChildByName("text");
    local kind = self:friendsMarkCall(tonumber(self.datas.mid));  
    self:setAddTitle(kind)
    self:isShowFansTip(kind)
    
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
end

function AddFriendsItem.dtor(self)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.FOLLOW_EACH_OTHER)
end 
--[Comment]
--更新用户头像
--function AddFriendsItem.updateUserIcon(self,data)
--    if tonumber(data.what) ~= self.datas.mid then return false end
--    self.m_icon:setFile(data.ImageName);
--end

--function AddFriendsItem.setOnBtnClick(self,obj,func)
--    self.m_btn_obj = obj;
--    self.m_btn_func = func;
--end

--[Comment]
--关注按钮点击事件
function AddFriendsItem.onBtnClick(self)
    
    local info = {};
    if self.guanzhu == true then
        AddFriendDialogController.getInstance():onSendFollow(1,self.datas.mid);
    else
       if not self.m_exit_dialog then
		   self.m_exit_dialog = new(ChioceDialog);
            self.m_exit_dialog:setMaskDialog(true)
	   end
       self.m_exit_dialog:setMessage("是否取消关注?");
       self.m_exit_dialog:setPositiveListener(self,function()
            AddFriendDialogController.getInstance():onSendFollow(0,self.datas.mid);
       end);
	   self.m_exit_dialog:show(self.m_root_view);
    end
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.FOLLOW_EACH_OTHER)
end

--function AddFriendsItem.onExitGuanzhuClickCall(self) --取消关注
--   Log.d("ZY onExitGuanzhuClickCall");
--   local info = {};
--   info.uid = UserInfo.getInstance():getUid();
--   info.target_uid = self.datas.mid;
--   info.op = 0;
--   OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_ADD_FLLOW,info);
--end

--[Comment]
--查询用户关系
--friendsid: 好友id
function AddFriendsItem.friendsMarkCall(self,friendsid)
   local friend = FriendsData.getInstance():isYourFriend(friendsid);
   local follow = FriendsData.getInstance():isYourFollow(friendsid);
   local fans = FriendsData.getInstance():isYourFans(friendsid);

   if friend ~= -1 then --好友
        return AddFriendsItem.relationKind.FRIEND
   elseif follow ~= -1 then --已关注
        return AddFriendsItem.relationKind.FOLLOW
   elseif fans ~= -1 then --粉丝
        --self.mGuideTipStatus = true 
        return AddFriendsItem.relationKind.FANS
   else -- 关注
        return AddFriendsItem.relationKind.STRANGER
   end
end

function AddFriendsItem:onEventTouch(finger_action,x,y,drawing_id_first,drawing_id_current)
    if not self.datas or not self.datas.mid then return end
    if kFingerDown == finger_action then
        self.mDownX,self.mDownY = x,y
    end

    if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
        if math.abs(self.mDownY-y) < 20 then
            AddFriendDialog.showUserInfoDialog(self.datas.mid)
        end
    end
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.FOLLOW_EACH_OTHER)
end

--设置关注按钮的显示内容，设置是否需要关注，true为需要关注，false为已关注
function AddFriendsItem.setAddTitle(self,kind)
    if kind == AddFriendsItem.relationKind.STRANGER then 
        self.m_addtile:setText(AddFriendsItem.addTitleContent.NOT_FOLLOW);
        self.guanzhu = true;
    elseif kind == AddFriendsItem.relationKind.FOLLOW then 
        self.m_addtile:setText(AddFriendsItem.addTitleContent.FOLLOWED);
        self.guanzhu = false;
    elseif kind == AddFriendsItem.relationKind.FANS then 
        self.m_addtile:setText(AddFriendsItem.addTitleContent.NOT_FOLLOW);
        self.guanzhu = true
        --加入首次互相关注的新手引导
        self:showFollowEachOtherGuidTip()
    else 
        self.m_addtile:setText(AddFriendsItem.addTitleContent.FOLLOW_EACH_OTHER);
        self.guanzhu = false;
    end 
    --self:showFollowEachOtherGuidTip()
end 

function AddFriendsItem.isShowFansTip(self,kind)
    if kind == AddFriendsItem.relationKind.FANS then 
        self.m_fans_tip:setVisible(true)
    else 
        self.m_fans_tip:setVisible(false)
    end 
end 
--互相关注的新手引导
function AddFriendsItem.showFollowEachOtherGuidTip(self)
    if NoviceBootProxy.getInstance():isFirstShow(NoviceBootProxy.s_constant.FOLLOW_EACH_OTHER) then 
        local guideTip = NoviceBootProxy.getInstance():getGuideTipView(NoviceBootProxy.s_constant.FOLLOW_EACH_OTHER)
        guideTip:setAlign(kAlignCenter)    
        local w,h = self.m_add:getSize()
        guideTip:setTipSize(w+20,h+20)
        guideTip:startAnim()
        guideTip:setBottomTipText(AddFriendsItem.FOLLOW_EACH_OTHER_GUIDE_TIP,-80,110,250,50,80)
        self.m_add_handler:addChild(guideTip)
        self.mGuideTipStatus = true 
        NoviceBootProxy.getInstance():setGuideTipViewShowTime(NoviceBootProxy.s_constant.FOLLOW_EACH_OTHER)
    end 
end 

function AddFriendsItem.isNeedGuideTip(self)
    return self.mGuideTipStatus
end 
---------------------------------controller------------------------------------

AddFriendDialogController = class();

function AddFriendDialogController.getInstance()
    if not AddFriendDialogController.s_instance then
        AddFriendDialogController.s_instance = new(AddFriendDialogController);
    end
    return AddFriendDialogController.s_instance;
end

function AddFriendDialogController.releaseInstance()
	delete(AddFriendDialogController.s_instance);
	AddFriendDialogController.s_instance = nil;
end

function AddFriendDialogController.ctor(self)
    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
    EventDispatcher.getInstance():register(Event.Call,self,self.onNativeCallDone);
end

function AddFriendDialogController.dtor(self)
    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpRequestsCallBack);
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeCallDone);
end

function AddFriendDialogController.setHandler(self,handler)
    self.m_handler = handler
end

--[Comment]
--获得用户推荐
function AddFriendDialogController.getNewRecommendList(self)
    HttpModule.getInstance():execute(HttpModule.s_cmds.recommendMailListCll)--,nil,"加载中");
end

--[Comment]
--查找用户 data: 输入框内的内容
function AddFriendDialogController.searchUser(self,data)
    local post_data = {};
	post_data.keyword = data;
    HttpModule.getInstance():execute(HttpModule.s_cmds.searchFriends,post_data,"搜索中");
end

--[Comment]
--查找用户 status: 关注状态 1-加关注 0-取消关注
--opid;关注人id  
function AddFriendDialogController.onSendFollow(self,status,opid)
    if not status then 
        ChessToastManager.getInstance():showSingle("操作失败！");
    end
    local info = {};
    info.uid = UserInfo.getInstance():getUid();
    info.target_uid = opid;
    info.op = status;
    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_ADD_FLLOW,info);
end

--[Comment]
--用户查询回调 isSuccess: 回调状态   message: 回调信息
function AddFriendDialogController.onGetSearchFriendsResponse(self,isSuccess,message)
    if not isSuccess then
        return;
    end
    local message = message.data;
    if not message.list or #message.list < 1 then 
        ChessToastManager.getInstance():showSingle("用户ID不存在！");
        return
    end

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
        if self.m_handler then
            self.m_handler:updateUserList(ranks);
        end
    else
        ChessToastManager.getInstance():showSingle("用户ID不存在！");
    end
end

--[Comment]
--手机好友回调 isSuccess: 回调状态   message: 回调信息
function AddFriendDialogController.onmailListResponse(self,isSuccess,message)
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
        if self.m_handler then
            self.m_handler:updateUserList(ranks);
        end
    else
        ChessToastManager.getInstance():showSingle("没有发现新的手机好友");
    end
end

--[Comment]
--native事件 获取通讯录回调监听
function AddFriendDialogController.onUpdatePhoneFriends(self,flag,json_data)
    if not json_data then return end;
    if self.m_handler then
        self.m_handler:loadingTileExit();
    end
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

--[Comment]
--native事件 更新关注状态
--info: server回调 关注状态信息
function AddFriendDialogController.onRecvServerMsgFollowSuccess(self,info)
    if info.ret ~= 0 then
        ChessToastManager.getInstance():show("关注失败!");
        return ;
    end
    self.m_handler:updataFollowStatus(info);
end

--[Comment]
--获得用户推荐回调
function AddFriendDialogController.getrecommendMailListCallResponse(self,isSuccess,message)
    if not isSuccess then
        Log.d("ZY getrecommendMailListCallResponse false");
        return ;
    end

    local data = message.data;
	if not data then
		print_string("not data");
		return
	end

    local ranks  = {};
    ranks.total = data.total_no_check:get_value();
    ranks.list = {};
	for _,value in pairs(data.list) do 
		local user = {};
        if type(value) == "table" then
		    user.drawtimes     = tonumber(value.drawtimes:get_value()) or 0;
            user.mid      = tonumber(value.mid:get_value()) or 0;
            user.score    = tonumber(value.score:get_value()) or 0;
            user.losetimes= tonumber(value.losetimes:get_value()) or 0;
            user.iconType     = value.iconType:get_value();
            user.icon_url = value.icon_url:get_value() or "";
            user.mnick     = ToolKit.subString(value.mnick:get_value(),16);
            user.mactivetime  = tonumber(value.mactivetime:get_value()) or 0;
            user.wintimes = tonumber(value.wintimes:get_value()) or 0;
		    user.money    = value.money:get_value();
		    user.rank    = value.rank:get_value();
            user.concat_name = value.concat_name:get_value() or "";
		    table.insert(ranks.list,user);
        end
	end

    if #ranks >= 0 then
        if self.m_handler then
            self.m_handler:updateUserList(ranks.list);
        end
    end
end


function AddFriendDialogController.onHttpRequestsCallBack(self,cmd, ...)
    Log.i("AddFriendDialog.onHttpRequestsCallBack");
	if self.s_httpRequestsCallBackFuncMap[cmd] then
     	self.s_httpRequestsCallBackFuncMap[cmd](self,...);
	end 
end

function AddFriendDialogController.onNativeCallDone(self ,param , ...)
	if self.s_nativeEventFuncMap[param] then
		self.s_nativeEventFuncMap[param](self,...);
	end
end

AddFriendDialogController.s_httpRequestsCallBackFuncMap  = {
    
    [HttpModule.s_cmds.mailListCll]          = AddFriendDialogController.onmailListResponse;
    [HttpModule.s_cmds.searchFriends]        = AddFriendDialogController.onGetSearchFriendsResponse;
    [HttpModule.s_cmds.recommendMailListCll] = AddFriendDialogController.getrecommendMailListCallResponse;
};

AddFriendDialogController.s_nativeEventFuncMap = {
    [kGetPhoneNumByPhoneAndSIM]              = AddFriendDialogController.onUpdatePhoneFriends;
    [kFriend_FollowCallBack]                 = AddFriendDialogController.onRecvServerMsgFollowSuccess;
}