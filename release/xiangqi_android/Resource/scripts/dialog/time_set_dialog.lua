
require(VIEW_PATH .. "time_set_dialog_view");
require("dialog/time_picker_dialog");
require(BASE_PATH.."chessDialogScene")
TimeSetDialog = class(ChessDialogScene,false);




TimeSetDialog.timout1_min_min = 5;
TimeSetDialog.timout1_max_min = 120;

TimeSetDialog.max_sec = 59;

TimeSetDialog.timeout = 60;

TimeSetDialog.ctor = function(self, room)
    
    super(self,time_set_dialog_view);

	self.m_root_view = self.m_root;
    
    self.m_room = room;

	self.m_dialog_bg = self.m_root_view:getChildByName("time_set_full_screen_bg");
	self.m_dialog_bg:setEventTouch(self,self.onTouch);

	self.m_content_view = self.m_root_view:getChildByName("time_set_content_view");

	self.m_time_set_title = self.m_content_view:getChildByName("time_set_title");

	self.m_time_set_content = self.m_content_view:getChildByName("time_set_content");
	self.m_timeout1_bg = self.m_time_set_content:getChildByName("timeout1_bg");
	self.m_timeout2_bg = self.m_time_set_content:getChildByName("timeout2_bg");
	self.m_timeout3_bg = self.m_time_set_content:getChildByName("timeout3_bg");

	-- self.m_timeout1_text = self.m_timeout1_bg:getChildByName("timeout1");
	-- self.m_timeout2_text = self.m_timeout2_bg:getChildByName("timeout2");
	-- self.m_timeout3_text = self.m_timeout3_bg:getChildByName("timeout3");

	self.m_timeout1_min = self.m_timeout1_bg:getChildByName("timeout1_min");
	self.m_timeout2_min = self.m_timeout2_bg:getChildByName("timeout2_min");
	self.m_timeout3_min = self.m_timeout3_bg:getChildByName("timeout3_min");

	self.m_timeout1_sec = self.m_timeout1_bg:getChildByName("timeout1_sec");
	self.m_timeout2_sec = self.m_timeout2_bg:getChildByName("timeout2_sec");
	self.m_timeout3_sec = self.m_timeout3_bg:getChildByName("timeout3_sec");

	self.m_timeout1_bg:setEventTouch(self,self.setTimeout1);
	self.m_timeout2_bg:setEventTouch(self,self.setTimeout2);
	self.m_timeout3_bg:setEventTouch(self,self.setTimeout3);

	self.m_cancel_btn = self.m_content_view:getChildByName("time_set_cancel_btn");
	self.m_sure_btn = self.m_content_view:getChildByName("time_set_sure_btn");

	self.m_cancel_texture = self.m_cancel_btn:getChildByName("time_set_cancel_texture");
	self.m_sure_texture = self.m_sure_btn:getChildByName("time_set_sure_texture");

	self.m_timeout_bg = self.m_content_view:getChildByName("time_set_time_bg");
	self.m_timeout_text = self.m_timeout_bg:getChildByName("time_set_time_text");


	self:setVisible(false);

	self:initDefaultTime();


end

TimeSetDialog.dtor = function(self)
	self.m_root_view = nil;

end

TimeSetDialog.initDefaultTime = function(self)
	print_string("TimeSetDialog.initDefaultTime");
	local sumtime = RoomConfig.getInstance():getFreedomRoomSumTime();
	self.m_time1_min = math.floor(sumtime/60);
	self.m_time1_sec = sumtime%60;

	local steptime = RoomConfig.getInstance():getFreedomRoomStepTime();
	self.m_time2_min = math.floor(steptime/60);
	self.m_time2_sec = steptime%60;

	local readtime = RoomConfig.getInstance():getFreedomRoomReadTime();
	self.m_time3_min = math.floor(readtime/60);
	self.m_time3_sec = readtime%60;

	self.m_need_default = false;
end

TimeSetDialog.onTouch = function(self)
	print_string("TimeSetDialog.onTouch");
end

TimeSetDialog.isShowing = function(self)
	return self:getVisible();
end

TimeSetDialog.setTime = function(self,timeout1,timeout2,timeout3)

	print_string(string.format("TimeSetDialog.setTime  timeout1 = %d,timeout2 = %d,timeout3 = %d",timeout1,timeout2,timeout3));

	self.m_time1_min = math.floor(timeout1/60);
	self.m_time1_sec = (timeout1%60);
	
	self.m_time2_min = math.floor(timeout2/60);
	self.m_time2_sec = (timeout2%60);
	
	self.m_time3_min = math.floor (timeout3/60);
	self.m_time3_sec = (timeout3%60);
	
end

