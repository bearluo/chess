require(BASE_PATH.."chessScene");

RankScene = class(ChessScene);

RankScene.s_controls = 
{
    rank_back_btn = 1;
    rank_type_toggle_view = 2;
    rank_content_view = 3;
    rank_score_placehold = 4;
    rank_money_placehold = 5;
    rank_num = 6;
    rank_user_icon = 7;
    rank_user_name = 8;
    rank_user_money = 9;
    rank_user_money_info = 10;
    rank_user_score_info = 11;
    rank_user_score = 12;
    rank_user_grade = 13;
}

RankScene.s_cmds = 
{
    showScoreRank = 1;
    showMoneyRank = 2;
    updateAdapter = 3;
}

RankScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = RankScene.s_controls;
    self:create();
end 
RankScene.resume = function(self)
    ChessScene.resume(self);
    self:updataView();
end;


RankScene.pause = function(self)
	ChessScene.pause(self);
end 


RankScene.dtor = function(self)

end 

----------------------------------- function ----------------------------

RankScene.onBack = function(self)
    self:requestCtrlCmd(RankController.s_cmds.onBack);
end

RankScene.create = function(self)
    self.m_rank_type_toggle_view = self:findViewById(self.m_ctrls.rank_type_toggle_view);

    self.m_score_select_btn = new(RadioButton,{"common/left_normal.png","common/left_choose.png"});
	self.m_money_select_btn = new(RadioButton,{"common/right_normal.png","common/right_choose.png"});
    self.m_score_select_btn_icon = new(Images,{"drawable/score_toggle_off.png","drawable/score_toggle_on.png",});
    self.m_money_select_btn_icon = new(Images,{"drawable/money_toggle_off.png","drawable/money_toggle_on.png",});
    self.m_score_select_btn:addChild(self.m_score_select_btn_icon);
    self.m_money_select_btn:addChild(self.m_money_select_btn_icon);

    self.m_rank_type_toggle_view:addChild(self.m_score_select_btn);
    self.m_rank_type_toggle_view:addChild(self.m_money_select_btn);
    
	local w = self.m_score_select_btn:getSize();
    self.m_money_select_btn:setPos(w);

    self.m_rank_type_toggle_view:setOnChange(self,self.updataSelectState);
    
    self.m_rank_user_score_info = self:findViewById(self.m_ctrls.rank_user_score_info);
    self.m_rank_user_money_info = self:findViewById(self.m_ctrls.rank_user_money_info);

    self.m_score_select_btn:setChecked(true);


    self.m_content_view = self:findViewById(self.m_ctrls.rank_content_view);
	self.m_rank_score_placeholder = self:findViewById(self.m_ctrls.rank_score_placehold);
	self.m_rank_money_placeholder = self:findViewById(self.m_ctrls.rank_money_placehold);


    local w,h = self:getSize();
    local cw,ch = self.m_content_view:getSize();
    self.m_content_view:setSize(nil,ch+h-800);

    self.m_rank_num = self:findViewById(self.m_ctrls.rank_num);
    self.m_rank_user_name = self:findViewById(self.m_ctrls.rank_user_name);
    self.m_rank_user_icon = self:findViewById(self.m_ctrls.rank_user_icon);

    self.m_rank_user_money = self:findViewById(self.m_ctrls.rank_user_money);
	self.m_rank_user_score = self:findViewById(self.m_ctrls.rank_user_score);
	self.m_rank_user_grade = self:findViewById(self.m_ctrls.rank_user_grade);

    
    self:updataSelectState();
end

RankScene.updataSelectState = function(self)
    if self.m_score_select_btn:isChecked() then
        self.m_score_select_btn_icon:setImageIndex(1);
        self.m_rank_score_placeholder:setVisible(true);
    else
        self.m_score_select_btn_icon:setImageIndex(0);
        self.m_rank_score_placeholder:setVisible(false);
    end
    
    if self.m_money_select_btn:isChecked() then
        self.m_money_select_btn_icon:setImageIndex(1);
        self.m_rank_money_placeholder:setVisible(true);
    else
        self.m_money_select_btn_icon:setImageIndex(0);
        self.m_rank_money_placeholder:setVisible(false);
    end
    self:updataView();
end

