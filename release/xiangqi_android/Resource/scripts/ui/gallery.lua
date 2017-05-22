-- gallery.lua
-- Author: Leoli
-- Date: 2015-11-2
-- Description: Implemented gallery 

require("core/object");
require("ui/scrollView");

-- Gallery 默认朝向都是水平kHorizontal
-- 在ScrollView基础上增加自动居中、左右回弹、
-- 左右滑动自动居中、显示左右两边的元素的边缘

-- 这个控件有坑使用要主要 curIndex 的变化 by bealuo

Gallery = class(ScrollView,false);

Gallery.SLIDE_TIME = 200;
Gallery.SCALE_TIME = 300;
Gallery.SLIDE_OFFSET = 100;

-- itemW,滑动item的宽;itemH,滑动item的高
-- firstOffset,第一个child距左边距离（为了居中）
Gallery.ctor = function(self, x, y, w, h, itemW,itemH, firstOffset)
	super(self,x, y, w, h, false);
    self.m_direction = kHorizontal;
    self.m_mainNode_offset = 0;
    self.m_itemW = itemW;
    self.m_itemH = itemH;
    self.m_firstOffset = firstOffset;
    -- 默认当前itemIndex = 0
    self.m_curIndex = 0;
end 

Gallery.addChildWithAnim = function(self, child, index)
    if not child or not index or index <=0 then return end;
    if index > 1 then
        self:toScale(child);
    end;

    if self.m_curIndex == 0 then self.m_curIndex = 1 end

    self:addChild(child);
end;

Gallery.setCallBackFunc = function(self, obj, func)
    self.m_call_back_func = func;
    self.m_call_back_obj  = obj;
end;

Gallery.callBack = function(self)
    if self.m_call_back_func and self.m_call_back_obj then
        self.m_call_back_func(self.m_call_back_obj);
    end;
end;


Gallery.onEventDrag =  function(self, finger_action, x, y,drawing_id_first, drawing_id_current)
    -- 如果动画正在移动,取消触摸事件
    if self.m_slide_anim then return end;
    if finger_action == kFingerDown then
        self.m_orignX = x;
        self.m_orignY = y;
        self.m_itemView,self.m_curIndex = self:getCurTouchViewAndIndex(self.m_orignX,self.m_orignY);
        Log.i("ScrollView.onEventDrag----->currentIndex...."..self.m_curIndex);
        self.m_touching = true;
    elseif finger_action == kFingerUp then
        self.m_touching = false; 
        self.m_totalOffset = x - self.m_orignX;
        if self.m_totalOffset >= 0 then
            if math.abs(self.m_totalOffset) > Gallery.SLIDE_OFFSET then
                if self:leftHasView() then
                    self:leftViewToShow();
                else
                    self:backToOrignPos();
                end;
            else
                self:backToOrignPos();
            end;
        elseif self.m_totalOffset < 0 then
            if math.abs(self.m_totalOffset) > Gallery.SLIDE_OFFSET then
                if self:rightHasView() then
                    self:rightViewToShow();
                else
                    self:backToOrignPos();
                end;
            else
                self:backToOrignPos();
            end;
        end;  
	elseif self.m_touching then 
        Log.i("elseif self.m_touching then ....."..(self.m_mainNode_offset + x - self.m_orignX));
        self.m_mainNode:setPos(self.m_mainNode_offset + x - self.m_orignX,nil);
    end;
end



Gallery.onScroll = function(self, scroll_status, diffY, totalOffset,isMarginRebounding)
	ScrollableNode.onScroll(self,scroll_status,diffY,totalOffset,true);
    Log.i("ScrollView.onScroll...."..totalOffset.."...diffY..."..diffY);
    self.m_totalOffset = totalOffset;
	self.m_mainNode:setPos(totalOffset,nil);
end




Gallery.getCurTouchViewAndIndex = function(self, x, y)
    -- 相对于item的x
    local relativeitemX = x - self.m_firstOffset;
    if relativeitemX <= 0 or relativeitemX >= self.m_itemW then
        relativeitemX = 0;
    end;
    -- 相对于MainNode的x
    local relativeMainNodeX = relativeitemX - self.m_mainNode_offset;
    local index = math.floor(relativeMainNodeX / self.m_itemW) + 1;
    Log.i("Gallery.getCurTouchViewAndIndex...."..index);
    local view = self:getChildren()[index];
    return view, index;
end

-- 当前view左侧是否还有view
Gallery.leftHasView = function(self)
    if self.m_curIndex > 1 then
        return true;
    end;
end;

