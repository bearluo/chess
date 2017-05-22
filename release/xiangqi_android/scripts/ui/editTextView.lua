-- editTextView.lua
-- Author: Vicent Gong
-- Date: 2012-09-27
-- Last modification : 2013-06-24
-- Description: Implement a single line edit text field

require("core/object");
require("core/global");
require("ui/textView");

EditTextView = class(TextView);

EditTextView.s_defaultHintText = " ";
EditTextView.s_defaultHintTextColorR = 128;
EditTextView.s_defaultHintTextColorG = 128;
EditTextView.s_defaultHintTextColorB = 128;

EditTextView.s_defaultMaxClickOffset = 5;

EditTextView.setDefaultHintText = function(hintText, r, g, b)
	EditTextView.s_hintText = hintText or EditTextView.s_defaultHintText;
	EditTextView.s_hintTextColorR = r or EditTextView.s_defaultHintTextColorR;
	EditTextView.s_hintTextColorG = g or EditTextView.s_defaultHintTextColorG;
	EditTextView.s_hintTextColorB = b or EditTextView.s_defaultHintTextColorB;
end

EditTextView.setDefaultMaxClickOffset = function(maxClickOffset)
	EditTextView.s_maxClickOffset = maxClickOffset or EditTextView.s_defaultMaxClickOffset;
end

EditTextView.ctor = function(self, str, width, height, align, fontName, fontSize, r, g, b)
	self.m_textColorR = r or 0;
	self.m_textColorG = g or 0;
	self.m_textColorB = b or 0;

	self.m_hintText = EditTextView.s_hintText or EditTextView.s_defaultHintText;
	self.m_hintTextColorR = EditTextView.s_hintTextColorR or EditTextView.s_defaultHintTextColorR;
	self.m_hintTextColorG = EditTextView.s_hintTextColorG or EditTextView.s_defaultHintTextColorG;
	self.m_hintTextColorB = EditTextView.s_hintTextColorB or EditTextView.s_defaultHintTextColorB;
	
	self.m_maxClickOffset = EditTextView.s_maxClickOffset or EditTextView.s_defaultMaxClickOffset;
	
	self.m_drawing:setEventTouch(self,self.onEventTouch);

	self.m_textChangeCallback = {};

	self.m_enable = true;

	self.m_inputMode = kEditBoxInputModeAny;
	self.m_inputFlag = kEditBoxInputFlagInitialCapsSentence;
end

EditTextView.setInputMode = function(self,mode)
	self.m_inputMode = mode;
end

EditTextView.setInputFlag = function(self,flag)
	self.m_inputFlag = flag;
end

EditTextView.setHintText = function(self, str, r, g, b)
	str = EditTextView.convert2SafePlatformString(self,str);
	
	self.m_hintText = str or EditTextView.s_hintText or EditTextView.s_defaultHintText;
    self.m_hintTextColorR = r or EditTextView.s_hintTextColorR or EditTextView.s_defaultHintTextColorR;
	self.m_hintTextColorG = g or EditTextView.s_hintTextColorG or EditTextView.s_defaultHintTextColorG;
	self.m_hintTextColorB = b or EditTextView.s_hintTextColorB or EditTextView.s_defaultHintTextColorB;
	
	local text = EditTextView.getText(self);
	if text == " " then
		EditTextView.setText(self,str,nil,nil,self.m_hintTextColorR,self.m_hintTextColorG,self.m_hintTextColorB);
    end
end

EditTextView.setText = function(self, str,width, height,r,g,b)
	if not str or str == self.m_hintText then
		str = self.m_hintText;
		r = self.m_hintTextColorR;
		g = self.m_hintTextColorG;
		b = self.m_hintTextColorB;
	else
        self.m_textColorR = r or self.m_textColorR;
	    self.m_textColorG = g or self.m_textColorG;
	    self.m_textColorB = b or self.m_textColorB;
		r = self.m_textColorR;
		g = self.m_textColorG;
		b = self.m_textColorB;
	end

	TextView.setText(self,str,width,height,r,g,b);
end

EditTextView.getText = function(self)
	local text = TextView.getText(self);
	text = (text == self.m_hintText) and " " or text;
	return text;
end

EditTextView.setEnable = function(self, enable)
	self.m_enable = enable;
end

EditTextView.setMaxLength = function(self, maxLength)
	self.m_maxLength = maxLength;
end

EditTextView.setOnTextChange = function(self, obj, func)
	self.m_textChangeCallback.obj = obj;
	self.m_textChangeCallback.func = func;
end

EditTextView.onTextChange = function(self)
	if self.m_textChangeCallback.func then
		self.m_textChangeCallback.func(self.m_textChangeCallback.obj,EditTextView.getText(self));
	end
end

EditTextView.dtor = function(self)
	ime_close_edit();
end

---------------------------------private functions-----------------------------------------

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
		ime_open_edit(EditTextView.getText(self),
			"",
			self.m_inputMode,
			self.m_inputFlag,
			kKeyboardReturnTypeDone,
			self.m_maxLength or -1,"global_view");
    end
end

function event_ime_close_global_view(strNewValue, flag)
	if flag==1 and EditTextViewGlobal then
		EditTextViewGlobal.setText(EditTextViewGlobal,strNewValue);
		if (not strNewValue) or strNewValue == "" or strNewValue == EditTextViewGlobal.m_hintText then
			EditTextViewGlobal.setText(EditTextViewGlobal,EditTextViewGlobal.m_hintText,nil,nil,EditTextViewGlobal.m_hintTextColorR,EditTextViewGlobal.m_hintTextColorG,EditTextViewGlobal.m_hintTextColorB);
		else
			EditTextViewGlobal.setText(EditTextViewGlobal,strNewValue,nil,nil,EditTextViewGlobal.m_textColorR,EditTextViewGlobal.m_textColorG,EditTextViewGlobal.m_textColorB);
		end
		EditTextViewGlobal.onTextChange(EditTextViewGlobal);
	end
	EditTextViewGlobal = nil;
end
