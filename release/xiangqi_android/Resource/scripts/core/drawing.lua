-- drawing.lua
-- Author: Vicent Gong
-- Date: 2012-09-21
-- Last modification : 2013-08-08
-- Description: provide basic wrapper for drawing

require("core/object");
require("core/constants");
require("core/anim");
require("core/prop");
require("core/system");
require("core/global");
local easing = require('libEffect.easing')
require("core/drawingPatch20");

---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] DrawingBase---------------------------------------
---------------------------------------------------------------------------------------------

DrawingBase = class();

property(DrawingBase,"m_drawingID","ID",true,false);
DrawingBase.s_ref_count = 0
DrawingBase.ctor = function(self)
    self.m_is_release = false
    DrawingBase.s_ref_count = DrawingBase.s_ref_count + 1
    self.m_drawingID = drawing_alloc_id();
    self.m_align = kAlignTopLeft;
	self.m_x = 0;
	self.m_y = 0;
	self.m_width = 0;
	self.m_height = 0;
	self.m_alignX = 0;
	self.m_alignY = 0;
	
	self.m_r = 255;
	self.m_g = 255;
	self.m_b = 255;
	self.m_alpha = 1.0;
	
	self.m_visible = true;

	self.m_pickable = true;

	self.m_level = 0;

	self.m_children = {};
	self.m_rchildren = {};
	
	self.m_props = {};

	self.m_eventCallbacks = {
		touch = {};
		drag = {};
		doubleClick = {};
		focus = {};
	};

end

DrawingBase.dtor = function(self)
	--This is safe, only because the drawing is going to release;
	--Otherwise it should remove the prop first then release it.
	delete(self.m_doubleClickAnim);
	self.m_doubleClickAnim = nil;
	
	for k,v in pairs(self.m_props) do 
		delete(v["prop"]);
		for _,anim in pairs(v["anim"]) do 
			delete(anim);
		end
	end
	self.m_props = {};
	
    for _,v in pairs(self.m_children) do 
        delete(v);
    end
    self.m_children = {};
    self.m_rchildren  = {};

    if self.m_parent then
		DrawingBase.removeChild(self.m_parent,self);
	end
    --[[
    self.m_touchEventCallbacks = {
		touch = {};
		drag = {};
		doubleClick = {};
		focus = {};
	};
    --]]
    self.m_eventCallbacks = {
		touch = {};
		drag = {};
		doubleClick = {};
		focus = {};
	};


    --This drawing_delete should actually be in derided class dtor,
    --It is here because the children release.
    --It is ugly but useful,so keep it for now.
    drawing_delete(self.m_drawingID);
    drawing_free_id(self.m_drawingID);
    if not self.m_is_release then
        self.m_is_release = true
        DrawingBase.s_ref_count = DrawingBase.s_ref_count - 1
    end
end

DrawingBase.setDebugName = function(self, name)
	drawing_set_debug_name(self.m_drawingID,name or "");
end

------------------------------------------Touch stuff ----------------------------------------------

DrawingBase.setPickable = function(self, pickable)
	self.m_pickable = pickable;
	drawing_set_pickable(self.m_drawingID,pickable and kTrue or kFalse);
end

DrawingBase.getPickable = function(self)
	return self.m_pickable;
end

--touch event
DrawingBase.setEventTouch = function(self, obj, func)
    -- print_string('DrawingBase.setEventTouch drawingId = ' .. tostring(self.m_drawingID) .. ' func = ' .. tostring(func) .. '.m_name = ' .. tostring(self.m_name) ..' stacktrace: ' .. debug.traceback())

	drawing_set_touchable(self.m_drawingID, 
		(func or self.m_registedDoubleClick) and kTrue or kFalse, 
		self, DrawingBase.touchEventHandler);

	self.m_eventCallbacks.touch.obj = obj;
	self.m_eventCallbacks.touch.func = func;
end

--drag event
DrawingBase.setEventDrag = function(self, obj, func)
    -- print_string('DrawingBase.setEventDrag  drawingId = ' .. tostring(self.m_drawingID) .. ' func = ' .. tostring(func) .. '.m_name = ' .. tostring(self.m_name) ..' stacktrace: ' .. debug.traceback())

	drawing_set_dragable(self.m_drawingID, func and kTrue or kFalse, self, DrawingBase.onEventDrag);

	self.m_eventCallbacks.drag.obj = obj;
	self.m_eventCallbacks.drag.func = func;
end

--double click
DrawingBase.setEventDoubleClick = function(self, obj, func)
	self.m_registedDoubleClick = func and true or false;

	self.m_eventCallbacks.doubleClick.obj = obj;
	self.m_eventCallbacks.doubleClick.func = func;

	drawing_set_touchable(self.m_drawingID,
		(self.m_eventCallbacks.touch.func or self.m_registedDoubleClick) and kTrue or kFalse, 
		self, self.touchEventHandler);
end

DrawingBase.setEventFocus = function(self, obj, func)
	self.m_eventCallbacks.focus.obj = obj;
	self.m_eventCallbacks.focus.func = func;
