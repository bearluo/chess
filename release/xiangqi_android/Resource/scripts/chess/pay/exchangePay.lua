require(PAY_PATH.."payInterface");

ExchangePay = class(PayInterface);

ExchangePay.getInstance = function()
    if not ExchangePay.instance then
        ExchangePay.instance = new(ExchangePay);
    end
    return ExchangePay.instance;
end
require(DIALOG_PATH.."input_tel_no_dialog")
ExchangePay.pay = function(goods,token)
	if goods then
        if goods.goods_type == 12 then -- 话费兑换
            delete(ExchangePay.mInputTelNoDialog)
            ExchangePay.mInputTelNoDialog = new(InputTelNoDialog,goods)
            ExchangePay.mInputTelNoDialog:show()
            return 
        end
        local post_data = {};
	    post_data.pid = goods.id;
	    post_data.position = goods.position;
	    post_data.sale_token = token or ""; -- 打折参数
	    HttpModule.getInstance():execute(HttpModule.s_cmds.exchangeProp,post_data,"兑换中，请稍后……");
	end
end
require("dialog/buy_tips_dialog");
ExchangePay.buy = function(self,goods,pos)
	if type(goods) ~= "table" then
		goods = ExchangePay.getExchangeProp(pos);
        if goods then
		    if not self.m_exchangeTipsDlg then
                
                self.m_exchangeTipsDlg = new(BuyTipsDialog);
            end
            local msg = "".. (goods.msg or "") .. "#n";
		    self.m_exchangeTipsDlg:setMode(BuyTipsDialog.MODE_SURE);
		    self.m_exchangeTipsDlg:setMessage(msg,kAlignLeft);
		    self.m_exchangeTipsDlg:setPositiveListener(goods,ExchangePay.pay);
		    self.m_exchangeTipsDlg:setNegativeListener();
            self.m_exchangeTipsDlg:show();
	    else
		    local message = "兑换失败！请检查网络"
		    ChessToastManager.getInstance():show(message);
        end
    else
        if not self.m_exchangeTipsDlg then
           
            self.m_exchangeTipsDlg = new(BuyTipsDialog);
        end

        local priceStr = ""
		if goods.exchange_num then
            if goods.exchange_num >= 10000 then
                if goods.exchange_num % 10000 > 1000 then
                    priceStr = string.format("%.1f万",goods.exchange_num/10000);
                else
                    priceStr = string.format("%.0f万",goods.exchange_num/10000);
                end
            else
			    priceStr = goods.exchange_num;
            end
		end

        if goods.exchange_type == 1 then
            priceStr = priceStr.."元宝";
        elseif goods.exchange_type == 4 then
            priceStr = priceStr.."棋魂";
        else
            priceStr = priceStr.."金币";
        end
        local title = string.format("是否用%s兑换%s?",priceStr,goods.name);--兑换dialog要用的参数
        local msg = title .. "#l#s28" .. (goods.desc or "") .."#n";
		self.m_exchangeTipsDlg:setMode(BuyTipsDialog.MODE_SURE,"好的");
		self.m_exchangeTipsDlg:setMessage(msg);
		self.m_exchangeTipsDlg:setPositiveListener(goods,ExchangePay.pay);
		self.m_exchangeTipsDlg:setNegativeListener();
        self.m_exchangeTipsDlg:show();
	end
	
	return self.m_exchangeTipsDlg;
end

