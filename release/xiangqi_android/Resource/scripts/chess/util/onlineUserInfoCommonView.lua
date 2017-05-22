--region onlineUserInfoCommonView.lua
--Date 2017.01.18
--联网用户信息view
--endregion

OnlineUserInfoCommonView = class(Node)

OnlineUserInfoCommonView.ONLINE_UP = 1
OnlineUserInfoCommonView.ONLINE_DOWN = 2
OnlineUserInfoCommonView.WATCH_LEFT = 3
OnlineUserInfoCommonView.WATCH_RIGHT = 4

function OnlineUserInfoCommonView.ctor(self,roomType)
    
    self.time_frame_bg = new(Image,"common/background/info_bg_8.png",nil,nil,30,30,0,0)
    self.time_frame_bg:setSize(570,49)
    self.time_frame_bg:setAlign(kAlignTop)
    self.time_frame_bg:setPos(0,82)
    self:addChild(self.time_frame_bg)

    self.timeout1_name = new(Text,"局时:",nil,nil,nil,nil,28,220,130,55)
    self.timeout1_name:setAlign(kAlignLeft)
    self.timeout1_name:setPos(48,0)
    self.time_frame_bg:addChild(self.timeout1_name)

    self.timeout2_name = new(Text,"读秒:",nil,nil,nil,nil,28,50,190,85)
    self.timeout2_name:setAlign(kAlignLeft)
    self.timeout2_name:setPos(369,0)
    self.time_frame_bg:addChild(self.timeout2_name)

    self.timeout1_text = new(Text,"00:00",nil,nil,nil,nil,28,220,130,55)
    self.timeout1_text:setAlign(kAlignLeft)
    self.timeout1_text:setPos(119,0)
    self.time_frame_bg:addChild(self.timeout1_text)

    self.timeout2_text = new(Text,"00:00",nil,nil,nil,nil,28,50,190,85)
    self.timeout2_text:setAlign(kAlignLeft)
    self.timeout2_text:setPos(440,0)
    self.time_frame_bg:addChild(self.timeout2_text)

    self.watch_user_bg = new(Image,"common/background/info_bg_9.png")
    self.watch_user_bg:setSize(225,74)
    self.watch_user_bg:setAlign(kAlignTopLeft)
    self.watch_user_bg:setPos(55,0)
    self.watch_user_bg:setVisible(false)
    self:addChild(self.watch_user_bg)

    self.watch_user_flag = new(Image,"common/icon/black_king.png")
    self.watch_user_flag:setSize(65,65)
    self.watch_user_flag:setAlign(kAlignTop)
    self.watch_user_flag:setPos(-58,4)
    self.watch_user_flag:setVisible(false)
    self:addChild(self.watch_user_flag)

    self.vip_logo = new(Image,"vip/vip_logo.png")
    self.vip_logo:setSize(46,38)
    self.vip_logo:setAlign(kAlignTopLeft)
    self.vip_logo:setPos(205,35)
    self.vip_logo:setVisible(false)
    self:addChild(self.vip_logo)

    self.user_name = new(Text,"博雅象棋",nil,nil,kAlignCenter,nil,32,245,235,210)
    self.user_name:setAlign(kAlignTop)
    self.user_name:setPos(0,16)
    self:addChild(self.user_name)

