-- text.lua
-- Author: Vicent Gong
-- Date: 2012-09-24
-- Last modification : 2013-06-24
-- Description: Implement a single line text

require("core/constants");
require("core/object");
require("core/res");
require("core/drawing");
require("core/gameString");

Text = class(DrawingImage,false);

---------------------costruct function  -------------------------------------------------
--Parameters: 	str 				-- the text to display
-- 				width , height	   	-- the region to show
--				algin				-- the alignment of the text to show in the region
									-- It can be 	kAlignCenter=0
									--				kAlignTop=1
									--				kAlignTopRight=2
									--				kAlignRight=3
									--				kAlignBottomRight=4
									--				kAlignBottom=5
									--				kAlignBottomLeft=6
									--				kAlignLeft=7 
									--				kAlignTopLeft=8
--				fontName			-- the font name 
--				fontSize			-- the font size
--				r,g,b				-- the color of the text,
									-- it can be default one , (0,0,0)
--Return 	:   no return
-----------------------------------------------------------------------------------------
Text.ctor = function(self, str, width, height, align, fontName, fontSize, r, g, b)
	self.m_str = Text.convert2SafeString(self,str);
	local platformstr = Text.convert2SafePlatformString(self,str);

	width = width or 0;
	height = height or 0;
	
    self.m_res = new(ResText,platformstr,width,height,align,fontName,fontSize,r,g,b,kTextSingleLine);
	super(self,self.m_res);
end

Text.setText = function(self, str, width, height, r, g, b)
	self.m_str = Text.convert2SafeString(self,str);
	local platformstr = Text.convert2SafePlatformString(self,str);

    if self.m_res then
	    self.m_res:setText(platformstr,width,height,r,g,b);
        Text.setSize(self,self.m_res:getWidth(),self.m_res:getHeight());
        self:updateTextStr()
    end
end

Text.getText = function(self)
	return self.m_str;
end

Text.dtor = function(self)
	delete(self.m_res);
	self.m_res = nil;
end
--[Comment]
-- w = -1 关闭该功能
function Text:setEllipsis(w,str)
    self.mEllipsisStr = str or "..."
    self.mEllipsisMaxW = w or select(1,self:getSize())
    self.mEllipsisWork = true
end

function Text:updateTextStr()
    if not self.m_res or not self.mEllipsisWork then return end
    local width = self.m_res:getWidth()
    local index = string.lenutf8(self.m_str)
    local ret = nil
    for i=index,1,-1 do
        if width <= self.mEllipsisMaxW then break end
        ret = string.subutf8(self.m_str,1,i) .. "..."
        local platformstr = Text.convert2SafePlatformString(self,ret)
        local res = new(ResText,platformstr,0,0,self.m_res.m_align, self.m_res.m_font, self.m_res.m_fontSize,0,0,0,self.m_res.m_multiLines)
        width = res:getWidth()
        delete(res)
    end
    if ret then
	    self.m_res:setText(ret,width,height,r,g,b);
        Text.setSize(self,self.m_res:getWidth(),self.m_res:getHeight()); 
    end
end

---------------------------------private functions-----------------------------------------

Text.convert2SafeString = function(self, str)
	str = (str == "" or not str) and "" or str;
	return str;
end

Text.convert2SafePlatformString = function(self, str)
	str = (str == "" or not str) and "" or str;
	local platformStr = GameString.convert2Platform(str);
	platformStr = (platformStr == "" or not platformStr) and "" or platformStr;

	return platformStr;
end		