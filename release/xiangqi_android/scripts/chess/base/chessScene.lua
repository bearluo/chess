--region ChessGameScene.lua
--Author : BearLuo
--createDate   : 2015/4/1
--updateDate   : 2015/4/1
--

require("gameBase/gameScene");

ChessScene = class(GameScene);

ChessScene.ctor = function(self,viewConfig,controller)
end 


ChessScene.resume = function(self)
    GameScene.resume(self);

end;

ChessScene.pause = function(self)
    GameScene.pause(self);

end;

ChessScene.dtor = function(self)
end 


ChessScene.findViewById = function(self,id)
    return self:getControl(id);
end