require("core/sceneLoader")
require("tmp")

local rootNode = nil;
function event_load ( width, height )
	anim_delete_group(-1);
	res_delete_group(-1);
	prop_delete_group(-1);
	drawing_delete_all();

	rootNode = SceneLoader.load(root);
end

function event_touch_raw ( finger_action, x, y, drawing_id)	  
 
end


-------------------------------------DrawingBase Interface---------------------------------------

function editor_getDrawingId()
	local time = dict_get_int("editor","time",0);

	local name = "editor" .. time;
	local node = _G[name];
	local drawingId = -1;
	if node ~= nil then
		drawingId = node.m_drawingID;
	end

	dict_set_int("editor","drawingId",drawingId);
end

function editor_setPos()
	local time = dict_get_int("editor","time",0);
	local x = dict_get_int("editor","x",0);
	local y = dict_get_int("editor","y",0);

	local name = "editor" .. time;
	local node = _G[name];
	if node ~= nil then
		node:setPos(x, y);
	end
end

function editor_setName()
	local time = dict_get_int("editor","time",0);
	local newName = dict_get_string("editor","newName") or "";

	local name = "editor" .. time;
	local node = _G[name];
	if node ~= nil then
		node:setName(newName);
	end
end

function editor_setLevel()
	local time = dict_get_int("editor","time",0);
	local level = dict_get_int("editor","level",0);

	local name = "editor" .. time;
	local node = _G[name];
	if node ~= nil then
		node:setLevel(level);
	end
end

function editor_addChild()
	local time = dict_get_int("editor","time",0);
	local childTime = dict_get_int("editor","childTime",0);

	local name = "editor" .. time;
	local childName = "editor" .. childTime;
	local node = _G[name];
	local childNode = _G[childName];
	if node ~= nil and childNode ~= nil then
		node:addChild(childNode);
	end
end

function editor_removeChild()
	local time = dict_get_int("editor","time",0);
	local childTime = dict_get_int("editor","childTime",0);

	local name = "editor" .. time;
	local childName = "editor" .. childTime;
	local node = _G[name];
	local childNode = _G[childName];
	if node ~= nil and childNode ~= nil then
		node:removeChild(childNode,true);
	end
end

------------------------------------- getNode function ------------------------------------------
function editor_getNode(node, drawingId)
	if node == nil then
		return;
	end

	if node.m_drawingID == drawingId then
		return node;
	end

	for _,v in pairs(node.m_children) do
		local childNode = editor_getNode(v, drawingId);
		if childNode ~= nil then
			return childNode;
		end
	end
end

------------------------------------- calcPos function ------------------------------------------
-- 计算移动后坐标位置 参照DrawingBase.revisePos函数，逆计算
-- moveX,moveY:屏幕显示相对父节点的相对坐标
-- return:实际相对父节点的相对坐标
function editor_calcSetPos()
	local moveX = dict_get_int("editor","moveX",0);
	local moveY = dict_get_int("editor","moveY",0);
	local drawingId = dict_get_int("editor","drawingId",0);
	local node = editor_getNode(rootNode, drawingId);
	if node == nil then
		dict_set_int("editor","newX",moveX);
		dict_set_int("editor","newY",moveY);
		return;
	end

	if node.m_fillRegion then-- or (node.m_fillParentWidth or node.m_fillParentHeight) then
		dict_set_int("editor","newX",moveX);
		dict_set_int("editor","newY",moveY);
		return;
	end

	local parentW,parentH;

	local parent = DrawingBase.getParent(node);
	if not parent then
		parentW = System.getScreenWidth();
		parentH = System.getScreenHeight();
	else
		parentW,parentH = DrawingBase.getRealSize(parent);
	end

	local w,h = DrawingBase.getRealSize(node);

	local newX = moveX;
	local newY = moveY;

	if node.m_align == kAlignTopLeft then
	elseif node.m_align == kAlignLeft then
		newY = moveY - (parentH - h)/2;
	elseif node.m_align == kAlignBottomLeft then
		newY = -moveY + (parentH - h);
	elseif node.m_align == kAlignTopRight then
		newX = -moveX + (parentW - w);
	elseif node.m_align == kAlignRight then
		newX = -moveX + (parentW - w);
		newY = moveY - (parentH - h)/2;
	elseif node.m_align == kAlignBottomRight then
		newX = -moveX + (parentW - w);
		newY = -moveY + (parentH - h);
	elseif node.m_align == kAlignTop then
		newX = moveX - (parentW - w)/2;
	elseif node.m_align == kAlignCenter then
		newX = moveX - (parentW - w)/2;
		newY = moveY - (parentH - h)/2;
	elseif node.m_align == kAlignBottom then
		newX = moveX - (parentW - w)/2;
		newY = -moveY + (parentH - h);
	end

	dict_set_int("editor","newX",newX);
	dict_set_int("editor","newY",newY);
