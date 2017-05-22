require("core/object");
require("core/gameString");

require("ui/node");
require("ui/image");
require("ui/images");
require("ui/button");
require("ui/text");
require("ui/textView");
require("ui/editText");
require("ui/editTextView");
require("ui/slider");
require("ui/switch");
require("ui/tableView");
require("ui/listView");
require("ui/viewPager");
require("ui/gridView");
require("ui/scrollView");
require("ui/tabView");
require("ui/toast");
require("ui/checkBox");
require("ui/radioButton");
require("ui/adapter");
require("ui/customNode");

UIFactory = class();

UIFactory.createNode = function()
	local node = new(Node);
	return node;
end

UIFactory.createImage = function(file, fmt, filter, leftWidth, rightWidth, topWidth, bottomWidth)
	if not file then 
		return;
	end 

	local node = new(Image, file, fmt, filter, leftWidth, rightWidth, topWidth, bottomWidth);
	return node;
end  

UIFactory.createImages = function(filenameArray, fmt, filter, leftWidth, rightWidth, topWidth, bottomWidth)
	if not filenameArray or #filenameArray <= 0 then
		return;
	end 

	local node = new(Images, filenameArray, fmt, filter, leftWidth, rightWidth, topWidth, bottomWidth);
	return node;
end

UIFactory.createButton = function(normalFile, disableFile, fmt, filter, leftWidth, rightWidth, topWidth, bottomWidth)
	if not normalFile then 
		return;
	end 
	
	local node = new(Button, normalFile, disableFile, fmt, filter, leftWidth, rightWidth, topWidth, bottomWidth);
	return node;
end

UIFactory.createText = function(str, fontSize, width, height, align, r, g, b, fontName)
	return UIFactory.createTexts(Text, str, fontSize, width, height, align, r, g, b, fontName);
end

UIFactory.createTextView = function(str, fontSize, width, height, align, r, g, b, fontName)
	return UIFactory.createTexts(TextView, str, fontSize, width, height, align, r, g, b, fontName);
end

UIFactory.createEditText = function(str, fontSize, width, height, align, r, g, b, fontName)
	return UIFactory.createTexts(EditText, str, fontSize, width, height, align, r, g, b, fontName);
end

UIFactory.createEditTextView = function(str, fontSize, width, height, align, r, g, b, fontName)
	return UIFactory.createTexts(EditTextView, str, fontSize, width, height, align, r, g, b, fontName);
end

UIFactory.createSlider = function(width, height, bgImage, fgImage, buttonImage)
	local node = new(Slider, width, height, bgImage, fgImage, buttonImage);
	return node;
end

UIFactory.createSwitch = function(width, height, onFile, offFile, buttonFile)
	local node = new(Switch, width, height, onFile, offFile, buttonFile);
	return node;
end

UIFactory.createAdapter = function(view, data)
	return UIFactory.createAdapters(Adapter, view, data);
end

UIFactory.createCacheAdapter = function(view, data)
	return UIFactory.createAdapters(CacheAdapter, view, data);
end

UIFactory.createTableView = function(x, y, w, h, autoAlignToItemEdge, isMultiItems, view, data)
	return UIFactory.createTables(TableView,x, y, w, h, nil, view, data, autoAlignToItemEdge, isMultiItems);
end

UIFactory.createListView = function(x, y, w, h, adapter, view, data)
	return UIFactory.createTables(ListView,x, y, w, h, adapter, view, data);
end

UIFactory.createViewPager = function(x, y, w, h, adapter, view, data)
	return UIFactory.createTables(ViewPager,x, y, w, h, adapter, view, data);
end

UIFactory.createGridView = function(x, y, w, h, adapter, view, data) 
	return UIFactory.createTables(GridView,x, y, w, h, adapter, view, data);
end

UIFactory.createScrollView = function(x, y, w, h, autoPositionChildren)
	local node = new(ScrollView, x, y, w, h, autoPositionChildren);
	return node;
end

UIFactory.createCheckBoxGroup = function()
	local node = new(CheckBoxGroup);
	return node;
end

UIFactory.createCheckBox = function(fileNameArray, fmt, filter, leftWidth, rightWidth, topWidth, bottomWidth)
	local node = new(CheckBox, fileNameArray, fmt, filter, leftWidth, rightWidth, topWidth, bottomWidth);
	return node;
end

UIFactory.createRadioButtonGroup = function()
	local node = new(RadioButtonGroup);
	return node;
end

UIFactory.createRadioButton = function(fileNameArray, fmt, filter, leftWidth, rightWidth, topWidth, bottomWidth)
	local node = new(RadioButton, fileNameArray, fmt, filter, leftWidth, rightWidth, topWidth, bottomWidth);
	return node;
end

UIFactory.createTabView = function(x, y, w, h)
	local node = new(TabView, x, y, w, h)
	return node;
end 

UIFactory.createToast = function()
	local node = Toast.getInstance();
	return node;
end

UIFactory.releaseToast = function()	
	return Toast.releaseInstance();
end

UIFactory.createCustomNode = function(renderType, userDataType, vertices, indices, textureFile, textureCoords, colorArray)
	local node = new(CustomNode, renderType, userDataType, vertices, indices, textureFile, textureCoords, colorArray);
	return node;
end
------------------------------------ private --------------------------------------------------------------
UIFactory.createTexts = function(classType, str, fontSize ,width, height, align, r, g, b,fontName)
	if not str then 
		return;
	end 

	align = align or kAlignLeft;
	fontName = fontName or "";
	fontSize = fontSize or 24;
	r = r or 255;
	g = g or 255;
	b = b or 255;

	local node = new(classType, str, width, height, align, fontName, fontSize, r, g, b);
	return node;
end

UIFactory.createAdapters = function(classType, view, data)
	if not view or type(data) ~= "table" or #data <= 0 then 
		return;
	end 

	local node = new(classType, view, data);
	return node;
end

UIFactory.createTables = function(classType,x, y, w, h, adapter, view, data, ...)
	local node = new(classType, x, y, w, h, ...);
	adapter = adapter or UIFactory.createCacheAdapter(view,data);
	if adapter then 
		node:setAdapter(adapter);
	end 
	return node;
end  