--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23

require(BASE_PATH.."chessScene");

FindScene = class(ChessScene);

FindScene.s_controls = 
{
    bottom_menu             = 1;
    web_view                = 2;
    recommend_scroll_view   = 3;
    ad_scroll_view          = 4;
    recommend_btn           = 5;
    endgate_btn             = 6;
    endgate_scroll_view     = 7;
    refresh_btn             = 8;
    help_btn                = 9
}

FindScene.s_cmds = 
{
    initAdScrollView = 1;
    initRecentlyPlayerView = 2;
    onFriendsAddFriendResponse  = 3;
    onWulinBoothRecommendResponse   = 4;
    addEndgate                          = 5;
    save_mychess                        = 6;
}

FindScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = FindScene.s_controls;
    self:create();
end 

FindScene.resume = function(self)
    ChessScene.resume(self);
--    self:removeAnimProp();
--    self:resumeAnimStart();
    if not self.inited then
        self.inited = true;
        self:refreshData();
    end

    BottomMenu.getInstance():onResume(self.m_bottom_menu,self.bottomMove);
    BottomMenu.getInstance():setHandler(self,2);
    BottomMenu.getInstance():setMyFindStatus();
--    self:showNativeListWebView();
end

FindScene.isShowBangdinDialog = false;

FindScene.pause = function(self)
	ChessScene.pause(self);
    self:removeAnimProp();
--    self:pauseAnimStart();
    BottomMenu.getInstance():onPause();
    call_native(kShareWebViewClose);
    call_native(kNativeWebViewClose);
end 

FindScene.dtor = function(self)
    delete(self.adsAnim);
    self:stopPopAnim();
    delete(self.helpDialog);
    delete(self.m_chioce_dialog);
end 
--占位
FindScene.setAnimItemEnVisible = function(self,ret)
end

FindScene.removeAnimProp = function(self)
    if self.m_anim_prop_need_remove then
--        self.m_bottom_menu:removeProp(1);
    --    self.m_top_view:removeProp(1);
    --    self.m_more_btn:removeProp(1);
    --    self.m_bottom_view:removeProp(1);
        self.m_anim_prop_need_remove = false;
    end
end

FindScene.resumeAnimStart = function(self,lastStateObj,timer)
--   self.m_anim_prop_need_remove = true;
--   self:removeAnimProp();
   local duration = timer.duration;
   local waitTime = timer.waitTime
   local delay = waitTime+duration;

    local anim_start = nil;
    local w,h = self:getSize();
    if typeof(lastStateObj,HallState)then
         self.bottomMove = false;
--         anim_start = self.m_root:addPropTranslate(1,kAnimNormal,400,waitTime,w,0,nil,nil);
    elseif typeof(lastStateObj,OwnState) then
        self.bottomMove = false;
        self.m_root:removeProp(1);
        anim_start = self.m_root:addPropTranslate(1,kAnimNormal,duration,waitTime,-w,0,nil,nil);
    else
         self.bottomMove = true;
         self.m_root:removeProp(1);
         anim_start = self.m_root:addPropTranslate(1,kAnimNormal,duration,waitTime,-w,0,nil,nil);
         BottomMenu.getInstance():hideView(true);
         BottomMenu.getInstance():removeOutWindow(0,timer);
    end
   if anim_start then
        anim_start:setEvent(self,function()
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
                delete(anim_start);
	        end
        end);
   end
   -- 上部动画
--   local w,h = self.m_title_icon:getSize();
--   local anim = self.m_title_icon:addPropTranslate(1, kAnimNormal, duration, delay, 0, 0, -h, 0);
--   anim:setEvent(self,self.removeAnimProp);
--   local w,h = self.m_scroll_view:getSize();
--   local x,y = self.m_scroll_view:getPos();
--   self.m_scroll_view:addPropTranslate(1, kAnimNormal, duration, delay, 0, 0, -h-y, 0);

   -- 下部动画
