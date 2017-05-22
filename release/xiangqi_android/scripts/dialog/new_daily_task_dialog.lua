require(BASE_PATH.."chessDialogScene");
require(VIEW_PATH.."new_daily_task_dialog_view");

NewDailyTaskDialog = class(ChessDialogScene,false)


NewDailyTaskDialog.ctor = function(self,task)
    super(self,new_daily_task_dialog_view);
    self.m_root_view = self.m_root;
    self.m_ctrls = NewDailyTaskDialog.s_controls;
    self.m_task = task;
    self.m_content_view = self.m_root_view:getChildByName("body_view");
    self:setShieldClick(self,self.dismiss);
    self.m_content_view:setEventTouch(self.m_content_view,function() end);


    self.m_close_btn = self.m_content_view:getChildByName("close_btn");
    self.m_close_btn:setOnClick(self,self.dismiss);
    self:create(task);
end

NewDailyTaskDialog.dtor = function(self)
    delete(self.anim_end);
    self.anim_end = nil;
end

NewDailyTaskDialog.isShowing = function(self)
	return self:getVisible();
end

NewDailyTaskDialog.onHttpRequestsCallBack = function(self,command,...)
	Log.i("NewDailyTaskDialog.onHttpRequestsCallBack");
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self,...);
	end 
end

NewDailyTaskDialog.setHandler = function(self,handler)
    self.m_handler = handler;
end


NewDailyTaskDialog.show = function(self)
	print_string("NewDailyTaskDialog.show ... ");
    self.super.show(self);
    self:setVisible(true);
	kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
	for i = 1,4 do 
        if not self.m_content_view:checkAddProp(i) then
            self.m_content_view:removeProp(i);
        end 
    end

    local w,h = self.m_content_view:getSize();
--    local anim = self.m_content_view:addPropTranslateWithEasing(1,kAnimNormal, 400, -1, nil, "easeOutBounce", 0,0, h, -h);
    local anim = self.m_content_view:addPropTranslate(1,kAnimNormal,600,-1,0,0,h+25,0);
    if anim then
        anim:setEvent(self,function()
            self.m_content_view:addPropTranslate(4,kAnimNormal,200,-1,0,0,0,-25);
            delete(anim);
            anim = nil;
        end);
    end
    self.anim_end = new(AnimInt,kAnimNormal,0,1,800,-1);
    if self.anim_end then
        self.anim_end:setEvent(self,function()
--            self.m_content_view:removeProp(1);	
            for i = 1,4 do 
                if not self.m_content_view:checkAddProp(i) then
                    self.m_content_view:removeProp(i);
                end 
            end
            delete(self.anim_end);
        end);
    end
end


NewDailyTaskDialog.dismiss = function(self)
    self.super.dismiss(self);
    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpRequestsCallBack);
--    HttpModule.getInstance():execute(HttpModule.s_cmds.GetNewDailyList);
    for i = 1,4 do 
        if not self.m_content_view:checkAddProp(i) then
            self.m_content_view:removeProp(i);
        end 
    end
    local w,h = self.m_content_view:getSize();
    local anim = self.m_content_view:addPropTranslate(2,kAnimNormal,300,-1,0,0,0,h);
    self.m_content_view:addPropTransparency(3,kAnimNormal,200,-1,1,0);
    if anim then
        anim:setEvent(self,function()
            self:setVisible(false);
            self.m_content_view:removeProp(2);
            self.m_content_view:removeProp(3);
            delete(anim);
        end);
    end
end

NewDailyTaskDialog.create = function(self,task)
    self.m_ListView = self:findViewById(self.m_ctrls.contentList);
    self:createListView(task);
end

NewDailyTaskDialog.updateListView = function(self,index,data)
    if self.m_adapter then
        self.m_adapter:updateData(index,data);
    end
end

NewDailyTaskDialog.updateListViewByPropId = function(self,id)
    if self.m_adapter then
        local datas = self.m_adapter:getData();
        if datas == nil then return false; end
        for i,data in pairs(datas) do
            if data.id == id then
                data.status = 2;
                self:updateListView(i,data);
                return true;
            end
        end
    end
    return false;
end

NewDailyTaskDialog.updateListViewByDate = function(self,tasks)
    if self.m_adapter then
        local datas = self.m_adapter:getData();
        if datas == nil then return end
        for j,task in pairs(tasks) do
            for i,data in pairs(datas) do
                if data.id == task.id then
                    self:updateListView(i,task);
                    break
                end
            end
        end
    end
end

NewDailyTaskDialog.createListView = function(self,datas)
    if not datas then return ; end
    self.m_adapter = new(CacheAdapter,NewDailyTaskDialogItem,datas);
    self.m_ListView:setAdapter(self.m_adapter);
