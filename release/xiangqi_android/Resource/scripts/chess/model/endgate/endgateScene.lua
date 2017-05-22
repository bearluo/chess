require(BASE_PATH.."chessScene");
require(MODEL_PATH.."endgate/endgate_map_path");
require(MODEL_PATH.."endgate/endgate_map_num");
EndgateScene = class(ChessScene);

EndgateScene.s_controls = 
{
    endgate_map                 = 1;
    cloud_layout                = 2;
    top_view                    = 3;
    top_title                   = 4;
    back_btn                    = 5;
    endgate_list                = 6;
    title_btn                   = 7;
    endgate_list_scroll_handler = 8;
}

EndgateScene.s_cmds = 
{
    updateListContent = 1;
    serverDataResponse = 2;
    updataUpdateNode = 3;
    updateUserInfoView = 4;
    resetEndgateList = 5;
    showPassAnim     = 6;
}

EndgateScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = EndgateScene.s_controls;
	self.m_btn = {};
    self:create();
    EndgateScene.s_showPassAnim = false;
end 

EndgateScene.resume = function(self)
    ChessScene.resume(self);
    self:checkPass();
    self:init();
    self:updateUserInfoView();
    self:onUpdateProgressBtnClick(false);
    self:setPickable(true);
    if EndgateScene.s_showPassAnim then
        EndgateScene.s_showPassAnim = false
        self:showPassAnim()
    end
end


EndgateScene.pause = function(self)
	ChessScene.pause(self);
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.ENDGATE_TITLE)
end 


EndgateScene.dtor = function(self)
    if EndgateScene.s_fire_icon then 
        delete(EndgateScene.s_fire_icon);
        EndgateScene.s_fire_icon = nil;
    end
    delete(EndgateScene.s_unlockAnim);
    delete(self.m_anim_start);
    delete(self.m_anim_end);
    delete(self.mBuyGateDialog)
end 

----------------------------------- function ----------------------------
EndgateScene.create = function(self)
    self.m_endgate_map = self:findViewById(self.m_ctrls.endgate_map);
    self.m_cloud_layout = self:findViewById(self.m_ctrls.cloud_layout);
    self.m_top_view = self:findViewById(self.m_ctrls.top_view);
    self.m_top_view:setEventDrag(self,function()end);
    self.m_top_title = self:findViewById(self.m_ctrls.top_title);
    self.m_endgate_list_scroll_handler = self:findViewById(self.m_ctrls.endgate_list_scroll_handler);
    self.m_endgate_list_scroll_handler.m_autoPositionChildren = true;
    self.m_endgate_list = self:findViewById(self.m_ctrls.endgate_list);
    self.m_endgate_list:setVisible(false);
    self.m_leaf_left = self.m_root:getChildByName("bamboo_left");
    self.m_leaf_right = self.m_root:getChildByName("bamboo_right");

    self.m_leaf_left:setFile("common/decoration/left_leaf.png")
    self.m_leaf_right:setFile("common/decoration/right_leaf.png")

    local w,h = self.m_endgate_map:getSize();
    local gw,gh = self:getSize();
    self.m_endgate_map:setSize(w,h+gh-System.getLayoutHeight()); --残局地图

	ScrollView.setEventDrag(self.m_endgate_map,self.m_endgate_map,function (obj, finger_action, x, y,drawing_id_first, drawing_id_current)
        EndgateScene.onEventDrag(obj, finger_action, x, y,drawing_id_first, drawing_id_current,self)
    end);
end

function EndgateScene:initEndgateList(data)
    self.m_endgate_list:setVisible(false);
    self.m_endgate_list_scroll_handler:removeAllChildren();
    self.m_endgateListItems = {};
    local nodeW,nodeH = 371,72;
    for i,v in ipairs(data) do
        local node = new(Node);
        node.index = i;
        node:setSize(nodeW,nodeH);
        local title = new(Text,"第"..self:getChinaNum(i).."章", 0, 0, nil, nil, 32, 255,255,255);
        title:setAlign(kAlignLeft);     
        title:setPos(40);
        node:addChild(title);
        
        local titleName = new(Text,v.title, 0, 0, nil, nil, 42, 255,255,255);
        titleName:setAlign(kAlignLeft);
        titleName:setPos(170);
        node:addChild(titleName);

        local img = new(Image,"common/decoration/cutline.png");
        img:setSize(350,2);
        img:setAlign(kAlignBottom);
        node:addChild(img);
        
        local clock = new(Image,"common/decoration/clock.png");
        clock:setAlign(kAlignLeft);
        node:addChild(clock);

        self.m_endgate_list_scroll_handler:addChild(node);
        node.title = title;
        node.titleName = titleName;

        function node.init()
            local uid = UserInfo.getInstance():getUid();
	        local latest_tid = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_GATE .. uid,17);
	        local latest_sort = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_SORT .. uid,0);
            if data[i].tid >latest_tid then 
                clock:setVisible(true);
            else
                clock:setVisible(false);
            end
            title:setColor(155,135,105);
            titleName:setColor(155,135,105)
        end

        function node.onClick()
            if not self:changeIndex(node.index) then return end
            for i,items in ipairs(self.m_endgateListItems) do
                items:init();
            end
            title:setColor(170,92,55);
            titleName:setColor(170,92,55);
        end

        function node.reSet()
            for i,items in ipairs(self.m_endgateListItems) do
                items:init();
            end
            title:setColor(170,92,55);
            titleName:setColor(170,92,55);
        end

        node.onTouchClick = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
            if drawing_id_first == drawing_id_current and finger_action == kFingerUp then
                node:onClick();
            end
        end
        node:setEventTouch(self,node.onTouchClick);
        
        self.m_endgateListItems[i] = node;
    end
    
    if NoviceBootProxy.getInstance():isFirstShow(NoviceBootProxy.s_constant.ENDGATE_TITLE) then
        local title_btn = self:findViewById(self.m_ctrls.title_btn)
        local guideTip = NoviceBootProxy.getInstance():getGuideTipView(NoviceBootProxy.s_constant.ENDGATE_TITLE)
        guideTip:setAlign(kAlignCenter)
        local w,h = title_btn:getSize()
        guideTip:setTipSize(w,h)
        guideTip:startAnim()
        guideTip:setBottomTipText("点击这里可以快速切换残局大关哦",-80,110,250,50,80)
        title_btn:addChild(guideTip)
        NoviceBootProxy.getInstance():setGuideTipViewShowTime(NoviceBootProxy.s_constant.ENDGATE_TITLE)
    end
    
end
-- 生成 <100 的 第n关
function EndgateScene:getChinaNum(sort)
    local retStr = "";
    local map = {
        [0] = "十",
        [1] = "一",
        [2] = "二",
        [3] = "三",
        [4] = "四",
        [5] = "五",
        [6] = "六",
        [7] = "七",
        [8] = "八",
        [9] = "九",
    }
    while sort > 0 do
        local num = sort % 10;
        sort = ( sort - num ) / 10;
        
        if num > 0 then
            retStr = map[num] .. retStr;
        end
        -- 补十
        if sort > 0 then
            retStr = map[0] .. retStr;
        end
        if sort == 1 then break end -- 对于 10+ 特殊处理
    end
    return retStr;
end


EndgateScene.init = function(self)
    if self.m_is_init then return end;
    self.m_is_init = true;
	local data = EndgateData.getInstance():getEndgateData();
    if #data == 0 then return end;
    self.m_endgate_map:removeAllChildren(true);
   
    local w,h = self.m_endgate_map:getSize();
    local scale = w/720;
    local width,height = 720*scale,4480*scale;
    self.m_cloud_layout:setSize(width,height);
    self.m_scale = scale;
    
    local uid = UserInfo.getInstance():getUid();
	local latest_tid = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_GATE .. uid,17);
	local pre_tid = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_SELECT_TID .. uid,latest_tid);
    local pre_pos = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_SELECT_POS .. uid,-1);
    self.m_index,self.m_gate_data = self:getShowData(data,pre_tid);

    
    self:initEndgateList(data);

    self.m_endgate_map_group = new(EndgateGateMap,self.m_gate_data,scale,self.m_index,self);
    self.m_endgate_map_group_cache = {};
    self.m_endgate_map_group_cache[self.m_index] = self.m_endgate_map_group;
    self.m_endgate_map:addChild(self.m_endgate_map_group);
    self.m_endgate_map:setFlippingOverFactor(0.15);
    self.m_endgate_map:setOnScrollEvent(self,self.onScroll) --滚动响应事件
    local anim = self.m_endgate_map:addPropTransparency(1,kAnimNormal,1000,-1,0,1);
    if anim then
        anim:setEvent(self,function(self)
            self.m_endgate_map:removeProp(1);
        end);
    end

    local w,h = self.m_endgate_map:getSize();
    local tw,th = self.m_top_view:getSize();
--    self.m_endgate_map:setReboundMargin(th,-th);-- 设置可以超出的上下距离
	self:setLocked(); -- 更新关卡状态
    self:showCurGate(); -- 显示当前在闯的关卡
    self:setFireIcon(); -- 显示当前在闯的关卡标志
    self:updateTitle();
end

EndgateScene.changeIndex = function(self,index)
	local data = EndgateData.getInstance():getEndgateData();
    if data and data[index] and index ~= self.m_index then
        local uid = UserInfo.getInstance():getUid();
	    local latest_tid = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_GATE .. uid,17);
	    local latest_sort = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_SORT .. uid,0);
        if data[index].tid >latest_tid then 
            if not self:showBuyGateDialog(data[index].tid) then
                if data[index-1] then -- 防止边界条件
                    ChessToastManager.getInstance():showSingle("请先解锁"..data[index-1].title);
                else
                    ChessToastManager.getInstance():showSingle("请先解锁"..data[index].title);
                end
            end
            return false;
        end
        if not self.m_endgate_map_group_cache[index] then
            self.m_endgate_map_group_cache[index] = new(EndgateGateMap,data[index],self.m_scale,index,self);
            self.m_endgate_map:addChild(self.m_endgate_map_group_cache[index]);
        end
        self.m_endgate_map:removeProp(1);
        local anim = self.m_endgate_map:addPropTransparency(1,kAnimNormal,1000,-1,0,1);
        if anim then
            anim:setEvent(self,function(self)
                self.m_endgate_map:removeProp(1);
            end);
        end
        self.m_endgate_map_group_cache[index]:setVisible(true);
        self.m_endgate_map_group:setVisible(false);
        self.m_endgate_map_group = self.m_endgate_map_group_cache[index];
        self.m_endgate_map:gotoBottom();
        self.m_index = index;
	    self:setLocked(); -- 更新关卡状态
        self:updateTitle();
        return true;
    end
    return false;
