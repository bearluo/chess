require(VIEW_PATH .. "time_picker_dialog_view");
require(BASE_PATH.."chessDialogScene")

TimePickerDialog = class(ChessDialogScene,false);

TimePickerDialog.zero_min_sec = 30;  --局时读秒，最少是30秒

TimePickerDialog.ctor = function(self)

	super(self,time_picker_dialog_view);
	self.m_root_view = self.m_root;


	self.m_dialog_bg = self.m_root_view:getChildByName("time_picker_full_screen_bg");
	self.m_dialog_bg:setEventTouch(self,self.onTouch);


	self.m_min_progress = self.m_root_view:getChildByName("time_picker_min_progress");
	self.m_sec_progress = self.m_root_view:getChildByName("time_picker_sec_progress");

	self.m_min_sub_btn = self.m_root_view:getChildByName("time_picker_min_sub_btn");
	self.m_min_add_btn = self.m_root_view:getChildByName("time_picker_min_add_btn");

	self.m_sec_sub_btn = self.m_root_view:getChildByName("time_picker_sec_sub_btn");
	self.m_sec_add_btn = self.m_root_view:getChildByName("time_picker_sec_add_btn");

	self.m_min_sub_btn:setOnClick(self,self.minSub);
	self.m_min_add_btn:setOnClick(self,self.minAdd);

	self.m_sec_sub_btn:setOnClick(self,self.secSub);
	self.m_sec_add_btn:setOnClick(self,self.secAdd);


	self.m_min_progress:setOnChange(self,self.minChange);
	self.m_sec_progress:setOnChange(self,self.secChange);

	self.m_min_text = self.m_root_view:getChildByName("time_picker_min");
	self.m_sec_text = self.m_root_view:getChildByName("time_picker_sec");


	self.m_cancel_btn = self.m_root_view:getChildByName("time_picker_cancel_btn");
	self.m_sure_btn = self.m_root_view:getChildByName("time_picker_sure_btn");



	self.m_cancel_btn:setOnClick(self,self.cancel);
	self.m_sure_btn:setOnClick(self,self.sure);

	self.m_sec_step = 5;
	self.m_min_step = 1;

	self:setVisible(false);
end

TimePickerDialog.dtor = function(self)
	self.m_root_view = nil;

end


TimePickerDialog.onTouch = function(self)
	print_string("TimePickerDialog.onTouch");
end


TimePickerDialog.isShowing = function(self)
	return self:getVisible();
end

TimePickerDialog.show = function(self)

	print_string("TimePickerDialog.show");
	self.m_min_text:setText(GameString.convert2UTF8(self.m_min .. "分"));
	self.m_sec_text:setText(GameString.convert2UTF8(self.m_sec .. "秒"));
	self:setVisible(true);
    self.super.show(self);
end

TimePickerDialog.setLimit = function(self,minMin,maxMin,minSec,maxSec)
	self.m_minMin = minMin or 0;
	self.m_maxMin = maxMin or 120;
	self.m_minSec = minSec or 0;
	self.m_maxSec = maxSec or 60;

	self.m_min_len = self.m_maxMin - self.m_minMin;
	self.m_sec_len = self.m_maxSec - self.m_minSec;
end

TimePickerDialog.setTime = function(self,min,sec)
	self.m_min = min;
	self.m_sec = sec;

	local progress_min = (min - self.m_minMin)/self.m_min_len;
	local progress_sec = (sec - self.m_minSec)/self.m_sec_len;

	self.m_min_progress:setProgress(progress_min);
	self.m_sec_progress:setProgress(progress_sec);

end

TimePickerDialog.minChange = function(self,progress)
	self.m_min = math.floor(self.m_min_len * progress) + self.m_minMin;
	self.m_min_text:setText(self.m_min .. "分");


	local progress = self.m_sec_progress:getProgress();  --没有get接口
	if self.m_min == 0 then
		self.m_sec_len = self.m_maxSec - TimePickerDialog.zero_min_sec;
		self.m_sec = math.floor(self.m_sec_len * progress) + TimePickerDialog.zero_min_sec;
		self.m_sec_text:setText(self.m_sec .. "秒");
	else
		self.m_sec_len = self.m_maxSec - self.m_minSec;
		self.m_sec = math.floor(self.m_sec_len * progress) + self.m_minSec;
		self.m_sec_text:setText(self.m_sec .. "秒");
	end
end

