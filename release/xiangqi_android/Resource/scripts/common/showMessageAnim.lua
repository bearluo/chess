-- file: 'showMessageAnim.lua'
-- desc: 弹提示信息


-- begin declare


ShowMessageAnim = {};

ShowMessageAnim.loaded = false;
ShowMessageAnim.show_time = 3500;
ShowMessageAnim.fontSize = 32;
ShowMessageAnim.LOG_TAG = "ShowMessageAnim";

ShowMessageAnim.LEVEL = 200;

ShowMessageAnim.BG = "dialog/dialog_transparent_bg.png"-- "room/room_chip_other_background.png"----"animation/message_bg.png";

ShowMessageAnim.play =  function(root,message)
	

	if not root then
		return
	end

	ShowMessageAnim.load(root);


	ShowMessageAnim.reset();

	root:addChild(ShowMessageAnim.message_bg);

	--[[根据文字适应长度
	ShowMessageAnim.message:setText("");
	ShowMessageAnim.message:setSize(0,nil);
	--]]
	ShowMessageAnim.message:setText(message);

	--[[根据文字适应长度
	local min_w = 400;
	local width,height = ShowMessageAnim.message:getSize();
	if width < min_w then
		width = min_w;
	end
	local bg_w = width + 20;
	local posx = (1280 - bg_w)/2;
	ShowMessageAnim.message_bg:setSize(bg_w,nil);
	ShowMessageAnim.message_bg:setPos(posx,322);
	Log.w(ShowMessageAnim.LOG_TAG,string.format("ShowMessageAnim.play width = %d,height = %d",width,height));
	--]]
	ShowMessageAnim.message_bg:setVisible(true);

	ShowMessageAnim.stopAnim = new(AnimInt,kAnimNormal,0,1,ShowMessageAnim.show_time,-1); --多四秒，预防延迟
	ShowMessageAnim.stopAnim:setDebugName("ShowMessageAnim.stopAnim");
	ShowMessageAnim.stopAnim:setEvent(ShowMessageAnim,ShowMessageAnim.reset);
end



ShowMessageAnim.reset = function()


	if ShowMessageAnim.stopAnim then
		delete(ShowMessageAnim.stopAnim);
		ShowMessageAnim.stopAnim = nil;
	end

	if ShowMessageAnim.message_bg then
		ShowMessageAnim.message_bg:setVisible(false);

		local parent = ShowMessageAnim.message_bg:getParent();
		if parent then
		    parent:removeChild(ShowMessageAnim.message_bg);
		end
	end
end

ShowMessageAnim.load = function(root)

	if ShowMessageAnim.loaded then
		Log.v(ShowMessageAnim.LOG_TAG,"ShowMessageAnim.loaded");
		return
	end

	--ShowMessageAnim.message_bg = new(Image,ShowMessageAnim.BG,nil,nil,16,16,0,0);
	ShowMessageAnim.message_bg = new(Image,ShowMessageAnim.BG,nil,nil,16,16,0,0);
	ShowMessageAnim.message_bg:setLevel(ShowMessageAnim.LEVEL);
	ShowMessageAnim.message_bg:setPos(280,322);
	ShowMessageAnim.message_bg:setSize(870,80);
	-- root:addChild(ShowMessageAnim.message_bg);

	ShowMessageAnim.message = new(Text, "", 830, 55, kAlignCenter,nil,ShowMessageAnim.fontSize,250, 230, 180);
	--ShowMessageAnim.message = new(Text, "", 780, 44, kAlignCenter,nil,ShowMessageAnim.fontSize,250, 230, 180);
	ShowMessageAnim.message:setPos(20,10);
	ShowMessageAnim.message_bg:addChild(ShowMessageAnim.message);
	ShowMessageAnim.loaded = true; 
end

--退出房间时调用
ShowMessageAnim.deleteAll = function()

	Log.w(ShowMessageAnim.LOG_TAG,"ShowMessageAnim.deleteAll");
	ShowMessageAnim.loaded = false;
	
	if ShowMessageAnim.stopAnim then
		delete(ShowMessageAnim.stopAnim);
		ShowMessageAnim.stopAnim = nil;
	end

end
