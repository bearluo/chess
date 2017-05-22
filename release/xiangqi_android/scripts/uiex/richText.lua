------------------------------------------------------------------
-- $Id: richText.lua 15725 2014-05-16 09:45:54Z FuYao $
-- 富文本
------------------------------------------------------------------
require("core/constants")
require("core/object")
require("core/res")
require("core/drawing")
require("core/gameString")
require("ui/text")

kRichUnderLine = "__________________________________________________________________"

--Lua里的转义字符: ( ) . % + - * ? [ ^ $ 
function SpecialCharSafe2Str(str)
	return string.gsub(str, "[%(%)%.%%%+%-%*%?%[%]%^%$]", 
		function(ret)
			-- Log.w("try to find special char", ret)
			ret = "%"..ret
			return ret
		end)
end

RichImageConf = {
	------------------------ sample ------------------------
	[101] = {file="common/blank.png", w=80,h=80,},
	
	------------------add your images below-----------------
	[102] = {file="common/blank.png", w=32,h=32},
	[103] = {file="common/blank.png", w=32,h=32},

	
	-- max is [999]
}

local LIMIT_CALL = 20

RichText = class(Node)
------------------------------------------------------------------
-- note:
-- width/height: 传入parent的宽、高度，以便于正确计算kAlignTop, kAlignCenter, kAlignBottom
RichText.ctor = function(self, str, width, height, align, fontName, fontSize, r, g, b, bAutoNewLine,lineSpace)
	self.m_str = RichText.convert2SafeString(self, str)
    -- 将换行字符转换成 richtext 的换行标签
    self.m_str = string.gsub(self.m_str,"\n","#l");
	self.m_strSequence = {}			-- 保存子串
	self.m_richCtrl = {}			-- 效果控制
	self.m_richViews = {}			-- 保存Text or Image控件

	self.m_width = width or 0
	self.m_height = height or 0
	self.m_fontName = fontName or kDefaultFontName
	self.m_fontSize = fontSize or kDefaultFontSize
	self.m_align = align or kAlignTopLeft

	self.m_defaultR = r
	self.m_defaultG = g
	self.m_defaultB = b

	self.m_bAutoNewLine = bAutoNewLine

	-- 当前Text的属性
	self.m_curPosX = 0 				-- 文字排版
	self.m_curPosY = 0
	self.m_curIndex = 0 			-- 当前Text Index
	self.m_curHeight = 0 			-- 当前高度
    self.m_lineSpace = lineSpace or 0           -- 行距 -- bearluo

	self.m_totalHeight = 0 			-- 总高度
	self.m_totalWidth = 0 			--长度，所有行最长的

	-- 记录一行Text的始末index，用于行遍历self.m_richViews
	self.m_lineInfo = {}

	-- 递归深度处理
	self.m_callCount = 0

	if System.getPlatform() == kPlatformWin32 then
		-- self:debugBg(true)
	end

	self:analyzeText(self.m_str)
end

--RichText.setLineSpace = function(self,lineSpace)
--    self.m_lineSpace = lineSpace or self.m_lineSpace;
--end

RichText.getLineSpace = function(self)
    return self.m_lineSpace;
end

RichText.debugBg = function(self, bDebug)
	if bDebug then
		self.m_Bg = new(Image, "common/shade.png")
		self.m_Bg:setFillParent(true, true)
		self:addChild(self.m_Bg)
	end
end

RichText.dtor = function(self)
    if not self.m_richViews then
        return;
    end
	for i, textView in pairs(self.m_richViews) do
		if textView then
			delete(self.m_richViews[i])
			self.m_richViews[i] = nil
		end
	end
	self.m_richViews = nil
	self.m_strSequence = nil
	self.m_richCtrl = nil
	self.m_lineInfo = nil

	if self.m_Bg ~= nil then
		delete(self.m_Bg)
		self.m_Bg = nil
	end
end

---------------------------------private functions-----------------------------------------
RichText.convert2SafeString = function(self, str)
	str = (str == "" or not str) and " " or str;
	return str;
end

RichText.convert2SafePlatformString = function(self, str)
	str = (str == "" or not str) and " " or str;
	local platformStr = GameString.convert2Platform(str);
	platformStr = (platformStr == "" or not platformStr) and " " or platformStr;

	return platformStr;
end

RichText.__formatColor = function(self, ctrl, extra)
	if ctrl == "r" then
		return 255, 0, 0
	elseif ctrl == "g" then
		return 0, 255, 0
	elseif ctrl == "b" then
		return 0, 0, 255
	elseif ctrl == "c" then
		return tonumber("0x"..string.sub(extra,1,2)), tonumber("0x"..string.sub(extra,3,4)), tonumber("0x"..string.sub(extra,5,6))
	end
end

-- 文字对齐
RichText.__alignText = function(self)
	-- self.m_align = kAlignCenter		-- for test
	local function get_diff_x_y(total_width, my_height, align_height)
		local diffX = 0
		local diffY = 0
		if self.m_align == kAlignTopLeft then
			-- diffX = 0
			-- diffY = 0

		elseif self.m_align == kAlignLeft then
			-- diffX = 0
			diffY = (align_height - my_height)/2

		elseif self.m_align == kAlignBottomLeft then
			-- diffX = 0
			diffY = (self.m_height - self:getTotalHeight()) + (align_height - my_height)

		elseif self.m_align == kAlignTop then
			diffX = (self.m_width - total_width)/2
			-- diffY = 0

		elseif self.m_align == kAlignCenter then
			diffX = (self.m_width - total_width)/2
			diffY = (self.m_height - self:getTotalHeight())/2 + (align_height - my_height)/2

		elseif self.m_align == kAlignBottom then
			diffX = (self.m_width - total_width)/2
			diffY = (self.m_height - self:getTotalHeight()) + (align_height - my_height)

		elseif self.m_align == kAlignTopRight then
			diffX = (self.m_width - total_width)
			-- diffY = 0

		elseif self.m_align == kAlignRight then
			diffX = (self.m_width - total_width)
			diffY = (self.m_height - self:getTotalHeight())/2 + (align_height - my_height)/2

		elseif self.m_align == kAlignBottomRight then
			diffX = (self.m_width - total_width)
			diffY = (self.m_height - self:getTotalHeight()) + (align_height - my_height)

		end

		return diffX, diffY
	end

	for lineIndex, lineInfo in ipairs(self.m_lineInfo) do
		for i = lineInfo.startIndex, lineInfo.endIndex, 1 do
			local _, h = self.m_richViews[i]:getSize()
			local diffX, diffY = get_diff_x_y(lineInfo.totalWidth, h, lineInfo.maxHeight)
			local x, y = self.m_richViews[i]:getPos()

			self.m_richViews[i]:setPos(x + diffX, y + diffY)
		end
	end
end

-- 创建文字，应用属性
RichText.__createText = function(self, index, text, rich)
	if not self.m_richViews[index] then
		if rich.imageId then
			rich.imageId = tonumber(rich.imageId) or 0
			local conf = RichImageConf[rich.imageId] or RichImageConf[101]
			self.m_richViews[index] = new(Image, conf.file)
			self.m_richViews[index]:setSize(conf.w, conf.h)
		else
			rich.color = rich.color or {self.m_defaultR, self.m_defaultG, self.m_defaultB}
			-- NOTE: 在创建子View时，采用kAlignCenter的对齐方式，否则在真机上效果不好
			self.m_richViews[index] = new(Text, text, 0, 0, kAlignCenter, self.fontName, rich.fontSize or self.m_fontSize, unpack(rich.color))
			self.m_richViews[index]:setText(text)
			if rich.isUnderLine then
				local textUnderLine = new(Text, kRichUnderLine, 0, 0, kAlignBottomLeft, "", 12, unpack(rich.color))
				textUnderLine:setSize(self.m_richViews[index]:getSize())
				textUnderLine:setName("UnderLine")
				self.m_richViews[index]:addChild(textUnderLine)
			end
			if rich.clickId then
				self.m_richViews[index].clickId = rich.clickId
				if not self.m_eventCallbacks.touch.func then
					self:setEventTouch(self, self.onClick)
				end
			end
		end
		self:addChild(self.m_richViews[index])
	end

	self.m_richViews[index]:setPos(self.m_curPosX, self.m_curPosY)

	local width, height = self.m_richViews[index]:getSize()
	self.m_curHeight = math.max(self.m_curHeight, height + self.m_lineSpace);
	self.m_curPosX = self.m_curPosX + width
	self.m_curIndex = index
end

------------------------------------------
-- @desc:		分割长字,Image的话直接换行
-- @params:		externLength-超出部分长度
RichText.__splitText = function(self, index, cur_line_width, extra_char, isImage, str_left)
	str_left = str_left or ""
	if not self.m_richViews[index] then return "" end
	if not isImage then
		local str = self.m_richViews[index]:getText()
		if str == "" then
			return str_left
		end

		local sub_str1 = ToolKit.utf8_substring(str, 1, math.floor(self.m_width/self.m_fontSize*2)-extra_char)
		-- 安全处理，因为上一步不能保证截取出来的sub_str1一定比str短
		if string.len(sub_str1) == string.len(str) then
			sub_str1 = ToolKit.utf8_sub(sub_str1, 1, ToolKit.utf8_len(sub_str1)-1)
		end
		
		-- 注意！！string.find不接受函数作为参数
		local temp = SpecialCharSafe2Str(sub_str1)
		local s, e = string.find(str, temp)
		local sub_str2 = string.sub(str, e+1, #str)..str_left
		
		self.m_richViews[index]:setText(sub_str1, 0)
		local child = self.m_richViews[index]:getChildByName("UnderLine")
		if child then
			child:setSize(self.m_richViews[index]:getSize())			
		end

		local isOverEdge = self.m_richViews[index]:getSize() + cur_line_width - self.m_width
		if isOverEdge > 0 and self.m_callCount <= LIMIT_CALL then
			local ex = (isOverEdge > self.m_fontSize) and math.floor(isOverEdge/self.m_fontSize*2) or 1
			self.m_callCount = self.m_callCount + 1
			return self:__splitText(index, cur_line_width, extra_char+ex, false, sub_str2)
		end
		self.m_callCount = 0
		return sub_str2
	else
		return ""
	end
end

-- pre create 试探性创建文字，如果文字长度过长，会自动换行
RichText.__preCreate = function(self, lineIndex, index, txt)
	self:__createText(index, txt, self.m_richCtrl)

	local curLineWidth = self.m_lineInfo[lineIndex].totalWidth
	local tempLength = self.m_richViews[index]:getSize() + curLineWidth
	local isOverEdge = tempLength - self.m_width
	if isOverEdge > 0 and self.m_bAutoNewLine then
		local str = self:__splitText(index, curLineWidth, 0, self.m_richCtrl.imageId ~= nil, nil)
		table.insert(self.m_strSequence, 1, {ctrl="l", text=str})
	end
	return true
end

------------------------------------------------------------------
-- #r\#b\#g : red\blue\green
-- #l : new line
-- #s : set font size: s后面的两个数字用来控制字体大小
-- #n : set the ctrl to default : default size, default color
-- #c : set the color in base 16, "#cffffff哈哈" --> color="ffffff", text="哈哈"
-- #p : add an image "#p101" --> imageId = 101
-- #u : underline the text
-- #e : set as clickable event "#e(111)"" --> "111"
RichText.analyzeText = function(self, str)
	-- 分割 #
	for token in string.gfind(str, "#?([^#]+)#?") do
		-- Log.i(token, string.find(str, "#"..token))
		if string.find(str, "#"..SpecialCharSafe2Str(token)) then
			local keyCtrl = string.sub(token, 1, 1)
			if keyCtrl == "p" then
				-- 处理插图: #pxxxtext --> #pxxx #dtext
				table.insert(self.m_strSequence, {ctrl="p", text=string.sub(token, 2, 4)})
				local sub_str = string.sub(token, 5, #token)
				if sub_str ~= "" then
					table.insert(self.m_strSequence, {ctrl="d", text=sub_str})
				end

			elseif keyCtrl == "e" then
				-- 处理点击
				local ret1, ret2 = nil, nil
				string.gsub(token, "e%(%D*(%d*).*%)(.*)", function(str1, str2) ret1 = str1; ret2 = str2; end)
				Log.w("RichText click test", ret1, ret2)
				table.insert(self.m_strSequence, {ctrl="e", text=ret1})
				if ret2 then
					table.insert(self.m_strSequence, {ctrl="d", text=ret2})
				end
			else
				table.insert(self.m_strSequence, {ctrl=keyCtrl, text=string.sub(token, 2, string.len(token)),})
			end
		else
			table.insert(self.m_strSequence, {ctrl="n", text=token,})
		end
	end
	-- Log.w("final str sequence", self.m_strSequence)
	self:createFromStr()
end

-- 根据#创建
RichText.createFromStr = function(self)
	local index = 1
	local lineIndex = 1
	self.m_lineInfo[lineIndex] = {startIndex = index, endIndex = nil, totalWidth = 0, maxHeight = self.m_curHeight}
	-- for _, txtInfo in ipairs(self.m_strSequence) do
	while next(self.m_strSequence) do
		local _, txtInfo = next(self.m_strSequence)
		local text = txtInfo.text
		self.m_richCtrl.imageId = nil

		if txtInfo.ctrl == "r" then
			self.m_richCtrl.color = {self:__formatColor("r")}

		elseif txtInfo.ctrl == "g" then
			self.m_richCtrl.color = {self:__formatColor("g")}

		elseif txtInfo.ctrl == "b" then
			self.m_richCtrl.color = {self:__formatColor("b")}

		elseif txtInfo.ctrl == "c" then
			local extra = string.sub(txtInfo.text, 1, 6)
			text = string.sub(txtInfo.text, 7, string.len(txtInfo.text))
			self.m_richCtrl.color = {self:__formatColor("c", extra)}

		elseif txtInfo.ctrl == "l" then
			-- 记录上一行的始末index，以及起始Y的位置，并把起始X和curHeight置0
			self.m_lineInfo[lineIndex].endIndex = index - 1
			lineIndex = lineIndex + 1
			self.m_lineInfo[lineIndex] = {startIndex = index, endIndex = nil, totalWidth = 0}
			self.m_totalHeight = self.m_totalHeight + self.m_curHeight;

			self.m_curPosX = 0
			self.m_curPosY = self:getTotalHeight();
			-- self.m_curHeight = 0

		elseif txtInfo.ctrl == "s" then
			self.m_richCtrl.fontSize, text = string.sub(txtInfo.text, 1, 2), string.sub(txtInfo.text, 3, string.len(txtInfo.text))

		elseif txtInfo.ctrl == "p" then
			self.m_richCtrl.imageId = string.sub(txtInfo.text, 1, 3)
			text = ""

		elseif txtInfo.ctrl == "u" then
			self.m_richCtrl.isUnderLine = true

		elseif txtInfo.ctrl == "e" then
			self.m_richCtrl.clickId = tonumber(text)
			text = ""

		elseif txtInfo.ctrl == "n" then
			self.m_richCtrl.color = {self.m_defaultR, self.m_defaultG, self.m_defaultB}
			self.m_richCtrl.fontSize = self.m_fontSize
			self.m_richCtrl.isUnderLine = false
			self.m_richCtrl.clickId = nil

		elseif txtInfo.ctrl == "d" then
			-- skip
		end

		-- Log.i("RichText ctrl&text: ", txtInfo.ctrl, text)
		table.remove(self.m_strSequence, 1)
		if text ~= "" or self.m_richCtrl.imageId ~= nil then
			local bRet = self:__preCreate(lineIndex, index, text)
			if bRet then
				-- record line info
				self.m_lineInfo[lineIndex].maxHeight = self.m_curHeight 	-- 这一行里最高的字
				self.m_lineInfo[lineIndex].totalWidth = self.m_richViews[index]:getSize() + self.m_lineInfo[lineIndex].totalWidth
				self.m_totalWidth = math.max(self.m_lineInfo[lineIndex].totalWidth, self.m_totalWidth);
				index = index + 1
			end
		end
	end

	self.m_totalHeight = self.m_totalHeight + self.m_curHeight
	self.m_lineInfo[lineIndex].endIndex = index - 1
	-- Log.i("RichText line info: ", self.m_lineInfo)
	self:setSize(self.m_totalWidth,self.m_totalHeight);
	self:__alignText()
end

RichText.setText = function(self, str, width, height, align, fontName, fontSize, r, g, b)
	RichText.dtor(self)
	RichText.ctor(self, str,
		width or self.m_width,
		height or self.m_height,
		align or self.m_align,
		fontName or self.m_fontName,
		fontSize or self.m_fontSize,
		r or self.m_defaultR,
		g or self.m_defaultG,
		b or self.m_defaultB,
		self.m_bAutoNewLine)
end

RichText.getText = function(self)
	return self.m_str;
end

RichText.getTotalHeight = function(self)
	return math.max(self.m_curHeight, self.m_totalHeight)
end

RichText.setSize = function(self,w,h)
	w = w or self.m_totalWidth;
	h = h or self.m_totalHeight;
	self.m_width = math.max(self.m_totalWidth,w);
	self.m_height = math.max(self.m_totalHeight,h);

	DrawingBase.setSize(self,self.m_width,self.m_height);
end 

RichText.getSize = function(self)
	if not self.m_bAutoNewLine then
		return self.m_totalWidth, self.m_height
	else
		return self.m_width,self.m_height;
	end
end 

RichText.setOnClick = function(self, obj, func)
	self.m_callBackObj = obj
	self.m_callBackFunc = func
end

RichText.onClick = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
	self.m_curClickId = self.m_curClickId or nil
	if finger_action == kFingerDown then
		local index, view = self:__getCurTouchViewAndIndex(x, y)
		if view then
			self.m_curClickId = view.clickId
			self:__onClickOffset(self.m_curClickId, false)
		end
	elseif finger_action == kFingerUp then
		if self.m_curClickId then
			self:__onClickOffset(self.m_curClickId, true)
			if self:__isInteract(self, x, y) then
				if self.m_callBackFunc then
					self.m_callBackFunc(self.m_callBackObj, self.m_curClickId)
				end
			end
		end
	end
end

RichText.__isInteract = function(self, view, x, y)
	local m_x, m_y = view:getAbsolutePos()
	local w, h = view:getSize()
	if x < m_x or y < m_y or x > m_x+w or y > m_y+h then 
		return false
	end
	return true
end

RichText.__getCurTouchViewAndIndex = function(self, x, y)
	if not self:__isInteract(self, x, y) then 
		return nil
	end
	
	for index, view in ipairs(self.m_richViews) do
		if self:__isInteract(view, x, y) then
			return index, view
		end
	end
	return nil
end

RichText.__onClickOffset = function(self, click_id, isUp)
	for index, view in ipairs(self.m_richViews) do
		if view.clickId and view.clickId == click_id then
			local _, y = view:getPos()
			view:setPos(nil, isUp and y-5 or y+5)
		end
	end
end