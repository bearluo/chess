require(VIEW_PATH .. "friend_choice_dialog_view");
require(BASE_PATH.."chessDialogScene")
require("uiex/urlImage");
FriendChoiceDialog = class(ChessDialogScene,false);

FriendChoiceDialog.MODE_SURE = 1;
FriendChoiceDialog.MODE_AGREE = 2;
FriendChoiceDialog.MODE_OK = 3;
FriendChoiceDialog.MODE_OTHER = 4;

FriendChoiceDialog.ctor = function(self)
    super(self,friend_choice_dialog_view);
	self.m_root_view = self.m_root;
    
    self.mBg = self.m_root_view:getChildByName("chioce_dialog_bg")
    self.mRoomInfoView = self.mBg:getChildByName("room_info_view")
    self.mRoomInfoView:setVisible(false)
	self.m_cancle_btn = self.m_root_view:getChildByName("chioce_dialog_bg"):getChildByName("chioce_cancel_btn");
	self.m_sure_btn = self.m_root_view:getChildByName("chioce_dialog_bg"):getChildByName("chioce_sure_btn");
    self.m_single_btn = self.m_root_view:getChildByName("chioce_dialog_bg"):getChildByName("chioce_single_btn");
	self.m_sure_texture = self.m_sure_btn:getChildByName("chioce_sure_text");
	self.m_cancel_texture = self.m_cancle_btn:getChildByName("chioce_cancel_text");

	self.m_levelIcon = self.m_root_view:getChildByName("chioce_dialog_bg"):getChildByName("head_view"):getChildByName("level");
    self.m_headImage_mask = self.m_root_view:getChildByName("chioce_dialog_bg"):getChildByName("head_view"):getChildByName("head_image");
    self.m_headImage = new(Mask,"common/background/head_mask_bg_86.png","common/background/head_mask_bg_86.png");
    self.m_headImage_mask:addChild(self.m_headImage);
    self.m_textView = self.m_root_view:getChildByName("chioce_dialog_bg"):getChildByName("text_view");
    
	self:setEventTouch(self,self.onTouch);

	self.m_cancle_btn:setOnClick(self,self.cancel);
	self.m_sure_btn:setOnClick(self,self.sure);
    self.m_single_btn:setOnClick(self,self.sure);

    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)
end

FriendChoiceDialog.dtor = function(self)
    if self.timeOutAnim then
        delete(self.timeOutAnim);
        self.timeOutAnim = nil;
    end
    delete(self.m_root_view);
	self.m_root_view = nil;
    self.mDialogAnim.stopAnim()
end

FriendChoiceDialog.isShowing = function(self)
	return self:getVisible();
end

FriendChoiceDialog.onTouch = function(self)
	print_string("FriendChoiceDialog.onTouch");
end

FriendChoiceDialog.show = function(self)
	print_string("FriendChoiceDialog.show ... ");
    self:setVisible(true);
    self.super.show(self,self.mDialogAnim.showAnim);
	kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
end

FriendChoiceDialog.cancel = function(self)
	print_string("FriendChoiceDialog.cancel ");
	self:dismiss();
	if self.m_negObj and self.m_negFunc then
		self.m_negFunc(self.m_negObj);
	end
end

FriendChoiceDialog.sure = function(self)
	print_string("FriendChoiceDialog.sure ");

	self:dismiss();
	if self.m_posObj and self.m_posFunc then
		self.m_posFunc(self.m_posObj);
	end
end


FriendChoiceDialog.setMessage = function(self,message)
 	self.m_message:setText(message);
end

