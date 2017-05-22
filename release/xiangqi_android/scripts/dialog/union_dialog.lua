require(VIEW_PATH .. "union_dialog_view");
require(BASE_PATH.."chessDialogScene")
require("ui/adapter");

UnionDialog = class(ChessDialogScene,false);

UnionDialog.SHOW_ANIM_TIME = 400;
UnionDialog.HIDE_ANIM_TIME = 200;
-- 左进右出动画时间
UnionDialog.LIRO_ANIM_TIME = 300;
UnionDialog.LORI_ANIM_TIME = 300;

UnionDialog.ctor = function(self,room)
	super(self,union_dialog_view);
    self.m_room = room;
	self.m_root_view = self.m_root;
    self.m_rootW, self.m_rootH = self:getSize();
    self:initView();
end

UnionDialog.dtor = function(self)
    delete(self.m_root_view);
end

UnionDialog.initView = function(self)
    self.m_bg_view = self.m_root_view:getChildByName("bg");
    self.m_union_view = self.m_bg_view:getChildByName("union_view");
    self.m_member_view = self.m_bg_view:getChildByName("member_view");


    self:setShieldClick(self,self.dismiss);
    self.m_bg_view:setEventTouch(self.m_bg_view,function() end);

    self.m_hide_btn = self.m_bg_view:getChildByName("hide_btn");
    self.m_hide_btn:setOnClick(self, self.dismiss);

    self.m_title_view = self.m_union_view:getChildByName("title_view");
    self.m_union_name = self.m_title_view:getChildByName("name_bg"):getChildByName("name");
    self.m_union_member_num = self.m_title_view:getChildByName("member_bg"):getChildByName("member_num");
    self.m_union_icon_text = self.m_title_view:getChildByName("icon_frame"):getChildByName("text");

    self.m_content_bg = self.m_union_view:getChildByName("content_bg");
    self.m_text_view = self.m_content_bg:getChildByName("prompt_textview");
    self.m_join_union_btn = self.m_content_bg:getChildByName("experience_btn");
    self.m_join_union_btn:setOnClick(self,self.joinUnion);

    self.m_show_view = self.m_content_bg:getChildByName("view"); 

    self.m_member_btn = self.m_show_view:getChildByName("member_btn");
    self.m_member_btn:setOnClick(self,self.checkMember);

    self.m_member            = {};  -- 推荐item
    self.m_member_name       = {};  -- 名字
    self.m_member_score      = {};  -- 积分
    self.m_member_head_frame = {};  -- 头像框
    self.m_head_icon         = {};  -- 头像
    self.m_follow_btn        = {};  -- 關注按鈕
    self.m_vip_frame         = {};
    for i = 1,3 do
        self.m_member[i] = self.m_show_view:getChildByName("item" .. i);
        self.m_member_name[i] = self.m_member[i]:getChildByName("name");
        self.m_member_score[i] = self.m_member[i]:getChildByName("score");
        self.m_member_head_frame[i] = self.m_member[i]:getChildByName("image");
        self.m_head_icon[i] = new(Mask,"userinfo/women_head01.png" ,"common/background/head_mask_bg_110.png");
        self.m_head_icon[i]:setAlign(kAlignCenter);
        self.m_head_icon[i]:setSize(110,110);
        self.m_follow_btn[i] = self.m_member[i]:getChildByName("button");
        local data = {};
        data.sf = self;
        data.index = i;
        self.m_follow_btn[i]:setOnClick(data,self.onFollow);
        self.m_member_head_frame[i]:addChild(self.m_head_icon[i]);
        self.m_vip_frame[i] = self.m_member_head_frame[i]:getChildByName("vip_frame");
    end
    
    self.m_union_task = self.m_show_view:getChildByName("union_task");
    
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
    self:setVisible(false);
end 

UnionDialog.isShowing = function(self)
    return self:getVisible();
end

UnionDialog.show = function(self)
    self:setVisible(true);
    self.super.show(self,false);
    self.data = nil;
    -- leftInAnim
    self.m_root:removeProp(11);
    local leftInAnim = self.m_root:addPropTranslateWithEasing(10, kAnimNormal, UnionDialog.SHOW_ANIM_TIME, -1, "easeOutBack", function (...) return 0 end, -100, 100, 0, 0)
    if not leftInAnim then return end;
    leftInAnim:setEvent(self, function() 


    end)
    self.m_union_view:setVisible(true);
    self.m_member_view:setVisible(false);
    self:releaseAnim();

    self:showView();

end