RankScene.updataView = function(self)
    if self.m_score_select_btn:isChecked() then
        self.m_rank_user_score_info:setVisible(true);
        self.m_rank_num:setText(self.m_scoreRank or 0);
    else
        self.m_rank_user_score_info:setVisible(false);
    end
    
    if self.m_money_select_btn:isChecked() then
        self.m_rank_user_money_info:setVisible(true);
        self.m_rank_num:setText(self.m_moneyRank or 0);
    else
        self.m_rank_user_money_info:setVisible(false);
    end
    if UserInfo.getInstance():getIconType() == -1 then
        self.m_rank_user_icon:setUrlImage(UserInfo.getInstance():getIcon());
    else
        self.m_rank_user_icon:setFile(UserInfo.DEFAULT_ICON[UserInfo.getInstance():getIconType()] or UserInfo.DEFAULT_ICON[1]);
    end
	self.m_rank_user_name:setText(UserInfo.getInstance():getName(),0,0);

	self.m_rank_user_money:setText(UserInfo.getInstance():getMoney());
	self.m_rank_user_score:setText("积分：" .. UserInfo.getInstance():getScore(),0,0);
	self.m_rank_user_grade:setText("战绩：" .. UserInfo.getInstance():getGrade(),0,0);
end

RankScene.showScoreRank = function(self,data)
    if not data then
        return ;
    end
    --PHP每次将自己的排名放在最后一个数据项
    self.m_rank_score_placeholder:removeAllChildren(true);
	local user = table.remove(data,table.maxn(data));
	self.m_scoreRank = user.rank;
	print_string(self.m_scoreRank);
	self.m_score_rank_adapter = new(CacheAdapter,ScoreRankItem,data);
	local w,h = self.m_rank_score_placeholder:getSize();
	self.m_score_rank_list = new(ListView,0,0,w,h);
    self.m_score_rank_list:setAdapter(self.m_score_rank_adapter);
	self.m_rank_score_placeholder:addChild(self.m_score_rank_list);
    self:updataView();
end

RankScene.showMoneyRank = function(self,data)
    if not data then
        return ;
    end
    self.m_rank_money_placeholder:removeAllChildren(true);
	local user = table.remove(data,table.maxn(data));
	self.m_moneyRank = user.rank;
	print_string(self.m_moneyRank);
	self.m_money_rank_adapter = new(CacheAdapter,MoneyRankItem,data);
	local w,h = self.m_rank_money_placeholder:getSize();
	self.m_money_rank_list = new(ListView,0,0,w,h);
    self.m_money_rank_list:setAdapter(self.m_money_rank_adapter);
	self.m_rank_money_placeholder:addChild(self.m_money_rank_list);
    self:updataView();
end

RankScene.updateAdapter = function(self,imageName,rank)
    if MoneyRankItem.ICON_PRE ==  string.sub(imageName,1,5) then
		if not self.m_money_rank_adapter then
			return
		end
		local data = self.m_money_rank_adapter:getData();
		local user = ToolKit.copyTable(data[rank]);
		user.img = imageName .. ".png";
		print_string(" user.img = " .. user.img);
		self.m_money_rank_adapter:updateData(rank,user);
	elseif ScoreRankItem.ICON_PRE == string.sub(imageName,1,5) then
		if not self.m_score_rank_adapter then
			return
		end
		local data = self.m_score_rank_adapter:getData();
		local user = ToolKit.copyTable(data[rank]);
		user.img = imageName .. ".png";
		print_string(" user.img = " .. user.img);
		self.m_score_rank_adapter:updateData(rank,user);
	else

	end
end

----------------------------------- onClick ---------------------------------





----------------------------------- config ------------------------------
RankScene.s_controlConfig = 
{
    [RankScene.s_controls.rank_back_btn] = {"rank_title_view","rank_back_btn"};
    [RankScene.s_controls.rank_type_toggle_view] = {"rank_title_view","rank_type_toggle_view"};
    [RankScene.s_controls.rank_content_view] = {"rank_content_view"};
    [RankScene.s_controls.rank_score_placehold] = {"rank_content_view","rank_score_placehold"};
    [RankScene.s_controls.rank_money_placehold] = {"rank_content_view","rank_money_placehold"};
    [RankScene.s_controls.rank_num] = {"rank_bottom_view","rank_num"};
    [RankScene.s_controls.rank_user_icon] = {"rank_bottom_view","rank_user_icon_bg","rank_user_icon"};
    [RankScene.s_controls.rank_user_name] = {"rank_bottom_view","rank_user_name"};
    [RankScene.s_controls.rank_user_money_info] = {"rank_bottom_view","rank_user_money_info"};
    [RankScene.s_controls.rank_user_money] = {"rank_bottom_view","rank_user_money_info","rank_user_money"};
    [RankScene.s_controls.rank_user_score_info] = {"rank_bottom_view","rank_user_score_info"};
    [RankScene.s_controls.rank_user_score] = {"rank_bottom_view","rank_user_score_info","rank_user_score"};
    [RankScene.s_controls.rank_user_grade] = {"rank_bottom_view","rank_user_score_info","rank_user_grade"};
};