FriendChoiceDialog.setMode = function(self,modeType,userData,packageInfo)
    local richText = nil;
    if not userData or not userData.mnick then
        userData = {};
        userData.mnick = "博雅象棋";
        userData.iconType = 1;
    end
    self.m_userData = userData;

    packageInfo = packageInfo or {} -- 防止为空

    local time_out = packageInfo.time_out
    local gameTime = packageInfo.gameTime
    local stepTime = packageInfo.stepTime
    local secondTime = packageInfo.secondTime

    if time_out then
        if (time_out == 0 or time_out < 0 )then
            time_out = 30;
        end
    else
        time_out = 30;
    end

    self.mBg:setSize(nil,329)
    local richW,richH = self.m_textView:getSize()
    RoomProxy.getInstance():setFriendsAutoSure(false)

    if modeType == 1 then
        self.m_time_out = time_out;
        delete(self.timeOutAnim);
        self.timeOutAnim = new(AnimInt,kAnimRepeat,0,1,1000,-1);
        self.timeOutAnim:setEvent(self,self.onAnimTime);
        self.m_single_btn:setVisible(false);
        self.m_sure_btn:setVisible(true);
        self.m_cancle_btn:setVisible(true);
	    self.m_sure_texture:setText("接受");
	    self.m_cancel_texture:setText("拒绝("..self.m_time_out.."s)");
        richText = new(RichText,"#c50BE82"..userData.mnick.."#n向你发起对战邀请，是否接受?",richW,richH,kAlignTopLeft,nil,32,80,80,80,true);
        self:initRoomInfo(gameTime,stepTime,secondTime)

    elseif modeType == 2 then
        self.m_single_btn:setVisible(false);
        self.m_sure_btn:setVisible(true);
        self.m_cancle_btn:setVisible(true);
	    self.m_sure_texture:setText("追踪旁观");
	    self.m_cancel_texture:setText("取消挑战");
        richText = new(RichText,"对方正在游戏中，是否追踪旁观?",richW,richH,kAlignTopLeft,nil,32,80,80,80,true);
    elseif modeType == 3 then
        self.m_single_btn:setVisible(false);
        self.m_sure_btn:setVisible(true);
        self.m_cancle_btn:setVisible(true);
	    self.m_sure_texture:setText("立即开始");
	    self.m_cancel_texture:setText("稍后");
        richText = new(RichText,"是否立即开始和#c50BE82"..userData.mnick.."#n的棋局对战?",richW,richH,kAlignTopLeft,nil,32,80,80,80,true);
    elseif modeType == 4 then
        self.m_single_btn:setVisible(true);
        self.m_sure_btn:setVisible(false);
        self.m_cancle_btn:setVisible(false);
        richText = new(RichText,"发起挑战失败，对方已下线！",richW,richH,kAlignTopLeft,nil,32,80,80,80,true);
    elseif modeType == 5 then
        self.m_time_out = time_out;
        delete(self.timeOutAnim);
        self.timeOutAnim = new(AnimInt,kAnimRepeat,0,1,1000,-1);
        self.timeOutAnim:setEvent(self,self.onAnimTime);
        self.m_single_btn:setVisible(false);
        self.m_sure_btn:setVisible(true);
        self.m_cancle_btn:setVisible(true);
	    self.m_sure_texture:setText("接受");
	    self.m_cancel_texture:setText("拒绝("..self.m_time_out.."s)");
        richText = new(RichText,"#c50BE82"..userData.mnick.."#n向你发起对战邀请，是否接受?",richW,richH,kAlignTopLeft,nil,32,80,80,80,true);
        self:initCustomRoomInfo(gameTime,stepTime,secondTime)
    else
        self.m_single_btn:setVisible(true);
        self.m_sure_btn:setVisible(false);
        self.m_cancle_btn:setVisible(false);
        self.m_sure_texture:setText("确定");
	    self.m_cancel_texture:setText("取消");
        richText = new(RichText,"对不起，游戏开了点小差!",richW,richH,kAlignTopLeft,nil,32,80,80,80,true);       
    end
    richText:setAlign(kAlignCenter);
    self.m_textView:removeAllChildren();
    self.m_textView:addChild(richText);
    self.m_levelIcon:setFile(string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevelByScore(userData.score)));

    if userData then
        if userData.iconType >= 0 then
            self.m_headImage:setFile(UserInfo.DEFAULT_ICON[userData.iconType] or UserInfo.DEFAULT_ICON[1]);
        elseif userData.iconType < 0 then
            self.m_headImage:setUrlImage(userData.icon_url,UserInfo.DEFAULT_ICON[1])
    --        UserInfo.getCacheImageManager(userData.icon_url,userData.mid);
        end;
    else
        self.m_headImage:setFile(UserInfo.DEFAULT_ICON[1]);
    end
end

