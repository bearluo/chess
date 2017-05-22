
require(VIEW_PATH .. "chioce_dialog_with_icon_view");
require(BASE_PATH.."chessDialogScene")
ChioceDialogWithIcon = class(ChessDialogScene,false);

ChioceDialogWithIcon.MODE_SURE = 1;
ChioceDialogWithIcon.MODE_AGREE = 2;
ChioceDialogWithIcon.MODE_OK = 3;
ChioceDialogWithIcon.MODE_OTHER = 4;
ChioceDialogWithIcon.MODE_COMMON = 5;
ChioceDialogWithIcon.MODE_SHOUCANG = 6; -- 收藏
ChioceDialogWithIcon.MODE_REPLAY_ROOM = 7; -- 回放房间结束

ChioceDialogWithIcon.ctor = function(self)
    super(self,chioce_dialog_with_icon_view);
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

    self.m_chioce_with_icon = self.m_content_view:getChildByName("chioce_with_icon");
	self.m_message = self.m_chioce_with_icon:getChildByName("chioce_message");
    self.m_icon_frame = self.m_chioce_with_icon:getChildByName("icon_frame");
    self.m_icon = new(Mask,"online/room/head_mask.png","online/room/head_mask.png");
    self.m_vip_frame = self.m_chioce_with_icon:getChildByName("vip");
    local maskW,maskH = self.m_icon_frame:getSize();
    self.m_icon:setSize(maskW-2,maskH-2);
    self.m_icon:setAlign(kAlignCenter);
    self.m_icon_frame:addChild(self.m_icon);
    self.m_grade_level = self.m_chioce_with_icon:getChildByName("level");
	self.m_dialog_bg:setEventTouch(self,self.onTouch);

	self.m_cancel_btn:setOnClick(self,self.cancel);
	self.m_sure_btn:setOnClick(self,self.sure);
--	self.m_close_btn:setOnClick(self,self.cancel);
	self.m_ok_btn:setOnClick(self,self.sure);
    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)
end

ChioceDialogWithIcon.dtor = function(self)
    delete(self.m_root_view);
	self.m_root_view = nil;
    self.mDialogAnim.stopAnim()
end

ChioceDialogWithIcon.isShowing = function(self)
	return self:getVisible();
end

ChioceDialogWithIcon.onTouch = function(self)
	print_string("ChioceDialogWithIcon.onTouch");
end

ChioceDialogWithIcon.show = function(self)
	print_string("ChioceDialogWithIcon.show ... ");
	kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
	self:setVisible(true);
    self.super.show(self,self.mDialogAnim.showAnim);
end

ChioceDialogWithIcon.cancel = function(self)
	print_string("ChioceDialogWithIcon.cancel ");
	self:dismiss();
    self.m_check_btn:setVisible(false);
	if self.m_negObj and self.m_negFunc then
		self.m_negFunc(self.m_negObj);
	end
end

ChioceDialogWithIcon.sure = function(self)
	print_string("ChioceDialogWithIcon.sure ");
	self:dismiss();
    self.m_check_btn:setVisible(false);
	if self.m_posObj and self.m_posFunc then
		self.m_posFunc(self.m_posObj,self.m_posArg);
	end
end


ChioceDialogWithIcon.setMessage = function(self,message)
 	self.m_message:setText(message);
end

ChioceDialogWithIcon.setIcon = function(self,user)
    local iconType = user:getIconType();
    local iconUrl = user:getIcon();
    if iconType and iconType > 0 then
        self.m_icon:setFile(UserInfo.DEFAULT_ICON[iconType] or UserInfo.DEFAULT_ICON[1]);
    elseif iconType and iconType == 0 then
        self.m_icon:setFile(UserInfo.DEFAULT_ICON[1]);
    else
        if iconType == -1 and iconUrl then --兼容1.7.5之前的版本的头像为""时显示默认头像。
            self.m_icon:setUrlImage(iconUrl,UserInfo.DEFAULT_ICON[1]);
        end
    end

    local my_set = user:getUserSet();
    if my_set then
        local frameRes = UserSetInfo.getInstance():getFrameRes(my_set.picture_frame);
        self.m_vip_frame:setVisible(frameRes.visible);
        local fw,fh = self.m_vip_frame:getSize();
        if frameRes.frame_res then
            self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
        end
    end
end

