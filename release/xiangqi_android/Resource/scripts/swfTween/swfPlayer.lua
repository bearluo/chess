-- Author: Fred Zeng
-- Date: 2016-03-10 19:44
-- Version 1.2.0  public 2015-12-15 增加特定节点的回调
-- Description: 
require("util/TableLib");
SwfPlayer = class(Node)

SwfPlayer.ctor = function(self,swfInfo,pinMap)
	self.m_swfInfo = swfInfo;
	self.m_spriteMap = {};
	self.m_imgMap = {};
	self.m_depthTypeMap = {};--记录层级的类型，目前用于区分遮罩和非遮罩层（{sDepth,eDepth} 遮罩，nil 非遮罩）
	self:setSize(swfInfo["width"],swfInfo["height"]);
	self.m_imgPinMap = pinMap or _G[swfInfo["imagePinMapName"]];
	assert(self.m_imgPinMap ~= nil,swfInfo["imagePinMapName"]);
	self.m_imgCache = nil;
end

-- 设置完成事件回调
SwfPlayer.setCompleteEvent = function(self, obj, func)
    self.m_completeCallback = self.m_completeCallback or {};
	self.m_completeCallback.obj = obj;
	self.m_completeCallback.func = func;
end
--设置帧事件，到第frame帧会调用
SwfPlayer.setFrameEvent = function(self,obj,func,frame)
	self.m_frameCallback = self.m_frameCallback or {};
	self.m_frameCallback[frame] = {};
	self.m_frameCallback[frame].obj = obj;
	self.m_frameCallback[frame].func = func;
end

SwfPlayer.processFrameEvent = function(self,frame)
	if self.m_frameCallback and self.m_frameCallback[frame] then
		if self.m_frameCallback[frame].obj and self.m_frameCallback[frame].func then
            self.m_frameCallback[frame].func(self.m_frameCallback[frame].obj,frame);
        end
	end
end

SwfPlayer.setNodeCallback = function(self,nodeName,obj,func)
	self.m_nodeCallback = self.m_nodeCallback or {};
	self.m_nodeCallback[nodeName] = {};
	self.m_nodeCallback[nodeName].obj = obj;
	self.m_nodeCallback[nodeName].func = func;
end

SwfPlayer.processNodeCallback = function(self,nodeName,node)
	if self.m_nodeCallback and self.m_nodeCallback[nodeName] then
		if self.m_nodeCallback[nodeName].func then
            self.m_nodeCallback[nodeName].func(self.m_nodeCallback[nodeName].obj,nodeName,node);
        end
	end
end

--暂停。frame为停在第几帧，默认为当前帧
SwfPlayer.pause = function(self,frame)
	self:stopTimer();
	local f = frame or self.m_currframe or 1;
	self:gotoAndStop(f);
end

--跳到并停留在某一帧
SwfPlayer.gotoAndStop = function(self,frame)
	assert(frame <= tonumber(self.m_swfInfo["fnum"]),"the frame can not be more than the total frame:" .. self.m_swfInfo["fnum"])
	self.m_currframe = 1;
	for i = 1,frame do
		self:onTimer();
	end
end

--parent   		  父节点
--frame    		  第几帧开始播放
--isKeep          播放完是否停留在最后一帧
--repeatCount 	  重复播放次数，-1或0为无限循环播放，默认1次
--delay           延迟播放
SwfPlayer.play = function(self,frame,isKeep,repeatCount,delay)	
	if frame and frame > 1 then
		self:gotoAndStop(frame);
	end
	self.m_currframe = frame or 1;
	self.m_repeatCount = repeatCount or 1;
	self.m_isKeep = isKeep;
	self.m_delay = delay or -1;
	self:statrTimer();
	self.m_depthTypeMap = {};
	self.m_playTimes = 0;
end

SwfPlayer.stop = function(self)
	self:stopTimer();
	if self.m_completeCallback then
        if self.m_completeCallback.obj and self.m_completeCallback.func then
            self.m_completeCallback.func(self.m_completeCallback.obj);
        end
    end
    if self.m_isKeep ~= true then
		-- self:dtor();
		delete(self)
	end
end

SwfPlayer.statrTimer = function(self)
	self:stopTimer();
	self.m_animTimer = new(AnimInt , kAnimRepeat, 0, 1 ,1/self.m_swfInfo["fps"] * 1000, self.m_delay);
  	self.m_animTimer:setDebugName("AnimInt|self.m_animTimer");
 	self.m_animTimer:setEvent(self, self.onTimer);
end

SwfPlayer.isNeedRepeat = function(self)
	return self.m_repeatCount <= 0 or self.m_playTimes < self.m_repeatCount;
end

