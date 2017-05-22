--region NewFile_1.lua
--Author : FordFan
--Date   : 2015/11/11
--房间内观战
--endregion

require("view/view_config");
require(VIEW_PATH.."watch_room_list");
require(BASE_PATH.."chessDialogScene");
require("ui/node");
require("ui/adapter");
require("ui/listView"); 

WatchListDialog = class(ChessDialogScene,false);

WatchListDialog.ctor = function(self,id)
    super(self,watch_room_list);
    self.m_bg = self.m_root:getChildByName("bg");
    self.m_bg:setEventTouch(self,function()end);
    self.m_content_view = self.m_bg:getChildByName("content_view")
    self.watch_player_view = self.m_content_view:getChildByName("watch_player");

    self.m_blackData = WatchListDialog.s_blackData or nil;
    self.m_redData = WatchListDialog.s_redData or nil;

    self.mGiftRankList = self.m_content_view:getChildByName("gift_rank_list")
    self.mRankListHandler = self.mGiftRankList:getChildByName("rank_list_handler")

    self:initTopView();
    self:setShieldClick(self, self.dismiss);
    self.mDialogAnim = AnimDialogFactory.createMoveUpAnim(self)
end

WatchListDialog.dtor = function(self)
    self.mDialogAnim.stopAnim()
    delete(self.mRefreshRank)
    self.mRefreshRank = nil
end

WatchListDialog.isShowing = function(self)
    return self:getVisible();
end

WatchListDialog.show = function(self)
    print_string("ChatDialog.show");
    self.super.show(self,self.mDialogAnim.showAnim);
    local info = {};
    info.tid = RoomProxy.getInstance():getTid();
    OnlineSocketManager.getHallInstance():sendMsg(OB_CMD_GET_NUM,info);
    if RoomProxy.getInstance():getCurRoomType() == RoomConfig.ROOM_TYPE_METIER_ROOM then
        if RoomProxy.getInstance():isMatchWatcher() then
            self.m_mode = WatchListDialogItem.s_mode_watch
            self:getWitnessPresentMoneyRank()
        else
            self.m_mode = WatchListDialogItem.s_mode_play
            self:getWitnessContributionRank()
        end
    elseif RoomProxy.getInstance():getCurRoomType() ~= RoomConfig.ROOM_TYPE_WATCH_ROOM then
        self.m_mode = WatchListDialogItem.s_mode_play
        self:getWitnessContributionRank()
    else
        self.m_mode = WatchListDialogItem.s_mode_watch
        self:getWitnessPresentMoneyRank()
    end
    self:getUserGiftNum()
end

function WatchListDialog:updateUserGiftNum(gift_target_id,gift_type,num)
    if not self.m_redData or not self.m_blackData then return end
    if not self.mRedGiftData or not self.mBlackGiftData then
        self:getUserGiftNum()
        return 
    end
    local num = tonumber(num) or 0
    local gift_type = gift_type or 0
    if tonumber(self.m_redData.m_uid) == tonumber(gift_target_id) then
        self.mRedGiftData[gift_type..""] = (self.mRedGiftData[gift_type..""] or 0) + num
        self.mRedGiftModuleScrollList:onUpdateItem(self.mRedGiftData)
    elseif tonumber(self.m_blackData.m_uid) == tonumber(gift_target_id) then
        self.mBlackGiftData[gift_type..""] = (self.mBlackGiftData[gift_type..""] or 0) + num
        self.mBlackGiftModuleScrollList:onUpdateItem(self.mBlackGiftData)
    end
    if self.mRefreshRank then delete(self.mRefreshRank) end
    self.mRefreshRank = AnimFactory.createAnimInt(kAnimNormal,0,1,100,2000)
    self.mRefreshRank:setEvent(self,function()
        if self.m_mode == WatchListDialogItem.s_mode_play then
            self:getWitnessContributionRank()
        else
            self:getWitnessPresentMoneyRank()
        end
        delete(self.mRefreshRank)
        self.mRefreshRank = nil
    end)
end

