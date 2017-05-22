-- image.lua
-- Author: Vicent Gong
-- Date: 2012-09-24
-- Last modification : 2013-06-25
-- Description: Wrap a class to create a image quickly

require("core/object");
require("core/res");
require("core/drawing");

Image = class(DrawingImage,false);

Image.ctor = function(self, file, fmt, filter, leftWidth, rightWidth, topWidth, bottomWidth)
    self.m_url_type = 0;
	self.m_res = new(ResImage,file,fmt,filter);
	super(self,self.m_res,leftWidth,rightWidth,topWidth,bottomWidth);
end

Image.setFile = function(self, file)
    if self.m_res then
	    self.m_res:setFile(file);
	    Image.setResRect(self,0,self.m_res);
    end
end
require("config/path_config")
require(DATA_PATH.."cacheImageManager");
Image.dtor = function(self)
	delete(self.m_res);
	self.m_res = nil;
    if self.m_image_tag and self.m_image_url then
        CacheImageManager.unregistered(self.m_image_url,self.m_image_tag);
    end
end

Image.getFile = function(self)
    if not self.m_res then return "" end
    return self.m_res:getFile();
end

Image.s_url_type_defualt = 0; -- 不改变大小
Image.s_url_type_by_url = 1; -- 跟随网络图片

Image.setUrlImage = function(self,url,defaultFile,url_type)
    self.m_url_type = url_type or Image.s_url_type_defualt;
    if self.m_image_tag and self.m_image_url then
        CacheImageManager.unregistered(self.m_image_url,self.m_image_tag);
    end
    if defaultFile then
        self:setFile(defaultFile);
    end
    self.m_image_tag = CacheImageManager.registered(self,url);
    self.m_image_url = url;
end

Image.setUrlFile = function(self, file)
    Log.i("CacheImageManager setUrlFile"..(file or 'nil'));
    if not self.m_res then 
        self.m_image_tag = nil;
        self.m_image_url = nil;
        return 
    end
	self.m_res:setFile(file);
	Image.setResRect(self,0,self.m_res);
    -- CacheImageManager 已经释放掉
    self.m_image_tag = nil;
    self.m_image_url = nil;
    if self.m_url_type == Image.s_url_type_by_url then
        self:setSize(self.m_res:getWidth(),self.m_res:getHeight());
    end
    if self.m_urlImageDownloadBack_func then 
        self.m_urlImageDownloadBack_func(self.m_urlImageDownloadBack_obj,file);
    end
end

Image.setUrlImageDownloadBack = function(self,obj,func)
    self.m_urlImageDownloadBack_obj = obj;
    self.m_urlImageDownloadBack_func = func;
end
