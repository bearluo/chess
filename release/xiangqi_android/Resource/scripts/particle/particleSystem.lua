
-- particleSystem.lua
-- Author: Williamwu
-- Date: 2013-04-10
-- Last modification : 2013-10-10
-- Description: Particle Manager

require("core/global");
require("core/constants");
require("core/object");
require("core/anim");
require("libs/bit");
require("ui/node");

ParticleSystem = class();

kParticleTypeForever = 1;
kParticleTypeBlast	 = 2;

ParticleSystem.s_instance = nil;

-- fix bugs
-- @self.m_vertexArr 少一组数据, 目前是在末尾补充 4 个 0 点.
-- @self.m_colorArr 少一组数据, 目前是在末尾补充 4 个 1111 颜色点.

-- 粒子系统调用方法
-- ParticleSystem.getInstance():create(file, particle, x0, y0, color, parType,maxNum, moredata)
-- @file 粒子效果文件名,可以为单个文件或者拼图
--           如果是拼图类型,请确保拼图文件名为1.png, 2.png 等从 i = i, maxIndex 的"i.png" 
--           !!!请不要修改 ParticleSystem 去适配拼图文件,请修改拼图文件适配 ParticleSystem
-- @particle 粒子效果类型,如 ParticleFireWork, ParticleMoney 等等
-- @x0 @y0 粒子的位置坐标,用于下一次更新粒子的位置坐标,主要是每一个粒子特效类型中的 init, update方法使用.
--           一般设置为0, 0
-- @color 实际上是设置粒子的透明度,nil为不设置透明度(即设置alpha通道为1.0),非nil非false值表示设置透明度,1.0为不透明,0.0为全透.
--           一般设置为 nil 或者 true
-- @parType :kParticleTypeBlast 和 kParticleTypeForever 需要注意的是,同样的代码,仅仅是parType不同,效果也将不同.
--           @kParticleTypeBlast 为一次性粒子效果
--           @kParticleTypeForever 为永久粒子效果
-- @maxNum   粒子的最大数目.不设置即为40.
-- @moredate 粒子更多的信息, 主要有
--			 @h 设置粒子的活动高度
--           @w 设置粒子的活动宽度
--           @rotation 设置粒子的旋转角度
--           @maxIndex 当file为拼图时,设置拼图中图片数目,一定要如实设置.
--           @scale 设置粒子的缩放大小. 一般不要设置放大,会出现锯齿等.

-- 粒子系统调用顺序.
-- 调用 ParticleSystem.create(...) 产生 ParticleNode.
-- ParticleNode 调用 ctor 产生 ParticleNode
-- 根据 parType, ParticleNode 在 ctor 过程中决定是否要调用 ParticleNode.generate(...) 方法(仅 kParticleTypeBlast 会调用).
-- 定时器启动, 调用 ParticleSystem.update(...) 方法, 粒子的 update 方法在其中调用.
--             之后会调用 ParticleNode.generate(...) 方法, 粒子的 init 方法在其中调用.

-- 粒子的 index, coord, 均在第一次生成. 此时 vertex 为空, 故会造成 lua 数组越界BUG. 在粒子数目较多时, 会出现白条等花屏等现象.
-- 故在 ParticleNode.generate(...) 方法中补充以下语句. 在每一次的 vertex 数组后面补上 4个 0坐标.
  -- 	   for i = 1, 8 do
  --           self.m_vertexArr[len*8 + i] = 0
  --       end
  --       res_set_double_array2( self.m_vertexResId,self.m_vertexArr);


-- ----------------------------interface
--得到唯一实例对象
ParticleSystem.getInstance = function()
	if not ParticleSystem.s_instance then 
		ParticleSystem.s_instance = new(ParticleSystem);
	end
	return ParticleSystem.s_instance;
end

--释放唯一实例对象
ParticleSystem.releaseInstance = function()
    delete(ParticleSystem.s_instance);
    ParticleSystem.s_instance = nil;
end

--调用生成一类粒子
ParticleSystem.create = function(self, file, particle, x0, y0, color, parType,maxNum, moredata)
	if not file or not particle then 
		return nil;
	end
	
 	local index = table.maxn(self.m_pars)+1;

 	self.m_pars[index] = new(ParticleNode, index, file, particle, x0, y0, color, parType,maxNum, moredata);

 	return self.m_pars[index];	
