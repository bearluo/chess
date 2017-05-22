
require("view/view_config");
require(VIEW_PATH.."common_ussue_view");
require(MODEL_PATH.."ownModel/setModel/commonIssueModel/commonIssueScene");
require(MODEL_PATH.."ownModel/setModel/commonIssueModel/commonIssueController");
require(BASE_PATH.."chessState");

CommonIssueState = class(ChessState);


CommonIssueState.ctor = function(self)
	self.m_controller = nil;
end

CommonIssueState.getController = function(self)
	return self.m_controller;
end

CommonIssueState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(CommonIssueController, self, CommonIssueScene, common_ussue_view);
	return true;
end

CommonIssueState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end

CommonIssueState.onExit = function(self)
	sys_exit();
end


CommonIssueState.onClose = function(self)
end

CommonIssueState.dtor = function(self)
end
