require("core/constants");
require("core/object");
require("core/global");
require("ui/scrollView");

ScrollPicker = class(ScrollView,false)

ScrollPicker.ctor = function(self, x, y, w, h)
    --边距填充
    self.m_padding = {};
    self.m_items = {};
    self.m_index_pos = {};
    self.m_selectIndex = 0;
    self.m_padding.__start = 0;
    self.m_padding.__end = 0;
    self.m_changeIndexClick = nil;

    self:setChangeFunc(self,self.changeFunc);

    super(self,x,y,w,h,true);

    self.m_scrollPickerListener = new(ScrollPickerListener,self);
end

ScrollPicker.addChild = function(self, child)
	self.m_mainNode:addChild(child);

    local optimize
    optimize = function (obj)
        drawing_set_bounding_circle_visible_test( obj.m_drawingID, 1 );
        local children = DrawingBase.getChildren(obj);
        for k, v in pairs(children) do
            optimize(v);                                   
        end 
    end 
    optimize(child);

	if self.m_autoPositionChildren then
		child:setAlign(kAlignTopLeft);
		local w,h = child:getSize();
		if self.m_direction == kVertical then
		    child:setPos(self.m_nodeW,self.m_nodeH+self.m_padding.__start);
			self.m_nodeH = self.m_nodeH + h;
		else
		    child:setPos(self.m_nodeW+self.m_padding.__start,self.m_nodeH);
			self.m_nodeW = self.m_nodeW + w;
		end
	else
		local x,y = child:getUnalignPos();
		local w,h = child:getSize();
		
		if self.m_direction == kVertical then
			self.m_nodeH = (self.m_nodeH > y + h) and self.m_nodeH or (y + h);
		else
			self.m_nodeW = (self.m_nodeW > x + w) and self.m_nodeW or (x + w);
		end
	end
	
	ScrollView.update(self);
end

ScrollPicker.removeAllChildren = function(self, doCleanup)
    self.m_padding = {};
    self.m_items = {};
    self.m_index_pos = {};
    self.m_selectIndex = 0;
    self.m_padding.__start = 0;
    self.m_padding.__end = 0;
    self.m_adapter = nil;
    return self.super.removeAllChildren(self, doCleanup);
end

ScrollPicker.setAdapter = function(self,adapter)
    if not typeof(adapter,ScrollPickerAdapter) then
        Log.e("ScrollPicker.setAdapter error: adapter must extends ScrollPickerAdapter");
        return ;
    end
    if self.m_adapter ~= adapter then
        self:removeAllChildren();
    end
    self.m_adapter = adapter;
    self.m_adapter:setListener(self.m_scrollPickerListener);
    if self.m_adapter:isEmpty() then return end
    self:updateView(0);
    
    if self.m_selectIndex > 0 then
        self:updateSelectItems(0);
        self.m_changeFunc(self.m_changeFuncObj,self.m_items[self.m_selectIndex],true);
    end
end
-- 为解决卡顿 暂时view 的高度要一致
--更新界面
ScrollPicker.updateView = function(self,pos)
    if pos == nil then
        pos = self:getViewLength();
    end
    if self.m_adapter and not self.m_adapter:isEmpty() then
        local count = self.m_adapter:getCount();
        if count then
            for i=1,count do
                local view = self.m_adapter:getView(i,self.m_items[i],self);
                if not self.m_items[i] then
                    self.m_items[i] = view;
                    self.m_changeFunc(self.m_changeFuncObj,self.m_items[i],false)
                    -- 如果是第一个view 且 未初始化距离则 初始化
                    if i == 1 and self.m_padding.__start == 0 then
                        local sw,sh = self:getSize();
                        local vw,vh = view:getSize();
                        self.m_selectIndex = 1;
                        if self.m_direction == kVertical then
                            self.m_padding.__start= (sh-vh) / 2;
	                    else
                            self.m_padding.__start= (sw-vw) / 2;
	                    end
                    end
                    -- 如果是最后一个view 且 未初始化距离则 初始化
                    if i == count and self.m_padding.__end == 0 then
                        local sw,sh = self:getSize();
                        local vw,vh = view:getSize();
                        if self.m_direction == kVertical then
                            self.m_padding.__end = (sh-vh) / 2;
	                    else
                            self.m_padding.__end = (sw-vw) / 2;
	                    end
                    end
                    ScrollPicker.addChild(self,view);
                end
                local x,y = view:getPos();
                local w,h = view:getSize();
                self.m_index_pos[i] = {};
                if self.m_direction == kVertical then
                    self.m_index_pos[i].s = y;
                    self.m_index_pos[i].e = self.m_index_pos[i].s + h;
	            else
                    self.m_index_pos[i].s = x;
                    self.m_index_pos[i].e = self.m_index_pos[i].s + w;
	            end
                if self.m_index_pos[i].e > pos + self:getFrameLength() then
                    break;
                end
            end
        end
    end
end

ScrollPicker.getViewLength = function(self)
	if self.m_direction == kVertical then
		return self.m_nodeH+self.m_padding.__start+self.m_padding.__end;
	else
		return self.m_nodeW+self.m_padding.__start+self.m_padding.__end;
	end
end