--   local w,h = self.m_bottom_menu:getSize();
--   local anim = self.m_bottom_menu:addPropTranslate(1, kAnimNormal, duration, delay, 0, 0, h, 0);
--   anim:setEvent(self,self.removeAnimProp);
   -- 
--   self.m_notice_view:addPropTransparency(1,kAnimNormal,duration,delay,0,1);
--   self.m_back_btn:addPropTransparency(1,kAnimNormal,duration,delay,0,1);
--   self.m_bottom_view:addPropTransparency(1,kAnimNormal,duration,delay,0,1);
--   self.m_top_view:addPropTransparency(1,kAnimNormal,duration,delay,0,1);
end

FindScene.pauseAnimStart = function(self,newStateObj,timer)
--   self.m_anim_prop_need_remove = true;
--   self:removeAnimProp();
   local duration = timer.duration;
   local waitTime = timer.waitTime
   local delay = waitTime+duration;

   local anim_end = nil;
   local w,h = self:getSize();
    if typeof(newStateObj,HallState) then
--        anim_end = self.m_root:addPropTranslate(1,kAnimNormal,400,400,0,w,0,nil,nil);
    elseif typeof(newStateObj,OwnState) then
        self.m_root:removeProp(1);
        anim_end = self.m_root:addPropTranslate(1,kAnimNormal,duration,waitTime,0,-w,nil,nil);
    else
        self.bottomMove = true;
        self.m_root:removeProp(1);
        anim_end = self.m_root:addPropTranslate(1,kAnimNormal,duration,waitTime,0,-w,nil,nil);
        BottomMenu.getInstance():removeOutWindow(1,timer);
    end

   if anim_end then
        anim_end:setEvent(self,function()
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end
            if self.bottomMove == true then
                BottomMenu.getInstance():hideView();
            end
            delete(anim_end);
        end);
   end
   -- 上部动画
--   local w,h = self.m_title_icon:getSize();
--   local anim = self.m_title_icon:addPropTranslate(1, kAnimNormal, duration, delay, 0, 0, 0, -h);
--   anim:setEvent(self,self.removeAnimProp);
--   local w,h = self.m_scroll_view:getSize();
--   local x,y = self.m_scroll_view:getPos();
--   self.m_scroll_view:addPropTranslate(1, kAnimNormal, duration, delay, 0, 0, 0, -h-y);
   -- 下部动画
--   local w,h = self.m_bottom_menu:getSize();
--   local anim = self.m_bottom_menu:addPropTranslate(1, kAnimNormal, duration, delay, 0, 0, 0, h);
--   anim:setEvent(self,self.removeAnimProp);
   -- 
--   self.m_notice_view:addPropTransparency(1,kAnimNormal,duration,delay,1,0);
--   self.m_back_btn:addPropTransparency(1,kAnimNormal,duration,delay,1,0);
--   self.m_bottom_view:addPropTransparency(1,kAnimNormal,duration,delay,1,0);
--   self.m_top_view:addPropTransparency(1,kAnimNormal,duration,delay,1,0);
end

---------------------- func --------------------
FindScene.create = function(self)

    self.m_bottom_menu = self:findViewById(self.m_ctrls.bottom_menu);
    self.m_web_view = self:findViewById(self.m_ctrls.web_view);
    self.bottomMove = false;
    local w,h = self:getSize();
    local mw,mh = self.m_web_view:getSize();
    self.m_web_view:setSize(mw,mh+h-System.getLayoutHeight());
    
    self:initRecommend();
    self:initEndgate();

    self.recommendBtn = self:findViewById(self.m_ctrls.recommend_btn);
    self.endgateBtn = self:findViewById(self.m_ctrls.endgate_btn);
    self:onRecommendBtnClick();

end

FindScene.refreshData = function(self)
    self.popularEndgateReplay:removeAllChildren(true);
    self.popularEndgateReplay:setSize(nil,0);
    self:requestCtrlCmd(FindController.s_cmds.requestData);
    self.recommendScrollView:updateScrollView();
    for i=1,3 do
        if self.endgateMenuSort and self.endgateMenuSort[i] then
            self:refreshEndgateScrollView(i);
        end
    end
