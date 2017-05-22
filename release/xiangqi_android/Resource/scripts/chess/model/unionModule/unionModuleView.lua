--UnionModuleView.lua
--Date 2016.9.3
--同城模块
--endregion
require("dialog/city_locate_pop_dialog")
require("dialog/user_info_dialog2")
require(VIEW_PATH.."union_module_view")

UnionModuleView = class()

UnionModuleView.s_event = {
    UpdateView = EventDispatcher.getInstance():getUserEvent();
}

UnionModuleView.s_cmds = 
{
    recommendCallBack    = 1;
    unionMemberCallBack  = 2;
}

UnionModuleView.LIRO_ANIM_TIME = 300;
UnionModuleView.LORI_ANIM_TIME = 300;

function UnionModuleView.ctor(self,scene)
    self.mScene = scene
    self.m_root_node = SceneLoader.load(union_module_view)
    self.mScene.m_city_view:addChild(self.m_root_node);

    self.friends_list_check = true;
    self.attention_list_check = false;
    self.fans_list_check = false;

    self:initView()
end

function UnionModuleView.resume(self)
    EventDispatcher.getInstance():register(UnionModuleView.s_event.UpdateView,self,self.refreshView);
    EventDispatcher.getInstance():register(Event.Call,self,self.onNativeCallDone);
end

function UnionModuleView.pause(self)
    EventDispatcher.getInstance():unregister(UnionModuleView.s_event.UpdateView,self,self.refreshView);
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeCallDone);
end

function UnionModuleView.onNativeCallDone(self ,param , ...)
	if self.s_nativeEventFuncMap[param] then
		self.s_nativeEventFuncMap[param](self,...);
	end
end

--[Comment]
--更新界面
function UnionModuleView.refreshView(self,cmd, ...)
    if not self.s_cmdConfig[cmd] then
		return;
	end

	return self.s_cmdConfig[cmd](self,...)
end

function UnionModuleView.dtor(self)

end

------------------anim ------------------------
-- 左出右进动画
function UnionModuleView.leftOutRightIn(self,leftView, rightView,callBackFun)
    leftView:setVisible(true);
    local leftW,leftH = leftView:getSize();
    -- leftSlide
    local leftAnim = leftView:addPropTranslate(0,kAnimNormal,UnionModuleView.LORI_ANIM_TIME,-1,0,-leftW,0,0);
    if not leftAnim then return end;
    leftAnim:setEvent(nil, function() 
        leftView:removeProp(0);
    end);
    -- leftTransparency
    local leftTransparency = leftView:addPropTransparency(1,kAnimNormal,UnionModuleView.LORI_ANIM_TIME,0,0.5,0);
    if not leftTransparency then return end;
    leftTransparency:setEvent(nil, function() 
        leftView:setVisible(false);
        leftView:removeProp(1);
    end);
    -- rightTransparency
    rightView:setVisible(true);
    local rightTransparency = rightView:addPropTransparency(1,kAnimNormal,UnionModuleView.LORI_ANIM_TIME-100,100,0,1);
    if not rightTransparency then return end;
    rightTransparency:setEvent(nil, function() 
        rightView:removeProp(1);
         if callBackFun then
            callBackFun(self);
        end;
    end);
end;

-- 左进右出动画
function UnionModuleView.leftInRightOut(self,leftView, rightView,callBackFun)
    -- leftSlide
    leftView:setVisible(true);
    local leftW,leftH = leftView:getSize();
    local leftAnim = leftView:addPropTranslate(1,kAnimNormal,UnionModuleView.LIRO_ANIM_TIME,0,-leftW,0,nil,nil);
    if not leftAnim then return end;
    leftAnim:setEvent(nil, function() 
         leftView:removeProp(1);  
         if callBackFun then
            callBackFun(self);
         end;     
    end)
    -- leftTransparency
    local leftTransparency = leftView:addPropTransparency(2,kAnimNormal,UnionModuleView.LORI_ANIM_TIME,0,0,1);
    if not leftTransparency then return end;
    leftTransparency:setEvent(nil, function() 
        leftView:removeProp(2);
    end);
    -- rightTransparency
    rightView:setVisible(true);
    local rightTransparency = rightView:addPropTransparency(2,kAnimNormal,UnionModuleView.LORI_ANIM_TIME-100,100,0.5,0);
    if not rightTransparency then return end;
    rightTransparency:setEvent(nil, function() 
        rightView:setVisible(false);
        rightView:removeProp(2);
    end);
