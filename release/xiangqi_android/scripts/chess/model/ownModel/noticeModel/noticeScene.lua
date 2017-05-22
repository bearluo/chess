--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23

require(BASE_PATH.."chessScene");


NoticeScene = class(ChessScene);

NoticeScene.s_controls = 
{
    back_btn                    = 1;
    title_icon                  = 2;
    notice_view                 = 3;
    teapot_dec                  = 4;
}

NoticeScene.s_cmds = 
{
    update_notice_view          = 1;
    del_notice_view_item        = 2;
}




NoticeScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = NoticeScene.s_controls;
    self:create();
end 

NoticeScene.resume = function(self)
    ChessScene.resume(self);
--    self:removeAnimProp();
--    self:resumeAnimStart();
end

NoticeScene.isShowBangdinDialog = false;

NoticeScene.pause = function(self)
	ChessScene.pause(self);
    self:removeAnimProp();
--    self:pauseAnimStart();
end 

NoticeScene.dtor = function(self)
    delete(self.anim_start);
    delete(self.anim_end);
end 

NoticeScene.removeAnimProp = function(self)
    if self.m_anim_prop_need_remove then
        self.m_notice_view:removeProp(1);
        self.m_title_icon:removeProp(1);
--        self.m_back_btn:removeProp(1);
        self.m_leaf_left:removeProp(1);
    --    self.m_top_view:removeProp(1);
    --    self.m_more_btn:removeProp(1);
    --    self.m_bottom_view:removeProp(1);
        self.m_anim_prop_need_remove = false;
    end
end

NoticeScene.setAnimItemEnVisible = function(self,ret)
    self.m_leaf_left:setVisible(ret);
end

NoticeScene.resumeAnimStart = function(self,lastStateObj,timer)
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

    self.m_notice_view:addPropTransparency(1,kAnimNormal,waitTime,delay,0,1);
    local lw,lh = self.m_leaf_left:getSize();
    self.m_leaf_left:addPropTranslate(1, kAnimNormal, waitTime, delay, -lw, 0, -10, 0);
    local tw,th = self.m_title_icon:getSize();
    local anim = self.m_title_icon:addPropTranslate(1, kAnimNormal, waitTime, delay, 0, 0, -th, 0);
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

NoticeScene.pauseAnimStart = function(self,newStateObj,timer)
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;
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

    self.m_notice_view:addPropTransparency(1,kAnimNormal,waitTime,-1,1,0);
    local lw,lh = self.m_leaf_left:getSize();
    self.m_leaf_left:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, -lw, 0, -10);
    local w,h = self.m_title_icon:getSize();
    local anim = self.m_title_icon:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, 0, 0, -h);
    if anim then
        anim:setEvent(self,function()
            self:setAnimItemEnVisible(false);
        end);
    end
end

---------------------- func --------------------
NoticeScene.create = function(self)
	self.m_back_btn = self:findViewById(self.m_ctrls.back_btn);
	self.m_title_icon = self:findViewById(self.m_ctrls.title_icon);
    self.m_leaf_left = self.m_root:getChildByName("bamboo_left");

    self.m_notice_view = self:findViewById(self.m_ctrls.notice_view);

    self.m_notice_content_view = self.m_notice_view:getChildByName("notice_content_view");
    self.m_notice_content_view.m_autoPositionChildren = true;
    self.m_notice_content_text = self.m_notice_view:getChildByName("text");
    self.m_notice_content_view:setOnScrollEvent(self,self.onScroll);
    self.m_notice_mask_view = self.m_notice_view:getChildByName("bg");
    self.m_notice_mask_view:setEventTouch(self,self.onTouchEvent);
	self.m_notice_content_view:removeAllChildren();
    self.m_notice_content_text:setVisible(true);
    self.m_scrollY = 0;
    self.itemViews = {};
end

NoticeScene.onBackAction = function(self)
    self:requestCtrlCmd(NoticeController.s_cmds.onBack);
end

