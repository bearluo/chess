--region NewFile_1.lua
--Author : FordFan
--Date   : 2016/4/26
--好友邀请分享弹窗

require(VIEW_PATH .. "common_share_dialog_view");
require(BASE_PATH .. "chessDialogScene");
require("chess/util/statisticsManager");


CommonShareDialog = class(ChessDialogScene,false);

CommonShareDialog.ANIM_TIME = 320; -- 单位毫秒
CommonShareDialog.s_dialogLayer = nil;
CommonShareDialog.DEFAULT_TEXT = "我的游戏id是" .. UserInfo.getInstance():getUid() .. "，快来和我一起对弈吧";

-- 不同分享场景item配置
CommonShareDialog.share_plist = {
    ["default"] = {{1,2,3,4,5},["title"] = "游戏分享"};
    ["flight_invite"] = {{1,2,8,3,5},["title"] = "邀请好友"};
    ["game_share"] = {{1,2,3,4,5},["title"] = "邀请好友"};
    ["arena_share"] = {{1,2,3,4,5},["title"] = "邀请好友"};
    ["sys_booth"] = {{1,2,3,7},["title"] = "残局分享"};
    ["wulin_booth"] = {{1,2,3,7,8},["title"] = "残局分享"};
    ["manual_share"] = {{1,2,3,4,6},["title"] = "复盘分享"};
    ["sociaty_share"] = {{1,2,3,4,5,8},["title"] = "邀请棋友加入棋社"};
    ["screenshot_share"] = {{1,2,3,4},["title"] = "分享截图"};
}




function CommonShareDialog:ctor()
    super(self,common_share_dialog_view);
    self.m_root_view = self.m_root;
    self.is_dismissing = false;
    self:initView();
    self.mDialogAnim = AnimDialogFactory.createMoveUpAnim(self)
    self:setVisible(false);
end

function CommonShareDialog:dtor()
    delete(self.m_root_view)
    self.m_root_view = nil
    delete(self.m_locate_city_dialog)
    self.mDialogAnim.stopAnim()
end

function CommonShareDialog:isShowing()
    return self:getVisible();
end

function CommonShareDialog:show()
    self.super.show(self,self.mDialogAnim.showAnim);

--    self.is_dismissing = false;
--    self:removeViewProp();
--    local w,h = self.m_dialog_view:getSize();

--    local anim_start = self.m_dialog_view:addPropTranslate(1,kAnimNormal,CommonShareDialog.ANIM_TIME,-1,0,0,h,0);
--    self:setVisible(true);
--    if anim_start then
--        anim_start:setEvent(self,function()
--            self.m_dialog_view:removeProp(1);
--        end);
--    end
--    self.m_share_view:setVisible(true);
    self:resetChatRoomList();

--    self.super.show(self,false);
end

function CommonShareDialog:dismiss()
    self.super.dismiss(self,self.mDialogAnim.dismissAnim);

--    --防止多次点击显示多次动画
--    if self.is_dismissing then
--        return;
--    end
--    self.is_dismissing = true;
--    self:removeViewProp();
--    local w,h = self.m_dialog_view:getSize();
--    local anim_end = self.m_dialog_view:addPropTranslate(1,kAnimNormal,CommonShareDialog.ANIM_TIME,-1,0,0,0,h);
--    self.m_root_view:addPropTransparency(1,kAnimNormal,CommonShareDialog.ANIM_TIME,-1,1,0);
--    if anim_end then
--        anim_end:setEvent(self,function()
--            self:setVisible(false);
--            self.m_dialog_view:removeProp(1);
--            self.m_root_view:removeProp(1);
--        end);
--    end
--    self.super.dismiss(self,false);

end

function CommonShareDialog:initView()
    -- 灰色背景
--    self.m_bg_black = self.m_root_view:getChildByName("bg_black");
--    self.m_bg_black:setEventTouch(self,self.dismiss);
    self.m_dialog_view = self.m_root_view:getChildByName("bg");
    self.m_dialog_view:setEventTouch(nil,function() end);
    self.m_title = self.m_dialog_view:getChildByName("title");
    self.m_share_view = self.m_dialog_view:getChildByName("share_view");
 
