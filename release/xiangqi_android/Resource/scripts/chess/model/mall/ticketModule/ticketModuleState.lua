--region ticketModuleState.lua
--Date 02016.11.12
--
--endregion


require("view/view_config");
require(VIEW_PATH.."ticket_view");
require(MODEL_PATH.."mall/ticketModule/ticketModuleController");
require(MODEL_PATH.."mall/ticketModule/ticketModuleScene");
require(BASE_PATH.."chessState");

TicketModuleState = class(ChessState);

function TicketModuleState.ctor (self)
	self.m_controller = nil;
end

function TicketModuleState.getController (self)
	return self.m_controller;
end

function TicketModuleState.load (self)
	ChessState.load(self);
	self.m_controller = new(TicketModuleController, self, TicketModuleScene, ticket_view);
	return true;
end

function TicketModuleState.unload (self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


function TicketModuleState.onExit (self)
	sys_exit();
end


function TicketModuleState.onClose (self)
end

function TicketModuleState.dtor (self)
end