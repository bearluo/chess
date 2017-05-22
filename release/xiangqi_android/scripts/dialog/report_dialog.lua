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

ReportDialog.show = function(self, emid)
    self:setVisible(true);
    self.m_emid = emid;
end;

ReportDialog.dismiss = function(self)
    self:setVisible(false);
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
        postData.expose.description = "no use in 2.2.5";
        HttpModule.getInstance():execute(HttpModule.s_cmds.reportBad,postData,"正在上报...");
    end;
    self:dismiss();
end;