end

FindScene.initEndgate = function(self)
    local w,h = self:getSize();
    self.endgateScrollView = self:findViewById(self.m_ctrls.endgate_scroll_view);
    self.endgateScrollView:setVisible(true);
    self.endgateScrollView:setPos(w,nil);
    local mw,mh = self.endgateScrollView:getSize();
    self.endgateScrollView:setSize(mw,mh+h-System.getLayoutHeight());

    self.endgateListHandler = self.endgateScrollView:getChildByName("endgate_list_handler");
    local mw,mh = self.endgateListHandler:getSize();
    self.endgateListHandler:setSize(mw,mh+h-System.getLayoutHeight());

    self.endgateLists = {};
    --我的创建没有残局提示：大侠，您还没创建过残局，快去试试吧，残局被通关还能获得金币奖励哦
--没有街边残局：暂时没有街边残局，试创建一个给棋友们挑战吧
    self.endgateListsTest = {
        '大侠，您还没创建过残局，快去试试吧，残局被通关还能获得金币奖励哦',
        '暂时没有街边残局，试创建一个给棋友们挑战吧',
        '暂时没有街边残局，试创建一个给棋友们挑战吧',
    }
    self.endgateListsTestView = {};
    for i=1,3 do
        local view = new(ScrollView, 0, 0, mw,mh+h-System.getLayoutHeight(), true)
        self.endgateListHandler:addChild(view);
        view:setVisible(false);
        view:setOnScrollEvent(self,function(self,scroll_status, diffY, totalOffset,isMarginRebounding)
            local frameLength = view:getFrameLength();  -- 显示区域
            local viewLength = view:getViewLength();    -- 总长度
            if math.abs(totalOffset) >= viewLength - frameLength then
                self:requestCtrlCmd(FindController.s_cmds.onEndgateMenuBtnClick,i,self.endgateMenuSort[i]);
            end
        end)
        self.endgateLists[i] = view;
        local textView = new(Node)
        textView:setSize(mh,mh+h-System.getLayoutHeight());
        local text = new(RichText,"loading...", mh / 3 * 2,mh+h-System.getLayoutHeight(), kAlignCenter, fontName, 30, 80, 80, 80, true,10);
        text:setAlign(kAlignCenter);
        textView:addChild(text);
        view:addChild(textView);
        self.endgateListsTestView[i] = textView;
    end
    self:initEndgateMenu();

    self.createEndgateBtn = self.endgateScrollView:getChildByName("create_endgate_btn");
    self.createEndgateBtn:setOnClick(self,self.gotoCreateEndgate);
end

FindScene.initEndgateMenu = function(self)
    self.endgateMenu = self.endgateScrollView:getChildByName("endgate_menu");
    self.ownCreateBtn = self.endgateMenu:getChildByName("own_create_btn");
    self.timeSortBtn = self.endgateMenu:getChildByName("time_sort_btn");
    self.jackpotSortBtn = self.endgateMenu:getChildByName("jackpot_sort_btn");
    self.endgateMenuBtn = {};
    self.endgateMenuBtn[1] = self.ownCreateBtn;
    self.endgateMenuBtn[2] = self.timeSortBtn;
    self.endgateMenuBtn[3] = self.jackpotSortBtn;
    self.endgateMenuSort = {};
    self.endgateMenuSortText = {};
    self.endgateMenuSortText[1] = '我创建的';
    self.endgateMenuSortText[2] = '时间排序';
    self.endgateMenuSortText[3] = '奖池排序';
    for i=1,3 do
        self:onEndgateMenuBtnClick(i);
        self:updateViewEndgateMenuBtn(i); -- 初始化数据
        self.endgateMenuBtn[i]:setOnClick(self,function(self)
            self:onEndgateMenuBtnClick(i);
        end)
    end
