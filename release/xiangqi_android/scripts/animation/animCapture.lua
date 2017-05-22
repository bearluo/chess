 -- animCapture.lua
-- Author: shineflag
-- Date: 
-- Description: 吃子动画


AnimCapture = {};
             
-- 图片是否被加载
AnimCapture.loaded = false;

-- 是否正在播放动画中
AnimCapture.playing = false;



AnimCapture.imgNum = 3;

-- 动画总时长
AnimCapture.ms= 100 * AnimCapture.imgNum;   --  1000/30 * AnimCapture.imgNum *3  每张图片放三帧

-- 图片路径
AnimCapture.resPath_Prefix = "animation/";

--public
--播放动画,可以反复调用
AnimCapture.play = function (root,x,y,chessSize,obj,func)

	
	if not root then 
		return; 
	end

	local delay = 0;

	AnimCapture.obj = obj;
	AnimCapture.func = func;
	

	local AnimCaptureW, AnimCaptureH = 89,137;
	if not AnimCapture.loaded then
		AnimCapture.loaded = true;
		delay = -1;
		-- local AnimCaptureX, AnimCaptureY = x,y + 51-133;
		-- local AnimCaptureW, AnimCaptureH = 60,157;
		local resCheckList = AnimCapture:createResString(AnimCapture.resPath_Prefix.."animate_eatchess_%d.png",AnimCapture.imgNum);
		AnimCapture.drawingCheck = new(Images, resCheckList);
		-- AnimCapture.drawingCheck:setPos(AnimCaptureX,AnimCaptureY);
--		AnimCapture.drawingCheck:setSize(AnimCaptureW,AnimCaptureH);
		AnimCapture.drawingCheck:setLevel(20);
		root:addChild(AnimCapture.drawingCheck);

		AnimCapture.drawingCheck:setVisible(false);
	else
		AnimCapture.clearAndReset();
	end

	AnimCapture.playing = true;
	local chessSize = chessSize;
	local AnimCaptureX, AnimCaptureY = x+(chessSize-AnimCaptureW)/2,y+chessSize-AnimCaptureH;
	AnimCapture.drawingCheck:setPos(AnimCaptureX,AnimCaptureY);
	AnimCapture.drawingCheck:setVisible(true);

    --创建一个可变值[0,11]
	AnimCapture.animIndex = new(AnimInt,kAnimNormal,0,AnimCapture.imgNum - 1,AnimCapture.ms , delay);
	AnimCapture.animIndex:setDebugName("AnimCapture.animIndex");

	--创建一个ImageIndex prop
	AnimCapture.propIndex = new(PropImageIndex,AnimCapture.animIndex);

	--赋给drawing ( pos = 0 ) 
	AnimCapture.drawingCheck:addProp(AnimCapture.propIndex,0);

	--anim结束后事件
    AnimCapture.animIndex:setEvent(AnimCapture, AnimCapture.onAnimComplete);

end

--public
--退出当前场景时调用
AnimCapture.deleteAll = function()
	AnimCapture.clearAndReset();
	if AnimCapture.loaded then
		AnimCapture.loaded=false;
		--delete(AnimCapture.drawingCheck);
	end
end
--private
AnimCapture.createResString = function(self,imageName,nImages)

	local resString = {};

	for i=1,nImages do
		local strTmp=string.format(imageName,i);
		table.insert(resString,strTmp);
	end
	return resString;
end

--private
AnimCapture.onAnimComplete = function (self,anim_type, anim_id, repeat_or_loop_num)
	AnimCapture.clearAndReset();    
	if AnimCapture.obj and AnimCapture.func then
		AnimCapture.func(AnimCapture.obj);
	end
end

--private
AnimCapture.clearAndReset=function(self,anim_type, anim_id, repeat_or_loop_num)
	if not AnimCapture.loaded then
		print_string("AnimCapture.clearAndReset not AnimCapture.loaded ");
		return;
	end

	if AnimCapture.playing then
		AnimCapture.playing = false;
	
		AnimCapture.drawingCheck:removeProp(0);
		delete(AnimCapture.propIndex);
		delete(AnimCapture.animIndex);

		AnimCapture.propIndex = nil;
		AnimCapture.animIndex = nil;
	
	end
	
	AnimCapture.drawingCheck:setImageIndex(0);
	AnimCapture.drawingCheck:setVisible(false);
	
    if AnimCapture.loaded then
    end
end