-- 当前view右侧是否还有view
Gallery.rightHasView = function(self)
    if self.m_curIndex < #self:getChildren() then
        return true;
    end;
end;



function Gallery:setChangeIndexListener(obj,func)
    self.mChangeIndexListener = {}
    self.mChangeIndexListener.obj = obj
    self.mChangeIndexListener.func = func
end

-- 显示左侧view
Gallery.leftViewToShow = function(self)
    local childNum = #self:getChildren();
    -- move anim
    local mainNodeX, mainNodeY = self.m_mainNode:getPos();
    local moveAnim = self.m_mainNode:addPropTranslate(0,kAnimNormal,Gallery.SLIDE_TIME,0,0, self.m_itemW - self.m_totalOffset,nil,nil);
    if not moveAnim then return end;
    self.m_slide_anim = true;
    moveAnim:setEvent(self, function()
         self.m_mainNode:removeProp(0);
         self.m_mainNode_offset = self.m_mainNode_offset + self.m_itemW;
         self.m_mainNode:setPos(self.m_mainNode_offset,nil);
         self.m_slide_anim = false;
    end)
    self.m_curIndex = self.m_curIndex - 1;
    self:toScale(self.m_itemView, self:getChildren()[self.m_curIndex]);
    if self.mChangeIndexListener and type(self.mChangeIndexListener.func) == "function" then
        self.mChangeIndexListener.func(self.mChangeIndexListener.obj)
    end
end;

-- 显示右侧view
Gallery.rightViewToShow = function(self)
    local childNum = #self:getChildren();
    -- move anim
    local mainNodeX, mainNodeY = self.m_mainNode:getPos();
    local moveAnim = self.m_mainNode:addPropTranslate(0,kAnimNormal,Gallery.SLIDE_TIME,0,0, - (self.m_itemW + self.m_totalOffset),nil,nil);
    if not moveAnim then return end;
    self.m_slide_anim = true;
    moveAnim:setEvent(self, function()
         self.m_mainNode:removeProp(0);
         self.m_mainNode_offset = self.m_mainNode_offset - self.m_itemW;
         self.m_mainNode:setPos(self.m_mainNode_offset,nil);
         self.m_slide_anim = false;
    end)
    self.m_curIndex = self.m_curIndex + 1;
    self:toScale(self.m_itemView, self:getChildren()[self.m_curIndex]);
    if self:isLastItem() then self:callBack(); end;
    if self.mChangeIndexListener and type(self.mChangeIndexListener.func) == "function" then
        self.mChangeIndexListener.func(self.mChangeIndexListener.obj)
    end
end;


Gallery.toScale = function(self, toSmallView, toBigView)
    if toSmallView then 
        toSmallView:removeProp(2);
        toSmallView:addPropScale(1, kAnimNormal, Gallery.SCALE_TIME, -1, 1,0.9,1,0.9,kCenterXY,self.m_itemW/2,self.m_itemH/2);
        toSmallView:setTransparency(0.6);  
    end;
    if toBigView then
        toBigView:removeProp(1);
        toBigView:addPropScale(2, kAnimNormal, Gallery.SCALE_TIME, -1, 0.9,1,0.9,1,kCenterXY,self.m_itemW/2,self.m_itemH/2);
        toBigView:setTransparency(1);
    end;
    
end;



-- 返回居中位置
Gallery.backToOrignPos = function(self)
    local mainNodeX, mainNodeY = self.m_mainNode:getPos();
    Log.i("Before Gallery.backToOrignPos....."..(mainNodeX - self.m_totalOffset));
    local moveAnim = self.m_mainNode:addPropTranslate(0,kAnimNormal,Gallery.SLIDE_TIME,0,0,- self.m_totalOffset,nil,nil);
    if not moveAnim then return end;
    moveAnim:setEvent(self, function()
         Log.i("Gallery.backToOrignPos....."..(mainNodeX - self.m_totalOffset));
         self.m_mainNode:removeProp(0);
         local offset = math.floor(mainNodeX - self.m_totalOffset);
         if offset < self.m_mainNode_offset then
             while(offset ~= self.m_mainNode_offset) do
                self.m_mainNode:setPos(offset,nil);
                offset = offset + 1;
             end;
         elseif offset > self.m_mainNode_offset then
             while(offset ~= self.m_mainNode_offset) do
                self.m_mainNode:setPos(offset,nil);
                offset = offset - 1;
             end;
         else
            self.m_mainNode:setPos(self.m_mainNode_offset,nil);
         end;
    end)
end;

