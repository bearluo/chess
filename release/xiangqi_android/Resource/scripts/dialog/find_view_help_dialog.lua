require(VIEW_PATH .. "find_view_help_dialog_view");
require(BASE_PATH .. "chessDialogScene");

FindViewHelpDialog = class(ChessDialogScene,false);

FindViewHelpDialog.CONTEXT = {
' #l#s30#c87645F推荐：#l#n',
'   热门活动均为有奖活动，人气活动会在推荐区滚动展示。#l',
'   最近对手推荐会为您推荐最近7天的对战用户，有惺惺相惜的棋友就赶快关注吧。#l',
'   热门棋谱是最受关注的热门街边残局的通关棋谱，适合棋友们推敲演练。棋友挑战高难度人气残局的通关棋谱都有机会获得官方推荐哦。#l',
' #l#s30#c87645F街边残局：#l#n',
'   街边残局采用累计奖池的方式，残局上传者的创建金、所有用户的挑战金都会累积至奖池中。残局的挑战者越多，难度越高，可获得的累计奖金和创建奖金越丰厚。#l',
'   所有挑战用户首次过关残局，都可以获得一定金币作为奖励；街边残局支持红黑互换，和棋算胜。#l',
'   残局被通过之后，创建者可一次性获得丰厚的金币奖励。#l',
'   残局上架后会有7天的展示时间，过期会自动下架。#l',
'   关注感兴趣的残局后，在残局下架前都可在【我关注的】中查看和挑战。#l',
}

FindViewHelpDialog.ctor = function(self)
    super(self,find_view_help_dialog_view);
    self.bg = self.m_root:getChildByName("bg");
    self.closeBtn = self.bg:getChildByName("close_btn");
    self.closeBtn:setOnClick(self,self.dismiss);
    self.scrollView = self.bg:getChildByName("scroll_view");
    local str = table.concat(FindViewHelpDialog.CONTEXT);
    local w,h = self.scrollView:getSize();
    self.richText = new(RichText,str, w, h, kAlignTopLeft, fontName, 28, 80, 80, 80, true,10);
    self.scrollView:addChild(self.richText);
end

FindViewHelpDialog.dtor = function(self)
    
end
