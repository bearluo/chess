require(BASE_PATH.."chessScene");
require(DATA_PATH.."userSetInfo");
require("dialog/vip_prompt_dialog");
require("ui/viewPager")

VipModifyScene = class(ChessScene);

VipModifyScene.s_mode_headList = 1;
VipModifyScene.s_mode_pieceList = 2;
VipModifyScene.s_mode_boardList = 3;


VipModifyScene.s_controls = 
{
    back_btn                    = 1;
    select_board                = 2;
    select_head_frame           = 3;
    select_chess_piece          = 4;
    bottom_btn = 5;
}

VipModifyScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = VipModifyScene.s_controls;
    self:create();
end 

VipModifyScene.resume = function(self)
    ChessScene.resume(self);
    self:updataList(self.listData);

    --初始化按钮是否变灰
    --[[
    self:onGetOffset(VipModifyScene.s_mode_headList,1,true);
    self:onGetOffset(VipModifyScene.s_mode_headList,2,true);

    self:onGetOffset(VipModifyScene.s_mode_pieceList,1,true);
    self:onGetOffset(VipModifyScene.s_mode_pieceList,2,true);

    self:onGetOffset(VipModifyScene.s_mode_boardList,1,true);
    self:onGetOffset(VipModifyScene.s_mode_boardList,2,true);
    ]]--
end


VipModifyScene.pause = function(self)
	ChessScene.pause(self);
    self:removeAnimProp();

end 

VipModifyScene.dtor = function(self)
    delete(self.m_vip_prompt);
    delete(self.anim_start);
    delete(self.anim_end);
    delete(self.goodInfoDialog)
end 

VipModifyScene.removeAnimProp = function(self)

    if self.m_anim_prop_need_remove then
        --self.m_title_icon:removeProp(1);
        --self.m_leaf_left:removeProp(1);
        self.m_anim_prop_need_remove = false;
    end
end

VipModifyScene.setAnimItemEnVisible = function(self,ret)
    --self.m_leaf_left:setVisible(ret);
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

    --local lw,lh = self.m_leaf_left:getSize();
    --self.m_leaf_left:addPropTranslate(1, kAnimNormal, waitTime, delay, -lw, 0, -10, 0);
    --local tw,th = self.m_title_icon:getSize();
    --local anim = self.m_title_icon:addPropTranslate(1, kAnimNormal, waitTime, delay, 0, 0, -th, 0);
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

    --local lw,lh = self.m_leaf_left:getSize();
    --self.m_leaf_left:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, -lw, 0, -10);
    --local w,h = self.m_title_icon:getSize();
    --local anim = self.m_title_icon:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, 0, 0, -h);
    if anim then
        anim:setEvent(self,function()
            self:setAnimItemEnVisible(false);
        end);
    end
end

