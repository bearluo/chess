--region ChessGameState.lua
--Author : BearLuo
--createDate   : 2015/4/1
--updateDate   : 2015/4/1
--
require("gameBase/gameState");

ChessState = class(GameState);

--ctor 不做耗时的占大量内存的初始化工作
ChessState.ctor = function(self)
	
end
ChessState.load = function(self)
    GameState.load(self);
end;
--resume 启动动画、注册消息之类的事情
ChessState.resume = function(self)
	GameState.resume(self);
end

--pause 暂停动画，取消事件注册
ChessState.pause = function(self)
	GameState.pause(self);
end

ChessState.dtor = function(self)

end 

ChessState.gobackLastState = function(self)
    if not ChessDialogManager.dismissDialog() then
        if self.m_controller and self.m_controller.onBack then
            self.m_controller.onBack(self.m_controller);
        end
    end
end

ChessState.getController = function(self)
    return self.m_controller;
end