TimeSetDialog.setTimeout1 = function(self)
	if not self.m_isSetTime then
		return
	end
	print_string("TimeSetDialog.setTimeout1");
	if not self.m_timeout_picker then
		self.m_timeout_picker  = new(TimePickerDialog,self);
	end
	self.m_timeout_picker:setPositiveListener(self,self.timeout1OnSet);
	self.m_timeout_picker:setLimit(TimeSetDialog.timout1_min_min,TimeSetDialog.timout1_max_min,0,TimeSetDialog.max_sec);
	self.m_timeout_picker:setTime(self.m_time1_min,self.m_time1_sec);
	self.m_timeout_picker:show();
end

TimeSetDialog.setTimeout2 = function(self)
	if not self.m_isSetTime then
		return
	end
	print_string("TimeSetDialog.setTimeout2");	
	if not self.m_timeout_picker then
		self.m_timeout_picker  = new(TimePickerDialog,self);

	end
	self.m_timeout_picker:setPositiveListener(self,self.timeout2OnSet);
	self.m_timeout_picker:setLimit(0,self.m_time1_min-1,0,TimeSetDialog.max_sec);
	self.m_timeout_picker:setTime(self.m_time2_min,self.m_time2_sec);
	self.m_timeout_picker:show();
end

TimeSetDialog.setTimeout3 = function(self)
	if not self.m_isSetTime then
		return
	end

	print_string("TimeSetDialog.setTimeout3");
	if not self.m_timeout_picker then
		self.m_timeout_picker  = new(TimePickerDialog,self);
	end
	self.m_timeout_picker:setPositiveListener(self,self.timeout3OnSet);
	self.m_timeout_picker:setLimit(0,self.m_time1_min-1,0,TimeSetDialog.max_sec);
	self.m_timeout_picker:setTime(self.m_time3_min,self.m_time3_sec);
	self.m_timeout_picker:show();
end

TimeSetDialog.timeout1OnSet = function(self,min,sec)
	self.m_time1_min = min;
	self.m_time1_sec = sec;
	self.m_timeout1_min:setText(self.m_time1_min .. "分");
	self.m_timeout1_sec:setText(self.m_time1_sec .. "秒");
	-- self.m_timeout1_text:setText(self.m_time1_min .. ":" .. self.m_time1_sec);
end

TimeSetDialog.timeout2OnSet = function(self,min,sec)
	self.m_time2_min = min;
	self.m_time2_sec = sec;
	self.m_timeout2_min:setText(self.m_time2_min .. "分");
	self.m_timeout2_sec:setText(self.m_time2_sec .. "秒");
	-- self.m_timeout2_text:setText(self.m_time2_min .. ":" .. self.m_time2_sec);
end

TimeSetDialog.timeout3OnSet = function(self,min,sec)
	self.m_time3_min = min;
	self.m_time3_sec = sec;
	self.m_timeout3_min:setText(self.m_time3_min .. "分");
	self.m_timeout3_sec:setText(self.m_time3_sec .. "秒");
	-- self.m_timeout3_text:setText(self.m_time3_min .. ":" .. self.m_time3_sec);
end

TimeSetDialog.show = function(self,isSetTime)
	self.m_isSetTime = isSetTime;

	self:timeout1OnSet(self.m_time1_min,self.m_time1_sec);
	self:timeout2OnSet(self.m_time2_min,self.m_time2_sec);
	self:timeout3OnSet(self.m_time3_min,self.m_time3_sec);

	-- self.m_timeout1_text:setText(self.m_time1_min .. ":" .. self.m_time1_sec);
	-- self.m_timeout2_text:setText(self.m_time2_min .. ":" .. self.m_time2_sec);
	-- self.m_timeout3_text:setText(self.m_time3_min .. ":" .. self.m_time3_sec);

	if isSetTime then
		self.m_time_set_title:setFile("drawable/timeset_title_set.png");

		local sure_text = sure_str or "确定";
		self.m_sure_texture:setText(sure_text);

		local cancel_text = cancel_str or "取消";
		self.m_cancel_texture:setText(cancel_text);

		self.m_cancel_btn:setOnClick(self,self.cancel);
		self.m_sure_btn:setOnClick(self,self.sure);

	else
		self.m_time_set_title:setFile("drawable/timeset_title_confirm.png");


		local sure_text = sure_str or "同意";
		self.m_sure_texture:setText(sure_text);

		local cancel_text = cancel_str or "拒绝";
		self.m_cancel_texture:setText(cancel_text);

		self.m_cancel_btn:setOnClick(self,self.refuse);
		self.m_sure_btn:setOnClick(self,self.agree);
	end

	self:startTimeout();

	self:setVisible(true);
    self.super.show(self);



end

TimeSetDialog.startTimeout = function(self)
	self.m_timeout = 60;
	self.m_timeoutAnim = new(AnimInt,kAnimLoop,0,1,1000,-1);
	self.m_timeoutAnim:setDebugName("TimeSetDialog.startTimeout.m_timeoutAnim");
	
	self.m_timeoutAnim:setEvent(self,self.timeoutRun);
