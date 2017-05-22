
--require("view/Android_800_480/chioce_dialog_view");
require(VIEW_PATH .. "big_head_dialog");
require(BASE_PATH.."chessDialogScene");
require("dialog/http_loading_dialog");
BigHeadDialog = class(ChessDialogScene,false);

BigHeadDialog.ctor = function(self)
    super(self,big_head_dialog);
	self.m_root_view = self.m_root;
    self.m_dialog_bg = self.m_root_view:getChildByName("bg");
    self.m_dialog_bg:setEventTouch(self.m_dialog_bg,function() end);
	self.m_icon_bg = self.m_dialog_bg:getChildByName("icon_bg");
    self.m_icon_mask = self.m_icon_bg:getChildByName("icon_mask");

    self.m_head_img = new(Mask,"common/background/head_mask_bg_260.png","common/background/head_mask_bg_260.png");
    self.m_head_img:setSize(self.m_icon_mask:getSize());
    self.m_icon_mask:addChild(self.m_head_img);
	self.sure_btn = self.m_dialog_bg:getChildByName("save_btn");
--    self:setEventTouch(self,self.onTouch);
	self.sure_btn:setOnClick(self,self.sure);

    self.p_load_img = self.m_dialog_bg:getChildByName("loading");
    self.p_load_img:setVisible(false);
	self.sure_btn:setVisible(false);
    self.p_imageFile = nil;

    self:setShieldClick(self,self.dismiss);
    self:setVisible(false);
    self.m_close_btn = self.m_dialog_bg:getChildByName("close_btn");
    self.m_close_btn:setOnClick(self,self.dismiss);
end

BigHeadDialog.dtor = function(self)
    delete(self.m_root_view);
	self.m_root_view = nil;
end

BigHeadDialog.isShowing = function(self)
	return self:getVisible();
end

--BigHeadDialog.onTouch = function(self,finger_action,x,y,drawing_id_first,drawing_id_last)
--	print_string("BigHeadDialog.onTouch");
--    if finger_action == kFingerUp and drawing_id_first == drawing_id_last then
--        local drawing_id = drawing_pick ( 0,x,y);
--        print_string("BigHeadDialog.onTouch drawing_id " .. drawing_id .. " self.p_dialog_bg.m_drawingID" .. self.p_dialog_bg.m_drawingID);
--        print_string("BigHeadDialog.onTouch x " .. x .. " y" .. y);
--        local icon_x,icon_y = self.m_head_img:getPos();
--        print_string("BigHeadDialog.onTouch icon_x " ..icon_x .. " icon_y" .. icon_y);
--        if drawing_id == self.m_dialog_bg.m_drawingID then
--            self:dismiss();
--        end
--    end
--end

BigHeadDialog.show = function(self,imgFile,imgType,isLoading)   --isLoading是否正在下载
	print_string("BigHeadDialog.show ... ");
	kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
    self.p_imgType = imgType;
--    if imgFile then
--        self.m_head_img:setFile(imgFile);
--        self.p_imageFile = imgFile;
--    elseif imgType and imgType ~= -1 then
--        self.m_head_img:setFile(UserInfo.DEFAULT_ICON[imgType] or UserInfo.DEFAULT_ICON[1]);
--    end
    if not self.p_load_img:checkAddProp(1) then 
		self.p_load_img:removeProp(1);
	end
    self.sure_btn:setVisible(false);
    self.p_load_img:setVisible(true);
    self.p_load_img:addPropRotate(1,kAnimRepeat,HttpLoadingDialog.s_duration,-1,0,-360,1);

    if imgType then
        if imgType == -1 then
            self.m_head_img:setUrlImageDownloadBack(self,self.callback);
            self.m_head_img:setUrlImage(imgFile);
        else
            self.m_head_img:setFile(UserInfo.DEFAULT_ICON[imgType] or UserInfo.DEFAULT_ICON[1]);
            self:callback();
        end
    else

    end

    if not self.m_dialog_bg:checkAddProp(1) then 
		self.m_dialog_bg:removeProp(1);
	end
    
    self.super.show(self,false);
	
    local w,h = self.m_dialog_bg:getSize();
    local anim = self.m_dialog_bg:addPropTranslate(1,kAnimNormal,200,-1,0,0,h,0);
    if anim then
        anim:setEvent(self, function(self)
            delete(anim);
            self:setVisible(true);
            self.m_dialog_bg:removeProp(1);
        end);
    end
--    self.m_animGameTranslate = self.m_dialog_bg:addPropTranslate(1,kAnimNormal,200,-1,0,0,h,0);
--    self.m_animGameTranslate:setEvent(self,self.onGameTranslateFinish);
end

--BigHeadDialog.onGameTranslateFinish = function(self)
--    if not self.m_dialog_bg:checkAddProp(1) then 
--		self.m_dialog_bg:removeProp(1);
--	end
--end

BigHeadDialog.update = function(self,imgFile)
    print_string("BigHeadDialog.update ... ");
    if imgFile then
        self.p_imageFile = imgFile;
        self.m_head_img:setFile(imgFile);
        self.sure_btn:setVisible(true);
        self.p_load_img:setVisible(false);
        self.p_load_img:removeProp(1);
    end
end

BigHeadDialog.callback = function(self)
    Log.i("BigHeadDialog.callback");
    self.p_imageFile = self.m_head_img:getFile();
    self.sure_btn:setVisible(true);
    self.p_load_img:setVisible(false);
    self.p_load_img:removeProp(1);
end

--BigHeadDialog.cancel = function(self)
--	print_string("BigHeadDialog.cancel ");
--	self:dismiss();
--	if self.p_negObj and self.p_negFunc then
--		self.p_negFunc(self.p_negObj);
--	end
--end

BigHeadDialog.sure = function(self)
	print_string("BigHeadDialog.sure ");
--	self:dismiss();
    local data = {};
    data.imageFile = self.p_imageFile;
    data.imageType = self.p_imgType;
    dict_set_string(kSaveImage,kSaveImage..kparmPostfix,json.encode(data));
    call_native(kSaveImage);
	if self.p_posObj and self.p_posFunc then
		self.p_posFunc(self.p_posObj);
	end
    self:dismiss();
end


BigHeadDialog.setPositiveListener = function(self,obj,func)
	self.p_posObj = obj;
	self.p_posFunc = func;
end


BigHeadDialog.setNegativeListener = function(self,obj,func)
	self.p_negObj = obj;
	self.p_negFunc = func;
end


BigHeadDialog.dismiss = function(self)
    if not self.p_load_img:checkAddProp(1) then
        self.p_load_img:removeProp(1);
    end
	self.super.dismiss(self,false);

    self.m_dialog_bg:removeProp(1);
    local w,h = self.m_dialog_bg:getSize();
    local anim = self.m_dialog_bg:addPropTranslate(1,kAnimNormal,200,-1,0,0,0,h);
    if anim then
        anim:setEvent(self,function(self)
            delete(anim);
            self.m_dialog_bg:removeProp(1);
            self:setVisible(false);
        end);
    end
--    self.m_animGameTranslate = 
--    self.m_animGameTranslate:setEvent(self,function()
--        self:setVisible(false);
--    end);
end