function WatchListDialog:getUserGiftNum()
    if self.m_redData then
        local params = {}
        params.param = {}
        params.param.mid = self.m_redData.m_uid
        params.param.table_id = RoomProxy.getInstance():getTid()
        params.param.start_time = RoomProxy.getInstance():getRoomStartTime()
        HttpModule.getInstance():execute2(HttpModule.s_cmds.UserGetUserGiftNum,params,function(isSuccess,resultStr)
            if isSuccess then
                local data = json.decode(resultStr)
                if not data or data.flag ~= 10000 then return end
                self.mRedGiftData = data.data
                self.mRedGiftModuleScrollList:onUpdateItem(data.data)
            else 
            end
        end)
    end
    if self.m_blackData then
        local params = {}
        params.param = {}
        params.param.mid = self.m_blackData.m_uid
        params.param.table_id = RoomProxy.getInstance():getTid()
        params.param.start_time = RoomProxy.getInstance():getRoomStartTime()
        HttpModule.getInstance():execute2(HttpModule.s_cmds.UserGetUserGiftNum,params,function(isSuccess,resultStr)
            if isSuccess then
                local data = json.decode(resultStr)
                if not data or data.flag ~= 10000 then return end
                self.mBlackGiftData = data.data
                self.mBlackGiftModuleScrollList:onUpdateItem(data.data)
            else 
            end
        end)
    end
end

function WatchListDialog:getWitnessPresentMoneyRank()
    local params = {}
    params.table_id = RoomProxy.getInstance():getTid()
    params.start_time = RoomProxy.getInstance():getRoomStartTime()
    HttpModule.getInstance():execute2(HttpModule.s_cmds.ArenaGetWitnessPresentMoneyRank,params,function(isSuccess,resultStr)
        if self.m_mode ~= WatchListDialogItem.s_mode_watch then return end
        if isSuccess then
            local data = json.decode(resultStr)
--            data = {}
--            data.time = 1490951260
--            data.flag = 10000
--            data.data = {}
--            for i=1,10 do
--                local tmp = {}
--                tmp.mid = i
--                tmp.mnick = i
--                tmp.icon_url = ""
--                tmp.is_vip = 0
--                tmp.my_set = ""
--                tmp.score = ""
--                tmp.iconType = 1
--                tmp.send_value = i
--                data.data[i] = tmp
--            end
            if not data or data.flag ~= 10000 then 
--                local msg = data.error or "操作失败！"
--                ChessToastManager.getInstance():showSingle(msg)
                self:resetRankList()
                return
            end
            self:resetRankList(data.data)
        else 
            self:resetRankList()
--            ChessToastManager.getInstance():showSingle("操作失败！")
        end
    end)
end

function WatchListDialog:getWitnessContributionRank()
    local params = {}
    params.table_id = RoomProxy.getInstance():getTid()
    params.start_time = RoomProxy.getInstance():getRoomStartTime()
    HttpModule.getInstance():execute2(HttpModule.s_cmds.ArenaGetWitnessContributionRank,params,function(isSuccess,resultStr)
        if self.m_mode ~= WatchListDialogItem.s_mode_play then return end
        if isSuccess then
            local data = json.decode(resultStr)
--            data = {}
--            data.time = 1490951260
--            data.flag = 10000
--            data.data = {}
--            for i=1,10 do
--                local tmp = {}
--                tmp.mid = i
--                tmp.mnick = i
--                tmp.icon_url = ""
--                tmp.is_vip = 0
--                tmp.my_set = ""
--                tmp.score = ""
--                tmp.iconType = 1
--                tmp.send_value = i
--                data.data[i] = tmp
--            end
            if not data or data.flag ~= 10000 then 
--                local msg = data.error or "操作失败！"
--                ChessToastManager.getInstance():showSingle(msg)
                self:resetRankList()
                return
            end
            self:resetRankList(data.data)
        else 
            self:resetRankList()
--            ChessToastManager.getInstance():showSingle("操作失败！")
        end
    end)
end

function WatchListDialog:resetRankList(datas)
    local offsetW,offsetH = self.mRankListHandler:getSize()
    local w,h = self.mGiftRankList:getSize()
    self.mRankListHandler:removeAllChildren()
    local addH = 0
    if type(datas) == "table" and datas[1] then
        for rank,data in ipairs(datas) do
            local item = new(WatchListDialogItem)
            item:setModel(self.m_mode)
            item:setUserData(data)
            item:setRankView(rank)
            item:setPos(0,addH)
            addH = addH + select(2,item:getSize())
            self.mRankListHandler:addChild(item)
        end
    else
        local text = new(Text,"暂无数据", w, 50, kAlignCenter, fontName, 30, 70, 70, 70)
        addH = addH + select(2,text:getSize())
        self.mRankListHandler:addChild(text)
    end
    self.mRankListHandler:setSize(nil,addH)
    self.mGiftRankList:setSize(nil,h-offsetH+addH)
    self.m_content_view:updateScrollView()
end

WatchListDialog.dismiss = function(self)
    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
    delete(self.mRefreshRank)
    self.mRefreshRank = nil
end

