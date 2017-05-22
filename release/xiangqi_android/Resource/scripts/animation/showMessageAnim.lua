-- file: 'showMessageAnim.lua'
-- desc: 弹提示信息


-- begin declare

ShowMessageAnim = {};

ShowMessageAnim.loaded = false;
ShowMessageAnim.show_time = 5*1000;
ShowMessageAnim.fontSize = 32;

ShowMessageAnim.LEVEL = 1;

ShowMessageAnim.play =  function(root,message)
	

	if not root then
		return
	end

	ShowMessageAnim.load(root);

	ShowMessageAnim.reset();

	ShowMessageAnim.message:setText(message);
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
	end
end

ShowMessageAnim.load = function(root)

	if ShowMessageAnim.loaded then
		print_string("ShowMessageAnim.loaded");
		return
	end

	ShowMessageAnim.message_bg = new(Image,"common/background/chat_show_bg_3.png",nil,nil,22,22,0,0); --drawable/chat_show_bg_3.png 
	ShowMessageAnim.message_bg:setLevel(TIPS_VISIBLE_LEVEL + ShowMessageAnim.LEVEL);
	ShowMessageAnim.message_bg:setPos(40,332);
	ShowMessageAnim.message_bg:setSize(400,64);
	root:addChild(ShowMessageAnim.message_bg);

	ShowMessageAnim.message = new(Text, "", 380, 44, kAlignCenter,nil,ShowMessageAnim.fontSize,255, 255, 255);
	ShowMessageAnim.message:setPos(10,10);
	ShowMessageAnim.message_bg:addChild(ShowMessageAnim.message);
	
	ShowMessageAnim.loaded = true; 
end

--退出房间时调用
ShowMessageAnim.deleteAll = function()
	ShowMessageAnim.loaded = false;
	
	if ShowMessageAnim.stopAnim then
		delete(ShowMessageAnim.stopAnim);
		ShowMessageAnim.stopAnim = nil;
	end

end