ExchangePay.getExchangeProp = function(pos)			
	local startNum = ExchangePay.getStartNum(pos);

	local prop;
	local msg = nil;
    if startNum then
        prop = ExchangePay.getExchangePropByGoodsType(startNum)
    end
	if startNum == 1 then--生命回复
		if prop then
			prop.msg = "生命不足无法继续闯关，需花费时间等待生命恢复，立即回满生命需"..prop.exchange_num.."金币，即刻回满继续闯关！";
			prop.position = pos;
		end
	elseif startNum == 2 then --悔棋
		if prop then
			prop.msg = "走错一步不要紧，悔棋可以帮你返回到这步棋的前一步，"..prop.exchange_num.."金币可获得悔棋X"..prop.goods_num.."，助你扭转局面！"
			prop.position = pos;
		end
	elseif startNum == 3 then --提示
		if prop then
			prop.msg = "让电脑帮助你走出最佳的一步棋子，"..prop.exchange_num.."金币可获得提示X"..prop.goods_num.."，助你步步为赢！"
			prop.position = pos;
		end
	elseif startNum == 4 then --起死回生
		if prop then
			prop.msg = "不知何时走错不要紧，起死回生可帮你穿越到出错的前一步，而且不消耗生命哦！"..prop.exchange_num.."金币可获得起死回生X"..prop.goods_num.."，助你反败为胜！"
			prop.position = pos;
		end
	elseif startNum == 5 then --增加生命上限	
		if prop then
			prop.msg = "提高生命上限可拥有更多的闯关机会，获得生命上限+3需"..prop.exchange_num.."金币，助你早日通关！"
			prop.position = pos;
		end
	elseif startNum == 6 then 
		if prop then
			prop.msg = "开通本大关卡，更多精彩内容等你来体验！"..prop.exchange_num.."金币可开通需，成功开通后，重新开始游戏不需再次购买。"
			prop.position = pos;
		end
	elseif startNum == 7 then 
		if prop then
			prop.msg = "保存棋谱可将走棋过程保存在本地，方便日后研究。"..prop.exchange_num.."金币可开通保存棋谱功能，精彩对局不容错过，反复斟酌提高棋艺！"
			prop.position = pos;
		end
	elseif startNum == 8 then 
		if prop then
			prop.msg = "开通本层关卡，更多精彩内容等你来体验！"..prop.exchange_num.."金币可开通需，成功开通后，重新开始游戏不需再次购买。"
			prop.position = pos;
		end
	end

	return prop;
end

ExchangePay.getExchangePropByGoodsType = function(typeId)
    local list = MallData.getInstance():getPropData();
    local goods = nil;

	if list then
		local len = #list;
		for i=1,len do
			local v =list[i]
		    if v and v.goods_type == typeId then
	   			goods = v;
	   			break;		
	   		end
		end
	end

	return goods;
end

ExchangePay.getStartNum = function(TextStr) 
    local startNum = 0;
    if TextStr and string.len(TextStr)>0 then
    	local numStr = string.sub(TextStr, 1,1);
    	startNum = tonumber(numStr);
    end

    return startNum;
end

require("dialog/exchange_tips_dialog")
ExchangePay.exchangePropResult = function (data)
    local isSuccess = false;
    local message = "unknow";
	if data then
		-- status	int -2金币不足	-1元宝不足，0兑换失败，1成功 -2 金币不足
		local status = data.status;
		if status == -2 then
            message = "金币不足！"
		elseif status == -1 then
			message = "元宝不足！"
		elseif status == 0 then
			message = "兑换失败！"
		elseif  status == 1  then
			message = "兑换成功！"
            isSuccess = true;
            if ExchangePay.mInputTelNoDialog then
                ExchangePay.mInputTelNoDialog:dismiss()
            end

            if data.goods_type == 12 then
                local goodsData = MallData.getInstance():getPropData()
                local tips = "奖品将于7个工作日内到帐，请耐心等待，如有问题请联系客服。"
                if goodsData then
                    for _,goods in pairs(goodsData) do
                        if type(goods) == "table" and tonumber(goods.id) and tonumber(goods.id) == tonumber(data.id) then
                            tips = string.format("恭喜你成功兑换%s，奖品将于7个工作日内到帐，请耐心等待，如有问题请联系客服。",goods.name)
                        end
                    end
                end
                if not ExchangePay.m_exchange_tips_dialog then
		            ExchangePay.m_exchange_tips_dialog = new(ExchangeTipsDialog,"兑换成功",tips);
	            end
	            ExchangePay.m_exchange_tips_dialog:show("兑换成功",tips);
            end

			ExchangePay.deliverProp(data);
		end
	else
		message = "兑换失败！请检查网络"
	end
    if message ~= "" then
        ChessToastManager.getInstance():show(message);
    end
    return isSuccess;
end

