-- groupNode.lua
-- Author: Vicent.Gong
-- Date: 2013-06-03
-- Last modification : 2013-07-05
-- Description: The base implement of RadioButton and CheckBox 

require("core/object");
require("core/global");
require("ui/node");
require("ui/images");

---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] RadioButtonGroup----------------------------------
---------------------------------------------------------------------------------------------

GroupNode = class(Node);

GroupNode.ctor = function(self)
	self.m_items = {};
	self.m_eventCallback = {};
end

GroupNode.addChild = function(self, item)
	if not typeof(item,GroupItem) then
		FwLog("The child adding to GroupNode is not a GroupItem");
		return;
	end

	self.m_items[#self.m_items+1] = item;
	Node.addChild(self,item);
	item:setGroup(self);
end

GroupNode.removeChild = function(self, item, doCleanup)
	local index = GroupNode.getItemIndex(self,item);
	if index then 
		item:setGroup(nil);
		Node.removeChild(self,item,doCleanup);
		table.remove(self.m_items,index);
	end
end

GroupNode.addItem = function(self, item)
	GroupNode.addChild(self,item);
end

GroupNode.removeItem = function(self, item, doCleanup)
	GroupNode.removeChild(self,item,doCleanup);
end

GroupNode.removeItemByIndex = function(self, index, doCleanup)
	if not (index and self.m_items[index]) then
		return;
	end

	local ret = self.m_items[index];
	GroupNode.removeChild(self,self.m_items[index],doCleanup);
	return (not doCleanup) and ret or nil;
end

GroupNode.getItemIndex = function(self, item)
	for k,v in ipairs(self.m_items) do 
		if v == item then
			return k;
		end
	end
end

GroupNode.getItem = function(self, index)
	if index then
		return self.m_items[index];
	end
end

GroupNode.getResult = function(self)
	error("Derived classes must implement this function");
end

GroupNode.clear = function(self)
	for _,item in pairs(self.m_items) do 
		item:setChecked(false);
	end
end

GroupNode.setEnable = function(self, enable)
	for _,item in pairs(self.m_items) do 
		item:setEnable(enable);
	end
end

GroupNode.setOnChange = function(self, obj, func)
	self.m_eventCallback.obj = obj;
	self.m_eventCallback.func = func;
end

GroupNode.onItemClick = function(self, item)
	error("Derived classes must implement this function");
end

GroupNode.dtor = function(self)
	self.m_items = nil;
	self.m_eventCallback = nil;
end

---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] RadioButton---------------------------------------
---------------------------------------------------------------------------------------------

GroupItem = class(Images);

GroupItem.ctor = function(self, fileNameArray, fmt, filter, leftWidth, rightWidth, topWidth, bottomWidth)
	GroupItem.setEventTouch(self,self,self.onEventTouch);
	
	self.m_enable = true;
	self.m_checked = false;
end

GroupItem.addChild = function(self, child)
	Images.addChild(self,child);
	child:setEventTouch(self,self.onEventTouch);
end

GroupItem.setGroup = function(self, group)
	self.m_group = group;
end

GroupItem.setChecked = function(self, checked)
	if self.m_checked == checked then 
		return;
	end
	
	self.m_checked = checked;
	GroupItem.setImageIndex(self,checked and 1 or 0);
end

GroupItem.isChecked = function(self)
	return self.m_checked;
end

GroupItem.dtor = function(self)

end

GroupItem.setEnable = function(self, enable)
	self.m_enable = enable;
end

---------------------------------private functions-----------------------------------------

GroupItem.onEventTouch = function(self, finger_action, x, y, drawing_id_first, drawing_id_last)
	if not self.m_enable then return end;
	
    if finger_action == kFingerUp and drawing_id_first == drawing_id_last then  
		if self.m_group then
			self.m_group.onItemClick(self.m_group,self);
		end
    end
end