WatchListDialog.initTopView = function(self)
    local func = function(view,enable)
        Log.i(enable);
        local title = view:getChildByName("text");
        if title then
            if enable then
                title:removeProp(1);
            else
                title:addPropScaleSolid(1,1.1,1.1,1);
            end
        end
    end

    self.watch_player_view:setVisible(true);
    --红方信息
    self.red_view = self.watch_player_view:getChildByName("red_player");
    self.red_name_view = self.red_view:getChildByName("name_view");
    self.red_name = self.red_view:getChildByName("name_view"):getChildByName("name");
    self.red_icon_mask = self.red_view:getChildByName("icon_bg"):getChildByName("icon_mask");
    self.red_level = self.red_view:getChildByName("level");
    self.red_vip_frame = self.red_view:getChildByName("icon_bg"):getChildByName("vip_frame");
    self.red_gift_view = self.red_view:getChildByName("gift_view");
    local rw,rh = self.red_gift_view:getSize()
    local rscrSize = {w = rw,h = rh}
    local ritemSize = {w = 80,h = 100}
    local rbgSize = {w = 80,h = 26}
    self.mRedGiftModuleScrollList = new(GiftModuleScrollList,rscrSize,ritemSize,rbgSize,GiftModuleItem.s_mode_user2)
    self.red_gift_view:addChild(self.mRedGiftModuleScrollList)

    --黑方信息
    self.black_view = self.watch_player_view:getChildByName("black_player");
    self.black_name_view = self.black_view:getChildByName("name_view");
    self.black_name = self.black_view:getChildByName("name_view"):getChildByName("name");
    self.black_icon_mask = self.black_view:getChildByName("icon_bg"):getChildByName("icon_mask");
    self.black_level = self.black_view:getChildByName("level");
    self.black_vip_frame = self.black_view:getChildByName("icon_bg"):getChildByName("vip_frame");
    self.black_gift_view = self.black_view:getChildByName("gift_view");
    local rw,rh = self.black_gift_view:getSize()
    local rscrSize = {w = rw,h = rh}
    local ritemSize = {w = 80,h = 100}
    local rbgSize = {w = 80,h = 26}
    self.mBlackGiftModuleScrollList = new(GiftModuleScrollList,rscrSize,ritemSize,rbgSize,GiftModuleItem.s_mode_user2)
    self.black_gift_view:addChild(self.mBlackGiftModuleScrollList)
    --观战人数
    self.watch_num = self.m_bg:getChildByName("tittle_line"):getChildByName("num");
    self.left_text = self.m_bg:getChildByName("tittle_line"):getChildByName("Text1");
    self.right_text = self.m_bg:getChildByName("tittle_line"):getChildByName("Text2");

    self:initPlayerData()
end

WatchListDialog.setRedData = function(data)
    WatchListDialog.s_redData = data;
end

WatchListDialog.setBlackData = function(data)
    WatchListDialog.s_blackData = data;
end

WatchListDialog.initPlayerData = function(self)

   local func = function(view,enable)
        Log.i(enable);
        local title = view:getChildByName("text");
        if title then
            if enable then
                title:removeProp(1);
            else
                title:addPropScaleSolid(1,1.1,1.1,1);
            end
        end
    end  
    if self.m_redData then
    --红方
        self.red_icon = new(Mask,UserInfo.DEFAULT_ICON[1],"common/background/head_mask_bg_86.png");
        self.red_icon:setSize(self.red_icon_mask:getSize());
        self.red_icon:setAlign(kAlignCenter);
        self.red_icon_mask:addChild(self.red_icon);

        self.red_icon:setFile(UserInfo.DEFAULT_ICON[1]);
        local iconType = tonumber(self.m_redData:getIconType());
        if iconType and iconType > 0 then
            self.red_icon:setFile(UserInfo.DEFAULT_ICON[iconType] or UserInfo.DEFAULT_ICON[1]);
        else
            if iconType == -1 then --兼容1.7.5之前的版本的头像为""时显示默认头像。
                self.red_icon:setUrlImage(self.m_redData:getIcon(),UserInfo.DEFAULT_ICON[1]);
            end
        end

        self.red_name:setText(self.m_redData.m_name,0,0);
        local width = self.red_name:getSize();
        self.red_level:setFile("common/icon/level_"..10 - UserInfo.getInstance():getDanGradingLevelByScore(tonumber(self.m_redData.m_score))..".png");

        if self.m_redData.m_vip and tonumber(self.m_redData.m_vip) == 1 then
             self.red_vip_frame:setVisible(true);
        else
             self.red_vip_frame:setVisible(false);
        end
    end
    --黑方
    if self.m_blackData then
        self.black_icon = new(Mask,UserInfo.DEFAULT_ICON[1],"common/background/head_mask_bg_86.png");
        self.black_icon:setSize(self.black_icon_mask:getSize());
        self.black_icon:setAlign(kAlignCenter);
        self.black_icon_mask:addChild(self.black_icon);

        self.black_icon:setFile(UserInfo.DEFAULT_ICON[1]);
        local iconType = tonumber(self.m_blackData:getIconType());
        if iconType and iconType > 0 then
            self.black_icon:setFile(UserInfo.DEFAULT_ICON[iconType] or UserInfo.DEFAULT_ICON[1]);
        else
            if iconType == -1 then --兼容1.7.5之前的版本的头像为""时显示默认头像。
                self.black_icon:setUrlImage(self.m_blackData:getIcon(),UserInfo.DEFAULT_ICON[1]);
            end
        end

        self.black_name:setText(self.m_blackData.m_name,0,0);
        local width = self.black_name:getSize();
        self.black_level:setFile("common/icon/level_"..10 - UserInfo.getInstance():getDanGradingLevelByScore(tonumber(self.m_blackData.m_score))..".png");

        if self.m_blackData.m_vip and tonumber(self.m_blackData.m_vip) == 1 then
             self.black_vip_frame:setVisible(true);
        else
             self.black_vip_frame:setVisible(false);
        end
    end