end

FindScene.updateViewEndgateMenuBtn = function(self,index)
    if self.endgateMenuBtn[index] then
        if self.endgateMenuSort[index] == 'desc' then
            self.endgateMenuSort[index] = 'asc';
            self.endgateMenuBtn[index]:getChildByName("text"):setText(self.endgateMenuSortText[index] .. "▼");
        else
            self.endgateMenuSort[index] = 'desc';
            self.endgateMenuBtn[index]:getChildByName("text"):setText(self.endgateMenuSortText[index] .. "▲");
        end
    end
end

FindScene.selectEndgateMenuBtn = function(self,index)
    local preIndex = self.endgateMenuIndex;
    if self.endgateMenuBtn[preIndex] then
        self.endgateMenuBtn[preIndex]:getChildByName("text"):setColor(125,80,65);
        self.endgateMenuBtn[preIndex]:getChildByName("red_line"):setVisible(false);
        self.endgateLists[preIndex]:setVisible(false);
    end

    if self.endgateMenuBtn[index] then
        self.endgateMenuIndex = index;
        self.endgateMenuBtn[index]:getChildByName("text"):setColor(215,76,45);
        self.endgateMenuBtn[index]:getChildByName("red_line"):setVisible(true);
        self.endgateLists[index]:setVisible(true);
        return true;
    else
        if self.endgateMenuBtn[preIndex] then
            self.endgateMenuBtn[preIndex]:getChildByName("text"):setColor(215,76,45);
            self.endgateMenuBtn[preIndex]:getChildByName("red_line"):setVisible(true);
            self.endgateLists[preIndex]:setVisible(true);
        end
    end
    return false;
end

FindScene.refreshEndgateScrollView = function(self,index)
    self:requestCtrlCmd(FindController.s_cmds.onEndgateMenuBtnClick,index,self.endgateMenuSort[index],0);
    local view = self.endgateLists[index];
    view:removeChild(self.endgateListsTestView[index]);
    view:removeAllChildren();
    view:addChild(self.endgateListsTestView[index]);
    self.endgateListsTestView[index]:setVisible(true);
    view:setOnScrollEvent(self,function(self,scroll_status, diffY, totalOffset,isMarginRebounding)
        local frameLength = view:getFrameLength();  -- 显示区域
        local viewLength = view:getViewLength();    -- 总长度
        if math.abs(totalOffset) >= viewLength - frameLength then
            self:requestCtrlCmd(FindController.s_cmds.onEndgateMenuBtnClick,index,self.endgateMenuSort[index]);
        end
    end)
end

FindScene.onEndgateMenuBtnClick = function(self,index)
    if self.endgateMenuIndex and self.endgateMenuIndex == index then
        self:updateViewEndgateMenuBtn(index);
        self:refreshEndgateScrollView(index);
    else
        if self:selectEndgateMenuBtn(index) then
            self.endgateMenuIndex = index;
        end
    end
end

FindScene.addEndgate = function(self,index,datas,isNoData,isNull)
    if type(datas) ~= "table" or not self.endgateLists[index] then return end;
    local scrollView = self.endgateLists[index];
    require(MODEL_PATH .. "findModel/endgateListItem");
    scrollView:removeChild(self.endgateListsTestView[index]);
    self.endgateListsTestView[index]:setVisible(false);
    if isNoData then
        if isNull then
            local mw,mh = self.endgateListHandler:getSize();
            local textView = new(Node)
            textView:setSize(mw,mh);
            local text = new(RichText,self.endgateListsTest[index],mh / 3 * 2,mh, kAlignCenter, fontName, 30, 80, 80, 80, true,10);
            text:setAlign(kAlignCenter);
            textView:addChild(text);
            scrollView:addChild(textView);
        else
            local w,h = scrollView:getSize();
            local item = new(Text,"没有更多数据了", w, 100, kAlignCenter, fontName, 30, 80, 80, 80);
            scrollView:addChild(item);
        end
        scrollView:updateScrollView();
        scrollView:setOnScrollEvent(nil,nil);
        return ;
    end

    for i,data in ipairs(datas) do
        local item = new(EndgateListItem,data);
        scrollView:addChild(item);
    end
    scrollView:updateScrollView();