--    self.watch_user_name = new(Text,"博雅象棋",0,0,kAlignLeft,nil,24,245,235,210)
--    self.watch_user_name:setAlign(kAlignTopLeft)
--    self.watch_user_name:setPos(145,5)
--    self:addChild(self.watch_user_name)

    self.user_icon_bg = new(Image,"online/room/head_bg.png")
    self.user_icon_bg:setSize(92,92)
    self.user_icon_bg:setAlign(kAlignTop)
    self.user_icon_bg:setPos(0,58)
    self:addChild(self.user_icon_bg)

    self.turn1 = new(Image,"online/room/progress_bg.png")
    self.turn1:setSize(100,100)
    self.turn1:setAlign(kAlignCenter)
    self.user_icon_bg:addChild(self.turn1)

    self.turn = new (Node);
    self.turn:setSize(100,100);
    self.turn:setAlign(kAlignCenter);
    self.turn:setLevel(7);
    self.turn:setName("imgNode");
    self.turnTexture = new(Image,"online/room/progress.png")
    self.turnTexture:setSize(110,110)
    self.turnTexture:setAlign(kAlignCenter)
    self.turnTexture:setLevel(9);
    self.turnTexture:setName("progress");
    self.turnTexture:setVisible(false);
    self.turn:addChild( self.turnTexture);
    self.turnTexture1 = new(Image,"online/room/progress1.png")
    self.turnTexture1:setSize(110,110)
    self.turnTexture1:setAlign(kAlignCenter)
    self.turnTexture1:setLevel(8);
    self.turnTexture1:setName("progress1");
    self.turnTexture1:setVisible(false);
    self.turn:addChild( self.turnTexture1);
    self.turnTexture2 = new(Image,"online/room/progress2.png")
    self.turnTexture2:setSize(110,110)
    self.turnTexture2:setAlign(kAlignCenter)
    self.turnTexture2:setLevel(7);
    self.turnTexture2:setName("progress2");
    self.turnTexture2:setVisible(false);
    self.turn:addChild( self.turnTexture2);
    self.turnTexturePoint = new(Image,"online/room/progresspoint.png")
    self.turnTexturePoint:setSize(25,25)
    self.turnTexturePoint:setAlign(kAlignCenter)
    self.turnTexturePoint:setLevel(9);
    self.turnTexturePoint:setName("progresspoint");
    self.turnTexturePoint:setVisible(false);
    self.turn:addChild( self.turnTexturePoint);
    self.user_icon_bg:addChild(self.turn)

    self.user_icon_frame_mask = new(Image,"online/room/head_mask.png")
    self.user_icon_frame_mask:setSize(86,86)
    self.user_icon_frame_mask:setAlign(kAlignCenter)
    self.user_icon_bg:addChild(self.user_icon_frame_mask) 

    self.user_icon = new(Mask,"online/room/head_mask.png","online/room/head_mask.png");
    self.user_icon:setSize(self.user_icon_frame_mask:getSize());
    self.user_icon:setAlign(kAlignCenter)
    self.user_icon_frame_mask:addChild(self.user_icon);
    self.user_icon:setEventTouch(self,self.showUserInfo);

    self.vip_frame = new(Image,"vip/vip_110.png")
    self.vip_frame:setSize(110,110)
    self.vip_frame:setAlign(kAlignCenter)
    self.vip_frame:setVisible(false)
    self.user_icon_bg:addChild(self.vip_frame)

    self.user_level_icon = new(Image,"common/icon/level_1.png")
    self.user_level_icon:setSize(52,26)
    self.user_level_icon:setAlign(kAlignBottom)
    self.user_level_icon:setPos(0,-13)
    self.user_icon_bg:addChild(self.user_level_icon)

    self.user_disconnect = new(Image,"common/decoration/disconnect.png")
    self.user_disconnect:setSize(110,110)
    self.user_disconnect:setAlign(kAlignCenter)
    self.user_disconnect:setVisible(false)
    self.user_icon_bg:addChild(self.user_disconnect)

    self.user_flag2 = new(Image,"common/icon/black_flag.png")
    self.user_flag2:setSize(58,24)
    self.user_flag2:setAlign(kAlignBottom)
    self.user_flag2:setPos(0,-10)
    self.user_flag2:setVisible(false)
    self.user_icon_bg:addChild(self.user_flag2)

    self.breath1 = new(Image,"online/room/red_light_1.png")
    self.breath1:setSize(88,88)
    self.breath1:setAlign(kAlignCenter)
    self.breath1:setVisible(false)
    self.user_icon_frame_mask:addChild(self.breath1)

    self.breath2 = new(Image,"online/room/red_light_2.png")
    self.breath2:setSize(88,88)
    self.breath2:setAlign(kAlignCenter)
    self.breath2:setVisible(false)
    self.user_icon_frame_mask:addChild(self.breath2)

    self.anim_view = new(Node)
    self.anim_view:setSize(90,90)
    self.anim_view:setAlign(kAlignCenter)
    self.user_icon_bg:addChild(self.anim_view)

    self.money_btn = new(Button,"online/room/money_bg.png")
    self.money_btn:setVisible(false)
    self.money_btn:setAlign(kAlignBottom)
    self.money_btn:setSize(202,44)
    self.money_btn:setPos(0,-52)
    self.money_btn:setOnClick(self,function()
        local addmoney = 0
        local config = RoomProxy.getInstance():getCurRoomConfig()
        if type(config) == "table" and tonumber(config.minmoney) then
            addmoney = tonumber(config.minmoney) 
        end
        local money = UserInfo.getInstance():getMoney()
        addmoney = addmoney -  money
        local goods = MallData.getInstance():getGoodsByMoreMoney(addmoney)
        if not goods then return end
        if next(goods) == nil then return end
        local payData = {}
        payData = ToolKit.getBuyCoinsPhpConfig()
        OnlineRoomSceneNew.m_PayInterface = PayUtil.getPayInstance(PayUtil.s_defaultType);
	    goods.position = MALL_COINS_GOODS;
	    OnlineRoomSceneNew.m_pay_dialog = OnlineRoomSceneNew.m_PayInterface:buy(goods,payData);
    end);
    self:addChild(self.money_btn)

    self.money_text = new(Text,"金币:0",nil,nil,kAlignLeft,nil,24,230,200,125)
    self.money_text:setAlign(kAlignLeft)
    self.money_text:setPos(17,0)
    self.money_btn:addChild(self.money_text)

    self.money_add_icon = new(Image,"online/room/money_icon.png")
    self.money_add_icon:setAlign(kAlignRight)
    self.money_btn:addChild(self.money_add_icon)

    self.m_net_state_view_bg = new(Image,"drawable/net_sinal_state_level1.png")
    self.m_net_state_view_bg:setAlign(kAlignBottomLeft)
    self.m_net_state_view_bg:setPos(349,30)
    self:addChild(self.m_net_state_view_bg)

    self:setSize(613,168)
    self:setPos(0,24)
    self:setAlign(kAlignTop)
    self:setLevel(2)
    self:createView(roomType)