UnionDialog.dismiss = function(self)
    self.m_root:removeProp(10);
    if self.m_city_locate_dialog then
        delete(self.m_city_locate_dialog);
        self.m_city_locate_dialog = nil;
    end
    self:releaseAnim();
    -- hideAnim
    local rightHideAnim = self.m_root:addPropTranslate(11,kAnimNormal,UnionDialog.HIDE_ANIM_TIME,0,0,-self.m_rootW,nil,nil);
    if not rightHideAnim then return end;
    rightHideAnim:setEvent(self, function() 
        self.super.dismiss(self);
        self:setVisible(false);
        self:resetDialog();
        self.m_room:setHallUnionBtnVisible(true);
    end)
end

UnionDialog.releaseAnim = function(self)
    for i = 0 ,2 do
        if not self.m_union_view:checkAddProp(i) then
            self.m_union_view:removeProp(i);
        end
        if not self.m_member_view:checkAddProp(i) then
            self.m_member_view:removeProp(i);
        end
    end
end

UnionDialog.resetDialog = function(self)
    self.m_text_view:setVisible(false);
    self.m_join_union_btn:setVisible(false);
    self.m_show_view:setVisible(false);
    self.m_member_view:setVisible(false);
end
------------------anim ------------------------
-- 左出右进动画
UnionDialog.leftOutRightIn = function(self,leftView, rightView,callBackFun)
    leftView:setVisible(true);
    local leftW,leftH = leftView:getSize();
    -- leftSlide
    local leftAnim = leftView:addPropTranslate(0,kAnimNormal,UnionDialog.LORI_ANIM_TIME,-1,0,-leftW,0,0);
    if not leftAnim then return end;
    leftAnim:setEvent(nil, function() 
        leftView:removeProp(0);
    end);
    -- leftTransparency
    local leftTransparency = leftView:addPropTransparency(1,kAnimNormal,UnionDialog.LORI_ANIM_TIME,0,0.5,0);
    if not leftTransparency then return end;
    leftTransparency:setEvent(nil, function() 
        leftView:setVisible(false);
        leftView:removeProp(1);
    end);
--    -- rightSlide

--    local rightW,rightH = rightView:getSize();
--    local rightAnim = rightView:addPropTranslate(0,kAnimNormal,UnionDialog.LORI_ANIM_TIME,0,rightW,0,nil,nil);
--    if not rightAnim then return end;
--    rightAnim:setEvent(nil, function() 
--        rightView:removeProp(0);
--        if callBackFun then
--            callBackFun(self);
--        end;
--    end);
    -- rightTransparency
    rightView:setVisible(true);
    local rightTransparency = rightView:addPropTransparency(1,kAnimNormal,UnionDialog.LORI_ANIM_TIME-100,100,0,1);
    if not rightTransparency then return end;
    rightTransparency:setEvent(nil, function() 
        rightView:removeProp(1);
         if callBackFun then
            callBackFun(self);
        end;
    end);
end;

-- 左进右出动画
UnionDialog.leftInRightOut = function(self,leftView, rightView,callBackFun)
    -- leftSlide
    leftView:setVisible(true);
    local leftW,leftH = leftView:getSize();
    local leftAnim = leftView:addPropTranslate(1,kAnimNormal,UnionDialog.LIRO_ANIM_TIME,0,-leftW,0,nil,nil);
    if not leftAnim then return end;
    leftAnim:setEvent(nil, function() 
         leftView:removeProp(1);  
         if callBackFun then
            callBackFun(self);
         end;     
    end)
    -- leftTransparency
    local leftTransparency = leftView:addPropTransparency(2,kAnimNormal,UnionDialog.LORI_ANIM_TIME,0,0,1);
    if not leftTransparency then return end;
    leftTransparency:setEvent(nil, function() 
        leftView:removeProp(2);
    end);
    -- rightSlide

--    local rightW,rightH = rightView:getSize();
--    local rightAnim = rightView:addPropTranslate(1,kAnimNormal,UnionDialog.LIRO_ANIM_TIME,0,0,rightW,nil,nil);
--    if not rightAnim then return end;
--    rightAnim:setEvent(nil, function() 
--        rightView:removeProp(1);      
--    end);
    -- rightTransparency
    rightView:setVisible(true);
    local rightTransparency = rightView:addPropTransparency(2,kAnimNormal,UnionDialog.LORI_ANIM_TIME-100,100,0.5,0);
    if not rightTransparency then return end;
    rightTransparency:setEvent(nil, function() 
        rightView:setVisible(false);
        rightView:removeProp(2);
    end);
end;

UnionDialog.showView = function(self)
    self:updateCityView();
    for i = 1,3 do
        local btnText = self.m_follow_btn[i]:getChildByName("text");
        btnText:setText("关注");
        self.m_follow_btn[i]:setFile({"common/button/dialog_btn_3_normal.png","common/button/dialog_btn_3_press.png"});
        self.m_member[i]:setVisible(false);
    end
