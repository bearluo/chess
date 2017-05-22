require("view/view_config");
require(VIEW_PATH .. "progress_loading_dialog_view");
require(BASE_PATH.."chessDialogScene")
ProgressDialog = class(ChessDialogScene,false);
--require("view/Android_800_480/progress_loading_dialog_view");



ProgressDialog.MS = 1000;

ProgressDialog.ctor = function(self)
    super(self,progress_loading_dialog_view)
	self.m_root_view = self.m_root;

	self.m_root_view:setLevel(DIALOG_VISIBLE_LEVEL);

--	self.m_progress_loading_dialog_bg = self.m_root_view:getChildByName("progress_loading_dialog_bg");

    self.m_progress_content_view = self.m_root_view:getChildByName("progress_content_view");
    
	self.m_cancel_btn = self.m_progress_content_view:getChildByName("progress_cancel_btn");

	self.m_message = self.m_progress_content_view:getChildByName("progress_message_text");

	self.m_loading = self.m_progress_content_view:getChildByName("progress_loading_img");

	self:setEventTouch(self,self.onTouch);

	self.m_cancel_btn:setOnClick(self,self.cancel);



	self:setVisible(false);
end

ProgressDialog.dtor = function(self)
	self.m_root_view = nil;

end

ProgressDialog.isShowing = function(self)
	return self:getVisible();
end

ProgressDialog.onTouch = function(self)
	print_string("ProgressDialog.onTouch");
end

ProgressDialog.show = function(tips,enableAbort,obj,func)


	if not ProgressDialog.s_instance then
		ProgressDialog.s_instance = new(ProgressDialog);
	end

	ProgressDialog.s_instance.m_enableAbort = enableAbort;

	
	ProgressDialog.s_instance.m_cancel_btn:setVisible(ProgressDialog.s_instance.m_enableAbort);

	ProgressDialog.s_instance:setMessage(tips);

	ProgressDialog.s_instance:setNegativeListener(obj,func);


	ProgressDialog.s_instance:release();
	
	ProgressDialog.s_instance.m_animRotate = new(AnimDouble , kAnimRepeat, 360 ,  0, ProgressDialog.MS , -1);
	ProgressDialog.s_instance.m_animRotate:setDebugName("ProgressDialog.s_instance.m_animRotate");
	
    ProgressDialog.s_instance.m_propRotate = new(PropRotate , ProgressDialog.s_instance.m_animRotate, kCenterDrawing);
    ProgressDialog.s_instance.m_loading:addProp(ProgressDialog.s_instance.m_propRotate , 0);


--    kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
	ProgressDialog.s_instance:setVisible(true);
    ProgressDialog.s_instance.super.show(ProgressDialog.s_instance);
	ProgressDialog.s_instance.m_showing = true;
end

ProgressDialog.setCancelListener = function(cObj,cFunc,requestID)
	ProgressDialog.s_instance.cObj = cObj;
	ProgressDialog.s_instance.cFunc = cFunc;
	ProgressDialog.s_instance.cRequestID = requestID;
end

ProgressDialog.cancel = function(self)
	print_string("ProgressDialog.cancel ");

	if not self.m_enableAbort then
		print_string("ProgressDialog.cancel not self.m_enableAbort");
		return;
	end
	if self.m_negObj and self.m_negFunc then
		self.m_negFunc(self.m_negObj);
	end
	if ProgressDialog.s_instance.cObj and ProgressDialog.s_instance.cFunc then
		ProgressDialog.s_instance.cFunc(ProgressDialog.s_instance.cObj,ProgressDialog.s_instance.cRequestID);
		ProgressDialog.setCancelListener(nil,nil,nil);
	end
	self:dismiss();
end



ProgressDialog.setMessage = function(self,message)

 	self.m_message:setText(GameString.convert2UTF8(message));
 	print_string("ProgressDialog.setMessag message = " .. self.m_message:getText());
end


ProgressDialog.setNegativeListener = function(self,obj,func)
	self.m_negObj = obj;
	self.m_negFunc = func;
end


ProgressDialog.dismiss = function(self)

	if self.m_showing then
		self:release();
	    self.m_showing = false;
	end

--	self:setVisible(false);
    self.super.dismiss(self);
end

ProgressDialog.stop = function()

	print_string("ProgressDialog.stop");

	if ProgressDialog.s_instance then
		ProgressDialog.s_instance:dismiss();
	end

end

ProgressDialog.release = function(self)
	if self.m_propRotate then
			    --删除prop和anim
	    ProgressDialog.s_instance.m_loading:removeProp(0);
	    delete(self.m_propRotate);
	   	self.m_propRotate = nil;
	end

	if self.m_animRotate then
	    delete(self.m_animRotate);
	    self.m_animRotate = nil;
	end


end