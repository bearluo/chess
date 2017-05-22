require(BASE_PATH.."chessScene");


DapuScene = class(ChessScene);

DapuScene.s_controls = 
{
    dapu_back_btn = 1;
    dapu_del_btn = 2;
    dapu_edit_btn = 3;
    dapu_cover_btn = 4;
    dapu_type_toggle_view = 5;
    dapu_local_placehold = 6;
    local_empty_view = 7;
    dapu_net_placehold = 8;
}

DapuScene.s_cmds = 
{
    
}

DapuScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = DapuScene.s_controls;
    self:create();
end 
DapuScene.resume = function(self)
    ChessScene.resume(self);
    self:init();
end;


DapuScene.pause = function(self)
	ChessScene.pause(self);
end 


DapuScene.dtor = function(self)
    UserInfo.getInstance():setDapuDataNeedToSave(nil)
end 

----------------------------------- function ----------------------------

DapuScene.create = function(self)

    self.m_dapu_local_empty_view = self:findViewById(self.m_ctrls.local_empty_view);
    self.m_edit_btn = self:findViewById(self.m_ctrls.dapu_edit_btn);
    self.m_del_btn = self:findViewById(self.m_ctrls.dapu_del_btn);
    self.m_cover_btn = self:findViewById(self.m_ctrls.dapu_cover_btn);
    
    self.m_dapu_type_toggle_view = self:findViewById(self.m_ctrls.dapu_type_toggle_view);

    self.m_local_select_btn = new(RadioButton,{"common/left_normal.png","common/left_choose.png"});
	self.m_net_select_btn = new(RadioButton,{"common/right_normal.png","common/right_choose.png"});
    self.m_local_select_btn_icon = new(Images,{"dapu/local_chess_lib_uncheck_texture.png","dapu/local_chess_lib_check_texture.png",});
    self.m_net_select_btn_icon = new(Images,{"dapu/net_chess_lib_uncheck_texture.png","dapu/net_chess_lib_check_texture.png",});
    self.m_local_select_btn:addChild(self.m_local_select_btn_icon);
    self.m_local_select_btn_icon:setAlign(kAlignCenter);
    self.m_net_select_btn_icon:setAlign(kAlignCenter);
    self.m_net_select_btn:addChild(self.m_net_select_btn_icon);
    local toggle_w, toggle_h = self.m_dapu_type_toggle_view:getSize();
    
    self.m_local_select_btn:setSize(toggle_w /2,nil);
    self.m_net_select_btn:setSize(toggle_w /2,nil);

    self.m_dapu_type_toggle_view:addChild(self.m_net_select_btn);
    self.m_dapu_type_toggle_view:addChild(self.m_local_select_btn);

	local w = self.m_local_select_btn:getSize();
    self.m_net_select_btn:setPos(w);


    self.m_dapu_type_toggle_view:setOnChange(self,self.updataSelectState);
    
    local root_w, root_h = self:getSize();
	self.m_dapu_local_placeholder = self:findViewById(self.m_ctrls.dapu_local_placehold);
    self.m_dapu_local_placeholder:setSize(root_w,root_h-70);
	self.m_dapu_net_placeholder = self:findViewById(self.m_ctrls.dapu_net_placehold);
    self.m_dapu_net_placeholder:setSize(root_w,root_h-70);
    
    self.m_local_select_btn:setChecked(true);

    self:updataSelectState();
end

--初始化部分状态
DapuScene.init = function(self)
	if UserInfo.getInstance():getDapuDataNeedToSave() == nil then
		self.m_net_select_btn:setEnable(true);
		self.m_edit_btn:setVisible(true);
		self.m_del_btn:setVisible(false);
		self.m_cover_btn:setVisible(false);
	else
		self.m_net_select_btn:setEnable(false);
		self.m_edit_btn:setVisible(false);
		self.m_del_btn:setVisible(false);
		self.m_cover_btn:setVisible(true);
		UserInfo.getInstance():setDapuSelData(self.m_local_adapter:getTmpView(1):getData());
        
		self.lastView =  self.m_local_adapter:getTmpView(1);
		self.lastView:setBgVisible(true);
	end
end


DapuScene.updataSelectState = function(self)
    if self.m_local_select_btn:isChecked() then
        self.m_local_select_btn_icon:setImageIndex(1);
        self.m_dapu_local_placeholder:setVisible(true);
        self:setLocalCheckVisible(false);
		self.m_edit_btn:setVisible(true);
		self.m_del_btn:setVisible(false);
		self:showLocal();
    else
        self.m_local_select_btn_icon:setImageIndex(0);
        self.m_dapu_local_placeholder:setVisible(false);
    end
    
    if self.m_net_select_btn:isChecked() then
        self.m_net_select_btn_icon:setImageIndex(1);
        self.m_dapu_net_placeholder:setVisible(true);
        self.m_edit_btn:setVisible(true);
		self.m_del_btn:setVisible(false);
