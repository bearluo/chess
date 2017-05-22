-- Author: JsonPeng
-- Date:   2017-05-04
-- Last modification :  2017-05-04
-- Description: 比大小游戏界面弹窗
 require(VIEW_PATH.."thansize_dialog_view");
 require(BASE_PATH.."chessDialogScene");

ThanSizeDialog = class(ChessDialogScene,false);

ThanSizeDialog.readButton = 1;
ThanSizeDialog.blackButton =2;

ThanSizeDialog.mCuttrenClickButton = 3;
ThanSizeDialog.mCurrenSysButton =3; 
ThanSizeDialog.ChessType = {
    "B_CHESS_ZU",              
    "B_CHESS_PAO",
    "B_CHESS_MA",
    "B_CHESS_CHE",
    "B_CHESS_XIANG",
    "B_CHESS_SHI",
    "B_CHESS_KING",
}

ThanSizeDialog.ChessTypeToBlackSprit = {

    B_CHESS_SHI         = "bbishop.png",          --黑士
    B_CHESS_PAO			= "bcannon.png",          --黑炮
    B_CHESS_XIANG	    = "belephant.png",        --黑象
    B_CHESS_MA		    = "bhorse.png",           --黑马
    B_CHESS_KING		= "bking.png",            --黑将
    B_CHESS_ZU		    = "bpawn.png",            --黑卒
    B_CHESS_CHE			= "brook.png",            --黑车
}

ThanSizeDialog.ChessTypeToRedSprit = {

    B_CHESS_SHI         = "rbishop.png",         
    B_CHESS_PAO			= "rcannon.png",
    B_CHESS_XIANG		= "relephant.png",
    B_CHESS_MA		    = "rhorse.png",
    B_CHESS_KING	    = "rking.png",
    B_CHESS_ZU		    = "rpawn.png",
    B_CHESS_CHE			= "rrook.png",
}

ThanSizeDialog.ctor = function(self,temonlineRoomSceneNew)
    super(self,thansize_dialog_view);
    self:initView();
    self.m_onlineRoomSceneNew = temonlineRoomSceneNew;
end

ThanSizeDialog.initView = function (self)
    print_string("Thansize initView");
    self.m_button_enable = true;
    self.m_root_view = self.m_root;
    self.m_buttonred = self.m_root_view:getChildByName("bgview"):getChildByName("ButtonRed");
    self.m_buttonblack = self.m_root_view:getChildByName("bgview"):getChildByName("ButtonBlack");
    self.m_redcicle = self.m_root_view:getChildByName("bgview"):getChildByName("bgTexture"):getChildByName("redciclered");
    self.m_blackcicle = self.m_root_view:getChildByName("bgview"):getChildByName("bgTexture"):getChildByName("redcicleblack");
    self.m_redpiece = self.m_buttonred:getChildByName("piece");
    self.m_blackpiece = self.m_buttonblack:getChildByName("piece");
    self.m_result_he = self.m_root_view:getChildByName("bgview"):getChildByName("result"):getChildByName("he");
    self.m_result_fail = self.m_root_view:getChildByName("bgview"):getChildByName("result"):getChildByName("fail");
    self.m_result_win = self.m_root_view:getChildByName("bgview"):getChildByName("result"):getChildByName("win");
    self.m_root_view:getChildByName("bgview"):getChildByName("bgTexture"):getChildByName("bg"):setEventTouch(self,function() end)
    self.m_buttonred:setOnClick(self,self.redButtonClick);
    self.m_buttonblack:setOnClick(self,self.blackButtonClick);

    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self);
    self:setShieldClick(self,self.checkClose);
    self:recoverPiece();
end

ThanSizeDialog.show = function(self)
    self:setPickable(true)
    self:stopAllAnim();
--	self:setVisible(true);
    if not self.mRegister then
        self.mRegister = true
        OnlineSocketManagerProcesser.getInstance():register(THAN_SIZE_RESULT,self,self.onThanSizeResult);
        print_string("Thansize OnlineSocketManagerProcesser register");
    end 

    self.super.show(self);
end

ThanSizeDialog.checkClose = function(self)
    if self.m_button_enable == true  then 
        self:dismiss();
    end
end

ThanSizeDialog.redButtonClick = function (self)
    if self.m_button_enable == true  then 
        local info = {};

        info.uid = UserInfo.getInstance():getUid();
        info.level = RoomProxy.getInstance():getCurRoomLevel();
        info.side = 0; --左红右黑 ，左0，右1；
        info.from = UserInfo.getInstance():getSource();
        OnlineSocketManager.getHallInstance():sendMsg(THAN_SIZE_START,info);
        StatisticsManager.getInstance():onCountToUM(THANSIZEDIALOG_BTN_THAN_SIZE,info.side);
        print_string("Thansize send redButtonClick"..info.uid.."/"..info.level.."/"..info.side.."/"..info.from );
        ThanSizeDialog.mCuttrenClickButton = ThanSizeDialog.readButton;
        ThanSizeDialog.mCurrenSysButton = ThanSizeDialog.blackButton;
        self.m_redcicle:setVisible(true);
        self.m_button_enable = false;
    end

