require(VIEW_PATH.."find_view_endgate_list_item");

EndgateListItem = class(Node)

require(MODEL_PATH .. "room/board");
EndgateListItem.ctor = function(self,data)
    self.root = SceneLoader.load(find_view_endgate_list_item);
    self:addChild(self.root);
    local w,h = self.root:getSize();
    self:setSize(w,h);
    self.data = data;

    self.headView = self.root:getChildByName("head_view");
    self.name = self.root:getChildByName("name");
    self.time = self.root:getChildByName("time");
    self.collectionNum = self.root:getChildByName("collection_num");
    self.challengBtn = self.root:getChildByName("challeng_btn");
    self.endgateName = self.root:getChildByName("endgate_name");
    self.jackpotNum = self.root:getChildByName("jackpot_num");
    self.challengNum = self.root:getChildByName("challeng_num");
    self.passText = self.root:getChildByName("pass_text");

    local w,h = self.headView:getSize();
    self.headIcon = new(Mask,UserInfo.DEFAULT_ICON[1],"common/background/head_mask_bg_86.png")
    self.headIcon:setSize(w,h);
    if data.icon_type == -1 and data.icon_url ~= nil then
        self.headIcon:setUrlImage(data.icon_url);
	else
        if not data.icon_type or data.icon_type <= 0 or data.icon_type>4 then
            data.icon_type = 1;
        end
		self.headIcon:setFile(UserInfo.DEFAULT_ICON[data.icon_type]);
    end
    self.headView:addChild(self.headIcon);

    local name = data.mnick or "";
    self.name:setText(name);
    local time = tonumber(data.add_time) or 0;
    local timeStr = os.date("%Y-%m-%d %H:%M:%S",time);
    self.time:setText(timeStr);
    local collectionNum = tonumber(data.collect_num) or 0;
    self.collectionNum:setText(collectionNum);
    local jackpotNum = tonumber(data.prize_pool) or 0;
    self.jackpotNum:setText("累计奖金: " .. jackpotNum);
    local challengNum = ( tonumber(data.play_num) or 0 ) + ( tonumber(data.black_play_num) or 0 );
    self.challengNum:setText("累计挑战: " .. challengNum);
    local boothTitle = data.booth_title or "";
    self.endgateName:setText(boothTitle);
    self.chessGroup = self.root:getChildByName("board"):getChildByName("chess_group");
    local boardW,boardH = self.chessGroup:getSize();
    -- chess_board
    if data.booth_fen then
        self.m_board = new(Board,boardW,boardH,self);
        Board.resetFenPiece();
        local chess_map = self.m_board:fen2chessMap(data.booth_fen);
        self.m_board:copyChess90(chess_map);
        self.m_board:setPickable(false);
        self.chessGroup:addChild(self.m_board);
    end

    self.challengBtn:setOnClick(self,self.gotoChalleng);
    self.chessGroup:setOnClick(self,self.gotoChalleng);
    self.challengBtn:setSrollOnClick();
    self.chessGroup:setSrollOnClick();
end

EndgateListItem.gotoChalleng = function(self)
    kEndgateData:setPlayCreateEndingData(self.data);
    StateMachine.getInstance():pushState(States.playCreateEndgate,StateMachine.STYPE_CUSTOM_WAIT);
end