end

EndgateScene.resetEndgateList = function(self)
    self.m_is_init = false;
    self:init();
end

EndgateScene.removeAnimProp = function(self)
    self.m_leaf_left:removeProp(1);
    self.m_leaf_right:removeProp(1);
    self.m_top_title:removeProp(1);
    self.m_top_title:removeProp(2);
end

EndgateScene.setAnimItemEnVisible = function(self,ret)
    self.m_leaf_left:setVisible(ret);
    self.m_leaf_right:setVisible(ret)
end

EndgateScene.resumeAnimStart = function(self,lastStateObj,timer)
    self:removeAnimProp();
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;
    delete(self.m_anim_start);
    self.m_anim_start = new(AnimInt,kAnimNormal,0,1,delay,-1);
    if self.m_anim_start then
        self.m_anim_start:setEvent(self,function()
            self:setAnimItemEnVisible(true);
            delete(self.m_anim_start);
            if kPlatform == kPlatformIOS then
                if tonumber(UserInfo.getInstance():getIosAuditStatus()) == 0 then return end;
                if tonumber(UserInfo.getInstance():getCanShowIOSAppstoreReview()) == 0 then return end;

            -- 判断是不是刚进入这个界面
                if self.firstLoaded == nil then 
                    self.firstLoaded = true;
                    return;
                end;
                -- 判断返回这个界面的时候 有没有通关
                local lastGate = self.lastGate;
                local lastGateSort = self.lastGateSort;

                local currentGate = EndgateData.getInstance():getGate();
                local currentGateSort = EndgateData.getInstance():getGateSort();
                if currentGate.sort < lastGate.sort then
                    return;
                end
                if currentGate.sort == lastGate.sort then
                    if currentGateSort <= lastGateSort then
                        return;
                    end
                end
                require(DIALOG_PATH .. "ios_review_dialog_view");
                if not self.reviewDialog then
                    self.reviewDialog = new(ReviewDialogView);
                end
                self.reviewDialog:show();
                UserInfo.getInstance():setCanShowIOSAppstoreReview(0);
            end
        end);
    end

    self.m_top_title:addPropTransparency(2,kAnimNormal,waitTime,delay,0,1);
    self.m_top_title:addPropScale(1,kAnimNormal,waitTime,delay,0.8,1,0.6,1,kCenterDrawing);

    local rw,rh = self.m_leaf_right:getSize();
    self.m_leaf_right:addPropTranslate(1,kAnimNormal,waitTime,delay,rw,0,-10,0);
    local lw,lh = self.m_leaf_left:getSize();
    local anim = self.m_leaf_left:addPropTranslate(1,kAnimNormal,waitTime,delay,-lw,0,-10,0);
    if anim then
        anim:setEvent(self,function()
            self:removeAnimProp();
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end
        end);
    end

end

EndgateScene.pauseAnimStart = function(self,newStateObj,timer)
    self:removeAnimProp();
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;
    delete(self.m_anim_end);
    self.m_anim_end = new(AnimInt,kAnimNormal,0,1,delay,-1);
    if self.m_anim_end then
        self.m_anim_end:setEvent(self,function()
            self:removeAnimProp();
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end
            delete(self.m_anim_end);
            self.lastGateSort = EndgateData.getInstance():getGateSort();
            self.lastGate = EndgateData.getInstance():getGate();
        end);
    end
    local rw,rh = self.m_leaf_right:getSize();
    self.m_leaf_right:addPropTranslate(1,kAnimNormal,waitTime,-1,0,rw,0,-10);
    local lw,lh = self.m_leaf_left:getSize();
    local anim = self.m_leaf_left:addPropTranslate(1,kAnimNormal,waitTime,-1,0,-lw,0,-10);
    if anim then
        anim:setEvent(self,function()
            self:setAnimItemEnVisible(false);
        end);
    end
end

EndgateScene.updateTitle = function(self)
    local data = EndgateData.getInstance():getEndgateData();
    local gates = data;
    if self.m_index and gates[self.m_index] and gates[self.m_index].title_img then
        self.m_top_title:setUrlImage(gates[self.m_index].title_img,nil,Image.s_url_type_by_url);
    end
end

-- 重写 endgate_map 的 滚动事件
EndgateScene.onEventDrag =  function(self, finger_action, x, y,drawing_id_first, drawing_id_current,handler)
    if handler and handler.m_endgate_list then
        handler.m_endgate_list:setVisible(false);
    end
	if not ScrollView.hasScroller(self) then return end
	self.m_scroller:onEventTouch(finger_action,x,y,drawing_id_first,drawing_id_current);
    
    if finger_action == kFingerUp then
        local viewlength = self:getViewLength();
        local frameLength = self:getFrameLength();
        local _,totalOffset = self:getScrollViewPos();
        if viewlength + totalOffset - frameLength <= -frameLength*0.15 then
            handler:onDownReboundEvent();
        end

        if totalOffset >= frameLength*0.15 then
            handler:onUpReboundEvent();
--            handler:showPassAnim();
        end
    end
end

EndgateScene.onScroll = function(self, scroll_status, diffY, totalOffset,isMarginRebounding)
--    if self.m_endgate_map_group_cache then
--        for i,v in pairs(self.m_endgate_map_group_cache) do
--            if v:getVisible() then
--                v:onScroll(diffY);
--            end
--        end
--    end

    if self.m_endgate_map_group then
        self.m_endgate_map_group:onScroll(diffY,totalOffset,self.m_endgate_map);
    end
end

EndgateScene.onUpReboundEvent = function(self)
    if not self.m_index then return end
	local data = EndgateData.getInstance():getEndgateData();
    local gates = data;
    if gates[self.m_index+1] then
        local uid = UserInfo.getInstance():getUid();
	    local latest_tid = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_GATE .. uid,17);
	    local latest_sort = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_SORT .. uid,0);
        if gates[self.m_index+1].tid >latest_tid then 
            if not self:showBuyGateDialog(gates[self.m_index+1].tid) then
                ChessToastManager.getInstance():showSingle("请先通关"..gates[self.m_index].title);
            end
            return 
        end
        self.m_endgate_map:stopScroller();
        self.m_endgate_map:gotoTop();
        local pre_index = self.m_index;
        self.m_index,self.m_gate_data = self.m_index+1,gates[self.m_index+1];
        local cur_index = self.m_index;
        if not self.m_endgate_map_group_cache[cur_index] then
            local endgate_map_group = new(EndgateGateMap,self.m_gate_data,self.m_scale,cur_index,self);
            self.m_endgate_map_group_cache[cur_index] = endgate_map_group;
            self.m_endgate_map:addChild(endgate_map_group);
        end
--        self.m_endgate_map_group:changeData(self.m_gate_data);
        self.m_endgate_map_group = self.m_endgate_map_group_cache[cur_index];
        self.m_endgate_map_group_cache[pre_index]:setVisible(true);
        self.m_endgate_map_group_cache[pre_index]:setLevel(1);
        self.m_endgate_map_group_cache[cur_index]:setVisible(true);
        self.m_endgate_map_group_cache[cur_index]:setLevel(2);
        
        self.m_endgate_map:stopScroller();
        self.m_endgate_map:gotoBottom();
	    self:setLocked(); -- 更新关卡状态
        self:setFireIcon(); -- 显示当前在闯的关卡标志

        local animEvent = function(self)
            self.m_endgate_map_group_cache[pre_index]:removeProp(1);
            self.m_endgate_map_group_cache[cur_index]:removeProp(1);
            self.m_endgate_map_group_cache[pre_index]:setVisible(false);
            self:updateTitle();
            EndgateScene.ChangeAnim = nil;
        end
        if EndgateScene.ChangeAnim then
            EndgateScene.ChangeAnim:onEvent();
            EndgateScene.ChangeAnim = nil;
        end
        self.m_endgate_map_group_cache[pre_index]:removeProp(1);
        self.m_endgate_map_group_cache[cur_index]:removeProp(1);
        local viewlength = self.m_endgate_map:getViewLength();
        local frameLength = self.m_endgate_map:getFrameLength();
        
        self.m_endgate_map_group_cache[pre_index]:addPropTranslate(1, kAnimNormal, 200, -1, 0, 0, viewlength-frameLength, viewlength);
        EndgateScene.ChangeAnim = self.m_endgate_map_group_cache[cur_index]:addPropTranslate(1, kAnimNormal, 200, -1, 0, 0, -frameLength,0);
        EndgateScene.ChangeAnim:setEvent(self,animEvent);
    end
end

EndgateScene.onDownReboundEvent = function(self)
    if not self.m_index then return end
	local data = EndgateData.getInstance():getEndgateData();
    local gates = data;
    if gates[self.m_index-1] then
        local uid = UserInfo.getInstance():getUid();
	    local latest_tid = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_GATE .. uid,17);
	    local latest_sort = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_SORT .. uid,0);
        if gates[self.m_index-1].tid >latest_tid then 
            if not self:showBuyGateDialog(gates[self.m_index-1].tid) then
                ChessToastManager.getInstance():showSingle("请先通关"..gates[self.m_index].title);
            end
            return 
        end
        self.m_endgate_map:stopScroller();
        self.m_endgate_map:gotoTop();
        local pre_index = self.m_index;
        self.m_index,self.m_gate_data = self.m_index-1,gates[self.m_index-1];
        local cur_index = self.m_index;
        if not self.m_endgate_map_group_cache[cur_index] then
            local endgate_map_group = new(EndgateGateMap,self.m_gate_data,self.m_scale,cur_index,self);
            self.m_endgate_map_group_cache[cur_index] = endgate_map_group;
            self.m_endgate_map:addChild(endgate_map_group);
        end
        
