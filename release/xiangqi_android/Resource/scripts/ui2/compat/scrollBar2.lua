--
-- UI2 Library, Version: 1.0 Alpha (0.99.2.2058-SNAPSHOT)
-- 
-- This file is a part of UI2 Library.
--
-- Author:
-- Xiaofeng Yang     2015
-- Vicent.Gong       2012
--
--

require("core/object");
require("core/global");
require("ui/image");

ScrollBar2 = class(Image,false);

ScrollBar2.s_defaultBgImage = "ui/scroll.png";
ScrollBar2.s_defaultInvisibleTime = 300;
ScrollBar2.s_defaultSmallestLength = 8;

ScrollBar2.setDefaultImage = function(filePath)
	ScrollBar2.s_bgImage = filePath or ScrollBar2.s_defaultBgImage;
end

ScrollBar2.setDefaultInvisibleTime = function(time)
	ScrollBar2.s_invisibleTime = time or ScrollBar2.s_defaultInvisibleTime;
end

ScrollBar2.setDefaultSmallestLength = function(smallestLength)
	ScrollBar2.s_smallestLength = smallestLength or ScrollBar2.s_defaultSmallestLength;
end

ScrollBar2.ctor = function(self, direction, frameLength, viewLength)
	local file = ScrollBar2.s_bgImage or ScrollBar2.s_defaultBgImage;
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
	
	self.m_invisibleTime = ScrollBar2.s_invisibleTime or ScrollBar2.s_defaultInvisibleTime;
	self.m_smallestLength = ScrollBar2.s_smallestLength or ScrollBar2.s_defaultSmallestLength;
end

ScrollBar2.setFile = function(self, file)
	Image.setFile(self,file 
					or ScrollBar2.s_bgImage 
					or ScrollBar2.s_defaultBgImage);
end

ScrollBar2.setInvisibleTime = function(self, invisibleTime)
	self.m_invisibleTime = invisibleTime 
						or ScrollBar2.s_invisibleTime 
						or ScrollBar2.s_defaultInvisibleTime;
end

ScrollBar2.setSmallestLength = function(self, smallestLength)
	self.m_smallestLength = smallestLength 
						or ScrollBar2.s_smallestLength 
						or ScrollBar2.s_defaultSmallestLength;
end

ScrollBar2.setFrameLength = function(self, frameLength)
	self.m_frameLength = frameLength or self.m_frameLength;
	self.m_normalLength = self.m_frameLength^2 / self.m_viewLength;
	
	ScrollBar2.forceUpdate(self);
	ScrollBar2.setVisibleImmediately(self);
end

ScrollBar2.setViewLength = function(self, viewLength)
	self.m_viewLength = viewLength or self.m_viewLength;
	self.m_normalLength = self.m_frameLength^2 / self.m_viewLength;
	
	ScrollBar2.forceUpdate(self);
	ScrollBar2.setVisibleImmediately(self);
end

ScrollBar2.setStartPos = function(self, pos)
	self.m_startPos = pos or self.m_startPos;
	ScrollBar2.forceUpdate(self);
end

ScrollBar2.setScrollPos = function(self, scrollPos)
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
		ScrollBar2.setPos(self,nil,self.m_startPos+posInFrame);
		ScrollBar2.setSize(self,nil,length);
	else
		ScrollBar2.setPos(self,self.m_startPos+posInFrame,nil);
		ScrollBar2.setSize(self,length,nil);
	end

	ScrollBar2.setVisible(self,true);
end

ScrollBar2.setVisible = function(self, isVisible)
    isVisible = (self.m_frameLength < self.m_viewLength) and isVisible;
    ScrollBar2.removFadeout(self);
    if isVisible then 
		Image.setVisible(self,isVisible);
	else
		ScrollBar2.addFadeout(self);
    end
end

ScrollBar2.setVisibleImmediately = function(self, isVisible)
    isVisible = (self.m_frameLength < self.m_viewLength) and isVisible;
    ScrollBar2.removFadeout(self);
    Image.setVisible(self,isVisible);
end

ScrollBar2.dtor = function(self)

end

---------------------------------private functions-----------------------------------------

ScrollBar2.forceUpdate = function(self)
	ScrollBar2.setScrollPos(self,self.m_scrollPos);
end

ScrollBar2.addFadeout = function(self)
    ScrollBar2.removFadeout(self);
    self.m_hasFadeout = true;
    ScrollBar2.addPropTransparency(self,0,kAnimNormal,self.m_invisibleTime,-1,1,0);
end

ScrollBar2.removFadeout = function(self)
    if self.m_hasFadeout then
        ScrollBar2.removeProp(self,0);
        self.m_hasFadeout = false;
    end
end


