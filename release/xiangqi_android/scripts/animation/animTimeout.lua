-- AnimTimeout.lua
-- Author: 
-- Date: 
-- Description: 将军动画


AnimTimeout = {};
             
-- 图片是否被加载
AnimTimeout.loaded = false;

-- 是否正在播放动画中
AnimTimeout.playing = false;



AnimTimeout.imgNum = 10;

-- 动画总时长
AnimTimeout.ms= 100 * AnimTimeout.imgNum; 

-- 图片路径
AnimTimeout.resPath_Prefix = "animation/";

--public
--播放动画,可以反复调用
AnimTimeout.play = function (root,obj,func)

	
	if not root then 
		return; 
	end

	kEffectPlayer:playEffect(Effects.AUDIO_MOVE_TIMEOUT);
	AnimTimeout.obj = obj;
	AnimTimeout.func = func;

	local delay = 0;
	
	if not AnimTimeout.loaded then
		AnimTimeout.loaded = true;
		delay = -1;
		local AnimTimeoutX, AnimTimeoutY = 72,135;
		local AnimTimeoutW, AnimTimeoutH = 322,322;
		local resTimeoutList = AnimTimeout:createResString(AnimTimeout.resPath_Prefix.."anim_timeout_%d.png",AnimTimeout.imgNum);
		AnimTimeout.drawingTimeout = new(Images, resTimeoutList);
        AnimTimeout.drawingTimeout:setAlign(kAlignCenter);
--		AnimTimeout.drawingTimeout:setPos(AnimTimeoutX,AnimTimeoutY);
		AnimTimeout.drawingTimeout:setSize(AnimTimeoutW,AnimTimeoutH);
		AnimTimeout.drawingTimeout:setLevel(20);
		root:addChild(AnimTimeout.drawingTimeout);

		AnimTimeout.drawingTimeout:setVisible(false);
	else
		AnimTimeout.clearAndReset();
	end
	
	AnimTimeout.playing = true;
	AnimTimeout.drawingTimeout:setVisible(true);

    --创建一个可变值[0,11]
	AnimTimeout.animIndex = new(AnimInt,kAnimNormal,0,AnimTimeout.imgNum - 1,AnimTimeout.ms , delay);
	AnimTimeout.animIndex:setDebugName("AnimTimeout.animIndex");

	--创建一个ImageIndex prop
	AnimTimeout.propIndex = new(PropImageIndex,AnimTimeout.animIndex);

	--赋给drawing ( pos = 0 ) 
	AnimTimeout.drawingTimeout:addProp(AnimTimeout.propIndex,0);

	--anim结束后事件
    AnimTimeout.animIndex:setEvent(AnimTimeout, AnimTimeout.onAnimComplete);

end

--public
--退出当前场景时调用
AnimTimeout.deleteAll = function()
	AnimTimeout.clearAndReset();
	if AnimTimeout.loaded then
		AnimTimeout.loaded=false;
		--delete(AnimTimeout.drawingTimeout);
	end
end
--private
AnimTimeout.createResString = function(self,imageName,nImages)

	local resString = {};
	for i=1,nImages do
		local strTmp=string.format(imageName,i);
		table.insert(resString,strTmp);
	end
	return resString;
end

--private
AnimTimeout.onAnimComplete = function (self,anim_type, anim_id, repeat_or_loop_num)
	AnimTimeout.clearAndReset();  

	if AnimTimeout.obj and AnimTimeout.func then
		AnimTimeout.func(AnimTimeout.obj);
	end

end

--private
AnimTimeout.clearAndReset=function(self,anim_type, anim_id, repeat_or_loop_num)

	if not AnimTimeout.loaded then
		print_string("AnimTimeout.clearAndReset not AnimCheck.loaded ");
		return;
	end
	
	if AnimTimeout.playing then
		AnimTimeout.playing = false;
	
		AnimTimeout.drawingTimeout:removeProp(0);
		delete(AnimTimeout.propIndex);
		delete(AnimTimeout.animIndex);
	
	end
	
	AnimTimeout.drawingTimeout:setImageIndex(0);
	AnimTimeout.drawingTimeout:setVisible(false);
	
    if AnimTimeout.loaded then
    end
end