VipModifyScene.create = function(self)
    self.m_root_view = self.m_root;
    self.m_back_btn  = self:findViewById(self.m_ctrls.back_btn);
    self.m_bottom_btn = self:findViewById(self.m_ctrls.bottom_btn)
    --self.m_leaf_left = self.m_root:getChildByName("Image1");
    --self.m_leaf_left:setFile("common/decoration/left_leaf.png")

    --self.m_title_icon = self.m_root_view:getChildByName("Image2");

    self.m_setBoardView = self:findViewById(self.m_ctrls.select_board);
    self.m_setHeadFrameView = self:findViewById(self.m_ctrls.select_head_frame);
    self.m_setChessPieceView = self:findViewById(self.m_ctrls.select_chess_piece);
    --self.m_headLeftBtn = self.m_setHeadFrameView:getChildByName("btn_l");
    --self.m_headRightBtn = self.m_setHeadFrameView:getChildByName("btn_r");
    --self.m_pieceLeftBtn = self.m_setChessPieceView:getChildByName("btn_l");
    --self.m_pieceRightBtn = self.m_setChessPieceView:getChildByName("btn_r");
    --self.m_boardLeftBtn = self.m_setBoardView:getChildByName("btn_l");
    --self.m_boardRightBtn = self.m_setBoardView:getChildByName("btn_r");

    --左右键点击事件
    --[[
    self.m_headLeftBtn:setOnClick(self,function()
        self:onLeftBtnClick(VipModifyScene.s_mode_headList);
    end);
    self.m_headRightBtn:setOnClick(self,function()
        self:onRightBtnClick(VipModifyScene.s_mode_headList);
    end);
    self.m_pieceLeftBtn:setOnClick(self,function()
        self:onLeftBtnClick(VipModifyScene.s_mode_pieceList);
    end);
    self.m_pieceRightBtn:setOnClick(self,function()
        self:onRightBtnClick(VipModifyScene.s_mode_pieceList);
    end);
    self.m_boardLeftBtn:setOnClick(self,function()
        self:onLeftBtnClick(VipModifyScene.s_mode_boardList);
    end);
    self.m_boardRightBtn:setOnClick(self,function()
        self:onRightBtnClick(VipModifyScene.s_mode_boardList);
    end);
    ]]--
    local bw,bh = self.m_setBoardView:getSize();
    local hw,hh = self.m_setHeadFrameView:getSize();
    local cw,ch = self.m_setChessPieceView:getSize();

    self.m_setBoardList = new(ScrollView,0,0,bw,bh,true);
    self.m_setBoardList:setAlign(kAlignCenter);
    self.m_setBoardList:setDirection(kHorizontal);
    self.m_setBoardView:addChild(self.m_setBoardList);

    self.m_setHeadList = new(ScrollView,0,0,hw,hh,true);
    self.m_setHeadList:setAlign(kAlignCenter);
    self.m_setHeadList:setDirection(kHorizontal);
    self.m_setHeadFrameView:addChild(self.m_setHeadList);
--    self.m_setHeadList:setOnScrollEvent(self,self.onScroll);

    self.m_setChessList = new(ScrollView,0,0,cw,ch,true);
    self.m_setChessList:setAlign(kAlignCenter);
    self.m_setChessList:setDirection(kHorizontal);
    self.m_setChessPieceView:addChild(self.m_setChessList);

    self.listTab = {};
    self.listTab[1] = self.m_setHeadList;
    self.listTab[2] = self.m_setChessList;
    self.listTab[3] = self.m_setBoardList;

    self.offsetTab = {};
    self.offsetTab[1] = 0;
    self.offsetTab[2] = 0;
    self.offsetTab[3] = 0;

    self.listData = UserSetInfo.getInstance():getAllSelectRes();
    UserSetInfo.getInstance():updateSelectStatus();
--    UserSetInfo.getInstance():updateSelectItem();
--    self.offset_x = 0;
--    UserSetInfo.getInstance():updataSelectData();
end

VipModifyScene.onBackAction = function(self)
    self:requestCtrlCmd(VipModifyController.s_cmds.onBack);
end

function VipModifyScene.onbottomBtnClick(self)
    self:showDialog()
