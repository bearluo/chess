require(VIEW_PATH .. "ios_review_dialog_view");
require(BASE_PATH .. "chessDialogScene")
require("uiex/richText");
require("animation/diceAccountDropMoney");

ReviewDialogView = class(ChessDialogScene, false);

ReviewDialogView.ctor = function (self)
	super(self, ios_review_dialog_view);
	self.root = self.m_root;
	self.bg = self.root:getChildByName("bg");
	self.newReviewMask = self.root:getChildByName("newReviewMask");
	self.closeButton = self.bg:getChildByName("closeButton");   
	self.confirmButton = self.bg:getChildByName("confirmButton");
	self.confirmButtonText = self.confirmButton:getChildByName("confirmButtonText");

	self.leftPrizeBg = self.bg:getChildByName("leftPrizeBg");
	self.leftPrizeImage = self.leftPrizeBg:getChildByName("leftPrizeImage");
	self.leftPrizeText = self.leftPrizeBg:getChildByName("leftPrizeText");

	self.rightPrizeBg = self.bg:getChildByName("rightPrizeBg");
	self.rightPrizeImage = self.rightPrizeBg:getChildByName("rightPrizeImage");
	self.rightPrizeText = self.rightPrizeBg:getChildByName("rightPrizeText");

	-- self.awardText = self.bg:getChildByName("awardText");
	-- self.centerImage = self.bg:getChildByName("centerImage");
	-- self.titleRichTextView = self.bg:getChildByName("titleRichTextView");

	-- local richTitleText = new(RichText, nil, 0, 64, kAlignCenter, nil, 40);
	-- richTitleText:analyzeText("#cffffffAppStore#cffff005星#cffffff好评");
	-- self.titleRichTextView:addChild(richTitleText);

	self.closeButton:setOnClick(self,self.dismiss);
	
	self.confirmButton:setOnClick(self,self.confirmButtonClick);

	-- 获取奖品信息
	local parameter = {};
	parameter.type = 0;
	HttpModule.getInstance():execute2(HttpModule.s_cmds.getIOSReviewPrize, parameter,
    function(isSuccess, response)
           if isSuccess then
                local jsonData = json.decode(response);
                local data = jsonData.data;

                -- 目前就只有两个商品 这么处理就好了
                if data.money ~= nil then
                	self.leftPrizeText:setText("游戏币×" .. data.money);
                	-- 以后应该要判断金币数额来确定图片
                	self.leftPrizeImage:setFile("mall/mall_list_gold2.png");
                end

                if data.soul ~= nil then
                	self.rightPrizeText:setText("棋魂×" .. data.soul);
                	self.rightPrizeImage:setFile("mall/soul.png");
                end

           end
    end);

end

ReviewDialogView.dtor = function (self)
	self.root = nil;
end

ReviewDialogView.show = function (self, time)
	self.super.show(self);
	EventDispatcher.getInstance():register(Event.Call,self,self.onNativeCallDone);
end

ReviewDialogView.dismiss = function (self)
	self.super.dismiss(self);
	EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeCallDone);
end

ReviewDialogView.confirmButtonClick = function (self)
  	call_native(kIosAppStoreEvaluate);
--	self.getPrize(self);
end

ReviewDialogView.getPrize = function (self)
	ReviewDialogView.dismiss(self);
	DiceAccountDropMoney.play(50);
	local parameter = {};
	parameter.type = 1;
	HttpModule.getInstance():execute2(HttpModule.s_cmds.getIOSReviewPrize, parameter,
   	function(isSuccess, response)
		if isSuccess then
            local jsonData = json.decode(response);
			local data = jsonData.data;
			-- 这里到时候要自定义改动金币
			--ChessToastManager.getInstance():showSingle("恭喜你获得"..data.prize,2200);
		end
   	end);
end

ReviewDialogView.isNewAppReview = function (self)
	self.newReviewMask:setOnClick(self,self.firstTouchMask);
	self.newReviewMask:setVisible(true);
end

-- iOS调用Lua
ReviewDialogView.onNativeCallDone = function(self ,param , ...)
	if self.s_nativeEventFuncMap[param] then
		self.s_nativeEventFuncMap[param](self,...);
	end
end

ReviewDialogView.firstTouchMask = function (self)
	ReviewDialogView.getPrize(self);
	self.newReviewMask:setVisible(false);
end

ReviewDialogView.s_nativeEventFuncMap = {
	[kGiveUserPrizeWithAppReview] = ReviewDialogView.getPrize;
	[kDismissAppReviewDialog] 	  = ReviewDialogView.dismiss;
	[kIsNewAppReviewAlert]		  = ReviewDialogView.isNewAppReview;
};