function FriendChoiceDialog:initRoomInfo(gameTime,stepTime,secondTime)
    if not gameTime or gameTime == -1 then
        return 
    end
    local roomConfig = RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_FRIEND_ROOM) or {}

    self.mRoomInfoView:setVisible(true)
    self.mBg:setSize(nil,479)

    local baseChip = roomConfig.money or 0
    local rent = roomConfig.rent or 0
    gameTime = tonumber(gameTime) or 0
    stepTime = tonumber(stepTime) or 0
    secondTime = tonumber(secondTime) or 0

    self.mRoomInfoView:getChildByName("basechip_view"):getChildByName("context_view"):setText(baseChip .. "金币")
    self.mRoomInfoView:getChildByName("game_time_view"):getChildByName("context_view"):setText(self:checkTime(gameTime))
    self.mRoomInfoView:getChildByName("step_time_view"):getChildByName("context_view"):setText(self:checkTime(stepTime))
    self.mRoomInfoView:getChildByName("second_time_view"):getChildByName("context_view"):setText(self:checkTime(secondTime,"不读秒"))
    self.mRoomInfoView:getChildByName("rent_txt"):setText("台费" .. rent .. "金币")
    
    RoomProxy.getInstance():setFriendsAutoSure(true)

end

function FriendChoiceDialog:initCustomRoomInfo(gameTime,stepTime,secondTime)
    if not gameTime or gameTime == -1 then
        return 
    end
    local roomConfig = RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_PRIVATE_ROOM) or {}

    self.mRoomInfoView:setVisible(true)
    self.mBg:setSize(nil,479)

    local baseChip = roomConfig.money or 0
    local rent = roomConfig.rent or 0
    gameTime = tonumber(gameTime) or 0
    stepTime = tonumber(stepTime) or 0
    secondTime = tonumber(secondTime) or 0

    self.mRoomInfoView:getChildByName("basechip_view"):getChildByName("context_view"):setText(baseChip .. "金币")
    self.mRoomInfoView:getChildByName("game_time_view"):getChildByName("context_view"):setText(self:checkTime(gameTime))
    self.mRoomInfoView:getChildByName("step_time_view"):getChildByName("context_view"):setText(self:checkTime(stepTime))
    self.mRoomInfoView:getChildByName("second_time_view"):getChildByName("context_view"):setText(self:checkTime(secondTime,"不读秒"))
    self.mRoomInfoView:getChildByName("rent_txt"):setText("台费" .. rent .. "金币")
    
    RoomProxy.getInstance():setFriendsAutoSure(true)

end

FriendChoiceDialog.checkTime = function(self,time,text0)
    if time and time < 60 and time > 0 then
        return time .. "秒";
    elseif time and time >= 60 then
        return time/60 .. "分"
    elseif time and time <= 0 then
        return text0 or "不限时"
    end
end


FriendChoiceDialog.onAnimTime = function(self)
    if self.m_time_out and self.m_time_out > 0 then
        self.m_time_out = self.m_time_out -1;
        self.m_cancel_texture:setText("拒绝("..self.m_time_out.."s)");
    else
        if self.timeOutAnim then
            delete(self.timeOutAnim);
            self.timeOutAnim = nil;
            self:dismiss();
--            self:cancel();
        end
    end
end

FriendChoiceDialog.setPositiveListener = function(self,obj,func)
	self.m_posObj = obj;
	self.m_posFunc = func;
end


FriendChoiceDialog.setNegativeListener = function(self,obj,func)
	self.m_negObj = obj;
	self.m_negFunc = func;
end


FriendChoiceDialog.dismiss = function(self)
    if self.timeOutAnim then
        delete(self.timeOutAnim);
        self.timeOutAnim = nil;
    end
--	self:setVisible(false);
    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
end

FriendChoiceDialog.update = function(self,info)
    Log.i("FriendChoiceDialog.update");
    if self.m_headImage then
        Log.i("FriendChoiceDialog.update info.what is " .. (info.what or "null"));
        Log.i("FriendChoiceDialog.update info.ImageName is " .. (info.ImageName  or "null"));
        Log.i("FriendChoiceDialog.update self.m_userData is " .. (self.m_userData.mid  or "null"));
        if self.m_userData and info and tonumber(info.what) == self.m_userData.mid then
            Log.i("FriendChoiceDialog.update success");
            self.m_headImage:setFile(info.ImageName);
        end
    end
end