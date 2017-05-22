require(BASE_PATH.."chessScene");

EndgateSubScene = class(ChessScene);

EndgateSubScene.s_controls = 
{
    endgate_sub_content_view = 1;
    endgate_sub_back_btn = 2;
    endgate_sub_user_money_bg = 3;
    endgate_sub_title_text = 4;
    endgate_sub_user_coin = 5;
    endgate_sub_user_money = 6;
    endgate_new_sub_bottom_view = 7;
    levelName = 8;
}

EndgateSubScene.s_cmds = 
{
    updateUserInfoView = 1;
}

EndgateSubScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = EndgateSubScene.s_controls;
	self.m_btn = {};
    self:create();
    self:setLocked(true);
    self:updateUserInfoView();
end 

EndgateSubScene.resume = function(self)
    ChessScene.resume(self);
    self:setLocked();
    self:updateUserInfoView();
end;


EndgateSubScene.pause = function(self)
	ChessScene.pause(self);
end 


EndgateSubScene.dtor = function(self)
    Log.i("111");
end 

----------------------------------- function ----------------------------

EndgateSubScene.create = function(self)
    self.m_title = self:findViewById(self.m_ctrls.endgate_sub_title_text);
    self.m_content_view = self:findViewById(self.m_ctrls.endgate_sub_content_view);
    local w,h = self:getSize();
    local cw,ch = self.m_content_view:getSize();
    self.m_content_view:setSize(nil,ch+h-800);
    self.gate = kEndgateData:getGate();
	self.m_title:setText(self.gate.title);

	local y_pos = 0;
	local x_pos = 0;
	local flag = 0;

	for index = 0,self.gate.subCount-1 do
		flag = index % 3;
		if flag == 0 then
			x_pos = 15;
			y_pos = index * 50;
		elseif flag == 1 then
			x_pos = 169;
		elseif flag == 2 then
			x_pos = 323;
		end

		self.m_btn[index+1] = new(EndGateSubItem,index+1,true);
		self.m_btn[index+1]:setOnClick(self,self.entryEndGateSubGame);
		self.m_btn[index+1]:setPos(x_pos, y_pos);
		self.m_btn[index+1]:setVisible(true);
		self.m_content_view:addChild(self.m_btn[index+1]);
	end
    
    self.m_endgate_sub_user_money = self:findViewById(self.m_ctrls.endgate_sub_user_money);
    self.m_endgate_sub_user_coin = self:findViewById(self.m_ctrls.endgate_sub_user_coin);
    self.m_levelName = self:findViewById(self.m_ctrls.levelName);
end

EndgateSubScene.updateUserInfoView = function(self)
    self.m_endgate_sub_user_money:setText(UserInfo.getInstance():getMoneyStr());
    self.m_endgate_sub_user_coin:setText(UserInfo.getInstance():getCoin());
    self.m_levelName:setText(UserInfo.getInstance():getDanGradingName());
end

EndgateSubScene.entryEndGateSubGame = function(self,level)
	print_string("EndGateSub.entryEndGateSubGame in")

	local uid = UserInfo.getInstance():getUid();
	local curNum = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_GATE_NUM..uid,1);

    kEndgateData:setIsNeedPayGate(false);

	kEndgateData:setGateSort(level-1);

    self:requestCtrlCmd(EndgateSubController.s_cmds.entryGame);
--	self:entryGame();
end

--设置小关卡状态
EndgateSubScene.setLocked = function(self,flag)
	local progress = self.gate.progress+1;
	for index = 1, progress do
		if self.m_btn[index] then
			self.m_btn[index]:setLocked(false);
		end
	end

    if self.m_btn[progress] then
		self.m_btn[progress]:setClearance(false);
	end
    --快速开始处理
    if not flag then
        print_string("EndGateSub.setLocked:"..progress.."+"..self.gate.subCount);
        if progress >= self.gate.subCount then
            progress = self.gate.subCount;
        end
        if self.m_btn[progress] then
            self.m_quickGameObj = self.m_btn[progress];
        end
	
        if self.m_btn[progress] and UserInfo.getInstance():getQuickPlay() then
            self.m_btn[progress]:onItemClick();
        end
        UserInfo.getInstance():setQuickPlay(false);
    end
end

----------------------------------- click -------------------------------

EndgateSubScene.onBackClick = function(self)
    self:requestCtrlCmd(EndgateController.s_cmds.onBack);
end

EndgateSubScene.quickPlay = function(self)
	print_string("quickPlay");
    if self.m_quickGameObj then
        self.m_quickGameObj:onItemClick();
    end
end

EndgateSubScene.onAddCoinBtnClick = function(self)
    self:requestCtrlCmd(EndgateSubController.s_cmds.gotoMall);
end

