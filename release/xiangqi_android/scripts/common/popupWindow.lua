
--弹出窗口的抽象类，为一个空节点
--所有弹出窗口须继承此类，并在界面创建完后把根节点加到该空节点下
--show和hidden方法可被子类重写，以方便不同的显示隐藏需求。
--但注意在重写时须显示地调用父类的对应方法
--如子类要重写show，则需在方法中添加 PopupWindow.show(self)；

require("gameBase/gameLayer");
require("core/eventDispatcher");
require("ui/toast");

PopupWindow = class(GameLayer);

kClosePopupWindows = EventDispatcher.getInstance():getUserEvent();
kShowPopupWindows = EventDispatcher.getInstance():getUserEvent();

PopupWindowStyle = 
{	
	NORMAL = 1,
	POPUP = 2,
	FADE  = 3,
};

--PopupWindow.s_level = 15;--所有弹出框的level统一
PopupWindow.s_level = 55;--所有弹出框的level统一

PopupWindow.ctor = function(self)
	local width,height = self.m_root:getSize();
    PopupWindow.setSize(self,width,height);

	self.m_styleFuncMap = {};
	self:setVisible(false);
	self:setLevel(PopupWindow.s_level);
	PopupWindow.shieldPopupWindowArea(self);

	PopupWindow.setPosition(self);

	PopupWindow.registerStyle(self,PopupWindowStyle.POPUP,PopupWindow.popupStyle);
	PopupWindow.registerStyle(self,PopupWindowStyle.FADE,PopupWindow.fadeStyle);
end

PopupWindow.dtor = function(self)

end

PopupWindow.registerStyle = function(self, style, func)
	self.m_styleFuncMap[style] = func;
end

PopupWindow.hidden = function(self,style)
	Toast.getInstance():hidden();
	EventDispatcher.getInstance():unregister(kClosePopupWindows , self ,self.hidden);
	EventDispatcher.getInstance():unregister(Event.Back , self ,self.hidden);

	if style and self.m_styleFuncMap and self.m_styleFuncMap[style] then 
		self.m_styleFuncMap[style](self.m_root,nil,nil,false);
	end 

	self:setVisible(false);
	self:resumeTouch();	
end

PopupWindow.show = function(self,style)	
	self.m_style = style or PopupWindowStyle.POPUP;
	EventDispatcher.getInstance():dispatch(kClosePopupWindows);

	EventDispatcher.getInstance():register(kClosePopupWindows , self ,self.hidden);
	EventDispatcher.getInstance():register(Event.Back , self ,self.hidden);
	
	EventDispatcher.getInstance():dispatch(kShowPopupWindows,self,self.hidden);

	self:setVisible(true);
	if self.m_styleFuncMap and self.m_styleFuncMap[self.m_style] then 
		self.m_styleFuncMap[self.m_style](self.m_root,self,self.showEnd,true);
	end 
end

--------------------- private ---------------------------------------------------------------
PopupWindow.showEnd = function(self)

end 

-- 屏蔽点击,drawingList 是一个table
PopupWindow.shieldTouch = function(self,drawingList)
	if drawingList and type(drawingList) == type(table) and #drawingList>0 then
		self.shieldTouchList = drawingList;
		for i = 1, #self.shieldTouchList do
			if typeof(self.shieldTouchList[i], DrawingBase) then
				 self.shieldTouchList[i]:setPickable(false);
			end
		end
	end 
end 

PopupWindow.resumeTouch = function(self)
	if self.shieldTouchList then
		for i = 1, #self.shieldTouchList do
			if typeof(self.shieldTouchList[i], DrawingBase) then
				 self.shieldTouchList[i]:setPickable(true);
			end
		end
	end
	self.shieldTouchList = nil;
end

PopupWindow.shieldPopupWindowArea = function(self)
	local bg = self.m_root:getChildByName("bg");
	if bg and typeof(bg,DrawingBase) then 
		bg:setEventTouch(self,function()
		end);
	end 
end 

PopupWindow.execDelegate = function(self,func,...)
    if self.m_delegate and self.m_delegate[func] then
        self.m_delegate[func](self.m_delegate,self,...);
    end
end

PopupWindow.setPosition = function(self,x,y)
	local screenW = System.getScreenScaleWidth();
	local screenH = System.getScreenScaleHeight();
	local w,h = self.m_root:getSize();
	x = x or (screenW - w)*0.5;
	y = y or (screenH - h)*0.5;
	self:setPos(x,y);
end

PopupWindow.popupStyle = function(drawing,callbackObj,callbackFunc,isShow)
	if not drawing or not drawing.m_drawingID then 
		return;
	end 
	PopupWindow.removeProps(drawing,0);
	PopupWindow.removeProps(drawing,1);

	drawing:setVisible(true);
	local offset = isShow and 0.5 or -0.5;
	local anim = drawing:addPropTransparency(0, kAnimNormal, 300, 0, 0.5-offset, 0.5+offset);
    anim:setDebugName("PopupWindow,anim");
	drawing:addPropScale(1, kAnimNormal, 300, 0, 0.5-offset,0.5+offset,0.5-offset,0.5+offset,kCenterDrawing);
	anim:setEvent(nil,function()
		PopupWindow.removeProps(drawing,0);
		PopupWindow.removeProps(drawing,1);

		if callbackFunc then
			callbackFunc(callbackObj);
		end  
	end);		
end 

PopupWindow.fadeStyle = function(drawing,callbackObj,callbackFunc,isShow)
	if not drawing or not drawing.m_drawingID then 
		return;
	end 
	PopupWindow.removeProps(drawing,0);

	drawing:setVisible(true);
	local offset = isShow and 0.5 or -0.5;
	local anim = drawing:addPropTransparency(0, kAnimNormal, 500, 0, 0.5-offset, 0.5+offset);
    anim:setDebugName("PopupWindow,anim");
	anim:setEvent(nil,function()
		PopupWindow.removeProps(drawing,0);

		if callbackFunc then
			callbackFunc(callbackObj);
		end  
	end);		
end

PopupWindow.removeProps = function(drawing,sequence)
	if drawing and drawing.m_drawingID then
		if not drawing:checkAddProp(sequence) then 
			drawing:removeProp(sequence);
		end
	end 
end