end

ThanSizeDialog.blackButtonClick = function (self)
    if self.m_button_enable == true  then 
        local info = {};

        info.uid = UserInfo.getInstance():getUid();
        info.level = RoomProxy.getInstance():getCurRoomLevel();
        info.side = 1; --左红右黑 ，左0，右1；
        info.from = UserInfo.getInstance():getSource();
        OnlineSocketManager.getHallInstance():sendMsg(THAN_SIZE_START,info);
        StatisticsManager.getInstance():onCountToUM(THANSIZEDIALOG_BTN_THAN_SIZE,info.side);
        print_string("Thansize send blackButtonClick"..info.uid.."/"..info.level.."/"..info.side.."/"..info.from );
        ThanSizeDialog.mCuttrenClickButton = ThanSizeDialog.blackButton;
        ThanSizeDialog.mCurrenSysButton = ThanSizeDialog.readButton;
        self.m_blackcicle:setVisible(true);
        self.m_button_enable = false;
    end
end

ThanSizeDialog.startFlipPieceAnim = function( self,buttonType,spriteName)
   
    self:stopFlipPieceAnim(buttonType);
    if buttonType == ThanSizeDialog.readButton then 
        print_string("Thansize startFlipPieceAnim readButton");
        self.m_buttonred:removeProp(1);
        self.m_buttonred:removeProp(2);
        self.mFlipAnimRed = self.m_buttonred:addPropScale(1, kAnimNormal, 500, -1, 1, 0, 1, 1, kCenterDrawing);
        self.mFlipAnimRed:setEvent(nil ,function()
            self.m_redpiece:setVisible(true);
            self.m_redpiece:setFile(boardres_map[spriteName]);
            self.m_buttonred:removeProp(1);
            delete(self.mFlipAnimRed);
            self.mFlipAnimRed = nil;

            self.mFlipAnimRedAction = self.m_buttonred:addPropScale(2, kAnimNormal, 500, -1, 0, 1, 1, 1, kCenterDrawing);
            self.mFlipAnimRedAction:setEvent(nil ,function()
                if self.m_buttonred then 
                    self.m_buttonred:removeProp(2);
                    delete( self.mFlipAnimRedAction);
                    self.mFlipAnimRedAction = nil;
                end
            end)
        end);
    end
    if buttonType == ThanSizeDialog.blackButton then
        print_string("Thansize startFlipPieceAnim blackButton");
        self.m_buttonblack:removeProp(3);
        self.m_buttonblack:removeProp(4);
        self.mFlipAnimBlack = self.m_buttonblack:addPropScale(3, kAnimNormal, 500, -1, 1, 0, 1, 1, kCenterDrawing);
        self.mFlipAnimBlack:setEvent(nil ,function()
            self.m_blackpiece:setVisible(true);
            self.m_blackpiece:setFile(boardres_map[spriteName]);
            self.m_buttonblack:removeProp(3);
            delete(self.mFlipAnimBlack);
            self.mFlipAnimBlack = nil;

            self.mFlipAnimBlackAction = self.m_buttonblack:addPropScale(4, kAnimNormal, 500, -1, 0, 1, 1, 1, kCenterDrawing);
            self.mFlipAnimBlackAction:setEvent(nil ,function()
                if self.m_buttonblack then 
                     self.m_buttonblack:removeProp(4);
                     delete(self.mFlipAnimBlackAction );
                     self.mFlipAnimBlackAction = nil;
                end 
            end)
        end);
    end
end

ThanSizeDialog.stopFlipPieceAnim = function(self,animType)
    if not self.mFlipAnimRed then 
        delete(self.mFlipAnimRed);
        self.mFlipAnimRed = nil;
    end 

    if not self.mFlipAnimBlack then 
        delete(self.mFlipAnimBlack);
        self.mFlipAnimBlack = nil;
    end 
end

ThanSizeDialog.dismiss = function(self)
    self:setPickable(false)
    self.super.dismiss(self, self.mDialogAnim.dismissAnim);
    self:recoverPiece();
    self:stopAllAnim();
    if self.mRegister then
        self.mRegister = false
        OnlineSocketManagerProcesser.getInstance():unregister(THAN_SIZE_RESULT,self,self.onThanSizeResult);
        print_string("Thansize OnlineSocketManagerProcesser unregister");
    end 
end

ThanSizeDialog.recoverPiece = function(self)
    self.m_redpiece:setVisible(false);
    self.m_blackpiece:setVisible(false);
    self.m_result_win:setVisible(false);
    self.m_result_fail:setVisible(false);
    self.m_result_he:setVisible(false);
    self.m_redcicle:setVisible(false);
    self.m_blackcicle:setVisible(false);
    self.m_button_enable = true;
    print_string("Thansize recoverPiece");
end

