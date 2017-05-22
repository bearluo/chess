
require(BASE_PATH.."chessScene");
require("view/selectButton");
require("dialog/progress_dialog");
require("dialog/create_room_dialog");

CollectScene = class(ChessScene);

CollectScene.s_controls = 
{
    back_btn            = 1;
    content_view        = 2;
}

CollectScene.s_cmds = 
{

}

CollectScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = CollectScene.s_controls;
    self:initView();
end 

CollectScene.resume = function(self)
    ChessScene.resume(self);
    self:showShareListWebView();
end;

CollectScene.pause = function(self)
	ChessScene.pause(self);
    call_native(kCollectWebViewClose);
end 


CollectScene.dtor = function(self)

end 


------------------------------function------------------------------
CollectScene.initView = function(self)
    --content
    self.m_content_holder = self:findViewById(self.m_ctrls.content_view);
end;

CollectScene.showShareListWebView = function(self)
	local width_content,height_content = self.m_content_holder:getSize();
    local absoluteX,absoluteY = self.m_content_holder:getAbsolutePos();
    local x = absoluteX*System.getLayoutScale();
    local y = 70*System.getLayoutScale();
    local width = width_content*System.getLayoutScale();
    local height = height_content*System.getLayoutScale() - 70*System.getLayoutScale();
    NativeEvent.getInstance():showCollectWebView(x,y,width,height);
end;

CollectScene.onBackActionBtnClick = function(self)
    self:requestCtrlCmd(ReplayController.s_cmds.back_action);
end;

---------------------------------config-------------------------------
CollectScene.s_controlConfig = 
{
	[CollectScene.s_controls.back_btn]         = {"title_view","back_btn"};
    [CollectScene.s_controls.content_view]     = {"content_view","content_holder"};
};

--定义控件的触摸响应函数
CollectScene.s_controlFuncMap =
{
	[CollectScene.s_controls.back_btn]       = CollectScene.onBackActionBtnClick;
};

CollectScene.s_cmdConfig = 
{
    
}