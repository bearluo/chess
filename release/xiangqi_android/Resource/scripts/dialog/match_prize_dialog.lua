
require(VIEW_PATH .. "show_prize_dialog")

MatchPrizeDialog = class(ChessDialogScene,false)

function MatchPrizeDialog:ctor(data)
    super(self,show_prize_dialog)
    self.datas = data;
    self.mBg = self.m_root:getChildByName("bg")
    self.mHeadBg   = self.mBg:getChildByName("head_bg")
    self.mVip      = self.mHeadBg:getChildByName("vip");
    self.mLevel    = self.mHeadBg:getChildByName("level_icon");
    self.mName     = self.mBg:getChildByName("name")
    self.mLife     = self.mBg:getChildByName("life")
    self.mMatchName = self.mBg:getChildByName("match_name")
    self.mRank    = self.mBg:getChildByName("rank")
    self.mPrize   = self.mBg:getChildByName("prize");
    self.mShareBtn  = self.m_root:getChildByName("share_btn")
    self.mShareBtn:setOnClick(self,self.onShareBtnClick)
    self.mGetPrizeBtn  = self.m_root:getChildByName("get_prize_btn")
    self.mGetPrizeBtn:setOnClick(self,self.onGetPrizeBtnClick)
    self.mGetPrizeTxt = self.mGetPrizeBtn:getChildByName("txt");
    self:setShieldClick(self,self.dismiss);
    EventDispatcher.getInstance():register(HttpModule.s_event, self, self.onHttpRequestsCallBack)
end

function MatchPrizeDialog:dtor()
    EventDispatcher.getInstance():unregister(HttpModule.s_event, self, self.onHttpRequestsCallBack)
end

function MatchPrizeDialog:show()
    self.super.show(self)
    EventDispatcher.getInstance():register(Event.Call,self,self.onNativeEvent)
    self:setHeadIcon();
    self:setGetPrizeBtnStatus(self.datas.is_operate or "0");
    local other_data = self.datas.other_data
    --{rank_text="冠军" match_id="13|17|2016-11-04|18:30:00|19500" packs="线上职业赛礼包" soul=100 match_name="xuen" money=50000 rank="1" }
    if other_data then
        other_data.packs = "";
        self.mLife:setText(string.format("生命:%s",other_data.match_score or "0"));
        self.mMatchName:setText( string.format("恭喜您在%s职业赛中获得",other_data.match_name or "") )
        self.mRank:setText(other_data.rank_text or "");
        local prize = "";
        if other_data.money and other_data.money ~= "" and tonumber(other_data.money) ~= 0 then
            prize = ((prize == "") and "" or (prize..",")) .. other_data.money .."金币";
        end; 
        if other_data.soul  and other_data.soul ~= "" and tonumber(other_data.soul) ~= 0 then
            prize = ((prize == "") and "" or (prize..",")) .. other_data.soul .."棋魂";
        end; 
        if other_data.packs and other_data.packs ~= "" then
            prize = ((prize == "") and "" or (prize..",")) .. other_data.packs;
        end; 
        self.mPrize:setText(prize);
    else
        self.mLife:setText("");
        self.mMatchName:setText("");
        self.mRank:setText("");
        self.mPrize:setText("");
    end
end

function MatchPrizeDialog:dismiss()
    self.super.dismiss(self)
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeEvent)
end

function MatchPrizeDialog:onShareBtnClick()
    local path = System.getStorageImagePath().."egame_share";
    ToolKit.takeShot(self.mBg.m_drawingID,path);
    EventDispatcher.getInstance():dispatch(Event.Call,kTakeShotComplete);
end

function MatchPrizeDialog:onGetPrizeBtnClick()
    local data = {};
    data.param = {};
    local other_data = self.datas.other_data;
    if other_data then
        data.param.match_id = other_data.match_id or "";
        data.param.mail_id = self.datas.id or "";
        HttpModule.getInstance():execute(HttpModule.s_cmds.getMatchPrize,data);
    end;
    self:dismiss();
end

function MatchPrizeDialog:onHttpGetMatchPrize(isSuccess, message)
    if not isSuccess then
        if type(message) == "number" then
            return; 
        elseif message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value(),2000);
            return;
        end;  
    end;
    ChessToastManager.getInstance():showSingle("领取成功");
    self:setGetPrizeBtnStatus(1);
end

function MatchPrizeDialog:setGetPrizeBtnStatus(flag)
    if tonumber(flag) == 1 then
        self.mGetPrizeBtn:setGray(true);
        self.mGetPrizeBtn:setEnable(false);
        self.mGetPrizeTxt:setText("已领取");
        self.datas.is_operate = "1";
    elseif tonumber(flag) == 0 then
        self.mGetPrizeBtn:setGray(false);
        self.mGetPrizeBtn:setEnable(true);
        self.mGetPrizeTxt:setText("领取奖励");
        self.datas.is_operate = "0";
    end;
end

function MatchPrizeDialog:setWatchBtnEvent(obj,func)
    self.mWatchBtnEventObj = obj;
    self.mWatchBtnEventFunc = func;
end

function MatchPrizeDialog:setShareBtnEvent(obj,func)
    self.mShareBtnEventObj = obj;
    self.mShareBtnEventFunc = func;
end

function MatchPrizeDialog:onNativeEvent(param,data)
    if param == kFriend_UpdateUserData then
        for _,userData in ipairs(data) do
            if self.mMyUid == userData.mid then
                local head_bg   = self.mBg:getChildByName("head_bg")
                local name      = self.mBg:getChildByName("name")
                self:setHeadIcon(head_bg,userData)
                name:setText(userData.mnick)
            end
        end
    end
end

function MatchPrizeDialog:setHeadIcon()
    self.m_icon = new(Mask,UserInfo.DEFAULT_ICON[1],"common/background/head_mask_bg_86.png");
    self.m_icon:setSize(86,86);
    self.m_icon:setAlign(kAlignCenter);
    self.m_icon:setUrlImage(UserInfo.getInstance():getIcon(),UserInfo.DEFAULT_ICON[1]);
    self.mHeadBg:addChild(self.m_icon);
    self.mName:setText(UserInfo.getInstance():getName());
    self.mLevel:setFile(string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevel()));
    self.mLevel:setLevel(1);
    local frameRes = UserSetInfo.getInstance():getFrameRes();
    if not frameRes then return end
    self.mVip:setVisible(frameRes.visible);
    local fw,fh = self.mVip:getSize();
    if frameRes.frame_res then
        self.mVip:setFile(string.format(frameRes.frame_res,130));
    end
end

MatchPrizeDialog.onHttpRequestsCallBack = function(self, command, ...)
	Log.i("MatchPrizeDialog.onHttpRequestsCallBack")
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self, ...)
	end 
end

MatchPrizeDialog.s_httpRequestsCallBackFuncMap = 
{
	[HttpModule.s_cmds.getMatchPrize] = MatchPrizeDialog.onHttpGetMatchPrize,
}