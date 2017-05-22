require(VIEW_PATH .. "handicap_dialog_view");
require(BASE_PATH.."chessDialogScene")
HandicapDialog = class(ChessDialogScene,false);


HandicapDialog.MODE_SURE = 1;
HandicapDialog.MODE_AGREE = 2;
HandicapDialog.MODE_OK = 3;



HandicapDialog.ctor = function(self,room)
    super(self,handicap_dialog_view);
	self.m_room = room;

	self.m_root_view = self.m_root;


	self.m_content_view = self.m_root_view:getChildByName("handicap_content_view");


	self.m_giveup_btn = self.m_content_view:getChildByName("handicap_giveup_btn");


	self.m_timeout_text = self.m_content_view:getChildByName("handicap_timeout_text");


	self.m_rival_info = self.m_content_view:getChildByName("handicap_rival_info");
	self.m_rival_icon_bg = self.m_rival_info:getChildByName("handicap_rival_icon_bg");
	self.m_rival_icon_mask = self.m_rival_icon_bg:getChildByName("handicap_rival_icon_mask");
    self.m_rival_icon = new(Mask,"common/background/head_mask_bg_122.png","common/background/head_mask_bg_122.png");
    self.m_rival_icon:setSize(self.m_rival_icon_mask:getSize());
    self.m_rival_icon_mask:addChild(self.m_rival_icon);

	self.m_rival_name = self.m_rival_info:getChildByName("handicap_rival_name");
	self.m_rival_score = self.m_rival_info:getChildByName("handicap_rival_score");
    self.m_rival_level = self.m_rival_icon_bg:getChildByName("handicap_rival_level");
	self.m_rival_rate = self.m_rival_info:getChildByName("handicap_rival_rate");
	self.m_rival_grade = self.m_rival_info:getChildByName("handicap_rival_grade");


	self.m_total_mul = self.m_content_view:getChildByName("handicap_total_mul");
	self.m_base_money = self.m_content_view:getChildByName("handicap_base_money");



	self.m_giveup_btn:setOnClick(self,self.giveup);


	self.m_handicap_chess1_btn = self.m_content_view:getChildByName("handicap_chess1_btn");
	self.m_handicap_chess1_texture = self.m_handicap_chess1_btn:getChildByName("handicap_chess1_texture");
	self.m_handicap_chess1_text = self.m_handicap_chess1_btn:getChildByName("handicap_chess1_mul");
	self.m_handicap_chess1_btn:setOnClick(self,self.handicapChess1);

	self.m_handicap_chess2_btn = self.m_content_view:getChildByName("handicap_chess2_btn");
	self.m_handicap_chess2_texture = self.m_handicap_chess2_btn:getChildByName("handicap_chess2_texture");
	self.m_handicap_chess2_text = self.m_handicap_chess2_btn:getChildByName("handicap_chess2_mul");
	self.m_handicap_chess2_btn:setOnClick(self,self.handicapChess2);

	self.m_handicap_chess3_btn = self.m_content_view:getChildByName("handicap_chess3_btn");
	self.m_handicap_chess3_texture = self.m_handicap_chess3_btn:getChildByName("handicap_chess3_texture");
	self.m_handicap_chess3_text = self.m_handicap_chess3_btn:getChildByName("handicap_chess3_mul");
	self.m_handicap_chess3_btn:setOnClick(self,self.handicapChess3);

    self:setNeedBackEvent(false);
    self:setNeedMask(false);
    self.noticeDialog = new(ChioceDialog);
    self.mDialogAnim = AnimDialogFactory.createMoveUpAnim(self)
end

HandicapDialog.dtor = function(self)
	self.m_root_view = nil;
    delete(self.noticeDialog);
    self.mDialogAnim.stopAnim()
end

HandicapDialog.isShowing = function(self)
	return self:getVisible();
end