end

FindScene.initRecommend = function(self)
    local w,h = self:getSize();
    self.recommendScrollView = self:findViewById(self.m_ctrls.recommend_scroll_view);
    self.recommendScrollView:setVisible(true);
    self.recommendScrollView:setPos(0,nil);
    local mw,mh = self.recommendScrollView:getSize();
    self.recommendScrollView:setSize(mw,mh+h-System.getLayoutHeight());

    self:initAdScrollView();
    self:initRecentlyPlayerView();
    self:initWulinBoothRecommendView();
end

FindScene.initAdScrollView = function(self,tab)
    self.adScrollView = self:findViewById(self.m_ctrls.ad_scroll_view);
    self.adView = self.adScrollView:getChildByName("ad_view");
    self.ad = self.adView:getChildByName("ad");
    self.adViewBottomTips = self.adView:getChildByName("ad_view_bottom_tips");
    self.adViewBtnL = self.adScrollView:getChildByName("btn_l");
    self.adViewBtnR = self.adScrollView:getChildByName("btn_r");
    self.adViewBtnL:setOnClick(self,self.showPreAd);
    self.adViewBtnR:setOnClick(self,self.showNextAd);

    if not tab or type(tab) ~= "table" or #tab == 0 then 
        self.ad:getChildByName("tip_text"):setVisible(true);
        self.ad:getChildByName("tip_text"):setText("活动即将开放，敬请期待");
        return ;
    end
    self.ad:getChildByName("tip_text"):setVisible(false);
    
    self:initAds(tab);
end

FindScene.onBackAction = function(self)
    self:requestCtrlCmd(FindController.s_cmds.onBack);
end

FindScene.showNextAd = function(self)
    if self.showAd and self.showAd > 0 then
        local len = #self.ads;
        local nextAd = self.showAd % len + 1;
        if self.ads[nextAd] then
            self.ads[self.showAd].act:setVisible(false);
            self.ads[self.showAd].tip:setFile("drawable/gray_dot.png");
            self.showAd = nextAd;
            self.ads[self.showAd].act:setVisible(true);
            self.ads[self.showAd].tip:setFile("drawable/red_dot.png");
        end
    end
end

FindScene.showPreAd = function(self)
    if self.showAd and self.showAd > 0 then
        local len = #self.ads;
        local nextAd = (self.showAd - 2 + len) % len + 1;
        if self.ads[nextAd] then
            self.ads[self.showAd].act:setVisible(false);
            self.ads[self.showAd].tip:setFile("drawable/gray_dot.png");
            self.showAd = nextAd;
            self.ads[self.showAd].act:setVisible(true);
            self.ads[self.showAd].tip:setFile("drawable/red_dot.png");
        end
    end
end

FindScene.initAds = function(self,tab)
    delete(self.adsAnim);
    if type(self.ads) == "table" then
        for _,ad in ipairs(self.ads) do
            delete(ad.act);
            delete(ad.tip);
        end
    end
    self.ads = {};
    self.adViewBottomTips:setSize(0,nil);
    self.showAd = 0;
    for _,data in pairs(tab) do
        self:addAd(data);
    end
    if #tab > 0 then
        self.showAd = 1;
        self.ads[self.showAd].act:setVisible(true);
        self.ads[self.showAd].tip:setFile("drawable/red_dot.png");
        if #tab > 1 then
            self.adsAnim = new(AnimInt,kAnimLoop, 0, 1, 5000, -1);
            self.adsAnim:setEvent(self,self.showNextAd);
        end
    end
end

