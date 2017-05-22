-- editText.lua
-- Author: Vicent Gong
-- Date: 2012-09-27
-- Last modification : 2013-07-04
-- Description: Implement a single line edit text field

require("core/object");
require("core/global");
require("ui/text");

EditText = class(Text);

EditText.s_defaultHintText = "";
EditText.s_defaultHintTextColorR = 128;
EditText.s_defaultHintTextColorG = 128;
EditText.s_defaultHintTextColorB = 128;

EditText.s_defaultMaxClickOffset = 5;

EditText.setDefaultHintText = function(hintText, r, g, b)
	EditText.s_hintText = hintText or EditText.s_defaultHintText;
	EditText.s_hintTextColorR = r or EditText.s_defaultHintTextColorR;
	EditText.s_hintTextColorG = g or EditText.s_defaultHintTextColorG;
	EditText.s_hintTextColorB = b or EditText.s_defaultHintTextColorB;
end

EditText.setDefaultMaxClickOffset = function(maxClickOffset)
	EditText.s_maxClickOffset = maxClickOffset or EditText.s_defaultMaxClickOffset;
end

EditText.ctor = function(self, str, width, height, align, fontName, fontSize, r, g, b)
	self.m_textColorR = r or 0;
	self.m_textColorG = g or 0;
	self.m_textColorB = b or 0;

	self.m_hintText = EditText.s_hintText or EditText.s_defaultHintText;
	self.m_hintTextColorR = EditText.s_hintTextColorR or EditText.s_defaultHintTextColorR;
	self.m_hintTextColorG = EditText.s_hintTextColorG or EditText.s_defaultHintTextColorG;
	self.m_hintTextColorB = EditText.s_hintTextColorB or EditText.s_defaultHintTextColorB;

	self.m_maxClickOffset = EditText.s_maxClickOffset or EditText.s_defaultMaxClickOffset;
	
	EditText.setEventTouch(self,self,self.onEventTouch);

	self.m_textChangeCallback = {};

	self.m_enable = true;

	self.m_inputMode = kEditBoxInputModeSingleLine;
	self.m_inputFlag = kEditBoxInputFlagInitialCapsSentence;

    self.mClipW,self.mClipH = self:getSize();
    self:setClip(0,0,self.mClipW,self.mClipH);
end

function EditText:setPos(x,y)
    Text.setPos(self,x,y)
    local x,y = self:getUnalignPos()
    self:setClip(x,y,self.mClipW,self.mClipH);
end

EditText.setInputMode = function(self,mode)
	self.m_inputMode = mode;
end

EditText.setInputFlag = function(self,flag)
	self.m_inputFlag = flag;
end

EditText.setHintText = function(self, str, r, g, b)
	str = EditText.convert2SafePlatformString(self,str);
	
	self.m_hintText = str or EditText.s_hintText or EditText.s_defaultHintText;
    self.m_hintTextColorR = r or EditText.s_hintTextColorR or EditText.s_defaultHintTextColorR;
	self.m_hintTextColorG = g or EditText.s_hintTextColorG or EditText.s_defaultHintTextColorG;
	self.m_hintTextColorB = b or EditText.s_hintTextColorB or EditText.s_defaultHintTextColorB;
	
	local text = EditText.getText(self);
	if text == "" then
		EditText.setText(self,str,nil,nil,self.m_hintTextColorR,self.m_hintTextColorG,self.m_hintTextColorB);
    end
end

EditText.setMaxClickOffset = function(self, offset)
	self.m_maxClickOffset = offset 
						or EditText.s_maxClickOffset 
						or EditText.s_defaultMaxClickOffset;
end

EditText.setText = function(self, str, width, height, r, g, b)
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
	
	Text.setText(self,str,width,height,r,g,b);
end

EditText.getText = function(self)
	local text = Text.getText(self);
	text = (text == self.m_hintText) and "" or text;
	return text;
end

EditText.setEnable = function(self, enable)
	self.m_enable = enable;
end

EditText.setMaxLength = function(self, maxLength)
	self.m_maxLength = maxLength;
end

EditText.setOnTextChange = function(self, obj, func)
	self.m_textChangeCallback.obj = obj;
	self.m_textChangeCallback.func = func;
end

EditText.onTextChange = function(self)
	if self.m_textChangeCallback.func then
		self.m_textChangeCallback.func(self.m_textChangeCallback.obj,EditText.getText(self));
	end
end

EditText.dtor = function(self)
	ime_close_edit();
end

---------------------------------private functions-----------------------------------------

EditText.onEventTouch = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
	if finger_action == kFingerDown then
	    self.m_startX = x;
	    self.m_startY = y;
	    self.m_touching = true;
	elseif finger_action == kFingerUp and drawing_id_first == drawing_id_current then
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
		ime_open_edit(EditText.getText(self),
			"",
			self.m_inputMode,
			self.m_inputFlag,
			kKeyboardReturnTypeDone,
			self.m_maxLength or -1,"global");
    else
        self.m_touching = false;
    end
end

function event_ime_close_global(strNewValue, flag)
	if flag==1 and EditTextGlobal then
		EditTextGlobal.setText(EditTextGlobal,strNewValue);
		if (not strNewValue) or strNewValue == "" or strNewValue == "" or strNewValue == EditTextGlobal.m_hintText then
			EditTextGlobal.setText(EditTextGlobal,EditTextGlobal.m_hintText,nil,nil,EditTextGlobal.m_hintTextColorR,EditTextGlobal.m_hintTextColorG,EditTextGlobal.m_hintTextColorB);
		else
			EditTextGlobal.setText(EditTextGlobal,strNewValue,nil,nil,EditTextGlobal.m_textColorR,EditTextGlobal.m_textColorG,EditTextGlobal.m_textColorB);
		end
		EditTextGlobal.onTextChange(EditTextGlobal);
	end
	EditTextGlobal = nil;
end
