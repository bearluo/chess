-- ReportDialog.lua
-- By LeoLi 
-- Date 2016/4/11

require(VIEW_PATH .. "report_dialog");
require(BASE_PATH.."chessDialogScene");
ReportDialog = class(ChessDialogScene,false);

ReportDialog.ctor = function(self)
    super(self,report_dialog);
    self.m_root_view = self.m_root;
    self:setShieldClick(self, self.dismiss);
    self:init();
end

ReportDialog.dtor = function(self)
    delete(self.m_root_view);
	self.m_root_view = nil;
end

ReportDialog.init = function(self)
    self.m_bg = self.m_root_view:getChildByName("bg");
    self.m_bg:setEventTouch(self,function() end);
    -- content
    self.m_content_view = self.m_bg:getChildByName("content_view");
    self.m_report_reason = self.m_content_view:getChildByName("report_reason");
    self.m_report_view = self.m_bg:getChildByName("report_view");

    -- btns
    self.m_btns_view = self.m_bg:getChildByName("btns_view");
    self.m_close_btn = self.m_btns_view:getChildByName("close");
    self.m_close_btn:setOnClick(self,self.dismiss);
    self.m_sure_btn = self.m_btns_view:getChildByName("sure");
    self.m_sure_btn:setOnClick(self, self.toReport);
end;

ReportDialog.isShowing = function(self)
	return self:getVisible();
end

ReportDialog.show = function(self, emid,data)
    self:setVisible(true);
    self.m_emid = emid;
    self:setReportInfo(data)
end;

ReportDialog.dismiss = function(self)
    self:setVisible(false);
    self.m_report_reason:clear();
    delete(self.node)
    self.node = nil
end;

ReportDialog.toReport = function(self)
    local checkIndex = self.m_report_reason:getResult();
    if not checkIndex then
        Log.i("ReportDialog.toReport--->no check!");
    else
        local postData = {};
        postData.expose = {};
        postData.expose.mid = UserInfo.getInstance():getUid();
        postData.expose.emid =  self.m_emid;
        postData.expose.type = checkIndex;
        postData.expose.description = self.reportInfo or "";
        HttpModule.getInstance():execute(HttpModule.s_cmds.reportBad,postData);
    end;
    self:dismiss();
end;

function ReportDialog.setReportInfo(self,info)
    if not info then return end
    self.reportInfo = info or ""
    self:createChatItem()
end

function ReportDialog:setUserData(data)
    if not data then return end
    self.mUserData = data
    self:createChatItem()
end

function ReportDialog.createChatItem(self) 
    if not self.mUserData or not self.reportInfo then return end
    if not self.node then 
        self.node = new(Node)
        self.node:setSize(550,50)
        self.node:setAlign(kAlignTop)
        local imgBg = new(Image,"input_bg_2.png",nil,nil,33,33,0,0)
        imgBg:setSize(600,62)
        imgBg:setAlign(kAlignCenter)
        self.node:addChild(imgBg)
    end

    local score = self.mUserData.score or 1
    if not self.levelImg then
        self.levelImg = new(Image,"common/icon/level_"..(10 - UserInfo.getInstance():getDanGradingLevelByScore(score))..".png")
        self.levelImg:setAlign(kAlignLeft)
        self.levelImg:setPos(18,0)
        self.node:addChild(self.levelImg)
    else
        self.levelImg:setFile("common/icon/level_"..(10 - UserInfo.getInstance():getDanGradingLevelByScore(score))..".png")
    end

    local sendName = self.mUserData.mnick or "博雅象棋"
    if not self.name then
        self.name = new(Text,sendName .. ":",nil, nil, nil, nil, 26, 220, 75, 30)
        self.name:setPos(76,0)
        self.name:setAlign(kAlignLeft)
        self.node:addChild(self.name)
    else
        self.name:setText(sendName .. ":",0,0)
    end
    local w,h = self.name:getSize()
    local str = self.reportInfo or "..."
    local len = ToolKit.utf8_len(str)
    if len > 30 then
        str = string.sub(str,1,30)
    end
    if not self.chatStr then
        self.chatStr = new(Text,str or "",nil, nil, nil, nil, 26, 80, 80, 80)
        self.chatStr:setPos(w + 80,0)
        self.chatStr:setAlign(kAlignLeft)
        self.node:addChild(self.chatStr)
    else
        self.chatStr:setPos(w + 80,0)
        self.chatStr:setText(str or "",0,0)
    end
    self.m_report_view:addChild(self.node)
end