--		self:updateNet();--功能没有
    else
        self.m_net_select_btn_icon:setImageIndex(0);
        self.m_dapu_net_placeholder:setVisible(false);
    end
end

DapuScene.setLocalCheckVisible = function(self,isVisible)
	if self.m_local_adapter then
		for i=1,self.m_local_adapter:getCount() do
			self.m_local_adapter:getTmpView(i):setCheckVisible(isVisible);
		end
	end
end

DapuScene.showLocal = function(self)
    local data = self:requestCtrlCmd(DapuController.s_cmds.updateLocal);
    if data and table.maxn(data) > 0 then
		self.m_dapu_local_empty_view:setVisible(false);
        if self.m_local_list then
            self.m_dapu_local_placeholder:removeChild(self.m_local_list,true);
        end;
        self.m_local_adapter = new(CacheAdapter,DapuLocalItem,data);
		local w,h = self.m_dapu_local_placeholder:getSize();
		self.m_local_list = new(ListView,0,0,w,h);
        self.m_local_list:setAdapter(self.m_local_adapter);
		self.m_local_list:setOnItemClick(self,self.onLocalListItemClick);
		self.m_dapu_local_placeholder:addChild(self.m_local_list);
	else
        if self.m_local_list then
            self.m_local_list:setVisible(false);
        end;
		self.m_dapu_local_empty_view:setVisible(true);
	end
end

--本地数据列表点击事件
DapuScene.onLocalListItemClick = function(self,adapter,view,index)
    local data = view:getData();
	if UserInfo.getInstance():getDapuDataNeedToSave() then
        UserInfo.getInstance():setDapuSelData(data);
		self.lastView:setBgVisible(false);
		view:setBgVisible(true);
		self.lastView = view;
	elseif self.m_del_btn:getVisible() == true then
		view:setCheckState();
	else
        if data.manual_type == 2 then
        Log.i("error 本地不应该出现残局类型");
        elseif data.manual_type == 3 then
            UserInfo.getInstance():setDapuSelData(data);
            StateMachine:getInstance():pushState(States.ReplayRoom,StateMachine.STYPE_CUSTOM_WAIT);
        elseif data.manual_type == 4 then
            UserInfo.getInstance():setDapuSelData(data);
            StateMachine:getInstance():pushState(States.ReplayRoom,StateMachine.STYPE_CUSTOM_WAIT);
        elseif data.manual_type == 5 then
            StateMachine:getInstance():pushState(States.CustomBoard,StateMachine.STYPE_CUSTOM_WAIT);
        else
            UserInfo.getInstance():setDapuSelData(data);
            StateMachine:getInstance():pushState(States.ReplayRoom,StateMachine.STYPE_CUSTOM_WAIT);
        end
	end
end

----------------------------------- onClick ---------------------------------

DapuScene.onBack = function(self)
    self:requestCtrlCmd(DapuController.s_cmds.onBack);
end

--编辑事件
DapuScene.edit = function(self)
	print_string("Dapu.edit");
	self.m_cover_btn:setVisible(false);
	self.m_edit_btn:setVisible(false);
	self.m_del_btn:setVisible(true);

	if self.m_local_select_btn:isChecked() then--处理本地棋谱
		self:setLocalCheckVisible(true);
	else

	end
end




DapuScene.onDel = function(self)

	print_string("Dapu.del");
	self.m_cover_btn:setVisible(false);
	self.m_edit_btn:setVisible(true);
	self.m_del_btn:setVisible(false);
	if self.m_local_select_btn:isChecked() then--处理本地棋谱
		self:delLocal();
		self:setLocalCheckVisible(false);
	else
	end    

end;


--覆盖事件
DapuScene.onCover = function(self)
    print_string("Dapu.cover");
	self.m_cover_btn:setVisible(false);
	self.m_edit_btn:setVisible(true);
	self.m_del_btn:setVisible(false);
	if self.m_local_select_btn:isChecked() then--处理本地棋谱
		local selData = UserInfo.getInstance():getDapuSelData();
		UserInfo.getInstance():getDapuDataNeedToSave().fileName = selData.fileName;
		local uid = UserInfo.getInstance():getUid();
		GameCacheData.getInstance():saveString(selData.key .. uid,json.encode(UserInfo.getInstance():getDapuDataNeedToSave()));
		self.m_local_need_update = true;
        self:showLocal();
		self:setLocalCheckVisible(false);
	else
	end
	self.m_net_select_btn:setEnable(true);
	UserInfo.getInstance():setDapuDataNeedToSave(nil);
end;



