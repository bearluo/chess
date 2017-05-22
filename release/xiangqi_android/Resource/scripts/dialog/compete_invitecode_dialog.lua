require(VIEW_PATH .. "compete_invitecode_dialog")

CompeteInviteCodeDialog = class(ChessDialogScene, false)

CompeteInviteCodeDialog.ctor = function( self, datas)
	super(self, compete_invitecode_dialog)
	self.anim_dlg = AnimDialogFactory.createNormalAnim(self)
	self.datas = datas
	self:initView()
    self:init();
    EventDispatcher.getInstance():register(HttpModule.s_event, self, self.onHttpRequestsCallBack)
end

CompeteInviteCodeDialog.dtor = function( self )
	self.anim_dlg:stopAnim()
	EventDispatcher.getInstance():unregister(HttpModule.s_event, self, self.onHttpRequestsCallBack)
end

CompeteInviteCodeDialog.initView = function(self)
    self.m_root_view = self.m_root;
    self.m_dialog_bg_img = self.m_root_view:getChildByName("bg_img");
    self.m_dialog_bg = self.m_root_view:getChildByName("bg");
    -- title
    self.m_title_view = self.m_dialog_bg:getChildByName("title");
    self.m_close_btn = self.m_title_view:getChildByName("close");
    self.m_close_btn:setOnClick(self, self.dismiss);

    -- code
    self.m_code_view = self.m_dialog_bg:getChildByName("code");
    self.m_code_hide = self.m_code_view:getChildByName("code_bg"):getChildByName("hide");
    self.m_code_tips = self.m_code_view:getChildByName("tips");
    self.m_code1 = self.m_code_view:getChildByName("num1");
    self.m_code2 = self.m_code_view:getChildByName("num2");
    self.m_code3 = self.m_code_view:getChildByName("num3");
    self.m_code4 = self.m_code_view:getChildByName("num4");
    self.m_code5 = self.m_code_view:getChildByName("num5");
    self.m_code6 = self.m_code_view:getChildByName("num6");

    -- pad
    self.m_pad_view = self.m_dialog_bg:getChildByName("pad");
    self.m_pad_tips = self.m_pad_view:getChildByName("tips");
    self.m_num0 = self.m_pad_view:getChildByName("num0");
    self.m_num0:setOnClick(self,self.onNum0Click);
    self.m_num1 = self.m_pad_view:getChildByName("num1");
    self.m_num1:setOnClick(self,self.onNum1Click);
    self.m_num2 = self.m_pad_view:getChildByName("num2");
    self.m_num2:setOnClick(self,self.onNum2Click);
    self.m_num3 = self.m_pad_view:getChildByName("num3");
    self.m_num3:setOnClick(self,self.onNum3Click);
    self.m_num4 = self.m_pad_view:getChildByName("num4");
    self.m_num4:setOnClick(self,self.onNum4Click);
    self.m_num5 = self.m_pad_view:getChildByName("num5");
    self.m_num5:setOnClick(self,self.onNum5Click);
    self.m_num6 = self.m_pad_view:getChildByName("num6");
    self.m_num6:setOnClick(self,self.onNum6Click);
    self.m_num7 = self.m_pad_view:getChildByName("num7");
    self.m_num7:setOnClick(self,self.onNum7Click);
    self.m_num8 = self.m_pad_view:getChildByName("num8");
    self.m_num8:setOnClick(self,self.onNum8Click);
    self.m_num9 = self.m_pad_view:getChildByName("num9");
    self.m_num9:setOnClick(self,self.onNum9Click);
    self.m_pad_clear_btn = self.m_pad_view:getChildByName("clear");
    self.m_pad_clear_btn:setOnClick(self,self.onClearBtnClick);
    self.m_pad_del_btn = self.m_pad_view:getChildByName("del");
    self.m_pad_del_btn:setOnClick(self,self.onDelBtnClick);

    -- confirm
    self.m_confirm_view = self.m_dialog_bg:getChildByName("confirm");
    self.m_sure_btn = self.m_confirm_view:getChildByName("sure");
    self.m_sure_btn:setOnClick(self, self.onSureBtnClick);
end;

