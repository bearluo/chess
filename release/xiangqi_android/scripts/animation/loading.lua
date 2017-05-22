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
Loading.ms= 100 * Loading.imgNum;   --  1000/30 * Loading.imgNum *3  每张图片放三帧

-- 图片路径
Loading.resPath_Prefix = "animation/";

Loading.m_resendBtnCall = {}
--public
--播放动画,可以反复调用
Loading.play = function (root, x, y, align, reSend)

	if not root then 
		return; 
	end
	local delay = 0;
	
	if not Loading.loaded then
		Loading.loaded = true;
		delay = -1;
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
	-- 重新发送 
    if reSend then
        Loading.reSendBtn = new(Button, "friends/friend_chat_resend_btn.png");
        Loading.reSendBtn:setOnClick(Loading, Loading.resendBtnClick);
        root:addChild(Loading.reSendBtn);
	    Loading.reSendBtn:setSize(28,28);
        Loading.reSendBtn:setAlign(kAlignTopRight);
        Loading.reSendBtn:setPos(x + 43,y + 8);
		Loading.reSendBtn:setVisible(false);
    end;
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

end

Loading.setResendBtnCallBack = function(obj ,fn)
    Loading.m_resendBtnCall.obj = obj;
    Loading.m_resendBtnCall.fn = fn;
end;

Loading.resendBtnClick = function(self)
--    Loading.drawingCheck:setVisible(true);
    Loading.reSendBtn:setVisible(false);
    Loading.deleteAll();
    if Loading.m_resendBtnCall.obj and Loading.m_resendBtnCall.fn then
        Loading.m_resendBtnCall.fn(Loading.m_resendBtnCall.obj);
    end;
end;



--public
--退出当前场景时调用
Loading.deleteAll = function()
	Loading.clearAndReset();

	if Loading.reSendBtn then
		delete(Loading.reSendBtn);
        Loading.reSendBtn = nil;
	end


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
    if repeat_or_loop_num == 10 then
        if Loading.reSendBtn then
            Loading.reSendBtn:setVisible(true);
        end;
        Loading.clearAndReset();
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