NoticeScene.onUserInfoSceneNoticeMsgListItem = function(self,data)
    if data then
		self:requestCtrlCmd(NoticeController.s_cmds.del_notice_msg,data.id);
	end
end


NoticeScene.onScroll = function(self, scroll_status, diffY, totalOffset,isMarginRebounding)
    local viewLength = self.m_notice_content_view:getViewLength(); -- 界面长度
    local frameLength = self.m_notice_content_view:getFrameLength(); -- 可见区域长度
    if frameLength - totalOffset == viewLength and scroll_status == kScrollerStatusStop and not self:requestCtrlCmd(NoticeController.s_cmds.isNoMoreData) then 
        self:requestCtrlCmd(NoticeController.s_cmds.get_notice_msg);
        self.m_scrollY = totalOffset;
    elseif frameLength - totalOffset == viewLength and scroll_status == kScrollerStatusStop and self:requestCtrlCmd(NoticeController.s_cmds.isNoMoreData) then
        ChessToastManager.getInstance():showSingle("没有更多数据了",1000);
    end
end

NoticeScene.updateNoticeView = function(self,list)
    if list then
		self.m_notice_content_view:removeAllChildren();
        local flag = false;
        self.m_notice_content_text:setVisible(false);
        self.itemViews = {};
		for k,v in pairs(list) do
            local msgItem = new(UserInfoSceneNoticeMsgListItem,v,self);
            msgItem:setHandler(self);
			self.m_notice_content_view:addChild(msgItem);
            flag = true;
            self.itemViews[v.id] = msgItem;
		end
        local viewLength = self.m_notice_content_view:getViewLength(); -- 界面长度
        local frameLength = self.m_notice_content_view:getFrameLength(); -- 可见区域长度
        if viewLength > frameLength and self.m_scrollY < frameLength - viewLength then
            self.m_scrollY = frameLength - viewLength;
        elseif viewLength <= frameLength then
            self.m_scrollY = 0;
        end
        if self.m_scrollY ~= 0 then
            self.m_scrollY = self.m_scrollY - 30;
        end
        self.m_notice_content_view:scrollToPos(self.m_scrollY);

        if not flag then 
            self.m_notice_content_text:setVisible(true);
        end
	end
    if self:requestCtrlCmd(NoticeController.s_cmds.isNoMoreData) then
        ChessToastManager.getInstance():showSingle("没有更多数据了",1000);
    end
end

function NoticeScene:checkNeedSeedGetMailMsg()
    local viewLength = self.m_notice_content_view:getViewLength(); -- 界面长度
    local frameLength = self.m_notice_content_view:getFrameLength(); -- 可见区域长度
    return viewLength <= frameLength and not self:requestCtrlCmd(NoticeController.s_cmds.isNoMoreData);
end

function NoticeScene:delNoticeViewItem(id)
    if self.itemViews[id] then
        local x,y = self.m_notice_content_view:getScrollViewPos();
        self.m_notice_content_view:scrollToPos(0);
        delete(self.itemViews[id]);
        self.m_notice_content_view:setScrollEnable(true)
        self.m_notice_content_view:updateScrollView();
        local viewLength = self.m_notice_content_view:getViewLength(); -- 界面长度
        local frameLength = self.m_notice_content_view:getFrameLength(); -- 可见区域长度
        if self:checkNeedSeedGetMailMsg() then
            self:requestCtrlCmd(NoticeController.s_cmds.get_notice_msg);
            self.m_scrollY = y;
        end
        if viewLength > frameLength and y < frameLength - viewLength then
            y = frameLength - viewLength;
        elseif viewLength <= frameLength then
            y = 0;
        end
        self.m_notice_content_view:scrollToPos(y);
    end
end

function NoticeScene:onTouchEvent()
    if UserInfoSceneNoticeMsgListItem.cur_item and UserInfoSceneNoticeMsgListItem.cur_item.status == UserInfoSceneNoticeMsgListItem.STATUS_DEL then
        UserInfoSceneNoticeMsgListItem.cur_item.status = UserInfoSceneNoticeMsgListItem.STATUS_NOR;
        UserInfoSceneNoticeMsgListItem.cur_item.isOnTouchClick = false;
        UserInfoSceneNoticeMsgListItem.cur_item:addScrollAnim();
    end