-- 获得curIndex
Gallery.getCurrentIndex = function(self)
    return self.m_curIndex;
end;

Gallery.getChildsNum = function(self)
    return #self:getChildren();
end;



Gallery.isLastItem = function(self)
    if #self:getChildren() == 1 then
        return true;
    elseif #self:getChildren() == self.m_curIndex then
        return true;
    end;
    return false;
end;

-- 删除item
Gallery.deleteItem = function(self,index)
    if not self:getChildren()[index] then return end;
    self:removeChildWithAnim(self:getChildren()[index],index);
end;


-- 带动画删除子节点
Gallery.removeChildWithAnim = function(self, child,index)
    if self:removeChild(child,true) then
        if self.m_curIndex == index then
            -- 删除中间条，则右侧view依次向左滑动
            if self:getChildren()[index] then
                -- 第一个rightView左滑动画
                local moveAnim = self:getChildren()[index]:addPropTranslate(0,kAnimNormal,Gallery.SLIDE_TIME,0,0,-self.m_itemW,nil,nil);
                if moveAnim then
                    moveAnim:setEvent(self,function() 
                        -- 实际位置移动
                        while index <= #self:getChildren() do
                            self:getChildren()[index].m_index = index;
                            local tempX,tempY = self:getChildren()[index]:getPos();
                            self:getChildren()[index]:setPos(tempX - self.m_itemW); 
                            index = index + 1;
                        end;
                        self:getChildren()[self.m_curIndex]:removeProp(0);
                    end)
                    -- 由于右侧的view整体左滑动，所以self.m_curIndex不变
                    self.m_curIndex = self.m_curIndex;
                end;   
                -- 第一个rightView放大动画           
                self:toScale(nil,self:getChildren()[self.m_curIndex]);
            -- 删除最后一条，则左面的view整体向右滑动
            elseif self:getChildren()[index - 1] then
                local tempX,tempY = self.m_mainNode:getPos();
                local moveAnim = self.m_mainNode:addPropTranslate(0,kAnimNormal,Gallery.SLIDE_TIME,0,0,self.m_itemW,nil,nil);
                if moveAnim then
                    moveAnim:setEvent(self,function() 
                        self.m_mainNode:removeProp(0);
                        self.m_mainNode:setPos(tempX + self.m_itemW); 
                        self.m_mainNode_offset = self.m_mainNode_offset + self.m_itemW;

                    end)
                end;
                self:toScale(nil,self:getChildren()[index - 1]);
                -- 由于左侧view整体滑动一个itemW宽，self.m_curIndex - 1
                self.m_curIndex = self.m_curIndex - 1;
            -- 删除的是第一条也是最后一条，self.m_curIndex为默认0
            else
                self.m_curIndex = 0;
            end;
        else
            Log.i("Gallery.removeChildWithAnim-->>>self.m_curIndex ！= index");
        end;
    end;
    
    if self.mChangeIndexListener and type(self.mChangeIndexListener.func) == "function" then
        self.mChangeIndexListener.func(self.mChangeIndexListener.obj)
    end
end

Gallery.removeChild = function(self, child, isClean)
    local itemIndex = self.m_mainNode.m_rchildren[child];
    if itemIndex then
        -- 索引置nil
        self.m_mainNode.m_rchildren[child] = nil;
        -- 脱离父子关系
        local ret = child:setParent();
        if isClean then delete(child) end;
        -- 从mainNode去除
        local tempChild = table.remove(self.m_mainNode.m_children, itemIndex);
	    tempChild = nil;
        -- 重置m_rchildren索引表
        while itemIndex <= #self:getChildren() do
            local child = self.m_mainNode.m_children[itemIndex];
            self.m_mainNode.m_rchildren[child] = self.m_mainNode.m_rchildren[child] - 1;
            itemIndex = itemIndex + 1;
        end;
        return ret;
    end
end;



-- 回弹
Gallery.rebondMargin = function(self,scrollerStatus, align)
end;

-- 滑动到指定index
Gallery.slideToIndex = function(self, index)
    if index > 1 then 
        self.m_mainNode_offset = -(index - 1) * self.m_itemW;
        self.m_mainNode:setPos(self.m_mainNode_offset,nil);
        for i = 1, index - 1 do
            self:toScale(self:getChildren()[i]);
        end;
        self:toScale(nil,self:getChildren()[index]);
        self.m_curIndex = index
        if self.mChangeIndexListener and type(self.mChangeIndexListener.func) == "function" then
            self.mChangeIndexListener.func(self.mChangeIndexListener.obj)
        end
    end
end;