--    self.m_wechat_btn = self.m_share_view:getChildByName("wechat"):getChildByName("btn");
--    self.m_pyq_btn    = self.m_share_view:getChildByName("pyq"):getChildByName("btn");
--    self.m_qq_btn     = self.m_share_view:getChildByName("qq"):getChildByName("btn");

--    self.m_other_view = self.m_share_view:getChildByName("other");
--    self.m_sms_view = self.m_share_view:getChildByName("sms");
--    self.m_weibo_view = self.m_share_view:getChildByName("weibo");
--    self.m_copy_url_view = self.m_share_view:getChildByName("copy_url");
--    self.mChatRoomView = self.m_share_view:getChildByName("chatRoom");

--    self.m_other_btn  = self.m_share_view:getChildByName("other"):getChildByName("btn");
--    self.m_sms_btn    = self.m_share_view:getChildByName("sms"):getChildByName("btn");
--    self.m_weibo_btn    = self.m_share_view:getChildByName("weibo"):getChildByName("btn");
--    self.m_copy_url_btn = self.m_share_view:getChildByName("copy_url"):getChildByName("btn");
--    self.mChatRoomBtn = self.m_share_view:getChildByName("chatRoom"):getChildByName("btn");

--    self.m_wechat_btn:setOnClick(self,self.onWechatBtnClick);
--    self.m_pyq_btn:setOnClick(self,self.onPyqBtnClick);
--    self.m_qq_btn:setOnClick(self,self.onQQBtnClick);
--    self.m_other_btn:setOnClick(self,self.onOtherBtnClick);
--    self.m_sms_btn:setOnClick(self,self.onSmsBtnClick);
--    self.m_weibo_btn:setOnClick(self,self.onWeiboBtnClick);
--    self.m_copy_url_btn:setOnClick(self,self.onCopyUrl);
--    self.mChatRoomBtn:setOnClick(self,self.sendToLTS);
    
    self.mChatRoomList = self.m_dialog_view:getChildByName("chat_room_view");
    self:setShieldClick(self,self.dismiss);
    self.m_dialog_view:setEventTouch(self,function() end)
end

--移除控件属性
--function CommonShareDialog:removeViewProp()

--    if not self.m_dialog_view:checkAddProp(1) then
--        self.m_dialog_view:removeProp(1);
--    end

--    if not self.m_root_view:checkAddProp(1) then
--        self.m_root_view:removeProp(1);
--    end
--end

--[Comment]
--短信分享
function CommonShareDialog:onSmsBtnClick()
    self:dismiss();
    if self.share_tab then
        CommonShareDialog.shareShortUrl(self.share_tab,"sms",function(data)
            self:onEventStat(StatisticsManager.SHARE_WAY_SMS);
            dict_set_string(SHARE_TEXT_TO_SMS_MSG , SHARE_TEXT_TO_SMS_MSG .. kparmPostfix , json.encode(data));
            call_native(SHARE_TEXT_TO_SMS_MSG);
        end)
    end
end

--[Comment]
--微博分享
function CommonShareDialog:onWeiboBtnClick()
    self:dismiss();
    if self.share_tab then
        CommonShareDialog.shareShortUrl(self.share_tab,"weibo",function(data)
            self:onEventStat(StatisticsManager.SHARE_WAY_WEIBO);
            dict_set_string(SHARE_TEXT_TO_WEIBO_MSG , SHARE_TEXT_TO_WEIBO_MSG .. kparmPostfix , json.encode(data));
            call_native(SHARE_TEXT_TO_WEIBO_MSG);
        end)
    end
end

--[Comment]
-- 控制分享弹窗显示的按钮
function CommonShareDialog.setShareDialogStatus(self)
    local eventType = "default"
    if self.eventType then
        eventType = self.eventType;
    end 
    local plist = CommonShareDialog.share_plist[eventType][1] or CommonShareDialog.share_plist["default"][1];
    self.m_title:setText(CommonShareDialog.share_plist[eventType].title or "游戏分享");
    local x,y = 0,0;
    for i,j in pairs(plist) do
        local node = self:cerateShareNode(j);
        if node then
            local w,h = node:getSize();
            node:setPos(x,y);
            x = x+w+5;
            if i%3 == 0 then
                x = 0;
                y = y+h+30;
            end
            self.m_share_view:addChild(node);
        end
    end

    
