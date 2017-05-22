-- AnimJam.lua
-- Author: 
-- Date: 
-- Description: 将军动画


AnimJam = {};
             
-- 图片是否被加载
AnimJam.loaded = false;

-- 是否正在播放动画中
AnimJam.playing = false;



AnimJam.imgNum = 12;

-- 动画总时长
AnimJam.ms= 100 * AnimJam.imgNum; 

-- 图片路径
AnimJam.resPath_Prefix = "animation/";

--public
--播放动画,可以反复调用
AnimJam.play = function (root,obj,func)

	
	if not root then 
		return; 
	end

	kEffectPlayer:playEffect(Effects.AUDIO_MOVE_JAM);
	AnimJam.obj = obj;
	AnimJam.func = func;

	local delay = 0;
	
	if not AnimJam.loaded then
		AnimJam.loaded = true;
		delay = -1;
		local AnimJamX, AnimJamY = 72,135;
		local AnimJamW, AnimJamH = 322,322;
		local resJamList = AnimJam:createResString(AnimJam.resPath_Prefix.."anim_stuck_%d.png",AnimJam.imgNum);
		AnimJam.drawingJam = new(Images, resJamList);
        AnimJam.drawingJam:setAlign(kAlignCenter);
--		AnimJam.drawingJam:setPos(AnimJamX,AnimJamY);
		AnimJam.drawingJam:setSize(AnimJamW,AnimJamH);
		AnimJam.drawingJam:setLevel(20);
		root:addChild(AnimJam.drawingJam);

		AnimJam.drawingJam:setVisible(false);
	else
		AnimJam.clearAndReset();
	end
	
	AnimJam.playing = true;
	AnimJam.drawingJam:setVisible(true);

    --创建一个可变值[0,11]
	AnimJam.animIndex = new(AnimInt,kAnimNormal,0,AnimJam.imgNum - 1,AnimJam.ms , delay);
	AnimJam.animIndex:setDebugName("AnimJam.animIndex");

	--创建一个ImageIndex prop
	AnimJam.propIndex = new(PropImageIndex,AnimJam.animIndex);

	--赋给drawing ( pos = 0 ) 
	AnimJam.drawingJam:addProp(AnimJam.propIndex,0);

	--anim结束后事件
    AnimJam.animIndex:setEvent(AnimJam, AnimJam.onAnimComplete);

end

--public
--退出当前场景时调用
AnimJam.deleteAll = function()
	AnimJam.clearAndReset();
	if AnimJam.loaded then
		AnimJam.loaded=false;
		--delete(AnimJam.drawingJam);
	end
end
--private
AnimJam.createResString = function(self,imageName,nImages)

	local resString = {};
	for i=1,nImages do
		local strTmp=string.format(imageName,i);
		table.insert(resString,strTmp);
	end
	return resString;
end

--private
AnimJam.onAnimComplete = function (self,anim_type, anim_id, repeat_or_loop_num)
	AnimJam.clearAndReset();  

	if AnimJam.obj and AnimJam.func then
		AnimJam.func(AnimJam.obj);
	end

end

--private
AnimJam.clearAndReset=function(self,anim_type, anim_id, repeat_or_loop_num)

	if not AnimJam.loaded then
		print_string("AnimJam.clearAndReset not AnimCheck.loaded ");
		return;
	end
	if AnimJam.playing then
		AnimJam.playing = false;
	
		AnimJam.drawingJam:removeProp(0);
		delete(AnimJam.propIndex);
		delete(AnimJam.animIndex);
	
	end
	
	AnimJam.drawingJam:setImageIndex(0);
	AnimJam.drawingJam:setVisible(false);
	
    if AnimJam.loaded then
    end
end