end


NewDailyTaskDialog.onGetNewDailyRewardResponse = function(self,isSuccess,message)
    if not isSuccess or message.data:get_value() == nil then
        ChessToastManager.getInstance():show("领取失败");
        return ;
    end
    require(PAY_PATH.."exchangePay");
    local data = json.analyzeJsonNode(message.data);
    if data.go_status == 200 then
        local taskId = data.task_id;
        if data.prop then
            for i,v in pairs(data.prop) do
                local goods_type = ExchangePay.getStartNum(v.rid);
                if goods_type > 0 then
                    self:updatePropById(goods_type,v.num);
                end
            end
        end
        local tips = data.tip_text or "领取成功";
        if taskId then
            self:updateListViewByPropId(taskId);
        end
--        if not string.find(tips,"金币") then
--            ChessToastManager.getInstance():show(tips);
--        end
    else
        ChessToastManager.getInstance():show("领取失败!");
    end
end

NewDailyTaskDialog.updatePropById = function(self,goods_type,num)
    if goods_type and num and goods_type > 0 then
        if goods_type == 1 then--生命回复 --已经不要了
    --	    	local limitNum = UserInfo.getInstance():getLifeLimitNum();
    --			UserInfo.getInstance():setLifeNum(limitNum);
	    elseif goods_type == 2 then --悔棋
		    local undoNum = UserInfo.getInstance():getUndoNum();
		    undoNum = undoNum + num; 
		    UserInfo.getInstance():setUndoNum(undoNum);
	    elseif goods_type == 3 then --提示 
		    local tipsNum = UserInfo.getInstance():getTipsNum();
		    tipsNum = tipsNum + num; 
		    UserInfo.getInstance():setTipsNum(tipsNum);
	    elseif goods_type == 4 then --起死回生
		    local reviveNum = UserInfo.getInstance():getReviveNum();
		    reviveNum = reviveNum + num; 
		    UserInfo.getInstance():setReviveNum(reviveNum);
	    elseif goods_type == 5 then --增加生命上限 --已经不要了
    --			local limitNum = UserInfo.getInstance():getLifeLimitNum();
    --			limitNum = limitNum + num; 
    --			if limitNum <=14 then
    --				UserInfo.getInstance():setLifeLimitNum(limitNum);
    --			end
        elseif goods_type == 6 then--残局大关 --已经不要了
    --			dict_set_string(kEndGateReplace,kEndGateReplace..kparmPostfix,""..UserInfo.getInstance():getUid());
    --			call_native(kEndGateReplace);
	    elseif goods_type == 7 then--dapu
	  	    UserInfo.getInstance():setDapuEnable(1);
	    elseif goods_type == 8 then--单机大关 --已经不要了
    --			UserInfo.getInstance():setHasConsoleNeedBuy(false);
    --			local uid = UserInfo.getInstance():getUid();
    --			local level = GameCacheData.getInstance():getInt(GameCacheData.CONSOLE_MAX_LEVEL .. uid,0);
    --			GameCacheData.getInstance():saveInt(GameCacheData.CONSOLE_MAX_LEVEL .. uid,level+1);
    ----			PHPInterface.uploadConsoleProgress();
	    end

	    --回调回去做本地发货或者更新关卡
	    --ExchangePay.uploadOrDownPropData(1);
    end
end

NewDailyTaskDialog.s_controls = 
{
--    close = 1;
    contentList = 2;
};

NewDailyTaskDialog.s_controlConfig = 
{
--    [NewDailyTaskDialog.s_controls.close] = {"bg","title","close"};
--    [NewDailyTaskDialog.s_controls.content_view] = {"body_view"};
    [NewDailyTaskDialog.s_controls.contentList] = {"body_view","contentList"};
};

NewDailyTaskDialog.s_controlFuncMap = 
{
--    [NewDailyTaskDialog.s_controls.close] = NewDailyTaskDialog.dismiss;
};

NewDailyTaskDialog.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.GetNewDailyReward] = NewDailyTaskDialog.onGetNewDailyRewardResponse;
};


-------------------------------- private node -------------

NewDailyTaskDialogItem = class(Node)
NewDailyTaskDialogItem.s_w = 650;
NewDailyTaskDialogItem.s_h = 128;

NewDailyTaskDialogItem.s_icon = {
    "dailytask/commit_userinfo_icon.png",
    "dailytask/daily_sign_icon.png",
    "dailytask/endgate_icon.png",
    "dailytask/online_game_icon.png",
    "dailytask/up_user_icon.png",
};