end

--停止喷射粒子
ParticleSystem.stopAll = function(self)
	self.m_isStoped = true;
end

--恢复stopAll之前状态
ParticleSystem.startAll = function(self)
	self.m_isStoped = false;
end

--暂停刷新粒子
ParticleSystem.pauseAll = function(self)
	self.m_isPaused = true;
end

--恢复pauseAll之前状态
ParticleSystem.resumeAll = function(self)
	self.m_isPaused = false;
end

--停止并擦除现有粒子效果
ParticleSystem.escape = function(self)
	--TODO
end

-------------------------private
ParticleSystem.ctor = function(self)
    self.m_pars = {};
	self.m_tick = 0;
    self.m_isStoped = false;
	self.m_isPaused = false;

	self.m_anim = new(AnimDouble, kAnimRepeat, 0, 1, 1, 0);
	self.m_anim:setDebugName("AnimDouble|ParticleSystem.ctor");
	self.m_anim:setEvent(self, self.update);
end

ParticleSystem.dtor = function(self)
	delete(self.m_anim);
	self.m_anim = nil;

	for k, v in pairs(self.m_pars or {}) do
		local parent = v:getParent();
		if parent then
			parent:removeChild(v);
		end
		delete(v);
	end
	self.m_pars = nil;
end

ParticleSystem.remove = function(self, index)
	self.m_pars[index] = nil;
end

ParticleSystem.update = function(self, _, _, repeat_or_loop_num)
	if self.m_isPaused then return;end
	self.m_tick = (self.m_tick + 1)%2;
	local pos ,par,t_vtx,particles,imgW,imgH,maxNum;
	for index, v in pairs(self.m_pars) do
		local activeNum = 0;
		if not v.m_isPaused then
			particles = v.m_particles;
			for loop = 1, #particles do 
				--激活状态
		        if particles[loop].m_active then 
		            activeNum = activeNum+1;
		        	par = particles[loop]; 
		        	pos = (loop-1);
		        	par:update(v, pos);
		        	
					t_vtx = v.m_vertexArr;
					imgW = v.m_texW;
					imgH = v.m_texH;

					local parPos = pos*8;
					if par.m_rotation then
						imgW = imgW/2;
						imgH = imgH/2;
						local rad = math.rad(par.m_rotation);
						local cosA = math.cos(rad);
						local sinA = math.sin(rad);
						local cs_w = cosA*( imgW);
						local sn_h = sinA*( imgH);
						local sn_w = sinA*( imgW);
						local cs_h = cosA*( imgH);
						t_vtx[parPos+1] = par.m_scale*(-cs_w+sn_h)+par.m_x;
						t_vtx[parPos+2] = par.m_scale*(-sn_w-cs_h)+par.m_y;
						t_vtx[parPos+3] = par.m_scale*(cs_w+sn_h)+par.m_x;
						t_vtx[parPos+4] = par.m_scale*(sn_w-cs_h)+par.m_y;
						t_vtx[parPos+5] = par.m_scale*(cs_w-sn_h)+par.m_x;
						t_vtx[parPos+6] = par.m_scale*(sn_w+cs_h)+par.m_y;
						t_vtx[parPos+7] = par.m_scale*(-cs_w-sn_h)+par.m_x;
						t_vtx[parPos+8] = par.m_scale*(-sn_w+cs_h)+par.m_y;
					else
						local offsetX = par.m_scale*imgW/2;
						local offsetY = par.m_scale*imgH/2;
						t_vtx[parPos+1],t_vtx[parPos+3],t_vtx[parPos+5],t_vtx[parPos+7] = par.m_x-offsetX,par.m_x+offsetX,par.m_x+offsetX,par.m_x-offsetX;
						t_vtx[parPos+2],t_vtx[parPos+4],t_vtx[parPos+6],t_vtx[parPos+8] = par.m_y-offsetY,par.m_y-offsetY,par.m_y+offsetY,par.m_y+offsetY;
					end
					if v.m_texType==3 and par.m_index then
						for i = 1, 8 do
							v.m_coordArr[parPos+i] = v.m_texCoordArr[par.m_index][i];
						end
					end
		        end
		    end	

			res_set_double_array2(v.m_vertexResId, v.m_vertexArr);
			if v.m_texType==3 then res_set_double_array2(v.m_coordResId, v.m_coordArr);end
			if v.m_color then res_set_double_array2(v.m_colorResId, v.m_colorArr);end
            if self.m_tick == 1 and not (v.m_isStoped or self.m_isStoped) then
		    	if v.m_type == kParticleTypeBlast then 
		    		for i = 1, v.m_maxNum do
			        	v:generate(repeat_or_loop_num);
		    		end
		    		v.m_isStoped = true;
			    elseif activeNum < v.m_maxNum then 
			    	--generate调用次数，应该根据实际粒子数和最大粒子数决定
			    	--这里简单处理
			        -- v:generate(repeat_or_loop_num);