end 
--[Comment]
--右滑按钮点击事件
--mode： 列表类型
--[[
function VipModifyScene.onRightBtnClick(self,mode)
    if not self.listTab or #self.listTab == 0 then
        print_string("self.listTab  index is 0");
        return
    end

    local offset = self:onGetOffset(mode,1);
    local pos = self.offsetTab[mode] - offset;
    self.offsetTab[mode] = pos;
    self.listTab[mode]:scrollToPos(pos);
    self:onGetOffset(mode,1);                 --再做一次判断是否有下一页
end
]]--
--[Comment]
--左滑按钮点击事件
--mode： 列表类型
--[[
function VipModifyScene.onLeftBtnClick(self,mode)
    if not self.listTab or #self.listTab == 0 then
        print_string("self.listTab  index is 0");
        return
    end

    local offset = self:onGetOffset(mode,2);
    local pos = self.offsetTab[mode] + offset;
    self.offsetTab[mode] = pos;
    self.listTab[mode]:scrollToPos(pos);
    self:onGetOffset(mode,2);                --再做一次判断是否有下一页
end
]]--
--[Comment]
--获得srollview滑动最终位置
--mode：列表类型（number）
--btnMode ：按钮类型（number） 2-左滑按钮 1-右滑按钮
--[[
function VipModifyScene.onGetOffset(self,mode,btnMode,isShow)
    if not self.listTab or #self.listTab == 0 then
        print_string("self.listTab  index is 0");
        return self.offsetTab[mode] or 0;
    end
    local offset = 0;
    local diff = 0;
    local headListViewWidth = self.listTab[mode]:getViewLength();
    local headListFrameWidth = self.listTab[mode]:getFrameLength();
    if btnMode == 1 then
        diff = headListViewWidth - headListFrameWidth - math.abs(self.offsetTab[mode]);
    elseif btnMode == 2 then
        diff = math.abs(self.offsetTab[mode]);
    end
    if diff >= VipModifySceneItem.s_w then
        offset = VipModifySceneItem.s_w;
        self:setLeftRightBtnGray(mode,btnMode,false);
        local temBtnModel =  btnMode == 1 and 2 or 1;
        self:setLeftRightBtnGray(mode,temBtnModel,false);
    elseif diff == 0 then
        if not isShow then 
            ChessToastManager.getInstance():showSingle("已翻至最后");
        end
        self:setLeftRightBtnGray(mode,btnMode,true);
    elseif diff < VipModifySceneItem.s_w then
        offset = diff;
        self:setLeftRightBtnGray(mode,btnMode,false);
        local temBtnModel =  btnMode == 1 and 2 or 1;
        self:setLeftRightBtnGray(mode,temBtnModel,false);
    end
    return offset;
end
]]--
--[[
function VipModifyScene.setLeftRightBtnGray(self,mode,btnMode,boolvalue)
    if btnMode == 1 then
            if mode == 1 then 
                self.m_headRightBtn:setGray(boolvalue);
            elseif mode == 2 then
                self.m_pieceRightBtn:setGray(boolvalue);    
            elseif mode == 3 then 
                self.m_boardRightBtn:setGray(boolvalue);   
            end
             
        elseif btnMode == 2 then 
            if mode == 1 then 
                self.m_headLeftBtn:setGray(boolvalue);    
            elseif mode == 2 then
                self.m_pieceLeftBtn:setGray(boolvalue);    
            elseif mode == 3 then 
                 self.m_boardLeftBtn:setGray(boolvalue);    
            end
        end
end
]]--
--function VipModifyScene.onScroll(self, scroll_status, diffY, totalOffset,isMarginRebounding)
--    self.offset_x = totalOffset;
--    if isMarginRebounding and self.need_update_pos then
--        self.m_setHeadList:onScroll(kScrollerStatusStop,0,totalOffset);
--        self.m_setHeadList:updateScrollView();
--        self.need_update_pos = false;
--    end
--end

VipModifyScene.updataList = function(self,data)
    if not data then return end
    --[[优先可用的，没有会员的，会员放最后，其他棋盘没有的不显示，
如在有会员的基础上，排序为 ：默认--会员--竹林--湖畔--怀旧； --]]
    local screenFunc = function(data1,data2)
        local is_enabled1 = tonumber(data1.is_enabled)
        local is_enabled2 = tonumber(data2.is_enabled)
        local my_set1 = data1.my_set
        local my_set2 = data2.my_set
        if is_enabled1 == is_enabled2 then
            local valueMap = {
                ['sys'] = 0,
                ['vip'] = 1,
                ['zhu_lin'] = 2,
                ['hu_pan'] = 3,
                ['huai_jiu'] = 4,
            }
            value1 = valueMap[my_set1] or 100
            value2 = valueMap[my_set2] or 100
            return value1 < value2
        end
        return is_enabled1 > is_enabled2
    end
    local screenData = {};
    for i,j in pairs(data[1]) do
        if j['is_enabled'] ~= 0 then
            table.insert(screenData,data[1][i])
        end
    end
    table.sort(screenData,screenFunc)
    for key,val in pairs(screenData) do
        local child = new(VipModifySceneItem,screenData[key],self);
        self.m_setHeadList:addChild(child);
    end
    screenData = {}

    local screenData = {};
    for i,j in pairs(data[2]) do
        if j['is_enabled'] ~= 0 then
            table.insert(screenData,data[2][i])
        end
    end
    table.sort(screenData,screenFunc)
    for key,val in pairs(screenData) do
        local child = new(VipModifySceneItem,screenData[key],self);
        self.m_setChessList:addChild(child);
    end
    screenData = {}

    
    local screenData = {};
    for i,j in pairs(data[3]) do
        if j['is_enabled'] ~= 0 then
            table.insert(screenData,data[3][i])
        end
    end
    table.sort(screenData,screenFunc)
    for key,val in pairs(screenData) do
        local child = new(VipModifySceneItem,screenData[key],self);
        self.m_setBoardList:addChild(child);
    end
    screenData = {}
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

