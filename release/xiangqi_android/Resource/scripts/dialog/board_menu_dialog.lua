require(VIEW_PATH .. "room_menu_dialog_view");
require(BASE_PATH.."chessDialogScene")
BoardMenuDialog = class(ChessDialogScene,false);


BoardMenuDialog.ctor = function(self,room)
    super(self,room_menu_dialog_view);

	self.m_room = room;

	self.m_root_view = self.m_root;

	self.m_root_view:setEventTouch(self,self.onTouch);
	self.m_borar_menu_dialog_bg = self.m_root_view:getChildByName("room_menu_full_screen_bg");
    self.m_root_view:getChildByName("room_menu_dialog"):setEventTouch(self,function()end);


	self.m_board_menu_undo_btn = self.m_root_view:getChildByName("room_menu_dialog_bg"):getChildByName("room_menu_undo_btn");
	self.m_board_menu_draw_btn = self.m_root_view:getChildByName("room_menu_dialog_bg"):getChildByName("room_menu_draw_btn");
	self.m_board_menu_surrender_btn = self.m_root_view:getChildByName("room_menu_dialog_bg"):getChildByName("room_menu_surrender_btn");
	self.m_board_menu_setting_btn = self.m_root_view:getChildByName("room_menu_dialog_bg"):getChildByName("room_menu_setting_btn");
	self.roomMenuBackButton = self.m_root_view:getChildByName("room_menu_dialog_bg"):getChildByName("roomMenuBackButton");

	self.m_board_menu_undo_btn:setOnClick(self,self.undo);
	self.m_board_menu_draw_btn:setOnClick(self,self.draw);
	self.m_board_menu_surrender_btn:setOnClick(self,self.surrender);
	self.m_board_menu_setting_btn:setOnClick(self,self.setting);
	self.roomMenuBackButton:setOnClick(self.m_room, self.m_room.back_action);

	self:setNeedMask(false)
	self:setVisible(false);
end

BoardMenuDialog.dtor = function(self)
	self.m_root_view = nil;

end

BoardMenuDialog.isShowing = function(self)
	return self:getVisible();
end

BoardMenuDialog.onTouch = function(self)
	print_string("SettingDialog.onTouch");
	self:dismiss();
end

BoardMenuDialog.show = function(self)
    if RoomProxy.getInstance():getCurRoomType() ~= RoomConfig.ROOM_TYPE_WATCH_ROOM then
	    self.m_board_menu_undo_btn:setEnable(self.m_room:isEnableUndo() or self.m_room.isUndoAble); 
	    self.m_board_menu_draw_btn:setEnable(self.m_room:isEnableDraw()); 
	    self.m_board_menu_surrender_btn:setEnable(self.m_room:isEnableSurrender());
	    self.m_board_menu_undo_btn:setGray(not (self.m_room:isEnableUndo() or self.m_room.isUndoAble)); 
	    self.m_board_menu_draw_btn:setGray(not self.m_room:isEnableDraw()); 
	    self.m_board_menu_surrender_btn:setGray(not self.m_room:isEnableSurrender());
    else
	    self.m_board_menu_undo_btn:setEnable(false); 
	    self.m_board_menu_draw_btn:setEnable(false); 
	    self.m_board_menu_surrender_btn:setEnable(false);
	    self.m_board_menu_undo_btn:setGray(true); 
	    self.m_board_menu_draw_btn:setGray(true); 
	    self.m_board_menu_surrender_btn:setGray(true);
    end

    if RoomProxy.getInstance():getCurRoomType() == RoomConfig.ROOM_TYPE_ARENA_ROOM then
        self.m_board_menu_undo_btn:setEnable(false);
        self.m_board_menu_undo_btn:setGray(true);
    end

	self:setVisible(true);
    self.super.show(self,false);
end

BoardMenuDialog.undo = function(self)
	print_string("BoardMenuDialog.undo ");
	self.m_room:undoAction();
	self:dismiss();
end

BoardMenuDialog.draw = function(self)
	print_string("BoardMenuDialog.draw ");
	self.m_room:draw();
	self:dismiss();

end


BoardMenuDialog.surrender = function(self)
	print_string("BoardMenuDialog.surrender ");
	self.m_room:surrender();
	self:dismiss();

end

BoardMenuDialog.setting = function(self)
	print_string("BoardMenuDialog.setting ");
	self.m_room:setting();
	self:dismiss();
end

--BoardMenuDialog.chess = function(self)
--	print_string("BoardMenuDialog.chess");
--	self.m_room:chess();
--	self:dismiss();
--end

BoardMenuDialog.dismiss = function(self)
	self:setVisible(false);
    self.super.dismiss(self,false);
end