
--require("view/Android_800_480/chioce_dialog_view");
require(VIEW_PATH .. "input_tel_no_dialog");
require(BASE_PATH.."chessDialogScene");

InputTelNoDialog = class(ChessDialogScene,false);

InputTelNoDialog.ctor = function(self,goods)
    super(self,input_tel_no_dialog);
	self.goods = goods;
	self.m_root_view = self.m_root;
--	self.m_dialog_bg = self.m_root_view:getChildByName("view_bg");

	self.m_dialog_view = self.m_root_view:getChildByName("bg");
	self.m_num_input_text_bg= self.m_dialog_view:getChildByName("num_input_text_bg");
 	self.m_num_input_edit = self.m_num_input_text_bg:getChildByName("num_input_edit");
    self.m_num_input_edit:setHintText("请输入有效的国内手机号码",165,145,125);
    local txt = UserInfo.getInstance():findBindAccountBySid(1) -- 绑定手机号
    if txt then  self.m_num_input_edit:setText(txt) end
	self.m_cancel_btn = self.m_dialog_view:getChildByName("cancel_btn");
	self.m_ok_btn = self.m_dialog_view:getChildByName("ok_btn");

	self.m_cancel_btn:setOnClick(self,self.cancel);

	self.m_ok_btn:setOnClick(self,self.ok_action);
--	self.m_dialog_bg:setEventTouch(self,self.onTouch);

    local func =  function(view,enable)
        local tip = view:getChildByName("text");
        if tip then
            if not enable then
                tip:setColor(255,255,255);
                tip:addPropScaleSolid(1,1.1,1.1,1);
            else
                tip:setColor(240,230,210);
                tip:removeProp(1);
            end
        end
    end

    self.m_cancel_btn:setOnTuchProcess(self.m_cancel_btn,func);
    self.m_ok_btn:setOnTuchProcess(self.m_ok_btn,func);

    self:setVisible(false);
    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)
end

InputTelNoDialog.dtor = function(self)
	self.mDialogAnim.stopAnim()
    self.m_root_view = nil;
end

InputTelNoDialog.isShowing = function(self)
	return self:getVisible();
end

--InputTelNoDialog.onTouch = function(self)
--	print_string("InputTelNoDialog.onTouch");
--end

InputTelNoDialog.show = function(self,goods)
	print_string("InputTelNoDialog.show ... ");
	if goods then
		self.goods = goods;
	end

	kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
	self:setVisible(true);
    self.super.show(self,self.mDialogAnim.showAnim);
end

InputTelNoDialog.cancel = function(self)
	print_string("InputTelNoDialog.cancel ");
	self:dismiss();
end

InputTelNoDialog.dismiss = function(self)

    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
    self:setVisible(false);
end

InputTelNoDialog.ok_action = function(self)
	local phoneNo = self.m_num_input_edit:getText();
   	if phoneNo and phoneNo ~= "" and self:islegal(phoneNo) and string.len(phoneNo) == 11 then
        local post_data = {};
	    post_data.pid = self.goods.id;
	    post_data.position = self.goods.position;
	    post_data.phone = phoneNo;
        HttpModule.getInstance():execute(HttpModule.s_cmds.exchangeProp,post_data,"兑换中，请稍后……");
	else
		local message = "请输入11位数字的电话号码！"
        ChessToastManager.getInstance():show(message);
	end
end

InputTelNoDialog.islegal = function(self,str)
	local date = "%D"
	if not string.find(str, date) then --非数字
		return true;
	else
		return false;
	end
end