----------------------------------- config ------------------------------
EndgateSubScene.s_controlConfig = 
{
    [EndgateSubScene.s_controls.endgate_sub_content_view] = {"endgate_sub_content_view"};
    [EndgateSubScene.s_controls.endgate_sub_back_btn] = {"endgate_sub_title_view","endgate_sub_back_btn"};
    [EndgateSubScene.s_controls.endgate_sub_user_money_bg] = {"endgate_sub_title_view","endgate_sub_userinfo","endgate_sub_user_money_bg"};
    [EndgateSubScene.s_controls.endgate_sub_title_text] = {"endgate_sub_title_view","endgate_sub_title_text"};
    [EndgateSubScene.s_controls.endgate_sub_user_coin] = {"endgate_sub_title_view","endgate_sub_userinfo","endgate_sub_user_coin_bg","endgate_sub_user_coin"};
    [EndgateSubScene.s_controls.endgate_sub_user_money] = {"endgate_sub_title_view","endgate_sub_userinfo","endgate_sub_user_money_bg","endgate_sub_user_money"};
    [EndgateSubScene.s_controls.endgate_new_sub_bottom_view] = {"endgate_new_sub_bottom_view"};
    [EndgateSubScene.s_controls.levelName] = {"endgate_sub_title_view","endgate_sub_userinfo","levelBg","levelName"};
    
};

EndgateSubScene.s_controlFuncMap =
{
    [EndgateSubScene.s_controls.endgate_sub_back_btn] = EndgateSubScene.onBackClick;
    [EndgateSubScene.s_controls.endgate_sub_user_money_bg] = EndgateSubScene.onAddCoinBtnClick;
};


EndgateSubScene.s_cmdConfig =
{
    [EndgateSubScene.s_cmds.updateUserInfoView] = EndgateSubScene.updateUserInfoView;
}





-------------------------------- private node -------------------
EndGateSubItem = class(Node);

EndGateSubItem.s_maxClickOffset = 10;

EndGateSubItem.FPLAY_ICON_PRE = "sub_fPlayer_icon";

EndGateSubItem.ctor = function(self,index,locked)
	self:setIndex(index);

	local title_x,title_y = 21,35;
	local flag_x,flag_y = 93,75;
	local head_bg_x,head_bg_y = 85,-2;
	local head_x,head_y = 17,4;

	self.m_ending_unlock_btn = new(Button,"endgate/endgate_sub_item_unlock_bg.png");
	self.m_ending_unlock_btn:setOnClick(self,self.onItemClick);
    self.m_ending_unlock_btn:setSrollOnClick();

	self.m_subgate_title = new(Text, self.m_index_text, 100, 36, kAlignCenter,nil,36,75,39,21);
	self.m_subgate_title:setPos(title_x,title_y);
	self.m_ending_unlock_btn:addChild(self.m_subgate_title);

	self.m_clear_flag = new(Image,"endgate/endgame_sub_clear_flag.png");
	self.m_clear_flag:setPos(flag_x,flag_y);
	self.m_ending_unlock_btn:addChild(self.m_clear_flag);

	self:addChild(self.m_ending_unlock_btn);

	self.m_ending_lock_btn = new(Button,"endgate/endgate_sub_item_lock_bg.png");
	self.m_ending_lock_btn:setOnClick(self,self.onItemClick2);
    self.m_ending_lock_btn:setSrollOnClick();
	
	self:addChild(self.m_ending_lock_btn);

	self.m_friend_head_bg = new(Image,"endgate/ending_friend_head_bg.png");
	self.m_friend_head_bg:setPos(head_bg_x,head_bg_y);

	self.m_friend_head = new(Image,"endgate/blank.png");
	self.m_friend_head:setPos(head_x,head_y);
	self.m_friend_head:setSize(40,40);
	self.m_friend_head_bg:addChild(self.m_friend_head);

	self.m_friend_head_bg:setVisible(false);

	self:addChild(self.m_friend_head_bg);

	self:setSize(self.m_ending_lock_btn:getSize());

	self:setLocked(locked);
end

EndGateSubItem.setIndex = function(self,index)
	self.m_index = index;
	self.m_index_text = index;
end

EndGateSubItem.getIndex = function(self,index)
	return self.m_index;
end

--设置状态
EndGateSubItem.setLocked = function(self,locked)
	self.m_locked = locked;

    if locked then
    	self.m_ending_unlock_btn:setVisible(false);
    	self.m_ending_lock_btn:setVisible(true);
--		self.m_ending_lock_btn:setEnable(false);
	else
		self:setClearance(true);
		self.m_ending_unlock_btn:setVisible(true);
    	self.m_ending_lock_btn:setVisible(false);
--		self.m_ending_lock_btn:setEnable(true);
	end
end

--设置通关标记
EndGateSubItem.setClearance = function(self,flag)
	if not self.m_locked then
		self.m_clear_flag:setVisible(flag);
	end
end

EndGateSubItem.isLocked = function(self)
	return self.m_locked ;
end

EndGateSubItem.setOnClick = function(self, obj,func)
    self.m_onClickFunc = func;
	self.m_onClickObj = obj;
end

EndGateSubItem.onItemClick = function(self)
	 if self.m_onClickFunc ~= nil then
        self.m_onClickFunc(self.m_onClickObj,self:getIndex());
    end	
end

EndGateSubItem.onItemClick2 = function(self)
    ChessToastManager.getInstance():showSingle("请您先攻克上一关,此关将自动解锁");
end

EndGateSubItem.setFriendHeadImg = function(self,img)
	if img then
		self.m_friend_head:setFile(img);
	end
end

EndGateSubItem.loadFriendHeadImg = function(self,url) -- 这个占时没有用 要用记得修改头像下载方式
	local icon_name = EndGateSubItem.FPLAY_ICON_PRE .. self.m_index;
	User.loadIcon(nil,icon_name,url);
	self.m_friend_head_bg:setVisible(true);
end