end;

function UnionModuleView.initView(self)
    self.m_union_view = self.m_root_node:getChildByName("union_view");
    self.m_member_view = self.m_root_node:getChildByName("member_view");

    self.m_union_name = self.m_union_view:getChildByName("name_bg"):getChildByName("name");
    self.m_union_member_num = self.m_union_view:getChildByName("member_bg"):getChildByName("member_num");
    self.m_union_icon_text = self.m_union_view:getChildByName("icon_frame"):getChildByName("text");
    self.m_content_bg = self.m_union_view:getChildByName("line_bg");
    self.m_text_view = self.m_content_bg:getChildByName("prompt_textview");
    self.m_join_union_btn = self.m_content_bg:getChildByName("experience_btn");
    self.m_join_union_btn:setOnClick(self,self.joinUnion);
    self.m_show_view = self.m_content_bg:getChildByName("view"); 
    self.m_member_btn = self.m_show_view:getChildByName("member_btn");
    self.m_member_btn:setOnClick(self,self.checkMember);
    self.m_recommend_view = self.m_show_view:getChildByName("recommend_view");

    self.m_union_task = self.m_content_bg:getChildByName("union_task");
    
    local msg = "同城所有玩家共同完成同城任务，可以按完成的等级情况获得奖励。即将开放，敬请期待！";
    self.m_text = new(RichText,msg,578,160,kAlignTopLeft,nil,36,80,80,80,true,5);
    self.m_text:setAlign(kAlignCenter);
    self.m_text:setPos(6,6);
    self.m_union_task:addChild(self.m_text);

    self.m_change_btn = self.m_show_view:getChildByName("change_button");
    self.m_change_btn:setOnClick(self,self.getMember);

    self.m_member_back = self.m_member_view:getChildByName("back_btn");
    self.m_member_back:setOnClick(self,self.onBackUnion);

    self.m_member_bg = self.m_member_view:getChildByName("member_bg");
    self.m_memberListView = new(ListView,0,0);
    self.m_memberListView:setAlign(kAlignCenter);
    self.m_memberListView:setDirection(kVertical);
    self.m_memberListView:setSize(self.m_member_bg:getSize());
    self.m_member_bg:addChild(self.m_memberListView);

    self.m_show_view:setVisible(false);
    self:updateCityView()
end

--加入联盟（选择城市）
function UnionModuleView.joinUnion(self)
    if not self.m_city_locate_dialog then
        self.m_city_locate_dialog = new(CityLocatePopDialog);
    end
    self.m_city_locate_dialog:setConfirmCallBack(self,self.updateCityView);
    self.m_city_locate_dialog:show(self);
end

function UnionModuleView.updateCityView(self)
    local str = UserInfo.getInstance():getCityName();
    if str and str ~= "" then
        self.m_union_name:setText(str .. "同城棋友会");
        self.m_union_icon_text:setText(str);
        self.m_text_view:setVisible(false);
        self.m_join_union_btn:setVisible(false);
        self.m_show_view:setVisible(true);
--        self:getMember(); -- 暂时
    else
        self.m_union_name:setText("尚未加入联盟");
        self.m_union_member_num:setText("无");
        self.m_union_icon_text:setText("同城");
        self.m_text_view:setVisible(true);
        self.m_join_union_btn:setVisible(true);
        self.m_show_view:setVisible(false);
    end
end

--[Comment]
--切换同城用户列表
function UnionModuleView.checkMember(self)
    self:leftOutRightIn(self.m_union_view,self.m_member_view);
    UnionModuleController.getInstance():onGetAllUnionMember();
end

--[Comment]
--切换同城推荐
function UnionModuleView.onBackUnion(self)
    self:leftInRightOut(self.m_union_view,self.m_member_view);
end

--[Comment]
--拉取推荐用户信息
function UnionModuleView.getMember(self)
    UnionModuleController.getInstance():onGetUnionRecommend();
end

function UnionModuleView.onRecommendCallBack(self,data)
    if not data.total then
        self.m_union_member_num:setText("无");
    else
        self.m_union_member_num:setText(data.total .. "");
    end
    if not data.list or #data.list < 1 then
        return
    end

    local tmpTab = data.list;
    for k,v in pairs(tmpTab) do
        v.room = self;
    end

    self.recommend_data = tmpTab;
    self:setListData(tmpTab);
end

