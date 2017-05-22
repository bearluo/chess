
require(VIEW_PATH .. "chioce_dialog_view");
require(BASE_PATH.."chessDialogScene")
ChioceDialog = class(ChessDialogScene,false);

ChioceDialog.MODE_SURE = 1;
ChioceDialog.MODE_AGREE = 2;
ChioceDialog.MODE_OK = 3;
ChioceDialog.MODE_OTHER = 4;
ChioceDialog.MODE_COMMON = 5;
ChioceDialog.MODE_SHOUCANG = 6; -- 收藏
ChioceDialog.MODE_REPLAY_ROOM = 7; -- 回放房间结束
ChioceDialog.MODE_FREEZEUSER = 8 ; --封号

ChioceDialog.ctor = function(self)
    super(self,chioce_dialog_view);
	self.m_root_view = self.m_root;

	self.m_dialog_bg = self.m_root_view:getChildByName("chioce_bg");

	self.m_content_view = self.m_root_view:getChildByName("chioce_content_view");

    self.m_check_btn = self.m_content_view:getChildByName("check_btn");
    self.m_check_btn:setOnClick(self, self.check);
    self.m_check = self.m_check_btn:getChildByName("check_bg");
    self.m_check:setVisible(false);
    self.m_check_txt = self.m_check_btn:getChildByName("check_txt");
	self.m_cancel_btn = self.m_content_view:getChildByName("chioce_cancel_btn");
	self.m_sure_btn = self.m_content_view:getChildByName("chioce_sure_btn");
	self.m_sure_texture = self.m_sure_btn:getChildByName("chioce_sure_text");
	self.m_cancel_texture = self.m_cancel_btn:getChildByName("chioce_cancel_text");
	self.m_close_btn = self.m_content_view:getChildByName("chioce_close_btn");
    self.m_close_btn:setVisible(false);
	self.m_ok_btn = self.m_content_view:getChildByName("chioce_ok_btn");
	self.m_ok_texture = self.m_ok_btn:getChildByName("chioce_ok_text");

	self.m_message = self.m_content_view:getChildByName("chioce_message");
	self.m_dialog_bg:setEventTouch(self,self.onTouch);

	self.m_cancel_btn:setOnClick(self,self.cancel);
	self.m_sure_btn:setOnClick(self,self.sure);
--	self.m_close_btn:setOnClick(self,self.cancel);
	self.m_ok_btn:setOnClick(self,self.sure);
    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)
    self:setNeedMask(false)
end

ChioceDialog.dtor = function(self)
    delete(self.m_root_view);
	self.m_root_view = nil;
    self.mDialogAnim.stopAnim()
end

ChioceDialog.isShowing = function(self)
	return self:getVisible();
end

ChioceDialog.onTouch = function(self)
	print_string("ChioceDialog.onTouch");
end

ChioceDialog.show = function(self)
	print_string("ChioceDialog.show ... ");
	kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
	self:setVisible(true);
    self.super.show(self,self.mDialogAnim.showAnim);
end

ChioceDialog.cancel = function(self)
	print_string("ChioceDialog.cancel ");
	self:dismiss();
    self.m_check_btn:setVisible(false);
	if self.m_negObj and self.m_negFunc then
		self.m_negFunc(self.m_negObj);
	end
end

ChioceDialog.sure = function(self)
	print_string("ChioceDialog.sure ");
	self:dismiss();
    self.m_check_btn:setVisible(false);
	if self.m_posObj and self.m_posFunc then
		self.m_posFunc(self.m_posObj,self.m_posArg);
	end
end

ChioceDialog.setMessage = function(self,message)
    self.m_message:removeAllChildren()
    local w,h = self.m_message:getSize()
    local richText = new(RichText,message, w, h, kAlignCenter, fontName, 32, 255, 255, 255, true,5)
 	self.m_message:addChild(richText)
end

ChioceDialog.setMode = function(self,mode,sure_str,cancel_str)
	self.m_mode = mode;	
--	self.m_close_btn:setOnClick(self,self.cancel);
	if self.m_mode == ChioceDialog.MODE_SURE then
--		self.m_close_btn:setVisible(false);
		local sure_text = sure_str or "确定";
		self.m_sure_texture:setText(sure_text);

		local cancel_text = cancel_str or "取消";
		self.m_cancel_texture:setText(cancel_text);

		self.m_cancel_btn:setVisible(true);
		self.m_sure_btn:setVisible(true);

		self.m_ok_btn:setVisible(false);
	elseif self.m_mode == ChioceDialog.MODE_AGREE then

