--region NewFile_1.lua
--Author : FordFan
--Date   : 2015/11/17
--新注册指引3
--endregion

require(VIEW_PATH .. "third_guide_dialog");
require(BASE_PATH .. "chessDialogScene");

ThirdGuideDialog = class(ChessDialogScene,false);

ThirdGuideDialog.TO_ONLINE = 5;
ThirdGuideDialog.TO_CONSOLE = 2;
ThirdGuideDialog.TO_ENDGATE = 8;
ThirdGuideDialog.s_handler = nil;

function ThirdGuideDialog.getInstance()
    if not ThirdGuideDialog.s_instance then
		ThirdGuideDialog.s_instance = new(ThirdGuideDialog);
	end
    return ThirdGuideDialog.s_instance;
end


ThirdGuideDialog.ctor = function(self)
    super(self,third_guide_dialog);

    self.m_view = self.m_root:getChildByName("view_bg");
    self.m_item_view = self.m_view:getChildByName("item_view");
    self.m_view:getChildByName("back_btn"):setOnClick(self,self.dismiss)
    
    self.m_item1 = self.m_item_view:getChildByName("item1");
    self.m_item2 = self.m_item_view:getChildByName("item2");
    self.m_item3 = self.m_item_view:getChildByName("item3");

    self.m_online_btn = self.m_item1:getChildByName("button");
    self.m_console_btn = self.m_item2:getChildByName("button");
    self.m_endgate_btn = self.m_item3:getChildByName("button");

    self.m_online_btn:setOnClick(self,function()
        self:changeState((ThirdGuideDialog.TO_ONLINE));
    end);
    

    self.m_console_btn:setOnClick(self,function()
        self:changeState((ThirdGuideDialog.TO_CONSOLE));
    end);
    self.m_endgate_btn:setOnClick(self,function()
        self:changeState((ThirdGuideDialog.TO_ENDGATE));
    end);

    local msg1 = "推荐去#cC82828联网对战#n快意厮杀，一决雌雄";
    self.m_tip1 = new(RichText,msg1,300,nil,kAlignLeft,nil,30,125,90,65,true,5);
    self.m_tip1:setPos(303,90);
    self.m_tip1:setAlign(kAlignTopLeft);
    self.m_item1:addChild(self.m_tip1);

    local msg2 = "推荐去#cC82828单机对弈#n练练手";
    self.m_tip2 = new(RichText,msg2,300,nil,kAlignLeft,nil,30,125,90,65,true,5);
    self.m_tip2:setPos(303,90);
    self.m_tip2:setAlign(kAlignTopLeft);
    self.m_item2:addChild(self.m_tip2);

    local msg3 = "推荐去#cC82828残局闯关#n从浅入深，慢慢学习";
    self.m_tip3 = new(RichText,msg3,300,nil,kAlignLeft,nil,30,125,90,65,true,5);
    self.m_tip3:setPos(303,90);
    self.m_tip3:setAlign(kAlignTopLeft);
    self.m_item3:addChild(self.m_tip3);

    local title = "请告诉我们您的棋艺水平#l以便更轻松愉快地享受游戏提升棋力";
    self.m_title = new(RichText,title,600,nil,kAlignTop,nil,36,245,220,145,true,15);
    self.m_title:setPos(0,81);
    self.m_title:setAlign(kAlignTop);
    self.m_root:addChild(self.m_title);

    self:setShieldClick(self,self.dismiss);
    self.m_item_view:setEventTouch(nil,function() end);

	self:setVisible(false);
end

ThirdGuideDialog.dtor = function(self)
    delete(self.m_anim);
end

ThirdGuideDialog.show = function(self)
    print_string("ThirdGuideDialog.show ... ");

    kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
    self:setVisible(true);
    self.super.show(self,false);
--    self:startAnim();
    StatisticsManager.getInstance():onNewUserCountToPHP(StatisticsManager.NEW_USER_COUNT_GUIDANCE_PAGE,UserInfo.getInstance():getIsFirstLogin())
end

ThirdGuideDialog.isShowing = function(self)
	return self:getVisible();
end

ThirdGuideDialog.dismiss = function(self)
    self:setVisible(false);
    self.super.dismiss(self,false);
    DailyTaskManager.getInstance():sendGetDailyTaskData()
    DailyTaskManager.getInstance():sendGetNewDailyTaskList()
    DailyTaskManager.getInstance():sendGetGrowTaskList()
end

function ThirdGuideDialog:setHandler(handler)
    if not handler then return end
    ThirdGuideDialog.s_handler = handler;
end

function ThirdGuideDialog:changeState(gameType)
    if not gameType then return end
--    self = obj[2];
    self:dismiss();
    if ThirdGuideDialog.s_handler then
        ThirdGuideDialog.s_handler:onGuideCallBack(gameType);
    end
end