--VipModifyScene.onScroll = function(self,diff,totalOffset,handler) 
--    print_string("listView -------------> onscroll");
--end

VipModifyScene.gotoMall = function(self)
    self:requestCtrlCmd(VipModifyController.s_cmds.gotoMall);
end

VipModifyScene.uploadSetType = function(self)
    self:requestCtrlCmd(VipModifyController.s_cmds.uploadSetType);
end

--[Comment]
--购买VIP提示弹窗
function VipModifyScene.showDialog(self)
    if not self.goodInfoDialog then
       self.goodInfoDialog = new(GoodInfoDialog)
    end
    local data = {};
--    local vipType = 2324;
--    if kPlatform == kPlatformIOS then
--        data = MallData.getInstance():getPropById(vipType)
--    else 
    data = MallData.getInstance():getVipGoods()
--    end
    if not data then
        ChessToastManager.getInstance():showSingle("请前往商城购买")
        return
    end
    local url = data.big_img
    self.goodInfoDialog:setUrlImage(url)
    self.goodInfoDialog:setNormalView()
    self.goodInfoDialog:setSureBtnEvent(self,self.buySure )
    self.goodInfoDialog:show()
end 

function VipModifyScene.buySure(self)
    self.goodInfoDialog:dismiss();
    local data = {};
    data = MallData.getInstance():getVipGoods()
    if not data or type(data) ~= "table" then  return end
    if next(data) ~= nil then
        if kPlatform == kPlatformIOS then
            VipModifyScene.m_PayInterface = PayUtil.getPayInstance(PayUtil.s_payType.Exchange);
		    data.position = data.id;
		    VipModifyScene.m_pay_dialog = VipModifyScene.m_PayInterface:buy(data,data.position);
        else
            local payData = {}
            payData.pay_scene = PayUtil.s_pay_scene.default_recommend
            VipModifyScene.m_PayInterface = PayUtil.getPayInstance(PayUtil.s_defaultType);
		    data.position = MALL_COINS_GOODS;
		    VipModifyScene.m_pay_dialog = VipModifyScene.m_PayInterface:buy(data,payData);
        end
    else
        self:gotoMall();
    end
end 
VipModifyScene.s_controlConfig = {
    [VipModifyScene.s_controls.back_btn]                          = {"new_style_view","back_btn"};
    [VipModifyScene.s_controls.select_board]                      = {"new_style_view","content_view","board_select_view"};
    [VipModifyScene.s_controls.select_head_frame]                 = {"new_style_view","content_view","head_select_view"};
    [VipModifyScene.s_controls.select_chess_piece]                = {"new_style_view","content_view","chess_piece_select_view"};
    [VipModifyScene.s_controls.bottom_btn]                        = {"new_style_view","bottom_btn"};
}

VipModifyScene.s_controlFuncMap = {
    [VipModifyScene.s_controls.back_btn]                        = VipModifyScene.onBackAction;
    [VipModifyScene.s_controls.bottom_btn]                        = VipModifyScene.onbottomBtnClick;
};

VipModifySceneItem = class(Node);

VipModifySceneItem.DECORATION_ITEM_BG = "common/background/decoration_item_bg.png"
VipModifySceneItem.FREE_FLAG = "common/icon/free_flag.png"
VipModifySceneItem.VIP_FLAG = "common/icon/vip_flag.png"
VipModifySceneItem.TIME_LIMIT_FLAG = "common/icon/timelimit_flag.png"
VipModifySceneItem.USING = "common/icon/using.png"

