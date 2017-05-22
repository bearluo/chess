--region replay_help_dialog.lua
--Author : LeoLi
--Date   : 2016/05/04

require(VIEW_PATH .. "replay_help_dialog");
require(BASE_PATH.."chessDialogScene")

ReplayHelpDialog = class(ChessDialogScene,false);

ReplayHelpDialog.CONTENT = {
                            [1] = {["title"] = "最近对局：",["content"] = "自动保存所有联网对局、单机对局、残局过关和观战的棋局，默认棋谱上限为"..UserInfo.getInstance():getSaveChessManualLimit().."盘"},
                            [2] = {["title"] = "我的收藏：",["content"] = "棋谱被收藏后可一直保留，方便随时演练；公开收藏为所有人可见，私密仅自己可见，点击棋谱下方的私密/公开按钮可切换棋谱的收藏方式"},
                            [3] = {["title"] = "棋友推荐：",["content"] = "可随时查看自己和好友公开收藏的棋谱，可以转收藏或评论喜欢的棋谱，若公开收藏的棋谱被好友转收藏，可以获得金币奖励"},
                            [4] = {["title"] = "清空对局：",["content"] = "右上清空按钮可一次性清空最近对局所有棋谱"},
                           };

ReplayHelpDialog.ctor = function(self)
    super(self,replay_help_dialog);
    self.m_root_view = self.m_root;
    self:init();
end

ReplayHelpDialog.dtor = function(self)
    delete(self.m_root_view);
	self.m_root_view = nil;
end

ReplayHelpDialog.init = function(self)
    self.m_bg = self.m_root_view:getChildByName("bg");
    -- content
    self.m_content_view = self.m_bg:getChildByName("frame"):getChildByName("content");
    self.m_content_view.m_autoPositionChildren = true;
    -- btn
    self.m_close_btn = self.m_bg:getChildByName("close_btn");
    self.m_close_btn:setOnClick(self,self.dismiss);
end;

ReplayHelpDialog.isShowing = function(self)
	return self:getVisible();
end

ReplayHelpDialog.show = function(self)
    self:setVisible(true);
    self.super.show(self,false);
    if not self.m_is_init then
        for i = 1, #ReplayHelpDialog.CONTENT do
            local item = new(HelpItem, ReplayHelpDialog.CONTENT[i]);
            self.m_content_view:addChild(item);
        end;
        self.m_is_init = true;
    end;
end;

ReplayHelpDialog.dismiss = function(self)
    self:setVisible(false);
    self.super.dismiss(self);
end;















------------------------------- content_item -----------------------------------

HelpItem = class(Node)


HelpItem.ctor = function(self, data)
    self.m_data = data;
    self:initView();
end;


HelpItem.initView = function(self)
    -- title
    self.m_title = new(Text,self.m_data.title,nil,nil,kAlignLeft,nil,36,135,100,95);
    self.m_title:setPos(35,20);
    self:addChild(self.m_title);
    -- content
--    self.m_content = new(TextView,self.m_data.content,560,0,kAlignLeft,nil,28,80,80,80);
    self.m_content = new(RichText,self.m_data.content,560,0,kAlignLeft,nil,28,80,80,80,true,10);
    self.m_content:setPos(35,90);
    self.m_content:setAlign(kAlignTopLeft);
    self:addChild(self.m_content);
    local w, h = self.m_content:getSize();
    self:setSize(nil,h + 90 + 50);
    self:setAlign(kAlignTopLeft);
end;



HelpItem.dtor = function(self)

end;