ChioceDialogWithIcon.setLevel = function(self,user)
    self.m_grade_level:setFile("common/icon/level_" .. 10 - UserInfo.getInstance():getDanGradingLevelByScore(user:getScore()) .. ".png")
end

ChioceDialogWithIcon.setMode = function(self,mode,sure_str,cancel_str)
	self.m_mode = mode;	
--	self.m_close_btn:setOnClick(self,self.cancel);
	if self.m_mode == ChioceDialogWithIcon.MODE_SURE then
--		self.m_close_btn:setVisible(false);
		local sure_text = sure_str or "确定";
		self.m_sure_texture:setText(sure_text);

		local cancel_text = cancel_str or "取消";
		self.m_cancel_texture:setText(cancel_text);

		self.m_cancel_btn:setVisible(true);
		self.m_sure_btn:setVisible(true);

		self.m_ok_btn:setVisible(false);
	elseif self.m_mode == ChioceDialogWithIcon.MODE_AGREE then

--		self.m_close_btn:setVisible(false);
		local sure_text = sure_str or "同意";
		self.m_sure_texture:setText(sure_text);

		local cancel_text = cancel_str or "拒绝";
		self.m_cancel_texture:setText(cancel_text);

		self.m_cancel_btn:setVisible(true);
		self.m_sure_btn:setVisible(true);

		self.m_ok_btn:setVisible(false);
	elseif self.m_mode == ChioceDialogWithIcon.MODE_OTHER then
--		self.m_close_btn:setVisible(true);
		self.m_cancel_btn:setVisible(false);
		self.m_sure_btn:setVisible(false);

		local sure_text = sure_str or "确定";
		self.m_ok_texture:setText(sure_text);
		self.m_ok_btn:setVisible(true);
	elseif self.m_mode == ChioceDialogWithIcon.MODE_COMMON then
--		self.m_close_btn:setVisible(true);
--	    self.m_close_btn:setOnClick(self,self.dismiss);
		local sure_text = sure_str or "确定";
		self.m_sure_texture:setText(sure_text);

		local cancel_text = cancel_str or "取消";
		self.m_cancel_texture:setText(cancel_text);

		self.m_cancel_btn:setVisible(true);
		self.m_sure_btn:setVisible(true);

		self.m_ok_btn:setVisible(false);
    elseif self.m_mode == ChioceDialogWithIcon.MODE_SHOUCANG then
        self.m_check_btn:setVisible(false);
		self.m_close_btn:setVisible(false);
		local sure_text = sure_str or "收藏";
		self.m_sure_texture:setText(sure_text);
		local cancel_text = cancel_str or "取消";
		self.m_cancel_texture:setText(cancel_text);
		self.m_cancel_btn:setVisible(true);
		self.m_sure_btn:setVisible(true);     
        self.m_ok_btn:setVisible(false);   
    elseif self.m_mode == ChioceDialogWithIcon.MODE_REPLAY_ROOM then
        self.m_check_btn:setVisible(false);
		self.m_close_btn:setVisible(false);
		local sure_text = sure_str or "确定";
		self.m_ok_texture:setText(sure_text);
		self.m_ok_btn:setVisible(true); 
    else
		self.m_cancel_btn:setVisible(false);
		self.m_sure_btn:setVisible(false);
--		self.m_close_btn:setVisible(false);

		local sure_text = sure_str or "确定";
		self.m_ok_texture:setText(sure_text);
		self.m_ok_btn:setVisible(true);
	end
end

ChioceDialogWithIcon.setPositiveListener = function(self,obj,func,arg) -- 增加arg参数，当点击确定的时候返回
	self.m_posObj = obj;
	self.m_posFunc = func;
    self.m_posArg = arg;
end


ChioceDialogWithIcon.setNegativeListener = function(self,obj,func)
	self.m_negObj = obj;
	self.m_negFunc = func;
end


ChioceDialogWithIcon.check = function(self)
    self.m_check:setVisible(not self.m_check:getVisible());
--    if self.m_check:getVisible() then
--        self.m_check_txt:setText("仅自己可见");
--    else
--        self.m_check_txt:setText("仅自己可见");
--    end;
end;


ChioceDialogWithIcon.getCheckState = function(self)
    return self.m_check:getVisible()
end;



ChioceDialogWithIcon.dismiss = function(self)
	self.super.dismiss(self,self.mDialogAnim.dismissAnim);
end

ChioceDialogWithIcon.setCancelText = function(self,str)
    self.m_cancel_texture:setText(str);
end;