FindScene.addAd = function(self,data)
    local act = new(Button,"common/background/activity_bg.png");
    local w,h = self.ad:getSize();
    local str = data.img_url;
    act:setSize(w,h);
    act:setUrlImage(str);
    act:setSrollOnClick();
    act:setOnClick(self,function()
        local absoluteX,absoluteY = 0,0;
        local x = absoluteX*System.getLayoutScale();
        local y = absoluteY*System.getLayoutScale();
        local width = System.getScreenWidth();
        local height = System.getScreenHeight();
        NativeEvent.getInstance():showActivityWebView(x,y,width,height,data.info_url);
    end);
    act:setVisible(false);
    
    local w,h = self.adViewBottomTips:getSize();

    local tip = new(Image,"drawable/gray_dot.png");
    tip:setSize(h,h);
    local ad = {};
    ad.act = act;
    ad.tip = tip;

    table.insert(self.ads,ad);
    tip:setPos(w,0);

    self.adViewBottomTips:addChild(tip);
    self.adViewBottomTips:setSize(w+h+5,nil);
    self.ad:addChild(act);
end

FindScene.showNativeListWebView = function(self)
	local width_content,height_content = self.m_web_view:getSize();
    local absoluteX,absoluteY = self.m_web_view:getPos();
    local x = absoluteX*System.getLayoutScale();
    local y = absoluteY*System.getLayoutScale();
    local width = width_content*System.getLayoutScale();
    local height = height_content*System.getLayoutScale();
    NativeEvent.getInstance():showNativeWebView(x,y,width,height);
end

FindScene.onRecommendBtnClick = function(self)
    self.recommendBtn:setEnable(false);
    self.endgateBtn:setEnable(true);

    if self.recommendScrollView then
        local w,h = self:getSize();
        local x,y = self.recommendScrollView:getPos();
        self:startPopAnim(-x);
    end
end

FindScene.onEndgateBtnClick = function(self)
    self.recommendBtn:setEnable(true);
    self.endgateBtn:setEnable(false);
    if self.endgateScrollView then
        local w,h = self:getSize();
        local x,y = self.endgateScrollView:getPos();
        self:startPopAnim(-x);
    end
end

FindScene.startPopAnim = function(self,len)
    self:stopPopAnim();
    self.popAnim = new(AnimInt, kAnimLoop, 0, 1, 1000/60, -1);
    self.popAnim:setEvent(self,function()
        if math.abs(len) < 5 then
            if self.endgateScrollView then
                local x,y = self.endgateScrollView:getPos();
                self.endgateScrollView:setPos(x+len,nil);
            end

            if self.recommendScrollView then
                local x,y = self.recommendScrollView:getPos();
                self.recommendScrollView:setPos(x+len,nil);
            end
            self:stopPopAnim();
            return ;
        end
        local move = len * 0.2;
        len = len - move;
        if self.endgateScrollView then
            local x,y = self.endgateScrollView:getPos();
            self.endgateScrollView:setPos(x+move,nil);
        end

        if self.recommendScrollView then
            local x,y = self.recommendScrollView:getPos();
            self.recommendScrollView:setPos(x+move,nil);
        end
    end);
end

FindScene.stopPopAnim = function(self)
    delete(self.popAnim);
end