CompeteInviteCodeDialog.onSureBtnClick = function(self)
    if self.datas then
        if self.datas.type and tonumber(self.datas.type) == 12 then
            local join_money = tonumber(self.datas.join_money) or 0
            if UserInfo.getInstance():getMoney() < join_money then
                ChessToastManager.getInstance():showSingle("金币不足")
                return
            end
            local info = {}
            info.level = self.datas.level
            RoomProxy.getInstance():gotoMoneyMatchRoom(info)
        else
	        local data = {}
	        data.param = 
	        {
		        config_id = self.datas.id,
		        match_id = self.datas.match_id,
                password = self.m_password or "";
	        }
	        HttpModule.getInstance():execute(HttpModule.s_cmds.joinMatch, data)            
        end;
    end;
    self:dismiss();
end;

CompeteInviteCodeDialog.showCodeVisible = function(self, flag)
    if flag then
        self.m_code_hide:setVisible(false);
        self.m_code1:setVisible(true);
        self.m_code2:setVisible(true);
        self.m_code3:setVisible(true);
        self.m_code4:setVisible(true);
        self.m_code5:setVisible(true);
        self.m_code6:setVisible(true);
    else
        self.m_code_hide:setVisible(true);
        self.m_code1:setVisible(false);
        self.m_code2:setVisible(false);
        self.m_code3:setVisible(false);
        self.m_code4:setVisible(false);
        self.m_code5:setVisible(false);
        self.m_code6:setVisible(false);
    end;
end;

CompeteInviteCodeDialog.verifyCode = function(self)
    if self.datas then
        local data = {};
        data.param = {};
        data.param.match_id = self.datas.match_id or "";
        self.m_password = string.format("%d%d%d%d%d%d",self.m_code_table[1] or 10,self.m_code_table[2] or 10,
                                                           self.m_code_table[3] or 10,self.m_code_table[4] or 10,
                                                           self.m_code_table[5] or 10,self.m_code_table[6] or 10) or "";
        data.param.password = self.m_password;
        HttpModule.getInstance():execute(HttpModule.s_cmds.checkPassword, data)
    end;
end;

CompeteInviteCodeDialog.onHttpCheckPassword = function(self, isSuccess, message)
    if not isSuccess then
        self.m_pad_tips:setVisible(true);
        return;
    end;
    self.m_pad_view:setVisible(false);
    self.m_confirm_view:setVisible(true);
    self.m_dialog_bg_img:setSize(nil,480);
end;

CompeteInviteCodeDialog.onNum0Click = function(self)
    self:showCodeVisible(true);
    if #self.m_code_table == 0 then
        self.m_code_table[1] = 0;
        self.m_code1:setText("0")
    elseif #self.m_code_table == 1 then
        self.m_code_table[2] = 0;
        self.m_code2:setText("0");
    elseif #self.m_code_table == 2 then
        self.m_code_table[3] = 0;
        self.m_code3:setText("0");
    elseif #self.m_code_table == 3 then
        self.m_code_table[4] = 0;
        self.m_code4:setText("0");
    elseif #self.m_code_table == 4 then
        self.m_code_table[5] = 0;
        self.m_code5:setText("0");
    elseif #self.m_code_table == 5 then
        self.m_code_table[6] = 0;
        self.m_code6:setText("0");    
        self:verifyCode();
    end;
end;

CompeteInviteCodeDialog.onNum1Click = function(self)
    self:showCodeVisible(true);
    if #self.m_code_table == 0 then
        self.m_code_table[1] = 1;
        self.m_code1:setText("1")
    elseif #self.m_code_table == 1 then
        self.m_code_table[2] = 1;
        self.m_code2:setText("1");
    elseif #self.m_code_table == 2 then
        self.m_code_table[3] = 1;
        self.m_code3:setText("1");
    elseif #self.m_code_table == 3 then
        self.m_code_table[4] = 1;
        self.m_code4:setText("1");
    elseif #self.m_code_table == 4 then
        self.m_code_table[5] = 1;
        self.m_code5:setText("1");
    elseif #self.m_code_table == 5 then
        self.m_code_table[6] = 1;
        self.m_code6:setText("1");  
        self:verifyCode();  
    end;
end;

