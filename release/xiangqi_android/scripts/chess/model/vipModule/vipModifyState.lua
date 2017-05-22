require("view/view_config");
require(VIEW_PATH.."vip_modify_view");
require(MODEL_PATH.."vipModule/vipModifyController");
require(MODEL_PATH.."vipModule/vipModifySecne");
require(BASE_PATH.."chessState");

VipModifyState = class(ChessState);

VipModifyState.ctor = function(self)
    self.m_controller = nil;
end

VipModifyState.getController = function(self)
    return self.m_controller;
end

VipModifyState.load = function(self)
    ChessState.load(self);
	self.m_controller = new(VipModifyController, self, VipModifyScene, vip_modify_view);
	return true;
end

VipModifyState.unload = function(self)
    ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end

VipModifyState.onExit = function(self)
    sys_exit();
end

VipModifyState.dtor = function(self)

end