require(VIEW_PATH .. "online_view_help_dialog_view");
require(BASE_PATH.."chessDialogScene");

OnlineSceneHelpDialog = class(ChessDialogScene,false);
OnlineSceneHelpDialog.CONTEXT = {
    ' #l#s36#c87645F观战：#n#l可围观专业二级以上（积分超过2000）用户的对局以及所关注的棋友的对局#l观战中，对局双方用户左边为黑方，右边为红方点击棋盘可以满屏显示战况',
    ' #l#s36#c87645F场次说明：#n',
    '新手场：底注#c197328%s#n金币，携带下限为#c197328%s#n金币，每局台费#c197328%s#n金币',
    '中级场：底注#c197328%s#n金币，携带下限为#c197328%s#n金币，每局台费#c197328%s#n金币',
    '大师场：底注#c197328%s#n金币，携带下限为#c197328%s#n金币，每局台费#c197328%s#n金币',
    '私人房：底注#c197328%s#n金币，携带下限为#c197328%s#n金币，每局台费#c197328%s#n金币',
    '挑战好友：底注#c197328%s#n金币，携带下限为#c197328%s#n金币，每局台费#c197328%s#n金币',
    ' #l#s36#c87645F设置说明：#n',
    '局时：棋局中，以步时为走子时限的有效时间',
    '步时：局时内开始的每步棋可用的走子时间',
    '读秒：局时用完后每步棋可用的走子时间',
    '   若设置不读秒即一方局时结束后棋局结束',
    ' #l  棋局中，首先进行“局时”与“步时”的计算。局时超时前，每步都必须在“步时”规定时间内完成走子，走下一步时，“步时”将重新计算。“局时”超时后，“局时”停止计算，每步都必须在“读秒”规定时间内完成走子。“步时”与“读秒”超时都会引起棋局结束，超时者判输。',
    ' #l#s36#c87645F其他：#n#l联网游戏悔棋和求和均需要对方同意',
}
function OnlineSceneHelpDialog:ctor()
    super(self,online_view_help_dialog_view);
    self.bg = self.m_root:getChildByName("bg");
    self.bg:setEventDrag(self,function()end);
    self.bg:setEventTouch(self,function()end);
    self.closeBtn = self.bg:getChildByName("close_btn");
    self.closeBtn:setOnClick(self,self.dismiss);
    self.scrollView = self.bg:getChildByName("scroll_view");
    self.scrollView.m_autoPositionChildren = true;
    local w,h = self.scrollView:getSize();
    local data = UserInfo.getInstance():getRoomConfig();
    if data then
        for i=1,5 do
            if data[i] then
                local index = i+2;
                OnlineSceneHelpDialog.CONTEXT[index] = string.format(OnlineSceneHelpDialog.CONTEXT[index],data[i].money,data[i].minmoney,data[i].rent);
            end
        end
    end
    local context = ""
    for i,str in ipairs(OnlineSceneHelpDialog.CONTEXT) do
        context = context .. "#l" .. str;
    end
    self.richText = new(RichText,context,w, 0, kAlignTopLeft, nil, 26, 80, 80, 80, true,5);
    self.scrollView:addChild(self.richText);
    self:setShieldClick(self,self.dismiss);
end