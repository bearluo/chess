

NoticeScroll = {};

NoticeScroll.res_img = "drawable/room_home_img.png"
NoticeScroll.FONTSIZE = 24;
NoticeScroll.textX = 25;
NoticeScroll.textY =25;

NoticeScroll.timeX = 300;
NoticeScroll.timeY =25;


NoticeScroll.ALPHA_SEQ = 0;  --淡入淡出属性seq
NoticeScroll.SCROLL_SEQ = 1;  --画卷滚动属性seq

NoticeScroll.scroll_time = 800; --画卷展开收起时间

NoticeScroll.top_x = 110;
NoticeScroll.bottom_x = 465;
NoticeScroll.posX = 0;




NoticeScroll.open = false; --是否是


NoticeScroll.play = function(root,msg)

	if not root then
		return
	end

	if NoticeScroll.open then
		return
	end


	NoticeScroll.open = true;
	NoticeScroll.load(root);
	NoticeScroll.setText(msg);
	NoticeScroll.onAlpha();


end


NoticeScroll.load = function(root)

	if NoticeScroll.loaded then
		return;
	end


	NoticeScroll.animImg = new(Image,NoticeScroll.res_img);
	NoticeScroll.animImg:setPos(NoticeScroll.posX,NoticeScroll.posY);

	root:addChild(NoticeScroll.animImg);

	local text = "对手暂时离开，请稍候..." ;
	NoticeScroll.text = new(Text,text,0,0,kTextAlignTopLeft,nil,NoticeScroll.FONTSIZE,255, 128, 64);
	NoticeScroll.text:setPos(NoticeScroll.textX,NoticeScroll.textY);
	NoticeScroll.animImg:addChild(NoticeScroll.text);

	NoticeScroll.time_text = new(Text,"00:00",0,0,kTextAlignTopLeft,nil,NoticeScroll.FONTSIZE,0, 0, 0);
	NoticeScroll.time_text:setPos(NoticeScroll.timeX,NoticeScroll.timeY);
	NoticeScroll.animImg:addChild(NoticeScroll.time_text);

	NoticeScroll.animImg:setVisible(false);

	NoticeScroll.loaded = true;

end


NoticeScroll.setText = function(msg)
	if NoticeScroll.text and msg then
		NoticeScroll.text:setText(msg);
	end
end


--淡入淡出效果
NoticeScroll.onAlpha = function()

	if NoticeScroll.propAlpha then
		NoticeScroll.animImg:removeProp(NoticeScroll.ALPHA_SEQ);
		delete(NoticeScroll.propAlpha);
		NoticeScroll.propAlpha = nil;
	end

	if NoticeScroll.animAlpha then
		delete(NoticeScroll.animAlpha);
		NoticeScroll.animAlpha = nil;
	end

	if NoticeScroll.open then
		NoticeScroll.animImg:setPos(NoticeScroll.right_x,NoticeScroll.posY);
		NoticeScroll.animImg:setVisible(true);
		NoticeScroll.animAlpha = new(AnimDouble,kAnimNormal,0,1.0,300);
		NoticeScroll.animAlpha:setDebugName("NoticeScroll.animAlpha");

		NoticeScroll.propAlpha = new(PropTransparency,NoticeScroll.animAlpha);

		NoticeScroll.animImg:addProp(NoticeScroll.propAlpha,NoticeScroll.ALPHA_SEQ);
		NoticeScroll.animAlpha:setEvent(NoticeScroll,NoticeScroll.endAlpha);
	else
		NoticeScroll.animAlpha = new(AnimDouble,kAnimNormal,1.0,0,300);
		NoticeScroll.animAlpha:setDebugName("NoticeScroll.animAlpha");
		NoticeScroll.propAlpha = new(PropTransparency,NoticeScroll.animAlpha);

		NoticeScroll.animImg:addProp(NoticeScroll.propAlpha,NoticeScroll.ALPHA_SEQ);
		NoticeScroll.animAlpha:setEvent(NoticeScroll,NoticeScroll.endAlpha);

		NoticeScroll.stopTime();
	end
end

NoticeScroll.endAlpha = function()
	if NoticeScroll.propAlpha then
		NoticeScroll.animImg:removeProp(NoticeScroll.ALPHA_SEQ);
		delete(NoticeScroll.propAlpha);
		NoticeScroll.propAlpha = nil;
	end

	if NoticeScroll.animAlpha then
		delete(NoticeScroll.animAlpha);
		NoticeScroll.animAlpha = nil;
	end

	if NoticeScroll.open then
		NoticeScroll.onScroll();
	else

		NoticeScroll.animImg:setVisible(false);
	end