end

function OnlineUserInfoCommonView.dtor(self)
    HeadSmogAnim.deleteAll();
end

function OnlineUserInfoCommonView.createView(self,roomType)
    self.viewType = roomType 
    if not self.viewType then 
        self.viewType = OnlineUserInfoCommonView.ONLINE_UP
    end
    self:switchView(self.viewType)
end

function OnlineUserInfoCommonView.initWatchView(self,roomType)
    self.viewType = roomType or OnlineUserInfoCommonView.WATCH_LEFT
    self:checkWatchName()
    self:initWatchFlag()
    self:switchView(self.viewType)
end

function OnlineUserInfoCommonView.switchView(self,roomType,ret)
    if not roomType then return end
    self.viewType = roomType
    self:switchWatchFlag()
    if self.viewType == OnlineUserInfoCommonView.ONLINE_UP then
        self.time_frame_bg:setPos(0,82)
        self.time_frame_bg:setVisible(true)
        self.watch_user_bg:setVisible(false)
        self.watch_user_flag:setVisible(false)
        self.breath1:setVisible(false)
        self.breath2:setVisible(false)
        self.user_flag2:setVisible(false)
        self.user_name:setVisible(true)
        self.money_btn:setVisible(false)
        self.m_net_state_view_bg:setVisible(false)
        if self.watch_user_name then
            self.watch_user_name:setVisible(false)
        end
        self.user_name:setAlign(kAlignTop)
        self.user_name:setPos(0,16)
        self.user_icon_bg:setAlign(kAlignTop)
        self.user_icon_bg:setPos(0,58)
        self.user_icon_bg:setSize(92,92)
        self.user_level_icon:setPos(0,-13)
        self.turn1:setSize(100,100)
        self:setTurnSize(110);
--        self.turn:setSize(100,100)
        self.breath1:setSize(88,88)
        self.breath2:setSize(88,88)
        self:setPos(0,24)
        self:setAlign(kAlignTop)

    elseif self.viewType == OnlineUserInfoCommonView.ONLINE_DOWN then
        self.time_frame_bg:setPos(0,55)
        self.time_frame_bg:setVisible(true)
        self.watch_user_bg:setVisible(false)
        self.watch_user_flag:setVisible(false)
        self.breath1:setVisible(false)
        self.breath2:setVisible(false)
        self.user_flag2:setVisible(false)
        self.user_name:setVisible(true)
        self.money_btn:setVisible(true)
        self.m_net_state_view_bg:setVisible(true)
        if self.watch_user_name then
            self.watch_user_name:setVisible(false)
        end
        self.user_name:setAlign(kAlignBottom)
        self.user_name:setPos(0,-10)
        self.user_icon_bg:setAlign(kAlignTop)
        self.user_icon_bg:setPos(0,36)
        self.user_icon_bg:setSize(92,92)
        self.user_level_icon:setPos(0,-13)
        self.turn1:setSize(100,100)
        self:setTurnSize(110);
