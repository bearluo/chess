require(VIEW_PATH .. "evaluation_room_accounts_dialog_view");
require(BASE_PATH.."chessDialogScene");

EvaluationRoomAccountsDialog = class(ChessDialogScene,false)
EvaluationRoomAccountsDialog.s_showType = {}
EvaluationRoomAccountsDialog.s_showType.WIN = 1
EvaluationRoomAccountsDialog.s_showType.DRAW = 2
EvaluationRoomAccountsDialog.s_showType.LOSE = 3
function EvaluationRoomAccountsDialog:ctor()
    super(self,evaluation_room_accounts_dialog_view)
    self.mTitleIcon = self.m_root:getChildByName("title_icon")
    self.mTitleTxtIcon = self.mTitleIcon:getChildByName("title_txt_icon")
    self.mScoreRichTxtHandler = self.m_root:getChildByName("score_rich_txt_handler")
    self.mHeadBg = self.m_root:getChildByName("head_bg")
    self.mLevelIcon = self.m_root:getChildByName("level_icon")
    self:setNeedBackEvent(false)
    local user = UserInfo.getInstance()
    self:setHeadIcon(user:getIconType(),user:getIcon())
    self:setScore(user:getScore())
    self.mUploadView = self.m_root:getChildByName("upload_view")
    self:setShieldClick(self,self.dismiss)
    self.mBg = self.m_root:getChildByName("bg")
    self.mBg:setEventTouch(self,function()end)
end

function EvaluationRoomAccountsDialog:dtor()
    delete(self.mGetDoublePropDialog)
    self.mGetDoublePropDialog = nil
end

--[Comment]
-- EvaluationRoomAccountsDialog.s_showType
function EvaluationRoomAccountsDialog:setShowType(showType)
    if showType == EvaluationRoomAccountsDialog.s_showType.WIN then
        self.mTitleIcon:setFile("animation/red_banners.png")
        self.mTitleTxtIcon:setFile("animation/win.png")
    elseif showType == EvaluationRoomAccountsDialog.s_showType.DRAW then
        self.mTitleIcon:setFile("animation/green_banners.png")
        self.mTitleTxtIcon:setFile("animation/draw.png")
    else
        self.mTitleIcon:setFile("animation/gray_banners.png")
        self.mTitleTxtIcon:setFile("animation/lose.png")
    end
end

function EvaluationRoomAccountsDialog:reportDataResult(isSuccess,score,offset)
    self.mUploadView:removeAllChildren()
    if isSuccess then
        self:setShieldClick(self,self.showGetDoublePropDialog)
        self:setScore(score,offset)
    else
        self:setShieldClick(self,self.dismiss)
        local richText = new(RichText,"由于网络原因,本次评测结果上报失败！#l下次登录会自动重新上报。#l三天内上报成功可获得双倍积分卡。", select(1,self.mUploadView:getSize()), select(2,self.mUploadView:getSize()), kAlignTopLeft, fontName, 28, 245, 55, 50, true,10)
        self.mUploadView:addChild(richText)
    end
end
require(DIALOG_PATH .. "getDoublePropDialog")
function EvaluationRoomAccountsDialog:showGetDoublePropDialog()
    self:dismiss()
    if not self.mGetDoublePropDialog then
        self.mGetDoublePropDialog = new(GetDoublePropDialog)
    end
    local countTime = UserInfo.getInstance():getDoublePropCountTime()
    local useTime = UserInfo.getInstance():getDoublePropUseTime()
    self.mGetDoublePropDialog:setTipsTxt( string.format("%d小时内获胜的前%d局联网对局可获双倍积分",countTime/3600,useTime))
    self.mGetDoublePropDialog:setQuickPlayBtnClick(self,function()
        StateMachine.getInstance():popState()
        local roomConfig = RoomConfig.getInstance();
        local money = UserInfo.getInstance():getMoney();
        local gotoRoom = RoomProxy.getInstance():getMatchRoomByMoney(money);
    
        if not gotoRoom then 
            StateMachine.getInstance():pushState(States.Online)
        else
            RoomProxy.getInstance():gotoLevelRoom(gotoRoom.level);
        end
    end)
    self.mGetDoublePropDialog:show()
end

function EvaluationRoomAccountsDialog:setHeadIcon(iconType,iconUrl)
    iconType = tonumber(iconType) or 0
    if not self.mHeadIcon then
        self.mHeadIcon = new(Mask,UserInfo.DEFAULT_ICON[1],"common/background/head_mask_bg_200.png")
        self.mHeadIcon:setSize(self.mHeadBg:getSize())
        self.mHeadBg:addChild(self.mHeadIcon)
    end
    if iconType ~= -1 then
        self.mHeadIcon:setUrlImage(iconUrl)
    else
        self.mHeadIcon:setFile(UserInfo.DEFAULT_ICON[iconType] or UserInfo.DEFAULT_ICON[1])
    end
end

function EvaluationRoomAccountsDialog:setScore(score,offset)
    score = tonumber(score) or 0
    offset = tonumber(offset) or 0
    self.mLevelIcon:setFile( string.format("common/icon/big_level_%d.png",10-UserInfo.getInstance():getDanGradingLevelByScore(score)))
    local str = "积分:"
    str = str .. score
    if offset ~= 0 then
        if offset > 0 then
            str = string.format("%s+%d",str,offset)
        else
            str = string.format("%s-%d",str,-offset)
        end
    end
    self.mScoreRichTxtHandler:removeAllChildren()
    local richText = new(RichText,str, select(1,self.mScoreRichTxtHandler:getSize()), select(2,self.mScoreRichTxtHandler:getSize()), kAlignCenter, fontName, 36, 255, 180, 100, false)
    self.mScoreRichTxtHandler:addChild(richText)
end


function EvaluationRoomAccountsDialog:show()
    self.super.show(self,false)
    StatisticsManager.getInstance():onNewUserCountToPHP(StatisticsManager.NEW_USER_COUNT_LEVEL,UserInfo.getInstance():getIsFirstLogin())
end