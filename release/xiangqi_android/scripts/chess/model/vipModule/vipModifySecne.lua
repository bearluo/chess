require(BASE_PATH.."chessScene");
require(DATA_PATH.."userSetInfo");
require("dialog/vip_prompt_dialog");

VipModifyScene = class(ChessScene);

VipModifyScene.s_controls = 
{
    back_btn                    = 1;
    select_board                = 2;
    select_head_frame           = 3;
    select_chess_piece          = 4;
}

VipModifyScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = VipModifyScene.s_controls;
    self:create();
end 

VipModifyScene.resume = function(self)
    ChessScene.resume(self);
    self:updataList(self.m_ListView);
end


VipModifyScene.pause = function(self)
	ChessScene.pause(self);
    self:removeAnimProp();

end 

VipModifyScene.dtor = function(self)
    delete(self.m_vip_prompt);
    delete(self.anim_start);
    delete(self.anim_end);
end 

VipModifyScene.removeAnimProp = function(self)

    if self.m_anim_prop_need_remove then
        self.m_title_icon:removeProp(1);
        self.m_leaf_left:removeProp(1);
        self.m_anim_prop_need_remove = false;
    end
end

VipModifyScene.setAnimItemEnVisible = function(self,ret)
    self.m_leaf_left:setVisible(ret);
end

VipModifyScene.resumeAnimStart = function(self,lastStateObj,timer)
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;
    delete(self.anim_start);
    self.anim_start = new(AnimInt,kAnimNormal,0,1,delay,-1);
    if self.anim_start then
        self.anim_start:setEvent(self,function()
            self:setAnimItemEnVisible(true);
            delete(self.anim_start);
        end);
    end

    local lw,lh = self.m_leaf_left:getSize();
    self.m_leaf_left:addPropTranslate(1, kAnimNormal, waitTime, delay, -lw, 0, -10, 0);
    local tw,th = self.m_title_icon:getSize();
    local anim = self.m_title_icon:addPropTranslate(1, kAnimNormal, waitTime, delay, 0, 0, -th, 0);
    if anim then
        anim:setEvent(self,function()
            self.m_anim_prop_need_remove = true;
            self:removeAnimProp();
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end  
        end);   
    end

end

VipModifyScene.pauseAnimStart = function(self,newStateObj,timer)
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;
    delete(self.anim_end);
    self.anim_end = new(AnimInt,kAnimNormal,0,1,delay,-1);
    if self.anim_end then
        self.anim_end:setEvent(self,function()
            self.m_anim_prop_need_remove = true;
            self:removeAnimProp();
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end  
            delete(self.anim_end);
        end);
    end

    local lw,lh = self.m_leaf_left:getSize();
    self.m_leaf_left:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, -lw, 0, -10);
    local w,h = self.m_title_icon:getSize();
    local anim = self.m_title_icon:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, 0, 0, -h);
    if anim then
        anim:setEvent(self,function()
            self:setAnimItemEnVisible(false);
        end);
    end
end

VipModifyScene.create = function(self)
    self.m_root_view = self.m_root;
    self.m_back_btn  = self:findViewById(self.m_ctrls.back_btn);
    self.m_leaf_left = self.m_root:getChildByName("Image1");
    self.m_title_icon = self.m_root_view:getChildByName("Image2");


    self.m_setBoardView = self:findViewById(self.m_ctrls.select_board);
    self.m_setHeadFrameView = self:findViewById(self.m_ctrls.select_head_frame);
    self.m_setChessPieceView = self:findViewById(self.m_ctrls.select_chess_piece);
    local bw,bh = self.m_setBoardView:getSize();
    local hw,hh = self.m_setHeadFrameView:getSize();
    local cw,ch = self.m_setChessPieceView:getSize();

    self.m_ListView = UserSetInfo.getInstance():getAllSelectRes();

    self.m_setBoardList = new(ScrollView,0,0,bw,bh,true);
    self.m_setBoardList:setAlign(kAlignCenter);
    self.m_setBoardList:setDirection(kHorizontal);
    self.m_setBoardView:addChild(self.m_setBoardList);

    self.m_setHeadList = new(ScrollView,0,0,hw,hh,true);
    self.m_setHeadList:setAlign(kAlignCenter);
    self.m_setHeadList:setDirection(kHorizontal);
    self.m_setHeadFrameView:addChild(self.m_setHeadList);

    self.m_setChessList = new(ScrollView,0,0,cw,ch,true);
    self.m_setChessList:setAlign(kAlignCenter);
    self.m_setChessList:setDirection(kHorizontal);
    self.m_setChessPieceView:addChild(self.m_setChessList);