--[Comment]
--设置随机推荐数据
function UnionModuleView.setListData(self,data)
    if not data or (type(data) == "table" and #data == 0) then 
        return ;
    end

    if self.m_recommendAdapter then
        self.m_recommend_view:removeChild(self.m_recommend_list,true);
        delete(self.m_recommendAdapter);
        delete(self.m_recommend_list);
        self.m_recommendAdapter = nil;
        self.m_recommend_list = nil;
    end

    self.m_recommendAdapter = new(CacheAdapter,UnionRecommendItem,data);
    local w,h = self.m_recommend_view:getSize();
	self.m_recommend_list = new(ListView,0,0,w,h,true);
    self.m_recommend_list:setAlign(kAlignLeft);
    self.m_recommend_list:setDirection(kHorizontal);
    self.m_recommend_list:setAdapter(self.m_recommendAdapter);
    self.m_recommend_view:addChild(self.m_recommend_list);
end

--[Comment]
--显示用户信息弹窗
function UnionModuleView.showUserInfoDialog(self,id)
    if not self.m_userinfo_dialog then
        self.m_userinfo_dialog = new(UserInfoDialog2);
    end;
    if self.m_userinfo_dialog:isShowing() then return end
    local retType = UserInfoDialog2.SHOW_TYPE.UNION
    local id = tonumber(id) or 0
    if UserInfo.getInstance():getUid() == id then
        retType = UserInfoDialog2.SHOW_TYPE.ONLINE_ME
    end
    self.m_userinfo_dialog:setShowType(retType)
    local user = FriendsData.getInstance():getUserData(id)
    self.m_userinfo_dialog:show(user,id)

--    self.m_extra_msg = FriendsData.getInstance():getUserData(tonumber(id));
--    self.m_userinfo_dialog:setForbidVisible(false);
--    self.m_userinfo_dialog:show(self.m_extra_msg,true);
end

--[Comment]
--获得名字字符串
function UnionModuleView.getNameStr(name)
    local str = name or "博雅象棋"
    if name then
        local lenth = string.lenutf8(GameString.convert2UTF8(name));
        if lenth > 6 then    
            str  = string.subutf8(name,1,7).."...";
        end
    end
    return str;
end

--[Comment]
--关注
function UnionModuleView.follow(data)
    local id = tonumber(data.mid)
    if not id then return end
    local info = {};
    info.uid = UserInfo.getInstance():getUid();
    info.target_uid = id;
    if FriendsData.getInstance():isYourFollow(tonumber(data.mid)) == -1 and FriendsData.getInstance():isYourFriend(tonumber(data.mid)) == -1 then
        info.op = 1;
    else
        info.op = 0;
    end
--    Log.i("info.op  "..info.op);
    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_ADD_FLLOW,info);
end

--[Comment]
--关注
function UnionModuleView.setUserIcon(data,v1,v2)
    if not data then return end
    if v1 then 
        if data.is_vip == 1 then
            v1:setVisible(true);
        else
            v1:setVisible(false);
        end
    end

    if v2 then
        if data.iconType and data.iconType >= 0 then
            v2:setFile(UserInfo.DEFAULT_ICON[data.iconType] or UserInfo.DEFAULT_ICON[1]);
        else
            if data.iconType == -1 and data.icon_url then --兼容1.7.5之前的版本的头像为""时显示默认头像。
                v2:setUrlImage(data.icon_url,UserInfo.DEFAULT_ICON[1]);
            end
        end
    end
end

function UnionModuleView.onUnionMemberCallBack(self,data)
    if not data.list or #data.list == 0 then 
        --显示暂无成员
        return 
    end
    local memberData = json.analyzeJsonNode(data.list);
    for _,v in pairs(memberData) do
        if v then
            v.room = self;
        end
    end
    self.m_memberData = memberData;

    self.m_memberAdapter = new(CacheAdapter,UnionMemberItem,memberData);
    self.m_memberListView:setAdapter(self.m_memberAdapter);
end

function UnionModuleView.onUpdateRecommendData(self,status, data)
    if status then
        if type(status) ~= "table" or #status == 0 then
            return
        end
        if self.m_userinfo_dialog then
            local ret = self.m_userinfo_dialog:setUserData(status[1]);
            if ret then
--              print_string("setUserData success");
            end
        end
    end
end