RankScene.s_controlFuncMap =
{
    [RankScene.s_controls.rank_back_btn] = RankScene.onBack;
};


RankScene.s_cmdConfig =
{
    [RankScene.s_cmds.showScoreRank] = RankScene.showScoreRank;
    [RankScene.s_cmds.showMoneyRank] = RankScene.showMoneyRank;
    [RankScene.s_cmds.updateAdapter] = RankScene.updateAdapter;
}




------------------------------------ private node -----------------------------

RankScene.default_icon = "drawable/women_head01.png";
RankScene.user_type_img = {
	[2] = "drawable/rank_user_weibo.png";
	[4] = "drawable/rank_user_360.png";
}



------积分排行榜的Item
ScoreRankItem = class(Node);
ScoreRankItem.ICON_PRE = "SCORE";



MoneyRankItem = class(Node);
MoneyRankItem.ICON_PRE = "MONEY";

MoneyRankItem.ctor = function(self,user)
	local icon_x,icon_y = 135,14;
	local rank_fontsize = 28
	local money_fontsize = 22;
	local name_x,name_y = 235,20;
	local money_info_x ,money_info_y = 240 , 52;
	local rank_x,rank_y = 20,7;
	local user_type_x,user_type_y = 430,15;
	self.line_h = 105;


	---名次图标
	local img_rank =  nil;
	if user.rank  < 4 and user.rank > 0 then 
		img_rank = new(Image,string.format("drawable/rank_img_%d.png",user.rank));
	else
		img_rank = new(Image,"drawable/rank_img_4.png");
		text_rank = new(Text,user.rank,90,86,kAlignCenter,nil,rank_fontsize,255, 222, 155);
		-- if user.rank > 9 then
		-- 	text_rank:setPos(13,10);
		-- else
		-- 	text_rank:setPos(23,10);
		-- end
		--text_rank:setSize(img_rank:getSize());
		img_rank:addChild(text_rank);
	end
	img_rank:setPos(rank_x,rank_y);
	self:addChild(img_rank);




	--用户头像
	self.m_user_icon_bg = new(Image,"drawable/room_user_icon_bg.png",nil,nil,32,32,32,32);
	self.m_user_icon_bg:setSize(80,80);
	self.m_user_icon_bg:setPos(icon_x,icon_y);

	user.img = user.img or RankScene.default_icon;
	print_string("MoneyRankItem user.rank = " .. user.rank);
	print_string("MoneyRankItem user.img = " .. user.img);
	self.m_user_icon = new(Image,user.img);

	self.m_user_icon:setSize(70,70);
	self.m_user_icon:setPos(5,5);
	self.m_user_icon_bg:addChild(self.m_user_icon);
	self:addChild(self.m_user_icon_bg);


	
	--用户名称
	self.m_user_name = new(Text, user.name, 0, 0, nil,nil,money_fontsize,255, 222, 155);
	self.m_user_name:setPos(name_x,name_y);
	self:addChild(self.m_user_name);



	--用户金钱
	self.m_money_info = new(Image,"drawable/gold_blank_bg.png",nil,nil,32,32,0,0);
	self.m_money_info:setPos(money_info_x ,money_info_y);
	self.m_money_info:setSize(400,32);

	self.m_money_icon = new(Image,"drawable/room_money_texture.png");
	self.m_money_icon:setPos(-5,0);
	self.m_money_icon:setSize(32,32);
	self.m_money_info:addChild(self.m_money_icon);

	self.m_money_text = new(Text, user.money, 0, 0, nil,nil,money_fontsize,255, 185, 82)
	self.m_money_text:setPos(37,2);
	self.m_money_info:addChild(self.m_money_text);
	self:addChild(self.m_money_info);

	local user_type_path = RankScene.user_type_img[user.usertype];
	if user_type_path then
		self.m_user_type = new(Image,user_type_path);
		self.m_user_type:setPos(user_type_x,user_type_y);
		self:addChild(self.m_user_type);
	end



	self.m_horizontal_line = new(Image,"drawable/rank_horizontal_line.png");
	self.m_horizontal_line:setPos(0,self.line_h);
	self:addChild(self.m_horizontal_line);



	--拉取头像
	if user.img == RankScene.default_icon then --这个场景已经不用了
		local icon_name = MoneyRankItem.ICON_PRE .. user.rank;