CompeteInviteCodeDialog.onNum2Click = function(self)
    self:showCodeVisible(true);
    if #self.m_code_table == 0 then
        self.m_code_table[1] = 2;
        self.m_code1:setText("2")
    elseif #self.m_code_table == 1 then
        self.m_code_table[2] = 2;
        self.m_code2:setText("2");
    elseif #self.m_code_table == 2 then
        self.m_code_table[3] = 2;
        self.m_code3:setText("2");
    elseif #self.m_code_table == 3 then
        self.m_code_table[4] = 2;
        self.m_code4:setText("2");
    elseif #self.m_code_table == 4 then
        self.m_code_table[5] = 2;
        self.m_code5:setText("2");
    elseif #self.m_code_table == 5 then
        self.m_code_table[6] = 2;
        self.m_code6:setText("2");    
        self:verifyCode();
    end;
end;

CompeteInviteCodeDialog.onNum3Click = function(self)
    self:showCodeVisible(true);
    if #self.m_code_table == 0 then
        self.m_code_table[1] = 3;
        self.m_code1:setText("3")
    elseif #self.m_code_table == 1 then
        self.m_code_table[2] = 3;
        self.m_code2:setText("3");
    elseif #self.m_code_table == 2 then
        self.m_code_table[3] = 3;
        self.m_code3:setText("3");
    elseif #self.m_code_table == 3 then
        self.m_code_table[4] = 3;
        self.m_code4:setText("3");
    elseif #self.m_code_table == 4 then
        self.m_code_table[5] = 3;
        self.m_code5:setText("3");
    elseif #self.m_code_table == 5 then
        self.m_code_table[6] = 3;
        self.m_code6:setText("3");  
        self:verifyCode();  
    end;
end;

CompeteInviteCodeDialog.onNum4Click = function(self)
    self:showCodeVisible(true);
    if #self.m_code_table == 0 then
        self.m_code_table[1] = 4;
        self.m_code1:setText("4")
    elseif #self.m_code_table == 1 then
        self.m_code_table[2] = 4;
        self.m_code2:setText("4");
    elseif #self.m_code_table == 2 then
        self.m_code_table[3] = 4;
        self.m_code3:setText("4");
    elseif #self.m_code_table == 3 then
        self.m_code_table[4] = 4;
        self.m_code4:setText("4");
    elseif #self.m_code_table == 4 then
        self.m_code_table[5] = 4;
        self.m_code5:setText("4");
    elseif #self.m_code_table == 5 then
        self.m_code_table[6] = 4;
        self.m_code6:setText("4");    
        self:verifyCode();  
    end;
end;

CompeteInviteCodeDialog.onNum5Click = function(self)
    self:showCodeVisible(true);
    if #self.m_code_table == 0 then
        self.m_code_table[1] = 5;
        self.m_code1:setText("5")
    elseif #self.m_code_table == 1 then
        self.m_code_table[2] = 5;
        self.m_code2:setText("5");
    elseif #self.m_code_table == 2 then
        self.m_code_table[3] = 5;
        self.m_code3:setText("5");
    elseif #self.m_code_table == 3 then
        self.m_code_table[4] = 5;
        self.m_code4:setText("5");
    elseif #self.m_code_table == 4 then
        self.m_code_table[5] = 5;
        self.m_code5:setText("5");
    elseif #self.m_code_table == 5 then
        self.m_code_table[6] = 5;
        self.m_code6:setText("5"); 
        self:verifyCode();   
    end;
end;

CompeteInviteCodeDialog.onNum6Click = function(self)
    self:showCodeVisible(true);
    if #self.m_code_table == 0 then
        self.m_code_table[1] = 6;
        self.m_code1:setText("6")
    elseif #self.m_code_table == 1 then
        self.m_code_table[2] = 6;
        self.m_code2:setText("6");
    elseif #self.m_code_table == 2 then
        self.m_code_table[3] = 6;
        self.m_code3:setText("6");
    elseif #self.m_code_table == 3 then
        self.m_code_table[4] = 6;
        self.m_code4:setText("6");
    elseif #self.m_code_table == 4 then
        self.m_code_table[5] = 6;
        self.m_code5:setText("6");
    elseif #self.m_code_table == 5 then
        self.m_code_table[6] = 6;
        self.m_code6:setText("6");   
        self:verifyCode(); 
    end;
end;

