

RoomHomeScroll = {};

RoomHomeScroll.res_img = "drawable/room_home_img.png"
RoomHomeScroll.FONTSIZE = 24;
RoomHomeScroll.textX = 25;
RoomHomeScroll.textY =25;

RoomHomeScroll.timeX = 300;
RoomHomeScroll.timeY =25;


RoomHomeScroll.ALPHA_SEQ = 0;  --淡入淡出属性seq
RoomHomeScroll.SCROLL_SEQ = 1;  --画卷滚动属性seq

RoomHomeScroll.scroll_time = 300; --画卷展开收起时间

RoomHomeScroll.left_x = 110;
RoomHomeScroll.right_x = 465;
RoomHomeScroll.posY = 0;




RoomHomeScroll.open = false; --是否是


RoomHomeScroll.play = function(root,msg,time)

	if not root then
		return
	end

	if RoomHomeScroll.open then
		return
	end

	RoomHomeScroll.time = time or 90;

	RoomHomeScroll.open = true;
	RoomHomeScroll.load(root);
	RoomHomeScroll.setText(msg);
	RoomHomeScroll.onAlpha();


end


RoomHomeScroll.load = function(root)

	if RoomHomeScroll.loaded then
		return;
	end

	RoomHomeScroll.posX = RoomHomeScroll.left_x;


	RoomHomeScroll.animImg = new(Image,RoomHomeScroll.res_img);
	RoomHomeScroll.animImg:setPos(RoomHomeScroll.posX,RoomHomeScroll.posY);

	root:addChild(RoomHomeScroll.animImg);

	local text = "对手暂时离开，请稍候..." ;
	RoomHomeScroll.text = new(Text,text,0,0,kTextAlignTopLeft,nil,RoomHomeScroll.FONTSIZE,0, 0, 0);
	RoomHomeScroll.text:setPos(RoomHomeScroll.textX,RoomHomeScroll.textY);
	RoomHomeScroll.animImg:addChild(RoomHomeScroll.text);

	RoomHomeScroll.time_text = new(Text,"00:00",0,0,kTextAlignTopLeft,nil,RoomHomeScroll.FONTSIZE,0, 0, 0);
	RoomHomeScroll.time_text:setPos(RoomHomeScroll.timeX,RoomHomeScroll.timeY);
	RoomHomeScroll.animImg:addChild(RoomHomeScroll.time_text);

	RoomHomeScroll.animImg:setVisible(false);

	RoomHomeScroll.loaded = true;

end


RoomHomeScroll.setText = function(msg)
	if RoomHomeScroll.text and msg then
		RoomHomeScroll.text:setText(msg);
	end
end


--淡入淡出效果
RoomHomeScroll.onAlpha = function()

	if RoomHomeScroll.propAlpha then
		RoomHomeScroll.animImg:removeProp(RoomHomeScroll.ALPHA_SEQ);
		delete(RoomHomeScroll.propAlpha);
		RoomHomeScroll.propAlpha = nil;
	end

	if RoomHomeScroll.animAlpha then
		delete(RoomHomeScroll.animAlpha);
		RoomHomeScroll.animAlpha = nil;
	end

	if RoomHomeScroll.open then
		RoomHomeScroll.animImg:setPos(RoomHomeScroll.right_x,RoomHomeScroll.posY);
		RoomHomeScroll.animImg:setVisible(true);
		RoomHomeScroll.animAlpha = new(AnimDouble,kAnimNormal,0,1.0,300);
		RoomHomeScroll.animAlpha:setDebugName("RoomHomeScroll.animAlpha");

		RoomHomeScroll.propAlpha = new(PropTransparency,RoomHomeScroll.animAlpha);

		RoomHomeScroll.animImg:addProp(RoomHomeScroll.propAlpha,RoomHomeScroll.ALPHA_SEQ);
		RoomHomeScroll.animAlpha:setEvent(RoomHomeScroll,RoomHomeScroll.endAlpha);
	else
		RoomHomeScroll.animAlpha = new(AnimDouble,kAnimNormal,1.0,0,300);
		RoomHomeScroll.animAlpha:setDebugName("RoomHomeScroll.animAlpha");
		RoomHomeScroll.propAlpha = new(PropTransparency,RoomHomeScroll.animAlpha);

		RoomHomeScroll.animImg:addProp(RoomHomeScroll.propAlpha,RoomHomeScroll.ALPHA_SEQ);
		RoomHomeScroll.animAlpha:setEvent(RoomHomeScroll,RoomHomeScroll.endAlpha);

		RoomHomeScroll.stopTime();
	end
end

RoomHomeScroll.endAlpha = function()
	if RoomHomeScroll.propAlpha then
		RoomHomeScroll.animImg:removeProp(RoomHomeScroll.ALPHA_SEQ);
		delete(RoomHomeScroll.propAlpha);
		RoomHomeScroll.propAlpha = nil;
	end

	if RoomHomeScroll.animAlpha then
		delete(RoomHomeScroll.animAlpha);
		RoomHomeScroll.animAlpha = nil;
	end

	if RoomHomeScroll.open then
		RoomHomeScroll.onScroll();
	else

		RoomHomeScroll.animImg:setVisible(false);
	end