FindScene.initRecentlyPlayerView = function(self,tab)
    self.recentlyPlayerGroup = {};
    self.recentlyPlayerView = self.recommendScrollView:getChildByName("recently_player_view");
    self.recentlyPlayerGroupView = self.recentlyPlayerView:getChildByName("recently_player_group_view");
    self.recentlyPlayerGroupView:removeAllChildren();
    self.recentlyPlayerView:getChildByName("recentlyPlayerBtn"):setOnClick(self,self.gotoRecentlyPlayerStatus)

    if type(tab) ~= "table" or #tab == 0 then
        local noDataView = self.recentlyPlayerView:getChildByName("recently_no_data_view");
        noDataView:setVisible(true);
        noDataView:getChildByName("tips"):setPickable(false)
        noDataView:getChildByName("quick_match_btn"):setOnClick(self,self.quickMatch);
        noDataView:getChildByName("challenge_friends_btn"):setOnClick(self,self.challengeFriends);
    else
        local noDataView = self.recentlyPlayerView:getChildByName("recently_no_data_view");
        noDataView:setVisible(false);
        require(MODEL_PATH.."findModel/recentlyPlayerItem");
        local w,h = self.recentlyPlayerGroupView:getSize();
        local len = w/3;
        for i=1,3 do
            if tab[i] then
                local item = new(RecentlyPlayerItem,tab[i]);
                self.recentlyPlayerGroupView:addChild(item);
                item:setPos((i-1)*len,0);
                item:setFollowBtnClick(self,self.requestFollow);
                self.recentlyPlayerGroup[i] = item;
            end
        end
    end
end

FindScene.onScrollEvent = function(self,scroll_status, diffY, totalOffset,isMarginRebounding)
    local frameLength = self.recommendScrollView:getFrameLength();  -- 显示区域
    local viewLength = self.recommendScrollView:getViewLength();    -- 总长度
    if math.abs(totalOffset) >= viewLength - frameLength then
        self:requestCtrlCmd(FindController.s_cmds.requestWulinBoothRecommend);
    end
end

FindScene.initWulinBoothRecommendView = function(self,datas,isNoData)
    self.popularEndgateReplay = self.recommendScrollView:getChildByName("popular_endgate_replay");
    if type(datas) ~= "table" then
        return ;
    end

    if isNoData then
        local w,h = self.popularEndgateReplay:getSize();
        local item = new(Text,"没有更多数据了", w, 100, kAlignCenter, fontName, 30, 80, 80, 80);
        local addW,addH = item:getSize();
        item:setPos(0,h + 20);
        self.popularEndgateReplay:setSize(nil,h+addH + 20);
        self.popularEndgateReplay:addChild(item);
        self.recommendScrollView:updateScrollView();
        self.recommendScrollView:setOnScrollEvent(nil,nil);
        return ;
    end
    self.recommendScrollView:setOnScrollEvent(self,self.onScrollEvent)

--    for i=1,3 do
--        table.insert(datas,datas[1]);
--    end


    require(MODEL_PATH.."findModel/recommendEndgateItem");
    for _,data in ipairs(datas) do
        local item = new(RecommendEndgateItem,data);
        local w,h = self.popularEndgateReplay:getSize();
        local addW,addH = item:getSize();
        item:setCollectionClick(self,self.savetoLocal)
        item:setPos(0,h + 20);
        self.popularEndgateReplay:setSize(nil,h+addH + 20);
        self.popularEndgateReplay:addChild(item);
        self.recommendScrollView:updateScrollView();
    end
end

-- 收藏棋谱
FindScene.savetoLocal = function(self, chessItem)
    self.m_chess_item = chessItem;
    -- 收藏弹窗
    if not self.m_chioce_dialog then
        self.m_chioce_dialog = new(ChioceDialog)
    end;
    self.m_chioce_dialog:setMode(ChioceDialog.MODE_SHOUCANG);  
    self.m_save_cost = UserInfo.getInstance():getFPcostMoney().collect_manual;  
    self.m_chioce_dialog:setMessage("是否花费"..(self.m_save_cost or 500) .."金币收藏当前棋谱？");
    self.m_chioce_dialog:setPositiveListener(self, self.saveChesstoMysave);
    self.m_chioce_dialog:show();
end;

-- 收藏到我的收藏
FindScene.saveChesstoMysave = function(self,item)
    self:requestCtrlCmd(FindController.s_cmds.save_mychess,self.m_chioce_dialog:getCheckState(),self.m_chess_item:getData());
end;