--        self.m_endgate_map_group:changeData(self.m_gate_data);
        self.m_endgate_map_group = self.m_endgate_map_group_cache[cur_index];
        self.m_endgate_map_group_cache[pre_index]:setVisible(true);
        self.m_endgate_map_group_cache[pre_index]:setLevel(1);
        self.m_endgate_map_group_cache[cur_index]:setVisible(true);
        self.m_endgate_map_group_cache[cur_index]:setLevel(2);
	    self:setLocked(); -- 更新关卡状态
        self:setFireIcon(); -- 显示当前在闯的关卡标志
        
        self.m_endgate_map:stopScroller();
        self.m_endgate_map:gotoTop();
        local animEvent = function(self)
            self.m_endgate_map_group_cache[pre_index]:removeProp(1);
            self.m_endgate_map_group_cache[cur_index]:removeProp(1);
            self.m_endgate_map_group_cache[pre_index]:setVisible(false);
            self:updateTitle();
            EndgateScene.ChangeAnim = nil;
        end
        if EndgateScene.ChangeAnim then
            EndgateScene.ChangeAnim:onEvent();
            EndgateScene.ChangeAnim = nil;
        end
        self.m_endgate_map_group_cache[pre_index]:removeProp(1);
        self.m_endgate_map_group_cache[cur_index]:removeProp(1);
        local viewlength = self.m_endgate_map:getViewLength();
        local frameLength = self.m_endgate_map:getFrameLength();
        
        self.m_endgate_map_group_cache[pre_index]:addPropTranslate(1, kAnimNormal, 200, -1, 0, 0, frameLength-viewlength, -viewlength);
        EndgateScene.ChangeAnim = self.m_endgate_map_group_cache[cur_index]:addPropTranslate(1, kAnimNormal, 200, -1, 0, 0, frameLength,0);
        EndgateScene.ChangeAnim:setEvent(self,animEvent);
    end
end


--显示当前在闯的关卡标志
EndgateScene.setFireIcon = function(self)
    if EndgateScene.s_fire_icon then 
        delete(EndgateScene.s_fire_icon);
        EndgateScene.s_fire_icon = nil;
    end
    local uid = UserInfo.getInstance():getUid();
	local latest_tid = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_GATE .. uid,17);
	local latest_sort = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_SORT .. uid,0);
	local pre_tid = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_SELECT_TID .. uid,latest_tid);
    local pre_pos = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_SELECT_POS .. uid,latest_sort);
    if self.m_endgate_map_group then 
        if self.m_endgate_map_group:getGateTid() == pre_tid then
            self.m_endgate_map_group:setFireIcon(pre_pos);
        end
    end
end

EndgateScene.updateUserInfoView = function(self)
	self:setLocked();   -- 更新关卡状态
    self:setFireIcon(); -- 显示当前在闯的关卡标志
--    self:showCurGate(); -- 显示当前在闯的关卡
end

EndgateScene.checkPass = function(self)
    local uid = UserInfo.getInstance():getUid();
	local latest_tid = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_GATE .. uid,17);
	local latest_sort = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_SORT .. uid,0);
	local data = EndgateData.getInstance():getEndgateData();
    local gates = data;
--  关卡需要付费通过 不自动跳关
--    local gate = nil;
--    for i,v in ipairs(gates) do
--        if v.tid == latest_tid then
--            gate = v;
--            break;
--        end
--    end

--	if gate and latest_sort >= gate.chessrecord_size then
--        local temptid = nil;
--        for i,v in ipairs(gates) do
--            if v.tid > latest_tid then
--                temptid = v.tid;
--                break;
--            end
--        end
--		if temptid then
--			GameCacheData.getInstance():saveInt(GameCacheData.ENDGAME_LATETST_GATE .. uid,temptid);
--			GameCacheData.getInstance():saveInt(GameCacheData.ENDGAME_LATETST_SORT .. uid,0);
--		end
--	end
    --当前关卡
	local pre_tid = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_SELECT_TID .. uid,17);
    local pre_pos = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_SELECT_POS .. uid,0);

    -- 修正
    if pre_tid > latest_tid or ( pre_tid == latest_tid and pre_pos > latest_sort ) then
        pre_tid = latest_tid
        pre_pos = latest_sort
		GameCacheData.getInstance():saveInt(GameCacheData.ENDGAME_LATETST_SELECT_TID .. uid,latest_tid)
		GameCacheData.getInstance():saveInt(GameCacheData.ENDGAME_LATETST_SELECT_POS .. uid,latest_sort)
    end

    local gate = nil;
    for i,v in ipairs(gates) do
        if v.tid == pre_tid then
            gate = v;
            break;
        end
    end
    -- 不能自动跳到未解锁的关卡
	if gate and pre_pos >= gate.chessrecord_size and pre_tid < latest_tid then
        local temptid = nil;
        for i,v in ipairs(gates) do
            if v.tid > pre_tid then
                temptid = v.tid;
                break;
            end
        end
		if temptid then
			GameCacheData.getInstance():saveInt(GameCacheData.ENDGAME_LATETST_SELECT_TID .. uid,temptid);
			GameCacheData.getInstance():saveInt(GameCacheData.ENDGAME_LATETST_SELECT_POS .. uid,0);
		end
	end
end

--刷新列表数据
EndgateScene.updateListContent = function(self,data)
	if table.maxn(data) == 0 then
		return;
	end

--    self.m_endgate_map_group = {};
--    local time = os.clock();
--    for i,v in ipairs(data) do
--        self.m_endgate_map_group[i] = new(EndgateGateMap,v,scale);
--        self.m_endgate_map_group[i]:setPos(0,height*(#data-i));
--        self.m_endgate_map:addChild(self.m_endgate_map_group[i]);
--        self.m_endgate_map:setFlippingOverFactor(0);
--    end

--    Log.e("aaaaaaaaaaaa"..os.clock()-time);
--    两片720的，放在中心点坐标360，56
--606的，放在中心点坐标303,22
--648的，放在中心点坐标197,74
--586的，放在中心点坐标403,12
--622的，放在中心点坐标555,22
    local config = {
    
    };
--    for i,v in ipairs(data) do
--        for index=1,6 do
--            local img = new(Image,'endgate/hall/cloud/move_cloud_'..index..'.png');
--            EndgateScene.scaleView(img,scale);
--            img:setAlign(kAlignTop);
--            local w,h = img:getSize();
--            img:setPos(0,height*(#data-i)-h/2);
--            self.m_endgate_map:addChild(img);
--        end
--    end

end

EndgateScene.getShowData = function(self,data,tid)
    for i,v in ipairs(data) do
        if v.tid == tid then 
            return i,v;
        end
    end
    return #data,data[#data];
end

-- 显示当前在闯的关卡
EndgateScene.showCurGate = function(self)
    local uid = UserInfo.getInstance():getUid();
	local latest_tid = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_GATE .. uid,17);
	local latest_sort = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_SORT .. uid,0);
	local pre_tid = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_SELECT_TID .. uid,latest_tid);
    local pre_pos = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_SELECT_POS .. uid,latest_sort);
    if pre_pos > 50 then pre_pos = 50 end
    if pre_pos < 1 then pre_pos = 1 end
    if self.m_endgate_map_group then 
        if self.m_endgate_map_group:getGateTid() == pre_tid and self.m_endgate_map_group:getViewConfig()[pre_pos] then
            local x,y = self.m_endgate_map_group:getPos();
            local w,h = self.m_endgate_map:getSize();
            self.m_endgate_map:scrollToPos(-y-self.m_endgate_map_group:getViewConfig()[pre_pos].y*self.m_scale+h/2);
            return ;
        else
            if EndgateScene.s_fire_icon then
                EndgateScene.s_fire_icon:setVisible(false);
            end
            self.m_endgate_map:scrollToPos(0);
        end
    end
end

-- 播放过关动画
EndgateScene.showPassAnim = function(self)
    local uid = UserInfo.getInstance():getUid();
	local latest_tid = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_GATE .. uid,17);
	local latest_sort = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_SORT .. uid,0);
	local pre_tid = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_SELECT_TID .. uid,latest_tid);
    local pre_pos = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_SELECT_POS .. uid,latest_sort);
    local gateData = self.m_endgate_map_group:getGate()
    local curTid = self.m_endgate_map_group:getGateTid()
    -- 如果是最后一个关卡的最后一小关通过 提示玩家购买下一关关卡
    if self:showBuyGateDialog() then
        return 
    end
    if self.m_endgate_map_group and curTid < pre_tid then
        self.m_endgate_map:stopScroller();
        self.m_endgate_map:gotoTop();
        self.m_endgate_map:setPickable(false);
        self.m_endgate_map_group:playPassAnim(function()
            self:onUpReboundEvent();
            self.m_endgate_map:setPickable(true);
        end);
    else
        self:showCurGate()
    end
end
--[Comment]
-- 
function EndgateScene:showBuyGateDialog(tid)
    local uid = UserInfo.getInstance():getUid();
	local latest_tid = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_GATE .. uid,17);
	local latest_sort = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_SORT .. uid,0);
	local data = EndgateData.getInstance():getEndgateData();
    local gates = data;
    local gate = nil;
    for i,v in ipairs(gates) do
        if v.tid == latest_tid then
            gate = v;
            break;
        end
    end

    if gate and latest_sort >= gate.chessrecord_size then
        local temp = nil;
        for i,v in ipairs(gates) do
            if v.tid > latest_tid then
                temp = v;
                break;
            end
        end
        if not temp then return end
        if temp.tid == tid or tid == nil then
--            ChessToastManager.getInstance():showSingle("购买"..temp.title)
            if not self.mBuyGateDialog then
                self.mBuyGateDialog = new(ChioceDialog)
                self.mBuyGateDialog:setMode(ChioceDialog.MODE_SURE,"确定","取消")
            end
            
            self.mBuyGateDialog:setMessage( string.format("恭喜通关%s，解锁%s需花费%d金币，是否继续？",gate.title,temp.title,temp.fee) )
            self.mBuyGateDialog:setPositiveListener(self,function()
                local diff = temp.fee - UserInfo.getInstance():getMoney() 
                if diff > 0 then
                    ChessToastManager.getInstance():showSingle( string.format("您的金币不足,还需%d金币才能解锁",diff))
                    local goods = MallData.getInstance():getGoodsByMoreMoney(diff)
                    if goods then
                        local payData = {}
                        payData.pay_scene = PayUtil.s_pay_scene.buy_booth
                        MallScene.m_PayInterface = PayUtil.getPayInstance(PayUtil.s_defaultType);
		                goods.position = ENDGATE_GATE;
		                MallScene.m_pay_dialog = MallScene.m_PayInterface:buy(goods,payData);
                    end
                    return 
                end
	            local post_data = {};
	            post_data.booth_tid = tonumber(temp.tid)
                HttpModule.getInstance():execute(HttpModule.s_cmds.BoothBuyGate,post_data,"购买中");
            end)

            self.mBuyGateDialog:show()
            return true
        end
    else
        return false
    end
