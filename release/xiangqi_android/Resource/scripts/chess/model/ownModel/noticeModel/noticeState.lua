--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23
require("view/view_config");
require(VIEW_PATH.."notice_view");
require(MODEL_PATH.."ownModel/noticeModel/noticeController");
require(MODEL_PATH.."ownModel/noticeModel/noticeScene");
require(BASE_PATH.."chessState");

NoticeState = class(ChessState);


NoticeState.ctor = function(self)
	self.m_controller = nil;
end

NoticeState.getController = function(self)
	return self.m_controller;
end

NoticeState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(NoticeController, self, NoticeScene, notice_view);
	return true;
end

NoticeState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end

NoticeState.onExit = function(self)
	sys_exit();
end


NoticeState.onClose = function(self)
end

NoticeState.dtor = function(self)
end