function UnionModuleView.onRecvServerMsgFollowSuccess(self,info)
    if info.ret ~= 0 then
        ChessToastManager.getInstance():show("关注失败!");
        return ;
    end

    local rindex = 0;
    local mindex = 0;
    if self.recommend_data and #self.recommend_data > 0 then
        for k,v in pairs(self.recommend_data) do
            if tonumber(v.mid) == info.target_uid then
                rindex = k;
            end
        end
    end 
    if self.m_memberData and #self.m_memberData > 0 then
        for i,j in pairs(self.m_memberData) do
            if tonumber(j.mid) == info.target_uid then
                mindex = i;
            end
        end
    end

    if info.ret == 0 then
        -- ret 1 更新联盟界面关注按钮 2 更新成员界面关注按钮
        self:updataBtnText(info,rindex,mindex);
    end
end

function UnionModuleView:updataBtnText(info,rindex,mindex)
    if not info then return end
    
    if rindex ~= 0 then
        local num =  #self.m_recommendAdapter:getData()
        if not self.m_recommendAdapter:getData() or num == 0 then
            return;
        end    
        local view = self.m_recommendAdapter:getView(rindex);
        if tonumber(view.data.mid) == info.target_uid then
            view:updataBtn(info);
        end
    end  
    
    if mindex ~= 0 then
        local num =  #self.m_memberAdapter:getData()
        if not self.m_memberAdapter:getData() or num == 0 then
            return;
        end    
        local view = self.m_memberAdapter:getView(mindex);
        if tonumber(view.data.mid) == info.target_uid then
            view:updataBtn(info);
        end
    end
end


UnionModuleView.s_cmdConfig = 
{
    [UnionModuleView.s_cmds.recommendCallBack]              = UnionModuleView.onRecommendCallBack;
    [UnionModuleView.s_cmds.unionMemberCallBack]            = UnionModuleView.onUnionMemberCallBack;
}

UnionModuleView.s_nativeEventFuncMap = {
    [kFriend_UpdateUserData]          = UnionModuleView.onUpdateRecommendData;
    [kFriend_FollowCallBack]          = UnionModuleView.onRecvServerMsgFollowSuccess;

}

------------------------ node -----------------
UnionRecommendItem = class(Node);

function UnionRecommendItem.ctor(self,data)
    if not data then return end

    self.handler = data.room
    self.data = data;
    self:setSize(190,291);
    self.m_head_icon = new(Image,"common/background/head_bg_130.png");
    self.m_head_icon:setAlign(kAlignTop);
    self.m_head_icon:setSize(116,116);
    self:addChild(self.m_head_icon);
    self.m_head_mask = new(Mask, UserInfo.DEFAULT_ICON[1],"common/background/head_mask_bg_110.png");
    self.m_head_mask:setSize(110,110);
    self.m_head_mask:setAlign(kAlignCenter);
    self.m_head_icon:addChild(self.m_head_mask);
    self.m_head_btn = new(Button,"drawable/blank.png");
    self.m_head_btn:setAlign(kAlignCenter);
    self.m_head_btn:setSize(116,116);
    self.m_head_icon:addChild(self.m_head_btn);
    self.m_vip_frame = new(Image,"vip/vip_130.png");
    self.m_vip_frame:setAlign(kAlignCenter);
    self.m_head_icon:addChild(self.m_vip_frame);
    self.m_vip_frame:setVisible(false);

    self.m_head_btn:setOnClick(self,function()
--        print_string("click head btutton");
        self:showDetailInfo();
    end);

    local name = UnionModuleView.getNameStr(data.mnick);
    self.m_name = new(Text,name,nil,nil,kAlignCenter,nil,30,80,80,80);
    self.m_name:setAlign(kAlignTop);
    self.m_name:setPos(0,128);
    self:addChild(self.m_name);

    local score = data.score or "0";
    self.m_score = new(Text,string.format("积分:%d",score),nil,nil,kAlignCenter,nil,30,80,80,80);
    self.m_score:setAlign(kAlignTop);
    self.m_score:setPos(0,169);
    self:addChild(self.m_score);

    self.m_follow_btn = new(Button,"common/button/dialog_btn_3_normal.png","common/button/dialog_btn_7_normal.png");
    self.m_follow_btn:setAlign(kAlignBottom);
    self.m_follow_btn:setPos(0,15);
    self.m_btnText = new(Text,"关注",nil,nil,kAlignCenter,nil,30,240,230,210);
    self.m_btnText:setAlign(kAlignCenter);
    self.m_follow_btn:addChild(self.m_btnText);
    self.m_follow_btn:setOnClick(self,function()
        UnionModuleView.follow(self.data);
    end);
    self:addChild(self.m_follow_btn);

    self:setHeadIcon();
