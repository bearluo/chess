-- editTextex.lua
require("ui/editText");

-- 扩充布局方式
EditText.s_EX_LAYOUT_LINEARLAYOUT_FULL_WIDTH = 1;			-- 宽满屏
EditText.s_EX_LAYOUT_RELATIVELAYOUT_NOT_FULL_WIDTH = 2;		-- 宽半屏

-- 扩充FLAG
-- kEditBoxInputFlagVisiblePassword					 = 5;

-- 扩充输入格式
EditText.s_EX_INPUT_TYPE_NUMBER = 1;						-- 1234 1234 1234
EditText.s_EX_INPUT_TYPE_PHONE_NUMBER = 2;					-- 123 1234 1234

EditText.s_ex_dict_table_name = "inputEditExTable";
EditText.s_ex_dict_key_layoutEx = "layoutEx";
EditText.s_ex_dict_key_modeEx = "modeEx";

-- 输入框布局
EditText.setInputLayoutEx = function(self, layoutEx)
	self.m_inputLayoutEx = layoutEx;
end

-- 扩充输入类型
EditText.setInputModeEx = function(self, modeEx)
	self.m_inputModeEx = modeEx;
end

-- 设置Android端显示的title
EditText.setInputTitle = function(self, title)
	self.m_inputTitle = title;
end

EditText.onSetExParams = function(self)
	-- layoutEx
	dict_set_int(EditText.s_ex_dict_table_name,EditText.s_ex_dict_key_layoutEx,self.m_inputLayoutEx or 0);
	-- modeEx
	dict_set_int(EditText.s_ex_dict_table_name,EditText.s_ex_dict_key_modeEx,self.m_inputModeEx or 0);
end


EditText.setText = function(self , str, width, height, r, g, b)

	if not str or str == self.m_hintText then
		EditText.setRealTextValue(self , " ");

		str = self.m_hintText;
		r = self.m_hintTextColorR;
		g = self.m_hintTextColorG;
		b = self.m_hintTextColorB;
	else
		EditText.setRealTextValue(self , str);

		if self.m_inputFlag == kEditBoxInputFlagPassword then
			--如果是密码 则进行转换再显示
			str = EditText.maskTextValue(self , str);
		end
      
	    self.m_textColorR = r or self.m_textColorR;
	    self.m_textColorG = g or self.m_textColorG;
	    self.m_textColorB = b or self.m_textColorB;
		r = self.m_textColorR;
		g = self.m_textColorG;
		b = self.m_textColorB;
	end

	Text.setText(self,str,width,height,r,g,b);
end

EditText.maskTextValue = function(self , beforeValue)
	beforeValue = beforeValue or "";
	beforeValue = string.gsub(beforeValue," ",'');
	local len = string.len(beforeValue);
	local afterValue = "";
	for i = 1,len do
		afterValue = afterValue .."*";
	end

	return afterValue;
end

EditText.getText = function(self)
	local text = Text.getText(self);

	if self.m_inputFlag == kEditBoxInputFlagPassword then
		text = self.m_realTextValue or text;
	end

	text = (text == self.m_hintText) and " " or text;

	return text;
end

EditText.setRealTextValue = function(self , realTextValue)
	self.m_realTextValue = Text.convert2SafeString(self , realTextValue);
end

EditText.onEventTouch = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
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

	    EditTextGlobal = self;

	    -- 扩充传值
	    self:onSetExParams();
		ime_open_edit(EditText.getText(self),
			self.m_inputTitle or "",
			self.m_inputMode,
			self.m_inputFlag,
			kKeyboardReturnTypeDone,
			self.m_maxLength or -1,"global");

    end
end
