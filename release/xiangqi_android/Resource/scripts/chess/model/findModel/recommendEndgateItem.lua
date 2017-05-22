require(VIEW_PATH.."find_view_recommend_endgate_item");
require(MODEL_PATH .. "room/board");

RecommendEndgateItem = class(Node)

RecommendEndgateItem.ctor = function(self,data)
    self.root = SceneLoader.load(find_view_recommend_endgate_item);
    self:addChild(self.root);
    local w,h = self.root:getSize();
    self:setSize(w,h);
    self.data = data;

    self.m_contentView = self.root:getChildByName("content_view");
    -- 初始化棋盘
    self.chessGroup = self.m_contentView:getChildByName("board_bg"):getChildByName("chess_view");
    local boardW,boardH = self.chessGroup:getSize();
    -- chess_board
    if data.start_fen then
        self.m_board = new(Board,boardW,boardH,self);
        Board.resetFenPiece();
        local chess_map = self.m_board:fen2chessMap(data.start_fen);
        self.m_board:copyChess90(chess_map);
        self.m_board:setPickable(false);
        self.chessGroup:addChild(self.m_board);
    end

    self.chessGroup:setOnClick(self,self.gotoReplay);
    self.chessGroup:setSrollOnClick();
    -- red_view
    self.m_redView = self.m_contentView:getChildByName("red_view");
    self.m_redHeadIcon = self:getHeadIcon(self.m_redView:getChildByName("head_view"),self.data.red_icon_type,self.data.red_icon_url);
    self.m_redName = self.m_redView:getChildByName("name");
    self.m_redName:setText(self.data.red_mnick or "博雅象棋");
    self.m_redScore = self.m_redView:getChildByName("score");
    self.m_redScore:setText("积分:" .. (self.data.red_score or "") );
    self.m_redLevelIcon = self.m_redView:getChildByName("level_icon");
    self.m_redLevelIcon:setFile("common/icon/big_level_" .. (self.data.red_level or 1) .. ".png");
    -- black_view 
    self.m_blackView = self.m_contentView:getChildByName("black_view");
    self.m_blackHeadIcon = self:getHeadIcon(self.m_blackView:getChildByName("head_view"),self.data.black_icon_type,self.data.black_icon_url);
    self.m_blackName = self.m_blackView:getChildByName("name");
    self.m_blackName:setText(self.data.black_mnick or "博雅象棋");
    self.m_blackScore = self.m_blackView:getChildByName("score");
    self.m_blackScore:setText("积分:" .. (self.data.black_score or "") );
    self.m_blackLevelIcon = self.m_blackView:getChildByName("level_icon");
    self.m_blackLevelIcon:setFile("common/icon/big_level_" .. (self.data.black_level or 1) .. ".png" );

    
    self.m_shareBtn = self.root:getChildByName("bottom_view"):getChildByName("share_btn");
    self.m_collectionBtn = self.root:getChildByName("bottom_view"):getChildByName("collection_btn");
    self.m_commentBtn = self.root:getChildByName("bottom_view"):getChildByName("comment_btn");

    self.m_shareBtn:setOnClick(self,self.onShare);
    self.m_shareBtn:setSrollOnClick();
    self.m_collectionBtn:setOnClick(self,self.onCollection);
    self.m_collectionBtn:setSrollOnClick();
    self.m_commentBtn:setOnClick(self,self.gotoComment);
    self.m_commentBtn:setSrollOnClick();

    self:initSuggestChessState();
end

RecommendEndgateItem.getHeadIcon = function(self,headView,iconType,icon_url)
    local w,h = headView:getSize();
    headIcon = new(Mask,UserInfo.DEFAULT_ICON[1],"common/background/head_mask_bg_86.png")
    headIcon:setSize(w,h);
    if iconType == -1 and icon_url ~= nil then
        headIcon:setUrlImage(icon_url);
	else
        if not iconType or iconType <= 0 or iconType>4 then
            iconType = 1;
        end
		headIcon:setFile(UserInfo.DEFAULT_ICON[iconType]);
    end
    headView:addChild(headIcon);
    return headIcon;
end

RecommendEndgateItem.gotoReplay = function(self)
    UserInfo.getInstance():setDapuSelData(self.data);
    StateMachine:getInstance():pushState(States.ReplayRoom,StateMachine.STYPE_CUSTOM_WAIT);
end

