BroadcastMessageAnim = {};

BroadcastMessageAnim.loaded = false;
BroadcastMessageAnim.show_time = 5*1000;
BroadcastMessageAnim.fontSize = 25;

BroadcastMessageAnim.LEVEL = 1;

BroadcastMessageAnim.index = 0;

BroadcastMessageAnim.ICON_IMG = "bicon";


BroadcastMessageAnim.play =  function(root,msgdata)

	if not root then
		return
	end

	BroadcastMessageAnim.load(root);

	BroadcastMessageAnim.reset();
	BroadcastMessageAnim.index = BroadcastMessageAnim.index +1;
	local message = {};

	message.mid = msgdata.mid;
	message.reward = msgdata.reward;
	message.img = msgdata.img;

	local lineText1 ="恭喜ID号"..message.mid.."获得";
	local lineText2 =message.reward.."的奖励"

--	local icon_name = BroadcastMessageAnim.ICON_IMG .. BroadcastMessageAnim.index ; --老版本逻辑
--	User.loadIcon(nil,icon_name,message.img);

	BroadcastMessageAnim.message1:setText(lineText1);
	BroadcastMessageAnim.message2:setText(lineText2);
	BroadcastMessageAnim.message_bg:setVisible(true);

	BroadcastMessageAnim.stopAnim = new(AnimInt,kAnimNormal,0,1,BroadcastMessageAnim.show_time,-1); --多四秒，预防延迟
	BroadcastMessageAnim.stopAnim:setDebugName("BroadcastMessageAnim.stopAnim");
	BroadcastMessageAnim.stopAnim:setEvent(BroadcastMessageAnim,BroadcastMessageAnim.reset);
    
    BroadcastMessageAnim.what = message.mid;
    local imageName = User.loadIcon1(nil,BroadcastMessageAnim.what,message.img);
    if imageName then
        BroadcastMessageAnim.showBroadcastImage2(imageName,BroadcastMessageAnim.what);
    end
end



BroadcastMessageAnim.initResult = function(model,keyParam)

    local callResult = dict_get_int(keyParam, kCallResult,-1);
    if callResult == 1 then -- 获取数值失败
        return nil;
    end
    local result = dict_get_string(keyParam , keyParam .. kResultPostfix);
    dict_delete(keyParam);
    local json_data = json.decode_node(result);
    --返回错误json格式.
    if json_data:get_value() then
        return json_data;   
    else
        return nil; 
    end
end


-- 显示下载图片 老版本
BroadcastMessageAnim.showBroadcastImage1 = function(imageName)
	if imageName then
		-- imageName = json_data.ImageName:get_value();
		-- print_string("BroadcastMessageAnim.downLoadBroadcastImage"  .. imageName);

		--排名的头像名字前缀只有五位
		local indexStr = string.sub(imageName,6,-1);
		index = tonumber(indexStr);

		if index == BroadcastMessageAnim.index and 
			BroadcastMessageAnim.ICON_IMG ==  string.sub(imageName,1,5) then

			BroadcastMessageAnim.message_icon = new(Image, imageName .. ".png");
			BroadcastMessageAnim.message_icon:setPos(30,13);
			BroadcastMessageAnim.message_icon:setSize(70,70);
			BroadcastMessageAnim.message_bg:addChild(BroadcastMessageAnim.message_icon);
		end
	end
end

-- 显示下载图片
BroadcastMessageAnim.showBroadcastImage2 = function(imageName,what)
	if BroadcastMessageAnim.loaded and imageName and tonumber(what) == BroadcastMessageAnim.what then
		BroadcastMessageAnim.message_icon = new(Image, imageName);
		BroadcastMessageAnim.message_icon:setPos(30,13);
		BroadcastMessageAnim.message_icon:setSize(70,70);
		BroadcastMessageAnim.message_bg:addChild(BroadcastMessageAnim.message_icon);
	end
end

BroadcastMessageAnim.reset = function()
	if BroadcastMessageAnim.stopAnim then
		delete(BroadcastMessageAnim.stopAnim);
		BroadcastMessageAnim.stopAnim = nil;
	end

	if BroadcastMessageAnim.message_bg then
		BroadcastMessageAnim.message_bg:setVisible(false);
	end
end

BroadcastMessageAnim.load = function(root)

	if BroadcastMessageAnim.loaded then
		print_string("BroadcastMessageAnim.loaded");
		return
	end

	BroadcastMessageAnim.message_bg = new(Image,"drawable/broadcast_msg_bg.png");
	BroadcastMessageAnim.message_bg:setLevel(TIPS_VISIBLE_LEVEL + BroadcastMessageAnim.LEVEL);
	BroadcastMessageAnim.message_bg:setPos(0,0);
	BroadcastMessageAnim.message_bg:setSize(480,121);
	root:addChild(BroadcastMessageAnim.message_bg);

	BroadcastMessageAnim.message1 = new(Text, "", 180, 0, kTextAlignLeft,nil,BroadcastMessageAnim.fontSize,255, 224, 168);
	BroadcastMessageAnim.message1:setPos(125,18);

	BroadcastMessageAnim.message2 = new(Text, "", 180, 0, kTextAlignLeft,nil,BroadcastMessageAnim.fontSize,255, 224, 168);
	BroadcastMessageAnim.message2:setPos(125,54);

	BroadcastMessageAnim.message_bg:addChild(BroadcastMessageAnim.message1);
	BroadcastMessageAnim.message_bg:addChild(BroadcastMessageAnim.message2);


	BroadcastMessageAnim.loaded = true; 
end

--退出房间时调用
BroadcastMessageAnim.deleteAll = function()
	BroadcastMessageAnim.loaded = false;
	BroadcastMessageAnim.index = 0;

	if BroadcastMessageAnim.message_bg then
		BroadcastMessageAnim.message_bg:setVisible(false);
	end

	if BroadcastMessageAnim.stopAnim then
		delete(BroadcastMessageAnim.stopAnim);
		BroadcastMessageAnim.stopAnim = nil;
	end

end