end

---------------------- config ------------------
NoticeScene.s_controlConfig = {
    [NoticeScene.s_controls.back_btn]                          = {"back_btn"};
    [NoticeScene.s_controls.title_icon]                        = {"title_icon"};
    [NoticeScene.s_controls.notice_view]                       = {"notice_view"};
    [NoticeScene.s_controls.teapot_dec]                        = {"teapot_dec"};
}

NoticeScene.s_controlFuncMap = {
    [NoticeScene.s_controls.back_btn]                        = NoticeScene.onBackAction;
};

NoticeScene.s_cmdConfig =
{
    [NoticeScene.s_cmds.update_notice_view]                  = NoticeScene.updateNoticeView;
    [NoticeScene.s_cmds.del_notice_view_item]                = NoticeScene.delNoticeViewItem;
    
}


UserInfoSceneNoticeMsgListItem = class(Node);
UserInfoSceneNoticeMsgListItem.cur_item = nil;
UserInfoSceneNoticeMsgListItem.ctor = function(self,data,handler)
    self.sceneHandler = handler;
	self.data = data;
    self.clickClip = 20;
    require(VIEW_PATH.."notice_view_mail_item");
    self.scene = SceneLoader.load(notice_view_mail_item);
    self:addChild(self.scene);
    local w,h = self.scene:getSize();
    self:setSize(w,h);
    self.scrollView = self.scene:getChildByName("scroll_view");
    self.delHandler = self.scene:getChildByName("del_handler");
    self.mailType = self.scrollView:getChildByName("top_view"):getChildByName("mail_type");
    self.mailTime = self.scrollView:getChildByName("top_view"):getChildByName("mail_time");
    self.mailTitle = self.scrollView:getChildByName("mail_title");
    self.newSign = self.scrollView:getChildByName("new_sign");
    self.tonchHandler = self.scrollView:getChildByName("tonch_handler");
    
    self:createDelBtn();

    if data.is_see == "0" then
        self.newSign:setVisible(true);
    else
        self.newSign:setVisible(false);
    end

    local mailType = "消息";
    if data.mail_type == kMailAll then
         mailType = "全服消息";
    elseif data.mail_type == kMailSys then
         mailType = "系统消息";
    elseif data.mail_type == kMailUser then
         mailType = "用户消息";
    end
    
    local mailTimeTab = os.date("*t",data.mail_time);
    local mailTime = string.format("%d月%d日  %02d:%02d",mailTimeTab.month,mailTimeTab.day,mailTimeTab.hour,mailTimeTab.min)

    local mailTitle = data.mail_title;

    self.mailType:setText(mailType);
    self.mailTime:setText(mailTime);
    self.mailTitle:setText(mailTitle);

    self.tonchHandler:setEventTouch(self,self.onTouchEvent);

    self.status = UserInfoSceneNoticeMsgListItem.STATUS_NOR;
end

UserInfoSceneNoticeMsgListItem.createDelBtn = function(self)
    local w,h = self.delHandler:getSize();
    self.limitMove = w/2;
    w = w * System.getLayoutScale();
    h = h * System.getLayoutScale();
    local x,y = 0,0;self.delHandler:getUnalignPos();
    local vertices = {  
        x,y,
        x,y+h,
        x+w,y+h,
        x+w,y,
    }
    local indices = {
        0,1,2,
        0,2,3,
    }

--    local colorArray = {
--        0.86,0.29,0.29,1.0,
--        0.86,0.29,0.29,1.0,
--        0.86,0.29,0.29,1.0,
--        0.86,0.29,0.29,1.0,
--    }
    local colorArray = {
        0.8,0.2,0.2,1.0,
        0.8,0.2,0.2,1.0,
        0.8,0.2,0.2,1.0,
        0.8,0.2,0.2,1.0,
    }
    self.customNode = new(CustomNode,nil,kRenderDataColors, vertices, indices, textureFile, textureCoords, colorArray);
    self.delHandler:getChildByName("bg"):addChild(self.customNode);
    self.customNode:setPos(0,0);
    self.delHandler:setEventTouch(self,self.onBtnClick);
