require(VIEW_PATH .. "chat_dialog_view");
require("audio/sound_manager");
require("ui/node");
require("ui/adapter");
require("ui/listView");
--require("view/Android_800_480/chat_dialog_view");

WatchChatDialog = class();

WatchChatDialog.edit_len = 10;

WatchChatDialog.log_width = 480;


WatchChatDialog.ctor = function(self,room,root_view)
	if not room or not root_view then
		print_string("WatchChatDialog.ctor but not room or not root_view");
		return
	end

	self.m_room = room;


	self.m_root_view = root_view;
	self.m_root_view:setLevel(CHESS_LEVEL+1);


	local data = {};
	data.name = "博雅中国象棋";
	data.str = "欢迎来到博雅中国象棋！";
	self.m_log = {data};


	local w,h = self.m_root_view:getSize();
	self.m_chat_log_list = new(ScrollView,0,0,w,h,true);
	local first = new(WatchChatLogItem,data);
	self.m_chat_log_list:addChild(first);
	self.m_root_view:addChild(self.m_chat_log_list);
	self.m_root_view:setVisible(false);
end



WatchChatDialog.dtor = function(self)
	self.m_root_view = nil;
end

WatchChatDialog.isShowing = function(self)
	return self.m_root_view:getVisible();
end

WatchChatDialog.addChatLog = function(self,name,message)
	if not message or message == "" then
		return
	end
	
	local data = {};
	data.name = GameString.convert2UTF8(name);
	data.str = GameString.convert2UTF8(message);
	--self.m_chat_log_adapter:appendData({data});

	local item = new(WatchChatLogItem,data);
	self.m_chat_log_list:addChild(item);
end


WatchChatDialog.show = function(self)

	print_string("WatchChatDialog.show");
	self.m_root_view:setVisible(true);

end



WatchChatDialog.dismiss = function(self)
	self.m_root_view:setVisible(false);
end


WatchChatLogItem = class(Node);

WatchChatLogItem.ctor = function(self,data)

	self.m_name = data.name;
	self.m_str = data.str;
	self.m_text = new(TextView,self.m_name .. ":" .. self.m_str,WatchChatDialog.log_width,0,nil,nil,nil,255,255,255);
	self:addChild(self.m_text);
	self:setSize(self.m_text:getSize());


	self:setEventTouch(self,WatchChatLogItem.onTouch);
end

WatchChatLogItem.getText = function(self)
	return self.m_str;
end

WatchChatLogItem.getSize = function(self)
	-- return self.m_text_bg:getSize();
	local w,h = self.m_text:getSize();
	print_string("WatchChatLogItem.getSize w = " .. w .. " h = " .. h);
	return self.m_text:getSize();
end

WatchChatLogItem.getName = function(self)
	return self.m_name;
end

WatchChatLogItem.dtor = function(self)
	
end	