require("core/constants");
require("animation/headTurnAnim");
require(BASE_PATH .. "chessDialogScene")
require(VIEW_PATH .. "ending_win_dialog_view");

EndingWinDialog = class(ChessDialogScene,false);

EndingWinDialog.win_texture  = "drawable/ending_win_texture.png";
EndingWinDialog.pass_texture  = "drawable/ending_pass_texture.png";

EndingWinDialog.chest_img = "drawable/ending_chest_texture.png";
EndingWinDialog.chest_img_bg = "drawable/ending_reward_bg.png";
EndingWinDialog.chest_img_select = "drawable/ending_reward_select_img.png";

EndingWinDialog.ctor = function(self,roomController)
	super(self,ending_win_dialog_view);
	self.m_root_view = self.m_root;

	self.m_roomController = roomController;

	self.m_dialog_bg = self.m_root_view:getChildByName("ending_win_dialog_full_screen_bg");


	self.m_content_view = self.m_root_view:getChildByName("ending_win_content_view");
	self.m_ending_win_people_tips_bg = self.m_content_view:getChildByName("ending_win_people_tips_bg");
	self.m_ending_win_people_tips_text = self.m_ending_win_people_tips_bg:getChildByName("ending_win_people_tips_text");

	self.m_ending_result_texture = self.m_content_view:getChildByName("endging_win_result_texture");

	self.m_ending_win_chest_bg = {};
	self.m_ending_win_chest = {};
	self.m_ending_win_tips = {};
	for index = 1,3 do 
		self.m_ending_win_chest_bg[index] = self.m_content_view:getChildByName(string.format("ending_win_chest%d",index));
		self.m_ending_win_chest[index] = self.m_ending_win_chest_bg[index]:getChildByName(string.format("ending_win_chest%d_texture",index));
		self.m_ending_win_chest[index]:setFile(EndingWinDialog.chest_img);
		self.m_ending_win_tips[index] = self.m_ending_win_chest_bg[index]:getChildByName(string.format("ending_win_tips%d",index));
		self.m_ending_win_tips[index]:setVisible(false);
	end

	self.m_ending_win_chest[1]:setEventTouch(self,self.selectFunc1);
	self.m_ending_win_chest[2]:setEventTouch(self,self.selectFunc2);
	self.m_ending_win_chest[3]:setEventTouch(self,self.selectFunc3);


	self.m_cancel_btn = self.m_content_view:getChildByName("ending_win_cancel_btn");
	self.m_next_btn = self.m_content_view:getChildByName("ending_win_next_btn");  --下一关
	self.m_share_btn = self.m_content_view:getChildByName("ending_win_share_btn");  --下一关


	self.m_cancel_btn:setOnClick(self,self.cancel);
	self.m_next_btn:setOnClick(self,self.nextSort);
	self.m_share_btn:setOnClick(self,self.shareInfo);

	self.m_dialog_bg:setEventTouch(self,self.onTouch);

--	room.m_root_view:addChild(self.m_root_view);
end

EndingWinDialog.dtor = function(self)
end

EndingWinDialog.isShowing = function(self)
	return self:getVisible();
end

EndingWinDialog.onTouch = function(self)
	print_string("EndingWinDialog.onTouch");
end

EndingWinDialog.show = function(self)
	kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);

	for index = 1,3 do 
		self.m_ending_win_chest_bg[index]:setFile(EndingWinDialog.chest_img_bg);
		self.m_ending_win_chest[index]:setFile(EndingWinDialog.chest_img);
		self.m_ending_win_chest[index]:setSize(128,130);
		self.m_ending_win_tips[index]:setVisible(false);
	end
	 --已获取奖励，就不可以再点击
	self.m_has_get_chest = false 

	if kEndgateData:isLastGate() == true then
		self.m_ending_result_texture:setFile(EndingWinDialog.pass_texture);
		self.m_next_btn:setVisible(false);
		self.m_share_btn:setPos(140,570);
	else
		self.m_share_btn:setPos(50,570);
		self.m_next_btn:setVisible(true);
		self.m_ending_result_texture:setFile(EndingWinDialog.win_texture);
	end

	local message = string.format("%d%%的玩家",UserInfo.getInstance():getProportion());
	self.m_ending_win_people_tips_text:setText(message);

	self:setVisible(true);
    self.super.show(self);
end


EndingWinDialog.cancel = function(self)
	print_string("EndingWinDialog.cancel ");
	self:dismiss();