ScrollPicker.onScroll = function(self, scroll_status, diffY, totalOffset,isMarginRebounding)
	--isMarginRebounding,useless in ScrollView
	ScrollableNode.onScroll(self,scroll_status,diffY,totalOffset,true);

	if self.m_direction == kVertical then
		self.m_mainNode:setPos(nil,totalOffset);
	else
		self.m_mainNode:setPos(totalOffset,nil);
	end
    self:updateView(-totalOffset);
    self:updateSelectItems(totalOffset,scroll_status);
end

ScrollPicker.changeFunc = function(self,view,selected)
    if selected then
        if not view:checkAddProp(1) then
            view:removeProp(1);
        end
    else
        if view:checkAddProp(1) then
            view:addPropScaleSolid(1, 0.8, 0.8, kCenterDrawing);
        end
    end
end

ScrollPicker.setChangeFunc = function(self,obj,func)
    if self.m_changeFunc then
        for i,item in pairs(self.m_items) do
            self.m_changeFunc(self.m_changeFuncObj,item,false)
        end
    end
    self.m_changeFunc = func;
    self.m_changeFuncObj = obj;
    if self.m_changeFunc then
        for i,item in pairs(self.m_items) do
            self.m_changeFunc(self.m_changeFuncObj,item,false)
        end
        if self.m_selectIndex > 0 then
            self.m_changeFunc(self.m_changeFuncObj,self.m_items[self.m_selectIndex],true)
        end
    end
end

ScrollPicker.updateSelectItems = function(self,pos,scroll_status)
    local w,h = self:getSize();
    local diff = 0;
    if self.m_direction == kVertical then
        diff = h/2;
	else
        diff = w/2;
	end
    if self.m_selectIndex > 0 then
        local count = self.m_adapter:getCount();
        if self.m_index_pos[self.m_selectIndex].s <= math.abs(pos-diff) and math.abs(pos-diff) < self.m_index_pos[self.m_selectIndex].e then

        else
            if self.m_index_pos[self.m_selectIndex].s > math.abs(pos-diff) and self.m_selectIndex > 1 then
                self.m_changeFunc(self.m_changeFuncObj,self.m_items[self.m_selectIndex],false)
                self.m_selectIndex = self.m_selectIndex - 1;
                self.m_changeFunc(self.m_changeFuncObj,self.m_items[self.m_selectIndex],true)
                if self.m_changeIndexClick and self.m_changeIndexClick.func then
                    self.m_changeIndexClick.func(self.m_changeIndexClick.obj,self.m_selectIndex);
                end
            end

            if self.m_index_pos[self.m_selectIndex].e < math.abs(pos-diff) and self.m_selectIndex < count then
                self.m_changeFunc(self.m_changeFuncObj,self.m_items[self.m_selectIndex],false)
                self.m_selectIndex = self.m_selectIndex + 1;
                self.m_changeFunc(self.m_changeFuncObj,self.m_items[self.m_selectIndex],true)
                if self.m_changeIndexClick and self.m_changeIndexClick.func then
                    self.m_changeIndexClick.func(self.m_changeIndexClick.obj,self.m_selectIndex);
                end
            end
        end
    end

    if ScrollView.hasScroller(self) and kScrollerStatusStop == scroll_status and self.m_selectIndex > 0 and not Scroller.isTouching(self.m_scroller) then
		local viewPos = (self.m_index_pos[self.m_selectIndex].s + self.m_index_pos[self.m_selectIndex].e)/2;
        local w,h = self:getSize();
        if self.m_direction == kVertical then
		    viewPos = viewPos - h/2;
	    else
		    viewPos = viewPos - w/2;
	    end

        local offset = -viewPos;
        if ScrollView.hasScroller(self) and offset ~= pos then
            Scroller.addRebound(self.m_scroller,offset - pos);
        end
	end
end

ScrollPicker.getSelectIndex = function(self)
    return self.m_selectIndex;
end

ScrollPicker.setChangeIndexClick = function(self,obj,func)
    self.m_changeIndexClick = {};
    self.m_changeIndexClick.obj = obj;
    self.m_changeIndexClick.func = func;
end
-----------------------

ScrollPickerAdapter = class();

ScrollPickerAdapter.ctor = function(self,data)
    self.m_datas = data;
    self.m_views = {};
end

ScrollPickerAdapter.dtor = function(self)

end

ScrollPickerAdapter.setListener = function(self,listener)
    if not typeof(listener,ScrollPickerListener) then
        Log.e("ScrollPickerAdapter.setListener error: listener must extends ScrollPickerListener");
        return ;
    end
    self.m_listener = listener;
end

ScrollPickerAdapter.updateView = function(self)
    self.m_listener:updateView();
end

ScrollPickerAdapter.getCount = function(self)
    return #self.m_datas;
end

ScrollPickerAdapter.getView = function(self,position,convertView,parent)
    if not self.m_views[position] then
        self.m_views[position] = new(Text,"test:"..self.m_datas[position], 0, 0, nil, nil, 30);
    end
    return self.m_views[position];
end

ScrollPickerAdapter.getItem = function(self,position)

end

ScrollPickerAdapter.getItemId = function(self,position)

end

ScrollPickerAdapter.isEmpty = function(self)
    return #self.m_datas == 0;
end

-------------------- listener ----------------------------------------

ScrollPickerListener = class()

ScrollPickerListener.ctor = function(self,handler)
    self.m_handler = handler;
end

ScrollPickerListener.updateView = function(self)
    self.m_handler:updateView();
end
