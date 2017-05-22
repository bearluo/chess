require(VIEW_PATH .. "online_treasure_box")
OnlineTreasureBox = class(Node)

function OnlineTreasureBox:ctor()
    self.mInit = true
    self.mRoot = SceneLoader.load(online_treasure_box)
    local w,h = self.mRoot:getSize()
    local fw,fh = self.mRoot:getFillParent()
    self:setSize(w,h)
    self:setFillParent(fw,fh)
    self:addChild(self.mRoot)
    
	self.m_chest_btn = self.mRoot:getChildByName("chest_btn");   
    self.m_chest_icon = self.m_chest_btn:getChildByName("chest");
    self.m_chest_anim_bg = self.m_chest_btn:getChildByName("chest_anim_bg");
    self.m_chest_btn:setEnable(false);
    self.m_chest_icon:setVisible(false);
    self.m_chest_anim_bg:setVisible(false);
	self.m_chest_btn:setOnClick(self,self.chest_action);    
    self.m_online_time_text_bg = self.m_chest_btn:getChildByName("chest_open_time_bg")
    self.m_online_time_text = self.m_online_time_text_bg:getChildByName("online_time_text");
    OnlineSocketManagerProcesser.getInstance():register(CLIENT_GET_OPENBOX_TIME,self,self.onRecvClientGetOpenboxTime)
end

function OnlineTreasureBox:dtor()
    self.mInit = false
    OnlineSocketManagerProcesser.getInstance():unregister(CLIENT_GET_OPENBOX_TIME,self,self.onRecvClientGetOpenboxTime)
	OnlineConfig.deleteTimer()
    OnlineConfig.deleteOpenBoxTimer()
    self:setUpdateViewFunc()
end

--获取在线宝箱
function OnlineTreasureBox:chest_action()
	if OnlineConfig.isReward then
        self.m_chest_btn:setEnable(false);
        OnlineConfig.deleteOpenBoxTimer();
        self:getOnlineReward(OnlineConfig.getOpenboxid())
	end
end

function OnlineTreasureBox:getOnlineReward(id)
	if id <= 0 then
		local retdata = {};
		retdata.flag =  2;
        self:onGetOpenboxTime(retdata);
        OnlineSocketManager.getHallInstance():sendMsg(CLIENT_GET_OPENBOX_TIME, nil , nil, 1);
		return;
	end
	local post_data = {};
	post_data.id = id;
	HttpModule.getInstance():execute2(HttpModule.s_cmds.getOnlineReward,post_data,tips,function(isSuccess,resultStr)
        if not self.mInit then return end
        self:onHttpGetOnlineRewardCallBack(isSuccess,json.decode_node(resultStr))
    end);    
end


function OnlineTreasureBox:getOpenboxTime(subcmd, changeMoney)
    if subcmd == 1 then
        OnlineSocketManager.getHallInstance():sendMsg(CLIENT_GET_OPENBOX_TIME,changeMoney, subcmd, 2);
    else
        OnlineSocketManager.getHallInstance():sendMsg(CLIENT_GET_OPENBOX_TIME,nil, nil, 1);
    end
end

function OnlineTreasureBox:onRecvClientGetOpenboxTime(packetInfo)

	OnlineConfig.setPlaytime(packetInfo.playtime);
	OnlineConfig.setOpenboxtime(packetInfo.openbox_time);
	OnlineConfig.setOpenboxid(packetInfo.openbox_id);

    self:onGetOpenboxTime();   
    
end



function OnlineTreasureBox:endOpenChest(self)
    self.m_chest_btn:setEnable(false);
    self.m_chest_icon:setVisible(false)
    self.m_chest_anim_bg:setVisible(false);
    self.m_chest_icon:setFile("common/decoration/chest_1.png");
    OnlineConfig.deleteOpenBoxTimer();
    TestAnim.endStarAnim();
end

function OnlineTreasureBox:startOpenChestAnim(rotate_view,star_view,callbackEvent,addMoney)
    local params = {rotate_view,star_view,callbackEvent}
    OnlineConfig.deleteOpenBoxTimer();
    if not rotate_view:checkAddProp(1) then
        rotate_view:removeProp(1);
    end
    rotate_view:addPropRotate(1, kAnimLoop, 3000, -1, 0, 360, kCenterDrawing);
    local data = {
        star_num = 10;
    };
    TestAnim.startStarAnim(star_view,data,callbackEvent,addMoney,rotate_view);
end

--领取宝箱回调
function OnlineTreasureBox:onGetOpenboxTime(data)
    if data and data.flag == 1 then	
        self.m_chest_anim_bg:setVisible(true);
        self.m_chest_icon:setFile("common/decoration/chest_2.png");
        local callbackEvent = {};
        callbackEvent.func = function(self)
            OnlineTreasureBox.endOpenChest(self);
            self:getOpenboxTime(1, data.changeMoney);
            OnlineConfig.startOnlineBoxtimer(self);    
        end
        callbackEvent.obj = self;
        OnlineTreasureBox.startOpenChestAnim(self,self.m_chest_anim_bg,self.m_chest_icon,callbackEvent,data.msg);
        return;
    elseif data and data.flag == 2 then
	    local message = "请稍候重试！"
        ChessToastManager.getInstance():showSingle(message);
	    return;
    elseif data and data.flag == -2 then
        local message = "重复领取，请稍候重试！"
	    ChessToastManager.getInstance():showSingle(message);
        return;
    end

    OnlineConfig.startOnlineBoxtimer(self);    
end


function OnlineTreasureBox:onHttpGetOnlineRewardCallBack(flag, message)
    Log.i("OnlineRoomController.onHttpGetOnlineRewardCallBack");
    if not flag or not message:get_value() then
        return
    end
	local data = message.data;

	if not data then
		return;
	end
	
	local retdata = {};
	retdata.flag =  tonumber(data.flag:get_value()); --:领取状态（-1在玩时间校验失败，0领奖失败，1成功，-2重复领取）

	retdata.msg =  data.msg:get_value() or "";
    if retdata.msg ~= "" then
        ChessToastManager.getInstance():showSingle(retdata.msg)
    end

	retdata.playtime =  tonumber(data.playtime:get_value());
	retdata.openbox_id =  tonumber(data.openbox_id:get_value());
	retdata.openbox_time =  tonumber(data.openbox_time:get_value());

	local money = tonumber(data.reward.money:get_value());
	local soul = tonumber(data.reward.soul:get_value());

	UserInfo.getInstance():setSoulCount(soul);
    local oldMoney = UserInfo.getInstance():getMoney();
    retdata.changeMoney = 0;
    if money then
        retdata.changeMoney = money - oldMoney;
    end
	UserInfo.getInstance():setMoney(money);

	OnlineConfig.setPlaytime(retdata.playtime);
	OnlineConfig.setOpenboxtime(retdata.openbox_time);
	OnlineConfig.setOpenboxid(retdata.openbox_id);
    self:onGetOpenboxTime(retdata)
    self:updateView()
end

function OnlineTreasureBox:updateView()
    if type(self.mUpdateViewFuncFunc) then
        self.mUpdateViewFuncFunc(self.mUpdateViewFuncObj)
    end
end

function OnlineTreasureBox:setUpdateViewFunc(obj,func)
    self.mUpdateViewFuncObj = obj
    self.mUpdateViewFuncFunc = func
end