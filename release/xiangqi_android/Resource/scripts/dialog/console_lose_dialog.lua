require("core/constants");
require("animation/headTurnAnim");
require(VIEW_PATH .. "console_lose_dialog_view");
require(BASE_PATH.."chessDialogScene")
ConsoleLoseDialog = class(ChessDialogScene,false);

ConsoleLoseDialog.ctor = function(self,room)
	super(self,console_lose_dialog_view);

	self.m_root_view = self.m_root;

	self.m_room = room;

	self.m_dialog_bg = self.m_root_view:getChildByName("console_lose_dialog_full_screen_bg");


	self.m_content_view = self.m_root_view:getChildByName("console_lose_content_view");

	self.m_console_result_texture = self.m_content_view:getChildByName("console_lose_result_texture");

	self.m_console_lose_title = self.m_content_view:getChildByName("console_lose_title");

    self.m_console_lose_dialog_bg = self.m_content_view:getChildByName("console_lose_dialog_bg");

	self.m_console_chest_tips = self.m_content_view:getChildByName("console_lose_chest_tips");
 



	self.m_cancel_btn = self.m_content_view:getChildByName("console_lose_cancel_btn");
	self.m_restart_btn = self.m_content_view:getChildByName("console_lose_restart_btn");  --重新开始
	self.m_save_btn = self.m_content_view:getChildByName("console_lose_save_btn");  --保存


	self.m_cancel_btn:setOnClick(self,self.cancel);
	self.m_restart_btn:setOnClick(self,self.restart);
	self.m_save_btn:setOnClick(self,self.save);

	self.m_dialog_bg:setEventTouch(self,self.onTouch);

	self:setVisible(false);

    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)
end

ConsoleLoseDialog.dtor = function(self)
	self.m_root_view = nil;
    self.mDialogAnim.stopAnim()
end

ConsoleLoseDialog.isShowing = function(self)
	return self:getVisible();
end

ConsoleLoseDialog.onTouch = function(self)
	print_string("ConsoleLoseDialog.onTouch");
end

ConsoleLoseDialog.show = function(self)
	kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
    if not  self.m_AnimLose then
        self.m_AnimLose = new(AnimLose);
    end;
    self.m_console_lose_dialog_bg:addChild(self.m_AnimLose);
    self.m_AnimLose:setPos(50, -25);
    self.m_AnimLose:play();
	local curLevel = UserInfo.getInstance():getPlayingLevel();
	
	self.m_console_chest_tips:setText(string.format("你在“%s”中,挑战失败",User.AI_TITLE[curLevel]));

	self:setVisible(true);
    self.super.show(self,self.mDialogAnim.showAnim);
end


ConsoleLoseDialog.cancel = function(self)
	print_string("ConsoleLoseDialog.cancel ");
	self:dismiss();
end


--下一关
ConsoleLoseDialog.restart = function(self)
	self:dismiss();
	if self.m_room then
		self.m_room:onStartGame();
	end
end

ConsoleLoseDialog.save = function(self)
	self:dismiss();
	if self.m_room then
		self.m_room:saveChess();
	end
end

ConsoleLoseDialog.dismiss = function(self)
    delete(self.m_AnimLose);
    self.m_AnimLose = nil;
--	self:setVisible(false);
    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
end