HandicapDialog.setData = function(self,data)

		self.m_mul = data.multiply;
        self.m_baseMoney = tonumber(data.baseMoney) or 0;

		self.m_timeout = tonumber(data.timeout);
	    self.m_timeout_text:setText(string.format("选择你想让的棋子 (%ds)",self.m_timeout));
		

		self.m_chess1 = data.chesses[1].chessID;
		self.m_chess1_mul = data.chesses[1].times;
		local file1 = Board.boardres_map[drawable_resource_id[data.chesses[1].chessID] .. ".png"];
		-- print_string("file1 = " .. file1);
		self.m_handicap_chess1_texture:setFile(file1);
		self.m_handicap_chess1_text:setText(string.format("翻%d倍",self.m_chess1_mul));
	

		self.m_chess2 = data.chesses[2].chessID;
		self.m_chess2_mul = data.chesses[2].times;
		local file2 = Board.boardres_map[drawable_resource_id[data.chesses[2].chessID] .. ".png"];
		-- print_string("file2 = " .. file2);
		self.m_handicap_chess2_texture:setFile(file2);
		self.m_handicap_chess2_text:setText(string.format("翻%d倍",self.m_chess2_mul));

		self.m_chess3 = data.chesses[3].chessID;
		self.m_chess3_mul = data.chesses[3].times;
		local file3 = Board.boardres_map[drawable_resource_id[data.chesses[3].chessID] .. ".png"];
		-- print_string("file3 = " .. file3);
		self.m_handicap_chess3_texture:setFile(file3);
		self.m_handicap_chess3_text:setText(string.format("翻%d倍",self.m_chess3_mul));

        
	    self.m_total_mul:setText(string.format("%d倍",self.m_mul));
        local money = self.m_mul * self.m_baseMoney
        local str = ""
        if money > 10000 then
            if money % 10000 == 0 then
                str = string.format("%dW金币",money/10000)
            else
                str = string.format("%.1fW金币",money/10000)
            end
        else
            str = string.format("%d金币",money)
        end
        self.m_base_money:setText(str);


            -- 获取按钮状态
    local roomConfig = RoomProxy.getInstance():getCurRoomConfig();
    if data and data.byMultiplyBtn and roomConfig and roomConfig.rangzi_level then
        self:initBtnStatus(data.byMultiplyBtn,roomConfig.rangzi_level)
    else
	    self.m_handicap_chess1_btn:setOnClick(self,self.handicapChess1);
	    self.m_handicap_chess2_btn:setOnClick(self,self.handicapChess2);
	    self.m_handicap_chess3_btn:setOnClick(self,self.handicapChess3);
        self.m_handicap_chess1_btn:setGray(false);
        self.m_handicap_chess2_btn:setGray(false);
        self.m_handicap_chess3_btn:setGray(false);
    end
end

HandicapDialog.show = function(self)
    

	local user = self.m_room.m_upUser
	if  user then
        if user:getIconType() == -1 then
            self.m_rival_icon:setUrlImage(user:getIcon());
        else
            self.m_rival_icon:setFile(UserInfo.DEFAULT_ICON[user:getIconType()] or UserInfo.DEFAULT_ICON[1]);
        end
		self.m_rival_name:setText(GameString.convert2UTF8(user:getName()));
		self.m_rival_score:setText(GameString.convert2UTF8(user:getScore()));
        self.m_rival_level:setFile(string.format("common/icon/%d.png",10-UserInfo.getInstance():getDanGradingLevelByScore()));
		self.m_rival_rate:setText(GameString.convert2UTF8(user:getRate()));
		self.m_rival_grade:setText(GameString.convert2UTF8(user:getGrade()));
	end

	kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
	self:startTimeout();
	self:setVisible(true);
    self.super.show(self,self.mDialogAnim.showAnim);

    self.m_content_view:removeProp(1);
    local w,h = self.m_content_view:getSize();
    local anim = self.m_content_view:addPropTranslate(1,kAnimNormal,400,-1,0,0,h,0);
    anim:setEvent(self,function()
        self.m_content_view:removeProp(1);
    end);
end

