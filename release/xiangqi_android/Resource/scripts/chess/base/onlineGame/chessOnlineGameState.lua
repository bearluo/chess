--region ChessGameState.lua
--Author : BearLuo
--createDate   : 2015/4/1
--updateDate   : 2015/4/1
--
require("gameBase/gameState");

ChessGameState = class(GameState);

--ctor 不做耗时的占大量内存的初始化工作
ChessGameState.ctor = function(self)
	
end

--resume 启动动画、注册消息之类的事情
ChessGameState.resume = function(self)
	GameState.resume(self);
end

--pause 暂停动画，取消事件注册
ChessGameState.pause = function(self)
	GameState.pause(self);
end

ChessGameState.dtor = function(self)

end 