end

TimeSetDialog.stopTimeout = function(self)
	if self.m_timeoutAnim then
		delete(self.m_timeoutAnim);
		self.m_timeoutAnim = nil;
	end
end

TimeSetDialog.timeoutRun = function(self)
	self.m_timeout =  self.m_timeout - 1;
	if self.m_timeout  < 0 then
		if self.m_isSetTime then
			self:cancel();
		else
			self:refuse();
		end
		return;
	end
	self.m_timeout_text:setText("" .. self.m_timeout);

end


TimeSetDialog.cancel = function(self)
	print_string("TimeSetDialog.cancel ");
	self:dismiss();
end

TimeSetDialog.sure = function(self)
	print_string("TimeSetDialog.sure ");
	
	if not self:setRoomTime() then
		return 
	end
    local info = {};
    info.timeout1 = self.m_room.m_timeout1;
    info.timeout2 = self.m_room.m_timeout2;
    info.timeout3 = self.m_room.m_timeout3;
	self.m_room.m_controller:sendSocketMsg(SET_TIME_INFO,info, 2,2);
	local message = "等待对手确认时间...";
	self.m_room:showLoadingDialog(message);
	self:dismiss();

end


TimeSetDialog.refuse = function(self)

	
	-- if not self:setRoomTime() then
	-- 	return 
	-- end

	self:setRoomTime();
    local info = {};
    info.isOK = 0;
    info.timeout1 = self.m_room.m_timeout1;
    info.timeout2 = self.m_room.m_timeout2;
    info.timeout3 = self.m_room.m_timeout3;
    self.m_room.m_controller:sendSocketMsg(SET_TIME_INFO,info, 4,2);
    self.m_room:dismissLoadingDialog();
    self.m_room:dismissLoadingDialog2();
    
--	local processer = ProcessFactory.getInstance():getProcesser(SET_TIME_INFO);
--	local ret = processer:doRequest(self.m_room,SET_TIME_INFO,4,0);

	self:dismiss();
end

TimeSetDialog.agree = function(self)

	-- if not self:setRoomTime() then
	-- 	return 
	-- end

	self:setRoomTime();
    local info = {};
    info.isOK = 1;
    info.timeout1 = self.m_room.m_timeout1;
    info.timeout2 = self.m_room.m_timeout2;
    info.timeout3 = self.m_room.m_timeout3;
    self.m_room.m_controller:sendSocketMsg(SET_TIME_INFO,info, 4,2);
    self.m_room:dismissLoadingDialog();
    self.m_room:dismissLoadingDialog2();
--	local processer = ProcessFactory.getInstance():getProcesser(SET_TIME_INFO);
--	local ret = processer:doRequest(self.m_room,SET_TIME_INFO,4,1);

	self:dismiss();
end

TimeSetDialog.setRoomTime = function(self)
	local timeout1 = self.m_time1_min * 60 + self.m_time1_sec;
	local timeout2 = self.m_time2_min * 60 + self.m_time2_sec;
	local timeout3 = self.m_time3_min * 60 + self.m_time3_sec;


	
	if(timeout1 < 60 * 5) then
		timeout2 = 60 * 5;
	end

	if(timeout2 < 30) then
		timeout2 = 30;
	end
	
	if(timeout3 < 30) then
		timeout3 = 30;
	end

	print_string(string.format("TimeSetDialog.setRoomTime timeout1 = %d,timeout2 = %d,timeout3 = %d",timeout1,timeout2,timeout3));

	self.m_room.m_timeout1 = timeout1;
	self.m_room.m_timeout2 = timeout2;
	self.m_room.m_timeout3 = timeout3;

	if timeout3 > timeout2 or timeout2 > timeout1 then
		if not self.m_chioce_dialog then
			self.m_chioce_dialog = new(ChioceDialog);
		end



		local message = "你的读秒大于步时，或者步时大于局时，请重新设置！！！";
		self.m_chioce_dialog:setMode(ChioceDialog.MODE_OK);
		self.m_chioce_dialog:setMessage(message);
		self.m_chioce_dialog:setPositiveListener(nil,nil);
		self.m_chioce_dialog:show();

		self.m_need_default = true;
		return false;
	end

	

	return true;
end

TimeSetDialog.dismiss = function(self)
	if self.m_timeout_picker and self.m_timeout_picker:isShowing() then
		self.m_timeout_picker:dismiss();
	end

	if self.m_chioce_dialog  and self.m_chioce_dialog:isShowing() then
		self.m_chioce_dialog:dismiss();
	end

	if self.m_need_default then
		self:initDefaultTime();
	end

	self:stopTimeout();
--	self:setVisible(false);
    self.super.dismiss(self);
end