end

EndingWinDialog.updateInfo = function(self)

	--保存最新关卡
	kEndgateData:setLatestGate();

	--上传进度
	local tid = kEndgateData:getGateTid();
	local sort = kEndgateData:getGateSort()+1 ;

	local propinfo = {};
	local uid = UserInfo.getInstance():getUid();

	local post_data = {};
	post_data.tid = tid;
	post_data.pos = sort;
	post_data.id = kEndgateData:getBoardTableId(); -------- 这个值不知道干嘛的
	post_data.propinfo = propinfo;
    HttpModule.getInstance():execute(HttpModule.s_cmds.uploadGateInfo,post_data);

	self:updateGateData();
end

EndingWinDialog.updateGateData = function(self)	
	local gate = kEndgateData:getGate();
	if gate.progress ~= gate.subCount then
		gate.progress = gate.progress + 1;
		if gate.progress >= gate.subCount then	--通大关啦
			gate.progress = gate.subCount;
			local uid = UserInfo.getInstance():getUid();
			local curGateNum = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_GATE_NUM..uid,1);
			curGateNum = curGateNum + 1;
			GameCacheData.getInstance():saveInt(GameCacheData.ENDGAME_GATE_NUM..uid,curGateNum);

			local tempTid = kEndgateData:getGateTids()[curGateNum];
			if tempTid then
				local uid = UserInfo.getInstance():getUid();
				GameCacheData.getInstance():saveInt(GameCacheData.ENDGAME_LATETST_GATE .. uid,tempTid);
				GameCacheData.getInstance():saveInt(GameCacheData.ENDGAME_LATETST_SORT .. uid,0);
			end
		end
		gate.uid = UserInfo.getInstance():getUid();
		dict_set_string(kUpdateEndGate,kUpdateEndGate..kparmPostfix,json.encode(gate));
		call_native(kUpdateEndGate);
	end
end

EndingWinDialog.randomChest = function(self,selected)

	local chests = nil;
	local isConnected = false--HallSocket.isConnected();
	if  isConnected then

		chests = {

		[1]	=  {
					["name"] = "悔棋",  --名字
					["probability"] = 75-kEndgateData:getWinEndGateGetSoulRate() , --获取概率
					["num_pro"] = {[1] = 60,[2] = 30, [3] = 10},  --个数的概率
					["image"] = "drawable/endgame_undo_icon.png",
					["cache_name"] = GameCacheData.ENDGAME_UNDO_NUM,
					["default_num"] = ENDING_UNDO_NUM,
			   },

		[2]	=  {
					["name"] = "起死回生",   --名字
					["probability"] = 20, --获取概率
					["num_pro"] = {85,10,5}, --个数的概率
					["image"] = "drawable/ending_reborn_img.png",
					["cache_name"] = GameCacheData.ENDGAME_REVIVE_NUM,
					["default_num"] = ENDING_REVIVE_NUM,
			   },

		[3]	=  {
				["name"] = "提示",   --名字
				["probability"] = 5, --获取概率
				["num_pro"] = {[1] = 85,[2] = 10, [3] = 5},  --个数的概率
				["image"] = "drawable/endgame_tips_icon.png",
				["cache_name"] = GameCacheData.ENDGAME_TIPS_NUM,
				["default_num"] = ENDING_TIPS_NUM,
		   },

		[4]	=  {
					["name"] = "棋魂",   --名字
					["probability"] = kEndgateData:getWinEndGateGetSoulRate(), --获取概率
					["num_pro"] = {[1] = 85,[1] = 10, [1] = 5},  --个数的概率
					["image"] = "drawable/qi_hun_icon.png",
					["cache_name"] = GameCacheData.QI_HUN,
					["default_num"] = 1,
			}

		}
	else

		chests = {

			[1]	=  {
						["name"] = "悔棋",  --名字
						["probability"] = 75, --获取概率
						["num_pro"] = {[1] = 60,[2] = 30, [3] = 10},  --个数的概率
						["image"] = "drawable/endgame_undo_icon.png",
						["cache_name"] = GameCacheData.ENDGAME_UNDO_NUM,
						["default_num"] = ENDING_UNDO_NUM,
				   },

			[2]	=  {
						["name"] = "起死回生",   --名字
						["probability"] = 20, --获取概率
						["num_pro"] = {85,10,5}, --个数的概率
						["image"] = "drawable/ending_reborn_img.png",
						["cache_name"] = GameCacheData.ENDGAME_REVIVE_NUM,
						["default_num"] = ENDING_REVIVE_NUM,
				   },

			[3]	=  {
					["name"] = "提示",   --名字
					["probability"] = 5, --获取概率
					["num_pro"] = {[1] = 85,[2] = 10, [3] = 5},  --个数的概率
					["image"] = "drawable/endgame_tips_icon.png",
					["cache_name"] = GameCacheData.ENDGAME_TIPS_NUM,
					["default_num"] = ENDING_TIPS_NUM,
			   }
		}		
	end

	local random_table_num = 6;
	if isConnected then
		random_table_num = 8;
	end

	local random_table = lua_get_random_table(100,random_table_num);

	local chest_pro = {};  --宝箱的概率表
	for key,value in pairs(chests) do
		chest_pro[key] = value.probability;
	end

	local isQiHun = false;
	for index = 1,3 do
		local pro_table = chest_pro;
		local key = lua_get_region_by_random_num(pro_table,random_table[index*2-1]);
		pro_table = chests[key]["num_pro"];
		local num = lua_get_region_by_random_num(pro_table,random_table[index*2]);

		if key == 4 then
			num = 1;
		end

		self.m_ending_win_tips[index]:setText(string.format("+%d",num));
		self.m_ending_win_tips[index]:setVisible(true);
		self.m_ending_win_chest[index]:setFile(chests[key]["image"]);
		self.m_ending_win_chest[index]:setSize(120,104);

		self.m_has_get_chest = true; --已获取奖励，就不可以再点击

		--获取奖励
		if selected == index then
			print_string(string.format("key = %d,num = %d",key,num)); 

			--背景变成选择状态
			self.m_ending_win_chest_bg[index]:setFile(EndingWinDialog.chest_img_select);
			--HeadTurnAnim.play(self.m_ending_win_chest[index]);
			--ShockAnim.play(self.m_ending_win_chest[index]);

			if key == 4 then
				isQiHun = true;
			end

			if key<4 then
				local uid = UserInfo.getInstance():getUid();
				local cache_key = chests[key]["cache_name"] .. uid;
				local cahce_num = GameCacheData.getInstance():getInt(cache_key,chests[key]["default_num"]);
				cahce_num = cahce_num + num ;
				GameCacheData.getInstance():saveInt(cache_key,cahce_num);

				if self.m_roomController then