end
--更新观战数量
WatchListDialog.updataWatchNum = function(self,info)
    if not info then return end

    self.watch_num:setText(info.ob_num);
    
    local pos_x,pos_y = self.watch_num:getPos();
    local w,h = self.watch_num:getSize();
    local lx = pos_x - w/2;
    local rx = pos_x + w/2
    self.left_text:setPos(lx - 68);
    self.right_text:setPos(rx + 84);

end

require(VIEW_PATH .. "watch_room_list_item")
WatchListDialogItem = class(Node)
WatchListDialogItem.s_mode_watch = 1
WatchListDialogItem.s_mode_play = 2
WatchListDialogItem.ctor = function(self)
    self.m_root = SceneLoader.load(watch_room_list_item);
    self:addChild(self.m_root);
    local w,h = self.m_root:getSize();
    self:setSize(w,h);

    self.mRankView = self.m_root:getChildByName("rank_view")
    self.mRankNum = self.m_root:getChildByName("rank_num")
    self.mLevel = self.m_root:getChildByName("level")
    self.mName = self.m_root:getChildByName("name")
    self.mHeadBg = self.m_root:getChildByName("head_bg")
    self.mModelTxt = self.m_root:getChildByName("model_txt")
    self.mHead = new(Mask,"common/icon/default_head.png","common/background/head_mask_bg_86.png")
    self.mHead:setSize(66,66)
    self.mHead:setAlign(kAlignCenter)
    self.mHeadBg:addChild(self.mHead)
    self.mName:setEllipsis(select(1,self.mName:getSize()))
    
end

function WatchListDialogItem:setModel(mode)
    if WatchListDialogItem.s_mode_play == mode then
        self.mModelTxt:setText("魅力贡献:")
    else
        self.mModelTxt:setText("金币数量:")
    end
end

function WatchListDialogItem:setUserData(data)
    if type(data) ~= "table" then return end
    self.mName:setText(data.mnick)
    if tonumber(data.iconType) == -1 then
        self.mHead:setUrlImage(data.icon_url,"common/icon/default_head.png")
    else
        local icon = tonumber(data.iconType) or 1
        self.mHead:setFile(UserInfo.DEFAULT_ICON[icon] or UserInfo.DEFAULT_ICON[1])
    end
    self.mLevel:setFile( string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevelByScore(data.score)))
    self:setRankValue(data.send_value)
end

function WatchListDialogItem:setRankValue(num)
    num = tonumber(num)
    if not num then return end
    local str = "0"
    if num < 10000 then
        str = num
    else
        if num % 10000 < 100 then
            str = string.format("%d万",num/10000)
        elseif num % 10000 > 100 and num % 1000 < 100 then
            str = string.format("%.1f万",num/10000)
        else 
            str = string.format("%.2f万",num/10000)
        end
    end
    self.mRankNum:setText(str)
end

function WatchListDialogItem:setRankView(rank)
    rank = tonumber(rank)
    if not rank then return end
    self.mRankView:removeAllChildren()
    if rank and rank < 4 and rank > 0 then
        local img = new(Image,"common/icon/temp_rank_icon_" .. rank .. ".png")
        img:setAlign(kAlignCenter)
        self.mRankView:addChild(img)
    else
        local txt = new(Text,rank, 0, 0, align, fontName, 28, 125, 80, 65)
        txt:setAlign(kAlignCenter)
        self.mRankView:addChild(txt)
    end
end