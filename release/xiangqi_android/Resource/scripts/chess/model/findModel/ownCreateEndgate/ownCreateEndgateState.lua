--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23
require("view/view_config");
require(VIEW_PATH.."find_own_create_endgate_view");
require(MODEL_PATH.."findModel/ownCreateEndgate/ownCreateEndgateController");
require(MODEL_PATH.."findModel/ownCreateEndgate/ownCreateEndgateScene");
require(BASE_PATH.."chessState");

OwnCreateEndgateState = class(ChessState);


OwnCreateEndgateState.ctor = function(self)
	self.m_controller = nil;
end

OwnCreateEndgateState.getController = function(self)
	return self.m_controller;
end

OwnCreateEndgateState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(OwnCreateEndgateController, self, OwnCreateEndgateScene, find_own_create_endgate_view);
	return true;
end

OwnCreateEndgateState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end

OwnCreateEndgateState.onExit = function(self)
	sys_exit();
end


OwnCreateEndgateState.onClose = function(self)
end

OwnCreateEndgateState.dtor = function(self)
end
