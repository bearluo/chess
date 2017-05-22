--region ImageEx.lua
--Author : BearLuo
--Date   : 2014/10/9
--此文件由[BabeLua]插件自动生成


require("core/object");
require("core/res");
require("core/drawing");

ImageEx = class(DrawingImage,false);

ImageEx.ctor = function(self, res, leftWidth, rightWidth, topWidth, bottomWidth)
	self.m_res = res;
	super(self,self.m_res,leftWidth,rightWidth,topWidth,bottomWidth);
end

ImageEx.setFile = function(self, file)
	self.m_res:setFile(file);
	Image.setResRect(self,0,self.m_res);
end

ImageEx.dtor = function(self)
	--delete(self.m_res);
	--self.m_res = nil;
end
