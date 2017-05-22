require("core/anim");
require("core/prop");

ConsolePassAnim = {};
             
-- 图片是否被加载
ConsolePassAnim.loaded = false;

-- 是否正在播放动画中
ConsolePassAnim.playing = false;


ConsolePassAnim.imgNum = 2;

-- 动画总时长
ConsolePassAnim.ms1 = 180; 
ConsolePassAnim.ms2 = 30;
ConsolePassAnim.ms3 = 50;
ConsolePassAnim.ms4 = 30;

-- 图片路径
ConsolePassAnim.resPath_Prefix = "drawable/";


ConsolePassAnim.play = function (root,obj,func,x,y)
	if not root then 
		return; 
	end

	kEffectPlayer:playEffect(Effects.AUDIO_CONSOLE_ANIM);
	ConsolePassAnim.obj = obj;
	ConsolePassAnim.func = func;

	local delay = 0;
	
	if not ConsolePassAnim.loaded then
		ConsolePassAnim.loaded = true;
		delay = -1;
		local ConsolePassAnimW, ConsolePassAnimH = 320,320;
		local resPassList = ConsolePassAnim:createResString(ConsolePassAnim.resPath_Prefix.."console_vs.png",ConsolePassAnim.imgNum);
		ConsolePassAnim.drawingPass = new(Images, resPassList);
		ConsolePassAnim.drawingPass:setPos(x,y);
		ConsolePassAnim.drawingPass:setSize(ConsolePassAnimW,ConsolePassAnimH);
		ConsolePassAnim.drawingPass:setLevel(20);
		root:addChild(ConsolePassAnim.drawingPass);

		ConsolePassAnim.drawingPass:setVisible(false);
	else
		ConsolePassAnim.clearAndReset();
	end
	ConsolePassAnim.drawingPass:setPos(x-135,y-50);

	ConsolePassAnim.playing = true;
	ConsolePassAnim.drawingPass:setVisible(true);

	ConsolePassAnim.animIndex = new(AnimDouble,kAnimNormal,1,0.95,ConsolePassAnim.ms1,delay);
	ConsolePassAnim.animIndex:setDebugName("ConsolePassAnim.animIndex");

	ConsolePassAnim.propIndex = new(PropScale,ConsolePassAnim.animIndex,ConsolePassAnim.animIndex,kCenterDrawing,0,0);

	--赋给drawing ( pos = 0 ) 
	ConsolePassAnim.drawingPass:addProp(ConsolePassAnim.propIndex,0);

	--anim结束后事件
    ConsolePassAnim.animIndex:setEvent(ConsolePassAnim, ConsolePassAnim.onAnimComplete1);
end

--public
--退出当前场景时调用
ConsolePassAnim.deleteAll = function()
	ConsolePassAnim.clearAndReset();
	if ConsolePassAnim.loaded then
		ConsolePassAnim.loaded=false;
	end
end

--private
ConsolePassAnim.createResString = function(self,imageName,nImages)
	local resString = {};
	for i=1,nImages do
		local strTmp=string.format(imageName,i);
		table.insert(resString,strTmp);
	end
	return resString;
end

--private
ConsolePassAnim.onAnimComplete1 = function (self,anim_type, anim_id, repeat_or_loop_num)
	ConsolePassAnim.drawingPass:removeProp(0);
	delete(ConsolePassAnim.propIndex);
	delete(ConsolePassAnim.animIndex);
	ConsolePassAnim.drawingPass:setImageIndex(0);

    ConsolePassAnim.animIndex = new(AnimDouble,kAnimNormal,0.95,0.6,ConsolePassAnim.ms2);
    ConsolePassAnim.animIndex:setDebugName("ConsolePassAnim.animIndex");
	ConsolePassAnim.propIndex = new(PropScale,ConsolePassAnim.animIndex,ConsolePassAnim.animIndex,kCenterDrawing,0,0);
	ConsolePassAnim.drawingPass:addProp(ConsolePassAnim.propIndex,0);
    ConsolePassAnim.animIndex:setEvent(ConsolePassAnim, ConsolePassAnim.onAnimComplete2);
end

--private
ConsolePassAnim.onAnimComplete2 = function (self,anim_type, anim_id, repeat_or_loop_num)
	ConsolePassAnim.drawingPass:removeProp(0);
	delete(ConsolePassAnim.propIndex);
	delete(ConsolePassAnim.animIndex);
	ConsolePassAnim.drawingPass:setImageIndex(0);

    ConsolePassAnim.animIndex = new(AnimDouble,kAnimNormal,0.6,0.15,ConsolePassAnim.ms3);
    ConsolePassAnim.animIndex:setDebugName("ConsolePassAnim.animIndex");
	ConsolePassAnim.propIndex = new(PropScale,ConsolePassAnim.animIndex,ConsolePassAnim.animIndex,kCenterDrawing,0,0);
	ConsolePassAnim.drawingPass:addProp(ConsolePassAnim.propIndex,0);
    ConsolePassAnim.animIndex:setEvent(ConsolePassAnim, ConsolePassAnim.onAnimComplete3);
end

--private
ConsolePassAnim.onAnimComplete3 = function (self,anim_type, anim_id, repeat_or_loop_num)
	ConsolePassAnim.drawingPass:removeProp(0);
	delete(ConsolePassAnim.propIndex);
	delete(ConsolePassAnim.animIndex);
	ConsolePassAnim.drawingPass:setImageIndex(0);

    ConsolePassAnim.animIndex = new(AnimDouble,kAnimNormal,0.15,0.2,ConsolePassAnim.ms4);
    ConsolePassAnim.animIndex:setDebugName("ConsolePassAnim.animIndex");
	ConsolePassAnim.propIndex = new(PropScale,ConsolePassAnim.animIndex,ConsolePassAnim.animIndex,kCenterDrawing,0,0);
	ConsolePassAnim.drawingPass:addProp(ConsolePassAnim.propIndex,0);
    ConsolePassAnim.animIndex:setEvent(ConsolePassAnim, ConsolePassAnim.onAnimComplete4);
end

--private
ConsolePassAnim.onAnimComplete4 = function (self,anim_type, anim_id, repeat_or_loop_num)
	ConsolePassAnim.clearAndReset();  

	if ConsolePassAnim.obj and ConsolePassAnim.func then
		ConsolePassAnim.func(ConsolePassAnim.obj);
	end

end

--private
ConsolePassAnim.clearAndReset=function(self,anim_type, anim_id, repeat_or_loop_num)

	if not ConsolePassAnim.loaded then
		print_string("ConsolePassAnim.clearAndReset not AnimCheck.loaded ");
		return;
	end
	
	if ConsolePassAnim.playing then
		ConsolePassAnim.playing = false;
	
		ConsolePassAnim.drawingPass:removeProp(0);
		delete(ConsolePassAnim.propIndex);
		delete(ConsolePassAnim.animIndex);
	end
	
	ConsolePassAnim.drawingPass:setImageIndex(0);
	ConsolePassAnim.drawingPass:setVisible(false);
	
    if ConsolePassAnim.loaded then
    end
end