--    UserSetInfo.getInstance():updataSelectData();
end

VipModifyScene.onBackAction = function(self)
    self:requestCtrlCmd(VipModifyController.s_cmds.onBack);
end

VipModifyScene.updataList = function(self,data)
    if not data then return end

    for i,j in pairs(data[1]) do
        local child = new(VipModifySceneItem,j,self);
        self.m_setHeadList:addChild(child);
    end
    for i,j in pairs(data[2]) do
        local child = new(VipModifySceneItem,j,self);
        self.m_setChessList:addChild(child);
    end
    for i,j in pairs(data[3]) do
        local child = new(VipModifySceneItem,j,self);
        self.m_setBoardList:addChild(child);
    end

end

VipModifyScene.resetSelectStatus = function(self,ret)
    local tab = {};
    --1 头像框 2 棋子   3 棋盘 
    if ret == 1 then
        tab = self.m_setHeadList:getChildren();
        for i,j in pairs(tab) do
            j:setSelectStatus(false);
        end
    elseif ret == 2 then
        tab = self.m_setChessList:getChildren();
        for i,j in pairs(tab) do
            j:setSelectStatus(false);
        end
    elseif ret == 3 then
        tab = self.m_setBoardList:getChildren();
        for i,j in pairs(tab) do
            j:setSelectStatus(false);
        end
    end
end

VipModifyScene.onScroll = function(self,diff,totalOffset,handler) 
    print_string("listView -------------> onscroll");
end

VipModifyScene.gotoMall = function(self)
    self:requestCtrlCmd(VipModifyController.s_cmds.gotoMall);
end

VipModifyScene.uploadSetType = function(self)
    self:requestCtrlCmd(VipModifyController.s_cmds.uploadSetType);
end

VipModifyScene.s_controlConfig = {
    [VipModifyScene.s_controls.back_btn]                          = {"back_btn"};
    [VipModifyScene.s_controls.select_board]                      = {"frame","board_select_view"};
    [VipModifyScene.s_controls.select_head_frame]                 = {"frame","head_select_view"};
    [VipModifyScene.s_controls.select_chess_piece]                = {"frame","chess_piece_select_view"};
}

VipModifyScene.s_controlFuncMap = {
    [VipModifyScene.s_controls.back_btn]                        = VipModifyScene.onBackAction;
};

VipModifySceneItem = class(Node);

VipModifySceneItem.s_w = 248;
VipModifySceneItem.s_hh = 275;
VipModifySceneItem.s_ch = 228;
VipModifySceneItem.s_bh = 396;

