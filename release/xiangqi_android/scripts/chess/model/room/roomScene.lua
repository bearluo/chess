
require(BASE_PATH.."chessScene");


RoomScene = class(ChessScene);

RoomScene.s_controls = 
{
}

RoomScene.s_cmds = 
{
}

RoomScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = RoomScene.s_controls;
end 
RoomScene.resume = function(self)
    ChessScene.resume(self);
    
end;


RoomScene.pause = function(self)
	ChessScene.pause(self);
end 


RoomScene.dtor = function(self)
    
end 



--------------------------------function--------------------------------


----------------------------------- config ------------------------------
RoomScene.s_controlConfig = 
{
};

RoomScene.s_controlFuncMap =
{
};


RoomScene.s_cmdConfig =
{
}


