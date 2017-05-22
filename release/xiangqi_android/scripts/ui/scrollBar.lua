-- scorllBar.lua
-- Author: Vicent.Gong
-- Date: 2012-09-26
-- Last modification : 2013-07-05
-- Description: Implemented scorll bar 

require("core/object");
require("core/global");
require("ui/image");

ScrollBar = class(Image,false);

ScrollBar.s_defaultBgImage = "ui/scroll.png";
ScrollBar.s_defaultInvisibleTime = 300;
ScrollBar.s_defaultSmallestLength = 8;

ScrollBar.setDefaultImage = function(filePath)
	ScrollBar.s_bgImage = filePath or ScrollBar.s_defaultBgImage;
end

ScrollBar.setDefaultInvisibleTime = function(time)
	ScrollBar.s_invisibleTime = time or ScrollBar.s_defaultInvisibleTime;
end

ScrollBar.setDefaultSmallestLength = function(smallestLength)
	ScrollBar.s_smallestLength = smallestLength or ScrollBar.s_defaultSmallestLength;
end

ScrollBar.ctor = function(self, direction, frameLength, viewLength)
	local file = ScrollBar.s_bgImage or ScrollBar.s_defaultBgImage;
	if direction ~= kHorizontal then
		super(self,file,nil,nil,2,2,4,4);
	else
		super(self,file,nil,nil,4,4,2,2);
	end

	self.m_direction = direction or kVertical;
	self.m_frameLength = frameLength or 1;
	self.m_viewLength = viewLength or 1;
    
	self.m_normalLength = frameLength^2 / viewLength;
	self.m_scrollPos = 0;
	self.m_startPos = 0;
	
	self.m_invisibleTime = ScrollBar.s_invisibleTime or ScrollBar.s_defaultInvisibleTime;
	self.m_smallestLength = ScrollBar.s_smallestLength or ScrollBar.s_defaultSmallestLength;
end

ScrollBar.setFile = function(self, file)
	Image.setFile(self,file 
					or ScrollBar.s_bgImage 
					or ScrollBar.s_defaultBgImage);
end

ScrollBar.setInvisibleTime = function(self, invisibleTime)
	self.m_invisibleTime = invisibleTime 
						or ScrollBar.s_invisibleTime 
						or ScrollBar.s_defaultInvisibleTime;
end

ScrollBar.setSmallestLength = function(self, smallestLength)
	self.m_smallestLength = smallestLength 
						or ScrollBar.s_smallestLength 
						or ScrollBar.s_defaultSmallestLength;
end

ScrollBar.setFrameLength = function(self, frameLength)
	self.m_frameLength = frameLength or self.m_frameLength;
	self.m_normalLength = self.m_frameLength^2 / self.m_viewLength;
	
	ScrollBar.forceUpdate(self);
	ScrollBar.setVisibleImmediately(self);
end

ScrollBar.setViewLength = function(self, viewLength)
	self.m_viewLength = viewLength or self.m_viewLength;
	self.m_normalLength = self.m_frameLength^2 / self.m_viewLength;
	
	ScrollBar.forceUpdate(self);
	ScrollBar.setVisibleImmediately(self);
end

ScrollBar.setStartPos = function(self, pos)
	self.m_startPos = pos or self.m_startPos;
	ScrollBar.forceUpdate(self);
end

ScrollBar.setScrollPos = function(self, scrollPos)
	self.m_scrollPos = scrollPos;
	
	scrollPos = -scrollPos;
	
	local posInFrame = scrollPos / self.m_viewLength * self.m_frameLength;
	local length = self.m_normalLength;
	
	if posInFrame < 0 then 
		length = self.m_normalLength + posInFrame;
		length = length < self.m_smallestLength and self.m_smallestLength or length;
		posInFrame = 0;
	elseif posInFrame + self.m_normalLength > self.m_frameLength then
		length = self.m_frameLength - posInFrame;
		if length < self.m_smallestLength then 
			posInFrame = self.m_frameLength - self.m_smallestLength;
			length = self.m_smallestLength;
		end
	end
	
	if self.m_direction == kVertical then
		ScrollBar.setPos(self,nil,self.m_startPos+posInFrame);
		ScrollBar.setSize(self,nil,length);
	else
		ScrollBar.setPos(self,self.m_startPos+posInFrame,nil);
		ScrollBar.setSize(self,length,nil);
	end

	ScrollBar.setVisible(self,true);
end

ScrollBar.setVisible = function(self, isVisible)
    isVisible = (self.m_frameLength < self.m_viewLength) and isVisible;
    ScrollBar.removFadeout(self);
    if isVisible then 
		Image.setVisible(self,isVisible);
	else
		ScrollBar.addFadeout(self);
    end
end

ScrollBar.setVisibleImmediately = function(self, isVisible)
    isVisible = (self.m_frameLength < self.m_viewLength) and isVisible;
    ScrollBar.removFadeout(self);
    Image.setVisible(self,isVisible);
end

ScrollBar.dtor = function(self)

end

---------------------------------private functions-----------------------------------------

ScrollBar.forceUpdate = function(self)
	ScrollBar.setScrollPos(self,self.m_scrollPos);
end

ScrollBar.addFadeout = function(self)
    ScrollBar.removFadeout(self);
    self.m_hasFadeout = true;
    ScrollBar.addPropTransparency(self,0,kAnimNormal,self.m_invisibleTime,-1,1,0);
end

ScrollBar.removFadeout = function(self)
    if self.m_hasFadeout then
        ScrollBar.removeProp(self,0);
        self.m_hasFadeout = false;
    end
end