end

------------------------------------------pos and size----------------------------------------------

DrawingBase.setAlign = function(self, align)
	self.m_align = align or kAlignTopLeft;
	self:revisePos();
end

DrawingBase.setPos = function(self, x, y)
	self.m_alignX = x or self.m_alignX;
	self.m_alignY = y or self.m_alignY;
	
	if not (self.m_fillParentWidth and self.m_fillParentHeight) then
		self:revisePos();
	end
end

DrawingBase.getPos = function(self)
	local x = self.m_fillParentWidth and 0 or self.m_alignX;
	local y = self.m_fillParentHeight and 0 or self.m_alignY;

	return x,y;
end

DrawingBase.getUnalignPos = function(self)
	return self.m_x/System.getLayoutScale(),
		self.m_y/System.getLayoutScale();
end

DrawingBase.getAbsolutePos = function(self)
	return DrawingBase.convertPointToSurface(self,0,0);
end

DrawingBase.setSize = function(self, w, h) 
	self.m_width = w or self.m_width or 0;
	self.m_height = h or self.m_height or 0;

	if not (self.m_fillParentWidth and self.m_fillParentHeight) then
		self:reviseSize();
		self:revisePos();
	end
end

DrawingBase.setFillParent = function(self, doFillParentWidth, doFillParentHeight)
	self.m_fillParentWidth = doFillParentWidth;
	self.m_fillParentHeight = doFillParentHeight;
	
	self:reviseSize();
	self:revisePos();
end

DrawingBase.getFillParent = function(self)
	return self.m_fillParentWidth,self.m_fillParentHeight;
end

DrawingBase.setFillRegion = function(self, doFill, topLeftX, topLeftY, bottomRightX, bottomRightY)
	self.m_fillRegion = doFill;
	if self.m_fillRegion then
		self.m_fillRegionTopLeftX = topLeftX;
		self.m_fillRegionTopLeftY = topLeftY;
		self.m_fillRegionBottomRightX = bottomRightX;
		self.m_fillRegionBottomRightY = bottomRightY;
	end
	
	self:reviseSize();
	self:revisePos();
end

DrawingBase.getFillRegion = function(self)
	return self.m_fillRegion,self.m_fillRegionTopLeftX,self.m_fillRegionTopLeftY,
		self.m_fillRegionBottomRightX,self.m_fillRegionBottomRightY;
end

DrawingBase.getSize = function(self)
	if not (self.m_fillParentWidth or self.m_fillParentHeight or self.m_fillRegion) then
		return self.m_width,self.m_height;
	end

	if self.m_fillRegion then
		local w,h;
		if self.m_parent then
			w,h = self.m_parent:getSize();
		else
			w,h = System.getScreenWidth()/System.getLayoutScale(),
				System.getScreenHeight()/System.getLayoutScale();
		end

		w = w - self.m_fillRegionTopLeftX - self.m_fillRegionBottomRightX;
		h = h - self.m_fillRegionTopLeftY - self.m_fillRegionBottomRightY;

		return w,h;
	end

	if self.m_fillParentWidth and self.m_fillParentHeight then
		if self.m_parent then
			return self.m_parent:getSize();
		else
			return System.getScreenWidth()/System.getLayoutScale(),
				System.getScreenHeight()/System.getLayoutScale();
		end
	end

	local w= self.m_width;
	local h = self.m_height;

	if self.m_fillParentWidth then
		if self.m_parent then
			w = self.m_parent:getSize();
		else
			w = System.getScreenWidth()/System.getLayoutScale();
		end
	end

	if self.m_fillParentHeight then
		if self.m_parent then
			_,h = self.m_parent:getSize();
		else
			h = System.getScreenHeight()/System.getLayoutScale();
		end
	end

	return w,h;
end

------------------------------------------color ----------------------------------------------

DrawingBase.setColor = function(self, r, g, b)
	self.m_r = r or self.m_r;
	self.m_g = g or self.m_g;
	self.m_b = b or self.m_b;

	drawing_set_color(self.m_drawingID, self.m_r, self.m_g, self.m_b);
end

DrawingBase.getColor = function(self)
	return self.m_r, self.m_g, self.m_b;
end

DrawingBase.setTransparency = function(self, val)
	self.m_alpha = val or self.m_alpha;
	local enable = (val>=0) and kTrue or kFalse;
	
	drawing_set_transparency(self.m_drawingID, enable, self.m_alpha);
end

DrawingBase.getTransparency = function(self)
	return self.m_alpha;
end

------------------------------------------ visible ----------------------------------------------

DrawingBase.setVisible = function(self, visible)
	self.m_visible = visible and true or false;
    drawing_set_visible(self.m_drawingID,self.m_visible and kTrue or kFalse);
end

DrawingBase.getVisible = function(self)
	return self.m_visible;
end

------------------------------------------ level ------------------------------------------------

DrawingBase.setLevel = function(self, level)
	self.m_level = level or self.m_level;
    drawing_set_level(self.m_drawingID, level);
end

DrawingBase.getLevel = function(self)
	return self.m_level;