--实施删除操作
DapuScene.delLocal = function(self)
	if self.m_local_adapter then
		local data = {};
		for i=1,self.m_local_adapter:getCount() do
			if self.m_local_adapter:getTmpView(i):getCheckState() == true then
				data[#data+1] = self.m_local_adapter:getTmpView(i):getData();
			end
		end
		local uid = UserInfo.getInstance():getUid();
		for key,value in pairs(data) do
			GameCacheData.getInstance():saveString(value.key .. uid,GameCacheData.NULL);
			local keys = GameCacheData.getInstance():getString(GameCacheData.DAPU_KEY .. uid,"");
			local keys_table = lua_string_split(keys, GameCacheData.chess_data_key_split);
			
			if #keys_table == 1 then
				keys_table = {};
			else
				for k,v in pairs(keys_table) do
					if v == value.key then
						keys_table[k] = GameCacheData.NULL;
					end
				end			
			end
			
			if #keys_table == 0 then
				GameCacheData.getInstance():saveString(GameCacheData.DAPU_KEY .. uid,GameCacheData.NULL);
			else
				GameCacheData.getInstance():saveString(GameCacheData.DAPU_KEY .. uid,table.concat(keys_table,GameCacheData.chess_data_key_split));
			end
		end
		if #data > 0 then--有数据改变，更新UI
			self.m_local_need_update = true;
			self:showLocal();
		end
	end
end

----------------------------------- config ------------------------------
DapuScene.s_controlConfig = 
{
	[DapuScene.s_controls.dapu_back_btn] = {"dapu_title_view","dapu_back_btn"};
	[DapuScene.s_controls.dapu_del_btn] = {"dapu_title_view","dapu_del_btn"};
	[DapuScene.s_controls.dapu_edit_btn] = {"dapu_title_view","dapu_edit_btn"};
	[DapuScene.s_controls.dapu_cover_btn] = {"dapu_title_view","dapu_cover_btn"};
	[DapuScene.s_controls.dapu_type_toggle_view] = {"dapu_title_view","dapu_type_toggle_view"};
	[DapuScene.s_controls.dapu_local_placehold] = {"dapu_content_view","dapu_local_placehold"};
	[DapuScene.s_controls.local_empty_view] = {"dapu_content_view","dapu_local_placehold","local_empty_view"};
	[DapuScene.s_controls.dapu_net_placehold] = {"dapu_content_view","dapu_net_placehold"};
};

DapuScene.s_controlFuncMap =
{
    [DapuScene.s_controls.dapu_back_btn] = DapuScene.onBack;
    [DapuScene.s_controls.dapu_edit_btn] = DapuScene.edit;
    [DapuScene.s_controls.dapu_del_btn]  = DapuScene.onDel;
    [DapuScene.s_controls.dapu_cover_btn]= DapuScene.onCover;


};


DapuScene.s_cmdConfig =
{
}


-------------------------------- private node ----------------
DapuScene.default_icon = "dapu/dapu_icon.png";

DapuLocalItem = class(Node);

DapuLocalItem.ctor = function(self,data)
	self.data = data;
	local check_x,check_y = 15,55;
	local index_x,index_y = 0,40;
	local icon_x,icon_y = 20,30;
	local fontsize = 25;
	local fileName_x,fileName_y = 100,40;
	local rivalName_x,rivalName_y = 100,70;
	local time_x ,time_y = 353,70;
	local result_x,result_y = 411,40;
	self.line_h = 140;
	
	--self.m_bg = new(Image,"dapu/dapu_listItem_bg.png");
	--self:addChild(self.m_bg);

    
	self.container = new(Node);
	self:addChild(self.container);
    self.container:setAlign(kAlignCenter);

    self:addContainer(self.container,data)

	self.m_focus_bg = new(Image,"dapu/dapu_listItem_focus_bg_2.png", nil, nil, 221, 221, nil, nil);
	self.m_focus_bg:setVisible(false);
    self.m_focus_bg:setAlign(kAlignCenter);
    self.m_focus_bg:setSize(460);
	self.container:addChild(self.m_focus_bg);

	self.m_checkBox = new(CheckBox,{"dapu/dapu_list_unchecked.png","dapu/dapu_list_checked.png"});
	--self.m_checkBox:setPos(check_x,check_y);
    self.m_checkBox:setAlign(kAlignLeft);
	self.m_checkBox:setVisible(false);
    self.m_checkBox:setEnable(false);
	self:addChild(self.m_checkBox);
end

--DapuLocalItem.getSize = function(self)
--	return 480,self.line_h;
--end

DapuLocalItem.getData = function(self)
	return self.data;
end

DapuLocalItem.setCheckVisible = function(self,isVisible)
	self.m_checkBox:setVisible(isVisible);
	if isVisible == true then
		self.container:setPos(40,0);
	else
		self.container:setPos(0,0);
	end
end

DapuLocalItem.setBgVisible = function(self,isVisible)
	self.m_focus_bg:setVisible(isVisible);
end

DapuLocalItem.setCheckState = function(self)
	if self.m_checkBox:isChecked() == true then
		self.m_checkBox:setChecked(false);
	else
		self.m_checkBox:setChecked(true);
	end
end

DapuLocalItem.getCheckState = function(self)
	return self.m_checkBox:isChecked();
end

DapuLocalItem.dtor = function(self)
	
end

DapuLocalItem.addContainer = function(self,container,data)
    self.m_bg = new(Button,"friends/friend_msg_bg.png");
    self.m_bg:setAlign(kAlignCenter)
    self.m_bg:setSrollOnClick();
    self.m_bg:setOnClick(self,self.gotoChessBoard);
    local w,h = self.m_bg:getSize();
    self:setSize(w+10,h+10);
    container:setSize(w,h);
    container:addChild(self.m_bg);
    self.m_icon = new(Image,"dapu/chess_icon.png");
    self.m_icon:setPos(15,0);
    self.m_icon:setAlign(kAlignLeft);
    self.m_bg:addChild(self.m_icon);

    self.m_icon_icon = new(Image,"dapu/fupan.png");
    self.m_icon_icon:setPos(-1,-3);
    self.m_icon:addChild(self.m_icon_icon);

   

    self.m_name = new(Text,data.fileName,nil,nil,nil,nil,28,105,50,35);
    self.m_name:setPos(100,22);
    self.m_bg:addChild(self.m_name);
    self.m_introduce = new(Node)--new(Text,"",nil,nil,nil,nil,20,105,50,35);
    self.m_introduce:setPos(100,60);
    self.m_bg:addChild(self.m_introduce);
    self.m_createTime = new(Text,data.time or "",nil,nil,nil,nil,18,105,50,35);
    self.m_createTime:setAlign(kAlignRight);
    self.m_createTime:setPos(15,-15);
    self.m_bg:addChild(self.m_createTime);
    if data.manual_type == 2 then
        local text = new(Text,"创建者:2",nil,nil,nil,nil,20,105,50,35);
        self.m_icon_icon:setFile("dapu/endgate.png");
        self.m_introduce:addChild(text);
    elseif data.manual_type == 3 then
        self:setFuPan(data);
    elseif data.manual_type == 4 then
        local text = new(Text,"创建者:4",nil,nil,nil,nil,20,105,50,35);
        self.m_icon_icon:setFile("dapu/dapu.png");
        self.m_introduce:addChild(text);
    elseif data.manual_type == 5 then
        local text = new(Text,"创建者:5",nil,nil,nil,nil,20,105,50,35);
        self.m_icon_icon:setFile("dapu/endgate.png");
        self.m_introduce:addChild(text);
    else
        self:setFuPan(data);
    end
end

DapuLocalItem.setFuPan = function(self,data)
    self.m_icon_icon:setFile("dapu/fupan.png");
    local text = new(Text,data.red_name or "博雅象棋",nil,nil,nil,nil,20,105,50,35);
    self.m_introduce:addChild(text);
    local preView = text;
    local text = new(Text,"(红)",nil,nil,nil,nil,20,255,0,0);
    if data.win_flag == FLAG_RED then
        local img = new(Image,"dapu/win_icon.png");
        img:setAlign(kAlignLeft)
        img:setPos(-30);
        text:addChild(img);
    end
    self:addViewToOtherViewAfter(preView,text,5);
    local preView = text;
    local text = new(Text,"VS",nil,nil,nil,nil,20,105,50,35);
    self:addViewToOtherViewAfter(preView,text,5);
    local preView = text;
    local text = new(Text,data.black_name or "博雅象棋",nil,nil,nil,nil,20,105,50,35);
    self:addViewToOtherViewAfter(preView,text,5);
    local preView = text;
    local text = new(Text,"(黑)",nil,nil,nil,nil,20,35,35,35);
    if data.win_flag == FLAG_BLACK then
        local img = new(Image,"dapu/win_icon.png");
        img:setAlign(kAlignLeft)
        img:setPos(-30);
        text:addChild(img);
    end
    self:addViewToOtherViewAfter(preView,text,5);
end

DapuLocalItem.addViewToOtherViewAfter = function(self,preView,aftView,diffx)
    if preView:getParent() then
        diffx = diffx or 0;
        local x,y = preView:getPos();
        local w,h = preView:getSize();
        local aw,ah = aftView:getSize();
        aftView:setPos(x+w+diffx,y-h+ah);
        preView:getParent():addChild(aftView);
    end
end