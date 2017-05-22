

HeadSmogAnim = {};  
HeadSmogAnim.flag = false;           
HeadSmogAnim.loaded = false;
HeadSmogAnim.playing = false;
HeadSmogAnim.audio = false;
HeadSmogAnim.step = -1;
HeadSmogAnim.idx = 0;
HeadSmogAnim.x = 0;
HeadSmogAnim.y = 0;
HeadSmogAnim.w = 135;
HeadSmogAnim.h = 135;



--[[
   [METHOD] play
   [ACTION] 炸弹动画 入口
   Parameters:
              flag:是否加到根节点标志
              seat:座位号，如果为空则设置其位置坐标为(x,y)
]]
HeadSmogAnim.play = function (seat) 

    if seat then
		HeadSmogAnim.w,HeadSmogAnim.h = seat:getSize();
		HeadSmogAnim.x = -HeadSmogAnim.w/4
		HeadSmogAnim.y = -HeadSmogAnim.h/4;
		HeadSmogAnim.w = HeadSmogAnim.w * 3 /2;
		HeadSmogAnim.h = HeadSmogAnim.h * 3 /2;
	else
		return;
	end

	HeadSmogAnim.load();
	seat:addChild(HeadSmogAnim.drawing);
	HeadSmogAnim.drawing:setPos(HeadSmogAnim.x,HeadSmogAnim.y);
	HeadSmogAnim.drawing:setVisible(false);

	--当炸弹在未播放完动画的时候再次调用play,则先强制清除prop , anim;(重入)
	HeadSmogAnim.stop();

    
	HeadSmogAnim.step = -1;
	HeadSmogAnim.idx = 0;
	HeadSmogAnim.audio = false;
	HeadSmogAnim.playing = true;

	--创建一个可变值(0,14)
	HeadSmogAnim.animIndex = new(AnimInt,kAnimRepeat,0,1,40,-1);
	ToolKit.setDebugName(HeadSmogAnim.animIndex , "AnimInt|HeadSmogAnim.animIndex");
	HeadSmogAnim.animIndex:setEvent(HeadSmogAnim,HeadSmogAnim.onTimer);

end

HeadSmogAnim.load = function()
	if not HeadSmogAnim.loaded then
		HeadSmogAnim.loaded = true;
		local imgs={};
		for i=1,6 do
			table.insert(imgs,string.format("animation/headSmog%d.png",i));
		end
		HeadSmogAnim.drawing = new(Images,imgs);
		HeadSmogAnim.drawing:setSize(HeadSmogAnim.w,HeadSmogAnim.h);
		ToolKit.setDebugName(HeadSmogAnim.drawing , "Images|HeadSmogAnim.drawing");
		
        HeadSmogAnim.drawing:setVisible(false);
        HeadSmogAnim.drawing:setLevel(100);
	end
end

--[[
    private
   [METHOD] onTimer
   [ACTION] 删除赋给prop的anim ; 删除赋给drawing的prop 保留drawing
   Parameters: 无
]]
HeadSmogAnim.onTimer = function (self,anim_type, anim_id, repeat_or_loop_num)		
	HeadSmogAnim.drawing:setVisible(true);

	HeadSmogAnim.step = HeadSmogAnim.step + 1;
	
	if HeadSmogAnim.step < 9 then
		HeadSmogAnim.idx = math.floor(HeadSmogAnim.step/3);
	else
	
		HeadSmogAnim.idx = (HeadSmogAnim.step-9) + 3;
	end

	if HeadSmogAnim.idx >= 6 then
		HeadSmogAnim.stop();
		HeadSmogAnim.release();
		return;
	end
	
	print_string("HeadSmogAnim " .. HeadSmogAnim.idx .. "width = " .. HeadSmogAnim.w .. "height = " ..HeadSmogAnim.h );
	HeadSmogAnim.drawing:setImageIndex(HeadSmogAnim.idx);
	HeadSmogAnim.idx = HeadSmogAnim.idx + 1;
end

--[[
   [METHOD] stop
   [ACTION] 执行 删除anim;
   Parameters: 无
]]
HeadSmogAnim.stop=function()
	if  HeadSmogAnim.playing then
		print_string("HeadSmogAnim.stop");
		HeadSmogAnim.playing = false;
		HeadSmogAnim.drawing:setVisible(false);
		HeadSmogAnim.drawing:setPos(HeadSmogAnim.x,HeadSmogAnim.y);
		HeadSmogAnim.drawing:setSize(HeadSmogAnim.w,HeadSmogAnim.h);		
		--删除anim
		delete(HeadSmogAnim.animIndex);
		HeadSmogAnim.animIndex = nil;
    end
end

HeadSmogAnim.release = function()
	if HeadSmogAnim.flag then
		HeadSmogAnim.flag = false;
		HeadSmogAnim.loaded = false;

		delete(HeadSmogAnim.drawing);
		HeadSmogAnim.drawing = nil;
	end
end

--[[
   [METHOD] deleteAll
   [ACTION] 释放资源(退出房间后调用)
   Parameters: 无
]]
HeadSmogAnim.deleteAll=function()
	HeadSmogAnim.stop();
	if HeadSmogAnim.loaded then
		print_string("HeadSmogAnim.deleteAll");

		HeadSmogAnim.release();
		HeadSmogAnim.loaded = false;
	end
end