end
--加入联盟（选择城市）
UnionDialog.joinUnion = function(self)
    require("dialog/city_locate_pop_dialog")
    if not self.m_city_locate_dialog then
        self.m_city_locate_dialog = new(CityLocatePopDialog);
    end
    self.m_city_locate_dialog:setConfirmCallBack(self,self.updateCityView);
    self.m_city_locate_dialog:show(self);

end

--拉取推荐用户信息
UnionDialog.getMember = function(self)
    for i = 1,3 do
        local btnText = self.m_follow_btn[i]:getChildByName("text");
        btnText:setText("关注");
        self.m_follow_btn[i]:setEnable(true);
        self.m_follow_btn[i]:setFile({"common/button/dialog_btn_3_normal.png","common/button/dialog_btn_3_press.png"});
    end
    self.m_room:getUnionRecommend();
end

--更新推荐玩家数据（hallscene返回）
UnionDialog.updataRecommend = function(self,data)
    if not data.total then
        self.m_union_member_num:setText("无");
    else
        self.m_union_member_num:setText(data.total .. "");
    end
    if not data.list or #data.list < 1 then
        self:showMember(0);
        return
    end
    self.data = data.list
    self:showMember(#(data.list));
    self:setListData(data.list);
end

UnionDialog.updataMember = function(self,data)
--    if not data.total then
--        self.m_union_member_num:setText("无");
--    else
--        self.m_union_member_num:setText(data.total .. "");
--    end
    if not data.list or #data.list == 0 then 
        --显示暂无成员
        return 
    end
    local memberData = data.list;
    for _,v in pairs(memberData) do
        v.room = self;
    end
    self.m_memberData = memberData;

    self.m_memberAdapter = new(CacheAdapter,UnionMemberItem,memberData);
    self.m_memberListView:setAdapter(self.m_memberAdapter);

end
--设置推荐玩家显示状态
UnionDialog.showMember = function(self,n)
    if not n then
        for i = 1,3 do
            self.m_member[i]:setVisible(false);
        end
        return;
    end
    
    if n < 3 then
        for j = n+1,3 do
            self.m_member[j]:setVisible(false);
        end
        if n == 0 then
            return
        end
    end

    for i = 1,n do
        self.m_member[i]:setVisible(true);
    end
end
--设置随机推荐数据
UnionDialog.setListData = function(self,data)
    for i = 1, #data do
        --设置名字
        if self.m_member_name[i] then
            if data[i].mnick then
                local lenth = string.lenutf8(GameString.convert2UTF8(data[i].mnick));
                if lenth > 6 then    
                    local str  = string.subutf8(data[i].mnick,1,6).."...";
                    self.m_member_name[i]:setText(str);
                    self.m_member_name[i]:setText(str);
                else
                    self.m_member_name[i]:setText(data[i].mnick);
                end
            else
                self.m_member_name[i]:setText("博雅棋友");
            end
        end
        --设置积分
        if self.m_member_score[i] then
            if data[i].score then
                self.m_member_score[i]:setText(data[i].score .. "");
            else
                self.m_member_score[i]:setText("0");
            end
        end
        --设置头像和vip
        if self.m_head_icon[i] then
            self:setUserIcon(i,data[i]);
        end
    end
end

UnionDialog.setUserIcon = function(self,n,data)
    if not n then return end
    if data.is_vip == 1 then
        self.m_vip_frame[n]:setVisible(true);
    else
        self.m_vip_frame[n]:setVisible(false);
    end

    if data.iconType and data.iconType > 0 then
        self.m_head_icon[n]:setFile(UserInfo.DEFAULT_ICON[data.iconType] or UserInfo.DEFAULT_ICON[1]);
    else
        if data.iconType == -1 and data.icon_url then --兼容1.7.5之前的版本的头像为""时显示默认头像。
            self.m_head_icon[n]:setUrlImage(data.icon_url,UserInfo.DEFAULT_ICON[1]);
        end
    end
end

UnionDialog.onFollow = function(obj)
    self = obj.sf
    local data = self.data[obj.index];
    local info = {};
    info.uid = UserInfo.getInstance():getUid();
    info.target_uid = tonumber(data.mid);
    if FriendsData.getInstance():isYourFollow(tonumber(data.mid)) == -1 and FriendsData.getInstance():isYourFriend(tonumber(data.mid)) == -1 then
        info.op = 1;
    else
        info.op = 0;
    end
    Log.i("info.op  "..info.op);

    if not info.target_uid then return end
    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_ADD_FLLOW,info);
end

