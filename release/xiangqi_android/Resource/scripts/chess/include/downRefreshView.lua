require("ui/scrollView");
DownRefreshView = class(ScrollView,false);

function DownRefreshView.ctor(self, x, y, w, h)
    ScrollView.ctor(self, x, y, w, h, true);

    self.mDownOffset = 100;
    self.m_direction = kVertical;
    self.mIsRefresh = false;
    local w,h = self:getSize();
    self.mRefreshText = new(Text,"下拉可刷新", w, 100, kAlignCenter, fontName, 30, 80, 80, 80);
    self.mRefreshText:setAlign(kAlignTop);
    self.mRefreshText:setPos(0,-100);
	ScrollableNode.addChild(self,self.mRefreshText);
    self:setFlippingOverFactor((self.mDownOffset+20)/self:getFrameLength());
end

function DownRefreshView.dtor(self)

end

function DownRefreshView.getFrameLength(self)
    local w,h = ScrollView.getSize(self);
	return h;
end

function DownRefreshView.getViewLength(self)
    local ret = self.m_nodeH;
    if ret < self:getFrameLength() then
        return self:getFrameLength()+1;
    end
	return ret;
end

function DownRefreshView.setRefreshListener(self,obj,func)
    self.mRefreshListenerObj = obj;
    self.mRefreshListenerFunc = func;
end

function DownRefreshView.refresh(self)
    self.mIsRefresh = true;
--    self:setFlippingOverFactor(0.05);
    self.mRefreshText:setText("正在刷新...")

    if type(self.mRefreshListenerFunc) == "function" then
        self.mRefreshListenerFunc(self.mRefreshListenerObj)
    end

    self:updateScrollView();
end

function DownRefreshView.refreshEnd(self,data,newFunction)
        
    self.mRefreshText:setText("下拉可刷新");
    self:removeProp(1);
    self.mIsRefresh = true;
    local anim = self:addPropTransparency(1, kAnimNormal, 300, -1, 1, 1);
    anim:setEvent(self,function()
            self.mViewData = data
            self.mViewTab  = {}
            self.mCurAddIndex = 0
            self.mViewNewFunction = newFunction
            self:removeAllChildren();  -- 这里会触发scrollAddView(0)
            self.mIsRefresh = false;
            self:scrollAddView(0)
--            self:setFlippingOverFactor((self.mDownOffset+20)/self:getFrameLength());
            self:updateScrollView();
            self:removeProp(1);
            self:addPropTransparency(1, kAnimNormal, 300, -1, 1, 1);
        end)
end

function DownRefreshView:scrollAddView(totalOffset)
    local frameLength = self:getFrameLength();
    local viewLength  = self:getViewLength();
    
    if self.m_nodeH + totalOffset - frameLength > 0 or self.mIsRefresh then return end
    if type(self.mViewData) == "table" and #self.mViewData > 0 and type(self.mViewNewFunction) == "function" and self.mCurAddIndex < #self.mViewData then
        while self.mCurAddIndex < #self.mViewData do
            self.mCurAddIndex = self.mCurAddIndex + 1
            local item = self.mViewData[self.mCurAddIndex]
            local view = self.mViewTab[self.mCurAddIndex] or self.mViewNewFunction(item)
            self:addChild(view)
            self.mViewTab[self.mCurAddIndex] = view
            if self.m_nodeH + totalOffset - frameLength > 0 then break end
        end
        self:stop()
        self:scrollToPos(totalOffset)
        --self:updateScrollView();
    end
end

function DownRefreshView:getViewData()
    return self.mViewData or {}
end

function DownRefreshView:getViewTab()
    return self.mViewTab or {}
end

function DownRefreshView.onScroll(self, scroll_status, diffY, totalOffset,isMarginRebounding)
	ScrollView.onScroll(self, scroll_status, diffY, totalOffset,isMarginRebounding);
    self:scrollAddView(totalOffset)
    local frameLength = self:getFrameLength();
    local viewLength  = self:getViewLength();

    if not self.mIsRefresh and totalOffset > self.mDownOffset and ScrollView.hasScroller(self) and not Scroller.isTouching(self.m_scroller) then
        self:refresh();
    end

    if totalOffset >= 0 then
        if totalOffset-100 >= 0 then
            self.mRefreshText:setPos(0,0);
        else
            self.mRefreshText:setPos(0,totalOffset-100);
        end
    else
        self.mRefreshText:setPos(0,-100);
    end
end