VipModifySceneItem.HEAD_TX = "头像框"
VipModifySceneItem.CHESS_PIECE_TX = "象棋子"
VipModifySceneItem.CHESS_TABLE_TX = "象棋棋盘"
VipModifySceneItem.s_w = 237;
VipModifySceneItem.s_hh = 278;
VipModifySceneItem.s_ch = 202;
VipModifySceneItem.s_bh = 430;

VipModifySceneItem.OPTION_WIDTH = 220
VipModifySceneItem.OPTION_HEIGHT = 180
VipModifySceneItem.OPTION_HEIGHT_CHESS_TABLE = 300
VipModifySceneItem.TX_WIDTH = 30
VipModifySceneItem.TX_HEIGHT = 20
function VipModifySceneItem.ctor(self,data,handler)
    self.m_data = data;
    if not data then return end
    
    self.is_select = false;
    self.itemType = data.settype;
--    self.selectType = data.property;
    self.is_enabled = data.is_enabled;
    self.my_set  = data.my_set;
    self.handler = handler;

    self.m_button = new(Button,"drawable/blank.png");
    self.m_button:setFillParent(true,true);
--    self.m_button:setOnClick(self,self.onSelect);
--    self.m_button:setSrollOnClick();
    self:addChild(self.m_button);

    -- itemType  1 头像框  2 棋子 3 棋盘
    if self.itemType == 1 then
        self.optionImg = new (Image,VipModifySceneItem.DECORATION_ITEM_BG)
        self.optionImg:setAlign(kAlignTop)
        self.optionImg:setSize(VipModifySceneItem.OPTION_WIDTH,VipModifySceneItem.OPTION_HEIGHT)
        self:addChild(self.optionImg)

        self.m_head_mask = new(Mask,"userinfo/women_head01.png" ,"common/background/head_bg_130.png");
        self.m_head_mask:setAlign(kAlignCenter);
--        self.m_head_mask:setPos(0,18);
        self.m_head_mask:setSize(130,130);
        self.optionImg:addChild(self.m_head_mask);

        self.m_head_frame = new(Image,"drawable/blank.png");
        self.m_head_frame:setVisible(false);
        self.m_head_frame:setSize(160,160)
        self.m_head_frame:setAlign(kAlignCenter)
        if data.visible then
            self.m_head_frame:setFile(string.format(data.frame_res,160));
            self.m_head_frame:setVisible(data.visible);
