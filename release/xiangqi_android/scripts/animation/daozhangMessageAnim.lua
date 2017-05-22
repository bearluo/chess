
DaozhangMessageAnim = {};

DaozhangMessageAnim.loaded = false;
DaozhangMessageAnim.show_time = 5*1000;
DaozhangMessageAnim.fontSize = 32;

DaozhangMessageAnim.LEVEL = 1;

DaozhangMessageAnim.play =  function(root,message)

	if not root then
		return
	end

	DaozhangMessageAnim.load(root);

	DaozhangMessageAnim.reset();

	DaozhangMessageAnim.message:setText(message);
	DaozhangMessageAnim.message_bg:setVisible(true);

	DaozhangMessageAnim.stopAnim = new(AnimInt,kAnimNormal,0,1,DaozhangMessageAnim.show_time,-1); --多四秒，预防延迟
	DaozhangMessageAnim.stopAnim:setDebugName("DaozhangMessageAnim.stopAnim");
	DaozhangMessageAnim.stopAnim:setEvent(DaozhangMessageAnim,DaozhangMessageAnim.reset);
end



DaozhangMessageAnim.reset = function()

	if DaozhangMessageAnim.stopAnim then
		delete(DaozhangMessageAnim.stopAnim);
		DaozhangMessageAnim.stopAnim = nil;
	end

	if DaozhangMessageAnim.message_bg then
		DaozhangMessageAnim.message_bg:setVisible(false);
	end
end

DaozhangMessageAnim.textW = 358;
DaozhangMessageAnim.textH = 120;
DaozhangMessageAnim.load = function(root)

	if DaozhangMessageAnim.loaded then
		print_string("DaozhangMessageAnim.loaded");
		return
	end

	DaozhangMessageAnim.message_bg = new(Image,"common/background/chat_show_bg_3.png",nil,nil,16,16,0,0); --drawable/chat_show_bg_3.png 
	DaozhangMessageAnim.message_bg:setLevel(TIPS_VISIBLE_LEVEL + DaozhangMessageAnim.LEVEL);
	DaozhangMessageAnim.message_bg:setPos(40,332);
	DaozhangMessageAnim.message_bg:setSize(400,138);
	root:addChild(DaozhangMessageAnim.message_bg);

	DaozhangMessageAnim.message=new(TextView," ",DaozhangMessageAnim.textW,DaozhangMessageAnim.textH,kTextAlignCenter,"",ChatMessageAnim.fontSize,255,255,255);
	DaozhangMessageAnim.message:setPos(30,10);
	DaozhangMessageAnim.message_bg:addChild(DaozhangMessageAnim.message);
	
	DaozhangMessageAnim.loaded = true; 
end

--退出房间时调用
DaozhangMessageAnim.deleteAll = function()
	DaozhangMessageAnim.loaded = false;
	if DaozhangMessageAnim.message_bg then
		DaozhangMessageAnim.message_bg:setVisible(false);
		DaozhangMessageAnim.message_bg = nil;
	end

	if DaozhangMessageAnim.stopAnim then
		delete(DaozhangMessageAnim.stopAnim);
		DaozhangMessageAnim.stopAnim = nil;
	end

end
