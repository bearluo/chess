require("ui/node");
require("core/system");
require("core/constants")


------------- 下面这些，如果本来没有，就加上如
kBlendSrcZero=0;
kBlendSrcOne=1;
kBlendSrcDstColor=2;
kBlendSrcOneMinusDstColor=3;
kBlendSrcSrcAlpha=4;
kBlendSrcOneMinusSrcAlpha=5;
kBlendSrcDstAlpha=6;
kBlendSrcOneMinusDstAlpha=7;
kBlendSrcSrcAlphaSaturate=8;

kBlendDstZero=0;
kBlendDstOne=1;
kBlendDstSrcColor=2;
kBlendDstOneMinusSrcColor=3;
kBlendDstSrcAlpha=4;
kBlendDstOneMinusSrcAlpha=5;
kBlendDstDstAlpha=6;
kBlendDstOneMinusDstAlpha=7;

DrawingBase.setBlend = function (self, blendSrc, blendDst)
  drawing_set_blend_mode (self.m_drawingID, blendSrc, blendDst);
end
-----------------------------

Mask = class(Node);

Mask.ctor = function (self, imageFile, imageMask)
	if not (imageFile and imageMask) then return end;

    self:loadRes(imageFile,imageMask);
    self:renderMask();
end

Mask.dtor = function (self)
	delete(self.m_prifileImage);
	delete(self.m_maskImage);

	self.m_prifileImage = nil;
	self.m_maskImage = nil;
end

Mask.setSize = function (self, w, h)  
    self.m_width = w or 0;
    self.m_height = h or 0;
          
    self.m_prifileImage:setSize(self.m_width, self.m_height);
    self.m_maskImage:setSize(self.m_width, self.m_height);
    self.super.setSize(self,self.m_width, self.m_height);
end

--Mask.getSize = function (self)
--     return Mask.getRealSize(self);
--end

-----------------------private function---------------------------------
Mask.loadRes = function (self, imageFile, imageMask)

    self.m_prifileImage = new(Image, imageFile, nil, 1);
    self.m_maskImage = new(Image, imageMask, nil, 1);
     
    self:addChild(self.m_maskImage);
    self:addChild(self.m_prifileImage);

    self.m_width, self.m_height = self.m_prifileImage:getSize();
    self:setSize(self.m_width, self.m_height);
end

Mask.renderMask= function (self)
    if self.m_prifileImage and self.m_maskImage then
        self.m_maskImage:setBlend(kBlendSrcOneMinusSrcAlpha, kBlendDstOneMinusSrcColor);
		    self.m_prifileImage:setBlend(kBlendSrcOneMinusDstAlpha, kBlendDstDstAlpha);
	  end
end

Mask.getRealSize =function(self)
    return self.m_width*System.getLayoutScale(), 
        self.m_height*System.getLayoutScale();
end

Mask.setFile = function(self,file)
    if self.m_prifileImage then
        self.m_prifileImage:setFile(file);
    end
end

Mask.getFile = function(self)
    if self.m_prifileImage then
        return self.m_prifileImage:getFile();
    end
end

Mask.setUrlImage = function(self,url,defaultFile)
    if self.m_prifileImage then
        self.m_prifileImage:setUrlImage(url,defaultFile);
    end
end

Mask.setUrlImageDownloadBack = function(self,obj,func)
    if self.m_prifileImage then
        self.m_prifileImage:setUrlImageDownloadBack(obj,func);
    end
end

Mask.setGray = function(self, gray)
    if self.m_prifileImage then
        self.m_prifileImage:setGray(gray)
    end
end