--					self.m_roomController:showUndoNum();
--					self.m_roomController:showTipsNum();
                    self.m_roomController:updateView(EndgateRoomScene.s_cmds.updateView);
				end
			end
		end
	end

	--抽完奖后上传进度
	--如果是最新关卡，则上传进度
	if not isQiHun then
		self:updateInfo();
	elseif isConnected then
		isQiHun = false;
		self:updateInfo();		
--		PHPInterface.getSoul(1);
	end
end

EndingWinDialog.selectFunc1 = function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
	 --已获取奖励，就不可以再点击
	if	self.m_has_get_chest  then
		print_string("EndingWinDialog.selectFunc1 but self.m_has_get_chest");
		return
	end
	print_string("EndingWinDialog.selectFunc1");
	if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
       self:randomChest(1);
    end
end
EndingWinDialog.selectFunc2 = function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
		 --已获取奖励，就不可以再点击
	if	self.m_has_get_chest then
		print_string("EndingWinDialog.selectFunc1 but self.m_has_get_chest");
		return
	end
	if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
       self:randomChest(2);
    end
end
EndingWinDialog.selectFunc3 = function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
		 --已获取奖励，就不可以再点击
	if	self.m_has_get_chest  then
		print_string("EndingWinDialog.selectFunc1 but self.m_has_get_chest");
		return
	end
	if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
       self:randomChest(3);
    end
end

--下一关
EndingWinDialog.nextSort = function(self)

	self:dismiss();

	if self.m_roomController then
		self.m_roomController:loadNextGate();
	end

end

--分享信息
EndingWinDialog.shareInfo = function(self)

	print_string("EndingWinDialog.shareInfo");


	-- self.m_share_chioce_dialog:show();
	self.m_roomController:shareInfo();
	self:dismiss();
end


EndingWinDialog.dismiss = function(self)

	if not self.m_has_get_chest then
		self:updateInfo();
	end


	if self.m_share_chioce_dialog then
		self.m_share_chioce_dialog:dismiss();
	end

--	self:setVisible(false);
    self.super.dismiss(self);
end