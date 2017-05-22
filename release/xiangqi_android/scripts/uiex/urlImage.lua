require("core/object");
require("ui/image");
require("libs/json_wrap");
--require("gameData/userData");
require("update/httpFileGrap");
require("common/serialize");

UrlImage = class(Image,false);

UrlImage.s_index = 1;
UrlImage.s_maxDownloadTimes = 3;
UrlImage.s_cacheFileName = "urlImageCaches.lua";

UrlImage.s_downloading = {};
UrlImage.s_cacheDuring = 7;--缓存保存时限（天）
UrlImage.s_cacheFiles = new(Serialize, UrlImage.s_cacheFileName, UrlImage.s_cacheDuring);

UrlImage.ctor = function(self,defaultFile,url,fmt,filter)
	super(self,defaultFile,fmt,filter);
	
	self.m_downloadCount = 0;
	self:beginDownload(url);
end

UrlImage.setUrl = function(self,url)
	self.m_downloadCount = 0;
	self:beginDownload(url);
end

UrlImage.saveInfo = function(url,fileName,obj)
	if UrlImage.s_downloading[url] then 
		local temp = UrlImage.s_downloading[url].obj;
		temp[#temp + 1] = obj;

		return true;
	else
		UrlImage.s_downloading[url] = {["name"] = fileName, ["obj"] = {obj}}; 

		return false;
	end
end 

UrlImage.beginDownload = function(self,url)
	self.m_url = url or "";
	if not url then 
		return;
	end
	
	local temp = string.sub(url, 1,4) 
	if temp and temp ~= "http" then
		self:setFile(url);
		return;
	end

	local cacheName = UrlImage.s_cacheFiles:get(self.m_url);
	if cacheName then
		self:setFile(cacheName);
		return;
	end

	local downloadName = "" .. os.time() .. UrlImage.s_index .. ".png";
	local fileName = kUserData:getAndroidImagesPath() .. downloadName;	

	self.m_downloadCount = self.m_downloadCount + 1;

	local isDownloading;
	if self.m_downloadCount == 1 then 
		isDownloading = UrlImage.saveInfo(url,downloadName,self);
	end

	if not isDownloading then 	
		UrlImage.s_index = UrlImage.s_index + 1;
		HttpFileGrap.getInstance():grapFile(url,fileName,15000,nil,UrlImage.onDownloaded);
	end 
end

UrlImage.onDownloaded = function(_,isSucessed, fileName, url)
	if not isSucessed then
		if UrlImage.s_downloading[url] then 
			local objs = UrlImage.s_downloading[url].obj;
			for _,v in pairs(objs) do 
				if v.m_downloadCount <= UrlImage.s_maxDownloadTimes - 1 then 
					v:beginDownload(url);
				end
			end 
			return;
		end
	else
		if UrlImage.s_downloading[url] then 
			local objs = UrlImage.s_downloading[url].obj;	
			local name = UrlImage.s_downloading[url].name;
			for _,v in pairs(objs) do 
				v:setFile(name);			
				v.m_downloadCount = 0;
			end 		
			UrlImage.s_downloading[url] = nil;

			UrlImage.s_cacheFiles:set(url, name);
			
			UrlImage.s_cacheFiles:save();
		end		
	end	
end

UrlImage.dtor = function(self)
	for k,v in pairs(UrlImage.s_downloading) do 
		if self.m_url == k then 
			for kk,_ in pairs(v.obj) do 
   				v.obj[kk] = nil;
			end
		end 
	end 
end