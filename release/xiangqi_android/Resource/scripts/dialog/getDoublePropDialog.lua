require(VIEW_PATH .. "get_double_prop_dialog_view");
require(BASE_PATH.."chessDialogScene");

GetDoublePropDialog = class(ChessDialogScene,false)

function GetDoublePropDialog:ctor()
    super(self,get_double_prop_dialog_view)
    self.mTipsTxt = self.m_root:getChildByName("tips_txt")
    self.mQuickPlayBtn = self.m_root:getChildByName("quick_play_btn")
    self.m_root:getChildByName("back_btn"):setOnClick(self,self.dismiss)
    self:setNeedBackEvent(false)
end

function GetDoublePropDialog:setTipsTxt(str)
    self.mTipsTxt:setText(str)
end

function GetDoublePropDialog:setQuickPlayBtnClick(obj,func)
    self.mQuickPlayBtn:setOnClick(obj,func)
end

function GetDoublePropDialog:show()
    self.super.show(self,false)
    StatisticsManager.getInstance():onNewUserCountToPHP(StatisticsManager.NEW_USER_COUNT_DOUBLE_PROP,UserInfo.getInstance():getIsFirstLogin())
end