end


NoticeScroll.onScroll = function()


	if NoticeScroll.propScroll then
		NoticeScroll.animImg:removeProp(NoticeScroll.SCROLL_SEQ);
		delete(NoticeScroll.propScroll);
		NoticeScroll.propScroll = nil;
	end

	if NoticeScroll.animX  then
		delete(NoticeScroll.animX);
		NoticeScroll.animX = nil;
	end


	if NoticeScroll.open then	--展开
		NoticeScroll.animImg:setPos(NoticeScroll.left_x,NoticeScroll.posY);

		local diffX  = NoticeScroll.right_x - NoticeScroll.left_x;

		NoticeScroll.animX = new(AnimInt,kAnimNormal,diffX,0,NoticeScroll.scroll_time,-1); 
		NoticeScroll.animX:setDebugName("NoticeScroll.animX");

		NoticeScroll.propScroll = new(PropTranslate,NoticeScroll.animX,nil);
		NoticeScroll.animImg:addProp(NoticeScroll.propScroll,NoticeScroll.SCROLL_SEQ);

		NoticeScroll.animX:setEvent(NoticeScroll,NoticeScroll.endScroll);


		NoticeScroll.startTime(); --打开计时

	else  --收起
		NoticeScroll.animImg:setPos(NoticeScroll.right_x,NoticeScroll.posY);

		local diffX  = NoticeScroll.left_x - NoticeScroll.right_x;

		NoticeScroll.animX = new(AnimInt,kAnimNormal,diffX,0,NoticeScroll.scroll_time,-1); 
		NoticeScroll.animX:setDebugName("NoticeScroll.animX");

		NoticeScroll.propScroll = new(PropTranslate,NoticeScroll.animX,nil);
		NoticeScroll.animImg:addProp(NoticeScroll.propScroll,NoticeScroll.SCROLL_SEQ);
		NoticeScroll.animX:setEvent(NoticeScroll,NoticeScroll.endScroll);
	end
	

end


NoticeScroll.endScroll = function()

	if NoticeScroll.propScroll then
		NoticeScroll.animImg:removeProp(NoticeScroll.SCROLL_SEQ);
		delete(NoticeScroll.propScroll);
		NoticeScroll.propScroll = nil;
	end

	if NoticeScroll.animX  then
		delete(NoticeScroll.animX);
		NoticeScroll.animX = nil;
	end

	--如果是展开过程
	if NoticeScroll.open then


	else
		NoticeScroll.onAlpha();
	end

end


--收起画卷过程
NoticeScroll.close = function()

	if NoticeScroll.open then

		NoticeScroll.open = false;

		NoticeScroll.onScroll();
	else

	end
end


NoticeScroll.startTime = function()
	NoticeScroll.stopTime();

	NoticeScroll.sTime = os.time();

	NoticeScroll.m_timeAnim = new(AnimInt,kAnimLoop,0,1,1000,-1);
	NoticeScroll.m_timeAnim:setDebugName("NoticeScroll.m_timeAnim");
	NoticeScroll.m_timeAnim:setEvent(NoticeScroll,NoticeScroll.timeRun);

end

NoticeScroll.stopTime = function()
	if NoticeScroll.m_timeAnim then
		delete(NoticeScroll.m_timeAnim);
		NoticeScroll.m_timeAnim = nil;
	end
end

NoticeScroll.timeRun = function(self)
	local cTime = os.time();

	local time = NoticeScroll.time - (cTime - NoticeScroll.sTime);

	local time_text =  "00:00"

	if time > 0 then
		local min = math.floor(time/60);
		local sec = time%60;
		time_text = string.format("%02d:%02d",min,sec);

	else

	end

	NoticeScroll.time_text:setText(time_text);
end


NoticeScroll.clearAndReset = function()
	
	if NoticeScroll.open then
		NoticeScroll.close();
	end

end

NoticeScroll.deleteAll = function()
	NoticeScroll.clearAndReset();
	if NoticeScroll.loaded then
		NoticeScroll.realse();
	end

	NoticeScroll.loaded = false;
end

NoticeScroll.realse = function()


	-- if NoticeScroll.time_text then
	-- 	delete(NoticeScroll.time_text);
	-- 	NoticeScroll.time_text = nil;
	-- end

	-- if NoticeScroll.text then
	-- 	delete(NoticeScroll.text);
	-- 	NoticeScroll.text = nil;
	-- end


	-- if NoticeScroll.animImg then
	-- 	delete(NoticeScroll.animImg);
	-- 	NoticeScroll.animImg = nil;
	-- end

end