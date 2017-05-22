require(VIEW_PATH .. "start_evaluation_game_dialog_view");
require(BASE_PATH.."chessDialogScene");

StartEvaluationGameDialog = class(ChessDialogScene,false)

function StartEvaluationGameDialog:ctor()
    super(self,start_evaluation_game_dialog_view)
    self.mStartBtn = self.m_root:getChildByName("start_btn")
    self.mCloseBtn = self.m_root:getChildByName("close_btn")
    self.mStartBtn:setOnClick(self,function()
        StateMachine.getInstance():pushState(States.evaluationGame,StateMachine.STYPE_CUSTOM_WAIT)
    end)
    self.mCloseBtn:setOnClick(self,self.showUpdateGuideDialog)
end
require("dialog/second_login_guide_dialog");
function StartEvaluationGameDialog:showUpdateGuideDialog()
    self:dismiss()
    -- µ¯³öÖ¸Òýµ¯´°2
    if not self.m_secondLogGuideDialog then
        self.m_secondLogGuideDialog = new(SecondLogGuideDialog);
    end
    self.m_secondLogGuideDialog:show();
end

function StartEvaluationGameDialog:show()
    self.super.show(self,false)
    StatisticsManager.getInstance():onNewUserCountToPHP(StatisticsManager.NEW_USER_COUNT_EVALUATION,UserInfo.getInstance():getIsFirstLogin())
end