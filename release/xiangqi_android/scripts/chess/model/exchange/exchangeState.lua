require("view/view_config");
require(VIEW_PATH.."exchange_view");
require(MODEL_PATH.."exchange/exchangeController");
require(MODEL_PATH.."exchange/exchangeScene");
require(BASE_PATH.."chessState");

ExchangeState = class(ChessState);


ExchangeState.ctor = function(self)
	self.m_controller = nil;
end

ExchangeState.getController = function(self)
	return self.m_controller;
end

ExchangeState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(ExchangeController, self, ExchangeScene, exchange_view);
	return true;
end

ExchangeState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


ExchangeState.onExit = function(self)
	sys_exit();
end


ExchangeState.onClose = function(self)
end

ExchangeState.dtor = function(self)
end