--    if not self.eventType then
--        self.share_tab = nil;
--        self.mChatRoomView:setVisible(false);
--        self.m_other_view:setVisible(true);
--        self.m_sms_view:setVisible(false);
--        self.m_weibo_view:setVisible(false);
--    elseif self.eventType == "flight_invite" then
--        self.mChatRoomView:setVisible(false);
--        self.m_other_view:setVisible(false);
--        self.m_sms_view:setVisible(true);
--        self.m_weibo_view:setVisible(true);
--    elseif self.eventType == "game_share" or self.eventType == "arena_share" then
--        self.mChatRoomView:setVisible(false);
--        self.m_other_view:setVisible(false);
--        self.m_sms_view:setVisible(true);
--        self.m_weibo_view:setVisible(true);
--        self.m_title:setText("邀请好友");
--    elseif self.eventType == "sys_booth" then
--        self.mChatRoomView:setVisible(false);
--        self.m_other_view:setVisible(true);
--        self.m_sms_view:setVisible(false);
--        self.m_weibo_view:setVisible(false);
--    elseif self.eventType == "wulin_booth" then
--        self.mChatRoomView:setVisible(true);
--        self.m_other_view:setVisible(true);
--        self.m_sms_view:setVisible(false);
--        self.m_weibo_view:setVisible(false);
--    elseif self.eventType == "manual_share" then
--        self.mChatRoomView:setVisible(false);
--        self.m_other_view:setVisible(false);
--        self.m_sms_view:setVisible(false);
--        self.m_weibo_view:setVisible(false);
--        self.m_copy_url_view:setVisible(true);
--    end
end

--[Comment]
-- 创建分享node
function CommonShareDialog.cerateShareNode(self,index)
    local item = CommonShareDialog.SHARE_ITEM[index]
    if not item then return end

    local node = new(Node)
    node:setSize(214,182)
    node:setAlign(kAlignTopLeft)

    local button = new(Button,item.icon)
    button:setSize(130,130)
    button:setAlign(kAlignTop)
    node:addChild(button)
    
    local text = new(Text,item.title,nil,kAlignCenter,nil,nil,32,80,80,80)
    text:setAlign(kAlignBottom)
    node:addChild(text)

    button:setOnClick(self,item.event);
    button:setSrollOnClick();
    return node
end

--[Comment]
--朋友圈分享
function CommonShareDialog:onPyqBtnClick()
    self:dismiss();
    if self.share_tab then
        CommonShareDialog.shareShortUrl(self.share_tab,"pyq",function(data)
            self:onEventStat(StatisticsManager.SHARE_WAY_PYQ);
            dict_set_string(SHARE_TEXT_TO_PYQ_MSG , SHARE_TEXT_TO_PYQ_MSG .. kparmPostfix , json.encode(data));
            call_native(SHARE_TEXT_TO_PYQ_MSG);
        end)
    end
end

--[Comment]
--微信分享
function CommonShareDialog:onWechatBtnClick()
    self:dismiss();
    if self.share_tab then
        CommonShareDialog.shareShortUrl(self.share_tab,"wechat",function(data)
            self:onEventStat(StatisticsManager.SHARE_WAY_WECHAT);
            dict_set_string(SHARE_TEXT_TO_WEICHAT_MSG , SHARE_TEXT_TO_WEICHAT_MSG .. kparmPostfix , json.encode(data));
            call_native(SHARE_TEXT_TO_WEICHAT_MSG);
        end)
    end
end

--[Comment]
--其他分享
function CommonShareDialog:onOtherBtnClick()
    self:dismiss();
    if self.share_tab then
        ToolKit.schedule_once(self,function() 
            dict_set_string(kTakeScreenShot , kTakeScreenShot .. kparmPostfix , "egame_share");
            call_native(kTakeScreenShot);       
        end,200);
    end
end

--[Comment]
--QQ分享
function CommonShareDialog:onQQBtnClick()
    self:dismiss();
    if self.share_tab then
        CommonShareDialog.shareShortUrl(self.share_tab,"QQ",function(data)
            self:onEventStat(StatisticsManager.SHARE_WAY_QQ);
            dict_set_string(SHARE_TEXT_TO_QQ_MSG , SHARE_TEXT_TO_QQ_MSG .. kparmPostfix , json.encode(data));     
            call_native(SHARE_TEXT_TO_QQ_MSG);
        end)
    end
