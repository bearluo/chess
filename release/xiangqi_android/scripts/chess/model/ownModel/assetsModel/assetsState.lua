--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23
require("view/view_config");
require(VIEW_PATH.."assets_view");
require(MODEL_PATH.."ownModel/assetsModel/assetsController");
require(MODEL_PATH.."ownModel/assetsModel/assetsScene");
require(BASE_PATH.."chessState");

AssetsState = class(ChessState);


AssetsState.ctor = function(self)
	self.m_controller = nil;
end

AssetsState.getController = function(self)
	return self.m_controller;
end

AssetsState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(AssetsController, self, AssetsScene, assets_view);
	return true;
end

AssetsState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end

AssetsState.onExit = function(self)
	sys_exit();
end


AssetsState.onClose = function(self)
end

AssetsState.dtor = function(self)
end
