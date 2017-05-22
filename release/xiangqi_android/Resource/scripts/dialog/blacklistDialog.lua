
require(VIEW_PATH .. "blacklist_dialog_view");
require(BASE_PATH.."chessDialogScene")

BlacklistDialog = class(ChessDialogScene,false)

function BlacklistDialog:ctor()
    super(self,blacklist_dialog_view)

    self.mBg = self.m_root:getChildByName("bg")
    self.mHelpView = self.mBg:getChildByName("help_view")
    self.mHelpView:setVisible(false)
    self.mHelpBtn = self.mBg:getChildByName("help_btn")
    self.mHelpBtn:setOnClick(self,function()
        self.mHelpView:setVisible(not self.mHelpView:getVisible())
    end)
    self.mBlacklistView = self.mBg:getChildByName("blacklistView")
    self.mEmptyView = self.mBg:getChildByName("empty_view")
    self.mEmptyView:setVisible(false)

    self.mBg:setEventTouch(self,function()end)
    self:setShieldClick(self,self.dismiss)
    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)
end

function BlacklistDialog:dtor()
    self.mDialogAnim.stopAnim()
    delete(BlacklistDialog.m_up_user_info_dialog)
end

function BlacklistDialog:show()
    self:resetBlacklistView()
    self.super.show(self,self.mDialogAnim.showAnim)
    FriendsData.getInstance():sendGetBlacklistCmd()
	EventDispatcher.getInstance():register(Event.Call,self,self.onNativeCallDone);
    self.mHelpView:setVisible(false)
end

function BlacklistDialog:dismiss()
    self.super.dismiss(self,self.mDialogAnim.dismissAnim)
	EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeCallDone);
end

BlacklistDialog.onNativeCallDone = function(self ,param , ...)
    if not self.s_nativeEventFuncMap then
        self.s_nativeEventFuncMap = {
            [kFriend_BlacklistUpdate] = self.resetBlacklistView;
        }
    end
	if self.s_nativeEventFuncMap[param] then
		self.s_nativeEventFuncMap[param](self,...);
	end
end

function BlacklistDialog:resetBlacklistView()
    local data =  FriendsData.getInstance():getBlacklist()
    if next(data) then
        self.mEmptyView:setVisible(false)
        self.mBlacklistView:setVisible(true)
        local adapter = new(CacheAdapter,BlacklistDialogItem,data)
        self.mBlacklistView:setAdapter(adapter)
    else
        self.mEmptyView:setVisible(true)
        self.mBlacklistView:setVisible(false)
    end
end

function BlacklistDialog.removeBlacklist(data)
    local uid = tonumber(data.mid)
    local mnick = data.mnick or uid
    if not uid then return end
    if not BlacklistDialog.s_choseDialog then
        BlacklistDialog.s_choseDialog = new(ChioceDialog)
        BlacklistDialog.s_choseDialog:setMode(ChioceDialog.MODE_COMMON)
        BlacklistDialog.s_choseDialog:setMaskDialog(true)
    end
    BlacklistDialog.s_choseDialog:setMessage( string.format("是否移除%s",mnick))
    BlacklistDialog.s_choseDialog:setNegativeListener(nil,nil)
    BlacklistDialog.s_choseDialog:setPositiveListener(uid,function(data)
        local params = {}
        params.param = {}
        params.param.target_mid = data
        HttpModule.getInstance():execute(HttpModule.s_cmds.BlackListDel,params)
    end)
    BlacklistDialog.s_choseDialog:show()
end

function BlacklistDialog.showUserInfoDialog(uid)
    uid = tonumber(uid)
    if not uid then return end
    delete(BlacklistDialog.m_up_user_info_dialog)
    BlacklistDialog.m_up_user_info_dialog = new(UserInfoDialog2);

    if UserInfo.getInstance():getUid() == uid then
        BlacklistDialog.m_up_user_info_dialog:setShowType(UserInfoDialog2.SHOW_TYPE.OTHER)
    else
        BlacklistDialog.m_up_user_info_dialog:setShowType(UserInfoDialog2.SHOW_TYPE.UNION)
    end

    FriendsData.getInstance():sendCheckUserData(uid)
    BlacklistDialog.m_up_user_info_dialog:show(nil,uid);
end

-------------------------
require(VIEW_PATH .. "blacklist_dialog_item")
BlacklistDialogItem = class(Node)

function BlacklistDialogItem:ctor(data)
    self.m_root = SceneLoader.load(blacklist_dialog_item)
    self:addChild(self.m_root)
    self:setSize(self.m_root:getSize())

    self.mHead = new(Mask,"common/background/head_bg_92.png","common/background/head_mask_bg_86.png")
    if data.iconType == -1 then
        self.mHead:setUrlImage(data.icon_url)
    else
		self.mHead:setFile(UserInfo.DEFAULT_ICON[iconType] or UserInfo.DEFAULT_ICON[1]);
    end
    self.mHead:setAlign(kAlignCenter)
    self.m_root:getChildByName("head"):addChild(self.mHead)

    self.mLevel = self.m_root:getChildByName("level")
    self.mLevel:setFile( string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevelByScore(data.score)))
    self.mScore = self.m_root:getChildByName("score")
    self.mScore:setText(data.score)
    self.mName = self.m_root:getChildByName("name")
    self.mName:setText(data.mnick)
    self.mBtn = self.m_root:getChildByName("remove_btn")
    self.mBtn:setOnClick(self,self.onClick)
    self.mData = data
    self.mHead:setEventTouch(self,self.showUserInfo)
end

function BlacklistDialogItem:onClick()
    BlacklistDialog.removeBlacklist(self.mData)
end

function BlacklistDialogItem:showUserInfo(finger_action,x,y,drawing_id_first,drawing_id_current)
    if self.mData then
        if  finger_action == kFingerUp and drawing_id_first == drawing_id_current then
            BlacklistDialog.showUserInfoDialog(self.mData.mid)
        end
    end
end