SwfPlayer.onTimer = function(self)
	-- if true then return end;
	if self.m_currframe > tonumber(self.m_swfInfo["fnum"]) then
		self.m_playTimes = self.m_playTimes + 1;
		local isRepeat = self:isNeedRepeat();
		if self.m_isKeep ~= true or isRepeat then
			for k,v in pairs(self.m_spriteMap) do
		   		delete(v);
		   		self.m_spriteMap[k] = nil;
	   		end
	   		self.m_spriteMap = {};
	   	end
	   	self.m_currframe = 1;
	   	if isRepeat ~= true then
			self:stop();
			return;
		end
	end
	local frameInfo = self.m_swfInfo["frames"][self.m_currframe];

	if not frameInfo then
		self:stop();
		return;
	end

	for i = 1,#frameInfo do
		local info = frameInfo[i];
		if info[1] == 1 then
			self.m_imgMap[info[2]] = info[3];
		elseif info[1] == 2 then
			--设置遮罩，延迟到所有对象显示完成再执行
			if info[6] ~= 0 or self.m_depthTypeMap[info[2]] then
				local matrix = nil;
				local cid = 0;
				local clipDepth = 0;
				if info[3] == 0 then
					if self.m_depthTypeMap[info[2]] then
						cid = self.m_depthTypeMap[info[2]][1];
						clipDepth = self.m_depthTypeMap[info[2]][3];
					end
				else
					cid = info[3];
					clipDepth = info[6];
				end

				if info[4] ~= 0 then
					matrix = {info[4][1],info[4][2],info[4][3],info[4][4],info[4][5],info[4][6]};
				end

				self.m_depthTypeMap[info[2]] = {cid,info[2],clipDepth,matrix}; -- 遮罩层
			else
				local sprite;
				if info[7] and info[7] ~= 0 then
					if info[3] ~= 0 then
						sprite = new(SwfNode,info[3],self.m_imgPinMap);
						sprite:setName("n_"..info[2]);
						sprite:setLevel(info[2]);
						self:addChild(sprite);
						self.m_spriteMap[info[3].. "_"..info[2]] = sprite;
						self:processNodeCallback(info[7],sprite)
					else
						sprite = self:getChildByName("n_"..info[2]);
					end
				else
					if info[3] ~= 0 then
						sprite = self:getChildByName("n_"..info[2]);
						if sprite then
							local imgName = self.m_swfInfo["imageName"] .. "_" .. self.m_imgMap[info[3]] .. ".png"
							sprite:changeImg(info[3],imgName);
							sprite:setVisible(true);
						else
							sprite = self:createSprite(info[3],info[2]);
							sprite:setName("n_"..info[2]);
							sprite:setLevel(info[2]);
							self:addChild(sprite);
						end
					else 
						sprite = self:getChildByName("n_"..info[2]);
					end
				end

				if info[4] ~= 0 then
					sprite:setMatrix(info[4][1],info[4][2],info[4][3],info[4][4],info[4][5],info[4][6]);
				end

				if info[5] ~= 0 then
					sprite:setColorTransform(info[5][1],info[5][2],info[5][3],info[5][4],
											info[5][5],info[5][6],info[5][7],info[5][8]);
				end
			end
		elseif info[1] == 3 then
			local lastSprite = self:getChildByName("n_"..info[2]);
			if lastSprite then
				lastSprite:setName("");
				lastSprite:removeMask();
				self:removeChild(lastSprite);
				lastSprite:setVisible(false);
			end
			if self.m_depthTypeMap[info[2]] then
				self:removeMask(self.m_depthTypeMap[info[2]][2],self.m_depthTypeMap[info[2]][3]);
				self.m_depthTypeMap[info[2]] = nil;
			end
			
		end
	end

	for k,v in pairs(self.m_depthTypeMap) do
		self:setMask(v[2],v[3],v[1],v[4])
	end

	self:processFrameEvent(self.m_currframe);
	self.m_currframe = self.m_currframe + 1;
	
end

SwfPlayer.setMask = function(self,sDepth,eDepth,cid,matrix_tb)
	local imgName = self.m_swfInfo["imageName"] .. "_" .. self.m_imgMap[cid] .. ".png";
	for i = sDepth + 1,eDepth do
		local sprite = self:getChildByName("n_"..i);
		if sprite then
			sprite:setMask(imgName,matrix_tb);
		end
	end
end

SwfPlayer.removeMask = function(self,sDepth,eDepth)
	for i = sDepth + 1,eDepth do
		local sprite = self:getChildByName("n_"..i);
		if sprite then
			sprite:removeMask();
		end
	end
end

SwfPlayer.stopTimer = function(self)
	if self.m_animTimer then
		delete(self.m_animTimer);
		self.m_animTimer = nil;
	end
end

SwfPlayer.createSprite = function(self,cid,depth)
	if self.m_spriteMap[cid.. "_"..depth] then
		self.m_spriteMap[cid.. "_"..depth]:setVisible(true);
		return self.m_spriteMap[cid.. "_"..depth];
	end
	local imgName = self.m_swfInfo["imageName"] .. "_" .. self.m_imgMap[cid] .. ".png";
	local sprite = new(SwfSprite,cid,imgName,self.m_imgPinMap);
	self.m_spriteMap[cid.. "_"..depth] = sprite;

	if self.m_imgCache == nil then
		self.m_imgCache = new(Image,self.m_imgPinMap[imgName]);
	end
	return sprite;
