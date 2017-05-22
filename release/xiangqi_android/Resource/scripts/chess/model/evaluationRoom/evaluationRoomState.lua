require("view/view_config");
require(VIEW_PATH.."evaluation_room_scene");
require(MODEL_PATH.."evaluationRoom/evaluationRoomController");
require(MODEL_PATH.."evaluationRoom/evaluationRoomScene");
require(MODEL_PATH.."room/roomState");

EvaluationRoomState = class(RoomState);


EvaluationRoomState.ctor = function(self)
	self.m_controller = nil;
end

EvaluationRoomState.getController = function(self)
	return self.m_controller;
end

EvaluationRoomState.load = function(self)
	RoomState.load(self);
	self.m_controller = new(EvaluationRoomController, self, EvaluationRoomScene, evaluation_room_scene);
	return true;
end

EvaluationRoomState.unload = function(self)
	RoomState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


EvaluationRoomState.onExit = function(self)
	sys_exit();
end


EvaluationRoomState.onClose = function(self)
end

EvaluationRoomState.dtor = function(self)
end