end


-------------------------------------new Class Interface-----------------------------------------
function editor_getNodeTable()
	local t = {};

	local TypeInt,TypeDouble,TypeString,TypeData = 0,1,2,3;
	local num = dict_get_int("editor","num",0);
	for i=1,num do
		local name = dict_get_string("editor","name"..i) or "";
		local dataType = dict_get_int("editor","type"..i,0);
		if dataType == TypeInt then
			t[name] = dict_get_int("editor","value"..i,0);
		elseif dataType == TypeDouble then
			t[name] = dict_get_double("editor","value"..i,0);
		elseif dataType == TypeData then
			t[name] = loadstring("return "..dict_get_string("editor","value"..i))();
		else
			t[name] = dict_get_string("editor","value"..i) or "";
		end
	end

	return t;
end

function editor_newNode()
	local parentTime = dict_get_int("editor","parentTime",0);
	local parentName = "editor" .. parentTime;
	local parentNode = _G[parentName];

	local t = editor_getNodeTable();
	
	local node;
	if t.type > 0 then
		node = SceneLoader.loadUI(t);
	else
		node = SceneLoader.loadView(t);
	end

	local name = "editor" .. t.time;
	_G[name] = node;

	if parentNode ~= nil then
		parentNode:addChild(node);
	end

	return node;
end

function editor_reCreateNode()
	local time = dict_get_int("editor","time",0);
	local name = "editor" .. time;
	if _G[name] == nil then
		return;
	end

	local t = editor_getNodeTable();

	local node;
	if t.type > 0 then
		node = SceneLoader.loadUI(t);
	else
		node = SceneLoader.loadView(t);
	end

	local allChildren = _G[name]:removeAllChildren(false);
	for _,v in pairs(allChildren) do 
		node:addChild(v);
	end

	local parent = DrawingBase.getParent(_G[name]);
	if parent ~= nil then
		parent:removeChild(_G[name],true);
		parent:addChild(node);
	else --root node
		delete(_G[name]);
		node:addToRoot();
	end

	_G[name] = node;

	return node;
end


---------------------------------------pcak Interface--------------------------------------------
function editor_readPack()
	local packName = dict_get_string("editor","packName") or "";
	require(packName);

	local packTable = _G[string.format("%s_map",packName)];
	
	if packTable ~= nil then
		local num = 0;
		for k,v in pairs(packTable) do
			num = num + 1;

			dict_set_string("editor","name"..num,k);
			dict_set_string("editor","file"..num,v.file);
			dict_set_int("editor","x"..num,v.x);
			dict_set_int("editor","y"..num,v.y);
			dict_set_int("editor","width"..num,v.width);
			dict_set_int("editor","height"..num,v.height);
		end
		dict_set_int("editor","num",num);
	end
end


---------------------------------------engine Interface------------------------------------------
function editor_res_delete()
	local iResId = dict_get_int("editor","iResId",0);
	res_delete(iResId);
end

function editor_res_create_text_image()
	local iGroup = dict_get_int("editor","iGroup",0);
	local iResId = dict_get_int("editor","iResId",0);
	local strText = dict_get_string("editor","strText") or "";
	local iWidth = dict_get_int("editor","iWidth",0);
	local iHeight = dict_get_int("editor","iHeight",0);
	local iRed255 = dict_get_int("editor","iRed255",0);
	local iGreen255 = dict_get_int("editor","iGreen255",0);
	local iBlue255 = dict_get_int("editor","iBlue255",0);
	local iAlign = dict_get_int("editor","iAlign",0);
	local strFont = dict_get_string("editor","strFont") or "";
	local iFontSize = dict_get_int("editor","iFontSize",0);
	local iMultiLine = dict_get_int("editor","iMultiLine",0);
	res_create_text_image(iGroup, iResId, strText, iWidth, iHeight, iRed255, iGreen255, iBlue255, iAlign, strFont, iFontSize, iMultiLine);
end

function editor_res_get_image_size()
	local iResId = dict_get_int("editor","iResId",0);
	local iWidth = res_get_image_width(iResId);
	local iHeight = res_get_image_height(iResId);
	dict_set_int("editor","iWidth",iWidth);
	dict_set_int("editor","iHeight",iHeight);
