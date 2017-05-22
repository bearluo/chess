require("core/anim")
require("core/prop")
require("dialog/chioce_dialog");
require(VIEW_PATH .. "match_dialog_view");
require(BASE_PATH.."chessDialogScene")


AddMailList = class(ChessDialogScene,false);

AddMailList.ctor = function(self) 
    super(self,match_dialog_view);


end

AddMailList.dtor = function(self)
	self.m_root_view = nil;

end


AddMailList.show = function(self,room)
    --local toast = new(ChessToastScene,room);
    --self:addToast(toast);
    --ChessToastManager.getInstance():show(showToast);
end