--更新状态
UnionDialog.onRecvServerAddFllow = function(self,info)
    if info.ret ~= 0 then
        ChessToastManager.getInstance():show("关注失败!");
        return ;
    end

    local uindex = 0;
    local mindex = 0;
    if self.data and #self.data > 0 then
        for k,v in pairs(self.data) do
            if tonumber(v.mid) == info.target_uid then
                uindex = k;
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
        if uindex ~= 0 then
            self:updataBtnText(info,1,uindex);
        end
        if mindex ~= 0 then
            self:updataBtnText(info,2,mindex);
        end
    end
end

UnionDialog.checkMember = function(self)
    self:leftOutRightIn(self.m_union_view,self.m_member_view);
    self.m_room:getAllUnionMember();
end

UnionDialog.onBackUnion = function(self)
    self:leftInRightOut(self.m_union_view,self.m_member_view);
end

UnionDialog.updataBtnText = function(self,info,ret,index)
    if not ret then return end
    
    if ret == 1 then
        local btnText = self.m_follow_btn[index]:getChildByName("text");
        -- 发起关注/取消关注，server返回会先更新FriendData的isYourFollow
        if info.relation == 2 or info.relation == 3 then
            ChessToastManager.getInstance():showSingle("关注成功！");
            btnText:setText("取消关注");
            self.m_follow_btn[index]:setFile({"common/button/dialog_btn_7_normal.png","common/button/dialog_btn_7_press.png"});
        else
            ChessToastManager.getInstance():showSingle("已取消关注！");
            btnText:setText("关注");
            self.m_follow_btn[index]:setFile({"common/button/dialog_btn_3_normal.png","common/button/dialog_btn_3_press.png"});
        end

--        if FriendsData.getInstance():isYourFollow(self.data[index]) == -1 then
--            ChessToastManager.getInstance():showSingle("关注成功！");
--            local btnText = self.m_follow_btn[index]:getChildByName("text");
--            btnText:setText("已关注");
--            self.m_follow_btn[index]:setEnable(false);
--        else
--            ChessToastManager.getInstance():showSingle("已取消关注");
--            local btnText = self.m_follow_btn[index]:getChildByName("text");
--            btnText:setText("加关注");
--            self.m_follow_btn[index]:setEnable(true);
--        end;
    elseif ret == 2 then
        local num =  #self.m_memberAdapter:getData()
        if not self.m_memberAdapter:getData() or num == 0 then
            return;
        end    
        local view = self.m_memberAdapter:getView(index);
        if tonumber(view.data.mid) == info.target_uid then
            view:updataBtn(info);
        end
    end
end

function UnionDialog:updateCityView()
    local str = UserInfo.getInstance():getCityName();
    if str and str ~= "" then
        self.m_union_name:setText(str .. "同城棋友会");
        self.m_union_icon_text:setText(str);
        self.m_text_view:setVisible(false);
        self.m_join_union_btn:setVisible(false);
        self.m_show_view:setVisible(true);
        self:getMember(); -- 暂时
    else
        self.m_union_name:setText("尚未加入联盟");
        self.m_union_member_num:setText("无");
        self.m_union_icon_text:setText("同城");
        self.m_text_view:setVisible(true);
        self.m_join_union_btn:setVisible(true);
        self.m_show_view:setVisible(false);
    end
end

----------------------node ------------------------------
UnionMemberItem = class(Node);

UnionMemberItem.ctor = function(self,data)
    if not data then return end
    
    self.room = data.room;
    self.data = data;
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

    if data.iconType and data.iconType > 0 then
        self.icon:setFile(UserInfo.DEFAULT_ICON[data.iconType] or UserInfo.DEFAULT_ICON[1]);
    else
        if data.iconType == -1 and data.icon_url then --兼容1.7.5之前的版本的头像为""时显示默认头像。
            self.icon:setUrlImage(data.icon_url,UserInfo.DEFAULT_ICON[1]);
        end
    end

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
    self.m_followBtn:setOnClick(self,self.onClick);

    local vx,vh = self.m_vip_logo:getPos();
    local vw,vh = self.m_vip_logo:getSize();
    local text = new(Text,self.data.mnick,nil,nil,nil,nil,32);
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

UnionMemberItem.dtor = function(self)
    
end

UnionMemberItem.onClick = function(self)
    local info = {};
    info.uid = UserInfo.getInstance():getUid();
    info.target_uid = tonumber(self.data.mid);
    if FriendsData.getInstance():isYourFollow(tonumber(self.data.mid)) == -1 and FriendsData.getInstance():isYourFriend(tonumber(self.data.mid)) == -1 then
        info.op = 1;
    else
        info.op = 0;
    end
    Log.i("info.op  "..info.op);
    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_ADD_FLLOW,info);
end

UnionMemberItem.updataBtn = function(self,info)
    if info.relation then
        Log.i("info.relation  "..info.relation);
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
