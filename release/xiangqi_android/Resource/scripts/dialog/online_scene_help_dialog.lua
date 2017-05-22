require(VIEW_PATH .. "online_view_help_dialog_view");
require(BASE_PATH.."chessDialogScene");

OnlineSceneHelpDialog = class(ChessDialogScene,false);
OnlineSceneHelpDialog.CONTEXT = {
    '#s30#c87645F观战：#n#l   可围观专业二级以上（积分超过2000）用户的对局以及所关注的棋友的对局#l   观战中，对局双方用户左边为黑方，右边为红方#l   点击棋盘可以切换为全屏模式显示',
    '#l#s30#c87645F场次说明：#n',
    '   竞技场：底注#c197328%s#n金币，携带下限为#c197328%s#n金币，每局台费#c197328%s#n金币；本场次局时，步时，读秒根据象棋升级赛规则统一设置',
    '   新手场：底注#c197328%s#n金币，携带下限为#c197328%s#n金币，每局台费#c197328%s#n金币',
    '   中级场：底注#c197328%s#n金币，携带下限为#c197328%s#n金币，每局台费#c197328%s#n金币',
    '   大师场：底注#c197328%s#n金币，携带下限为#c197328%s#n金币，每局台费#c197328%s#n金币',
    '#l#s30#c87645F其他场次：#n',
    '   私人房：底注#c197328%s#n金币，携带下限为#c197328%s#n金币，每局台费#c197328%s#n金币',
    '   挑战好友：底注#c197328%s#n金币，携带下限为#c197328%s#n金币，每局台费#c197328%s#n金币',
    '   与好友对局和私人房对局不产生积分变化',
    ' #l#s30#c87645F设置说明：#n',
    '   局时：棋局中，以步时为走子时限的有效时间',
    '   步时：局时内开始的每步棋可用的走子时间',
    '   读秒：局时用完后每步棋可用的走子时间',
    '   若设置不读秒即一方局时结束后棋局结束',
    '   棋局中，首先进行“局时”与“步时”的计算。局时超时前，每步都必须在“步时”规定时间内完成走子，走下一步时，“步时”将重新计算。“局时”超时后，“局时”停止计算，每步都必须在“读秒”规定时间内完成走子。“步时”与“读秒”超时都会引起棋局结束，超时者判输。',
    '#l#s30#c87645F其他：#n#l   联网游戏悔棋和求和均需要对方同意。',
    '   联网对局或观战，可以在棋友信息中选择关注棋友或者屏蔽或取消屏蔽该棋友当局的聊天消息。',
    '   私人房可以邀请身边好友一起对局，也可以直接在聊天室向棋友发起挑战。',
    '   私人房对局和好友对局不产生积分变化。',
    '   棋局中可通过设置修改走子的操作方式。棋盘和棋子的显示样式可在我的个人装扮中修改。',
    '#l#s30#c87645F反作弊机制：#n',
    '   为了保证游戏的公平性，小雅会定期对竞技场的对局棋谱进行检测，涉嫌违规的用户会被暂时屏蔽成绩，并进行联系核实，核实成功的用户可以恢复奖励并获得棋力认证，还可获得月会员体验奖励。'
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
    local roomConfig        = RoomConfig.getInstance();
    local noviceData        = roomConfig:getRoomTypeConfig(RoomConfig.ROOM_TYPE_NOVICE_ROOM);
    local intermediateData  = roomConfig:getRoomTypeConfig(RoomConfig.ROOM_TYPE_INTERMEDIATE_ROOM);
    local masterData        = roomConfig:getRoomTypeConfig(RoomConfig.ROOM_TYPE_MASTER_ROOM);
    local arenaData         = roomConfig:getRoomTypeConfig(RoomConfig.ROOM_TYPE_ARENA_ROOM);
    local privateData       = roomConfig:getRoomTypeConfig(RoomConfig.ROOM_TYPE_PRIVATE_ROOM);
    local friendData         = roomConfig:getRoomTypeConfig(RoomConfig.ROOM_TYPE_FRIEND_ROOM);
    if noviceData then--新手场;
        OnlineSceneHelpDialog.CONTEXT[4] = string.format(OnlineSceneHelpDialog.CONTEXT[4],noviceData.money,noviceData.minmoney,noviceData.rent);
    end
    if intermediateData then--中级场;
        OnlineSceneHelpDialog.CONTEXT[5] = string.format(OnlineSceneHelpDialog.CONTEXT[5],intermediateData.money,intermediateData.minmoney,intermediateData.rent);
    end
    if masterData  then--大师场;
        OnlineSceneHelpDialog.CONTEXT[6] = string.format(OnlineSceneHelpDialog.CONTEXT[6],masterData.money,masterData.minmoney,masterData.rent);
    end
    if arenaData then--竞技场;
        OnlineSceneHelpDialog.CONTEXT[3] = string.format(OnlineSceneHelpDialog.CONTEXT[3],arenaData.money,arenaData.minmoney,arenaData.rent);
    end
    if privateData then--私人房;
        OnlineSceneHelpDialog.CONTEXT[8] = string.format(OnlineSceneHelpDialog.CONTEXT[8],privateData.money,privateData.minmoney,privateData.rent);
    end
    if friendData then--好友房;
        OnlineSceneHelpDialog.CONTEXT[9] = string.format(OnlineSceneHelpDialog.CONTEXT[9],friendData.money,friendData.minmoney,friendData.rent);
    end

    local context = ""
    for i,str in ipairs(OnlineSceneHelpDialog.CONTEXT) do
        context = context .. "#l" .. str;
    end
    self.richText = new(RichText,context,w, 0, kAlignTopLeft, nil, 28, 80, 80, 80, true,10);
    self.scrollView:addChild(self.richText);
    self:setShieldClick(self,self.dismiss);
end