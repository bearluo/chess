 -- animCheck.lua
-- Author: 
-- Date: 
-- Description: 将军动画


AnimCheck = {};
             
-- 图片是否被加载
AnimCheck.loaded = false;

-- 是否正在播放动画中
AnimCheck.playing = false;



AnimCheck.imgNum = 12;

-- 动画总时长
AnimCheck.ms= 100 * AnimCheck.imgNum;   --  1000/30 * AnimCheck.imgNum *3  每张图片放三帧

-- 图片路径
AnimCheck.resPath_Prefix = "animation/";

--public
--播放动画,可以反复调用
AnimCheck.play = function (root)

	
	if not root then 
		return; 
	end

	local delay = 0;
	
	if not AnimCheck.loaded then
		AnimCheck.loaded = true;
		delay = -1;
--		local AnimCheckX, AnimCheckY = 72,135;
		local AnimCheckW, AnimCheckH = 322,322;
		local resCheckList = AnimCheck:createResString(AnimCheck.resPath_Prefix.."anim_check_%d.png",AnimCheck.imgNum);
		AnimCheck.drawingCheck = new(Images, resCheckList);
--		AnimCheck.drawingCheck:setPos(AnimCheckX,AnimCheckY);
		AnimCheck.drawingCheck:setSize(AnimCheckW,AnimCheckH);
		AnimCheck.drawingCheck:setLevel(20);
        AnimCheck.drawingCheck:setAlign(kAlignCenter);
		root:addChild(AnimCheck.drawingCheck);

		AnimCheck.drawingCheck:setVisible(false);
	else
		AnimCheck.clearAndReset();
	end
	
	AnimCheck.playing = true;
	AnimCheck.drawingCheck:setVisible(true);

    --创建一个可变值[0,11]
	AnimCheck.animIndex = new(AnimInt,kAnimNormal,0,AnimCheck.imgNum - 1,AnimCheck.ms , delay);
	AnimCheck.animIndex:setDebugName("AnimCheck.animIndex");

	--创建一个ImageIndex prop
	AnimCheck.propIndex = new(PropImageIndex,AnimCheck.animIndex);

	--赋给drawing ( pos = 0 ) 
	AnimCheck.drawingCheck:addProp(AnimCheck.propIndex,0);

	--anim结束后事件
    AnimCheck.animIndex:setEvent(AnimCheck, AnimCheck.onAnimComplete);

end

--public
--退出当前场景时调用
AnimCheck.deleteAll = function()
	AnimCheck.clearAndReset();
	if AnimCheck.loaded then
		AnimCheck.loaded=false;
		--delete(AnimCheck.drawingCheck);
	end


end
--private
AnimCheck.createResString = function(self,imageName,nImages)

	local resString = {};
	for i=1,nImages do
		local strTmp=string.format(imageName,i);
		table.insert(resString,strTmp);
	end
	return resString;
end

--private
AnimCheck.onAnimComplete = function (self,anim_type, anim_id, repeat_or_loop_num)
	AnimCheck.clearAndReset();    
end

--private
AnimCheck.clearAndReset=function(self,anim_type, anim_id, repeat_or_loop_num)
	if not AnimCheck.loaded then
		print_string("AnimCheck.clearAndReset not AnimCheck.loaded ");
		return;
	end

	if AnimCheck.playing then
		AnimCheck.playing = false;
	
		AnimCheck.drawingCheck:removeProp(0);
		delete(AnimCheck.propIndex);
		delete(AnimCheck.animIndex);
		AnimCheck.propIndex = nil;
		AnimCheck.animIndex = nil;
	
	end
	
	AnimCheck.drawingCheck:setImageIndex(0);
	AnimCheck.drawingCheck:setVisible(false);
	
    if AnimCheck.loaded then
    end
end

