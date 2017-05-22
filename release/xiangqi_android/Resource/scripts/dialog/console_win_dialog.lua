require("core/constants");
require("animation/headTurnAnim");
require(VIEW_PATH .. "console_win_dialog_view");
require(BASE_PATH.."chessDialogScene")
ConsoleWinDialog = class(ChessDialogScene,false);

ConsoleWinDialog.win_texture  = "drawable/console_win_texture.png";
ConsoleWinDialog.pass_texture  = "drawable/console_win_texture.png";

ConsoleWinDialog.chest_img = "drawable/ending_chest_texture.png";
ConsoleWinDialog.chest_img_bg = "drawable/ending_reward_bg.png";
ConsoleWinDialog.chest_img_select = "drawable/ending_reward_select_img.png";

ConsoleWinDialog.ctor = function(self,room,isCrossLayer)
	super(self,console_win_dialog_view);
	self.m_root_view = self.m_root;
    self.m_room = room;
	self.m_isCrossLayer = isCrossLayer;

	self.m_dialog_bg = self.m_root_view:getChildByName("console_win_dialog_full_screen_bg");

	self.m_content_view = self.m_root_view:getChildByName("console_win_content_view");

    self.m_console_win_dialog_bg = self.m_content_view:getChildByName("console_win_dialog_bg");

	self.m_console_win_title = self.m_content_view:getChildByName("console_win_title");

	self.m_console_chest_tips = self.m_content_view:getChildByName("console_win_chest_tips");
 
	self.m_console_win_chest_bg = {};
	self.m_console_win_chest = {};
	self.m_console_win_tips = {};
	for index = 1,3 do 
		self.m_console_win_chest_bg[index] = self.m_content_view:getChildByName(string.format("console_win_chest%d",index));
		self.m_console_win_chest[index] = self.m_console_win_chest_bg[index]:getChildByName(string.format("console_win_chest%d_texture",index));
		self.m_console_win_chest[index]:setFile(ConsoleWinDialog.chest_img);
		self.m_console_win_tips[index] = self.m_console_win_chest_bg[index]:getChildByName(string.format("console_win_tips%d",index));
		self.m_console_win_tips[index]:setVisible(false);
	end

	self.m_console_win_chest[1]:setEventTouch(self,self.selectFunc1);
	self.m_console_win_chest[2]:setEventTouch(self,self.selectFunc2);
	self.m_console_win_chest[3]:setEventTouch(self,self.selectFunc3);


	self.m_cancel_btn = self.m_content_view:getChildByName("console_win_cancel_btn");
	self.m_retry_btn = self.m_content_view:getChildByName("console_win_retry_btn");  --再来一局
	self.m_share_btn = self.m_content_view:getChildByName("console_win_share_btn");  --分享
	self.m_save_btn = self.m_content_view:getChildByName("console_win_save_btn");  --保存


	self.m_cancel_btn:setOnClick(self,self.cancel);
	self.m_retry_btn:setOnClick(self,self.retry);
	self.m_share_btn:setOnClick(self,self.shareInfo);
	self.m_save_btn:setOnClick(self,self.save);

	self.m_dialog_bg:setEventTouch(self,self.onTouch);

	self:setVisible(false);
    
    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)
end

ConsoleWinDialog.dtor = function(self)
	self.m_root_view = nil;
    self.mDialogAnim.stopAnim()
end

ConsoleWinDialog.isShowing = function(self)
	return self:getVisible();
end

ConsoleWinDialog.onTouch = function(self)
	print_string("ConsoleWinDialog.onTouch");
end

