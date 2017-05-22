require(VIEW_PATH.."play_create_ending_result_dialog_view");
require(BASE_PATH.."chessDialogScene")
require("util/drawingPack");
PlayCreateEndingResultDialog = class(ChessDialogScene,false);
PlayCreateEndingResultDialog.MODE_SURE = 1;
PlayCreateEndingResultDialog.MODE_NOR  = 2;


PlayCreateEndingResultDialog.ctor = function(self)
	super(self,play_create_ending_result_dialog_view);

    self.m_collection_btn = self.m_root:getChildByName("collection_btn");
    self.m_collection_btn:setOnClick(self,self.collection);
    self.m_follow_btn = self.m_root:getChildByName("follow_btn");
    self.m_follow_btn:setOnClick(self,self.follow);
    
    self.m_close_btn = self.m_root:getChildByName("close_btn");
    self.m_title_anim_view = self.m_root:getChildByName("title_anim_view");
    
    self.m_board_view = self.m_root:getChildByName("board_view");
    self.m_win_view = self.m_root:getChildByName("win_view");
    self.m_win_view:setVisible(false);
    self.m_lose_view = self.m_root:getChildByName("lose_view");
    self.m_lose_view:setVisible(false);
    self.m_close_btn = self.m_root:getChildByName("close_btn");
    self.m_close_btn:setOnClick(self,self.dismiss);
   
    self.m_bottom_btn_view = self.m_root:getChildByName("bottom_btn_view");
    self.m_btn_1 = self.m_bottom_btn_view:getChildByName("btn_1");
    self.m_btn_2 = self.m_bottom_btn_view:getChildByName("btn_2");
    self.m_btn_3 = self.m_bottom_btn_view:getChildByName("btn_3");
    self.m_btn_1:setVisible(false);
    self.m_btn_2:setVisible(false);
    self.m_btn_3:setVisible(false);
    
	self.m_btn_1:setOnClick(self,self.cancel);
	self.m_btn_2:setOnClick(self,self.sure);
	self.m_btn_3:setOnClick(self,self.sure);

    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)
end

PlayCreateEndingResultDialog.dtor = function(self)
    self.mDialogAnim.stopAnim()
    self:blurBehind(false);
    delete(self.m_win_anim_view);
    delete(self.m_lose_anim_view);
end

PlayCreateEndingResultDialog.setBoradView = function(self,view)
    local borad = drawingShot(view);
    borad:setPos(0,0);
    borad:setAlign(kAlignTopLeft);
    self.m_board_view:removeAllChildren();
    self.m_board_view:addChild(borad)
    local w,h = borad:getSize();
    local pw,ph = self.m_board_view:getSize();
    borad:addPropScaleSolid(100,pw/w,ph/h,kCenterXY,0,0); 
end

PlayCreateEndingResultDialog.setWinText = function(self,info1,info2,info3)
    self.m_lose_view:setVisible(false);
    self.m_win_view:setVisible(true);
    self.m_win_view:getChildByName("info_1"):setText(info1);
    self.m_win_view:getChildByName("info_2"):setText(info2);
    self.m_win_view:getChildByName("info_3"):setText(info3);
end

PlayCreateEndingResultDialog.setLoseText = function(self)
    self.m_lose_view:setVisible(true);
    self.m_win_view:setVisible(false);
end

PlayCreateEndingResultDialog.setMode = function(self,mode,str1,str2)
    if PlayCreateEndingResultDialog.MODE_SURE == mode then
        self.m_btn_1:setVisible(false);
        self.m_btn_2:setVisible(false);
        self.m_btn_3:setVisible(true);
        self.m_btn_3:getChildByName("text"):setText(str1 or "确定");
    elseif PlayCreateEndingResultDialog.MODE_NOR == mode then
        self.m_btn_1:setVisible(true);
        self.m_btn_1:getChildByName("text"):setText(str1 or "取消");
        self.m_btn_2:setVisible(true);
        self.m_btn_2:getChildByName("text"):setText(str2 or "确定");
        self.m_btn_3:setVisible(false);
    end
end

