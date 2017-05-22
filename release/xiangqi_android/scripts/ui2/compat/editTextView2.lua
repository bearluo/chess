--
-- UI2 Library, Version: 1.0 Alpha (0.99.2.2058-SNAPSHOT)
-- 
-- This file is a part of UI2 Library.
--
-- Author:
-- Xiaofeng Yang     2015
-- Vicent Gong       2012
--
--

--- 
--
-- @module editTextView2

require("core/object");
require("core/global");
require("ui2/compat/textView2");

EditTextView2 = class(TextView2);

EditTextView2.s_defaultHintText = " ";
EditTextView2.s_defaultHintTextColorR = 128;
EditTextView2.s_defaultHintTextColorG = 128;
EditTextView2.s_defaultHintTextColorB = 128;

EditTextView2.s_defaultMaxClickOffset = 5;

EditTextView2.setDefaultHintText = function(hintText, r, g, b)
	EditTextView2.s_hintText = hintText or EditTextView2.s_defaultHintText;
	EditTextView2.s_hintTextColorR = r or EditTextView2.s_defaultHintTextColorR;
	EditTextView2.s_hintTextColorG = g or EditTextView2.s_defaultHintTextColorG;
	EditTextView2.s_hintTextColorB = b or EditTextView2.s_defaultHintTextColorB;
end

EditTextView2.setDefaultMaxClickOffset = function(maxClickOffset)
	EditTextView2.s_maxClickOffset = maxClickOffset or EditTextView2.s_defaultMaxClickOffset;
end

EditTextView2.ctor = function(self, str, width, height, align, fontName, fontSize, r, g, b)
	self.m_textColorR = r or 0;
	self.m_textColorG = g or 0;
	self.m_textColorB = b or 0;

	self.m_hintText = EditTextView2.s_hintText or EditTextView2.s_defaultHintText;
	self.m_hintTextColorR = EditTextView2.s_hintTextColorR or EditTextView2.s_defaultHintTextColorR;
	self.m_hintTextColorG = EditTextView2.s_hintTextColorG or EditTextView2.s_defaultHintTextColorG;
	self.m_hintTextColorB = EditTextView2.s_hintTextColorB or EditTextView2.s_defaultHintTextColorB;
	
	self.m_maxClickOffset = EditTextView2.s_maxClickOffset or EditTextView2.s_defaultMaxClickOffset;
	
	self.m_drawing:setEventTouch(self,self.onEventTouch);

	self.m_textChangeCallback = {};

	self.m_enable = true;

	self.m_inputMode = kEditBoxInputModeAny;
	self.m_inputFlag = kEditBoxInputFlagInitialCapsSentence;
end

EditTextView2.setInputMode = function(self,mode)
	self.m_inputMode = mode;
end

EditTextView2.setInputFlag = function(self,flag)
	self.m_inputFlag = flag;
end

EditTextView2.setHintText = function(self, str, r, g, b)
	str = EditTextView2.convert2SafePlatformString(self,str);
	
	self.m_hintText = str or EditTextView2.s_hintText or EditTextView2.s_defaultHintText;
    self.m_hintTextColorR = r or EditTextView2.s_hintTextColorR or EditTextView2.s_defaultHintTextColorR;
	self.m_hintTextColorG = g or EditTextView2.s_hintTextColorG or EditTextView2.s_defaultHintTextColorG;
	self.m_hintTextColorB = b or EditTextView2.s_hintTextColorB or EditTextView2.s_defaultHintTextColorB;
	
	local text = EditTextView2.getText(self);
	if text == " " then
		EditTextView2.setText(self,str,nil,nil,self.m_hintTextColorR,self.m_hintTextColorG,self.m_hintTextColorB);
    end
end

EditTextView2.setText = function(self, str,width, height,r,g,b)
	self.m_textColorR = r or self.m_textColorR;
	self.m_textColorG = g or self.m_textColorG;
	self.m_textColorB = b or self.m_textColorB;

	if not str or str == self.m_hintText then
		str = self.m_hintText;
		r = self.m_hintTextColorR;
		g = self.m_hintTextColorG;
		b = self.m_hintTextColorB;
	else
		r = self.m_textColorR;
		g = self.m_textColorG;
		b = self.m_textColorB;
	end
	
	TextView2.setText(self,str,width,height,r,g,b);
end

EditTextView2.getText = function(self)
	local text = TextView2.getText(self);
	text = (text == self.m_hintText) and "" or text;
	return text;
end

EditTextView2.setEnable = function(self, enable)
	self.m_enable = enable;
end

EditTextView2.setMaxLength = function(self, maxLength)
	self.m_maxLength = maxLength;
end

EditTextView2.setOnTextChange = function(self, obj, func)
	self.m_textChangeCallback.obj = obj;
	self.m_textChangeCallback.func = func;
end

EditTextView2.onTextChange = function(self)
	if self.m_textChangeCallback.func then
		self.m_textChangeCallback.func(self.m_textChangeCallback.obj,EditTextView2.getText(self));
	end
end

EditTextView2.dtor = function(self)
	ime_close_edit();
end

---------------------------------private functions-----------------------------------------

EditTextView2.onEventTouch = function(self, finger_action, x, y, drawing_id_first, drawing_id_current, event_time)
	TextView2.onEventTouch(self,finger_action,x,y,drawing_id_first,drawing_id_current, event_time);
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

	    EditTextView2Global = self;
		ime_open_edit(EditTextView2.getText(self),
			"",
			self.m_inputMode,
			self.m_inputFlag,
			kKeyboardReturnTypeDone,
			self.m_maxLength or -1,"edit_text_view2");
    end
end

function event_ime_close_edit_text_view2(strNewValue, flag)
	if flag==1 and EditTextView2Global then
		EditTextView2Global.setText(EditTextView2Global,strNewValue);
		if (not strNewValue) or strNewValue == "" or strNewValue == EditTextView2Global.m_hintText then
			EditTextView2Global.setText(EditTextView2Global,EditTextView2Global.m_hintText,nil,nil,EditTextView2Global.m_hintTextColorR,EditTextView2Global.m_hintTextColorG,EditTextView2Global.m_hintTextColorB);
		else
			EditTextView2Global.setText(EditTextView2Global,strNewValue,nil,nil,EditTextView2Global.m_textColorR,EditTextView2Global.m_textColorG,EditTextView2Global.m_textColorB);
		end
		EditTextView2Global.onTextChange(EditTextView2Global);
	end
	EditTextView2Global = nil;
end
