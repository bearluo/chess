-- checkBox.lua
-- Author: Vicent Gong
-- Date: 2012-09-24
-- Last modification : 2013-07-05
-- Description: Implemented check box 

require("core/object");
require("core/global");
require("ui/groupNode");

---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] CheckBoxGroup-------------------------------------
---------------------------------------------------------------------------------------------

CheckBoxGroup = class(GroupNode);

CheckBoxGroup.addCheckBox = function(self, box)
	return CheckBoxGroup.addItem(self,box);
end

CheckBoxGroup.removeCheckBox = function(self, box, doCleanup)
	return CheckBoxGroup.removeItem(self,box,doCleanup);
end

CheckBoxGroup.removeCheckBoxByIndex = function(self, index, doCleanup)
	return CheckBoxGroup.removeItemByIndex(self,index,doCleanup);
end

CheckBoxGroup.getCheckBoxIndex = function(self, box)
	return CheckBoxGroup.getItemIndex(self,box);
end

CheckBoxGroup.getCheckBox = function(self, index)
	return CheckBoxGroup.getItem(self,index);
end

CheckBoxGroup.getResultPairs = function(self)
	local result = {};
	for k,box in ipairs(self.m_items) do
		result[k] = box:isChecked();
	end
	return result;
end

CheckBoxGroup.setChecked = function(self, index, doChecked)
	if not (index and self.m_items[index]) then
		return;
	end
	self.m_items[index]:setChecked(doChecked);
end

CheckBoxGroup.isChecked = function(self, index)
	if not (index and self.m_items[index]) then
		return;
	end

	return self.m_items[index]:isChecked();
end

CheckBoxGroup.getResult = function(self)
	local result = {};
	for k,box in ipairs(self.m_items) do 
		if box:isChecked() then
			result[#result+1] = k;
		end
	end
	
	return result;
end

CheckBoxGroup.onItemClick = function(self, box)
	if not box then return end;
	local index = CheckBoxGroup.getCheckBoxIndex(self,box);
	local isChecked = box:isChecked();

	CheckBoxGroup.setChecked(self,index,not isChecked);

	if self.m_eventCallback.func then
		self.m_eventCallback.func(self.m_eventCallback.obj,index,not isChecked);
	end
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] CheckBox------------------------------------------
---------------------------------------------------------------------------------------------

CheckBox = class(GroupItem,false);

CheckBox.s_defaultImages = {"ui/radioButton1.png","ui/radioButton2.png"}--{"ui/checkBox1.png","ui/checkBox2.png"};

CheckBox.setDefaultImages = function(images)
	CheckBox.s_images = images or CheckBox.s_defaultImages;
end

CheckBox.ctor = function(self, fileNameArray, fmt, filter, leftWidth, rightWidth, topWidth, bottomWidth)
	local array = fileNameArray or CheckBox.s_images or CheckBox.s_defaultImages; 
	super(self,array,fmt,filter,leftWidth,rightWidth,topWidth,bottomWidth);

	self.m_changeCallback = {};
end

CheckBox.setOnChange = function(self, obj, func)
	self.m_changeCallback.obj = obj;
	self.m_changeCallback.func = func;
end

CheckBox.onEventTouch = function(self, finger_action, x, y, drawing_id_first, drawing_id_last)
	if not self.m_enable then return end;
	
    if finger_action == kFingerUp then 
		if self.m_group then
			self.m_group.onItemClick(self.m_group,self);
		else
			CheckBox.setChecked(self,not self.m_checked);
			if self.m_changeCallback.func then
				self.m_changeCallback.func(self.m_changeCallback.obj,self.m_checked);
			end
		end
    end
end