end

--[Comment]
--复制链接
function CommonShareDialog:onCopyUrl()
    self:dismiss();
    if self.share_tab then
        local url = require("libs/url");
        local u = url.parse(self.share_tab.h5_developUrl);
        local params = {}
        params.manual_id = self.share_tab.manual_id
        u:addQuery(params);
        local url = u:build()
        dict_set_string("CopyUrl" , "CopyUrl" .. kparmPostfix , url);
        call_native("CopyUrl");
    end
end

--[Comment]
--事件统计
function CommonShareDialog:onEventStat(way)
    if not self.eventType then return end
    StatisticsManager.getInstance():onCountShare(self.eventType,way);
end

--[Coment]
--data:分享内容  shareType:分享类型
function CommonShareDialog:setShareDate(data,shareType)
    self.share_tab = data;
    self.eventType = shareType;
    self:setShareDialogStatus();
end

--[Comment]
--切换到聊天室分享
function CommonShareDialog.sendToLTS(self)
    self.mChatRoomList:setVisible(true);
    self.m_share_view:setVisible(false);
end

--[Comment]
--设置聊天房间配置
function CommonShareDialog.resetChatRoomList(self)
    self.mChatRoomList:removeAllChildren();
    self.mChatRoomList:setVisible(false);
    self.m_share_view:setVisible(true);
    local chatRoomConfig = UserInfo.getInstance():getChatRoomList(true);
    local x,y = 22,0;
    if not chatRoomConfig then return end
    for i,param in ipairs(chatRoomConfig) do
        local group = self:getChatRoomItem(param);
        local w,h = group:getSize();
        group:setPos(x,y);
        y = y+h;
        self.mChatRoomList:addChild(group);
    end
end

--[Comment]
--聊天室分享
-- 占时只有街边残局用到 所以占时写死
function CommonShareDialog.getChatRoomItem(self,data)
    local group = new(Button,"drawable/blank.png");
    group:setSize(600,100);

    local icon = new(Image,"common/icon/lts_small.png");
    icon:setAlign(kAlignLeft);
    icon:setPos(17,0);
    group:addChild(icon);

    local dec = new(Image,"common/decoration/line_2.png");
    dec:setAlign(kAlignBottom);
    dec:setSize(600);
    group:addChild(dec);

    local title = new(Text,data.name, nil, nil, kAlignBottom, nil, 28, 125,80,65);
    title:setAlign(kAlignLeft);
    title:setPos(84,0);
    group:addChild(title);

    group:setOnClick(self,function()
            -- 同城聊天要特殊处理
            local params = {};
            params.method = "gotoCustomEndgateRoom";
            params.time   = os.time()
            local endgateData = kEndgateData:getPlayCreateEndingData()
            if type(endgateData) ~= "table" then ChessToastManager.getInstance():show("数据错误") return end
            params.booth_id = endgateData.booth_id
            if tonumber(data.id) and tonumber(data.id) == 1001 then 
                if UserInfo.getInstance():getProvinceCode() == 0 then
                    self:dismiss();
                    ChessToastManager.getInstance():showSingle("请先设置所在地区");
                    if not self.m_locate_city_dialog then
                        self.m_locate_city_dialog = new(CityLocatePopDialog);
                    end
                    self.m_locate_city_dialog:show();
                    return
                end
                self:sendChatRoomMsg(UserInfo.getInstance():getProvinceCode(),params);
            else
                self:sendChatRoomMsg(data.id,params);
            end
            
            ChessToastManager.getInstance():showSingle("发送成功");
            self:onEventStat(StatisticsManager.SHARE_WAY_CHAT);
        end
    );
    group:setSrollOnClick();
    return group;
end

function CommonShareDialog.sendChatRoomMsg(self,roomId,params)
    StatisticsManager.getInstance():onCountInvitePlayChess(StatisticsManager.SHARE_WAY_CHAT);
    local msgdata = {};
	msgdata.room_id = roomId;
	msgdata.msg = SchemesProxy.getMySchemesUrl(params);
	msgdata.name = UserInfo.getInstance():getName();
	msgdata.uid = UserInfo.getInstance():getUid();
	OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_USER_CHAT_MSG,msgdata);
    -- 发送完消息需要离开房间
	local info = {};
	info.room_id = roomId;
	info.uid = UserInfo.getInstance():getUid();
    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_LEAVE_ROOM,info);
    self:dismiss();