ConsoleWinDialog.show = function(self,isCrossLayer)
	if isCrossLayer then
		self.m_isCrossLayer = isCrossLayer
	end
    if not self.m_AnimWin then
        self.m_AnimWin = new(AnimWin);
    end;
    self.m_AnimWin = new(AnimWin);
    self.m_console_win_dialog_bg:addChild(self.m_AnimWin);
    self.m_AnimWin:setPos(50, -25);
    self.m_AnimWin:play();
	kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);

	for index = 1,3 do 
		self.m_console_win_chest_bg[index]:setFile(ConsoleWinDialog.chest_img_bg);
		self.m_console_win_chest[index]:setFile(ConsoleWinDialog.chest_img);
		self.m_console_win_chest[index]:setSize(128,130);
		self.m_console_win_tips[index]:setVisible(false);
	end
	 --已获取奖励，就不可以再点击
	self.m_has_get_chest = false 

	local curLevel = UserInfo.getInstance():getPlayingLevel();
	self.m_console_chest_tips:setText(string.format("你在“%s”中挑战成功",User.AI_TITLE[curLevel]));
	self:setVisible(true);
    self.super.show(self,self.mDialogAnim.showAnim);
end


ConsoleWinDialog.cancel = function(self)
	print_string("ConsoleWinDialog.cancel ");
	self:dismiss();
end

ConsoleWinDialog.updateInfo = function(self)
	-- --上传进度
	-- PHPInterface.uploadGateInfo();
end

ConsoleWinDialog.randomChest = function(self,selected)
	local rate ;
	if self.m_isCrossLayer then
		rate = UserInfo.getInstance():getPassConsoleLayerGetSoulRate();
	else
		rate = UserInfo.getInstance():getWinConsoleGetSoulRate();
	end

	local drate1 = 0;
	local drate2 = 0;
	local drate3 = 0;

	if rate > 75 then
		if rate > 95 then
			drate1 = 75
			drate2 = 20
			drate3 = rate -95
		else
			drate1 = 75
			drate2 = rate -75
		end
	else
		drate1 = rate;
	end

	local isConnected = UserInfo.getInstance():getConnectHall();
	if not  isConnected then
		rate  = 0;--没有网络时候无法获取 几率为0
	end


	local chests = {

		[1]	=  {
					["name"] = "悔棋",  --名字
					["probability"] = 75 - drate1, --获取概率
					["num_pro"] = {[1] = 60,[2] = 30, [3] = 10},  --个数的概率
					["image"] = "drawable/endgame_undo_icon.png",
					["cache_name"] = GameCacheData.ENDGAME_UNDO_NUM,
					["default_num"] = ENDING_UNDO_NUM,
			   },
		[2]	=  {
					["name"] = "起死回生",   --名字
					["probability"] = 20 - drate2, --获取概率
					["num_pro"] = {85,10,5}, --个数的概率
					["image"] = "drawable/ending_reborn_img.png",
					["cache_name"] = GameCacheData.ENDGAME_REVIVE_NUM,
					["default_num"] = ENDING_REVIVE_NUM,

			   },
		[3]	=  {
				["name"] = "提示",   --名字
				["probability"] = 5 - drate3, --获取概率
				["num_pro"] = {[1] = 85,[2] = 10, [3] = 5},  --个数的概率
				["image"] = "drawable/endgame_tips_icon.png",
				["cache_name"] = GameCacheData.ENDGAME_TIPS_NUM,
				["default_num"] = ENDING_TIPS_NUM,
		   },

		[4]	=  {
					["name"] = "棋魂",   --名字
					["probability"] = rate, --获取概率
					["num_pro"] = {[1] = 85,[1] = 10, [1] = 5},  --个数的概率
					["image"] = "drawable/qi_hun_icon.png",
					["cache_name"] = GameCacheData.QI_HUN,
					["default_num"] = 1,
			},		   
	}

	local random_table = lua_get_random_table(100,6);

	local chest_pro = {};  --宝箱的概率表
	for key,value in pairs(chests) do
		chest_pro[key] = value.probability;
	end

	local isQihun = false;

	for index = 1,3 do
		local pro_table = chest_pro;
		local key = lua_get_region_by_random_num(pro_table,random_table[index*2-1]);
        if key < 1 or key > 4 then
            key = 1;
        end
		pro_table = chests[key]["num_pro"];
		local num = lua_get_region_by_random_num(pro_table,random_table[index*2]);
	
		if key == 4 then
			num = 1;
		end

		self.m_console_win_tips[index]:setText(string.format("+%d",num));
		self.m_console_win_tips[index]:setVisible(true);
		self.m_console_win_chest[index]:setFile(chests[key]["image"]);
		self.m_console_win_chest[index]:setSize(120,104);

		self.m_has_get_chest = true; --已获取奖励，就不可以再点击

		--获取奖励
		if selected == index then
			print_string(string.format("key = %d,num = %d,index = %d",key,num,index)); 

			--背景变成选择状态
			self.m_console_win_chest_bg[index]:setFile(ConsoleWinDialog.chest_img_select);
			--HeadTurnAnim.play(self.m_console_win_chest[index]);
			--ShockAnim.play(self.m_console_win_chest[index]);

			local uid = UserInfo.getInstance():getUid();
			local cache_key = chests[key]["cache_name"] .. uid;
			local cahce_num = GameCacheData.getInstance():getInt(cache_key,chests[key]["default_num"]);
			cahce_num = cahce_num + num ;
			GameCacheData.getInstance():saveInt(cache_key,cahce_num);

			if key == 4 then
				isQiHun = true;
			end

			if self.m_room then
				self.m_room.m_view:showUndoNum();
