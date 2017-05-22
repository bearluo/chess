--RadioCheckGroup.lua
--Date 
--radioButton 与 checkButton 结合
--endregion

require("core/object");
require("core/global");
require("ui/groupNode");

RadioCheckGroup = new(GroupNode)

function RadioCheckGroup.ctor(self)
	self.m_items = {};
	self.m_eventCallback = {};
end

function RadioCheckGroup.dtor(self)
    self.m_items = nil;
	self.m_eventCallback = nil;
end

function RadioCheckGroup.addButtonChild(self,item)
    return RadioCheckGroup.addItem(self,item);
end

function RadioCheckGroup.removeButton(self, item, doCleanup)
	return RadioCheckGroup.removeItem(self,item,doCleanup);
end

function RadioCheckGroup.removeButtonByIndex(self, index, doCleanup)
	return RadioCheckGroup.removeItemByIndex(self,index,doCleanup);
end

function RadioCheckGroup.getButtonIndex(self, item)
	return RadioCheckGroup.getItemIndex(self,item);
end

function RadioCheckGroup.getButton(self, index)
	return RadioCheckGroup.getItem(self,index);
end

function RadioCheckGroup.setSelected (self, index)
	if not (index and self.m_items[index]) then
		return false
	end
     
    local item = self.m_items[index]
    if not item then return false end

    if self.m_checkedButton and self.m_checkedButton == item then
        self.m_checkedButton:setChecked(false);
        self.m_checkedButton = nil
        return true
    end

    if self.m_checkedButton then
        self.m_checkedButton:setChecked(false);
    end
    item:setChecked(true)
    self.m_checkedButton = item

    return true
end

function RadioCheckGroup.getResult(self)
	for k,button in ipairs(self.m_items) do 
		if button:isChecked() then
			return k;
		end
	end
    return false;
end

function RadioCheckGroup.onItemClick(self, item)
	if not item then return end;
    local lastCheckButton = self.m_checkedButton;
	local index = RadioCheckGroup.getButtonIndex(self,item);
	local doSucceed = RadioCheckGroup.setSelected(self,index);

	if doSucceed and self.m_eventCallback.func then
		self.m_eventCallback.func(self.m_eventCallback.obj,
			 index,RadioButtonGroup.getButtonIndex(self,lastCheckButton));
	end
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] RadioCheckButton----------------------------------
---------------------------------------------------------------------------------------------

RadioCheckButton = class(GroupItem,false);

RadioCheckButton.s_defaultImages = {"ui/radioButton1.png","ui/radioButton2.png"};

function RadioCheckButton.setDefaultImages(images)
	RadioCheckButton.s_images = images or RadioCheckButton.s_defaultImages;
end

function RadioCheckButton.ctor(self, fileNameArray, fmt, filter, leftWidth, rightWidth, topWidth, bottomWidth)
	local array = fileNameArray or RadioCheckButton.s_images or RadioCheckButton.s_defaultImages; 
	super(self,array,fmt,filter,leftWidth,rightWidth,topWidth,bottomWidth);

--	self.m_changeCallback = {};
end

--RadioCheckButton.setOnChange = function(self, obj, func)
--	self.m_changeCallback.obj = obj;
--	self.m_changeCallback.func = func;
--end

function RadioCheckButton.setChecked(self, checked)
--    if finger_action == kFingerUp then 
--		if self.m_group then
--			self.m_group.onItemClick(self.m_group,self);
--		else
--			RadioCheckButton.setChecked(self,not self.m_checked);
--			if self.m_changeCallback.func then
--				self.m_changeCallback.func(self.m_changeCallback.obj,self.m_checked);
--			end
--		end
--    end
	
	GroupItem.setChecked(self,checked);

--	if self.m_group then
--		self.m_group:setSelected(self.m_group:getButtonIndex(self));
--	end
end