NewDailyTaskDialogItem.idToIcon = {
    [1] = "dailytask/endgate_icon.png";
    [2] = "dailytask/online_game_icon.png";
    [3] = "dailytask/daily_sign_icon.png";
    [4] = "dailytask/daily_sign_icon.png";
    [8] = "dailytask/up_user_icon.png";
    [9] = "dailytask/commit_userinfo_icon.png";
    [10] = "dailytask/up_user_icon.png";
}

NewDailyTaskDialogItem.ctor = function(self,data)
    self.m_data = data;
    if not data then return ; end
    self:setSize(NewDailyTaskDialogItem.s_w,NewDailyTaskDialogItem.s_h);
    self.m_bg = new(Image,"drawable/blank.png");
    self.m_bg:setSize(620,100);
    self.m_bg:setAlign(kAlignCenter);
    self:addChild(self.m_bg);

    self.m_bottom_line = new(Image,"common/decoration/line_2.png");
    self.m_bottom_line:setAlign(kAlignBottom);
    self.m_bottom_line:setSize(620,2);
    self:addChild(self.m_bottom_line);

    self.m_icon = new(Image,NewDailyTaskDialogItem.idToIcon[data.id] or "dailytask/daily_sign_icon.png");
    self.m_icon:setAlign(kAlignLeft);
    self.m_icon:setPos(15);
    self.m_bg:addChild(self.m_icon);

    local sx = 42 + self.m_icon:getSize(); 
    local sy = 15;


    self.m_title = new(Text,data.name,nil, nil, nil, nil, 32, 80, 80, 80);
    self.m_progress = new(Text,string.format("(%d/%d)",data.progress or 0,data.num or 0),nil, nil, nil, nil, 32, 80, 80, 80);

    if data.show_progress == 0 then
        self.m_progress:setVisible(false);
    end
    self.m_contentTextTitle = new(Text,"奖励:",nil, nil, nil, nil, 28, 80, 80, 80);
    self.m_contentText = new(Text,data.tip_text,nil, nil, nil, nil, 28, 125, 80, 65);

    self.m_title:setPos(sx,sy);
    
    local ssx = self.m_title:getPos() + self.m_title:getSize();

    self.m_progress:setPos(ssx+5,sy);

    sy = sy + 39;

    self.m_contentTextTitle:setPos(sx,sy);

    sx = sx + self.m_contentTextTitle:getSize();

    self.m_contentText:setPos(sx,sy);

    self.m_btn = new(Button,"common/button/dialog_btn_7_normal.png");
    self.m_text = new(Text,"挑战",nil, nil, nil, nil, 32, 255, 255, 255);
    self.m_text:setAlign(kAlignCenter);
    self.m_btn:addChild(self.m_text);
    
    if data.status == 1 then
        self.m_btn:setFile("common/button/dialog_btn_3_normal.png");
        self.m_text:setText("领取");
    elseif data.status == 2 then
        self.m_btn:setFile("common/button/dialog_btn_9.png");
        self.m_text:setText("已领取");
        self.m_btn:setEnable(false);
    end

    if data.status == 0 and  tonumber(data.jump) == 0 then
        self.m_btn:setFile("common/button/dialog_btn_9.png");
        self.m_text:setText("挑战");
        self.m_btn:setEnable(false);
    end

    self.m_btn:setAlign(kAlignRight);
    self.m_btn:setPos(15);
    self.m_btn:setOnClick(self,self.onBtnClick);
    
    self.m_bg:addChild(self.m_title);
    self.m_bg:addChild(self.m_contentTextTitle);
    self.m_bg:addChild(self.m_contentText);
    self.m_bg:addChild(self.m_btn)
    self.m_bg:addChild(self.m_progress);

end

NewDailyTaskDialogItem.setOnBtnClick = function(self,obj,func)
    self.m_btn_obj = obj;
    self.m_btn_func = func;
end

NewDailyTaskDialogItem.onBtnClick = function(self)
    if self.m_btn_func then
        self.m_btn_func(self.m_btn_obj,self.m_data);
    end
--    if self.m_data.id == 3 or 
    if self.m_data.status == 0 and tonumber(self.m_data.jump)~= 0 then 
        ChessDialogManager.dismissDialog();
        if self.m_data.id == 8 then
            require(MODEL_PATH.."userInfo/userInfoScene");
            UserInfoScene.isShowBangdinDialog = true;
        end
        StateMachine.getInstance():pushState(tonumber(self.m_data.jump),StateMachine.STYPE_CUSTOM_WAIT);
    elseif self.m_data.status == 1 then
        local tips = "领取中...";
        local post_data = {};
        post_data.task_id = self.m_data.id;
        HttpModule.getInstance():execute(HttpModule.s_cmds.GetNewDailyReward,post_data,tips);
    end
end