--region payUtil.lua
--Author : BearLuo
--Date   : 2015/4/10
require(PAY_PATH.."unityPay");
require(PAY_PATH.."exchangePay");
require(PAY_PATH.."godPay");
PayUtil = class();

PayUtil.s_payType = {
    UnityPay = 1;
    Exchange = 2;
    GodSdk = 3;
};

PayUtil.s_defaultType = PayUtil.s_payType.GodSdk;
PayUtil.s_useType = 0;

if kPlatform == kPlatformIOS then
    PayUtil.aliPay_mode = 265;             --支付宝
    PayUtil.pay_mode_weixin = 463;         --微信;
    PayUtil.pay_mode_appstore = 99;        --AppStore;
    --支持的支付方式
    PayUtil.pmodes = {
    	PayUtil.pay_mode_appstore;
    	PayUtil.aliPay_mode;
    	PayUtil.pay_mode_weixin; 
    }
else
    PayUtil.mm_mode = 218;                 --移动MM弱网
    PayUtil.wo_shop_mode = 109;            --联通wo商店
    PayUtil.dianxin_aiyouxi_mode = 34      --电信爱游戏
    PayUtil.huafubao_mode = 35;            --话付宝
    PayUtil.oppo_mode = 501;               --OPPO支付
    PayUtil.aliPay_mode = 265;             --支付宝
    PayUtil.pay_mode_mo9 = 29 ;            --mo9;
    PayUtil.huawei_mode = 110;             --华为支付
    PayUtil.pay_mode_weixin = 431;         --微信;
    PayUtil.pay_mode_union = 198;          --银联;
    --支持的支付方式
    PayUtil.pmodes = {
        PayUtil.mm_mode;
    	PayUtil.wo_shop_mode;
     	PayUtil.dianxin_aiyouxi_mode;
    	PayUtil.aliPay_mode;
    	PayUtil.pay_mode_weixin;
    	PayUtil.pay_mode_union;
    }
end;


PayUtil.init = function()
    if 	not PayUtil.initPay  then
        require(DATA_PATH.."userInfo");
	  	PayUtil.initPay = true;
	 	local objJson = {};
		objJson.sid = UserInfo.getInstance():getPaySid();
		objJson.appid = UserInfo.getInstance():getAppid();
		local line = json.encode(objJson)
		dict_set_string(kInitBoyaaPay , kInitBoyaaPay .. kparmPostfix , line);
		call_native(kInitBoyaaPay);
  	end
end

PayUtil.getPayInstance = function(PayType)
    if PayType == PayUtil.s_payType.UnityPay then
        PayUtil.s_useType = PayUtil.s_payType.UnityPay;
        return UnityPay.getInstance();
    elseif PayType ==  PayUtil.s_payType.Exchange then
        return ExchangePay.getInstance();
    elseif PayType == PayUtil.s_payType.GodSdk then
        PayUtil.s_useType = PayUtil.s_payType.GodSdk;
        return GodPay.getInstance();
    end
end

require("animation/daozhangMessageAnim");

PayUtil.addPayBudanLog = function(payLogs,controlerhandler)

	if not payLogs then
		return;
	end

	local message = "你获得的";
	if payLogs.type == 1 then

		local money = tonumber(UserInfo:getInstance():getMoney());
		local bccoin = tonumber(UserInfo:getInstance():getBccoin());
		local soulcount = tonumber(UserInfo:getInstance():getSoulCount());

 		local ispre = false;
		if bccoin < payLogs.bycoin then
			UserInfo.getInstance():setBccoin(payLogs.bycoin);
			message = message.."元宝";
			ispre = true;
		end

		if soulcount < payLogs.chess_soul_num then
			UserInfo.getInstance():setSoulCount(payLogs.chess_soul_num);
			
			if ispre then
				message = message.."、棋魂";
			else
				message = message.."棋魂";
			end
			ispre = true;
		end

		if money < payLogs.money then
			UserInfo.getInstance():setMoney(payLogs.money);

			if ispre then
				message = message.."、金币";

			else
				message = message.."金币";
			end
			ispre = true;
		end

		if ispre then

			message = message.."已经到帐！";
            ChessToastManager.getInstance():show(message);
		end
	elseif  #payLogs >0 then
		local len = #payLogs;
		local count1=0;local count2=0;local count3=0;local count4=0;local count5=0;local count6=0;local count7=0;local count8=0;
		local msg1=nil;local msg2=nil;local msg3=nil;local msg4=nil;local msg5=nil;local msg6=nil;local msg7=nil;local msg8=nil;

		for i=1,len do

			local pallog =  payLogs[i];
			local propid = pallog.propid;
			local num = pallog.num;
			
		    local startNum = 0;
 			startNum = ExchangePay.getStartNum(propid);
		    if startNum == 1 then--生命回复
		    	msg1 = "生命回复"
			elseif startNum == 2 then --悔棋
				count2= count2+num;
				msg2 = count2.."个悔棋"
			elseif startNum == 3 then --提示
				count3= count3+num;
				msg3 = count3.."个提示"
			elseif startNum == 4 then --起死回生
				count4= count4+num;
				msg4 = count4.."个起死回生"
			elseif startNum == 5 then --增加生命上限
				msg5 = "生命上限+3"
		   	elseif startNum == 6 then--残局大关
				msg6 = "开通残局关卡"
		  	elseif startNum == 7 then--dapu
				msg7 = "打谱功能"
		   	elseif startNum == 8 then--单机大关
				msg8 = "开通单机大关卡"
			end

			PayUtil.payBudanLog(pallog,startNum);
		end

        controlerhandler:sendSocketMsg(HALL_MSG_RESPONSE_SERVER,payLogs.orderData, SUBCMD_LADDER, 2,"hall");
