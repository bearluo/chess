--Author : LeoLi
--Date   : 2015/7/20
--Description: loading动画


Loading = {};
             
-- 图片是否被加载
Loading.loaded = false;

-- 是否正在播放动画中
Loading.playing = false;



Loading.imgNum = 8;

-- 动画总时长
Loading.ms= 80 * Loading.imgNum;

-- 图片路径
Loading.resPath_Prefix = "animation/";

--public
--播放动画,可以反复调用
Loading.play = function (root, x, y, align, func, obj)
	if not root then 
		return; 
	end
	local delay = 0;
	
	if not Loading.loaded then
		Loading.loaded = true;
		delay = 0;
		local LoadingW, LoadingH = 114,44;
		local resCheckList = Loading:createResString(Loading.resPath_Prefix.."loading%d.png",Loading.imgNum);
		Loading.drawingCheck = new(Images, resCheckList);
		Loading.drawingCheck:setSize(LoadingW,LoadingH);
		root:addChild(Loading.drawingCheck);
        Loading.drawingCheck:setAlign(align or kAlignCenter);
        Loading.drawingCheck:setPos(x,y);
		Loading.drawingCheck:setVisible(false);
	else
		Loading.clearAndReset();
	end

	Loading.playing = true;
	Loading.drawingCheck:setVisible(true);
    --创建一个可变值[0,7]
	Loading.animIndex = new(AnimInt,kAnimRepeat,0,Loading.imgNum-1,Loading.ms , delay);
	Loading.animIndex:setDebugName("Loading.animIndex");
	--创建一个ImageIndex prop
	Loading.propIndex = new(PropImageIndex,Loading.animIndex);
	--赋给drawing ( pos = 0 ) 
	Loading.drawingCheck:addProp(Loading.propIndex,0);
	--anim结束后事件
    Loading.animIndex:setEvent(Loading, Loading.onAnimComplete);
    
    --回调事件
    Loading.obj = obj;
    Loading.func = func;
end



--public
--退出当前场景时调用
Loading.deleteAll = function()
	Loading.clearAndReset();
end
--private
Loading.createResString = function(self,imageName,nImages)
	local resString = {};
	for i=1,nImages do
		local strTmp=string.format(imageName,i);
		table.insert(resString,strTmp);
	end
	return resString;
end

--private
Loading.onAnimComplete = function (self,anim_type, anim_id, repeat_or_loop_num)
    Log.i("Loading.onAnimComplete "..repeat_or_loop_num);
    if repeat_or_loop_num >= 3 then
        Loading.clearAndReset();
        if Loading.func and Loading.obj then
            Loading.func(Loading.obj);
        end;
    end;   
end

--private
Loading.clearAndReset=function(self,anim_type, anim_id, repeat_or_loop_num)
	if not Loading.loaded then
		print_string("Loading.clearAndReset not Loading.loaded ");
		return;
	end

	if Loading.playing then
		Loading.playing = false;
	
		Loading.drawingCheck:removeProp(0);
		delete(Loading.propIndex);
		delete(Loading.animIndex);
		Loading.propIndex = nil;
		Loading.animIndex = nil;
	
	end
	
	Loading.drawingCheck:setImageIndex(0);
	Loading.drawingCheck:setVisible(false);
	
    if Loading.loaded then
        Loading.loaded = false
    end
end