--        self.turn:setSize(100,100)
        self.breath1:setSize(88,88)
        self.breath2:setSize(88,88)
        self:setPos(0,90)
        self:setAlign(kAlignBottom)

    elseif self.viewType == OnlineUserInfoCommonView.WATCH_LEFT then
        self:checkWatchName(ret)
        self.time_frame_bg:setVisible(false)
        self.user_name:setVisible(false)
        self.watch_user_bg:setVisible(true)
        self.watch_user_bg:setAlign(kAlignTopLeft)
        self.watch_user_bg:setPos(55,0);
        self.breath1:setVisible(false)
        self.breath2:setVisible(false)
        self.watch_user_name:setVisible(true)
        self.money_btn:setVisible(false)
        self.m_net_state_view_bg:setVisible(false)
        self.user_icon_bg:setAlign(kAlignTopLeft)
        self.user_icon_bg:setPos(60,0)
        self.user_icon_bg:setSize(74,74)
        self.user_level_icon:setPos(0,-13)
        self:setTurnSize(100);
--        self.turn:setSize(90,90)
        self.turn1:setSize(90,90)
        self.vip_logo:setAlign(kAlignTopLeft);
        self.vip_logo:setPos(205,35);
        self.breath1:setSize(74,74)
        self.breath2:setSize(74,74)
        self.user_icon:setSize(74,74)
        self.user_icon_frame_mask:setSize(74,74)
        self:setPos(-40,24)
        self:setAlign(kAlignTop)
    elseif self.viewType == OnlineUserInfoCommonView.WATCH_RIGHT then
        self:checkWatchName(ret)
        self.time_frame_bg:setVisible(false)
        self.user_name:setVisible(false)
        self.watch_user_bg:setVisible(true)
        self.watch_user_bg:setAlign(kAlignTopRight)
        self.watch_user_bg:setPos(55,0);
        self.breath1:setVisible(false)
        self.breath2:setVisible(false)
        self.watch_user_name:setVisible(true)
        self.money_btn:setVisible(false)
        self.m_net_state_view_bg:setVisible(false)
        self.user_icon_bg:setAlign(kAlignTopRight)
        self.user_icon_bg:setPos(60,0);
        self.user_icon_bg:setSize(74,74);
        self.user_level_icon:setPos(0,-13)
        self:setTurnSize(100);
--        self.turn:setSize(90,90)
        self.turn1:setSize(90,90)
        self.vip_logo:setAlign(kAlignTopRight);
        self.vip_logo:setPos(195,35);
        self.breath1:setSize(74,74)
        self.breath2:setSize(74,74)
        self.user_icon:setSize(74,74)
        self.user_icon_frame_mask:setSize(74,74)
        self:setPos(0,24)
        self:setAlign(kAlignTop)
    end
end

function OnlineUserInfoCommonView.checkWatchName(self,ret)
    if self.watch_user_name and not ret then return end
    delete(self.watch_user_name)
    local textAlgin = (self.viewType == OnlineUserInfoCommonView.WATCH_LEFT and kAlignLeft) or kAlignRight
    local viewAlgin = (self.viewType == OnlineUserInfoCommonView.WATCH_LEFT and kAlignTopLeft) or kAlignTopRight
    local name = "博雅象棋"
    if self.userData then
        name = self.userData:getName() or "博雅象棋"
    end
    self.watch_user_name = new(Text,name,0,0,textAlgin,nil,24,245,235,210)
    self.watch_user_name:setAlign(viewAlgin)
    self.watch_user_name:setPos(145,5)
    self:addChild(self.watch_user_name)
end

function OnlineUserInfoCommonView.initWatchFlag(self)
    if self.viewType == OnlineUserInfoCommonView.WATCH_LEFT then
        self.watch_user_flag:setFile("common/icon/black_king.png")
        self.watch_user_flag:setPos(-58,4)
        self.watch_user_flag:setVisible(true)
        self.user_flag2:setFile("common/icon/black_flag.png")
        self.user_flag2:setPos(75,5)
        self.user_flag2:setVisible(true)
    elseif self.viewType == OnlineUserInfoCommonView.WATCH_RIGHT then
        self.watch_user_flag:setFile("common/icon/red_king.png")
        self.watch_user_flag:setPos(58,4)
        self.watch_user_flag:setVisible(true)
        self.user_flag2:setFile("common/icon/red_flag.png")
        self.user_flag2:setPos(-75,5)
        self.user_flag2:setVisible(true)
    end
end

function OnlineUserInfoCommonView.switchWatchFlag(self)
    if self.viewType == OnlineUserInfoCommonView.WATCH_LEFT then
        self.watch_user_flag:setPos(-58,4)
        self.watch_user_flag:setVisible(true)
        self.user_flag2:setPos(75,5)
        self.user_flag2:setVisible(true)
    elseif self.viewType == OnlineUserInfoCommonView.WATCH_RIGHT then
        self.watch_user_flag:setPos(58,4)
        self.watch_user_flag:setVisible(true)
        self.user_flag2:setPos(-75,5)
        self.user_flag2:setVisible(true)
    end
