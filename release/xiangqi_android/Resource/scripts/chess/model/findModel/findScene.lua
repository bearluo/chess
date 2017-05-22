--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23

require(BASE_PATH.."chessScene");
require("dialog/common_share_dialog");
require(MODEL_PATH.."online/private/privateScene");
require("dialog/common_share_dialog");
require(MODEL_PATH.."findModel/recommendEndgateItem");
require(MODEL_PATH.."findModel/recentlyPlayerItem");
require(MODEL_PATH .. "findModel/endgateListItem");
require("chess/include/slidingLoadView");
require("dialog/common_help_dialog");


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

    init_ad_scroll_view                 = 1;
    init_recently_player_view           = 2;
    add_friend_response                 = 3;
    wulin_booth_recommend_response      = 4;
    add_endgate                         = 5;
    save_mychess                        = 6;
}


function FindScene.ctor(self,viewConfig,controller)
	self.m_ctrls = FindScene.s_controls;
    self:create();
end 


function FindScene.resume(self)
    ChessScene.resume(self);
--    self:removeAnimProp();
--    self:resumeAnimStart();

    if not self.mInited then
        self.mInited = true;
        self:refreshData();
    end
end

FindScene.isShowBangdinDialog = false;


function FindScene.pause(self)
	ChessScene.pause(self);
    self:removeAnimProp();
--    self:pauseAnimStart();
    call_native(kShareWebViewClose);
    call_native(kNativeWebViewClose);
    call_native(kActivityWebViewClose);
end 


function FindScene.dtor(self)
    delete(self.mHelpDialog);
    delete(self.mChioceDialog);
end 
--占位

function FindScene.setAnimItemEnVisible(self,ret)
end


function FindScene.removeAnimProp(self)
end

function FindScene.resumeAnimStart(self,lastStateObj,timer,changeStyle)
    self:removeAnimProp();
    local duration = timer.waitTime;
    local delay = timer.duration + duration;
    local w,h = self:getSize();
    
end




function FindScene.pauseAnimStart(self,newStateObj,timer,changeStyle)
    self:removeAnimProp();
    local w,h = self:getSize();
    local duration = timer.waitTime;
    local delay = timer.duration + duration;
    
end

---------------------- func --------------------

function FindScene.create(self)
    self.mBottomMenu = self:findViewById(self.m_ctrls.bottom_menu);
    self.mWebView = self:findViewById(self.m_ctrls.web_view);

    self.m_left_leaf = self.m_root:getChildByName("console_title_view"):getChildByName("bamboo_left");
    self.m_right_leaf = self.m_root:getChildByName("console_title_view"):getChildByName("bamboo_right");
    self.m_left_leaf:setFile("common/decoration/left_leaf.png")
    self.m_right_leaf:setFile("common/decoration/right_leaf.png")

    local w,h = self:getSize()
    local mw,mh = self.mWebView:getSize();
    self.mWebView:setSize(mw,mh+h-System.getLayoutHeight());
    
    self:initEndgate();

    self.recommendBtn = self:findViewById(self.m_ctrls.recommend_btn);
    self.endgateBtn = self:findViewById(self.m_ctrls.endgate_btn);
    self.m_root:getChildByName("back_btn"):setOnClick(nil,function()
        self:requestCtrlCmd(FindController.s_cmds.onBack)
    end)
end


function FindScene.refreshData(self)
    self:refreshEndgateData();
end


function FindScene.refreshEndgateData(self)
    for i=1,3 do
        if self.endgateMenuSort and self.endgateMenuSort[i] then
            self:refreshEndgateScrollView(i);
        end
    end
end


function FindScene.initEndgate(self)
    local w,h = self:getSize();
    self.endgateScrollView = self:findViewById(self.m_ctrls.endgate_scroll_view);
    self.endgateScrollView:setVisible(true);
    local mw,mh = self.endgateScrollView:getSize();
    self.endgateScrollView:setSize(mw,mh+h-System.getLayoutHeight());

    self.endgateListHandler = self.endgateScrollView:getChildByName("endgate_list_handler");
    local mw,mh = self.endgateListHandler:getSize();
    self.endgateListHandler:setSize(mw,mh+h-System.getLayoutHeight());

    self.endgateLists = {};
    --我的创建没有残局提示：大侠，您还没创建过残局，快去试试吧，残局被通关还能获得金币奖励哦