end

SwfPlayer.dtor = function(self)
	self:stopTimer();

	if self.m_spriteMap then
	   	for k,v in pairs(self.m_spriteMap) do
	   		delete(v);
	   		self.m_spriteMap[k] = nil;
	   	end
	end
   	self.m_spriteMap = nil;

   	self.m_completeCallback = nil;
   	self.m_frameCallback = nil;
   	if self.m_imgCache then
   		delete(self.m_imgCache)
   	end
   	self.m_imgCache = nil;
   	self.m_imgPinMap = nil;
end

---/////////SwfSprite class////////////
SwfSprite = class(Image,false)

SwfSprite.ctor = function(self,cid,imgName,imgPinMap)
	self.m_cid = cid;
	self.m_imgName = imgName;
	self.m_imgPinMap = imgPinMap;
	super(self,self.m_imgPinMap[imgName])
end

SwfSprite.setMask = function(self,maskImgName,matrix_tb)
	if self.m_maskImgName ~= maskImgName then
		self:removeMask();
		self.m_maskImgName = maskImgName;
		self.m_mask = new(Image,self.m_imgPinMap[maskImgName]);
		
		self.m_parent:addChild(self.m_mask); --必须添加到显示列表，否则遮罩位置不更新
	end
	
	if matrix_tb and table.equal(self.m_maskMatrix,matrix_tb) == false then
		local a,b,c,d,sx,sy = matrix_tb[1],matrix_tb[2],matrix_tb[3],matrix_tb[4],matrix_tb[5],matrix_tb[6];
		sx = sx * System.getLayoutScale();
		sy = sy * System.getLayoutScale();
		drawing_set_matrix(self.m_mask.m_drawingID,{a,b,0,0,c,d,0,0,0,0,1,0,sx,sy,1,1});
		self:setMaskDrawing(self.m_mask);
		self.m_maskMatrix = matrix_tb;
	end
end

SwfSprite.removeMask = function(self)
	if self.m_mask then
		self:delMaskDrawing(self.m_mask);
		delete(self.m_mask);
		self.m_mask = nil;
	end
	self.m_maskImgName = nil;
	self.m_maskMatrix = nil;
end

SwfSprite.changeImg = function(self,cid,imgName)
	self.m_cid = cid;
	self.m_imgName = imgName;
	self:setFile(self.m_imgPinMap[imgName]);
	self:setSize(self.m_res.m_width,self.m_res.m_height);
end

SwfSprite.setMatrix = function(self,a,b,c,d,sx,sy)
	sx = sx * System.getLayoutScale();
	sy = sy * System.getLayoutScale();
	drawing_set_matrix(self.m_drawingID,{a,b,0,0,c,d,0,0,0,0,1,0,sx,sy,1,1});
end

SwfSprite.dtor = function(self)
   	self:removeMask();
   	if self.m_color_id then
		res_delete(self.m_color_id);
   		res_free_id(self.m_color_id);
   		self.m_color_id = nil;
	end
end
--//SwfNode
SwfNode = class(Node,false);
SwfNode.ctor = function(self,cid,imgPinMap)
	self.m_cid = cid;
	self.m_imgPinMap = imgPinMap;
	super(self)
end

SwfNode.setMask = function(self,maskImgName,matrix_tb)
	if self.m_maskImgName ~= maskImgName then
		self:removeMask();
		self.m_maskImgName = maskImgName;
		self.m_mask = new(Image,self.m_imgPinMap[maskImgName]);
		
		self.m_parent:addChild(self.m_mask);
	end
	
	if matrix_tb and table.equal(self.m_maskMatrix,matrix_tb) == false then
		local a,b,c,d,sx,sy = matrix_tb[1],matrix_tb[2],matrix_tb[3],matrix_tb[4],matrix_tb[5],matrix_tb[6];
		sx = sx * System.getLayoutScale();
		sy = sy * System.getLayoutScale();
		drawing_set_matrix(self.m_mask.m_drawingID,{a,b,0,0,c,d,0,0,0,0,1,0,sx,sy,1,1});
		self:setMaskDrawing(self.m_mask);
		self.m_maskMatrix = matrix_tb;
	end
end

SwfNode.removeMask = function(self)
	if self.m_mask then
		self:delMaskDrawing(self.m_mask);
		delete(self.m_mask);
		self.m_mask = nil;
	end
	self.m_maskImgName = nil;
	self.m_maskMatrix = nil;
end

SwfNode.setMatrix = function(self,a,b,c,d,sx,sy)
	sx = sx * System.getLayoutScale();
	sy = sy * System.getLayoutScale();
	drawing_set_matrix(self.m_drawingID,{a,b,0,0,c,d,0,0,0,0,1,0,sx,sy,1,1});
end

SwfNode.dtor = function(self)
   	self:removeMask();
   	if self.m_color_id then
		res_delete(self.m_color_id);
   		res_free_id(self.m_color_id);
   		self.m_color_id = nil;
	end
end