end

function OnlineUserInfoCommonView.updateViewData(self,user)
    if not user then return end
    self.userData = user

    if self.watch_user_name then
        self.watch_user_name:setText(self.userData:getName());
    end
    self.user_name:setText(self.userData:getName());
    self.user_level_icon:setFile(string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevelByScore(self.userData:getScore())));
    self.user_icon:setFile(UserInfo.DEFAULT_ICON[1]);
    local iconType = tonumber(self.userData:getIconType()); 
    if iconType and iconType > 0 then
        self.user_icon:setFile(UserInfo.DEFAULT_ICON[iconType] or UserInfo.DEFAULT_ICON[1]);
    else
        if iconType == -1 then
            self.user_icon:setUrlImage(self.userData:getIcon(),UserInfo.DEFAULT_ICON[1]);
        end
    end

    self:playUserInAnim()

end

function OnlineUserInfoCommonView.updateVipData(self)
    if not self.userData then return end
    local nx,nt = self.user_name:getPos();
    local nw,nh = self.user_name:getSize();
    local vw,vh = self.vip_logo:getSize();
--    local text = new(Text,self.user_name:getText(),nil,nil,nil,nil,32);
--    local nw,nh = text:getSize();
    if self.userData and self.userData.m_is_vip and self.userData.m_is_vip == 1 then
        if not OnlineRoomSceneNew.IS_NEW then
            self.vip_logo:setPos(nx - nw/2 - vw/2 - 3);
        end;
        self.vip_frame:setVisible(true);
        self.vip_logo:setVisible(true)
    elseif self.userData and self.userData.m_vip and self.userData.m_vip == 1 then
        if not OnlineRoomSceneNew.IS_NEW then
            self.vip_logo:setPos(nx - nw/2 - vw/2 - 3);
        end;
        self.vip_frame:setVisible(true);
        self.vip_logo:setVisible(true);
    else
        self.vip_frame:setVisible(false);
        self.vip_logo:setVisible(false);
    end
end


function OnlineUserInfoCommonView.updataTimeOut(self,user)
    if not user then return end
    self.userData = user
	self.timeout1_text:setText(self.userData:getTimeout1());
	self.timeout2_text:setText(self.userData:getTimeout2());
end

function OnlineUserInfoCommonView.updataTimeOutStr(self,str1,str2)
	self.timeout1_text:setText(str1);
	self.timeout2_text:setText(str2);
end

function OnlineUserInfoCommonView:setTimeout2Name(str)
    self.timeout2_name:setText(str)
end

function OnlineUserInfoCommonView.getAnimView(self)
    return self.turn,self.breath1,self.breath2,self.anim_view
end

function OnlineUserInfoCommonView.setIconTouch(self,obj,func)
    self.obj = obj
    self.func = func
end

function OnlineUserInfoCommonView.showUserInfo(self,finger_action, x, y)
    if self.obj and self.func then
        if type(self.func) == "function" then
           self.func(self.obj,finger_action, x, y) 
        end
    end
end

function OnlineUserInfoCommonView.resetIconView(self)
    self.user_icon:setFile(User.MAN_ICON);
	HeadSmogAnim.play(self.user_icon);
	self.user_icon:setVisible(false);
    self.vip_frame:setVisible(false);
    self.vip_logo:setVisible(false);
    self.user_disconnect:setVisible(false);
    self.user_name:setText("");
end

function OnlineUserInfoCommonView.playUserInAnim(self)
    self.user_icon:setVisible(true);
    HeadSmogAnim.play(self.user_icon);
end

function OnlineUserInfoCommonView.updataMoneyData(self,money)
    local str = money or 0 
    str = "金币:" .. money
    self.money_text:setText(str)
end

function OnlineUserInfoCommonView.showNetSinalIcon(self,level)
    local sinal_icon_arr = {"drawable/net_sinal_state_level0.png","drawable/net_sinal_state_level1.png","drawable/net_sinal_state_level2.png","drawable/net_sinal_state_level3.png","drawable/net_sinal_state_level4.png","drawable/net_sinal_state_level_none.png"};
	self.m_net_state_view_bg:setFile(sinal_icon_arr[level])
end

function OnlineUserInfoCommonView.setTurnSize(self,size)
    self.turn:setSize(size,size);
    self.turnTexture:setSize(size,size);
    self.turnTexture1:setSize(size,size);
    self.turnTexture2:setSize(size,size);
end 