end

UserInfoSceneNoticeMsgListItem.getData = function(self)
	return self.data;
end

UserInfoSceneNoticeMsgListItem.setHandler = function(self,handler)
    self.m_handler = handler;
end

UserInfoSceneNoticeMsgListItem.onBtnClick = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
	print_string("UserInfoSceneNoticeMsgListItem.onBtnClick");
    if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
        self.m_handler.onUserInfoSceneNoticeMsgListItem(self.m_handler,self.data);
    end
end

UserInfoSceneNoticeMsgListItem.STATUS_NOR = 1;
UserInfoSceneNoticeMsgListItem.STATUS_DEL = 2;

UserInfoSceneNoticeMsgListItem.onTouchEvent = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
    if finger_action == kFingerDown then
        self.mFingerDownTime = os.clock();
        self.mFingerDownX = x;
        self.mFingerDownY = y;
        self.mFingerMoveX = x;
        self.mFingerMoveY = y;
        self.isOnTouchClick = true;
        self.isOnDelClick = false;
        self:stopScrollAnim();
        if UserInfoSceneNoticeMsgListItem.cur_item and UserInfoSceneNoticeMsgListItem.cur_item.status == UserInfoSceneNoticeMsgListItem.STATUS_DEL then
            UserInfoSceneNoticeMsgListItem.cur_item.status = UserInfoSceneNoticeMsgListItem.STATUS_NOR;
            UserInfoSceneNoticeMsgListItem.cur_item.isOnTouchClick = false;
            UserInfoSceneNoticeMsgListItem.cur_item:addScrollAnim();
            self.isOnTouchClick = false;
        end
        UserInfoSceneNoticeMsgListItem.cur_item = self;
    elseif finger_action == kFingerMove then
        if math.abs(self.mFingerDownY-y) > self.clickClip then
            self.isOnTouchClick = false;
        end

        if math.abs(self.mFingerDownX - x) > self.clickClip and self.isOnTouchClick then
            self.isOnTouchClick = false;
            self.isOnDelClick = true;
            if self.sceneHandler and self.sceneHandler.m_notice_content_view then
            -- 关闭scrollview 滚动
                ScrollView.onEventDrag(self.sceneHandler.m_notice_content_view,kFingerUp,x, y, drawing_id_first, drawing_id_current)
            end
        end


        if not self.isOnTouchClick and self.isOnDelClick then
            local length = x - self.mFingerMoveX;
            self:onScrollViewChange(length);
            self:onDelHandlerChange(2*length);
            local x,y = self.delHandler:getPos();
            local w,h = self.delHandler:getSize();
            if -x > w/2 then
                self.status = UserInfoSceneNoticeMsgListItem.STATUS_NOR;
            else
                self.status = UserInfoSceneNoticeMsgListItem.STATUS_DEL;
            end
        end
        self.mFingerMoveX = x;
        self.mFingerMoveY = y;
    elseif finger_action == kFingerUp then
        if drawing_id_first == drawing_id_current then
            local w,h = self.scene:getSize();
            if math.abs(self.mFingerDownY-y) > self.clickClip then
                self.isOnTouchClick = false;
            end
            if self.isOnTouchClick then
                self.newSign:setVisible(false);
                local params = {};
                params.mail_id = self.data.id;
                HttpModule.getInstance():execute(HttpModule.s_cmds.UserMailSeeMail,params);
                require(DIALOG_PATH .. "notice_view_mail_dialog");
                if not self.notice_dialog then
                    self.notice_dialog = new(NoticeViewMailDialog);
                end
                self.notice_dialog:show(self.data);
            end
        end
        self:addScrollAnim();
    end
end

function UserInfoSceneNoticeMsgListItem:setHandlerScrollEnable(flag)
    if self.sceneHandler and self.sceneHandler.m_notice_content_view then
        self.sceneHandler.m_notice_content_view:setScrollEnable(flag);
    end
