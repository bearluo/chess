-- file: 'ChatMessageAnim.lua'
-- desc: 聊天信息框动画


-- begin declare

ChatMessageAnim = {};
ChatMessageAnim.loaded = false;
ChatMessageAnim.chatBG = nil;
ChatMessageAnim.chatText = nil;
ChatMessageAnim.animStop = nil;
ChatMessageAnim.anim = nil;
ChatMessageAnim.prop = nil;
ChatMessageAnim.animTita = nil;
ChatMessageAnim.index = nil;
ChatMessageAnim.textX = nil;
ChatMessageAnim.textY = nil;
ChatMessageAnim.chatTextW = nil;
ChatMessageAnim.chatTextH = nil;

ChatMessageAnim.fontSize = 30;

ChatMessageAnim.stopms=3000;
ChatMessageAnim.ms=2000;

-- 聊天
ChatMessageAnim.chatMsg = {
	chatImgW = {[1]=284;[2]=284;[3]=390};
	chatImgH = {[1]=144;[2]=144;[3]=64};--64
	chatImgX = {[1]=0;[2]=0;[3]=0};
	chatImgY = {[1]=0;[2]=0;[3]=0};
    chatImgAlign = {[1]=kAlignBottom;[2]=kAlignTop;[3]=kAlignTop};


	chatTextW = {[1]=270;[2]=270;[3]=360}; -- 330
	chatTextH = {[1]=90;[2]=90;[3]=30};--28
	chatTextX = {[1]=0;[2]=0;[3]=0};
	chatTextY = {[1]=0;[2]=-10;[3]=0};
    chatTextR = {[1]=80;[2]=80;[3]=240};
    chatTextG = {[1]=80;[2]=80;[3]=230};
    chatTextB = {[1]=80;[2]=80;[3]=210}; 

	chatLeft = {[1]=100;[2]=100;[3]=64};  --9Grid拉伸
	chatRight = {[1]=100;[2]=100;[3]=64};
};

--参数:
ChatMessageAnim.play = function (root,userIndex,str)
	if userIndex < 0 or userIndex > 3 then
        return;
    end


	if not ChatMessageAnim.loaded then
		ChatMessageAnim.load(root);
	end

	--清除上一次的动画信息
	ChatMessageAnim.reset(userIndex);

	--显示聊天背景框
	ChatMessageAnim.chatBG[userIndex]:setVisible(true);
	--判断聊天textview是否被创建
	if not ChatMessageAnim.chatText[userIndex] then 
        local checkText = new(Text," ",ChatMessageAnim.chatTextW[userIndex],ChatMessageAnim.chatTextH[userIndex],kAlignCenter,"",ChatMessageAnim.fontSize,ChatMessageAnim.chatTextR[userIndex],ChatMessageAnim.chatTextG[userIndex],ChatMessageAnim.chatTextB[userIndex]);
        local w,h = checkText:getSize();
        if h > ChatMessageAnim.chatTextH[userIndex] then
            ChatMessageAnim.chatTextH[userIndex] = h;
        end
		ChatMessageAnim.chatText[userIndex]=new(TextView," ",ChatMessageAnim.chatTextW[userIndex],ChatMessageAnim.chatTextH[userIndex],kAlignCenter,"",ChatMessageAnim.fontSize,ChatMessageAnim.chatTextR[userIndex],ChatMessageAnim.chatTextG[userIndex],ChatMessageAnim.chatTextB[userIndex]);
        if userIndex == 1 then
            ChatMessageAnim.chatText[userIndex]:setAlign(kAlignBottomLeft);
        else
            ChatMessageAnim.chatText[userIndex]:setAlign(kAlignTopLeft);
        end
		ChatMessageAnim.chatText[userIndex]:setPos(ChatMessageAnim.textX[userIndex],ChatMessageAnim.textY[userIndex]);
		ChatMessageAnim.chatText[userIndex]:setSize(ChatMessageAnim.chatTextW[userIndex],ChatMessageAnim.chatTextH[userIndex]);
		ChatMessageAnim.chatText[userIndex]:setLevel(TIPS_VISIBLE_LEVEL);
        ChatMessageAnim.chatText[userIndex]:setAlign(kAlignCenter);
		ChatMessageAnim.chatBG[userIndex]:addChild(ChatMessageAnim.chatText[userIndex]);
	end
	
	--显示聊天textview并赋值
	ChatMessageAnim.chatText[userIndex]:setVisible(true);
	ChatMessageAnim.chatText[userIndex]:setText(str);
	ChatMessageAnim.hidTVScroll(userIndex);
	--1.5秒后调用
	ChatMessageAnim.animStop[userIndex] = new(AnimInt,kAnimNormal,1.0,0.0,ChatMessageAnim.stopms);
	ChatMessageAnim.animStop[userIndex]:setDebugName(string.format("ChatMessageAnim.animStop[%d]",userIndex));
	ChatMessageAnim.animStop[userIndex]:setEvent(userIndex,ChatMessageAnim.onStopTimer);