--		self.m_close_btn:setVisible(false);
		local sure_text = sure_str or "同意";
		self.m_sure_texture:setText(sure_text);

		local cancel_text = cancel_str or "拒绝";
		self.m_cancel_texture:setText(cancel_text);

		self.m_cancel_btn:setVisible(true);
		self.m_sure_btn:setVisible(true);

		self.m_ok_btn:setVisible(false);
	elseif self.m_mode == ChioceDialog.MODE_OTHER then
--		self.m_close_btn:setVisible(true);
		self.m_cancel_btn:setVisible(false);
		self.m_sure_btn:setVisible(false);

		local sure_text = sure_str or "确定";
		self.m_ok_texture:setText(sure_text);
		self.m_ok_btn:setVisible(true);
	elseif self.m_mode == ChioceDialog.MODE_COMMON then
--		self.m_close_btn:setVisible(true);
--	    self.m_close_btn:setOnClick(self,self.dismiss);
		local sure_text = sure_str or "确定";
		self.m_sure_texture:setText(sure_text);

		local cancel_text = cancel_str or "取消";
		self.m_cancel_texture:setText(cancel_text);

		self.m_cancel_btn:setVisible(true);
		self.m_sure_btn:setVisible(true);

		self.m_ok_btn:setVisible(false);
    elseif self.m_mode == ChioceDialog.MODE_SHOUCANG then
        self.m_check_btn:setVisible(false);
		self.m_close_btn:setVisible(false);
		local sure_text = sure_str or "收藏";
		self.m_sure_texture:setText(sure_text);
		local cancel_text = cancel_str or "取消";
		self.m_cancel_texture:setText(cancel_text);
		self.m_cancel_btn:setVisible(true);
		self.m_sure_btn:setVisible(true);     
        self.m_ok_btn:setVisible(false);   
    elseif self.m_mode == ChioceDialog.MODE_REPLAY_ROOM then
        self.m_check_btn:setVisible(false);
		self.m_close_btn:setVisible(false);
		local sure_text = sure_str or "确定";
		self.m_ok_texture:setText(sure_text);
		self.m_ok_btn:setVisible(true); 
    elseif self.m_mode == ChioceDialog.MODE_FREEZEUSER then 
        self.m_check_btn:setVisible(false);
        self.m_close_btn:setVisible(false);

        local sure_text = sure_str or "联系客服";
		self.m_sure_texture:setText(sure_text);

		local cancel_text = cancel_str or "退出游戏";
		self.m_cancel_texture:setText(cancel_text);

		self.m_cancel_btn:setVisible(true);
		self.m_sure_btn:setVisible(true);

		self.m_ok_btn:setVisible(false);
        self.m_sure_btn:setOnClick(self,self.freezeUserSure);
    else
		self.m_cancel_btn:setVisible(false);
		self.m_sure_btn:setVisible(false);
--		self.m_close_btn:setVisible(false);

		local sure_text = sure_str or "确定";
		self.m_ok_texture:setText(sure_text);
		self.m_ok_btn:setVisible(true);
	end
end

ChioceDialog.setPositiveListener = function(self,obj,func,arg) -- 增加arg参数，当点击确定的时候返回
	self.m_posObj = obj;
	self.m_posFunc = func;
    self.m_posArg = arg;
end


ChioceDialog.setNegativeListener = function(self,obj,func)
	self.m_negObj = obj;
	self.m_negFunc = func;
end


ChioceDialog.check = function(self)
    self.m_check:setVisible(not self.m_check:getVisible());
--    if self.m_check:getVisible() then
--        self.m_check_txt:setText("仅自己可见");
--    else
--        self.m_check_txt:setText("仅自己可见");
--    end;
end;


ChioceDialog.getCheckState = function(self)
    return self.m_check:getVisible()
end;



ChioceDialog.dismiss = function(self)
	self.super.dismiss(self,self.mDialogAnim.dismissAnim);
end

ChioceDialog.setCancelText = function(self,str)
    self.m_cancel_texture:setText(str);
end;

ChioceDialog.freezeUserSure = function(self)
	print_string("ChioceDialog.sure ");
--	self:dismiss();
    self.m_check_btn:setVisible(false);
	if self.m_posObj and self.m_posFunc then
		self.m_posFunc(self.m_posObj,self.m_posArg);
	end
end