CompeteInviteCodeDialog.onNum7Click = function(self)
    self:showCodeVisible(true);
    if #self.m_code_table == 0 then
        self.m_code_table[1] = 7;
        self.m_code1:setText("7")
    elseif #self.m_code_table == 1 then
        self.m_code_table[2] = 7;
        self.m_code2:setText("7");
    elseif #self.m_code_table == 2 then
        self.m_code_table[3] = 7;
        self.m_code3:setText("7");
    elseif #self.m_code_table == 3 then
        self.m_code_table[4] = 7;
        self.m_code4:setText("7");
    elseif #self.m_code_table == 4 then
        self.m_code_table[5] = 7;
        self.m_code5:setText("7");
    elseif #self.m_code_table == 5 then
        self.m_code_table[6] = 7;
        self.m_code6:setText("7");  
        self:verifyCode();  
    end;
end;

CompeteInviteCodeDialog.onNum8Click = function(self)
    self:showCodeVisible(true);
    if #self.m_code_table == 0 then
        self.m_code_table[1] = 8;
        self.m_code1:setText("8")
    elseif #self.m_code_table == 1 then
        self.m_code_table[2] = 8;
        self.m_code2:setText("8");
    elseif #self.m_code_table == 2 then
        self.m_code_table[3] = 8;
        self.m_code3:setText("8");
    elseif #self.m_code_table == 3 then
        self.m_code_table[4] = 8;
        self.m_code4:setText("8");
    elseif #self.m_code_table == 4 then
        self.m_code_table[5] = 8;
        self.m_code5:setText("8");
    elseif #self.m_code_table == 5 then
        self.m_code_table[6] = 8;
        self.m_code6:setText("8");   
        self:verifyCode();   
    end;
end;

CompeteInviteCodeDialog.onNum9Click = function(self)
    self:showCodeVisible(true);
    if #self.m_code_table == 0 then
        self.m_code_table[1] = 9;
        self.m_code1:setText("9")
    elseif #self.m_code_table == 1 then
        self.m_code_table[2] = 9;
        self.m_code2:setText("9");
    elseif #self.m_code_table == 2 then
        self.m_code_table[3] = 9;
        self.m_code3:setText("9");
    elseif #self.m_code_table == 3 then
        self.m_code_table[4] = 9;
        self.m_code4:setText("9");
    elseif #self.m_code_table == 4 then
        self.m_code_table[5] = 9;
        self.m_code5:setText("9");
    elseif #self.m_code_table == 5 then
        self.m_code_table[6] = 9;
        self.m_code6:setText("9"); 
        self:verifyCode();   
    end;
end;

CompeteInviteCodeDialog.onClearBtnClick = function(self)
    self.m_code_table = {};
    self.m_code1:setText("");
    self.m_code2:setText("");
    self.m_code3:setText("");
    self.m_code4:setText("");
    self.m_code5:setText("");
    self.m_code6:setText("");
    self.m_pad_tips:setVisible(false);
end;

CompeteInviteCodeDialog.onDelBtnClick = function(self)
    if #self.m_code_table == 0 then
    elseif #self.m_code_table == 1 then
        table.remove(self.m_code_table,1);
        self.m_code1:setText("");
    elseif #self.m_code_table == 2 then
        table.remove(self.m_code_table,2);
        self.m_code2:setText("");
    elseif #self.m_code_table == 3 then
        table.remove(self.m_code_table,3);
        self.m_code3:setText("");
    elseif #self.m_code_table == 4 then
        table.remove(self.m_code_table,4);
        self.m_code4:setText("");
    elseif #self.m_code_table == 5 then
        table.remove(self.m_code_table,5);
        self.m_code5:setText(""); 
    elseif #self.m_code_table == 6 then
        table.remove(self.m_code_table,6);
        self.m_code6:setText(""); 
    end;    
    self.m_pad_tips:setVisible(false);
end;


CompeteInviteCodeDialog.init = function(self)
    self.m_code_table = {};
    self.m_code_count = {};
end;

CompeteInviteCodeDialog.show = function( self )
	self.super.show(self, self.anim_dlg.showAnim)
end

CompeteInviteCodeDialog.dismiss = function( self )
	self.super.dismiss(self, self.anim_dlg.dismissAnim)
end


CompeteInviteCodeDialog.onHttpRequestsCallBack = function(self, command, ...)
	Log.i("CompeteInviteCodeDialog.onHttpRequestsCallBack")
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self, ...)
	end 
end

CompeteInviteCodeDialog.s_httpRequestsCallBackFuncMap = 
{
	[HttpModule.s_cmds.checkPassword] = CompeteInviteCodeDialog.onHttpCheckPassword,
}