--没有街边残局：暂时没有街边残局，试创建一个给棋友们挑战吧
    self.endgateListsTest = {

        '暂无关注残局，关注的未下架残局都可以在这里快速找到哦。',
        '暂时没有街边残局，试创建一个给棋友们挑战吧',
        '暂时没有街边残局，试创建一个给棋友们挑战吧',
    }

    for i=1,3 do

        local view = new(SlidingLoadView, 0, 0, mw,mh+h-System.getLayoutHeight(), true)
        view:setOnLoad(self,function(self)
            self:requestCtrlCmd(FindController.s_cmds.onLoadEndgate,i,self.endgateMenuSort[i]);
        end)
        view:setNoDataTip(self.endgateListsTest[i]);
        view:setVisible(false);
        self.endgateListHandler:addChild(view);

        self.endgateLists[i] = view;

    end
    self:initEndgateMenu();

    self.createEndgateBtn = self.endgateScrollView:getChildByName("create_endgate_btn");
    self.createEndgateBtn:setOnClick(self,self.gotoCreateEndgate);
    self.ownCreateBtn = self.endgateScrollView:getChildByName("own_create_btn");
    self.ownCreateBtn:setOnClick(self,self.gotoOwnCreateEndgate);
    
end


function FindScene.initEndgateMenu(self)
    self.endgateMenu = self.endgateScrollView:getChildByName("endgate_menu");

    self.ownMarkBtn = self.endgateMenu:getChildByName("own_mark_btn");
    self.timeSortBtn = self.endgateMenu:getChildByName("time_sort_btn");
    self.jackpotSortBtn = self.endgateMenu:getChildByName("jackpot_sort_btn");
    self.endgateMenuBtn = {};

    self.endgateMenuBtn[1] = self.ownMarkBtn;
    self.endgateMenuBtn[2] = self.timeSortBtn;
    self.endgateMenuBtn[3] = self.jackpotSortBtn;
    self.endgateMenuSort = {};
    self.endgateMenuSortText = {};
    self.endgateMenuSortText[1] = '我关注的';
    self.endgateMenuSortText[2] = '时间排序';
    self.endgateMenuSortText[3] = '奖池排序';
    for i=1,3 do
        self:onEndgateMenuBtnClick(i,true);
        self:updateViewEndgateMenuBtn(i); -- 初始化数据
        self.endgateMenuBtn[i]:setOnClick(self,function(self)
            self:onEndgateMenuBtnClick(i);
        end)
    end
end


function FindScene.updateViewEndgateMenuBtn(self,index)
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


function FindScene.selectEndgateMenuBtn(self,index)
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



function FindScene.refreshEndgateScrollView(self,index)
    self:requestCtrlCmd(FindController.s_cmds.onEndgateMenuBtnClick,index);
    local view = self.endgateLists[index];

    view:reset()
    view:loadView();
end




function FindScene.onEndgateMenuBtnClick(self,index,isNotRefresh)
    if self.endgateMenuIndex and self.endgateMenuIndex == index then
        self:updateViewEndgateMenuBtn(index);
        self:refreshEndgateScrollView(index);
    else
        if self:selectEndgateMenuBtn(index) then
            self.endgateMenuIndex = index;
            if not isNotRefresh then
                self:refreshEndgateScrollView(index);
            end
        end
    end
end

function FindScene.addEndgate(self,index,datas,isNoData)
    if type(datas) ~= "table" or not self.endgateLists[index] then return end;
    local scrollView = self.endgateLists[index];
    for i,data in ipairs(datas) do
        local item = new(EndgateListItem,data);
        scrollView:addChild(item);
    end
    scrollView:loadEnd(isNoData);