--[Comment]
-- status ：金币不足配置
-- status2 : 允许点击配置
require("libs/bit");
function HandicapDialog:initBtnStatus(status,status2)
    local bits = bit.tobits(status);
    local bits2 = bit.tobits(status2)
    -- {0,0,0,0,0,0} 自1 别1 自2 别2 自3 别3
    self:initBtnStatusByData(self.m_handicap_chess1_btn,bits[1] or 0,bits[2] or 0,bits2[1] or 0,self.handicapChess1);
    self:initBtnStatusByData(self.m_handicap_chess2_btn,bits[3] or 0,bits[4] or 0,bits2[2] or 0,self.handicapChess2);
    self:initBtnStatusByData(self.m_handicap_chess3_btn,bits[5] or 0,bits[6] or 0,bits2[3] or 0,self.handicapChess3);
end
-- btn 按钮 mbtn 我的状态 obtn 对手状态
function HandicapDialog:initBtnStatusByData(btn,mbtn,obtn,cbtn,click)
    btn:setGray(false);
    if cbtn ~= 1 then
        btn:setOnClick(self,function()
            ChessToastManager.getInstance():showSingle("本场次不支持该功能");
        end);
        btn:setGray(true);
        return;   
    end
    if mbtn ~= 1 then
        btn:setOnClick(self,function()
            ChessToastManager.getInstance():showSingle("您的金币不足");
        end);
        btn:setGray(true);
    elseif obtn ~= 1 then
        btn:setOnClick(self,function(self)
            local message = "对方金币不足以支付该倍数金额，如胜利，实际所获金币将少于所应获得，是否继续抢先？"
	        self.noticeDialog:setMode(ChioceDialog.MODE_SURE);
	        self.noticeDialog:setPositiveListener(self,click);
            self.noticeDialog:setNegativeListener(nil);
	        self.noticeDialog:setMessage(message);
	        self.noticeDialog:show();
        end);
        btn:setGray(false);
    else
        btn:setOnClick(self,click);
        btn:setGray(false);
    end
end

HandicapDialog.startTimeout = function(self)
	self:stopTimeout();
	self.m_timeout = self.m_timeout or 60;
	self.m_timeout_text:setText(string.format("选择你想让的棋子 (%ds)",self.m_timeout));
	self.m_timeoutAnim = new(AnimInt,kAnimLoop,0,1,1000,-1);
	self.m_timeoutAnim:setDebugName("HandicapDialog.startTimeout.m_timeoutAnim");
	
	self.m_timeoutAnim:setEvent(self,self.timeoutRun);
end

HandicapDialog.stopTimeout = function(self)
	if self.m_timeoutAnim then
		delete(self.m_timeoutAnim);
		self.m_timeoutAnim = nil;
	end
end

HandicapDialog.timeoutRun = function(self)
	self.m_timeout =  self.m_timeout - 1;
	if self.m_timeout  < 0 then
		--self:giveup();
		self:dismiss();
		return;
	end
	self.m_timeout_text:setText(string.format("选择你想让的棋子 (%ds)",self.m_timeout));

end

HandicapDialog.giveup = function(self)
	print_string("HandicapDialog.giveup ");
	self:dismiss();
    self.m_room:sendHandicapMsg(0);

end

HandicapDialog.sure = function(self)
	print_string("HandicapDialog.sure ");
	self:dismiss();
    StatisticsManager.getInstance():onCountToUM(ROOM_READYING_HANDICAP_TRUE,self.m_chess)
    self.m_room:sendHandicapMsg(self.m_chess);

end


HandicapDialog.handicapChess1 = function(self)
	self.m_chess = self.m_chess1;
    self:sure();
end

HandicapDialog.handicapChess2 = function(self)
	self.m_chess = self.m_chess2;
    self:sure();
end

HandicapDialog.handicapChess3 = function(self)
	self.m_chess = self.m_chess3;
    self:sure();
end


HandicapDialog.dismiss = function(self)
	self:stopTimeout();
--	self:setVisible(false);
    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
    self.m_content_view:removeProp(1);
    local w,h = self.m_content_view:getSize();
    local anim = self.m_content_view:addPropTranslate(1,kAnimNormal,400,-1,0,0,0,h);
    anim:setEvent(self,function()
        self.m_content_view:removeProp(1);
        self:setVisible(false);
    end);
    self.noticeDialog:dismiss();
end