end

function UserInfoSceneNoticeMsgListItem:onScrollViewChange(length)
    local x,y = self.scrollView:getPos();
    local w,h = self.scrollView:getSize();
    local nx = x + length;

    if nx > 0 then
        nx = 0;
    elseif nx < -( self.limitMove + 20 ) then
        nx = -( self.limitMove + 20 );
    end
    self.scrollView:setPos(nx);
end

function UserInfoSceneNoticeMsgListItem:onDelHandlerChange(length)
    local x,y = self.delHandler:getPos();
    local w,h = self.delHandler:getSize();
    local nx = x + -length;

    if nx > 0 then
        nx = 0;
    elseif nx < -self.limitMove*2 then
        nx = -self.limitMove*2;
    end
    self.delHandler:setPos(nx);
    self.delHandler:setTransparency(1+nx/w);
end

UserInfoSceneNoticeMsgListItem.addScrollAnim = function(self)
    self:stopScrollAnim();
    self.scrollAnim = new(AnimInt,kAnimLoop, 0, 1, 1000/24, -1);
    self.scrollAnim:setDebugName("UserInfoSceneNoticeMsgListItem.scrollAnim");
    self.scrollAnim:setEvent(self,self.scrollAnimEvent)
end

UserInfoSceneNoticeMsgListItem.scrollAnimEvent = function(self)
    local flag1 = self:fixDelHandler();
    local flag2 = self:fixScrollView();
    if flag1 and flag2 then
        if self.status == UserInfoSceneNoticeMsgListItem.STATUS_NOR then
            self:setHandlerScrollEnable(true);
        else
            self:setHandlerScrollEnable(false);
        end
        self:stopScrollAnim();
    end
end

UserInfoSceneNoticeMsgListItem.SCROLL_FACTOR = 0.7;
-- 注意 滚动基于view 的对齐方式
UserInfoSceneNoticeMsgListItem.fixScrollView = function(self)
    local w,h = self.delHandler:getSize();
    local x,y = self.scrollView:getPos();
    local lenght = 0;
    -- x2 - x1 得到 从x1 到坐标 x2 需要移动的距离
    if self.status == UserInfoSceneNoticeMsgListItem.STATUS_DEL then
        lenght = (-w/2-x)*UserInfoSceneNoticeMsgListItem.SCROLL_FACTOR;
        if math.abs(lenght) < 10 then
            lenght = -w/2-x;
        end
    else
        lenght = -x*UserInfoSceneNoticeMsgListItem.SCROLL_FACTOR;
        if math.abs(lenght) < 10 then
            lenght = -x;
        end
    end
    if lenght == 0 then return true end
    self:onScrollViewChange(lenght);
    return false;
end

UserInfoSceneNoticeMsgListItem.fixDelHandler = function(self)
    local w,h = self.delHandler:getSize();
    local x,y = self.delHandler:getPos();
    local lenght = 0;
    if self.status == UserInfoSceneNoticeMsgListItem.STATUS_DEL then
        lenght = -x*UserInfoSceneNoticeMsgListItem.SCROLL_FACTOR;
        if math.abs(lenght) < 10 then
            lenght = -x;
        end
    else
        lenght = (-w-x)*UserInfoSceneNoticeMsgListItem.SCROLL_FACTOR;
        if math.abs(lenght) < 10 then
            lenght = -w-x;
        end
    end
    if lenght == 0 then return true end
    self:onDelHandlerChange(-lenght);
    return false;
end

UserInfoSceneNoticeMsgListItem.stopScrollAnim = function(self)
    if self.scrollAnim then
        delete(self.scrollAnim);
        self.scrollAnim = nil;
    end
end

UserInfoSceneNoticeMsgListItem.dtor = function(self)
	if UserInfoSceneNoticeMsgListItem.cur_item == self then
        UserInfoSceneNoticeMsgListItem.cur_item = nil;
    end
    delete(self.notice_dialog);
end