end


RoomHomeScroll.onScroll = function()


	if RoomHomeScroll.propScroll then
		RoomHomeScroll.animImg:removeProp(RoomHomeScroll.SCROLL_SEQ);
		delete(RoomHomeScroll.propScroll);
		RoomHomeScroll.propScroll = nil;
	end

	if RoomHomeScroll.animX  then
		delete(RoomHomeScroll.animX);
		RoomHomeScroll.animX = nil;
	end


	if RoomHomeScroll.open then	--展开
		RoomHomeScroll.animImg:setPos(RoomHomeScroll.left_x,RoomHomeScroll.posY);

		local diffX  = RoomHomeScroll.right_x - RoomHomeScroll.left_x;

		RoomHomeScroll.animX = new(AnimInt,kAnimNormal,diffX,0,RoomHomeScroll.scroll_time,-1); 
		RoomHomeScroll.animX:setDebugName("RoomHomeScroll.animX");

		RoomHomeScroll.propScroll = new(PropTranslate,RoomHomeScroll.animX,nil);
		RoomHomeScroll.animImg:addProp(RoomHomeScroll.propScroll,RoomHomeScroll.SCROLL_SEQ);

		RoomHomeScroll.animX:setEvent(RoomHomeScroll,RoomHomeScroll.endScroll);


		RoomHomeScroll.startTime(); --打开计时

	else  --收起
		RoomHomeScroll.animImg:setPos(RoomHomeScroll.right_x,RoomHomeScroll.posY);

		local diffX  = RoomHomeScroll.left_x - RoomHomeScroll.right_x;

		RoomHomeScroll.animX = new(AnimInt,kAnimNormal,diffX,0,RoomHomeScroll.scroll_time,-1); 
		RoomHomeScroll.animX:setDebugName("RoomHomeScroll.animX");

		RoomHomeScroll.propScroll = new(PropTranslate,RoomHomeScroll.animX,nil);
		RoomHomeScroll.animImg:addProp(RoomHomeScroll.propScroll,RoomHomeScroll.SCROLL_SEQ);
		RoomHomeScroll.animX:setEvent(RoomHomeScroll,RoomHomeScroll.endScroll);
	end
	

end


RoomHomeScroll.endScroll = function()

	if RoomHomeScroll.propScroll then
		RoomHomeScroll.animImg:removeProp(RoomHomeScroll.SCROLL_SEQ);
		delete(RoomHomeScroll.propScroll);
		RoomHomeScroll.propScroll = nil;
	end

	if RoomHomeScroll.animX  then
		delete(RoomHomeScroll.animX);
		RoomHomeScroll.animX = nil;
	end

	--如果是展开过程
	if RoomHomeScroll.open then


	else
		RoomHomeScroll.onAlpha();
	end

end


--收起画卷过程
RoomHomeScroll.close = function()

	if RoomHomeScroll.open then

		RoomHomeScroll.open = false;

		RoomHomeScroll.onScroll();
	else

	end
end


RoomHomeScroll.startTime = function()
	RoomHomeScroll.stopTime();

	RoomHomeScroll.sTime = os.time();

	RoomHomeScroll.m_timeAnim = new(AnimInt,kAnimLoop,0,1,1000,-1);
	RoomHomeScroll.m_timeAnim:setDebugName("RoomHomeScroll.m_timeAnim");
	RoomHomeScroll.m_timeAnim:setEvent(RoomHomeScroll,RoomHomeScroll.timeRun);

end

RoomHomeScroll.stopTime = function()
	if RoomHomeScroll.m_timeAnim then
		delete(RoomHomeScroll.m_timeAnim);
		RoomHomeScroll.m_timeAnim = nil;
	end
end

RoomHomeScroll.timeRun = function()
	local cTime = os.time();

	local time = RoomHomeScroll.time - (cTime - RoomHomeScroll.sTime);

	local time_text =  "00:00"

	if time > 0 then
		local min = math.floor(time/60);
		local sec = time%60;
		time_text = string.format("%02d:%02d",min,sec);

	else
		RoomHomeScroll.close();
	end

	RoomHomeScroll.time_text:setText(time_text);
end


RoomHomeScroll.clearAndReset = function()
	
	if RoomHomeScroll.open then
		RoomHomeScroll.close();
	end

end

RoomHomeScroll.deleteAll = function()
	RoomHomeScroll.clearAndReset();
	if RoomHomeScroll.loaded then
		RoomHomeScroll.realse();
	end

	RoomHomeScroll.loaded = false;
end

RoomHomeScroll.realse = function()
	RoomHomeScroll.stopTime();

	-- if RoomHomeScroll.time_text then
	-- 	delete(RoomHomeScroll.time_text);
	-- 	RoomHomeScroll.time_text = nil;
	-- end

	-- if RoomHomeScroll.text then
	-- 	delete(RoomHomeScroll.text);
	-- 	RoomHomeScroll.text = nil;
	-- end


	-- if RoomHomeScroll.animImg then
	-- 	delete(RoomHomeScroll.animImg);
	-- 	RoomHomeScroll.animImg = nil;
	-- end

end