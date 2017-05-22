require(BASE_PATH .. "chessState")
require(VIEW_PATH .. "compete_view")
require(MODEL_PATH .. "compete/competeController")
require(MODEL_PATH .. "compete/competeScene")

CompeteState = class(ChessState)

CompeteState.ctor = function( self )
	-- body
end

CompeteState.dtor = function( self )
	-- body
end

CompeteState.getController = function( self )
	return self.m_controller
end

CompeteState.load = function( self )
	ChessState.load(self)
	self.m_controller = new(CompeteController, self, CompeteScene, compete_view)
	return true
end

CompeteState.unload = function( self )
	ChessState.unload(self)
	delete(self.m_controller)
	self.m_controller = nil
end

CompeteState.onClose = function( self )
	-- body
end

CompeteState.onExit = function( self )
	sys_exit()
end