end

function editor_drawing_delete()
	local iDrawingId = dict_get_int("editor","iDrawingId",0);
	drawing_delete(iDrawingId);
end

function editor_drawing_create_image()
	local iGroup = dict_get_int("editor","iGroup",0);
	local iDrawingId = dict_get_int("editor","iDrawingId",0);
	local iResId = dict_get_int("editor","iResId",0);
	local x = dict_get_double("editor","x",0);
	local y = dict_get_double("editor","y",0);
	local fWidth = dict_get_double("editor","fWidth",0);
	local fHeight = dict_get_double("editor","fHeight",0);
	local iGrid9 = dict_get_int("editor","iGrid9",0);
	local iLeftWidth = dict_get_int("editor","iLeftWidth",0);
	local iRightWidth = dict_get_int("editor","iRightWidth",0);
	local iBottomWidth = dict_get_int("editor","iBottomWidth",0);
	local iTopWidth = dict_get_int("editor","iTopWidth",0);
	local iLevel = dict_get_int("editor","iLevel",0);

	local scale = System.getLayoutScale();
	drawing_create_image2(iGroup, iDrawingId, iResId, x, y,fWidth, fHeight,
						 iGrid9, iLeftWidth, iRightWidth, iBottomWidth, iTopWidth,
						 iLeftWidth * scale,iRightWidth * scale,iBottomWidth * scale,iTopWidth * scale, iLevel);
end

if drawing_create_image ~= drawing_create_image2 then
	drawing_create_image2 = drawing_create_image;

	DrawingImage.ctor = function(self, res, leftWidth, rightWidth, topWidth, bottomWidth)
		self.m_resID = res:getID();
		self.m_width = res:getWidth();
		self.m_height = res:getHeight();

		self.m_isGrid9 = (leftWidth and rightWidth and bottomWidth and topWidth) and true or false;
		
		local realWidth,realHeight = DrawingImage.getRealSize(self);

		leftWidth = leftWidth or 0;
		rightWidth = rightWidth or 0;
		bottomWidth = bottomWidth or 0;
		topWidth = topWidth or 0;
		local scale = System.getLayoutScale();
		drawing_create_image2(0, self.m_drawingID, self.m_resID,
								self.m_x, self.m_y, realWidth, realHeight, 
								self.m_isGrid9  and kTrue or kFalse, leftWidth,rightWidth,bottomWidth,topWidth, 
								leftWidth * scale,rightWidth * scale,bottomWidth * scale,topWidth * scale, 
								self.m_level);

		DrawingImage.setResRect(self,0,res);
	end	
end

if anim_set_event ~= anim_set_event2 then
	anim_set_event2 = anim_set_event;
end

---------------------------------------rewrite function------------------------------------------
RadioButtonGroup.removeChild = function(self, item, doCleanup)
	if item == self.m_checkedButton then
		self.m_checkedButton = nil;
	end
	GroupNode.removeChild(self, item, doCleanup);
end

Switch.removeAllChildren = function (self, doCleanup)
	Node.removeAllChildren(self, true);
	return {};
end

Slider.removeAllChildren = function (self, doCleanup)
	Node.removeAllChildren(self, true);
	return {};
end

function editor_IsNewSetClip()
	local buildDate = sys_get_int("build_date",0);
	local date = os.date("*t", buildDate);
	return (date.year >= 2015 and date.month >= 9 and date.day >= 1);
end

local testSetClip = function()
	local node = new(Node);
	node:setClip(0,0,1,1);
	delete(node);
end

if not pcall(function() testSetClip(); end) then
	--UIEditor:new setClip function   Engine:old setClip function
	if editor_IsNewSetClip() then
		DrawingBase.setClip = function(self, x, y, w, h)
			local posx,posy = self:getUnalignPos();
			local layoutScale = System.getLayoutScale();
			drawing_set_clip_rect(self.m_drawingID, 1, (x-posx)*layoutScale,(y-posy)*layoutScale,w*layoutScale,h*layoutScale);
		end
	end

	--UIEditor:old setClip function   Engine:new setClip function
	if not editor_IsNewSetClip() then
		DrawingBase.setClip = function(self, enable, x, y, w, h)
			local posx,posy = self:getUnalignPos();
			local layoutScale = System.getLayoutScale();
			drawing_set_clip_rect(self.m_drawingID, (x+posx)*layoutScale,(y+posy)*layoutScale,w*layoutScale,h*layoutScale);
		end
	end
end
