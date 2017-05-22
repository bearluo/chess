-- scene.lua
-- Author: Vicent Gong
-- Date: 2012-10-10
-- Last modification : 2012-11-21
-- Description: implement a class to prase scene lua info and create a scene

require("core/object")
require("core/gameString")
require("ui/node")
require("ui/button")
require("ui/button2")
require("ui/image")
require("ui/images")
require("ui/text")
require("ui/textView")
require("ui/editText")
require("ui/editTextView")
require("ui/listView")
require("ui/radioButton")
require("ui/checkBox")
require("ui/scrollView")
require("ui/scrollViewEx")
require("ui/slider")
require("ui/viewPager")

Scene = class();

Scene.ctor = function(self,t)
	if type(t) ~= "table" then
		return;
	end

	self.m_root = self:load(t);
end

Scene.registLoadFunc = function(name,func)
	Scene.loadFuncMap[name] = func;
end

Scene.getRoot = function(self)
	return self.m_root;
end

Scene.dtor = function(self)
	self:unload(self.m_root);
	delete(self.m_root);
end

Scene.load = function(self,t)
	local root;
	if t.type > 0 then
		root = self:loadUI(t);
	else
		root = self:loadView(t);
	end
	for _,v in ipairs(t) do
		local node = self:load(v);
		root:addChild(node);
	end
	root:addToRoot();
	return root;
end

------------------------------private functions, don't use these functions in your code ----------------------------------------------

Scene.loadUI = function(self,t)
	return Scene.loadFuncMap[t.typeName](self,t);
end

Scene.loadView = function(self,t)
	if not Scene.loadFuncMap[t.typeName] then
		return self:loadNilNode(t);
	end

	return Scene.loadFuncMap[t.typeName](self,t);
end

Scene.unload = function(self,node)

end



Scene.getResPath = function(self,t,filename)
	if not t.packFile then
		return filename;
	end

	local packFile = string.sub(t.packFile,1,string.find(t.packFile,".",1,true)-1);

	require(packFile);

	local findName = function(str)
		local pos;
		local found = 0;
		while found do
			pos = found;
			found = string.find(str,"/",pos+1,true);
		end

		if not pos then
			pos = 0;
		end
		return string.sub(str,pos+1);
	end

	local pitchName = findName(filename);
	local packName = findName(packFile);
	return _G[string.format("%s_map",packName)][pitchName];
end

Scene.getWH = function(self,t)
	local w = t.width>0 and t.width or nil;
	local h = t.height>0 and t.height or nil;
	return w,h;
end

Scene.setBaseInfo = function(self,node,t)
	node:setDebugName(t.typeName .. "|" .. t.name);
	node:setName(t.name or "");
	node:setPos(t.x,t.y);
	node:setSize(self:getWH(t));
	node:setVisible(t.visible==1 and true or false);
end

Scene.loadButton = function(self,t)
	local node = new(Button,self:getResPath(t,t.file),nil,nil,t.gridLeft,t.gridRight,t.gridTop,t.gridBottom);
	self:setBaseInfo(node,t);
	return node;
end

Scene.loadButton2 = function(self,t)
	local node = new(Button2,self:getResPath(t,t.file),self:getResPath(t,t.file2),nil,nil,t.gridLeft,t.gridRight,t.gridTop,t.gridBottom);
	self:setBaseInfo(node,t);
	return node;
end

Scene.loadImage = function(self,t)
	local node = new(Image,self:getResPath(t,t.file),nil,nil,t.gridLeft,t.gridRight,t.gridTop,t.gridBottom);
	self:setBaseInfo(node,t);
	return node;
end

Scene.loadText = function(self,t)
	local node = new(Text,t.string,t.width,t.height,t.align,"",t.fontSize,t.colorRed,t.colorGreen,t.colorBlue);
	node:setName(t.name or "");
	node:setPos(t.x,t.y);
	node:setVisible(t.visible==1 and true or false);
	return node;
end

Scene.loadTextView = function(self,t)
	local node = new(TextView,t.string,t.width,t.height,t.align,"",t.fontSize,t.colorRed,t.colorGreen,t.colorBlue);
	node:setName(t.name or "");
	node:setPos(t.x,t.y);
	node:setVisible(t.visible==1 and true or false);
	return node;
end

Scene.loadEditText = function(self,t)
	local node = new(EditText,t.string,t.width,t.height,t.align,"",t.fontSize,t.colorRed,t.colorGreen,t.colorBlue);
	node:setName(t.name or "");
	node:setPos(t.x,t.y);
	node:setVisible(t.visible==1 and true or false);
	return node;
end

Scene.loadEditTextView = function(self,t)
	local node = new(EditTextView,t.string,t.width,t.height,t.align,"",t.fontSize,t.colorRed,t.colorGreen,t.colorBlue);
	node:setName(t.name or "");
	node:setPos(t.x,t.y);
	node:setVisible(t.visible==1 and true or false);
	return node;
end

Scene.loadNilNode = function(self,t)
	local node = new(Node);
	self:setBaseInfo(node,t);
	return node;
end

Scene.loadCheckBoxGroup = function(self,t)
	local node = new(CheckBoxGroup);
	self:setBaseInfo(node,t);
	return node;
end

Scene.loadCheckBox = function(self,t)
	local param;
	if t.file and t.file2 then
		param = {t.file,t.file2};
	end
	local node = new(CheckBox,param);
	self:setBaseInfo(node,t);
	return node;
end

Scene.loadRadioButtonGroup = function(self,t)
	local node = new(RadioButtonGroup);
	self:setBaseInfo(node,t);
	return node;
end

Scene.loadRadioButton = function(self,t)
	local param;
	if t.file and t.file2 then
		param = {t.file,t.file2};
	end
	local node = new(RadioButton,param);
	self:setBaseInfo(node,t);
	return node;
end

Scene.loadScrollView = function(self,t)
	local node = new(ScrollView,t.x,t.y,t.width,t.height);
	self:setBaseInfo(node,t);
	return node;
end

Scene.loadScrollViewEx = function(self,t)
	local node = new(ScrollViewEx,t.x,t.y,t.width,t.height);
	self:setBaseInfo(node,t);
	return node;
end

Scene.loadSlider = function(self,t)
	local node = new(Slider,t.x,t.y,t.width);
	self:setBaseInfo(node,t);
	return node;
end

Scene.loadFuncMap = {
		[""]=				Scene.loadNilNode;
		["Button"]=		    Scene.loadButton;
		["Button2"]=		Scene.loadButton2;  
		["Image"]=			Scene.loadImage;
		["Text"]=			Scene.loadText;
		["TextView"]=		Scene.loadTextView;
		["EditText"]=		Scene.loadEditText;
		["EditTextView"]=	Scene.loadEditTextView;
		["CheckBoxGroup"]=	Scene.loadCheckBoxGroup;
		["CheckBox"]=		Scene.loadCheckBox;
		["RadioButtonGroup"]=	Scene.loadRadioButtonGroup;
		["RadioButton"]=	Scene.loadRadioButton;
		["ScrollView"]=		Scene.loadScrollView;
		["ScrollViewEx"]=		Scene.loadScrollViewEx;
		["Slider"]=			Scene.loadSlider;
};

