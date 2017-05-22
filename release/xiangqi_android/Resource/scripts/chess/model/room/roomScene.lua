
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
    if BroadCastHorn.getInstance():isPlaying() then
        local broadMsgType = BroadCastHorn.getInstance():getMsgType();
        if tonumber(broadMsgType) and tonumber(broadMsgType) == 2 then
            BroadCastHorn.getInstance():dismiss();
        end;
    end;
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


