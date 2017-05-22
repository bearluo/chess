-- sceneLoader.lua
-- Author: Vicent Gong
-- Date: 2012-10-10
-- Last modification : 2013-06-24
-- Description: implement a class to prase scene lua info and create a scene

require("core/object");
require("core/gameString");
require("ui/node");
require("ui/button");
require("ui/image");
require("ui/images");
require("ui/text");
require("ui/textView");
require("ui/editText");
require("ui/editTextView");
require("ui/listView");
require("ui/radioButton");
require("ui/checkBox");
require("ui/scrollView");
require("ui/slider");
require("ui/switch");
require("ui/viewPager");

SceneLoader = class();

SceneLoader.registLoadFunc = function(name, func)
	SceneLoader.loadFuncMap[name] = func;
end

SceneLoader.load = function(t)
	if type(t) ~= "table" then
		return;
	end

	local root;
	if t.type > 0 then
		root = SceneLoader.loadUI(t);
	else
		root = SceneLoader.loadView(t);
	end

	local name = "editor" .. t.time;
	_G[name] = root;

	for _,v in ipairs(t) do
		local node = SceneLoader.load(v);
		root:addChild(node);
	end
	root:addToRoot();
	return root;
end

----------------------------private functions, don't use these functions in your code ------------------------

SceneLoader.loadUI = function(t)
	local node = SceneLoader.loadFuncMap[t.typeName](t);
	if node ~= nil and t.effect ~= nil and typeof(node, DrawingImage) then
		local ShaderManager = require("core/shaderManager");
		ShaderManager.getInstance().addShader(node, t.effect.shader, t.effect);
	end
	return node;
end

SceneLoader.loadView = function(t)
	if not SceneLoader.loadFuncMap[t.typeName] then
		return SceneLoader.loadNilNode(t);
	end

	return SceneLoader.loadUI(t);
end

SceneLoader.loadButton = function(t)
	local node = new(Button,SceneLoader.getResPath(t,t.file),SceneLoader.getResPath(t,t.file2),nil,nil,t.gridLeft,t.gridRight,t.gridTop,t.gridBottom);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadImage = function(t)
	local node = new(Image,SceneLoader.getResPath(t,t.file),t.fmt,t.filter,t.gridLeft,t.gridRight,t.gridTop,t.gridBottom);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadText = function(t)
	local node = new(Text,t.string,t.width,t.height,t.textAlign or t.align,t.fontName,t.fontSize,t.colorRed,t.colorGreen,t.colorBlue);
	node:setName(t.name or "");
	node:setPos(t.x,t.y);
	node:setAlign(t.nodeAlign);
	node:setVisible(t.visible==1 and true or false);
	return node;
end

SceneLoader.loadTextView = function(t)
	local node = new(TextView,t.string,t.width,t.height,t.textAlign or t.align,t.fontName,t.fontSize,t.colorRed,t.colorGreen,t.colorBlue);
	node:setName(t.name or "");
	node:setPos(t.x,t.y);
	node:setAlign(t.nodeAlign);
	node:setVisible(t.visible==1 and true or false);
	return node;
end

SceneLoader.loadEditText = function(t)
	local node = new(EditText,t.string,t.width,t.height,t.textAlign or t.align,t.fontName,t.fontSize,t.colorRed,t.colorGreen,t.colorBlue);
	node:setName(t.name or "");
	node:setPos(t.x,t.y);
	node:setAlign(t.nodeAlign);
	node:setVisible(t.visible==1 and true or false);
	return node;
end

SceneLoader.loadEditTextView = function(t)
	local node = new(EditTextView,t.string,t.width,t.height,t.textAlign or t.align,t.fontName,t.fontSize,t.colorRed,t.colorGreen,t.colorBlue);
	node:setName(t.name or "");
	node:setPos(t.x,t.y);
	node:setAlign(t.nodeAlign);
	node:setVisible(t.visible==1 and true or false);
	return node;
end

SceneLoader.loadNilNode = function(t)
	local node = new(Node);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadCheckBoxGroup = function(t)
	local node = new(CheckBoxGroup);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadCheckBox = function(t)
	local param;
	if t.file and t.file2 then
		param = {t.file,t.file2};
	end
	local node = new(CheckBox,param);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadRadioButtonGroup = function(t)
	local node = new(RadioButtonGroup);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadRadioButton = function(t)
	local param;
	if t.file and t.file2 then
		param = {t.file,t.file2};
	end
	local node = new(RadioButton,param);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadAutoScrollView = function(t)
	local node = new(ScrollView,t.x,t.y,t.width,t.height,true);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadScrollView = function(t)
	local node = new(ScrollView,t.x,t.y,t.width,t.height);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadSlider = function(t)
	local node = new(Slider,t.width,t.height,t.bgFile,t.fgFile,t.buttonFile);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadSwitch = function(t)
	local node = new(Switch,t.width,t.height,t.onFile,t.offFile,t.buttonFile);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadListView = function(t)
	local node = new(ListView,t.x,t.y,t.width,t.height);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadViewPager = function(t)
	local node = new(ViewPager,t.x,t.y,t.width,t.height);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.getResPath = function(t, filename)
	if not filename then
		return filename;
	end

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

SceneLoader.getWH = function(t)
	local w = t.width>0 and t.width or nil;
	local h = t.height>0 and t.height or nil;
	return w,h;
end

SceneLoader.setBaseInfo = function(node, t)
	node:setDebugName(t.typeName .. "|" .. t.name);
	node:setName(t.name or "");
    node:setFillParent(t.fillParentWidth==1 and true or false,
						 t.fillParentHeight==1 and true or false);
	 if t.fillTopLeftX and t.fillTopLeftY 
		 and t.fillBottomRightX and t.fillBottomRightY then
		 node:setFillRegion(true,t.fillTopLeftX,t.fillTopLeftY,
			 t.fillBottomRightX,t.fillBottomRightY);
	 end
	node:setPos(t.x,t.y);
	node:setAlign(t.nodeAlign);
	node:setSize(SceneLoader.getWH(t));
	node:setVisible(t.visible==1 and true or false);
end

SceneLoader.loadFuncMap = {
	[""]					= SceneLoader.loadNilNode;
	["Button"]				= SceneLoader.loadButton;
	["Button2"]				= SceneLoader.loadButton2;
	["Image"]				= SceneLoader.loadImage;
	["Text"]				= SceneLoader.loadText;
	["TextView"]			= SceneLoader.loadTextView;
	["EditText"]			= SceneLoader.loadEditText;
	["EditTextView"]		= SceneLoader.loadEditTextView;
	["CheckBoxGroup"]		= SceneLoader.loadCheckBoxGroup;
	["CheckBox"]			= SceneLoader.loadCheckBox;
	["RadioButtonGroup"]	= SceneLoader.loadRadioButtonGroup;
	["RadioButton"]			= SceneLoader.loadRadioButton;
	["AutoScrollView"]		= SceneLoader.loadAutoScrollView;
	["ScrollView"]			= SceneLoader.loadScrollView;
	["Slider"]				= SceneLoader.loadSlider;
	["Switch"]				= SceneLoader.loadSwitch;
	["ListView"]			= SceneLoader.loadListView;
	["ViewPager"]			= SceneLoader.loadViewPager;
};