end

EndgateScene.updateGates = function(self)
    self:requestCtrlCmd(EndgateController.s_cmds.onGetBoothInfo)
end

EndgateScene.entryEndGateSubGame = function(self,index,gate)
	print_string("********EndgateScene.entryEndGateSubGame*********");

	self:requestCtrlCmd(EndgateController.s_cmds.onEntryGame,gate);
end

--设置关卡状态
EndgateScene.setLocked = function(self)
    if self.m_endgate_map_group then
        self.m_endgate_map_group:setLocked();
    end
end

EndgateScene.serverDataResponse = function(self,data)
    local uid = UserInfo.getInstance():getUid();
	if data.mid and data.mid:get_value() then
		uid = data.mid:get_value();
	end
    local cover_progress = tonumber(data.cover_progress:get_value());
	if data.progress and data.progress:get_value() then
		local progress = data.progress;
		local tid = tonumber(progress.tid:get_value());
		local pos = tonumber(progress.pos:get_value());
	    local latest_tid = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_GATE .. uid,17);
	    local latest_sort = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_SORT .. uid,0);

        if cover_progress == 0 then
            if latest_tid == tid and latest_sort == pos then return end

            if latest_tid > tid or (latest_tid == tid and latest_sort > pos) then return end
        end
        local gates = EndgateData.getInstance():getEndgateData();
--        不再自动跳关        
--        for i,v in ipairs(gates) do
--            if v.tid == tid then
--                if v.chessrecord_size == pos then
--                    if gates[i+1] then
--                        tid = gates[i+1].tid;
--                        pos = 0;
--                    end
--                end
--                break;
--            end
--        end
		GameCacheData.getInstance():saveInt(GameCacheData.ENDGAME_LATETST_GATE .. uid,tid);
		GameCacheData.getInstance():saveInt(GameCacheData.ENDGAME_LATETST_SORT .. uid,pos);
    else
        -- 数据错误无需更新界面
        return ;
	end
	self:setLocked();   -- 更新关卡状态
    self:showCurGate(); -- 显示当前在闯的关卡
    self:setFireIcon(); -- 显示当前在闯的关卡标志
end

EndgateScene.updataUpdateNode = function(self)
    if self.updateNode then
		self.updateNode:setNumText(kEndgateData:getEndingUpdateNum());
	end
end

EndgateScene.onUpdateProgressBtnClick = function(self,flag)
    self:requestCtrlCmd(EndgateController.s_cmds.onDownloadProgress,flag);
end

----------------------------------- click -------------------------------

EndgateScene.onBackClick = function(self)
    self:requestCtrlCmd(EndgateController.s_cmds.onBack);
end

function EndgateScene:onTitleBtnClick()
    self.m_endgate_list:setVisible(not self.m_endgate_list:getVisible());
    if self.m_index and self.m_endgateListItems and self.m_endgateListItems[self.m_index] then
        self.m_endgateListItems[self.m_index].reSet();
    end
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.ENDGATE_TITLE)
end
----------------------------------- config ------------------------------
EndgateScene.s_controlConfig = 
{
    [EndgateScene.s_controls.endgate_map]                           = {"endgate_map"};
    [EndgateScene.s_controls.cloud_layout]                          = {"cloud_layout"};
    [EndgateScene.s_controls.top_view]                              = {"top_view"};
    [EndgateScene.s_controls.top_title]                             = {"top_view","top_title_bg","top_title"};
    [EndgateScene.s_controls.endgate_list]                          = {"top_view","endgate_list"};
    [EndgateScene.s_controls.endgate_list_scroll_handler]           = {"top_view","endgate_list","endgate_list_scroll_handler"};
    [EndgateScene.s_controls.title_btn]                             = {"top_view","title_btn"};
    [EndgateScene.s_controls.back_btn]                              = {"back_btn"};
};

EndgateScene.s_controlFuncMap =
{
    [EndgateScene.s_controls.back_btn]              = EndgateScene.onBackClick;
    [EndgateScene.s_controls.title_btn]             = EndgateScene.onTitleBtnClick;
    
};


EndgateScene.s_cmdConfig =
{
    [EndgateScene.s_cmds.updateListContent] = EndgateScene.updateListContent;
    [EndgateScene.s_cmds.serverDataResponse] = EndgateScene.serverDataResponse;
    [EndgateScene.s_cmds.updataUpdateNode] = EndgateScene.updataUpdateNode;
    [EndgateScene.s_cmds.updateUserInfoView] = EndgateScene.updateUserInfoView;
    [EndgateScene.s_cmds.resetEndgateList] = EndgateScene.resetEndgateList;
    [EndgateScene.s_cmds.showPassAnim] = EndgateScene.showPassAnim;
    
    
}

EndgateScene.scaleView = function(view,scale)
    local w,h = view:getSize();
    view:setSize(w*scale,h*scale);
end

-------------------------------- private node -------------------
EndgateGatePath = class(Image,false)

EndgateGatePath.ctor = function(self,index,data,scale)
    self.m_data = data;
    self.m_scale = scale;
    super(self,endgate_map_path_map[index..'_gray.png']);
    EndgateScene.scaleView(self,scale);
    self:setPos(data.path.x*scale,data.path.y*scale)
end



EndgateGateMap = class(Node)

EndgateGateMap.ctor = function(self,data,scale,index,handler)
    self.m_handler = handler;
    self.m_data = data;
    self.m_index = index;
    self.m_asset_index = data.asset_index or index;
    self.m_viewConfig = EndgateGateMapConfig[self.m_asset_index] or EndgateGateMapConfig[1];
    self.m_scale = scale;
    self.m_bgs = {};
    self.m_bgs_config = {};
    self.m_bg_group = new(Node);
    self:addChild(self.m_bg_group);

    local width,height = 0,-200*scale;
    self.m_bgs[1] = new(Image,"endgate/hall/map_pre.png");
    EndgateScene.scaleView(self.m_bgs[1],scale);
    local w,h = self.m_bgs[1]:getSize();
    self.m_bgs[1]:setPos(0,height);
    self.m_bgs_config[1] = {};
    self.m_bgs_config[1].start_y = height;
    height = height + h;
    self.m_bgs_config[1].end_y = height;
    width = w;
    self.m_bg_group:addChild(self.m_bgs[1]);
    for i=4,1,-1 do
--        self.m_bgs[i+1] = new(Image,"endgate/hall/map"..self.m_asset_index.."_"..i..".jpg");
--        EndgateScene.scaleView(self.m_bgs[i+1],scale);
--        local w,h = self.m_bgs[i+1]:getSize();
--        self.m_bgs[i+1]:setPos(0,height);
        local h = 1220*scale;
        self.m_bgs_config[i+1] = {};
        self.m_bgs_config[i+1].start_y = height;
        height = height + h;
        self.m_bgs_config[i+1].end_y = height;
        width = w;
--        self:addChild(self.m_bgs[i+1]);
    end
    self:setSize(width,height-200*scale);
    
--    self:createPath();
    self:createItem();
--    self:createCloud();
    self:createLockCloud();
end

EndgateGateMap.changeData = function(self,data)
--    self.m_data = data;
--    self:removeAllChildren(true);
--    self.m_bgs = {};
--    local width,height = 0,-200*scale;
--    for i=4,1,-1 do
--        self.m_bgs[i] = new(Image,"endgate/hall/map1_"..i..".jpg");
--        EndgateScene.scaleView(self.m_bgs[i],scale);
--        local w,h = self.m_bgs[i]:getSize();
--        self.m_bgs[i]:setPos(0,height);
--        height = height + h;
--        width = w;
--        self:addChild(self.m_bgs[i]);
--    end
--    self:setSize(width,height-200*scale);
----    self:createPath();
--    self:createItem();
----    self:createCloud();
--    self:createLockCloud();
end

EndgateGateMap.getViewConfig = function(self)
    return self.m_viewConfig;
end

EndgateGateMap.getGate = function(self)
    return self.m_data;
end

EndgateGateMap.getGateTid = function(self)
    return self.m_data.tid;
end

EndgateGateMap.setFireIcon = function(self,sort)
    if not self.m_items or sort + 1 > self.m_data.chessrecord_size then
        return;
    end

    if not self.m_items[sort+1] then
        self.m_items[sort+1] = new(EndgateGateMapItem,sort+1,self.m_scale,self);
        self.m_item_group:addChild(self.m_items[sort+1]);
    end

    if self.m_items and self.m_items[sort+1] then
        if EndgateScene.s_fire_icon then 
            delete(EndgateScene.s_fire_icon);
            EndgateScene.s_fire_icon = nil;
        end
        EndgateScene.s_fire_icon = new(Button,"endgate/hall/fire_icon.png","endgate/hall/fire_icon.png");
        EndgateScene.scaleView(EndgateScene.s_fire_icon,self.m_scale);
        local w,h = EndgateScene.s_fire_icon:getSize();
        EndgateScene.s_fire_icon:setAlign(kAlignTop);
        EndgateScene.s_fire_icon:setPos(0,-h+30);
        EndgateScene.s_fire_icon:addPropScale(1, kAnimLoop, 200, -1, 1, 1.05, 1, 1.05, kCenterXY, w/2, h);
        self.m_items[sort+1]:setFireIcon(EndgateScene.s_fire_icon);
    end
end

EndgateGateMap.showUnlockAnim = function(self,sort,obj,func)
    if self.m_items and self.m_items[sort+1] then
        self.m_items[sort+1]:showUnlockAnim(self,function(self)
            self:setFireIcon(sort);
            if func then
                func(obj);
            end
        end);
    end
end

EndgateGateMap.setLocked = function(self)
    if self.m_items then
        for i,v in pairs(self.m_items) do
            v:setLocked();
        end
    end
    
	local data = EndgateData.getInstance():getEndgateData();
    local gates = data;
    local uid = UserInfo.getInstance():getUid();
	local latest_tid = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_GATE .. uid,17);
	local latest_sort = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_SORT .. uid,0);
    local last_str = "_normal";
    local lock = false;
    if not gates[self.m_index+1] or gates[self.m_index+1].tid >latest_tid then 
        lock = true;
    else
        lock = false;
    end

    if self.m_lock and self.m_lock == lock then return end
    self.m_lock = lock;
    if not self.m_title_bg then return end;
    self.m_title_bg:setVisible(not self.m_lock);
    self.m_cloud_layout:setVisible(self.m_lock);