end


CommonShareDialog.SHARE_ITEM = {
   
   [1] = {
        ["icon"]    = "common/icon/wechat.png";
        ["title"]   = "微信";
        ["event"]   = CommonShareDialog.onWechatBtnClick;
                         
    },
    [2] = {
        ["icon"]    = "common/icon/pyq.png";
        ["title"]   = "朋友圈";
        ["event"]   = CommonShareDialog.onPyqBtnClick;
    },
    [3] = {
        ["icon"]    = "common/icon/qq_icon.png";
        ["title"]   = "QQ";
        ["event"]   = CommonShareDialog.onQQBtnClick;
    },
    [4] = {
        ["icon"]    = "common/icon/weibo.png";
        ["title"]   = "微博";
        ["event"]   = CommonShareDialog.onWeiboBtnClick;
    },
    [5] = {
        ["icon"]    = "common/icon/sms.png";
        ["title"]   = "短信";
        ["event"]   = CommonShareDialog.onSmsBtnClick;
    },
    [6] = {
        ["icon"]    = "common/icon/fzlj.png";
        ["title"]   = "复制链接";
        ["event"]   = CommonShareDialog.onCopyUrl;
    },
    [7] = { 
        ["icon"]    = "common/icon/share_othe.png";
        ["title"]   = "其他";
        ["event"]   = CommonShareDialog.onOtherBtnClick;
    },
    [8] = {
        ["icon"]    = "common/icon/lts.png";
        ["title"]   = "聊天室";
        ["event"]   = CommonShareDialog.sendToLTS;
    },

}

CommonShareDialog.getShareTitle = function(win_flag,redName,red_level,blackName,black_level)
    local title = nil
    if win_flag and redName and red_level and blackName and black_level then
        local len = string.lenutf8(GameString.convert2UTF8(redName) or "")
        if len > 4 then
            redName = string.subutf8(redName,1,4).."..."
        end
        local len = string.lenutf8(GameString.convert2UTF8(blackName) or "")
        if len > 4 then
            blackName = string.subutf8(blackName,1,4).."..."
        end
        if win_flag == 1 then
            title = "【"..(User.QILI_LEVEL[red_level] or "九级").."】"..(redName or "博雅象棋").." 胜 "
                    .."【"..(User.QILI_LEVEL[black_level] or "九级").."】"..(blackName or "博雅象棋")
        elseif win_flag == 2 then
            title = "【"..(User.QILI_LEVEL[black_level] or "九级").."】"..(blackName or "博雅象棋").." 胜 "
                    .."【"..(User.QILI_LEVEL[black_level] or "九级").."】"..(redName or "博雅象棋")        
        else
            title = "【"..(User.QILI_LEVEL[red_level] or "九级").."】"..(redName or "博雅象棋").." 平 "
                    .."【"..(User.QILI_LEVEL[black_level] or "九级").."】"..(blackName or "博雅象棋")
        end
    end
    return title
end

CommonShareDialog.getShareTime = function(add_time)
    local addTime = nil
    if add_time then
        addTime = "对局时间："..os.date("%Y/%m/%d %H:%M",add_time)
    end
    return addTime
end


CommonShareDialog.shareShortUrl = function(data,shareType,callback)
    local mData = Copy(data)
    if mData.is_picture == "1" then -- 分享图片不需要
        callback(mData)
        return
    end
    local url = require("libs/url");
    local u = url.parse(mData.url);
    local addparams = {}
    addparams.share_source = shareType;
    u:addQuery(addparams);
    local params = {}
    params.long_url = SchemesProxy.ToBase64(u:build())
    HttpModule.getInstance():execute2(HttpModule.s_cmds.IndexCreateShortUrl,params,function(isSuccess,resultStr)
        if not isSuccess then
            ChessToastManager.getInstance():showSingle("分享链接生成失败")
            return 
        end

        local params = json.decode(resultStr)

        if not params or tonumber(params.flag) ~= 10000 or not params.data then
            ChessToastManager.getInstance():showSingle("分享链接生成失败")
            return 
        end
        mData.url = params.data.short_url;
        callback(mData)
    end)
end