end

ChatMessageAnim.hidTVScroll = function(userIndex)
	if userIndex and ChatMessageAnim.chatText and ChatMessageAnim.chatText[userIndex] and ChatMessageAnim.chatText[userIndex].m_scrollBar then
		ChatMessageAnim.chatText[userIndex].m_scrollBar:setVisibleImmediately(false);
		--ChatMessageAnim.chatText[userIndex].m_scrollBar:setVisible(false);
	end
end

ChatMessageAnim.onStopTimer = function(userIndex,anim_type, anim_id, repeat_or_loop_num)
-- print_string("---------------------------------------onStopTimer=" .. userIndex);
	delete(ChatMessageAnim.animStop[userIndex]);
	ChatMessageAnim.animStop[userIndex] = nil;
	-- need muti_line delay 1.5 seconds
	--文字显示需要的高度
	local resH = ChatMessageAnim.chatText[userIndex].m_res.m_height;
	--textview当前显示区域的高度
	local clipH = ChatMessageAnim.chatText[userIndex].m_height;

	-- single line
	if resH < clipH then
		ChatMessageAnim.ms = 600;
		ChatMessageAnim.anim[userIndex] = new(AnimDouble,kAnimNormal,1.0,0.0,ChatMessageAnim.ms);
		ChatMessageAnim.anim[userIndex]:setDebugName(string.format("ChatMessageAnim.anim[%d]",userIndex));

		ChatMessageAnim.prop[userIndex] = new(PropTransparency,ChatMessageAnim.anim[userIndex]);
		ChatMessageAnim.anim[userIndex]:setEvent(userIndex,ChatMessageAnim.reset);
		ChatMessageAnim.chatBG[userIndex]:addProp(ChatMessageAnim.prop[userIndex],0);
		ChatMessageAnim.chatText[userIndex]:addProp(ChatMessageAnim.prop[userIndex],0);
	elseif resH > clipH  then
		ChatMessageAnim.animTita[userIndex] = new (AnimInt,kAnimRepeat,1.0,0.0,30);
		ChatMessageAnim.animTita[userIndex]:setEvent(userIndex,ChatMessageAnim.onTita);
	else
		ChatMessageAnim.reset(userIndex);
	end
end

--信息滚动
ChatMessageAnim.onTita = function(userIndex,anim_type, anim_id, repeat_or_loop_num)
	local deltas = ChatMessageAnim.chatTextH[userIndex]/13;
	if(6 <= repeat_or_loop_num and 19 >= repeat_or_loop_num) then 	
		ChatMessageAnim.chatText[userIndex]:onScroll(kScrollerStatusAuto,0,-deltas*(repeat_or_loop_num-6));
		ChatMessageAnim.hidTVScroll(userIndex);
	elseif( repeat_or_loop_num >= 50) then
		ChatMessageAnim.ms = 1000;
		if ChatMessageAnim.chatBG[userIndex] then
			if not ChatMessageAnim.anim[userIndex] then
				ChatMessageAnim.anim[userIndex] = new(AnimDouble,kAnimNormal,1.0,0.0,ChatMessageAnim.ms);
				ChatMessageAnim.anim[userIndex]:setDebugName(string.format("ChatMessageAnim.anim[%d]",userIndex));
				
				ChatMessageAnim.prop[userIndex] = new(PropTransparency,ChatMessageAnim.anim[userIndex]);
				ChatMessageAnim.anim[userIndex]:setEvent(userIndex,ChatMessageAnim.reset);
				ChatMessageAnim.chatBG[userIndex]:addProp(ChatMessageAnim.prop[userIndex],0);
				ChatMessageAnim.chatText[userIndex]:addProp(ChatMessageAnim.prop[userIndex],0);
			end
		end
	end