PlayCreateEndingResultDialog.cancel = function(self)
	print_string("ChioceDialog.cancel ");
	if self.m_negObj and self.m_negFunc then
		self.m_negFunc(self.m_negObj);
    else
        self:dismiss();
	end
end

PlayCreateEndingResultDialog.sure = function(self)
	print_string("ChioceDialog.sure ");
	if self.m_posObj and self.m_posFunc then
		self.m_posFunc(self.m_posObj,self.m_posArg);
    else
        self:dismiss();
	end
end

PlayCreateEndingResultDialog.collection = function(self)
    if self.m_col_obj and self.m_col_func then
        self.m_col_func(self.m_col_obj);
    end
end

PlayCreateEndingResultDialog.follow = function(self)
    if self.m_fol_obj and self.m_fol_func then
        self.m_fol_func(self.m_fol_obj);
    end
end

PlayCreateEndingResultDialog.setPositiveListener = function(self,obj,func)
	self.m_posObj = obj;
	self.m_posFunc = func;
end


PlayCreateEndingResultDialog.setNegativeListener = function(self,obj,func)
	self.m_negObj = obj;
	self.m_negFunc = func;
end

PlayCreateEndingResultDialog.setCollectionListener = function(self,obj,func)
	self.m_col_obj = obj;
	self.m_col_func = func;
end

PlayCreateEndingResultDialog.setFollowListener = function(self,obj,func)
	self.m_fol_obj = obj;
	self.m_fol_func = func;
end

function PlayCreateEndingResultDialog.updateFollowIcon(self,isFollow)
    if isFollow then
        self.m_follow_btn:setFile("common/button/follow_btn_press.png");
    else
        self.m_follow_btn:setFile("common/button/follow_btn_nor.png");
    end
end

PlayCreateEndingResultDialog.isShowing = function(self)
	return self:getVisible();
end

PlayCreateEndingResultDialog.show = function(self,isWin,isFollow)
    -- 虚化房间背景
    self:blurBehind(true);
    
    self:updateFollowIcon(isFollow);

    if isWin then
        if not self.m_win_anim_view then
            self.m_win_anim_view = new(AnimWin);
            self.m_win_anim_view:setAlign(kAlignTop);
        end
        self:setTitleAnimView(self.m_win_anim_view);
    else
        if not self.m_lose_anim_view then
            self.m_lose_anim_view = new(AnimLose);
            self.m_lose_anim_view:setAlign(kAlignTop);
        end
        self:setTitleAnimView(self.m_lose_anim_view);
    end
    if self.m_title_anim and self.m_title_anim.play then
        self.m_title_anim:play(self.m_title_anim_view);
        self.m_title_anim:setVisible(true);
    end
	self:setVisible(true);
    self.super.show(self,self.mDialogAnim.showAnim);
end

PlayCreateEndingResultDialog.setTitleAnimView = function(self,animView)
    self.m_title_anim_view:removeAllChildren(true);
    self.m_title_anim = animView;
end

-- 是否虚化房间背景
PlayCreateEndingResultDialog.blurBehind = function(self, isBlur)
    local controller;
    local View;
    controller = StateMachine.getInstance():getCurrentController();
    if not controller then return end;
    view = controller:getRootView();
    if not view or not view:getID() then return end;

    if isBlur then
        local drawing = view:packDrawing(true);
        self.m_bg_pack_drawing = drawing;
        local blur = require("libEffect/shaders/blur");
        blur.applyToDrawing(drawing,1);
    else
        local common = require("libEffect/shaders/common");
        common.removeEffect(self.m_bg_pack_drawing);
        view:packDrawing(false);
        self.m_bg_pack_drawing = nil;
    end
end

PlayCreateEndingResultDialog.dismiss = function(self)
	print_string("PlayCreateEndingResultDialog dismiss");
    self:blurBehind(false);
    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
    self:setVisible(false);
    if self.m_win_anim_view then
        self.m_win_anim_view:setVisible(false);
    end
    if self.m_lose_anim_view then
        self.m_lose_anim_view:setVisible(false);
    end
end