VipModifySceneItem.ctor = function(self,data,handler)
    self.m_data = data;
    if not data then return end
    
    self.is_select = false;
    self.itemType = data.settype;
    self.selectType = data.property;
    self.canClick = data.can_click;
    self.handler = handler;

    self.m_button = new(Button,"drawable/blank.png");
    self.m_button:setFillParent(true,true);
    self.m_button:setOnClick(self,self.onSelect);
    self:addChild(self.m_button);

    -- itemType  1 头像框  2 棋子 3 棋盘
    if self.itemType == 1 then
        self.m_head_mask = new(Mask,"userinfo/women_head01.png" ,"common/background/head_bg_130.png");
        self.m_head_mask:setAlign(kAlignTop);
        self.m_head_mask:setPos(0,18);
        self.m_head_mask:setSize(130,130);
        self:addChild(self.m_head_mask);

        self.m_head_frame = new(Image,"drawable/blank.png");
        self.m_head_frame:setVisible(false);

        if data.visible then
            self.m_head_frame:setFile(string.format(data.frame_res,130));
            self.m_head_frame:setVisible(data.visible);
            self.m_head_frame:setFillParent(true,true);
        end
        self.m_head_mask:addChild(self.m_head_frame);
        self:setSize(VipModifySceneItem.s_w,VipModifySceneItem.s_hh);

        if self.selectType and self.selectType == UserSetInfo.getInstance():getHeadFrameType() then
             self.is_select = true;
        end
    end
    if self.itemType == 2 then
        local piece = boardres_map["piece.png"];
        if data.piece_bg then
            piece = data.piece_bg;
        end
        local piece_img = boardres_map["rking.png"];
        if data.piece_img then
            piece_img = data.piece_img;
        end
        self.m_chess_piece = new(Image,piece);
        self.m_chess_piece:setAlign(kAlignTop);
        self.m_chess_piece:setPos(6,18);
        self:addChild(self.m_chess_piece);

        self.m_chess_piece_img = new(Image,piece_img);
        self.m_chess_piece_img:setAlign(kAlignTop);
        self.m_chess_piece_img:setPos(-2,3);
        self.m_chess_piece:addChild(self.m_chess_piece_img);
        self:setSize(VipModifySceneItem.s_w,VipModifySceneItem.s_ch);

        if self.selectType and self.selectType == UserSetInfo.getInstance():getChessPieceType() then
             self.is_select = true;
        end

    end
    if self.itemType == 3 then
        local img = boardres_map["chess_board.png"];
        if data.board_res then
            img = data.board_img;
        end
        self.board_img = new(Image,img);
        self.board_img:setAlign(kAlignTop);
        self.board_img:setPos(2,10);
        self:addChild(self.board_img);
        self:setSize(VipModifySceneItem.s_w,VipModifySceneItem.s_bh);
        if self.selectType and self.selectType == UserSetInfo.getInstance():getBoardType() then
             self.is_select = true;
        end
    end
    --棋盘类型
    local name = data.name;
    if not name then
        name = "默认";
    end
    self.board_text = new(Text,name,200,50,kAlignCenter,nil,36,135,100,95);
    self.board_text:setPos(2,72);
    self.board_text:setAlign(kAlignBottom);

    self.m_select_frame = new(Image,"common/check_bg.png");
    self.m_select_frame:setAlign(kAlignBottom);
    self.m_select_frame:setPos(4,16);
    self.select_img = new(Image,"common/checked.png");
    self.select_img:setAlign(kAlignCenter);
    self.select_img:setVisible(self.is_select);
    self.m_select_frame:addChild(self.select_img);

    self:addChild(self.board_text);
    self:addChild(self.m_select_frame);
    self:setAlign(kAlignTopLeft);
    

    if not self.canClick or self.canClick == 0 then
        if UserInfo.getInstance():getIsVip() == 0 then
            if self.itemType == 1 then
                self.m_head_mask:setGray(true);
            end
            if self.itemType == 2 then
                self.m_chess_piece:setGray(true);
            end
            if self.itemType == 3 then
                self.board_img:setGray(true);
            end
            self.m_button:setOnClick(self,self.showDialog);
        end
    end

--    local ret = nil;
--    if self.itemType == 1 then
--        ret = UserInfo.getInstance():getSetGray(self.itemType, self.selectType);
--        self.m_head_mask:setGray(ret);
--    elseif self.itemType == 2 then
--        ret = UserInfo.getInstance():getSetGray(self.itemType, self.selectType);
--        self.m_chess_piece:setGray(ret);
--    elseif self.itemType == 3 then
--        ret = UserInfo.getInstance():getSetGray(self.itemType, self.selectType);
--        self.board_img:setGray(ret);
--    end
--    if not ret then
--        self.m_button:setOnClick(self,self.showDialog);
--    end
end

VipModifySceneItem.onSelect = function(self)
    if not self.is_select then
        self.handler:resetSelectStatus(self.itemType);
        --1 头像框  2 棋子   3 棋盘
        if self.itemType == 1 then
            UserSetInfo.getInstance():setHeadFrameType(self.selectType);
        elseif self.itemType == 2 then
            UserSetInfo.getInstance():setChessPieceType(self.selectType);
        elseif self.itemType == 3 then
            UserSetInfo.getInstance():setBoardType(self.selectType);
        end
        self.handler:uploadSetType();
        self.select_img:setVisible(true);
        self.is_select = true;
    end
end

VipModifySceneItem.showDialog = function(self)
    if not self.m_vip_prompt then
        self.m_vip_prompt = new(VipPromptDialog);
    end
	self.m_vip_prompt:setPositiveListener(self.handler,self.handler.gotoMall);
	self.m_vip_prompt:show();
end

VipModifySceneItem.setSelectStatus = function(self,status)
    self.is_select = status;
    self.select_img:setVisible(status);
end