--      通知server
--	   	local processer = ProcessFactory.getInstance():getProcesser(HALL_MSG_RESPONSE_SERVER);--通知server
--		processer.doRequest(nil,payLogs.orderData);

		local isStart = true;
		if msg1 then
			message = message..msg1;
			isStart=false;
		end

		if msg2 then
			if not isStart then
				msg2 = ","..msg2
			else
				isStart=false;
			end

			message = message..msg2
		end

		if msg3 then
			if not isStart then
				msg3 = ","..msg3
			else
				isStart=false;
			end

			message = message..msg3
		end

		if msg4 then
			if not isStart then
				msg4 = ","..msg4
			else
				isStart=false;
			end

			message = message..msg4
		end

		if msg5 then
			if not isStart then
				msg5 = ","..msg5
			else
				isStart=false;
			end

			message = message..msg5
		end


		if msg6 then
			if not isStart then
				msg6 = ","..msg6
			else
				isStart=false;
			end

			message = message..msg6
		end

		if msg7 then
			if not isStart then
				msg7 = ","..msg7
			else
				isStart=false;
			end

			message = message..msg7
		end



		if msg8 then
			if not isStart then
				msg8 = ","..msg8
			else
				isStart=false;
			end

			message = message..msg8
		end

		message = message.."已经到帐！";

		ChessToastManager.getInstance():show(message);

	elseif #payLogs == 0  then
		local money = UserInfo:getInstance():getMoney();

		if money < payLogs.money then
			UserInfo:getInstance():setMoney(payLogs.money);
			
			message = message.."金币已经到帐！";
            ChessToastManager.getInstance():show(message);
		end
	end
end

PayUtil.payBudanLog = function(palLog,startNum)
	print_string("=======PayUtil.payBudanLog======");
--	UserInfo.getInstance():setPmode(PayInterface.pay_mode_egamepay);

	local pid = palLog.pid;
	local propid = palLog.propid;
	local num = palLog.num;


    if startNum == 1 then--生命回复
    	local limitNum = UserInfo:getInstance():getLifeLimitNum();
		UserInfo.getInstance():setLifeNum(limitNum + UserInfo.getInstance():getLifeNum());
	elseif startNum == 2 then --悔棋
		local undoNum = UserInfo:getInstance():getUndoNum();
		undoNum = undoNum + num; 
		UserInfo:getInstance():setUndoNum(undoNum);
	elseif startNum == 3 then --提示
		local tipsNum = UserInfo:getInstance():getTipsNum();
		tipsNum = tipsNum + num; 
		UserInfo:getInstance():setTipsNum(tipsNum);
	elseif startNum == 4 then --起死回生
		local reviveNum = UserInfo:getInstance():getReviveNum();
		reviveNum = reviveNum + num; 
		UserInfo:getInstance():setReviveNum(reviveNum);
	elseif startNum == 5 then --增加生命上限
		local limitNum = UserInfo:getInstance():getLifeLimitNum();
		limitNum = limitNum + num; 
		if limitNum <=14 then
			UserInfo:getInstance():setLifeLimitNum(limitNum);
		end
   	elseif startNum == 6 then--残局大关
		dict_set_string(kEndGateReplace,kEndGateReplace..kparmPostfix,""..UserInfo.getInstance():getUid());
		call_native(kEndGateReplace);
  	elseif startNum == 7 then--dapu
  		UserInfo.getInstance():setDapuEnable(1);
   	elseif startNum == 8 then--单机大关
--   		if UserInfo.getInstance():getPlayConsoleFlag() == 1 and UserInfo.getInstance():getPlayConsoleCount() >= 3 then
--			UserInfo.getInstance():setPlayConsoleFlag(0);
--			PHPInterface.uploadConsoleProgress(true);
--		else
--			UserInfo.getInstance():setHasConsoleNeedBuy(false);
--			local uid = UserInfo.getInstance():getUid();
--			local level = GameCacheData.getInstance():getInt(GameCacheData.CONSOLE_MAX_LEVEL .. uid,0);
--			local newLevel = (math.floor(level/AI_EVERY_GATE_NUM)+1) * AI_EVERY_GATE_NUM;
--		 	GameCacheData.getInstance():saveInt(GameCacheData.CONSOLE_MAX_LEVEL .. uid,newLevel);
--			PHPInterface.uploadConsoleProgress();
--		end
	end

	-- GameCacheData.getInstance():saveBoolean("bool"..pid,false);
--  同步数据
    ExchangePay.uploadOrDownPropData(1);

	local posStr = GameCacheData.getInstance():getString("str"..pid,"-1");
    ExchangePay.addDeliverLog(pid,propid,tonumber(posStr))

end