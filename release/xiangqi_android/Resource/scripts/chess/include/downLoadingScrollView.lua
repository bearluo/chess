--region DownLoadingScrollView.lua
--Date 2017/02/09
--上滑加载
--endregion

require("ui/scrollView");
DownLoadingScrollView = class(ScrollView,false);

function DownLoadingScrollView.ctor(self, x, y, w, h)
    ScrollView.ctor(self, x, y, w, h, true);
    self.mNoMoreData = false;
    self.mLoadIng    = false;
    self.totalHeight = 0
end

function DownLoadingScrollView.setOnLoadEvent(self,obj,func)
    self.mOnLoadObj     = obj;
    self.mOnLoadFunc    = func;
end

function DownLoadingScrollView.dtor(self)
    
end

function DownLoadingScrollView.newLoadingTips(self,tips)
    self.tipsText = new(Text,tips or "",nil,nil,nil,nil,32,80,80,80)

end

function DownLoadingScrollView.addChild(self, child)
    ScrollView.addChild(self, child);

    local w,h = child:getSize()
    self.totalHeight = self.totalHeight + h
end

function DownLoadingScrollView.updateScrollView(self)
    ScrollView.updateScrollView(self);
end

function DownLoadingScrollView.removeChild(self, child, doCleanup)
	return ScrollView.removeChild(self,child, doCleanup);
end

function DownLoadingScrollView.onScroll(self, scroll_status, diffY, totalOffset,isMarginRebounding)
    ScrollView.onScroll(self,scroll_status,diffY,totalOffset,isMarginRebounding);

    local lvW, lvH = self:getSize();
    local trueOffset = self.totalHeight - lvH;
    if totalOffset and trueOffset > 0 then
        if (math.abs(tonumber(totalOffset)) >  trueOffset + 150) then
            if not self.mLoadIng then
                self.mLoadIng = true;
                if self.mOnLoadObj and self.mOnLoadFunc then
                    self.mOnLoadFunc(self.mOnLoadObj);
                end
            end;
        elseif math.abs(tonumber(totalOffset)) < trueOffset+10 and math.abs(tonumber(totalOffset)) > trueOffset then
            self.mLoadIng = false;
        end;
    end;
end