RecommendEndgateItem.onShare = function(self)
--    require(BASE_PATH.."chessShareManager");
    local manualData = {};
    manualData.red_mid = self.data.red_mid or "0";       --红方uid
    manualData.black_mid = self.data.black_mid or "0";    --黑方uid
    manualData.win_flag = self.data.win_flag or "1";        --胜利方（1红胜，2黑胜，3平局）
    manualData.manual_type = self.data.manual_type or "1";     --棋谱类型，1联网游戏，2残局，3单机游戏，4用户打谱
    manualData.end_type = self.data.m_game_end_type or self.data.end_type or "1";    --棋盘开局
    manualData.start_fen = self.data.fenStr or self.data.start_fen;    -- 棋盘开局
    manualData.move_list = self.data.mvStr or self.data.move_list;     -- 走法，json字符串
    manualData.manual_id = self.data.manual_id;       -- 保存的棋谱id
    manualData.mid = self.data.mid;                   -- mid     
    manualData.h5_developUrl = PhpConfig.h5_developUrl;  
    manualData.title = self:getShareTitle() or "复盘演练（博雅中国象棋）";
    manualData.description = self:getShareTime() or "复盘让您回顾精彩对局"; 
    local url = require("libs/url");
    local u = url.parse(manualData.h5_developUrl);
    local params = {}
    params.manual_id = manualData.manual_id
    u:addQuery(params);
    manualData.url =  u:build()
    if type(self.shareClickFunc) == "function" then
        self.shareClickFunc(self.shareClickObj,manualData);
    end
end

RecommendEndgateItem.getShareTitle = function(self)
    local title = nil;
    if self.data then
        if self.data.win_flag then
            local redName = nil;
            local blackName = nil;
            local redId = self.data.red_mid or "博雅象棋";
            local idLen = string.lenutf8(GameString.convert2UTF8(redId) or "");
            if idLen > 4 then
                redId = string.subutf8(redId,1,4).."...";
            end;
            local blackId = self.data.black_mid or "博雅象棋"
            idLen = string.lenutf8(GameString.convert2UTF8(blackId) or "");
            if idLen > 4 then
                blackId = string.subutf8(blackId,1,4).."...";
            end;
            if self.data.red_mnick then
                redName = self.data.red_mnick;
                local len = string.lenutf8(GameString.convert2UTF8(redName) or "");
                if len > 4 then
                    redName = string.subutf8(redName,1,4).."...";
                end;
            end;
            if self.data.black_mnick then
                blackName = self.data.black_mnick;
                local len = string.lenutf8(GameString.convert2UTF8(blackName) or "");
                if len > 4 then
                    blackName = string.subutf8(blackName,1,4).."...";
                end;
            end;
            if tonumber(self.data.win_flag) == 1 then
                title = "【"..(User.QILI_LEVEL[self.data.red_level] or "九级").."】"..(redName or redId).." 胜 "
                        .."【"..(User.QILI_LEVEL[self.data.black_level] or "九级").."】"..(blackName or blackId);
            elseif tonumber(self.data.win_flag) == 2 then
                title = "【"..(User.QILI_LEVEL[self.data.black_level] or "九级").."】"..(blackName or blackId).." 胜 "
                        .."【"..(User.QILI_LEVEL[nil] or "九级").."】"..(redName or redId);                
            else
                title = "【"..(User.QILI_LEVEL[self.data.red_level] or "九级").."】"..(redName or redId).." 平 "
                        .."【"..(User.QILI_LEVEL[self.data.black_level] or "九级").."】"..(blackName or blackId);  
            end;
        end;
    end;
    return title;
end;



RecommendEndgateItem.getShareTime = function(self)
    local addTime = nil;
    if self.data then
        if self.data.add_time then
            addTime = "对局时间："..os.date("%Y/%m/%d %H:%M",self.data.add_time);
        end;
    end;
    return addTime;
end;

RecommendEndgateItem.setShareBtnClick = function(self,obj,func)
    self.shareClickObj = obj;
    self.shareClickFunc = func;
end

RecommendEndgateItem.setCollectionClick = function(self,obj,func)
    self.collectionClickObj = obj;
    self.collectionClickFunc = func;
end

RecommendEndgateItem.onCollection = function(self)
    if type(self.collectionClickFunc) == "function" then
        self.collectionClickFunc(self.collectionClickObj,self);
    end
end

RecommendEndgateItem.gotoComment = function(self)
    if UserInfo.getInstance():isFreezeUser() then return end;
    UserInfo.getInstance():setDapuSelData(self.data);
    StateMachine.getInstance():pushState(States.Comment,StateMachine.STYPE_CUSTOM_WAIT);
end

RecommendEndgateItem.initSuggestChessState = function(self)
    if self.data.is_collect then
        -- 1已收藏，0未收藏
        if tonumber(self.data.is_collect) == 1 then 
            self.m_collectionBtn:getChildByName("text_img"):setFile("replay/has_save.png");     
            self.m_collectionBtn:setEnable(false);            
        elseif tonumber(self.data.is_collect) == 0 then
            self.m_collectionBtn:getChildByName("text_img"):setFile("replay/save.png");
            self.m_collectionBtn:setEnable(true);
        end;
    end;
end;

RecommendEndgateItem.setSuggestIsCollect = function(self)
   if tonumber(self.data.is_collect) == 0 then
        self.data.is_collect = 1;
   else
        self.data.collect_type = 0;
   end    
   self:initSuggestChessState();
end

RecommendEndgateItem.getData = function(self)
    return self.data;
end