--			        v:generate(repeat_or_loop_num);
			        v:generate(repeat_or_loop_num);
			    end
			end

		end
	end
end

--------------------
ParticleNode = class(Node);
ParticleNode.defaultCoord = {0.0,1.0,1.0,1.0,1.0,0.0,0.0,0.0};

ParticleNode.ctor = function(self, index, file, particle, x0, y0, color, parType, maxNum, moredata)
	--假定所有参数合法
	self.m_index = index;
 	self.m_fileName = file;
 	self.m_particle = particle;
	self.m_x0 = x0;
 	self.m_y0 = y0;
 	self.m_color = color;
	self.m_type = parType==kParticleTypeBlast and kParticleTypeBlast or kParticleTypeForever;
	self.m_maxNum = maxNum or 40;
 	self.moredata = moredata;

 	self.m_particles = {};
 	self.m_isStoped = true;
 	self.m_isPaused = false;

 	self.m_vertexResId = res_alloc_id();
 	self.m_vertexArr = {};
	res_create_double_array2(0,self.m_vertexResId,self.m_vertexArr);
 	self.m_indexResId = res_alloc_id();
 	self.m_indexArr = {};
	res_create_ushort_array2(0,self.m_indexResId,self.m_indexArr);
 	self.m_coordResId = res_alloc_id();
 	self.m_coordArr = {};
	res_create_double_array2(0,self.m_coordResId,self.m_coordArr);
	if color then 
	 	self.m_colorResId = res_alloc_id();
	 	self.m_colorArr = {};
		res_create_double_array2(0,self.m_colorResId,self.m_colorArr);
	end
 	self.m_imageResId = res_alloc_id();
	if type(file)=="table" then
		if moredata.maxIndex then
			self.m_texType = 3;
			res_create_image(0,self.m_imageResId,file["1.png"].file,0,1);
			self.m_mainTexW = res_get_image_width(self.m_imageResId);
			self.m_mainTexH = res_get_image_height(self.m_imageResId);
			self.m_subTexW = file["1.png"].width;
			self.m_subTexH = file["1.png"].height;
			self.m_texCoordArr = {};
			local f;
			for i = 1, moredata.maxIndex do
				f = file[i .. ".png"];
				self.m_texCoordArr[i] = {
				f.x/self.m_mainTexW,
				(f.y+f.height)/self.m_mainTexH,
				(f.x+f.width)/self.m_mainTexW,
				(f.y+f.height)/self.m_mainTexH,
				(f.x+f.width)/self.m_mainTexW,
				f.y/self.m_mainTexH,
				f.x/self.m_mainTexW,
				f.y/self.m_mainTexH};
			end
		else
			self.m_texType = 2;
			res_create_image(0,self.m_imageResId,file.file,0,1);
			self.m_mainTexW = res_get_image_width(self.m_imageResId);
			self.m_mainTexH = res_get_image_height(self.m_imageResId);
			self.m_subTexW = file.width;
			self.m_subTexH = file.height;
			
			self.m_texCoordArr = {
    			 file.x/self.m_mainTexW,
    			 (file.y+file.height)/self.m_mainTexH,
    			 (file.x+file.width)/self.m_mainTexW,
    			 (file.y+file.height)/self.m_mainTexH,
    			 (file.x+file.width)/self.m_mainTexW,
    			 file.y/self.m_mainTexH,
    			 file.x/self.m_mainTexW,
    			 file.y/self.m_mainTexH
			 };
		end
	else
		self.m_texType = 1;
	 	res_create_image(0,self.m_imageResId,file,0,1);
	 	self.m_texCoordArr = ParticleNode.defaultCoord;
	end
	self.m_texW = self.m_subTexW or res_get_image_width(self.m_imageResId); --//纹理宽度
	self.m_texH = self.m_subTexH or res_get_image_height(self.m_imageResId);--//纹理高度

	self.m_drawingId = drawing_alloc_id();
	drawing_create_node(0,self.m_drawingId,0);

	drawing_set_parent(self.m_drawingId, self.m_drawingID);

	--最后一个参数指明需要贴图	
	if color then 
		drawing_set_node_renderable(self.m_drawingId,kRenderTriangles, bit.bor(kRenderDataColors, kRenderDataTexture));
	else 
		drawing_set_node_renderable(self.m_drawingId,kRenderTriangles, kRenderDataTexture);
	end
	drawing_set_node_vertex(self.m_drawingId,self.m_vertexResId,self.m_indexResId);
	drawing_set_node_texture(self.m_drawingId,self.m_imageResId,self.m_coordResId);
	if color then drawing_set_node_colors(self.m_drawingId, self.m_colorResId);end
	if self.m_type == kParticleTypeBlast then 
		self.m_isStoped = false;
		for i = 1, self.m_maxNum do
	    	self:generate();
		end
		self.m_isPaused = true;
	end
