-- radioButton.lua
-- Author: Vicent.Gong
-- Date: 2012-09-26
-- Last modification : 2013-07-05
-- Description: Implemented radio button 

require("core/object");
require("core/global");
require("ui/groupNode");

---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] RadioButtonGroup----------------------------------
---------------------------------------------------------------------------------------------

RadioButtonGroup = class(GroupNode);

RadioButtonGroup.addChild = function(self, item)
	GroupNode.addChild(self,item);
	if item:isChecked() then
		RadioButtonGroup.setSelected(self,RadioButtonGroup.getButtonIndex(self,item));
	end
end

RadioButtonGroup.addButton = function(self, button)
	return RadioButtonGroup.addItem(self,button);
end

RadioButtonGroup.removeButton = function(self, button, doCleanup)
	return RadioButtonGroup.removeItem(self,button,doCleanup);
end

RadioButtonGroup.removeButtonByIndex = function(self, index, doCleanup)
	return RadioButtonGroup.removeItemByIndex(self,index,doCleanup);
end

RadioButtonGroup.getButtonIndex = function(self, button)
	return RadioButtonGroup.getItemIndex(self,button);
end

RadioButtonGroup.getButton = function(self, index)
	return RadioButtonGroup.getItem(self,index);
end

RadioButtonGroup.setSelected = function(self, index)
	if not (index and self.m_items[index]) then
		return false;
	end

	local button = self.m_items[index];

	if (self.m_checkedButton == button) or (not button) then
		return false;
	end

	if self.m_checkedButton then
		self.m_checkedButton:setChecked(false);
	end
	button:setChecked(true);

	self.m_checkedButton = button;

	return true;
end

RadioButtonGroup.isSelected = function(self, index)
	if not (index and self.m_items[index]) then
		return;
	end

	self.m_items[index]:isChecked();
end

RadioButtonGroup.getResult = function(self)
	for k,button in ipairs(self.m_items) do 
		if button:isChecked() then
			return k;
		end
	end
end

RadioButtonGroup.clear = function(self)
	GroupNode.clear(self);
	self.m_checkedButton = nil;
end

RadioButtonGroup.onItemClick = function(self, button)
	local lastCheckButton = self.m_checkedButton;
	local index = RadioButtonGroup.getButtonIndex(self,button);
	local doSucceed = RadioButtonGroup.setSelected(self,index);

	if doSucceed and self.m_eventCallback.func then
		self.m_eventCallback.func(self.m_eventCallback.obj,
			 index,RadioButtonGroup.getButtonIndex(self,lastCheckButton));
	end
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] RadioButton---------------------------------------
---------------------------------------------------------------------------------------------

RadioButton = class(GroupItem,false);

RadioButton.s_defaultImages = {"ui/radioButton1.png","ui/radioButton2.png"};

RadioButton.setDefaultImages = function(images)
	RadioButton.s_images = images or RadioButton.s_defaultImages;
end

RadioButton.ctor = function(self, fileNameArray, fmt, filter, leftWidth, rightWidth, topWidth, bottomWidth)
	local array = fileNameArray or RadioButton.s_images or RadioButton.s_defaultImages;	
	super(self,array,fmt,filter,leftWidth,rightWidth,topWidth,bottomWidth);
end

RadioButton.setChecked = function(self, checked)
	if self.m_checked == checked then 
		return;
	end
	
	GroupItem.setChecked(self,checked);

	if self.m_group then
		self.m_group:setSelected(self.m_group:getButtonIndex(self));
	end
end