ThanSizeDialog.onThanSizeResult = function(self,data)
    local uid       = data.uid:get_value();                          --用户id
    local result    = data.result:get_value();                       --输赢结果,1:玩家赢，2：玩家输， 3：平局， 4：金币不足或其他原因导致的不能玩小游戏 
    local side      = data.side:get_value();                         --用户选择的边
    local userchess = data.userchess:get_value();                    --用户棋子
    local syschess  = data.syschess:get_value();                     --系统棋子
    local chip      = data.chip:get_value();                         --下注金额
    self.leftmoney = data.money:get_value();                        --剩余金币
    print_string("Thansize onThanSizeResult");
    if result == 4 then 
        ChessToastManager.getInstance():showSingle("您的资产不足，无法进行此游戏");
        self.m_redcicle:setVisible(false);
        self.m_blackcicle:setVisible(false);
        self.m_button_enable = true;
        return;
    end 
    self:flipPieceFromeResult(uid,result,side,userchess,syschess,chip);
end

ThanSizeDialog.flipPieceFromeResult = function(self,uid,result,side,userchess,syschess,chip)
    if uid and uid == UserInfo.getInstance():getUid() then
        local spriteNameUser ;
        local spriteNameSys;
        
        if side == 0 then 
            spriteNameUser = ThanSizeDialog.ChessTypeToRedSprit[ThanSizeDialog.ChessType[userchess]];
            spriteNameSys  = ThanSizeDialog.ChessTypeToBlackSprit[ThanSizeDialog.ChessType[syschess]];
        elseif side == 1 then 
            spriteNameUser = ThanSizeDialog.ChessTypeToBlackSprit[ThanSizeDialog.ChessType[userchess]];
            spriteNameSys  = ThanSizeDialog.ChessTypeToRedSprit[ThanSizeDialog.ChessType[syschess]];
        end
        self:startFlipPieceAnim(ThanSizeDialog.mCuttrenClickButton,spriteNameUser);
        self:startFlipPieceAnim(ThanSizeDialog.mCurrenSysButton,spriteNameSys);
        
        self.m_moveAnimAction = AnimFactory.createAnimInt(kAnimNormal, 0, 1, 2000, -1);
        self.m_moveAnimAction:setEvent(self,function()
            self:showWinOrFail(result,chip);
            delete(self.m_moveAnimAction);
            self.m_moveAnimAction = nil;
        end );
        print_string("Thansize flipPieceFromeResult");
    end
end

--输赢结果,1:玩家赢，2：玩家输， 3：平局， 4：金币不足或其他原因导致的不能玩小游戏
ThanSizeDialog.showWinOrFail = function(self,result,gold)
    if not result then return end ;
    if result == 1 then 
        self.m_result_win:setVisible(true);
        self.m_result_win:getChildByName("gold"):setText("+"..gold);
    elseif result == 2 then
        self.m_result_fail:setVisible(true);
        self.m_result_fail:getChildByName("gold"):setText("-"..gold);
    elseif result == 3 then 
        self.m_result_he:setVisible(true);
    else 
        
    end
    OnlineRoomSceneNew.s_cmdConfig[OnlineRoomSceneNew.s_cmds.thanSizeGameReturn]( self.m_onlineRoomSceneNew,self.leftmoney);
    self.m_moveAnim = AnimFactory.createAnimInt(kAnimNormal, 0, 1, 2000, -1);
    self.m_moveAnim:setEvent(self,
        function()
            self:recoverPiece();
            delete(self.m_moveAnim);
            self.m_moveAnim = nil;
            self:isHasTurnToPlayChess();
        end
    );
end

ThanSizeDialog.stopAllAnim = function (self)
    if not self.m_moveAnim then 
        delete(self.m_moveAnim);
        self.m_moveAnim = nil;
    end 

    if not self.m_moveAnimAction then 
        delete(self.m_moveAnimAction);
        self.m_moveAnimAction = nil;
    end 

     if not self.mFlipAnimRed then 
        delete(self.mFlipAnimRed);
        self.mFlipAnimRed = nil;
    end 

    if not self.mFlipAnimRedAction then 
        delete(self.mFlipAnimRedAction);
        self.mFlipAnimRedAction = nil;
    end 

    if not self.mFlipAnimBlack then 
        delete(self.mFlipAnimBlack);
        self.mFlipAnimBlack = nil;
    end 

    if not self.mFlipAnimBlackAction then 
        delete(self.mFlipAnimBlackAction);
        self.mFlipAnimBlackAction = nil;
    end 

    if not self.mDialogAnim then 
        delete(self.mDialogAnim);
        self.mDialogAnim = nil;
    end 

end

ThanSizeDialog.turnToOwnPlayChess = function (self)
    self.turnToOwnPlayChessBool = true;
    self:checkClose();
end

ThanSizeDialog.isHasTurnToPlayChess = function (self)
    if self.turnToOwnPlayChessBool then 
        self:checkClose();
        self.turnToOwnPlayChessBool = false;
    else 
    end 
end