--            self.m_head_frame:setFillParent(true,true);
        end
        self.m_head_mask:addChild(self.m_head_frame);
        self:setSize(VipModifySceneItem.s_w,VipModifySceneItem.s_hh);

        --是否使用中标识
        self.usingImg = new (Image,VipModifySceneItem.USING)
        self.usingImg:setAlign(kAlignTopLeft)
        self.usingImg:setSize(80,30)
        self.usingImg:setVisible(false)
        self.optionImg:addChild(self.usingImg)

        if self.my_set and self.my_set == UserSetInfo.getInstance():getHeadFrameType() then
            self.is_select = true;
            self.usingImg:setVisible(true)
        end
        
        --说明字段，eg."头像框"
        self.tx = new (Text,VipModifySceneItem.HEAD_TX,0,0,kAlignLeft,nil,24,180,160,135)
        self.tx:setAlign(kAlignBottomLeft)
        self.tx:setPos(VipModifySceneItem.TX_WIDTH,VipModifySceneItem.TX_HEIGHT)
        self:addChild(self.tx)
    end
    if self.itemType == 2 then
        self.optionImg = new (Image,VipModifySceneItem.DECORATION_ITEM_BG)
        self.optionImg:setAlign(kAlignTop)
        self.optionImg:setSize(VipModifySceneItem.OPTION_WIDTH,VipModifySceneItem.OPTION_HEIGHT)
        self:addChild(self.optionImg)

        local piece = boardres_map["piece.png"];
        if data.piece_bg then
            piece = data.piece_bg;
        end
        local piece_img = boardres_map["rking.png"];
        if data.piece_img then
            piece_img = data.piece_img;
        end

        self.m_chess_piece = new(Image,piece);
        self.m_chess_piece:setAlign(kAlignCenter);
        self.m_chess_piece:setPos(0,8);
        self.optionImg:addChild(self.m_chess_piece);
        self.m_chess_piece_img = new(Image,piece_img);
        self.m_chess_piece_img:setAlign(kAlignTop);
        self.m_chess_piece_img:setPos(0,1);
        self.m_chess_piece:addChild(self.m_chess_piece_img);
        self:setSize(VipModifySceneItem.s_w,VipModifySceneItem.s_hh);

        --是否使用中标识
        self.usingImg = new (Image,VipModifySceneItem.USING)
        self.usingImg:setAlign(kAlignTopLeft)
        self.usingImg:setSize(80,30)
        self.usingImg:setVisible(false)
        self.optionImg:addChild(self.usingImg)

        if self.my_set and self.my_set == UserSetInfo.getInstance():getChessPieceType() then
             self.is_select = true;
             self.usingImg:setVisible(true)
        end
        
        --说明字段，eg."象棋子"
        self.tx = new (Text,VipModifySceneItem.CHESS_PIECE_TX,0,0,kAlignLeft,nil,24,180,160,135)
        self.tx:setAlign(kAlignBottomLeft)
        self.tx:setPos(VipModifySceneItem.TX_WIDTH,VipModifySceneItem.TX_HEIGHT)
        self:addChild(self.tx)
    end
    if self.itemType == 3 then
        self.optionImg = new (Image,VipModifySceneItem.DECORATION_ITEM_BG)
        self.optionImg:setAlign(kAlignTop)
        self.optionImg:setSize(VipModifySceneItem.OPTION_WIDTH,VipModifySceneItem.OPTION_HEIGHT_CHESS_TABLE)
        self:addChild(self.optionImg)

        local img = boardres_map["chess_board.png"];
        if data.board_res then
            img = data.board_img;
        end
        self.board_img = new(Image,img);
        self.board_img:setAlign(kAlignCenter);
        --self.board_img:setPos(0,5);
        self.board_img:setFillParent(true,true)
        self.optionImg:addChild(self.board_img);
        self:setSize(VipModifySceneItem.s_w,VipModifySceneItem.s_bh);

        --是否使用中标识
        self.usingImg = new (Image,VipModifySceneItem.USING)
        self.usingImg:setAlign(kAlignTopLeft)
        self.usingImg:setSize(80,30)
        self.usingImg:setVisible(false)
        self.optionImg:addChild(self.usingImg)

        if self.my_set and self.my_set == UserSetInfo.getInstance():getBoardType() then
            self.is_select = true;
            self.usingImg:setVisible(true)
        end

        --说明字段，eg."象棋棋盘"
        self.tx = new (Text,VipModifySceneItem.CHESS_TABLE_TX,0,0,kAlignLeft,nil,24,180,160,135)
        self.tx:setAlign(kAlignBottomLeft)
        self.tx:setPos(30,50)
        self:addChild(self.tx)
    end
    --棋盘类型
    local name = data.name;
    if not name then
        name = "默认";
    end
    self.board_text = new(Text,name,0,0,kAlignLeft,nil,32,85,70,40);
    if self.itemType == 3 then 
        self.board_text:setPos(30,80);
    else
        self.board_text:setPos(30,50);
    end 
    self.board_text:setAlign(kAlignBottomLeft);
    self:addChild(self.board_text)

    self.flagImg = new (Image,VipModifySceneItem.FREE_FLAG)
    self.flagImg:setAlign(kAlignBottomLeft)
    if self.itemType == 1 then 
        self.flagImg:setPos(130,53)
    elseif self.itemType == 3 then 
        self.flagImg:setPos(160,83)
    else 
        self.flagImg:setPos(160,53)
    end 
    
    self.flagImg:setSize(45,25)
    self:addChild(self.flagImg)
    if data.flag == 1 then 
        self.flagImg:setFile(VipModifySceneItem.VIP_FLAG)
    elseif data.flag == 2 then 
        self.flagImg:setFile(VipModifySceneItem.TIME_LIMIT_FLAG)
    end 
    --[[self.m_select_frame = new(Image,"common/check_bg.png")
    self.m_select_frame:setAlign(kAlignBottom)
    self.m_select_frame:setPos(-3,0)
    self.select_img = new(Image,"common/checked.png")
    self.select_img:setAlign(kAlignCenter)
    self.select_img:setVisible(self.is_select)
    self.m_select_frame:addChild(self.select_img)

    
    self:addChild(self.m_select_frame);
    ]]--
    self:setAlign(kAlignTopLeft);
    
    if not self.is_enabled or self.is_enabled == -1 then
        --self.m_select_frame:setGray(true);