TimePickerDialog.secChange = function(self,progress)

	if self.m_min == 0 then
		self.m_sec_len = self.m_maxSec - TimePickerDialog.zero_min_sec;
		self.m_sec = math.floor(self.m_sec_len * progress) + TimePickerDialog.zero_min_sec;
		self.m_sec_text:setText(self.m_sec .. "秒");
	else
		self.m_sec_len = self.m_maxSec - self.m_minSec;
		self.m_sec = math.floor(self.m_sec_len * progress) + self.m_minSec;
		self.m_sec_text:setText(self.m_sec .. "秒");
	end

	-- self.m_sec = math.floor(self.m_sec_len * progress) + self.m_minSec;
	-- self.m_sec_text:setText(self.m_sec .. "秒");
end


TimePickerDialog.minAdd = function(self)
	
	self.m_min = self.m_min + self.m_min_step;

	if self.m_min > self.m_maxMin then
		self.m_min = self.m_maxMin;
	end

	self.m_min_text:setText(self.m_min .. "分");

	local progress = (self.m_min - self.m_minMin)/(self.m_maxMin - self.m_minMin);
	self.m_min_progress:setProgress(progress);
	


	progress = self.m_sec_progress:getProgress();  --没有get接口
	if self.m_min == 0 then
		self.m_sec_len = self.m_maxSec - TimePickerDialog.zero_min_sec;
		self.m_sec = math.floor(self.m_sec_len * progress) + TimePickerDialog.zero_min_sec;
		self.m_sec_text:setText(self.m_sec .. "秒");
	else
		self.m_sec_len = self.m_maxSec - self.m_minSec;
		self.m_sec = math.floor(self.m_sec_len * progress) + self.m_minSec;
		self.m_sec_text:setText(self.m_sec .. "秒");
	end

end

TimePickerDialog.minSub = function(self)
		self.m_min = self.m_min - self.m_min_step;

	if self.m_min < self.m_minMin then
		self.m_min = self.m_minMin;
	end

	self.m_min_text:setText(self.m_min .. "分");

	local progress = (self.m_min - self.m_minMin)/(self.m_maxMin - self.m_minMin);
	self.m_min_progress:setProgress(progress);
	


	progress = self.m_sec_progress:getProgress();  --没有get接口
	if self.m_min == 0 then
		self.m_sec_len = self.m_maxSec - TimePickerDialog.zero_min_sec;
		self.m_sec = math.floor(self.m_sec_len * progress) + TimePickerDialog.zero_min_sec;
		self.m_sec_text:setText(self.m_sec .. "秒");
	else
		self.m_sec_len = self.m_maxSec - self.m_minSec;
		self.m_sec = math.floor(self.m_sec_len * progress) + self.m_minSec;
		self.m_sec_text:setText(self.m_sec .. "秒");
	end
end



TimePickerDialog.secAdd = function(self)
	
	self.m_sec = self.m_sec + self.m_sec_step;

	if self.m_sec > self.m_maxSec then
		self.m_sec = self.m_maxSec;
	end

	self.m_sec_text:setText(self.m_sec .. "秒");

	
	if self.m_min == 0 then
		local progress = (self.m_sec - TimePickerDialog.zero_min_sec)/(self.m_maxSec - TimePickerDialog.zero_min_sec);
		self.m_sec_progress:setProgress(progress);
	else
		local progress = (self.m_sec - self.m_minSec)/(self.m_maxSec - self.m_minSec);
		self.m_sec_progress:setProgress(progress);
	end

end

TimePickerDialog.secSub = function(self)
	self.m_sec = self.m_sec - self.m_sec_step;

	local minSec = self.m_minSec;
	if self.m_min == 0 then
		minSec = TimePickerDialog.zero_min_sec;
	end

		

	if self.m_sec <  minSec then
		self.m_sec = minSec;
	end

	local progress = (self.m_sec - minSec)/(self.m_maxSec - minSec);
	self.m_sec_progress:setProgress(progress);

	self.m_sec_text:setText(self.m_sec .. "秒");

	
	

end

TimePickerDialog.cancel = function(self)
	print_string("TimePickerDialog.cancel ");
	self:dismiss();
end

TimePickerDialog.sure = function(self)
	print_string("TimePickerDialog.sure ");

	if self.m_posObj and self.m_posFunc then
		self.m_posFunc(self.m_posObj,self.m_min,self.m_sec);
	end

	self:dismiss();

end

TimePickerDialog.setPositiveListener = function(self,obj,func)
	self.m_posObj = obj;
	self.m_posFunc = func;
end

TimePickerDialog.setNegativeListener = function(self,obj,func)
	self.m_negObj = obj;
	self.m_negFunc = func;
end


--TimePickerDialog.dismiss = function(self)
--	self:setVisible(false);

--end