FindScene.onSaveMychessCallBack = function(self,data)
    if not data then return end;
    if data.cost then
        if data.cost > 0 then 
            ChessToastManager.getInstance():showSingle("收藏成功！",2000);
            if self.m_chess_item then
                self.m_chess_item:setSuggestIsCollect();
            end;
        elseif data.cost == 0 then
            ChessToastManager.getInstance():showSingle("您已经收藏过了！",1000);
        elseif data.cost == -1 then
            -- -1是老版本本地棋谱上传成功
        end
    end
end

FindScene.requestFollow = function(self,data)
    self:requestCtrlCmd(FindController.s_cmds.requestFollow,data);
end

FindScene.onFriendsAddFriendResponse = function(self,data)
    if type(self.recentlyPlayerGroup) == "table" then
        for i=1,3 do
            local item = self.recentlyPlayerGroup[i];
            if item and item.getTargetMid and item:getTargetMid() == data.target_mid then
                item:updateRelation(data.relation);
            end
        end
    end
end

FindScene.gotoRecentlyPlayerStatus = function(self)
    StateMachine.getInstance():pushState(States.RecentlyPlayerState,StateMachine.STYPE_CUSTOM_WAIT);
end

FindScene.quickMatch = function(self)
    self:requestCtrlCmd(FindController.s_cmds.quickPlay);
end

FindScene.challengeFriends = function(self)
    require(MODEL_PATH.."online/onlineScene");
    OnlineScene.changeFriends = true;
    StateMachine.getInstance():pushState(States.Online,StateMachine.STYPE_CUSTOM_WAIT);
end

FindScene.gotoCreateEndgate = function(self)
    StateMachine.getInstance():pushState(States.createEndgate,StateMachine.STYPE_CUSTOM_WAIT);
end

FindScene.onHelpBtnClick = function(self)
    require(DIALOG_PATH .. "find_view_help_dialog");
    if not self.helpDialog then
        self.helpDialog = new(FindViewHelpDialog);
    end
    self.helpDialog:show();
end

FindScene.onRefreshBtnClick = function(self)
    self:refreshData();
end

---------------------- config ------------------
FindScene.s_controlConfig = {
    [FindScene.s_controls.bottom_menu]                      = {"bottom_menu"};
    [FindScene.s_controls.web_view]                         = {"web_view"};
    [FindScene.s_controls.recommend_scroll_view]            = {"web_view","recommend_scroll_view"};
    [FindScene.s_controls.ad_scroll_view]                   = {"web_view","recommend_scroll_view","ad_scroll_view"};
    [FindScene.s_controls.recommend_btn]                    = {"web_view","recommend_btn"};
    [FindScene.s_controls.endgate_btn]                      = {"web_view","endgate_btn"};
    [FindScene.s_controls.endgate_scroll_view]              = {"web_view","endgate_scroll_view"};
    [FindScene.s_controls.help_btn]                         = {"help_btn"};
    [FindScene.s_controls.refresh_btn]                      = {"refresh_btn"};

    
}

FindScene.s_controlFuncMap = {
    [FindScene.s_controls.recommend_btn]                    = FindScene.onRecommendBtnClick;
    [FindScene.s_controls.endgate_btn]                      = FindScene.onEndgateBtnClick;
    [FindScene.s_controls.help_btn]                         = FindScene.onHelpBtnClick;
    [FindScene.s_controls.refresh_btn]                      = FindScene.onRefreshBtnClick;
    
};

FindScene.s_cmdConfig =
{
    [FindScene.s_cmds.initAdScrollView]                             = FindScene.initAdScrollView;
    [FindScene.s_cmds.initRecentlyPlayerView]                       = FindScene.initRecentlyPlayerView;
    [FindScene.s_cmds.onFriendsAddFriendResponse]                   = FindScene.onFriendsAddFriendResponse;
    [FindScene.s_cmds.onWulinBoothRecommendResponse]                = FindScene.initWulinBoothRecommendView;
    [FindScene.s_cmds.addEndgate]                                   = FindScene.addEndgate;
    [FindScene.s_cmds.save_mychess]                                 = FindScene.onSaveMychessCallBack;
    
}