end

------------------------------------------ name ------------------------------------------------

DrawingBase.setName = function(self, name)
	self.m_name = name;
	drawing_set_name(self.m_drawingID,name);
end

DrawingBase.getName = function(self)
	return self.m_name;
end

DrawingBase.getFullName = function(self)
	return DrawingBase.getRelativeName(self,nil);
end

DrawingBase.getRelativeName = function(self, relativeRoot)
	local ret = {};
	local drawing = self;
	while drawing and drawing ~= relativeRoot do 
		ret[#ret+1] = drawing:getName();
		drawing = drawing:getParent();
	end

	if drawing ~= relativeRoot then
		return nil;
	end

	if relativeRoot then
		ret[#ret+1] = relativeRoot:getName();
	end

	local nNames = #ret;
	for i=1,math.floor(nNames/2) do 
		ret[i],ret[nNames+1-i] = ret[nNames+1-i],ret[i];
	end

	return ret;
end

------------------------------------------ clip ------------------------------------------------
--[Comment]
--在这个方法为兼容，不进行缩放
--2015_08_27日/31日/9月1日/9月11日
--覆盖boyaa20.dll/libboyaa20.so***###@@@本次更新后，lua接口不兼容!!!

--drawing_set_clip_rect ( drawingId, x,y,w,h )
--增加了一个参数，改为：drawing_set_clip_rect ( drawingId,enable, x,y,w,h )
--不再兼容之前的用法***###@@@!!!
--旧版接口是以drawingId父节点的坐标(0,0)为基准来裁剪；而新版是以当前drawingId的坐标(0,0)为基准来裁剪;
--同时新版修复了裁剪的一些bug
function DrawingBase:setClip(x, y, w, h)
    local childX, childY = self:getUnalignPos();
    x = x - childX;
    y = y - childY;
	local layoutScale = System.getLayoutScale();
    local flag = pcall(function()
		drawing_set_clip_rect(self.m_drawingID, kTrue, 
			x*layoutScale,y*layoutScale,w*layoutScale,h*layoutScale);
		end);
    if not flag then
        drawing_set_clip_rect(self.m_drawingID,
    	    x*layoutScale,
            y*layoutScale,
            w*layoutScale,
            h*layoutScale);
    end
end

DrawingBase.setClipRes = function(self, res)
	if not res then
		drawing_set_clip_res(self.m_drawingID,kFalse,-1);
	else
		drawing_set_clip_res(self.m_drawingID,kTrue,res:getID());
	end
end

------------------------------------------ child ------------------------------------------------

DrawingBase.addChild = function(self, child)
	if not child then
		return;
	end
	
	if child.m_parent then
		child.m_parent:removeChild(child);
	end
		
	local ret = child:setParent(self); 
	--local ret = drawing_set_parent(child.m_drawingID,self.m_drawingID);
	
	local index = #self.m_children+1;
	self.m_children[index] = child;
	self.m_rchildren[child] = index;
	--child.m_parent = self;

	--child:revisePos();

	return ret;
end

DrawingBase.removeChild = function(self, child, doCleanup)
	local ret = child:setParent();
	--local ret = drawing_set_parent(child.m_drawingID,0);

	local index = self.m_rchildren[child];
	if self.m_rchildren[child] then
	self.m_rchildren[child] = nil;
	end
	
	if self.m_children[index] then
	self.m_children[index] = nil;
	end
	--child.m_parent = nil;

	if doCleanup then
		delete(child);
	end

	return ret == 0;
end

DrawingBase.removeAllChildren = function(self, doCleanup)
	doCleanup = (doCleanup == nil) or doCleanup; -- default is true

	local allChildren = {};
	for _,v in pairs(self.m_children) do 
        DrawingBase.removeChild(self,v);
        if doCleanup then
        	delete(v);
        else
        	allChildren[#allChildren+1] = v;
        end
    end
    self.m_children = {};
    self.m_rchildren  = {};

    if not doCleanup then
    	return allChildren;
    end
end

DrawingBase.getParent = function(self)
	return self.m_parent;
end

DrawingBase.getChildren = function(self)
	return self.m_children;
end

DrawingBase.addToRoot = function(self)
	if self.m_parent then
		self.m_parent:removeChild(self);
	end
	self:setParent();
	--drawing_set_parent(self.m_drawingID,0);

	--self:revisePos();
end

DrawingBase.getChildByName = function(self, name)
	for _,v in pairs(self.m_children) do 
		if v.m_name == name then
			return v;
		end
	end
end

------------------------------------------ point convert -------------------------------------------

-- convert local pos to global pos ,vice versa
DrawingBase.convertPointToSurface = function(self, x, y)
	local newX = drawing_convert_x_to_surface(self.m_drawingID,x*System.getLayoutScale() or 0);
	local newY = drawing_convert_y_to_surface(self.m_drawingID,y*System.getLayoutScale() or 0);
	
	return newX/System.getLayoutScale(),newY/System.getLayoutScale();
end

DrawingBase.convertSurfacePointToView = function(self, x, y)
	local newX = drawing_convert_x_to_surface(self.m_drawingID,0);
	local newY = drawing_convert_y_to_surface(self.m_drawingID,0);
	
	return x-newX/System.getLayoutScale(),y-newY/System.getLayoutScale();
end

DrawingBase.setScreenRelative = function(self, enable)
	drawing_set_screen_relative(self.m_drawingID,enable and kTrue or kFalse);
end

------------------------------------------ props ----------------------------------------------

DrawingBase.addProp = function(self, prop, sequence)
    local ret = drawing_prop_add(self.m_drawingID, prop:getID(), sequence);
	return ret == 0;
end

DrawingBase.removeProp = function(self, sequence)
    if drawing_prop_remove(self.m_drawingID, sequence) ~= 0 then
    	return false;
    end

	if self.m_props[sequence] then
		delete(self.m_props[sequence]["prop"]);
		for _,v in pairs(self.m_props[sequence]["anim"]) do 
			delete(v);
		end
		self.m_props[sequence] = nil;
	end
	return true;
end

DrawingBase.removePropByID = function(self, propId)
	if drawing_prop_remove_id(self.m_drawingID, propId) ~= 0 then
		return false;
	end

	for k,v in pairs(self.m_props) do 
		if v["prop"]:getID() == propId then
			delete(v["prop"]);
			for _,anim in pairs(v["anim"]) do 
				delete(anim);
			end
			self.m_props[k] = nil;
			break;
		end
	end
	
	return true;
end

DrawingBase.addPropColor = function(self, sequence, animType, duration, delay, rStart, rEnd, gStart, gEnd, bStart, bEnd)
	return DrawingBase.addAnimProp(self,sequence,PropColor,nil,nil,nil,animType,duration,delay,rStart,rEnd,gStart,gEnd,bStart,bEnd);
end

DrawingBase.addPropTransparency = function(self, sequence, animType, duration, delay, startValue, endValue)
	return DrawingBase.addAnimProp(self,sequence,PropTransparency,nil,nil,nil,animType,duration,delay,startValue,endValue);
end

DrawingBase.addPropTransparencyWithEasing = function(self, sequence, animType, duration, delay, easingFunction, b, c)
    if animType == nil then 
        animType = kAnimNormal
    end 
    if duration == nil then 
        duration = 2000
    end 
    if delay == nil then 
        delay = 0
    end 
    local defaultEasingFn = 'easeInOutQuad'
    if easingFunction == nil then 
        easingFunction = defaultEasingFn
    end 
    if b == nil then 
        b = 0
    end 
    if c == nil then 
        c = 1
    end 
    local data = easing.getEaseArray(easingFunction, duration, b, c)
    local res = new(ResDoubleArray, data)
    local anim = new(AnimIndex, animType, 0, #data - 1, duration, res, delay)
    local prop = new(PropTransparency, anim)
    DrawingBase.doAddProp(self,prop,sequence,anim)
	return anim
end
DrawingBase.addPropTranslate = function(self, sequence, animType, duration, delay, startX, endX, startY, endY)
	local layoutScale = System.getLayoutScale();
	startX = startX and startX * layoutScale or startX;
	endX = endX and endX * layoutScale or endX;
	startY = startY and startY * layoutScale or startY;
	endY = endY and endY * layoutScale or endY;
	return DrawingBase.addAnimProp(self,sequence,PropTranslate,nil,nil,nil,animType,duration,delay,startX,endX,startY,endY);
end

DrawingBase.addPropTranslateWithEasing = function(self, sequence, animType, duration, delay, easingFunctionX, easingFunctionY, bX, cX, bY, cY)
    if animType == nil then 
        animType = kAnimNormal
    end 
    if duration == nil then 
        duration = 1000
    end 
    if delay == nil then 
        delay = 0
    end 
    local currentX, currentY = self:getPos()
    local defaultOffset = 600
    local defaultEasingFn = easing.fns.easeInCirc

    if easingFunctionX == nil then 
        easingFunctionX = defaultEasingFn
        if bX == nil then 
            bX = 0
        end 
        if cX == nil then 
            cX = defaultOffset
        end 
    end 
    if easingFunctionY == nil then 
        easingFunctionY = defaultEasingFn
        if bY == nil then 
            bY = 0
        end 
        if cY == nil then 
            cY = defaultOffset
        end 
    end 
    local dataX = easing.getEaseArray(easingFunctionX, duration, bX, cX)
    local resX = new(ResDoubleArray, dataX)
    local dataY = easing.getEaseArray(easingFunctionY, duration, bY, cY)
    local resY = new(ResDoubleArray, dataY)
    local animX = new(AnimIndex, animType, 0, #dataX - 1, duration, resX, delay)
    local animY = new(AnimIndex, animType, 0, #dataY - 1, duration, resY, delay)
    local prop = new(PropTranslate, animX, animY)
    DrawingBase.doAddProp(self,prop,sequence,animX,animY)
	return animX, animY
end
DrawingBase.addPropRotate = function(self, sequence, animType, duration, delay, startValue, endValue, center, x, y)
	local layoutScale = System.getLayoutScale();
	x = x and x * layoutScale or x;
	y = y and y * layoutScale or y;
	return DrawingBase.addAnimProp(self,sequence,PropRotate,center, x, y,animType,duration,delay,startValue,endValue);
end

DrawingBase.addPropRotateWithEasing = function(self, sequence, animType, duration, delay, easingFunction, b, c, center, x, y)
    if animType == nil then 
        animType = kAnimNormal
    end 
    if duration == nil then 
        duration = 400
    end 
    if delay == nil then 
        delay = 0
    end 
    local defaultEasingFn = 'easeOutExpo'
    if easingFunction == nil then 
        easingFunction = defaultEasingFn
    end 
    if b == nil then 
        b = 0
    end 
    if c == nil then 
        c = 360
    end 
    if center == nil then 
        center = kCenterDrawing
    end 
    local data = easing.getEaseArray(easingFunction, duration, b, c)
    local res = new(ResDoubleArray, data)
    local anim = new(AnimIndex, animType, 0, #data - 1, duration, res, delay)
    local prop = new(PropRotate, anim, center, x, y)
    DrawingBase.doAddProp(self,prop,sequence,anim)
	return anim
end
DrawingBase.addPropScale = function(self, sequence, animType, duration, delay, startX, endX, startY, endY, center, x, y)
	local layoutScale = System.getLayoutScale();
	x = x and x * layoutScale or x;
	y = y and y * layoutScale or y;
	return DrawingBase.addAnimProp(self,sequence,PropScale,center, x, y,animType,duration,delay,startX,endX,startY,endY);
end
DrawingBase.addPropScaleWithEasing = function(self, sequence, animType, duration, delay, easingFunctionX, easingFunctionY, b, c, center, x, y)
    if animType == nil then 
        animType = kAnimNormal
    end 
    if duration == nil then 
        duration = 400
    end 
    if delay == nil then 
        delay = 0
    end 
    local defaultEasingFn = 'easeOutExpo'
    if easingFunctionX == nil then 
        easingFunctionX = defaultEasingFn
    end 
    if easingFunctionY == nil then 
        easingFunctionY = defaultEasingFn
    end 
    if b == nil then 
        b = 0
    end 
    if c == nil then 
        c = 1
    end 
    local dataX = easing.getEaseArray(easingFunctionX, duration, b, c)
    local resX = new(ResDoubleArray, dataX)
    local dataY = easing.getEaseArray(easingFunctionY, duration, b, c)
    local resY = new(ResDoubleArray, dataY)
    local animX = new(AnimIndex, animType, 0, #dataX - 1, duration, resX, delay)
    local animY = new(AnimIndex, animType, 0, #dataY - 1, duration, resY, delay)
    if center == nil then 
        center = kCenterDrawing
    end 
    local prop = new(PropScale, animX, animY, center, x, y)
    DrawingBase.doAddProp(self,prop,sequence,animX,animY)
	return animX, animY
end

DrawingBase.addPropTranslateSolid = function(self, sequence, x, y)
	local layoutScale = System.getLayoutScale();
	x = x and x * layoutScale or x;
	y = y and y * layoutScale or y;
	DrawingBase.addSolidProp(self,sequence,PropTranslateSolid,x,y);
end

DrawingBase.addPropRotateSolid = function(self, sequence, angle360, center, x, y)
	local layoutScale = System.getLayoutScale();
	x = x and x * layoutScale or x;
	y = y and y * layoutScale or y;
	DrawingBase.addSolidProp(self,sequence,PropRotateSolid,angle360,center,x,y);
end

DrawingBase.addPropScaleSolid = function(self, sequence, scaleX, scaleY, center, x, y)
	local layoutScale = System.getLayoutScale();
	x = x and x * layoutScale or x;
	y = y and y * layoutScale or y;
	DrawingBase.addSolidProp(self,sequence,PropScaleSolid,scaleX, scaleY,center,x,y);
end

--------------- private functions, don't use these functions in your code -----------------------

--virtual
DrawingBase.setParent = function(self,parent)
	local ret = drawing_set_parent(self.m_drawingID,parent and parent:getID() or 0);
	self.m_parent = parent;

	if self.m_fillParentHeight or self.m_fillParentWidth or self.m_fillRegion then
		self:reviseSize();
	end
	self:revisePos();
	return ret == 0;
end

DrawingBase.reviseSize = function(self)
	drawing_set_size(self.m_drawingID,DrawingBase.getRealSize(self));

	for _,v in pairs(self.m_children or {}) do 
		if v.m_fillParentHeight or v.m_fillParentWidth or v.m_fillRegion then
			v:reviseSize();
		end
		v:revisePos();
	end
end

DrawingBase.revisePos = function(self)
	if self.m_fillRegion then
		self.m_x = self.m_fillRegionTopLeftX *System.getLayoutScale();
		self.m_y = self.m_fillRegionTopLeftY *System.getLayoutScale();

		drawing_set_position(self.m_drawingID, self.m_x, self.m_y);
		return;
	end

	local parentW,parentH;

	local parent = DrawingBase.getParent(self);
	if not parent then
		parentW = System.getScreenWidth();
		parentH = System.getScreenHeight();
	else
		parentW,parentH = DrawingBase.getRealSize(parent);
	end

	local x,y = DrawingBase.getPos(self);
	x,y = x*System.getLayoutScale(),y*System.getLayoutScale();
	local w,h = DrawingBase.getRealSize(self);

	if self.m_align == kAlignTopLeft 
		or self.m_align == kAlignLeft 
		or self.m_align == kAlignBottomLeft then

		x = x;
	elseif self.m_align == kAlignTopRight
		or self.m_align == kAlignRight
		or self.m_align == kAlignBottomRight then

		x = parentW - w - x;
	elseif self.m_align == kAlignTop 
		or self.m_align == kAlignCenter
		or self.m_align == kAlignBottom then

		x = (parentW - w)/2 + x;
	end

	if self.m_align == kAlignTopLeft 
		or self.m_align == kAlignTop 
		or self.m_align == kAlignTopRight then

		y = y;
	elseif self.m_align == kAlignBottomLeft
		or self.m_align == kAlignBottom
		or self.m_align == kAlignBottomRight then

		y = parentH - h - y;
	elseif self.m_align == kAlignLeft 
		or self.m_align == kAlignCenter
		or self.m_align == kAlignRight then
		
		y = (parentH - h)/2 + y;
	end

	drawing_set_position(self.m_drawingID, x, y);

	self.m_x = x;
	self.m_y = y;
end

DrawingBase.getRealSize = function(self)
	local w,h = DrawingBase.getSize(self);
	w = w >= 0 and w or 1;
	h = h >= 0 and h or 1;
	return w*System.getLayoutScale(),
		h*System.getLayoutScale();
end

DrawingBase.touchEventHandler = function(self, finger_action, x, y, drawing_id_first, drawing_id_current, event_time)
	--no double click ,just touch
	 if not self.m_registedDoubleClick then 
		--continue the event routing or not 
        if DrawingBase.onEventTouch(self,finger_action,x,y,drawing_id_first,drawing_id_current, event_time) then
			drawing_set_touch_continue();
		end
		return;
	 end
	 
	 --Double click considered
	 if finger_action == kFingerDown then 
		--retain the down pos
		self.m_touching = true;

	    self.m_touchDownX = x;
	    self.m_touchDownY = y;
		
		--start timing the double click event
	    if not self.m_doubleClickAnim then 
	    	self:onStopDoubleClickAnim(); 
            self.m_doubleClickAnim = new(AnimInt,kAnimNormal,0,1,500);
            self.m_doubleClickAnim:setEvent(self,self.onDoubleClickEnd);
            self.m_doubleClickAnim:setDebugName("AnimInt|DrawingBase.touchEventHandler m_doubleClickAnim");
            self.m_douleClickDelayTimes = 0;
        end
		--respond the touch event and test if continue the event routing or not
        if DrawingBase.onEventTouch(self,finger_action,x,y,drawing_id_first,drawing_id_current, event_time) then
			drawing_set_touch_continue();
		end
	 else
	 	if not self.m_touching then
	 		return;
	 	end

		-- retain the last pos
		self.m_lastTouchX = x;
	    self.m_lastTouchY = y;
		
		-- if move the touch pos ,then not double click
	    if math.abs(self.m_touchDownX - x) > 10 
            or math.abs(self.m_touchDownY - y) > 10 then
            self:onStopDoubleClickAnim();
	    end
		
		--if not double click ,response the move event
	    if not self.m_doubleClickAnim then 
            if DrawingBase.onEventTouch(self,finger_action,x,y,drawing_id_first,drawing_id_current, event_time) then
				drawing_set_touch_continue();
			end
	    end
	    
		--if not move ,then up or cancle
	    if finger_action ~= kFingerMove then
			-- retain the touch stuff
			self.m_touching = false;
			
	        self.m_lastTouchX = x;
            self.m_lastTouchY = y;
            self.m_lastDrawing_id_first = drawing_id_first;
            self.m_lastDrawing_id_current = drawing_id_current;
            self.m_lastTouchEventTime = event_time;
            
	        if self.m_doubleClickAnim then 
	            self.m_douleClickDelayTimes = self.m_douleClickDelayTimes + 1;
	            
				--test double or not
	            if self.m_douleClickDelayTimes > 1 then
	                if drawing_id_first == drawing_id_current then 
                        DrawingBase.onEventDoubleClick(self,finger_action,x,y,drawing_id_first,drawing_id_current, event_time);
                    end
                    self.m_douleClickDelayTimes = 0;
                    self:onStopDoubleClickAnim();
                end
                end
           end
        end               
	 end

DrawingBase.onStopDoubleClickAnim = function(self)
	delete(self.m_doubleClickAnim);
	self.m_doubleClickAnim = nil;
end

DrawingBase.onEvent = function(self, eventType, ...)
	local eventCallback = self.m_eventCallbacks[eventType];
	if eventCallback and eventCallback.func then 
		return eventCallback.func(eventCallback.obj,...);
	else -- this else branch is only for "continue touch",for others the return value has no meanings;
		return true;
	end
end

DrawingBase.onEventDoubleClick = function(self, finger_action, x, y, drawing_id, event_time)
    DrawingBase.onEvent(self,"doubleClick",finger_action,x,y,drawing_id, event_time);
end

DrawingBase.onDoubleClickEnd = function(self)
	delete(self.m_doubleClickAnim);
	self.m_doubleClickAnim = nil;
	--if not catch the double click ,then response a touch up event
	if self.m_douleClickDelayTimes > 0 then 
        DrawingBase.onEventTouch(self,kFingerUp,self.m_lastTouchX,self.m_lastTouchY,self.m_lastDrawing_id_first,self.m_lastDrawing_id_current, self.m_lastTouchEventTime);
	end
end

DrawingBase.onEventFocus = function(self, focus_action)
	if self.m_pickable then
		DrawingBase.onEvent(self,"focus",focus_action);
	end
end

DrawingBase.onEventDrag = function(self, finger_action, x, y, drawing_id_first, drawing_id_current, event_time)
	x = x / System.getLayoutScale();
	y = y / System.getLayoutScale();

    DrawingBase.onEvent(self,"drag",finger_action,x,y,drawing_id_first,drawing_id_current, event_time);
end

DrawingBase.onEventTouch = function(self, finger_action, x, y, drawing_id_first, drawing_id_current, event_time)
	x = x / System.getLayoutScale();
	y = y / System.getLayoutScale();
	
    return DrawingBase.onEvent(self,"touch",finger_action,x,y,drawing_id_first,drawing_id_current, event_time);
end

DrawingBase.addAnimProp = function(self, sequence, propClass, center, x, y, animType, duration, delay, ...)
	if not DrawingBase.checkAddProp(self,sequence) then 
		return;
	end

	delay = delay or 0;

	local nAnimArgs = select("#",...);
	local nAnims = math.floor(nAnimArgs/2);

	local anims = {};

	for i=1,nAnims do 
		local startValue,endValue = select(i*2-1,...);
		anims[i] = DrawingBase.createAnim(self,animType,duration,delay,startValue,endValue);
	end

	if nAnims == 1 then
		local prop = new(propClass,anims[1],center,x,y);
		if DrawingBase.doAddProp(self,prop,sequence,anims[1]) then
			return anims[1];
		end
	elseif nAnims == 2 then
		local prop = new(propClass,anims[1],anims[2],center,x,y);
		if DrawingBase.doAddProp(self,prop,sequence,anims[1],anims[2]) then
			return anims[1],anims[2];
		end
	elseif nAnims == 3 then
		local prop = new(propClass,anims[1],anims[2],anims[3],center,x,y);
		if DrawingBase.doAddProp(self,prop,sequence,anims[1],anims[2],anims[3]) then
			return anims[1],anims[2],anims[3];
		end
	elseif nAnims == 4 then
		local prop = new(propClass,anims[1],anims[2],anims[3],anims[4],center,x,y);
		if DrawingBase.doAddProp(self,prop,sequence,anims[1],anims[2],anims[3],anims[4]) then
			return anims[1],anims[2],anims[3],anims[4];
		end
	else
		for _,v in pairs(anims) do 
			delete(v);
		end
		error("There is not such a prop that requests more than 4 anims");
	end
end

DrawingBase.addSolidProp = function(self, sequence, propClass, ...)
	if not DrawingBase.checkAddProp(self,sequence) then 
		return;
	end
	
	local prop = new(propClass, ...);
	DrawingBase.doAddProp(self,prop,sequence)
end

DrawingBase.createAnim = function(self, animType, duration, delay, startValue, endValue)
	local anim;
	if startValue and endValue then
		anim = new(AnimDouble,animType,startValue,endValue,duration,delay);
		return anim;
	end
end

DrawingBase.checkAddProp = function(self, sequence)
	if self.m_props[sequence] then
		FwLog(string.format("DrawingBase.addProp failed for having a prop in sequence %d",sequence));
		return false;
	end
	return true;
end

DrawingBase.doAddProp = function(self, prop, sequenece, ...)
	local anims = {select(1,...)};
	if DrawingBase.addProp(self,prop,sequenece) then 
		self.m_props[sequenece] = {["prop"] = prop;["anim"] = anims};
		return true;
	else
		delete(prop);
		for _,v in pairs(anims) do 
			delete(v);
		end
		return false;
	end
end



DrawingBase.setMaskDrawing = function(self,mask)
	mask:setLevel(self.m_level);
	drawing_set_mask_drawing(self.m_drawingID,1,mask and mask.m_drawingID);
	drawing_set_program(mask.m_drawingID,"image2dMask",6);
end

DrawingBase.delMaskDrawing = function(self,mask)
	drawing_set_mask_drawing(self.m_drawingID,0,mask and mask.m_drawingID);
	drawing_set_program(mask.m_drawingID,"",6);
end

DrawingBase.setColorTransform = function(self,r,g,b,a,rOffest,gOffest,bOffest,aOffest)
	if self.m_color_id then
		res_delete(self.m_color_id);
   		res_free_id(self.m_color_id);
   		self.m_color_id = nil;
	end
	self.m_color_id = drawing_set_color_transform(self.m_drawingID,1,r,g,b,a,rOffest,gOffest,bOffest,aOffest)
end


function drawing_set_matrix(drawingID,matrix)
	drawing_set_force_matrix(drawingID,1,matrix);
end

----------------------------------------------------------------------------------------------
-----------------------------------[CLASS] Drawing Image--------------------------------------
----------------------------------------------------------------------------------------------

DrawingImage = class(DrawingBase);

DrawingImage.ctor = function(self, res, leftWidth, rightWidth, topWidth, bottomWidth)
    self.m_res = res;
    self.m_resID = res:getID();
    self.m_width = res:getWidth();
    self.m_height = res:getHeight();
    
    self.m_isGrid9 = (leftWidth and rightWidth and bottomWidth and topWidth) and true or false;
	
	local realWidth,realHeight = DrawingImage.getRealSize(self);
	-- drawing_create_image(0, self.m_drawingID, self.m_resID,
	-- 						self.m_x, self.m_y, realWidth, realHeight, 
	-- 						self.m_isGrid9  and kTrue or kFalse, leftWidth or 0,rightWidth or 0,bottomWidth or 0,topWidth or 0, 
	-- 						self.m_level);
	local scale = System:getLayoutScale();
    leftWidth = leftWidth and leftWidth or 0;
    rightWidth = rightWidth and rightWidth or 0;
    bottomWidth = bottomWidth and bottomWidth or 0;
    topWidth = topWidth and topWidth or 0;
    drawing_create_image2(0, self.m_drawingID, self.m_resID,
							self.m_x, self.m_y, realWidth, realHeight, 
							self.m_isGrid9  and kTrue or kFalse, leftWidth, rightWidth, bottomWidth,topWidth, 
                            leftWidth * scale, rightWidth * scale, bottomWidth * scale,topWidth * scale, 
							self.m_level);

	DrawingImage.setResRect(self,0,res);
end

DrawingImage.setImageIndex = function(self, idx)
    drawing_set_image_index(self.m_drawingID, idx);
end

DrawingImage.addImage = function(self, res, index)
    drawing_set_image_add_image(self.m_drawingID, res:getID(), index);
    DrawingImage.setResRect(self,index,res);
end

DrawingImage.removeImage = function(self, index)
    drawing_set_image_remove_image(self.m_drawingID, index);
end

DrawingImage.removeAllImage = function(self)
    drawing_set_image_remove_all_images(self.m_drawingID);
end

DrawingImage.setGray = function(self, isGray)
	drawing_set_gray(self.m_drawingID,isGray and kTrue or kFalse);
end

DrawingImage.dtor = function(self)
	--drawing_delete(self.m_drawingID);
end

DrawingImage.setResRect = function(self, index, res)
	if typeof(res,ResImage) then
		local subTexX,subTexY,subTexW,subTexH = res:getSubTextureCoord();													
		if subTexX and subTexY and subTexW and subTexH then 
			drawing_set_image_res_rect(self.m_drawingID,index,subTexX,subTexY,subTexW,subTexH);
		else
		    local width,height = res:getWidth(),res:getHeight();
		    drawing_set_image_res_rect(self.m_drawingID,index,0,0,width,height);
		end
	end
end

DrawingImage.setResRectPlain = function(self, index, x, y, w, h)
	if x and y and w and h then 
		drawing_set_image_res_rect(self.m_drawingID,index,x,y,w,h);
	end
end


----------------------------------------------------------------------------------------------
-----------------------------------[CLASS] Drawing Empty--------------------------------------
----------------------------------------------------------------------------------------------

DrawingEmpty = class(DrawingBase);

DrawingEmpty.ctor = function(self)
	drawing_create_node(0,self.m_drawingID,self.m_level);
end

DrawingEmpty.dtor = function(self)
	--drawing_delete(self.m_drawingID);
end


----------------------------------------------------------------------------------------------
-----------------------------------[CLASS] Drawing Custom-------------------------------------
----------------------------------------------------------------------------------------------

DrawingCustom = class(DrawingEmpty);

DrawingCustom.ctor = function(self, renderType, userDataType, vertexRes, indexRes, texRes, texCoordRes, colorRes)
	if not (vertexRes and indexRes) then
		return;
	end

	drawing_set_node_renderable(self.m_drawingID,renderType or kRenderTriangles,userDataType or kRenderDataDefault);
	drawing_set_node_vertex(self.m_drawingID,vertexRes:getID(),indexRes:getID());

	if texRes and texCoordRes then
		drawing_set_node_texture(self.m_drawingID,texRes:getID(),texCoordRes:getID());
	end

	if colorRes then
		drawing_set_node_colors(self.m_drawingID,colorRes:getID());
	end
end

DrawingCustom.dtor = function(self)
	--drawing_delete(self.m_drawingID);
end