end

ParticleNode.dtor = function(self)
	if self.m_vertexResId then
		for k, v in pairs(self.m_particles or {}) do
			delete(v);
		end
		self.m_particles = nil;
		self.m_isStoped = true;
		self.m_isPaused = true;
		res_delete(self.m_vertexResId);
		self.m_vertexResId = nil;
		self.m_vertexArr = nil;
		res_delete(self.m_indexResId);
		self.m_indexResId = nil;
		self.m_indexArr = nil;
		res_delete(self.m_coordResId);
		self.m_coordResId = nil;
		self.m_coordArr = nil;
		if self.m_color then 
			res_delete(self.m_colorResId);
			self.m_colorResId = nil;
			self.m_colorArr = nil;
		end
		res_delete(self.m_imageResId);
		self.m_imageResId = nil;
		drawing_delete(self.m_drawingId);
		self.m_drawingId = nil;
		ParticleSystem.getInstance():remove(self.m_index);
	end
end

ParticleNode.generate = function(self, step)
	if self.m_isStoped then 
		return;
	end
    local par, len, particles;
    particles = self.m_particles;
   	for loop = 1, #particles do 
		 if not particles[loop].m_active then 
		 	par = particles[loop];
		 	len = loop - 1;
		 	break;
		 end
	end
	if par == nil then 
	    len = #particles;
		par = new(self.m_particle, self.m_fileName);
		particles[len+1] = par;
		if self.m_texType~=3 then
			for i = 1, 8 do
				self.m_coordArr[len*8+i] = self.m_texCoordArr[i]; 
			end
		else 
			for i = 1, 8 do
				self.m_coordArr[len*8+i] = self.m_texCoordArr[1][i]; 
			end
		end
		-- 012.023为画两个三角形组成的一个矩形
		local t_idx = self.m_indexArr;
		t_idx[len*6+1],t_idx[len*6+2],t_idx[len*6+3],t_idx[len*6+4],t_idx[len*6+5],t_idx[len*6+6] = 4*len+0,4*len+1,4*len+2,4*len+0,4*len+2,4*len+3;
		
		--透明度
		if self.m_color then 
			-- 在 self.m_colorArr 末尾补充一组 1 数据(即显示数据)
			for i = 1, 16 do
				self.m_colorArr[len*16 + i] = 1
			end
			res_set_double_array2(self.m_colorResId, self.m_colorArr)
		end

		-- 在 self.m_vertexArr 末尾补充一组 0 数据.
        for i = 1, 8 do
            self.m_vertexArr[len*8 + i] = 0
        end
		res_set_double_array2( self.m_coordResId,self.m_coordArr);
		res_set_ushort_array2( self.m_indexResId,t_idx);
        res_set_double_array2( self.m_vertexResId,self.m_vertexArr);
	end
	par:init(len, index, self, step);
end

--停止喷射粒子
ParticleNode.stop = function(self)
	self.m_isStoped = true;
end

--开始喷射粒子
ParticleNode.start = function(self)
	self.m_isStoped = false;
end

--暂停刷新粒子
ParticleNode.pause = function(self)
	self.m_isPaused = true;
end

--恢复刷新粒子
ParticleNode.resume = function(self)
	self.m_isPaused = false;
end
