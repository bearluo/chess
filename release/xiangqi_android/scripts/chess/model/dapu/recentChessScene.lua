require(BASE_PATH.."chessScene");


RecentChessScene = class(ChessScene);

RecentChessScene.s_controls = 
{
    back_btn = 1;
    content_view = 2;
}

RecentChessScene.s_cmds = 
{
}

RecentChessScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = RecentChessScene.s_controls;
    self:create();
end 
RecentChessScene.resume = function(self)
    ChessScene.resume(self);
    self:init();
end;


RecentChessScene.pause = function(self)
	ChessScene.pause(self);
end 


RecentChessScene.dtor = function(self)
end 

----------------------------------- function ----------------------------

RecentChessScene.create = function(self)
    self.m_contentView = self:findViewById(self.m_ctrls.content_view);
    local w,h = self:getSize();
    local mw,mh = self.m_contentView:getSize();
    self.m_contentView:setSize(mw,mh+h-800);
    self:createListView();
end

--初始化部分状态
RecentChessScene.init = function(self)
	
end

RecentChessScene.createListView = function(self)
    if not self.m_contentView then return end;
    if self.m_listView then
        self.m_contentView:removeChild(self.m_listView,true);
    end
    local datas = self:requestCtrlCmd(RecentChessController.s_cmds.updateLocal);
    if datas and table.maxn(datas) > 0 then
        self.m_listAdapter = new(CacheAdapter,RecentChessItem,datas);
        local w,h = self.m_contentView:getSize();
        self.m_listView = new(ListView,0,0,w,h);
        self.m_listView:setAdapter(self.m_listAdapter);
        self.m_contentView:addChild(self.m_listView);
    end
end

----------------------------------- onClick ---------------------------------

RecentChessScene.onBack = function(self)
    self:requestCtrlCmd(RecentChessController.s_cmds.onBack);
end


----------------------------------- config ------------------------------
RecentChessScene.s_controlConfig = 
{
	[RecentChessScene.s_controls.back_btn]          = {"top_menu","back_btn"}; 
    [RecentChessScene.s_controls.content_view]      = {"content_view"};
};

RecentChessScene.s_controlFuncMap =
{
    [RecentChessScene.s_controls.back_btn]  = RecentChessScene.onBack;
};


RecentChessScene.s_cmdConfig =
{
    
}


-------------------------------- private node ----------------

RecentChessItem = class(Node);

RecentChessItem.ctor = function(self,data)
    self.m_data = data;
    self.m_bg = new(Button,"friends/friend_msg_bg.png");
    self.m_bg:setAlign(kAlignCenter)
    self.m_bg:setSrollOnClick();
    self.m_bg:setOnClick(self,self.gotoChessBoard);
    local w,h = self.m_bg:getSize();
    self:setSize(w,h+10);
    self:addChild(self.m_bg);
    self.m_icon = new(Image,"dapu/chess_icon.png");
    self.m_icon:setPos(15,0);
    self.m_icon:setAlign(kAlignLeft);
    self.m_bg:addChild(self.m_icon);

    self.m_icon_icon = new(Image,"dapu/fupan.png");
    self.m_icon_icon:setPos(-1,-3);
    self.m_icon:addChild(self.m_icon_icon);

   

    self.m_name = new(Text,data.fileName,nil,nil,nil,nil,28,105,50,35);
    self.m_name:setPos(100,22);
    self.m_bg:addChild(self.m_name);
    self.m_introduce = new(Node)--new(Text,"",nil,nil,nil,nil,20,105,50,35);
    self.m_introduce:setPos(100,60);
    self.m_bg:addChild(self.m_introduce);
    self.m_createTime = new(Text,data.time,nil,nil,nil,nil,18,105,50,35);
    self.m_createTime:setAlign(kAlignRight);
    self.m_createTime:setPos(15,-15);
    self.m_bg:addChild(self.m_createTime);
    if data.manual_type == 2 then
        local text = new(Text,"创建者:2",nil,nil,nil,nil,20,105,50,35);
        self.m_icon_icon:setFile("dapu/endgate.png");
        self.m_introduce:addChild(text);
    elseif data.manual_type == 3 then
        self:setFuPan(data);
    elseif data.manual_type == 4 then
        local text = new(Text,"创建者:4",nil,nil,nil,nil,20,105,50,35);
        self.m_icon_icon:setFile("dapu/dapu.png");
        self.m_introduce:addChild(text);
    elseif data.manual_type == 5 then
        local text = new(Text,"创建者:5",nil,nil,nil,nil,20,105,50,35);
        self.m_icon_icon:setFile("dapu/endgate.png");
        self.m_introduce:addChild(text);
    else
        self:setFuPan(data);
    end
end

RecentChessItem.setFuPan = function(self,data)
    self.m_icon_icon:setFile("dapu/fupan.png");
    local text = new(Text,data.red_name,nil,nil,nil,nil,20,105,50,35);
    self.m_introduce:addChild(text);
    local preView = text;
    local text = new(Text,"(红)",nil,nil,nil,nil,20,255,0,0);
    if data.win_flag == FLAG_RED then
        local img = new(Image,"dapu/win_icon.png");
        img:setAlign(kAlignLeft)
        img:setPos(-30);
        text:addChild(img);
    end
    self:addViewToOtherViewAfter(preView,text,5);
    local preView = text;
    local text = new(Text,"VS",nil,nil,nil,nil,20,105,50,35);
    self:addViewToOtherViewAfter(preView,text,5);
    local preView = text;
    local text = new(Text,data.black_name,nil,nil,nil,nil,20,105,50,35);
    self:addViewToOtherViewAfter(preView,text,5);
    local preView = text;
    local text = new(Text,"(黑)",nil,nil,nil,nil,20,35,35,35);
    if data.win_flag == FLAG_BLACK then
        local img = new(Image,"dapu/win_icon.png");
        img:setAlign(kAlignLeft)
        img:setPos(-30);
        text:addChild(img);
    end
    self:addViewToOtherViewAfter(preView,text,5);
end

RecentChessItem.addViewToOtherViewAfter = function(self,preView,aftView,diffx)
    if preView:getParent() then
        diffx = diffx or 0;
        local x,y = preView:getPos();
        local w,h = preView:getSize();
        local aw,ah = aftView:getSize();
        aftView:setPos(x+w+diffx,y-h+ah);
        preView:getParent():addChild(aftView);
    end
end

RecentChessItem.gotoChessBoard = function(self)
    Log.i("RecentChessItem.gotoChessBoard");
    if self.m_data.manual_type == 2 then
        Log.i("error 本地不应该出现残局类型");
    elseif self.m_data.manual_type == 3 then
        UserInfo.getInstance():setDapuSelData(self.m_data);
        StateMachine:getInstance():pushState(States.ReplayRoom,StateMachine.STYPE_CUSTOM_WAIT);
    elseif self.m_data.manual_type == 4 then
        UserInfo.getInstance():setDapuSelData(self.m_data);
        StateMachine:getInstance():pushState(States.ReplayRoom,StateMachine.STYPE_CUSTOM_WAIT);
    elseif self.m_data.manual_type == 5 then
        StateMachine:getInstance():pushState(States.CustomBoard,StateMachine.STYPE_CUSTOM_WAIT);
    else
        UserInfo.getInstance():setDapuSelData(self.m_data);
        StateMachine:getInstance():pushState(States.ReplayRoom,StateMachine.STYPE_CUSTOM_WAIT);
    end
end