--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23

require(BASE_PATH.."chessScene");

OwnCreateEndgateScene = class(ChessScene);

OwnCreateEndgateScene.s_controls = 
{
    back_btn                = 1;
    view_handler            = 2;              
}

OwnCreateEndgateScene.s_cmds = 
{
    add_endgate             = 1;
}

OwnCreateEndgateScene.ctor = function(self,viewConfig,controller)
    local w,h               = self:getSize();
	self.m_ctrls            = OwnCreateEndgateScene.s_controls;
    self.mBackBtn           = self:findViewById(self.m_ctrls.back_btn);
    self.mViewHandler       = self:findViewById(self.m_ctrls.view_handler);
    local mw,mh             = self.mViewHandler:getSize();
    self.mEndgateScrollView = new(SlidingLoadView, 0, 0, mw,mh+h-System.getLayoutHeight(), true)
    self.mEndgateScrollView:setOnLoad(self,function(self)
        self:requestCtrlCmd(OwnCreateEndgateController.s_cmds.onLoadEndgate);
    end)
    self.mEndgateScrollView:setNoDataTip("大侠，您还没创建过残局，快去试试吧，残局被通关还能获得金币奖励哦");
    self.mViewHandler:addChild(self.mEndgateScrollView);
end 

OwnCreateEndgateScene.resume = function(self)
    ChessScene.resume(self);
    if not self.mInit then 
        self.mInit = true;
        self.mEndgateScrollView:reset()
        self.mEndgateScrollView:loadView();
    end
end

OwnCreateEndgateScene.pause = function(self)
	ChessScene.pause(self);
end 

OwnCreateEndgateScene.dtor = function(self)
end 
--占位
OwnCreateEndgateScene.setAnimItemEnVisible = function(self,ret)
end

OwnCreateEndgateScene.removeAnimProp = function(self)

end

OwnCreateEndgateScene.resumeAnimStart = function(self,lastStateObj,timer)

end

OwnCreateEndgateScene.pauseAnimStart = function(self,newStateObj,timer)

end

---------------------- func --------------------
function OwnCreateEndgateScene.onBackBtnClick(self)
    self:requestCtrlCmd(OwnCreateEndgateController.s_cmds.onBack);
end

require(MODEL_PATH .. "findModel/endgateListItem");
function OwnCreateEndgateScene.addEndgate(self,datas,isNoData)
    if type(datas) ~= "table" then return end;
    for i,data in ipairs(datas) do
        local item = new(EndgateListItem,data);
        self.mEndgateScrollView:addChild(item);
    end
    self.mEndgateScrollView:loadEnd(isNoData);
end

---------------------- config ------------------
OwnCreateEndgateScene.s_controlConfig = {
    [OwnCreateEndgateScene.s_controls.back_btn]                                   = {"back_btn"};
    [OwnCreateEndgateScene.s_controls.view_handler]                               = {"view_handler"};
}

OwnCreateEndgateScene.s_controlFuncMap = {
    [OwnCreateEndgateScene.s_controls.back_btn]                 = OwnCreateEndgateScene.onBackBtnClick;
};

OwnCreateEndgateScene.s_cmdConfig = {
    [OwnCreateEndgateScene.s_cmds.add_endgate]                  = OwnCreateEndgateScene.addEndgate;
    
}