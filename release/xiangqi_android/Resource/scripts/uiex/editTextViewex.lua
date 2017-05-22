-- editTextViewex.lua
require("ui/editTextView");

-- 设置Android端显示的title
EditTextView.setInputTitle = function(self, title)
	self.m_inputTitle = title;
end

-- 输入框布局
EditTextView.setInputLayoutEx = function(self, layoutEx)
	self.m_inputLayoutEx = layoutEx;
end

-- 扩充输入类型
EditTextView.setInputModeEx = function(self, modeEx)
	self.m_inputModeEx = modeEx;
end
-- 强制吊起输入框
EditTextView.showInputDialog = function(self)
    EditTextViewGlobal = self;
	ime_open_edit(EditTextView.getText(self),
		self.m_inputTitle or "",
		self.m_inputMode,
		self.m_inputFlag,
		kKeyboardReturnTypeDone,
		self.m_maxLength or -1,"global_view");
end

EditTextView.onEventTouch = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
	TextView.onEventTouch(self,finger_action,x,y,drawing_id_first,drawing_id_current);
	if finger_action == kFingerDown then
	    self.m_startX = x;
	    self.m_startY = y;
	    self.m_touching = true;
	elseif finger_action == kFingerUp then
	    if not self.m_touching then return end;

	    self.m_touching = false;

	    local diffX = math.abs(x - self.m_startX);
	    local diffY = math.abs(y - self.m_startY);
	    if diffX > self.m_maxClickOffset 
	    	or diffY > self.m_maxClickOffset 
	    	or (not self.m_enable) 
	    	or (drawing_id_first ~= drawing_id_current) then
	        return;
	    end

	    EditTextViewGlobal = self;

	     -- 扩充传值
	    self:onSetExParams();

		ime_open_edit(EditTextView.getText(self),
			self.m_inputTitle or "",
			self.m_inputMode,
			self.m_inputFlag,
			kKeyboardReturnTypeDone,
			self.m_maxLength or -1,"global_view");
    end
end

EditTextView.onSetExParams = function(self)
	-- layoutEx
	dict_set_int(EditText.s_ex_dict_table_name,EditText.s_ex_dict_key_layoutEx,self.m_inputLayoutEx or 0);
	-- modeEx
	dict_set_int(EditText.s_ex_dict_table_name,EditText.s_ex_dict_key_modeEx,self.m_inputModeEx or 0);
end