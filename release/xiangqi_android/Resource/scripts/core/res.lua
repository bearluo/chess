-- res.lua
-- Author: Vicent Gong
-- Date: 2012-09-20
-- Last modification : 2013-07-12
-- Description: provide basic wrapper for resources manager

require("core/object");
require("core/constants");

---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] ResBase-------------------------------------------
---------------------------------------------------------------------------------------------

ResBase = class();

property(ResBase,"m_resID","ID",true,false);

ResBase.ctor = function(self)
    self.m_resID = res_alloc_id();
end

ResBase.dtor = function(self)
    res_free_id(self.m_resID);
end

ResBase.setDebugName = function(self, name)
	res_set_debug_name(self.m_resID,name or "");
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] ResImage------------------------------------------
---------------------------------------------------------------------------------------------

ResImage = class(ResBase);

property(ResImage,"m_width","Width",true,false);
property(ResImage,"m_height","Height",true,false);

ResImage.setFormatPicker = function(func)
	ResImage.s_formatPickerFunc = func;
end

ResImage.setFilterPicker = function(func)
	ResImage.s_filterPickerFunc = func;
end

ResImage.setPathPicker = function(func)
	ResImage.s_pathPickerFunc = func;
end

ResImage.ctor = function(self, file, format, filter)
	local fileName;
	if type(file) == "table" then
		fileName = file.file or "";
		self.m_subTexX = file.x;
		self.m_subTexY = file.y;
		self.m_subTexW = file.width;
		self.m_subTexH = file.height;
	else
		fileName = file or "";
	end

	local configPath = ResImage.s_pathPickerFunc and ResImage.s_pathPickerFunc(fileName) or "";
	self.m_fileName = configPath .. fileName;

	self.m_filter = self.m_filter 
					or filter 
					or (ResImage.s_filterPickerFunc and ResImage.s_filterPickerFunc(configPath,fileName))
					or kFilterLinear;
	self.m_format = self.m_format 
					or format 
					or (ResImage.s_formatPickerFunc and ResImage.s_formatPickerFunc(configPath,fileName))
					or kRGBA8888;

	res_create_image(0, self.m_resID, self.m_fileName, self.m_format,self.m_filter);
	self.m_width = self.m_subTexW or res_get_image_width(self.m_resID);
    self.m_height = self.m_subTexH or res_get_image_height(self.m_resID);		
end

ResImage.getSubTextureCoord = function(self)
	return self.m_subTexX,self.m_subTexY,self.m_subTexW,self.m_subTexH;
end

ResImage.releaseImage = function(self)
	res_free_image(self.m_resID);
end

ResImage.reloadImage = function(self)
	res_reload_image(self.m_resID);
end

ResImage.setFile = function(self, file, format, filter)
	ResImage.dtor(self);

	self.m_subTexX = nil;
	self.m_subTexY = nil;
	self.m_subTexW = nil;
	self.m_subTexH = nil;

	ResImage.ctor(self, file, format, filter)
end

ResImage.getFile = function(self)
    return self.m_fileName;
end

ResImage.dtor = function(self)
    res_delete(self.m_resID);
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] ResText-------------------------------------------
---------------------------------------------------------------------------------------------

ResText = class(ResBase);

property(ResText,"m_width","Width",true,false);
property(ResText,"m_height","Height",true,false);

ResText.setDefaultColor = function(r, g, b)
	ResText.s_r = r;
	ResText.s_g = g;
	ResText.s_b = b;
end

ResText.setDefaultFontNameAndSize = function(fontName, fontSize)
	ResText.s_fontName = fontName;
	ResText.s_fontSize = fontSize;
end

ResText.setDefaultTextAlign = function(align)
	ResText.s_align = align;
end

ResText.ctor = function(self, str, width, height, align, fontName, fontSize, r, g, b, multiLines)
    self.m_str = str;
    self.m_width = width or 0;
    self.m_height = height or 0;
    self.m_r = r or ResText.s_r or kDefaultTextColorR;
    self.m_g = g or ResText.s_g or kDefaultTextColorG;
    self.m_b = b or ResText.s_b or kDefaultTextColorB;
    self.m_align = align or ResText.s_align or kAlignLeft;
    self.m_font = fontName or ResText.s_fontName or kDefaultFontName;
    self.m_fontSize = fontSize or ResText.s_fontSize or kDefaultFontSize;
	self.m_multiLines = multiLines or kTextSingleLine;
--    if kPlatform == kPlatformAndroid then
--        dict_set_int("ResText","r",self.m_r)
--        dict_set_int("ResText","g",self.m_g)
--        dict_set_int("ResText","b",self.m_b)
--        res_create_text_image(0, self.m_resID, self.m_str, self.m_width, self.m_height,
--							255,255,255, self.m_align, self.m_font, self.m_fontSize, self.m_multiLines);
--    else
        res_create_text_image(0, self.m_resID, self.m_str == "" and " " or self.m_str, self.m_width, self.m_height,
							self.m_r,self.m_g,self.m_b, self.m_align, self.m_font, self.m_fontSize, self.m_multiLines);
--    end

    self.m_width = res_get_image_width(self.m_resID);
    self.m_height = res_get_image_height(self.m_resID);
end

ResText.setText = function(self, str, width, height, r, g, b)
    ResText.dtor(self);
    ResText.ctor(self,
    	str or self.m_str,
    	width or self.m_width,
    	height or self.m_height,
    	self.m_align,
    	self.m_font,
    	self.m_fontSize,
    	r or self.m_r,
    	g or self.m_g,
    	b or self.m_b,
    	self.m_multiLines);
end

ResText.dtor = function(self)
    res_delete(self.m_resID);
end
---- 文本大小适配
--ResText.s_def_w = 10--18
--ResText.s_def_h = 20
--ResText.s_scale = 1
--local TextAdaptation = function()
--    local a = new(ResText,"我",0, 0, kAlignTopLeft, nil, 20)
--    local w,h = a:getWidth(),a:getHeight()
--    delete(a)
--    ResText.s_scale = h / ResText.s_def_h
--end
--TextAdaptation()
---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] ResDoubleArray------------------------------------
---------------------------------------------------------------------------------------------

ResDoubleArray = class(ResBase);

ResDoubleArray.ctor = function(self, nums)
    res_create_double_array2(0, self.m_resID, nums);
end

ResDoubleArray.setData = function(self, nums)
	ResDoubleArray.dtor(self);
    ResDoubleArray.ctor(self,nums);
end

ResDoubleArray.dtor = function(self)
    res_delete(self.m_resID);
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] ResIntArray---------------------------------------
---------------------------------------------------------------------------------------------

ResIntArray = class(ResBase);

ResIntArray.ctor = function(self, nums)
    res_create_int_array2(0, self.m_resID, nums);
end

ResIntArray.setData = function(self, nums)
	ResIntArray.dtor(self);
    ResIntArray.ctor(self,nums);
end

ResIntArray.dtor = function(self)
    res_delete(self.m_resID);
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] ResUShortArray---------------------------------------
---------------------------------------------------------------------------------------------

ResUShortArray = class(ResBase);

ResUShortArray.ctor = function(self, nums)
    res_create_ushort_array2(0, self.m_resID, nums);
end

ResUShortArray.setData = function(self, nums)
	ResUShortArray.dtor(self);
    ResUShortArray.ctor(self,nums);
end

ResUShortArray.dtor = function(self)
    res_delete(self.m_resID);
end