end
--动画结束
ChatMessageAnim.reset = function(userIndex)
	-- print_string("---------------------------------------reset=" .. userIndex);
		delete(ChatMessageAnim.animStop[userIndex]);
		ChatMessageAnim.animStop[userIndex] = nil;

		if ChatMessageAnim.chatBG[userIndex] then
			ChatMessageAnim.removeProp(ChatMessageAnim.chatBG[userIndex],ChatMessageAnim.prop[userIndex]);
			ChatMessageAnim.chatBG[userIndex]:setVisible(false);
		end

		if ChatMessageAnim.chatText[userIndex] then
			ChatMessageAnim.removeProp(ChatMessageAnim.chatText[userIndex],ChatMessageAnim.prop[userIndex]);
			-- if ChatMessageAnim.root then
			-- 	DrawingBase.removeChild(ChatMessageAnim.root,ChatMessageAnim.chatText[userIndex]);
			-- end
			delete(ChatMessageAnim.chatText[userIndex]);
			ChatMessageAnim.chatText[userIndex] = nil;
			--ChatMessageAnim.chatText[userIndex]:setVisible(false);
		end
		--ChatMessageAnim.hidTVScroll();
		delete(ChatMessageAnim.animTita[userIndex]);
		ChatMessageAnim.animTita[userIndex] = nil;

		delete(ChatMessageAnim.anim[userIndex]);
		ChatMessageAnim.anim[userIndex] = nil;

		delete(ChatMessageAnim.prop[userIndex]);
		ChatMessageAnim.prop[userIndex] = nil;
end

-- 判断prop 不为空时移除
ChatMessageAnim.removeProp = function(view,prop)
    if view and (prop and prop.m_propID) then
        view:removePropByID(prop.m_propID);
    end
end

-- load resources
ChatMessageAnim.load = function(root)
    ChatMessageAnim.root=root;
	if ChatMessageAnim.chatBG then
		for _,v in ipairs(ChatMessageAnim.chatBG) do
			--DrawingBase.removeChild(root,v);
			root:removeChild(v);
			delete(v);
			v = nil;
		end
	end
	local diff = ChatMessageAnim.chatMsg;
	ChatMessageAnim.chatBG = {};
	for i = 1,3 do 
		ChatMessageAnim.chatBG[i] = new(Image,"common/background/chat_show_bg_"..i..".png",nil,nil,diff.chatLeft[i],diff.chatRight[i],0,0);
        if i == 1 then
            ChatMessageAnim.chatBG[i]:setAlign(kAlignBottom);
        else
            ChatMessageAnim.chatBG[i]:setAlign(kAlignTop);
        end
		ChatMessageAnim.chatBG[i]:setPos(diff.chatImgX[i],diff.chatImgY[i]);
        ChatMessageAnim.chatBG[i]:setAlign(diff.chatImgAlign[i]);
		ChatMessageAnim.chatBG[i]:setSize(diff.chatImgW[i],diff.chatImgH[i]);
		root:addChild(ChatMessageAnim.chatBG[i]);

		ChatMessageAnim.chatBG[i]:setLevel(TIPS_VISIBLE_LEVEL);
		ChatMessageAnim.chatBG[i]:setVisible(false);
	end
	
	-- create text_drawing
	ChatMessageAnim.chatText = {};
	ChatMessageAnim.textX = diff.chatTextX;
	ChatMessageAnim.textY = diff.chatTextY;
	ChatMessageAnim.chatTextW=diff.chatTextW;
	ChatMessageAnim.chatTextH=diff.chatTextH;
    ChatMessageAnim.chatTextR=diff.chatTextR;
    ChatMessageAnim.chatTextG=diff.chatTextG;
    ChatMessageAnim.chatTextB=diff.chatTextB;
	ChatMessageAnim.animStop = {};
	ChatMessageAnim.anim = {};
	ChatMessageAnim.prop = {};
	ChatMessageAnim.animTita = {};

	ChatMessageAnim.loaded = true;

end

--退出房间时调用
ChatMessageAnim.deleteAll=function()
	if ChatMessageAnim.loaded  == false then
		return;
	end
	ChatMessageAnim.loaded = false;

	ChatMessageAnim.index = nil;
	ChatMessageAnim.textX = nil;
	ChatMessageAnim.textY = nil;
	ChatMessageAnim.chatTextW = nil;
	ChatMessageAnim.chatTextH = nil;

	for _,v in pairs(ChatMessageAnim.animStop) do
			delete(v);
			v = nil
	end
	ChatMessageAnim.animStop = nil;

	for k,v in pairs(ChatMessageAnim.chatText) do
		ChatMessageAnim.removeProp(v,ChatMessageAnim.prop[k]);
        delete(v);
	end
	ChatMessageAnim.chatText = nil;

	for _,v in pairs(ChatMessageAnim.animTita) do
		delete(v);
		v = nil
	end
	ChatMessageAnim.animTita = nil;

	for _,v in pairs(ChatMessageAnim.anim) do
		delete(v);
		v = nil
	end
	ChatMessageAnim.anim = nil;

	for _,v in pairs(ChatMessageAnim.prop) do
		delete(v);
		v = nil
	end
	ChatMessageAnim.prop = nil;
    if ChatMessageAnim.chatBG then
		for _,v in ipairs(ChatMessageAnim.chatBG) do
			delete(v);
			v = nil;
		end
	end
	ChatMessageAnim.chatBG=nil;
end