--        self.m_button:setOnClick(self,self.showDialog);
    end

    self.m_button:setEventTouch(self,self.onTouchEvent);
end

--[Comment]
--item点击事件
--重写防止滑动出错
function VipModifySceneItem.onTouchEvent(self, finger_action, x, y, drawing_id_first, drawing_id_current)
    if finger_action == kFingerDown then
        self.mFingerDownX = x;
        self.mFingerDownY = y;
        self.mFingerMoveX = x;
        self.mFingerMoveY = y;
    elseif finger_action == kFingerMove then
        self.mFingerMoveX = x;
        self.mFingerMoveY = y;
    elseif finger_action == kFingerUp then
        if drawing_id_first == drawing_id_current then
            if math.abs(self.mFingerDownX - self.mFingerMoveX) > 30 then
                return
            end

            if not self.is_enabled or self.is_enabled == -1 then
                self.handler:showDialog();
                return
            end

            if not self.is_select then
                if self.handler then
                    self.handler:resetSelectStatus(self.itemType);
                end
                --1 头像框  2 棋子   3 棋盘
                if self.itemType == 1 then
                    UserSetInfo.getInstance():setHeadFrameType(self.my_set);
                elseif self.itemType == 2 then
                    UserSetInfo.getInstance():setChessPieceType(self.my_set);
                elseif self.itemType == 3 then
                    UserSetInfo.getInstance():setBoardType(self.my_set);
                end
                if self.handler then
                    self.handler:uploadSetType();
                end
                --self.select_img:setVisible(true);
                self.usingImg:setVisible(true)
                self.is_select = true;
            end
        end
    end
end

--[Comment]
--购买VIP提示弹窗
function VipModifySceneItem.showDialog(self)
    local data = {};
--    local vipType = 2324;
--    if kPlatform == kPlatformIOS then
--        data = MallData.getInstance():getPropById(vipType)
--    else 
        data = MallData.getInstance():getVipGoods()
--    end

    if not self.m_vip_prompt then
        self.m_vip_prompt = new(VipPromptDialog);
    end
	self.m_vip_prompt:setPositiveListener(self,function()
        self.m_vip_prompt:dismiss();
        if not data or type(data) ~= "table" then  return end
        if next(data) ~= nil then
            if kPlatform == kPlatformIOS then
                VipModifyScene.m_PayInterface = PayUtil.getPayInstance(PayUtil.s_payType.Exchange);
		        data.position = data.id;
		        VipModifyScene.m_pay_dialog = VipModifyScene.m_PayInterface:buy(data,data.position);
            else
                local payData = {}
                payData.pay_scene = PayUtil.s_pay_scene.default_recommend
                VipModifyScene.m_PayInterface = PayUtil.getPayInstance(PayUtil.s_defaultType);
		        data.position = MALL_COINS_GOODS;
		        VipModifyScene.m_pay_dialog = VipModifyScene.m_PayInterface:buy(data,payData);
            end
        else
            self.handler:gotoMall();
        end
    end);--self.handler,self.handler.gotoMall);
	self.m_vip_prompt:show();
end

--[Comment]
--设置item选中状态
--status：是否选中（boolean）
function VipModifySceneItem.setSelectStatus(self,status)
    self.is_select = status;
    --self.select_img:setVisible(status);
    self.usingImg:setVisible(status)
    
end