ExchangePay.deliverProp = function(data)
	print_string("======PayUtil.deliverProp=====");

	if data then
		local pos = data.position;
		local num = data.goods_num;
		local goods_type = data.goods_type;

	    if goods_type == 1 then--生命回复 --已经不要了
	    	local limitNum = UserInfo.getInstance():getLifeLimitNum();
			UserInfo.getInstance():setLifeNum(limitNum);
		elseif goods_type == 2 then --悔棋
			local undoNum = UserInfo.getInstance():getUndoNum();
			undoNum = undoNum + num; 
			UserInfo.getInstance():setUndoNum(undoNum);
		elseif goods_type == 3 then --提示 
			local tipsNum = UserInfo.getInstance():getTipsNum();
			tipsNum = tipsNum + num; 
			UserInfo.getInstance():setTipsNum(tipsNum);
		elseif goods_type == 4 then --起死回生
			local reviveNum = UserInfo.getInstance():getReviveNum();
			reviveNum = reviveNum + num; 
			UserInfo.getInstance():setReviveNum(reviveNum);
		elseif goods_type == 5 then --增加生命上限 --已经不要了
			local limitNum = UserInfo.getInstance():getLifeLimitNum();
			limitNum = limitNum + num; 
			if limitNum <=14 then
				UserInfo.getInstance():setLifeLimitNum(limitNum);
			end
    	elseif goods_type == 6 then--残局大关 --已经不要了
			dict_set_string(kEndGateReplace,kEndGateReplace..kparmPostfix,""..UserInfo.getInstance():getUid());
			call_native(kEndGateReplace);
	  	elseif goods_type == 7 then--dapu
	  		UserInfo.getInstance():setDapuEnable(1);
	   	elseif goods_type == 8 then--单机大关 --已经不要了
			UserInfo.getInstance():setHasConsoleNeedBuy(false);
			local uid = UserInfo.getInstance():getUid();
			local level = GameCacheData.getInstance():getInt(GameCacheData.CONSOLE_MAX_LEVEL .. uid,0);
			GameCacheData.getInstance():saveInt(GameCacheData.CONSOLE_MAX_LEVEL .. uid,level+1);
--			PHPInterface.uploadConsoleProgress();
        elseif goods_type == 14 then
            UserSetInfo.getInstance():setBoardType("zhu_lin");
            ExchangePay.updataModify();
        elseif goods_type == 15 then
            UserSetInfo.getInstance():setBoardType("hu_pan");
            ExchangePay.updataModify();
        elseif goods_type == 21 then
            UserSetInfo.getInstance():setHeadFrameType("sliver");
            ExchangePay.updataModify();
		end



		--回调回去做本地发货或者更新关卡
		

		--ExchangePay.uploadOrDownPropData(1);

--		ExchangePay.addDeliverLog(data.orderno,data.id,pos);
	end
end

--[Comment]
--上传更新设置
function ExchangePay.updataModify()
    local info = {}
    info.version = kLuaVersionCode;
    info.my_set = json.encode(UserSetInfo.getInstance():getMySetType());
    HttpModule.getInstance():execute(HttpModule.s_cmds.uploadMySet,info);
end

ExchangePay.uploadOrDownPropData = function(update)--0 :恢复道具 1:上传道具
    print_string("==============PHP====uploadOrDownPropData===============");

	local post_data = {};
	post_data.update = update;
	if update == 1 then	
		local propinfo = {};
		local uid = UserInfo.getInstance():getUid();

		post_data.propinfo = propinfo;
	end
    HttpModule.getInstance():execute(HttpModule.s_cmds.uploadOrDownPropData,post_data);
end

ExchangePay.addDeliverLog = function(pid,propid,buyPropPlace)
    print_string("PHPInterface.addDeliverLogCallBack pid = " .. pid .. " propid = " .. propid);
	-- UserInfo.getInstance():setPmode(mode);
	local tips = "请稍候...";
	local post_data = {};
	post_data.pid = pid ;--支付方式
	post_data.propid = propid; --价格
	post_data.place = buyPropPlace; --价格

	post_data.boothTid = kEndgateData:getGateTid() or -1 ;--支付方式
	post_data.id = kEndgateData:getBoardTableId() or -1 ; --价格

	post_data.mid = UserInfo.getInstance():getUid();
	local pmode = 	UserInfo.getInstance():getPmode();
	post_data.pmode = pmode;
    
    HttpModule.getInstance():execute(HttpModule.s_cmds.addDeliverLog,post_data,tips);
end