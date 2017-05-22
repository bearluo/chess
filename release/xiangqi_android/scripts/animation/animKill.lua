-- AnimKill.lua
-- Author: 
-- Date: 
-- Description: 将军动画


AnimKill = {};
             
-- 图片是否被加载
AnimKill.loaded = false;

-- 是否正在播放动画中
AnimKill.playing = false;



AnimKill.imgNum = 14;

-- 动画总时长
AnimKill.ms= 100 * AnimKill.imgNum; 

-- 图片路径
AnimKill.resPath_Prefix = "animation/";

--public
--播放动画,可以反复调用
AnimKill.play = function (root,obj,func)

	
	if not root then 
		return; 
	end

	kEffectPlayer:playEffect(Effects.AUDIO_MOVE_KILL);
	AnimKill.obj = obj;
	AnimKill.func = func;

	local delay = 0;
	
	if not AnimKill.loaded then
		AnimKill.loaded = true;
		delay = -1;
		local AnimKillX, AnimKillY = 72,135;
		local AnimKillW, AnimKillH = 322,322;
		local resKillList = AnimKill:createResString(AnimKill.resPath_Prefix.."anim_kill_%d.png",AnimKill.imgNum);
		AnimKill.drawingKill = new(Images, resKillList);
		--AnimKill.drawingKill:setPos(AnimKillX,AnimKillY);
        AnimKill.drawingKill:setAlign(kAlignCenter);
		AnimKill.drawingKill:setSize(AnimKillW,AnimKillH);
		AnimKill.drawingKill:setLevel(20);
		root:addChild(AnimKill.drawingKill);

		AnimKill.drawingKill:setVisible(false);
	else
		AnimKill.clearAndReset();
	end
	
	AnimKill.playing = true;
	AnimKill.drawingKill:setVisible(true);

    --创建一个可变值[0,11]
	AnimKill.animIndex = new(AnimInt,kAnimNormal,0,AnimKill.imgNum - 1,AnimKill.ms , delay);
	AnimKill.animIndex:setDebugName("AnimKill.animIndex");

	--创建一个ImageIndex prop
	AnimKill.propIndex = new(PropImageIndex,AnimKill.animIndex);

	--赋给drawing ( pos = 0 ) 
	AnimKill.drawingKill:addProp(AnimKill.propIndex,0);

	--anim结束后事件
    AnimKill.animIndex:setEvent(AnimKill, AnimKill.onAnimComplete);

end

--public
--退出当前场景时调用
AnimKill.deleteAll = function()
	AnimKill.clearAndReset();
	if AnimKill.loaded then
		AnimKill.loaded=false;
		--delete(AnimKill.drawingKill);
	end
end
--private
AnimKill.createResString = function(self,imageName,nImages)

	local resString = {};
	for i=1,nImages do
		local strTmp=string.format(imageName,i);
		table.insert(resString,strTmp);
	end
	return resString;
end

--private
AnimKill.onAnimComplete = function (self,anim_type, anim_id, repeat_or_loop_num)
	AnimKill.clearAndReset();  

	if AnimKill.obj and AnimKill.func then
		AnimKill.func(AnimKill.obj);
	end

end

--private
AnimKill.clearAndReset=function(self,anim_type, anim_id, repeat_or_loop_num)

	if not AnimKill.loaded then
		print_string("AnimKill.clearAndReset not AnimCheck.loaded ");
		return;
	end
	
	if AnimKill.playing then
		AnimKill.playing = false;
	
		AnimKill.drawingKill:removeProp(0);
		delete(AnimKill.propIndex);
		delete(AnimKill.animIndex);
	
	end
	
	AnimKill.drawingKill:setImageIndex(0);
	AnimKill.drawingKill:setVisible(false);
	
    if AnimKill.loaded then
    end
end