end

function UnionRecommendItem.updataBtn(self,info)
    if info.relation then
--        Log.i("info.relation  "..info.relation);
    end
    if info.relation == 2 or info.relation == 3 then
        ChessToastManager.getInstance():showSingle("关注成功！");
        self.m_btnText:setText("取消关注");
        self.m_follow_btn:setFile({"common/button/dialog_btn_7_normal.png","common/button/dialog_btn_7_press.png"});
    else
        ChessToastManager.getInstance():showSingle("已取消关注！");
        self.m_btnText:setText("关注");
        self.m_follow_btn:setFile({"common/button/dialog_btn_3_normal.png","common/button/dialog_btn_3_press.png"});
    end
end

function UnionRecommendItem.setHeadIcon(self)
    UnionModuleView.setUserIcon(self.data,self.m_vip_frame,self.m_head_mask);
end

function UnionRecommendItem.showDetailInfo(self)
    local id = self.data.mid;
    if not id then return end
    if not self.handler then return end
    self.handler:showUserInfoDialog(id);
end

----------------------node ------------------------------
UnionMemberItem = class(Node);

require(VIEW_PATH.."watch_player_node");
function UnionMemberItem.ctor(self,data)
    if not data then return end
    
    self.room = data.room;
    self.data = data;
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
    if UserInfo.getInstance():getUid() == tonumber(data.mid) then
        self.m_followBtn:setVisible(false);
    end
    self.m_btnText = self.m_followBtn:getChildByName("text");
    self.m_vip_frame = self.m_root_view:getChildByName("icon_bg"):getChildByName("vip_frame");
    self.m_vip_logo = self.m_root_view:getChildByName("vip_logo");
    self:addChild(self.m_root_view);
        
    self.icon = new(Mask,UserInfo.DEFAULT_ICON[1],"common/background/head_mask_bg_86.png");
    self.icon:setSize(self.icon_mask:getSize());
    self.icon:setAlign(kAlignCenter);
    self.icon_mask:addChild(self.icon);

    self.m_name:setText(self.data.mnick);
    self.m_level:setFile("common/icon/level_"..10 - UserInfo.getInstance():getDanGradingLevelByScore(tonumber(self.data.score))..".png");
    self.m_score:setText("积分:"..tonumber(self.data.score));
    if FriendsData.getInstance():isYourFollow(tonumber(self.data.mid)) == -1 and FriendsData.getInstance():isYourFriend(tonumber(self.data.mid)) == -1 then
        self.m_btnText:setText("关注");
        self.m_followBtn:setFile({"common/button/dialog_btn_3_normal.png","common/button/dialog_btn_3_press.png"});
    else
        self.m_btnText:setText("取消关注");
        self.m_followBtn:setFile({"common/button/dialog_btn_7_normal.png","common/button/dialog_btn_7_press.png"});
    end
    self.m_followBtn:setOnClick(self,function()
        UnionModuleView.follow(self.data);
    end);

    local vx,vh = self.m_vip_logo:getPos();
    local vw,vh = self.m_vip_logo:getSize();
    local text = new(Text,self.data.mnick,nil,nil,nil,nil,32);
    local nw,nh = text:getSize();

    if self.data.is_vip and tonumber(self.data.is_vip) == 1 then
        self.m_name:setPos(vx + vw + 3,-16);
        self.m_vip_logo:setVisible(true);
    else
        self.m_name:setPos(134,-16);
        self.m_vip_logo:setVisible(false);
    end

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
    self:setHeadIcon();
end

function UnionMemberItem.dtor(self)
    
end

function UnionMemberItem.updataBtn(self,info)
    if info.relation then
--        Log.i("info.relation  "..info.relation);
    end
    if info.relation == 2 or info.relation == 3 then
        ChessToastManager.getInstance():showSingle("关注成功！");
        self.m_btnText:setText("取消关注");
        self.m_followBtn:setFile({"common/button/dialog_btn_7_normal.png","common/button/dialog_btn_7_press.png"});
    else
        ChessToastManager.getInstance():showSingle("已取消关注！");
        self.m_btnText:setText("关注");
        self.m_followBtn:setFile({"common/button/dialog_btn_3_normal.png","common/button/dialog_btn_3_press.png"});
    end
end

function UnionMemberItem.setHeadIcon(self)
    UnionModuleView.setUserIcon(self.data,self.m_vip_frame,self.icon);
end
