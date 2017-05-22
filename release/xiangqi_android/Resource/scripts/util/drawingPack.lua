--用于合并drawing的操作。


local DrawingPackRes = class(ResBase)

property(DrawingPackRes,"m_width","Width",true,false);
property(DrawingPackRes,"m_height","Height",true,false);

DrawingPackRes.ctor = function(self,width,height)
	self.m_width = width 
	self.m_height = height
	res_create_dynamic_image(0, self.m_resID, width, height, 1);
	res_set_debug_name(self.m_resID, "DrawingPackRes")
end

DrawingPackRes.dtor = function(self)
	res_delete(self.m_resID)
end


----------------------------------------
local DrawingPackImage = class(DrawingImage, false)
DrawingPackImage.ctor = function(self,width,height)
	self.m_res = new(DrawingPackRes,width,height)
	self._is_pack_drawing = true
	super(self, self.m_res)
	drawing_set_debug_name(self.m_drawingID, "DrawingPackImage")
end

DrawingPackImage.packFromDrawing = function(self, drawing)
	res_set_image_from_drawing(self.m_res:getID(), drawing:getID(), 0)
end

DrawingPackImage.dtor = function(self)
	delete(self.m_res)
	self.m_res = nil
end


-----------------------------
-- 将此drawing(及其下所有子drawing)进行一次截图操作，生成一整张合并后的新图片。
-- 然后将此新图片添加到此drawing的子节点，并隐藏此drawing及其他所有的子drawing(此隐藏操作不会改变visible属性)。
-- 此操作可以减少绘制操作，提升性能。
-- 但进行此操作后，对drawing及子drawing进行的任何操作都不会生效(除addchild外)，除非再次调用packDrawing方法。
DrawingBase.packDrawing = function(self, packing)
	if self.m_pack_drawing_img then 
		self:removeChild(self.m_pack_drawing_img, true)
		self.m_pack_drawing_img = nil
	end
	
	local function hideOrShow(drawing, show)
		if drawing._is_pack_drawing then 
			return 
		end
		-- drawing_set_transparency(drawing.m_drawingID, 1, show and drawing:getTransparency() or 1.01)
		drawing_set_force_hide(drawing.m_drawingID, show and 0 or 1);
		local children = drawing:getChildren()
		if children and #children>0 then 
			for i,child in ipairs(children) do
				hideOrShow(child, show)
			end
		end
	end

	-- 恢复
	if not packing then 
		hideOrShow(self, true)
		return
	end

	local screenW = System.getScreenWidth()
	local screenH = System.getScreenHeight()
	local realW,realH = self:getRealSize()
	local w,h = self:getSize()
	local align = self:getAlign()
	local newW = math.max(realW, screenW)
	local newH = math.max(realH, screenH)
	local fillParentWidth, fillParentHeight = self:getFillParent()
	local fillRegion, fillRegionTopLeftX, fillRegionTopLeftY, 
			fillRegionBottomRightX,fillRegionBottomRightY = self:getFillRegion()

	local function pack()
		local img = new(DrawingPackImage,newW,newH)
		local dtor = img.dtor 
		img.dtor = function(img)
			dtor(img)
			self.m_pack_drawing_img = nil
		end
		img:packFromDrawing(self)
		img:setSize(w, h)
		img:setAlign(align)
		img:setFillParent(fillParentWidth, fillParentHeight)
		img:setFillRegion(fillRegion, fillRegionTopLeftX, 
			fillRegionTopLeftY, fillRegionBottomRightX, fillRegionBottomRightY)
		return img
	end

	hideOrShow(self, true)
	local img = pack()
	self.m_pack_drawing_img = img
	self:addChild(img)
	hideOrShow(self, false)
	return img
end

-- 对drawing及其所有子结点进行一次截图操作
-- 返回截图后生成的新drawing
function drawingShot(drawing)
	local hadPack = drawing.m_pack_drawing_img~=nil and true or false
	local img = drawing:packDrawing(true)
	drawing:removeChild(img, false)
	drawing.m_pack_drawing_img = nil
	drawing:packDrawing(false)
	if hadPack then 
		drawing:packDrawing(true)
	end
	return img
end