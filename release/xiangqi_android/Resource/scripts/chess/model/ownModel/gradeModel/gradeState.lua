--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23
require("view/view_config");
require(VIEW_PATH.."grade_view");
require(MODEL_PATH.."ownModel/gradeModel/gradeController");
require(MODEL_PATH.."ownModel/gradeModel/gradeScene");
require(BASE_PATH.."chessState");

GradeState = class(ChessState);


GradeState.ctor = function(self)
	self.m_controller = nil;
end

GradeState.getController = function(self)
	return self.m_controller;
end

GradeState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(GradeController, self, GradeScene, grade_view);
	return true;
end

GradeState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end

GradeState.onExit = function(self)
	sys_exit();
end


GradeState.onClose = function(self)
end

GradeState.dtor = function(self)
end