end

function FindScene.onBackAction(self)
    self:requestCtrlCmd(FindController.s_cmds.onBack);
end

-- 收藏棋谱
function FindScene.savetoLocal(self, chessItem)
    self.mChessItem = chessItem;
    self:saveChesstoMysave();
end

-- 统计分享复盘
function FindScene.shareReplay(self, manualData)
    if not self.commonShareDialog then
        self.commonShareDialog = new(CommonShareDialog);
    end
    self.commonShareDialog:setShareDate(manualData,"manual_share");
    self.commonShareDialog:show();
end;

-- 收藏到我的收藏
function FindScene.saveChesstoMysave(self,item)
--    self:requestCtrlCmd(FindController.s_cmds.save_mychess,self.mChioceDialog:getCheckState(),self.mChessItem:getData());
    self:requestCtrlCmd(FindController.s_cmds.save_mychess,false,self.mChessItem:getData());
end;

function FindScene.onSaveMychessCallBack(self,data)
    if not data then return end;
    if data.cost then
        if data.cost >= 0 then 
            ChessToastManager.getInstance():showSingle("收藏成功！",2000);
            if self.mChessItem then
                self.mChessItem:setSuggestIsCollect();
            end;
        elseif data.cost == -1 then
            -- -1是老版本本地棋谱上传成功
        end
    end
end

function FindScene.requestFollow(self,data)
    self:requestCtrlCmd(FindController.s_cmds.requestFollow,data);
end

function FindScene.onFriendsAddFriendResponse(self,data)
    if type(self.recentlyPlayerGroup) == "table" then
        for i=1,3 do
            local item = self.recentlyPlayerGroup[i];
            if item and item.getTargetMid and item:getTargetMid() == data.target_mid then
                item:updateRelation(data.relation);
            end
        end
    end
end

function FindScene.challengeFriends(self)
    PrivateScene.challengeFriends = true;
    StateMachine.getInstance():pushState(States.PrivateHall,StateMachine.STYPE_CUSTOM_WAIT);
end

function FindScene.gotoCreateEndgate(self)
    StateMachine.getInstance():pushState(States.createEndgate,StateMachine.STYPE_CUSTOM_WAIT);
end

function FindScene.gotoOwnCreateEndgate(self)
    StateMachine.getInstance():pushState(States.ownCreateEndgate,StateMachine.STYPE_CUSTOM_WAIT);
end

function FindScene.onHelpBtnClick(self)
    if not self.mHelpDialog then
        self.mHelpDialog = new(CommonHelpDialog)
        self.mHelpDialog:setMode(CommonHelpDialog.find_mode)
    end 
    self.mHelpDialog:show()
end

function FindScene.onRefreshBtnClick(self)
    self:refreshEndgateData()
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
    [FindScene.s_controls.refresh_btn]                      = {"refresh_bg","refresh_btn"};

    
}

FindScene.s_controlFuncMap = {
    [FindScene.s_controls.recommend_btn]                    = FindScene.onRecommendBtnClick;
    [FindScene.s_controls.endgate_btn]                      = FindScene.onEndgateBtnClick;
    [FindScene.s_controls.help_btn]                         = FindScene.onHelpBtnClick;
    [FindScene.s_controls.refresh_btn]                      = FindScene.onRefreshBtnClick;
    
};

FindScene.s_cmdConfig =
{
    [FindScene.s_cmds.init_ad_scroll_view]                              = FindScene.initAdScrollView;
    [FindScene.s_cmds.init_recently_player_view]                        = FindScene.initRecentlyPlayerView;
    [FindScene.s_cmds.add_friend_response]                              = FindScene.onFriendsAddFriendResponse;
    [FindScene.s_cmds.wulin_booth_recommend_response]                   = FindScene.initWulinBoothRecommendView;
    [FindScene.s_cmds.add_endgate]                                      = FindScene.addEndgate;
    [FindScene.s_cmds.save_mychess]                                     = FindScene.onSaveMychessCallBack;
    
}