--		User.loadIcon(nil,icon_name,user.icon);
		print_string("MoneyRankItem user.img ..rank = " .. user.rank);
	end
end

MoneyRankItem.getSize = function(self)
	return 480,self.line_h;
end

MoneyRankItem.dtor = function(self)
	
end	



------积分排行榜的Item
ScoreRankItem = class(Node);
ScoreRankItem.ICON_PRE = "SCORE";

ScoreRankItem.ctor = function(self,user)
	local icon_x,icon_y = 135,14;
	local rank_fontsize = 28
	local name_fontsize = 22;
	local score_fontsize = 18;

	local name_x,name_y = 227,15;
	local score_info_x ,score_info_y = 212 , 40;
	local rank_x,rank_y = 20,7;
	local user_type_x,user_type_y = 430,10;
	self.line_h = 105;


	---名次图标
	local img_rank =  nil;
	if user.rank  < 4 and user.rank > 0 then 
		img_rank = new(Image,string.format("drawable/rank_img_%d.png",user.rank));
	else
		img_rank = new(Image,"drawable/rank_img_4.png");
		text_rank = new(Text,user.rank,90,86,kAlignCenter,nil,rank_fontsize,255, 222, 155);
		img_rank:addChild(text_rank);
	end
	img_rank:setPos(rank_x,rank_y);
	self:addChild(img_rank);


	--用户头像
	self.m_user_icon_bg = new(Image,"drawable/room_user_icon_bg.png",nil,nil,32,32,32,32);
	self.m_user_icon_bg:setSize(80,80);
	self.m_user_icon_bg:setPos(icon_x,icon_y);

	user.img = user.img or RankScene.default_icon;
	print_string("ScoreRankItem user.rank = " .. user.rank);
	print_string("ScoreRankItem user.img = " .. user.img);
	self.m_user_icon = new(Image,user.img);


	self.m_user_icon:setSize(70,70);
	self.m_user_icon:setPos(5,5);
	self.m_user_icon_bg:addChild(self.m_user_icon);
	self:addChild(self.m_user_icon_bg);


	
	--用户名称
	self.m_user_name = new(Text, user.name, 0, 0, nil,nil,name_fontsize,255, 222, 155);
	self.m_user_name:setPos(name_x,name_y);
	self:addChild(self.m_user_name);



	--用户积分
	self.m_score_info = new(Image,"drawable/gold_blank_bg.png",nil,nil,32,32,0,0);
	self.m_score_info:setPos(score_info_x ,score_info_y);
	self.m_score_info:setSize(400,54);


	local score_str = string.format("积分：%d",user.score);
	self.m_score_text = new(Text, score_str, 0, 0, nil,nil,score_fontsize,255, 185, 82)
	self.m_score_text:setPos(13,5);
	self.m_score_info:addChild(self.m_score_text);


	local grade_str = string.format("战绩：%d胜/%d败/%d和",user.wintimes,user.losetimes,user.drawtimes);
	self.m_grade_text = new(Text, grade_str, 0, 0, nil,nil,score_fontsize,0, 255, 0)
	self.m_grade_text:setPos(13,27);
	self.m_score_info:addChild(self.m_grade_text);

	self:addChild(self.m_score_info);

	local user_type_path = RankScene.user_type_img[user.usertype];
	if user_type_path then
		self.m_user_type = new(Image,user_type_path);
		self.m_user_type:setPos(user_type_x,user_type_y);
		self:addChild(self.m_user_type);
	end



	--网格线
	self.m_horizontal_line = new(Image,"drawable/rank_horizontal_line.png");
	self.m_horizontal_line:setPos(0,self.line_h);
	self:addChild(self.m_horizontal_line);


	-- self.m_portrait_line = new(Image,"drawable/rank_portrait_line.png");
	-- self.m_portrait_line:setSize(3,self.line_h);
	-- self.m_portrait_line:setPos(100,0);
	-- self:addChild(self.m_portrait_line);

			--拉取头像
	if user.img == RankScene.default_icon then--这个场景已经不用了
		local icon_name = ScoreRankItem.ICON_PRE .. user.rank;
		User.loadIcon(nil,icon_name,user.icon);
	end



end

ScoreRankItem.getSize = function(self)
	return 480,self.line_h;
end

ScoreRankItem.dtor = function(self)
	
end	