--				self.m_room.m_view:showTipsNum();
			end
	
			--上传统计数据
			local one_reward = {};
			one_reward.type = key + 1;
			one_reward.num = num;
			one_reward.level = 	 UserInfo.getInstance():getPlayingLevel();
			one_reward.time = os.time();
			reward_str = json.encode(one_reward);
	        local post_data = {};
	        post_data.reward_str = UserInfo.getInstance():addPlayConsoleReward(reward_str);
            self.m_room:sendHttpMsg(HttpModule.s_cmds.statRewardPerLevel, post_data);
--			PHPInterface.statRewardPerLevel(reward_str);

		end
	end

	if isQiHun and isConnected then
		isQiHun = false;
		if self.m_isCrossLayer then
            self.m_room:onGetSoul(3);
		else
            self.m_room:onGetSoul(4);
		end
	end

end

ConsoleWinDialog.selectFunc1 = function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
	 --已获取奖励，就不可以再点击
	if	self.m_has_get_chest  then
		print_string("ConsoleWinDialog.selectFunc1 but self.m_has_get_chest");
		return
	end
	print_string("ConsoleWinDialog.selectFunc1");
	if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
       self:randomChest(1);
    end
end
ConsoleWinDialog.selectFunc2 = function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
		 --已获取奖励，就不可以再点击
	if	self.m_has_get_chest then
		print_string("ConsoleWinDialog.selectFunc1 but self.m_has_get_chest");
		return
	end
	if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
       self:randomChest(2);
    end
end
ConsoleWinDialog.selectFunc3 = function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
		 --已获取奖励，就不可以再点击
	if	self.m_has_get_chest  then
		print_string("ConsoleWinDialog.selectFunc1 but self.m_has_get_chest");
		return
	end
	if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
       self:randomChest(3);
    end
end

--下一关
ConsoleWinDialog.retry = function(self)

	self:dismiss();

	if self.m_room then
		self.m_room:onStartGame();
	end

end

--分享信息
ConsoleWinDialog.shareInfo = function(self)

	print_string("ConsoleWinDialog.shareInfo");


	-- self.m_share_chioce_dialog:show();
	self.m_room:onShareAction();
	self:dismiss();
end

ConsoleWinDialog.save = function(self)
	self:dismiss();
	if self.m_room then
		self.m_room:saveChess();
	end
end


ConsoleWinDialog.dismiss = function(self)

	if not self.m_has_get_chest then
		self:updateInfo();
	end

	if self.m_share_chioce_dialog then
		self.m_share_chioce_dialog:dismiss();
	end
    delete(self.m_AnimWin);
    self.m_AnimWin = nil;
--	self:setVisible(false);
    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
end