end

EndgateGateMap.createPath = function(self)
    local node = new(Node);
    self:addChild(node);
    node:setFillParent(true,true);
    self.m_paths = {};
    for i,v in ipairs(self.m_viewConfig) do
        self.m_paths[i] = new(EndgateGatePath,i,v,self.m_scale);
        node:addChild(self.m_paths[i]);
    end
end

EndgateGateMap.createItem = function(self)
    self.m_item_group = new(Node);
    self:addChild(self.m_item_group);
    self.m_item_group:setFillParent(true,true);
    self.m_items = {};
--    for i=1,self.m_data.chessrecord_size do
--        self.m_items[i] = new(EndgateGateMapItem,i,self.m_scale,self);
--        node:addChild(self.m_items[i]);
----        self.m_items[i]:setPath(self.m_paths[i])
--    end
end

EndgateGateMap.createCloud = function(self)
    local node = new(Node);
    self:addChild(node);
    node:setFillParent(true,true);
    local w,h = self:getSize();
    self.m_clouds = {};
    for i=1,3 do
        local img = new(Image,"endgate/hall/cloud/unmove_cloud_"..i..".png");
        EndgateScene.scaleView(img,self.m_scale);
        img:setPos(0,math.random(-h/2,h/2));
        img:setAlign(kAlignTopLeft);
        self.m_clouds[#self.m_clouds+1] = {};
        self.m_clouds[#self.m_clouds].img = img;
        node:addChild(img);
        if math.random(1,2) == 1 then
            self.m_clouds[#self.m_clouds].factor = 1 -  math.random(10,20)/100;
        else
            self.m_clouds[#self.m_clouds].factor = 1 +  math.random(10,20)/100;
        end
    end
    
    for i=4,8 do
        local img = new(Image,"endgate/hall/cloud/unmove_cloud_"..i..".png");
        EndgateScene.scaleView(img,self.m_scale);
        img:setAlign(kAlignTopRight);
        img:setPos(0,math.random(-h/2,h/2));
        self.m_clouds[#self.m_clouds+1] = {};
        self.m_clouds[#self.m_clouds].img = img;
        node:addChild(img);
        if math.random(1,2) == 1 then
            self.m_clouds[#self.m_clouds].factor = 1 - math.random(10,20)/100;
        else
            self.m_clouds[#self.m_clouds].factor = 1 + math.random(10,20)/100;
        end
    end
end

EndgateGateMap.createLockCloud = function(self)
    local node = new(Node);
    self:addChild(node);
    node:setFillParent(true,true);

    local title_bg = new(Image,"endgate/hall/title/fram_bg_2.png" ,nil, nil, 32, 32, 35, 35);
    local w,h = title_bg:getSize();
    title_bg:setAlign(kAlignTop);
    title_bg:setPos(0,-h);
    self.m_title_bg = title_bg;
    node:addChild(title_bg);
    
    local data = EndgateData.getInstance():getEndgateData();
    local gates = data;
    if gates[self.m_index+1] and gates[self.m_index+1].gate_img then
        title_bg:setUrlImage(gates[self.m_index+1].gate_img,nil,Image.s_url_type_by_url);
    end
    
    title_bg:setPos(0,-h+20*self.m_scale);
    local img = new(Image,"endgate/hall/title/next_icon.png");
    EndgateScene.scaleView(img,self.m_scale);
    img:setAlign(kAlignTop);
    local sw,sh = img:getSize();
    img:setPos(0,-sh-10*self.m_scale);
    title_bg:addChild(img);

    self.m_cloud_layout = new(Node);
    node:addChild(self.m_cloud_layout);
    self.m_cloud_layout:setFillParent(true,true);
    self.m_cloud_layout:setVisible(false);

    if self.m_index > 1 then
        local aw,ah = self:getSize();
        local title_bg = new(Image,"endgate/hall/title/fram_bg_2.png" ,nil, nil, 32, 32, 35, 35);
        local w,h = title_bg:getSize();
        title_bg:setAlign(kAlignTop);
        node:addChild(title_bg);
        local data = EndgateData.getInstance():getEndgateData();
        local gates = data;
        if gates[self.m_index-1] and gates[self.m_index-1].gate_img then
            title_bg:setUrlImage(gates[self.m_index-1].gate_img,nil,Image.s_url_type_by_url);
        end
        title_bg:setPos(0,ah);
    end


    if not self.m_lock_clouds then
        self.m_lock_clouds = {};
        local config = {
            [1] = {
                ['x'] = 25;
                ['y'] = -130;
                ['ex'] = -310;
            },
            [2] = {
                ['x'] = -5;
                ['y'] = -313;
                ['ex'] = 720;
            },
            [3] = {
                ['x'] = -226;
                ['y'] = -104;
                ['ex'] = -406;
            },
            [4] = {
                ['x'] = -100;
                ['y'] = -193;
                ['ex'] = 720;
            },
            [5] = {
                ['x'] = 420;
                ['y'] = -104;
                ['ex'] = 720;
            },
            [6] = {
                ['x'] = 218;
                ['y'] = -115;
                ['ex'] = 720;
            },
            [7] = {
                ['x'] = 0;
                ['y'] = -304;
                ['ex'] = -440;
            },
            [8] = {
                ['x'] = 427;
                ['y'] = -279;
                ['ex'] = 727;
            },
        };
        for i=8,1,-1 do
            self.m_lock_clouds[i] = {};
            self.m_lock_clouds[i].view = new(Image,"endgate/hall/cloud/cloud"..i..".png");
            EndgateScene.scaleView(self.m_lock_clouds[i].view,self.m_scale);
            self.m_lock_clouds[i].config = config[i];
            self.m_lock_clouds[i].config.x = self.m_lock_clouds[i].config.x*self.m_scale;
            self.m_lock_clouds[i].config.y = self.m_lock_clouds[i].config.y*self.m_scale;
            self.m_lock_clouds[i].config.ex = self.m_lock_clouds[i].config.ex*self.m_scale;
            self.m_lock_clouds[i].view:setPos(self.m_lock_clouds[i].config.x,self.m_lock_clouds[i].config.y);
            self.m_cloud_layout:addChild(self.m_lock_clouds[i].view);
        end
        local title_bg = new(Image,"endgate/hall/title/fram_bg_1.png" ,nil, nil, 32, 32, 35, 35);
        local w,h = title_bg:getSize();
        title_bg:setAlign(kAlignTop);
        title_bg:setPos(0,-h);
        self.m_cloud_layout:addChild(title_bg);

        local width,height = 20*self.m_scale,0;

        local data = EndgateData.getInstance():getEndgateData();
        local gates = data;
        if not gates[self.m_index+1] then
            width = width + 20*self.m_scale;
            local img = new(Image,"endgate/hall/title/no_open.png");
            img:setAlign(kAlignLeft);
            img:setPos(width,0);
            EndgateScene.scaleView(img,self.m_scale);
            title_bg:addChild(img);
            local w,h = img:getSize();
            width = width + w;
            width = width + 20*self.m_scale;
            height = h + 40*self.m_scale;
            width = width + 20*self.m_scale;
            title_bg:setSize(width,height);
        else
            if gates[self.m_index+1] and gates[self.m_index+1].gate_img then
                title_bg:setUrlImage(gates[self.m_index+1].gate_img,nil,Image.s_url_type_by_url);
            end
        end


        local node = new(Node);
        title_bg:addChild(node);

        self.m_lock_img = new(Image,"endgate/hall/title/lock.png");
        EndgateScene.scaleView(self.m_lock_img,self.m_scale);
        node:setAlign(kAlignTop);
        local w,h = self.m_lock_img:getSize();
        node:setPos(0,-h-10*self.m_scale);
        node:setSize(self.m_lock_img:getSize());
        node:addChild(self.m_lock_img);

        self.m_lock_img_line_1 = new(Image,"endgate/hall/title/line.png");
        EndgateScene.scaleView(self.m_lock_img_line_1,self.m_scale);
        self.m_lock_img_line_1:setAlign(kAlignCenter);
        local sw,sh = self.m_lock_img_line_1:getSize();
        self.m_lock_img_line_1:setPos(-sw/2-w/2-10*self.m_scale,0);
        node:addChild(self.m_lock_img_line_1);

        self.m_lock_img_line_2 = new(Image,"endgate/hall/title/line.png");
        EndgateScene.scaleView(self.m_lock_img_line_2,self.m_scale);
        self.m_lock_img_line_2:setAlign(kAlignCenter);
        local sw,sh = self.m_lock_img_line_2:getSize();
        self.m_lock_img_line_2:setPos(sw/2+w/2+10*self.m_scale,0);
        node:addChild(self.m_lock_img_line_2);

        self.m_lock_img_line_3 = new(Image,"endgate/hall/title/next_icon.png");
        EndgateScene.scaleView(self.m_lock_img_line_3,self.m_scale);
        self.m_lock_img_line_3:setAlign(kAlignTop);
        local sw,sh = self.m_lock_img_line_3:getSize();
        self.m_lock_img_line_3:setPos(0,-sh-20*self.m_scale);
        title_bg:addChild(self.m_lock_img_line_3);
        self.m_lock_img_line_3:setVisible(false);
    end
end

EndgateGateMap.onScroll = function(self,diff,totalOffset,handler)
    if self.m_clouds then 
        for i,v in ipairs(self.m_clouds) do
            local img = v.img;
            local factor = v.factor;
            local x,y = img:getPos();
            img:setPos(x,y-diff*factor);
        end
    end

    local top = -totalOffset;
    local bottom = handler:getFrameLength() - totalOffset;

    for i=4,1,-1 do
        if not self.m_bgs[i+1] then
            if ( top <= self.m_bgs_config[i+1].start_y and self.m_bgs_config[i+1].start_y <= bottom ) or 
                ( top <= self.m_bgs_config[i+1].end_y and self.m_bgs_config[i+1].end_y <= bottom ) or
                ( self.m_bgs_config[i+1].start_y <= top and  top <= self.m_bgs_config[i+1].end_y ) or 
                ( self.m_bgs_config[i+1].start_y <= bottom and bottom <= self.m_bgs_config[i+1].end_y ) 
                 then
                self.m_bgs[i+1] = new(Image,"endgate/hall/map"..self.m_asset_index.."_"..i..".jpg");
                EndgateScene.scaleView(self.m_bgs[i+1],self.m_scale);
                self.m_bgs[i+1]:setPos(0,self.m_bgs_config[i+1].start_y);
                self.m_bg_group:addChild(self.m_bgs[i+1]);
            end
        end
    end

    for i=1,self.m_data.chessrecord_size do
        if not self.m_items[i] then
            local start_y = (self.m_viewConfig[i].y+200)*self.m_scale;
            local end_y = start_y + self.m_viewConfig[i].h*self.m_scale;
            if ( top <= start_y and start_y <= bottom ) or 
                ( top <= end_y and end_y <= bottom  ) or 
                ( start_y <= top and top <= end_y ) or 
                ( start_y <= bottom and bottom <= end_y  ) then
                self.m_items[i] = new(EndgateGateMapItem,i,self.m_scale,self);
                self.m_item_group:addChild(self.m_items[i]);
            end
        end
    end


--    if self.m_cloud_layout:getVisible() and self.m_lock_clouds and totalOffset >= 0 and self.m_handler.m_endgate_map then
--        local frameLength = self.m_handler.m_endgate_map:getFrameLength();
--        frameLength = frameLength*0.15;
--        local factor = totalOffset/frameLength;
--        for _,v in ipairs(self.m_lock_clouds) do
--            local x = (v.config.ex-v.config.x) * factor;
--            v.view:setPos(v.config.x+x,nil);
--        end
--    end
end

EndgateGateMap.playPassAnim = function(self,callback)
    self.m_title_bg:setVisible(false);
    self.m_cloud_layout:setVisible(true);

    local anim = self:addPropTranslate(1, kAnimNormal, 500, -1, 0, 0, 0, 200*self.m_scale);
    if not anim then return end;

    
    anim:setEvent(self,function()
        if self.m_lock_img_line_1 and self.m_lock_img_line_2 and self.m_lock_img_line_3 and self.m_lock_clouds and self.m_lock_img then
            local w,h = self.m_lock_img_line_1:getSize();
            self.m_lock_img_line_1:addPropTranslate(1, kAnimLoop, 300, -1, 0, w/3, 0, 0);
            local w,h = self.m_lock_img_line_2:getSize();
            self.m_lock_img_line_2:addPropTranslate(1, kAnimLoop, 300, -1, 0, -w/3, 0, 0);
--            self.m_lock_img:setVisible(true);
            self.m_lock_img_line_3:setVisible(true)
            self.m_lock_img:addPropTransparency(1, kAnimNormal, 500, -1, 1, 0);
            self.m_lock_img_line_3:addPropTransparency(1, kAnimNormal, 1, 500, 0, 1);


            local anim = nil;
            for i=8,1,-1 do
                anim = self.m_lock_clouds[i].view:addPropTranslate(1,kAnimNormal, 600, -1, 0, self.m_lock_clouds[i].config.ex-self.m_lock_clouds[i].config.x, 0, 0);
            end

            if anim then
                anim:setEvent(self,function()
                    self.m_lock_img:removeProp(1);
                    self.m_lock_img_line_3:removeProp(1);
                    self.m_lock_img_line_1:removeProp(1);
                    self.m_lock_img_line_2:removeProp(1);
                    self.m_lock_img_line_3:setVisible(false)
                    self:removeProp(1);
                    for i=8,1,-1 do
                        self.m_lock_clouds[i].view:removeProp(1);
                    end
                    if callback then
                        callback();
                    end
                end);
            end
        else
            self:removeProp(1);
            if callback then
                callback();
            end
        end
    end);

end

EndgateGateMapItem = class(Node)

EndgateGateMapItem.ctor = function(self,data,scale,handler)
    self.m_data = data;
    self.m_scale = scale;
    self.m_handler = handler;
    self.m_viewConfig = handler:getViewConfig();
    self.m_num_group = new(Node);
    self.m_num_group:setAlign(kAlignTop);
    self.m_icon = new(Image,self.m_viewConfig[self.m_data].lock_icon);
    self.m_icon:setAlign(kAlignTop);
    EndgateScene.scaleView(self.m_icon,self.m_scale);
    local w,h = self.m_icon:getSize();
    self.m_btn = new(Button,"drawable/blank.png");
    self.m_btn:setSize(w,h);
    self:setSize(w,h);
    self.m_btn:setAlign(kAlignTop);
    self.m_btn:setOnClick(self,self.onClick);
    self.m_btn:setSrollOnClick();
    self.m_num_group:setPos(0,h);
    self:addChild(self.m_icon);
    self:addChild(self.m_num_group);
    self:addChild(self.m_btn);

    self:setPos(self.m_viewConfig[self.m_data].x*scale,(self.m_viewConfig[self.m_data].y+200)*scale);
    self:setLocked(true);
end

EndgateGateMapItem.getGateSort = function(self)
    return self.m_data;
end

EndgateGateMapItem.showUnlockAnim = function(self,obj,func)
    self.m_icon:setFile(self.m_viewConfig[self.m_data].unlock_icon)
    delete(self.m_anim_icon);
    self.m_anim_icon = new(Image,self.m_viewConfig[self.m_data].lock_icon);
    EndgateScene.scaleView(self.m_anim_icon,self.m_scale);
    self.m_icon:addChild(self.m_anim_icon);
    self.m_anim_icon:addPropScale(1, kAnimNormal, 1000, -1, 1, 1.5, 1, 1.5, kCenterDrawing);
    local anim = self.m_anim_icon:addPropTransparency(2, kAnimNormal, 900, -1, 0.9, 0);
    anim:setEvent(self,function(self)
        if func then
            func(obj);
        end
        self:stopUnlockAnim();
    end);
end

EndgateGateMapItem.stopUnlockAnim = function(self)
    delete(self.m_anim_icon);
end

EndgateGateMapItem.onClick = function(self)
    if self.m_locked then 
        ChessToastManager.getInstance():showSingle("请您先攻克上一关,此关将自动解锁");
--        self:showUnlockAnim();
        return ;
    end
    kEndgateData:setGate(self.m_handler:getGate());
    kEndgateData:setGateSort(self:getGateSort()-1);
    RoomProxy.getInstance():gotoEndgateRoom();
end

EndgateGateMapItem.setFireIcon = function(self,view)
    if typeof(view,Button) then
        view:setOnClick(self,self.onClick);
        view:setSrollOnClick();
    end
    self.m_icon:addChild(view);
    self:setLevel(EndgateGateMapItem.firelevel);-- 防止标记被遮住;
    EndgateGateMapItem.firelevel = EndgateGateMapItem.firelevel + 1;
end

EndgateGateMapItem.firelevel = 1;

EndgateGateMapItem.setLocked = function(self)
    local uid = UserInfo.getInstance():getUid();
	local latest_tid = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_GATE .. uid,17);
	local latest_sort = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_SORT .. uid,0);

    self.m_locked = not (self.m_handler:getGateTid() < latest_tid or (self.m_handler:getGateTid() == latest_tid and (self:getGateSort()-1) <= latest_sort));

    local _last = ""

    if self.m_locked then
        _last = "_gray";
        self.m_icon:setFile(self.m_viewConfig[self.m_data].lock_icon);
    else
        _last = "";
        self.m_icon:setFile(self.m_viewConfig[self.m_data].unlock_icon);
    end

    self.m_num_group:removeAllChildren(true);

    local sort = self.m_data;
    -- 生成 <100 的 第n关
    local img = new(Image,endgate_map_num_map[string.format("end%s.png",_last)]);
    img:setAlign(kAlignRight);
    EndgateScene.scaleView(img,self.m_scale);
    self.m_num_group:addChild(img);
    local w,h = img:getSize();
    while sort > 0 do
        local num = sort % 10;
        sort = ( sort - num ) / 10;
        
        if num > 0 then
            local img = new(Image,endgate_map_num_map[string.format("%d%s.png",num,_last)]);
            img:setAlign(kAlignRight);
            EndgateScene.scaleView(img,self.m_scale);
            self.m_num_group:addChild(img);
            local aw,ah = img:getSize();
            img:setPos(w,0);
            w = w + aw;
        end

        if sort > 0 then
            local img = new(Image,endgate_map_num_map[string.format("0%s.png",_last)]);
            img:setAlign(kAlignRight);
            EndgateScene.scaleView(img,self.m_scale);
            self.m_num_group:addChild(img);
            local aw,ah = img:getSize();
            img:setPos(w,0);
            w = w + aw;
        end
        if sort == 1 then break end -- 对于 10+ 特殊处理
    end

    local img = new(Image,endgate_map_num_map[string.format("pre%s.png",_last)]);
    img:setAlign(kAlignRight);
    EndgateScene.scaleView(img,self.m_scale);
    self.m_num_group:addChild(img);
    local aw,ah = img:getSize();
    img:setPos(w,0);
    w = w + aw;
    self.m_num_group:setSize(w,h);

    self:setPath();
end

EndgateGateMapItem.setPath = function(self,view)
    self.m_path_view = view or self.m_path_view;
    if not self.m_path_view then return end
    local uid = UserInfo.getInstance():getUid();
	local latest_tid = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_GATE .. uid,17);
	local latest_sort = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_SORT .. uid,0);

    if not self.m_locked and (self:getGateSort()-1) < latest_sort then
        self.m_path_view:setFile(endgate_map_path_map[(self.m_data)..'.png']);
    else
        self.m_path_view:setFile(endgate_map_path_map[(self.m_data)..'_gray.png']);
    end
end

EndgateGateMapCloudConfig = {
    [1] = {
        ['align'] = kAlignTopLeft,
    },
    [2] = {
        ['align'] = kAlignTopLeft,
    },
    [3] = {
        ['align'] = kAlignTopLeft,
    },
    [4] = {
        ['align'] = kAlignTopRight,
    },
    [5] = {
        ['align'] = kAlignTopRight,
    },
    [6] = {
        ['align'] = kAlignTopRight,
    },
    [7] = {
        ['align'] = kAlignTopRight,
    },
    [8] = {
        ['align'] = kAlignTopRight,
    },
}
EndgateGateMapConfig = {};
EndgateGateMapConfig[1] = {
    [1] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 242,
        ['y'] = 4372,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [2] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 107,
        ['y'] = 4280,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [3] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 105,
        ['y'] = 4129,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [4] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 270,
        ['y'] = 4205,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [5] = {
        ['lock_icon'] = 'endgate/hall/dec_3_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_3_normal.png',
        ['w'] = 88,
        ['h'] = 96,
        ['x'] = 383,
        ['y'] = 4064,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [6] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 561,
        ['y'] = 4015,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [7] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 580,
        ['y'] = 3855,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [8] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 520,
        ['y'] = 3721,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [9] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 396,
        ['y'] = 3843,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [10] = {
        ['lock_icon'] = 'endgate/hall/dec_2_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_2_normal.png',
        ['w'] = 179,
        ['h'] = 146,
        ['x'] = 256,
        ['y'] = 3608,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [11] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 140,
        ['y'] = 3744,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [12] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 48,
        ['y'] = 3639,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [13] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 139,
        ['y'] = 3474,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [14] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 287,
        ['y'] = 3439,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [15] = {
        ['lock_icon'] = 'endgate/hall/dec_5_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_5_normal.png',
        ['w'] = 106,
        ['h'] = 105,
        ['x'] = 428,
        ['y'] = 3384,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [16] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 542,
        ['y'] = 3272,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [17] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 364,
        ['y'] = 3245,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [18] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 195,
        ['y'] = 3226,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [19] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 66,
        ['y'] = 3121,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [20] = {
        ['lock_icon'] = 'endgate/hall/dec_2_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_2_normal.png',
        ['w'] = 179,
        ['h'] = 146,
        ['x'] = 48,
        ['y'] = 2889,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [21] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 324,
        ['y'] = 2921,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [22] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 487,
        ['y'] = 2842,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [23] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 546,
        ['y'] = 2695,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [24] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 355,
        ['y'] = 2648,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [25] = {
        ['lock_icon'] = 'endgate/hall/dec_4_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_4_normal.png',
        ['w'] = 109,
        ['h'] = 73,
        ['x'] = 491,
        ['y'] = 2507,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [26] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 377,
        ['y'] = 2439,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [27] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 185,
        ['y'] = 2514,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [28] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 83,
        ['y'] = 2399,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [29] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 182,
        ['y'] = 2260,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [30] = {
        ['lock_icon'] = 'endgate/hall/dec_2_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_2_normal.png',
        ['w'] = 179,
        ['h'] = 146,
        ['x'] = 290,
        ['y'] = 2075,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [31] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 536,
        ['y'] = 1996,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [32] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 332,
        ['y'] = 1982,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [33] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 103,
        ['y'] = 1928,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [34] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 244,
        ['y'] = 1782,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [35] = {
        ['lock_icon'] = 'endgate/hall/dec_3_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_3_normal.png',
        ['w'] = 88,
        ['h'] = 96,
        ['x'] = 435,
        ['y'] = 1664,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [36] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 394,
        ['y'] = 1564,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [37] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 197,
        ['y'] = 1564,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [38] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 258,
        ['y'] = 1413,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [39] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 326,
        ['y'] = 1282,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [40] = {
        ['lock_icon'] = 'endgate/hall/dec_2_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_2_normal.png',
        ['w'] = 179,
        ['h'] = 146,
        ['x'] = 485,
        ['y'] = 1125,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [41] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 491,
        ['y'] = 1001,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [42] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 496,
        ['y'] = 863,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [43] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 332,
        ['y'] = 836,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [44] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 163,
        ['y'] = 807,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [45] = {
        ['lock_icon'] = 'endgate/hall/dec_5_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_5_normal.png',
        ['w'] = 106,
        ['h'] = 105,
        ['x'] = 174,
        ['y'] = 574,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [46] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 404,
        ['y'] = 598,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [47] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 268,
        ['y'] = 486,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [48] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 84,
        ['y'] = 407,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [49] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 296,
        ['y'] = 301,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [50] = {
        ['lock_icon'] = 'endgate/hall/dec_1_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_1_normal.png',
        ['w'] = 263,
        ['h'] = 199,
        ['x'] = 253,
        ['y'] = 37,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
}
EndgateGateMapConfig[2] = {
    [1] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 572,
        ['y'] = 4291,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [2] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 569,
        ['y'] = 4103,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [3] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 391,
        ['y'] = 4110,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [4] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 232,
        ['y'] = 4229,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [5] = {
        ['lock_icon'] = 'endgate/hall/dec_3_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_3_normal.png',
        ['w'] = 88,
        ['h'] = 96,
        ['x'] = 75,
        ['y'] = 4094,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [6] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 168,
        ['y'] = 3958,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [7] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 223,
        ['y'] = 3810,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [8] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 377,
        ['y'] = 3742,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [9] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 562,
        ['y'] = 3697,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [10] = {
        ['lock_icon'] = 'endgate/hall/dec_2_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_2_normal.png',
        ['w'] = 179,
        ['h'] = 146,
        ['x'] = 382,
        ['y'] = 3494,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [11] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 212,
        ['y'] = 3534,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [12] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 119,
        ['y'] = 3406,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [13] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 225,
        ['y'] = 3264,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [14] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 428,
        ['y'] = 3238,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [15] = {
        ['lock_icon'] = 'endgate/hall/dec_5_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_5_normal.png',
        ['w'] = 106,
        ['h'] = 105,
        ['x'] = 589,
        ['y'] = 3099,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [16] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 508,
        ['y'] = 2974,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [17] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 317,
        ['y'] = 2929,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [18] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 138,
        ['y'] = 2866,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [19] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 86,
        ['y'] = 2722,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [20] = {
        ['lock_icon'] = 'endgate/hall/dec_2_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_2_normal.png',
        ['w'] = 179,
        ['h'] = 146,
        ['x'] = 139,
        ['y'] = 2427,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [21] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 388,
        ['y'] = 2691,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [22] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 552,
        ['y'] = 2546,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [23] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 531,
        ['y'] = 2372,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [24] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 379,
        ['y'] = 2246,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [25] = {
        ['lock_icon'] = 'endgate/hall/dec_4_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_4_normal.png',
        ['w'] = 109,
        ['h'] = 73,
        ['x'] = 104,
        ['y'] = 2196,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [26] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 177,
        ['y'] = 2036,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [27] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 351,
        ['y'] = 1956,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [28] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 514,
        ['y'] = 1836,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [29] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 540,
        ['y'] = 1668,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [30] = {
        ['lock_icon'] = 'endgate/hall/dec_2_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_2_normal.png',
        ['w'] = 179,
        ['h'] = 146,
        ['x'] = 314,
        ['y'] = 1530,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [31] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 150,
        ['y'] = 1668,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [32] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 110,
        ['y'] = 1519,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [33] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 130,
        ['y'] = 1337,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [34] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 263,
        ['y'] = 1238,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [35] = {
        ['lock_icon'] = 'endgate/hall/dec_3_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_3_normal.png',
        ['w'] = 88,
        ['h'] = 96,
        ['x'] = 442,
        ['y'] = 1183,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [36] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 540,
        ['y'] = 1043,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [37] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 500,
        ['y'] = 901,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [38] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 314,
        ['y'] = 933,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [39] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 113,
        ['y'] = 982,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [40] = {
        ['lock_icon'] = 'endgate/hall/dec_2_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_2_normal.png',
        ['w'] = 179,
        ['h'] = 146,
        ['x'] = 131,
        ['y'] = 758,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [41] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 430,
        ['y'] = 775,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [42] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 595,
        ['y'] = 670,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [43] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 517,
        ['y'] = 527,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [44] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 334,
        ['y'] = 487,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [45] = {
        ['lock_icon'] = 'endgate/hall/dec_5_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_5_normal.png',
        ['w'] = 106,
        ['h'] = 105,
        ['x'] = 107,
        ['y'] = 429,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [46] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 169,
        ['y'] = 329,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [47] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 333,
        ['y'] = 345,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [48] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 504,
        ['y'] = 371,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [49] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 549,
        ['y'] = 244,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [50] = {
        ['lock_icon'] = 'endgate/hall/dec_1_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_1_normal.png',
        ['w'] = 263,
        ['h'] = 199,
        ['x'] = 272,
        ['y'] = 47,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },

}

EndgateGateMapConfig[3] = {
    [1] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 114,
        ['y'] = 4343,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [2] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 224,
        ['y'] = 4233,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [3] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 390,
        ['y'] = 4216,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [4] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 550,
        ['y'] = 4210,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [5] = {
        ['lock_icon'] = 'endgate/hall/dec_3_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_3_normal.png',
        ['w'] = 88,
        ['h'] = 96,
        ['x'] = 469,
        ['y'] = 4064,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [6] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 338,
        ['y'] = 4072,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [7] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 545,
        ['y'] = 3934,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [8] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 486,
        ['y'] = 3819,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [9] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 338,
        ['y'] = 3770,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [10] = {
        ['lock_icon'] = 'endgate/hall/dec_2_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_2_normal.png',
        ['w'] = 179,
        ['h'] = 146,
        ['x'] = 111,
        ['y'] = 3610,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [11] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 312,
        ['y'] = 3529,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [12] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 471,
        ['y'] = 3484,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [13] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 529,
        ['y'] = 3340,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [14] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 372,
        ['y'] = 3272,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [15] = {
        ['lock_icon'] = 'endgate/hall/dec_5_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_5_normal.png',
        ['w'] = 106,
        ['h'] = 105,
        ['x'] = 163,
        ['y'] = 3179,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [16] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 153,
        ['y'] = 3054,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [17] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 274,
        ['y'] = 2922,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [18] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 136,
        ['y'] = 2849,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [19] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 160,
        ['y'] = 2666,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [20] = {
        ['lock_icon'] = 'endgate/hall/dec_2_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_2_normal.png',
        ['w'] = 179,
        ['h'] = 146,
        ['x'] = 361,
        ['y'] = 2668,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [21] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 517,
        ['y'] = 2588,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [22] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 520,
        ['y'] = 2410,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [23] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 492,
        ['y'] = 2267,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [24] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 328,
        ['y'] = 2330,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [25] = {
        ['lock_icon'] = 'endgate/hall/dec_4_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_4_normal.png',
        ['w'] = 109,
        ['h'] = 73,
        ['x'] = 115,
        ['y'] = 2310,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [26] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 275,
        ['y'] = 2168,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [27] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 195,
        ['y'] = 2032,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [28] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 380,
        ['y'] = 1964,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [29] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 491,
        ['y'] = 1846,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [30] = {
        ['lock_icon'] = 'endgate/hall/dec_2_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_2_normal.png',
        ['w'] = 179,
        ['h'] = 146,
        ['x'] = 403,
        ['y'] = 1606,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [31] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 283,
        ['y'] = 1572,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [32] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 163,
        ['y'] = 1478,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [33] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 271,
        ['y'] = 1353,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [34] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 454,
        ['y'] = 1282,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [35] = {
        ['lock_icon'] = 'endgate/hall/dec_3_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_3_normal.png',
        ['w'] = 88,
        ['h'] = 96,
        ['x'] = 532,
        ['y'] = 1113,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [36] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 434,
        ['y'] = 1055,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [37] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 245,
        ['y'] = 1060,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [38] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 157,
        ['y'] = 955,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [39] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 331,
        ['y'] = 928,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [40] = {
        ['lock_icon'] = 'endgate/hall/dec_2_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_2_normal.png',
        ['w'] = 179,
        ['h'] = 146,
        ['x'] = 440,
        ['y'] = 814,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [41] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 301,
        ['y'] = 802,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [42] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 102,
        ['y'] = 786,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [43] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 62,
        ['y'] = 655,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [44] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 237,
        ['y'] = 628,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [45] = {
        ['lock_icon'] = 'endgate/hall/dec_5_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_5_normal.png',
        ['w'] = 106,
        ['h'] = 105,
        ['x'] = 393,
        ['y'] = 548,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [46] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 348,
        ['y'] = 449,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [47] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 578,
        ['y'] = 381,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [48] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 509,
        ['y'] = 273,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [49] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 349,
        ['y'] = 297,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [50] = {
        ['lock_icon'] = 'endgate/hall/dec_1_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_1_normal.png',
        ['w'] = 263,
        ['h'] = 199,
        ['x'] = 41,
        ['y'] = 184,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },

}

EndgateGateMapConfig[4] = {
    [1] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 313,
        ['y'] = 4337,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [2] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 206,
        ['y'] = 4256,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [3] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 55,
        ['y'] = 4203,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [4] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 268,
        ['y'] = 4150,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [5] = {
        ['lock_icon'] = 'endgate/hall/dec_3_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_3_normal.png',
        ['w'] = 88,
        ['h'] = 96,
        ['x'] = 429,
        ['y'] = 4112,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [6] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 590,
        ['y'] = 4065,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [7] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 546,
        ['y'] = 3928,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [8] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 403,
        ['y'] = 3877,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [9] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 251,
        ['y'] = 3844,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [10] = {
        ['lock_icon'] = 'endgate/hall/dec_2_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_2_normal.png',
        ['w'] = 179,
        ['h'] = 146,
        ['x'] = 51,
        ['y'] = 3667,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [11] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 260,
        ['y'] = 3602,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [12] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 422,
        ['y'] = 3535,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [13] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 573,
        ['y'] = 3454,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [14] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 561,
        ['y'] = 3279,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [15] = {
        ['lock_icon'] = 'endgate/hall/dec_5_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_5_normal.png',
        ['w'] = 106,
        ['h'] = 105,
        ['x'] = 408,
        ['y'] = 3144,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [16] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 246,
        ['y'] = 3141,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [17] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 79,
        ['y'] = 3103,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [18] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 177,
        ['y'] = 2987,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [19] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 311,
        ['y'] = 2908,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [20] = {
        ['lock_icon'] = 'endgate/hall/dec_2_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_2_normal.png',
        ['w'] = 179,
        ['h'] = 146,
        ['x'] = 289,
        ['y'] = 2707,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [21] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 131,
        ['y'] = 2788,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [22] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 163,
        ['y'] = 2639,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [23] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 363,
        ['y'] = 2603,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [24] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 544,
        ['y'] = 2559,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [25] = {
        ['lock_icon'] = 'endgate/hall/dec_4_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_4_normal.png',
        ['w'] = 109,
        ['h'] = 73,
        ['x'] = 514,
        ['y'] = 2343,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [26] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 342,
        ['y'] = 2373,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [27] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 162,
        ['y'] = 2314,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [28] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 202,
        ['y'] = 2176,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [29] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 89,
        ['y'] = 2040,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [30] = {
        ['lock_icon'] = 'endgate/hall/dec_2_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_2_normal.png',
        ['w'] = 179,
        ['h'] = 146,
        ['x'] = 258,
        ['y'] = 1952,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [31] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 543,
        ['y'] = 2054,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [32] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 565,
        ['y'] = 1886,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [33] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 423,
        ['y'] = 1788,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [34] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 268,
        ['y'] = 1708,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [35] = {
        ['lock_icon'] = 'endgate/hall/dec_3_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_3_normal.png',
        ['w'] = 88,
        ['h'] = 96,
        ['x'] = 331,
        ['y'] = 1533,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [36] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 411,
        ['y'] = 1417,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [37] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 315,
        ['y'] = 1292,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [38] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 153,
        ['y'] = 1203,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [39] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 359,
        ['y'] = 1163,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [40] = {
        ['lock_icon'] = 'endgate/hall/dec_2_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_2_normal.png',
        ['w'] = 179,
        ['h'] = 146,
        ['x'] = 422,
        ['y'] = 999,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [41] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 338,
        ['y'] = 917,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [42] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 207,
        ['y'] = 841,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [43] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 324,
        ['y'] = 747,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [44] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 404,
        ['y'] = 614,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [45] = {
        ['lock_icon'] = 'endgate/hall/dec_5_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_5_normal.png',
        ['w'] = 106,
        ['h'] = 105,
        ['x'] = 531,
        ['y'] = 483,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [46] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 378,
        ['y'] = 479,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [47] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 219,
        ['y'] = 439,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [48] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 72,
        ['y'] = 375,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [49] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 259,
        ['y'] = 301,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [50] = {
        ['lock_icon'] = 'endgate/hall/dec_1_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_1_normal.png',
        ['w'] = 263,
        ['h'] = 199,
        ['x'] = 265,
        ['y'] = 72,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },

} 
EndgateGateMapConfig[5] = {
    [1] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 392,
        ['y'] = 4385,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [2] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 571,
        ['y'] = 4320,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [3] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 474,
        ['y'] = 4216,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [4] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 311,
        ['y'] = 4251,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [5] = {
        ['lock_icon'] = 'endgate/hall/dec_3_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_3_normal.png',
        ['w'] = 88,
        ['h'] = 96,
        ['x'] = 167,
        ['y'] = 4128,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [6] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 95,
        ['y'] = 4030,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [7] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 263,
        ['y'] = 3962,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [8] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 424,
        ['y'] = 3938,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [9] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 561,
        ['y'] = 3855,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [10] = {
        ['lock_icon'] = 'endgate/hall/dec_2_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_2_normal.png',
        ['w'] = 179,
        ['h'] = 146,
        ['x'] = 329,
        ['y'] = 3630,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [11] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 189,
        ['y'] = 3734,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [12] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 85,
        ['y'] = 3625,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [13] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 204,
        ['y'] = 3504,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [14] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 361,
        ['y'] = 3444,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [15] = {
        ['lock_icon'] = 'endgate/hall/dec_5_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_5_normal.png',
        ['w'] = 106,
        ['h'] = 105,
        ['x'] = 515,
        ['y'] = 3317,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [16] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 552,
        ['y'] = 3136,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [17] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 370,
        ['y'] = 3061,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [18] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 189,
        ['y'] = 3068,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [19] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 95,
        ['y'] = 2946,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [20] = {
        ['lock_icon'] = 'endgate/hall/dec_2_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_2_normal.png',
        ['w'] = 179,
        ['h'] = 146,
        ['x'] = 248,
        ['y'] = 2827,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [21] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 541,
        ['y'] = 2844,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [22] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 576,
        ['y'] = 2631,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [23] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 393,
        ['y'] = 2563,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [24] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 193,
        ['y'] = 2544,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [25] = {
        ['lock_icon'] = 'endgate/hall/dec_4_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_4_normal.png',
        ['w'] = 109,
        ['h'] = 73,
        ['x'] = 84,
        ['y'] = 2395,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [26] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 285,
        ['y'] = 2322,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [27] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 462,
        ['y'] = 2338,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [28] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 506,
        ['y'] = 2186,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [29] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 277,
        ['y'] = 2167,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [30] = {
        ['lock_icon'] = 'endgate/hall/dec_2_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_2_normal.png',
        ['w'] = 179,
        ['h'] = 146,
        ['x'] = 26,
        ['y'] = 1990,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [31] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 231,
        ['y'] = 1901,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [32] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 373,
        ['y'] = 1986,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [33] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 567,
        ['y'] = 1999,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [34] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 500,
        ['y'] = 1830,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [35] = {
        ['lock_icon'] = 'endgate/hall/dec_3_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_3_normal.png',
        ['w'] = 88,
        ['h'] = 96,
        ['x'] = 289,
        ['y'] = 1719,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [36] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 131,
        ['y'] = 1644,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [37] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 328,
        ['y'] = 1604,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [38] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 518,
        ['y'] = 1584,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [39] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 478,
        ['y'] = 1422,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [40] = {
        ['lock_icon'] = 'endgate/hall/dec_2_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_2_normal.png',
        ['w'] = 179,
        ['h'] = 146,
        ['x'] = 221,
        ['y'] = 1273,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [41] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 98,
        ['y'] = 1201,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [42] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 164,
        ['y'] = 1028,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [43] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 351,
        ['y'] = 1091,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [44] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 566,
        ['y'] = 1023,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [45] = {
        ['lock_icon'] = 'endgate/hall/dec_5_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_5_normal.png',
        ['w'] = 106,
        ['h'] = 105,
        ['x'] = 420,
        ['y'] = 774,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [46] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 213,
        ['y'] = 718,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [47] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 66,
        ['y'] = 556,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [48] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 271,
        ['y'] = 513,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [49] = {
        ['lock_icon'] = 'endgate/hall/btn_nopass.png',
        ['unlock_icon'] = 'endgate/hall/btn_pass.png',
        ['w'] = 50,
        ['h'] = 53,
        ['x'] = 486,
        ['y'] = 449,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
    [50] = {
        ['lock_icon'] = 'endgate/hall/dec_1_gray.png',
        ['unlock_icon'] = 'endgate/hall/dec_1_normal.png',
        ['w'] = 263,
        ['h'] = 199,
        ['x'] = 317,
        ['y'] = 150,
        ['path'] = {
            ['x'] = 591,
            ['y'] = 4330,
        },
    },
}
