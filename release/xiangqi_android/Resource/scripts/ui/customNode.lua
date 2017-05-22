-- customNode.lua
-- Author: Vicent Gong
-- Date: 2013-07-01
-- Last modification : 2013-07-12
-- Description: Implement a custom rendering node

require("core/object");
require("core/drawing");

CustomNode = class(DrawingCustom,false);

CustomNode.ctor = function(self, renderType, userDataType, vertices, indices, textureFile, textureCoords, colorArray)
    if not (vertices and indices) then
		return;
	end

	self.m_vertexRes = new(ResDoubleArray,vertices);
	self.m_indexRes = new(ResUShortArray,indices);

	if textureFile then
		self.m_texRes = new(ResImage,textureFile);
	end

	if textureCoords then
		self.m_texCoordRes = new(ResDoubleArray,textureCoords);
	end

	if colorArray then
		self.m_colorRes = new(ResDoubleArray,colorArray);
	end

	super(self,renderType,userDataType,self.m_vertexRes,self.m_indexRes,self.m_texRes,self.m_texCoordRes,self.m_colorRes);
end

CustomNode.dtor = function(self)
    delete(self.m_vertexRes);
    self.m_vertexRes = nil;

    delete(self.m_indexRes);
    self.m_indexRes = nil;

    delete(self.m_texRes);
    self.m_texRes = nil;

    delete(self.m_texCoordRes);
    self.m_texCoordRes = nil;

    delete(self.m_colorRes);
    self.m_colorRes = nil;
end
