--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/24
require("util/game_cache_data")
EndgateData = class(GameCacheData,false);

EndgateData.ENDGAME_VERSION = "endgame_version";    --残局版本号
EndgateData.ENDGAME_GATE_NUM = "endgame_gate_num";    --残局大关卡数
EndgateData.ENDGAME_DATA = "endgame_data"             --残局关卡数据

EndgateData.ctor = function(self)
	self.m_dict = new(Dict,"endgate_data");
	self.m_dict:load();
	EventDispatcher.getInstance():register(Event.Call,self,self.onNativeCallDone);
end

EndgateData.getInstance = function()
	if not EndgateData.s_endgate_instance then
		EndgateData.s_endgate_instance = new(EndgateData);
--        EndgateData.s_isCreateInit = true;
        -- 提高win32下启动速度
        if not "win32"==System.getPlatform() then
            EndgateData.s_endgate_instance:getEndgateData();
        end
	end
	return EndgateData.s_endgate_instance;
end

EndgateData.setGateTids = function(self,tids)
	self.m_tids = tids;
end

EndgateData.getGateTids = function (self)
	return self.m_tids;
end

--用户选择的大关卡
EndgateData.setGate = function(self,gate)--对应Gate.java
	self.m_gate = gate;
	self:setGateTid(gate.tid);
end

EndgateData.getGate = function(self)
	return self.m_gate;
end

--用户选择的大关卡TID
EndgateData.setGateTid = function(self,gate_tid)
	self.m_gate_tid = gate_tid;
end
EndgateData.getGateTid = function(self)
	if self.m_gate then
		return self.m_gate.tid;
	else
		return nil;
	end

	--return self.m_gate_tid or 0;
end

--用户选择的大关卡的某一小关
EndgateData.setGateSort = function(self,gate_sort)
	self.m_gate_sort = gate_sort;
end

EndgateData.getGateSort = function(self)
	return self.m_gate_sort or 0;
end

EndgateData.setEndingUpdateNum = function(self,num)--残局更新数
	self.m_ending_update_num = num;
end

EndgateData.getEndingUpdateNum = function(self)
	return self.m_ending_update_num or 0;
end

--残局
EndgateData.setIsNeedPayGate= function(self,needPay)
	self.m_needPay = needPay;
end

EndgateData.IsNeedPayGate = function(self)
	return self.m_needPay or false;
end

--是不是最新的关卡
EndgateData.isLatestGate = function(self)
	local uid = UserInfo.getInstance():getUid();
	local latest_tid = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_GATE .. uid,17);
	local latest_sort = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_SORT .. uid,0);


	local tid = self:getGateTid();
	local sort = self:getGateSort();
	tid = tonumber(tid);
	sort = tonumber(sort);

	print_string(string.format("latest_tid = %d,latest_sort = %d,tid = %d,sort = %d",latest_tid,latest_sort,tid,sort));

	if latest_tid == -1 or  (tid == latest_tid and sort >= latest_sort) then

		return true
	end

	return  false;
end

--是否为最后一小关
EndgateData.isLastGate = function (self)
	local max = self:getGate().chessrecord_size;
	local gate_sort = self:getGateSort();
	if (gate_sort+1) == max then
		return true;
	end
	return false;
end

EndgateData.setLatestGate = function(self)
	print_string("EndgateData.setLatestGate ");
	if not self:isLatestGate() then
		return;
	end

	local uid = UserInfo.getInstance():getUid();
	local tid = self:getGateTid();
	local sort = self:getGateSort();
	
	tid = tonumber(tid);
	sort = tonumber(sort);

	print_string(string.format("tid = %d,sort = %d",tid,sort));
	GameCacheData.getInstance():saveInt(GameCacheData.ENDGAME_LATETST_GATE .. uid,tid);
	GameCacheData.getInstance():saveInt(GameCacheData.ENDGAME_LATETST_SORT .. uid,sort+1);
end

EndgateData.setBoardTable = function(self,board_table)
    self.m_borad_table = board_table;
end

EndgateData.getBoardTableId = function(self)
    if self.m_borad_table then
        return self.m_borad_table.id or -1;
    end
    return -1;
end

EndgateData.getBoardTableSubTitle = function(self)
    if self.m_borad_table then
        return self.m_borad_table.SubTitle or "";
    end
    return "";
end

EndgateData.setWinEndGateGetSoulRate= function(self,rate)
	if rate then
		self.m_endgate_getsoul_rate= 100*rate;
	else
		self.m_endgate_getsoul_rate= 0;
	end
end

EndgateData.getWinEndGateGetSoulRate= function(self)
	return self.m_endgate_getsoul_rate or 0;
end

EndgateData.analyzeJsonNode = function(data)
    local ret = {};
    if data then
        function analyze(node,t)
            for i,k in pairs(t) do
                local a = k:get_value();
                if type(a) == "table" then
                    node[i] = {};
                    analyze(node[i],k);
                else
                    node[i] = k:get_value();
                end
            end
        end
        analyze(ret,data);
    end
    return ret;
end

EndgateData.setStartTime = function(self,time)
    self.m_start_time = time;
end

EndgateData.getStartTime = function(self)
    return self.m_start_time or -1;
end

EndgateData.getPlayCreateEndingDataID = function(self)
    return self.m_play_create_ending_data_id;
end

EndgateData.setPlayCreateEndingData = function(self,data)
    self.m_play_create_ending_data_id = data.booth_id
    self.m_play_create_ending_data = data;
end

EndgateData.getPlayCreateEndingData = function(self)
    return self.m_play_create_ending_data;
end

EndgateData.getEndgateData = function(self)
    if "win32"==System.getPlatform() then
	    if self.m_endgateData == nil then
            local ret,errMessage = pcall(
                function() -- 捕捉到异常后把数据清理
                        local str = self:getString(GameCacheData.ENDGAME_DATA,nil);
                        local data;
                        if str == nil then
                            data = EndgateData.ChangeTonumber(json.decode(EndgateData.s_endgateData));
                        else
                            data = EndgateData.ChangeTonumber(json.decode(str));
                        end
                    return data;
                end
            );
            if ret and errMessage then
                self.m_endgateData ={};
                for i,v in ipairs(errMessage) do
                    self.m_endgateData[i] = v.gate;
                    self.m_endgateData[i].chessrecord_size = #v.chessrecord;
                    self.m_endgateData[i].chessrecord = v.chessrecord;
                end
                return self.m_endgateData;
            else
                self.m_endgateData = {}
                local data = EndgateData.ChangeTonumber(json.decode(EndgateData.s_endgateData));
                for i,v in ipairs(data) do
                    self.m_endgateData[i] = v.gate;
                    self.m_endgateData[i].chessrecord_size = #v.chessrecord;
                    self.m_endgateData[i].chessrecord = v.chessrecord;
                end
                return self.m_endgateData;
            end
        end
        return self.m_endgateData;
    elseif "android"==System.getPlatform() or "ios"==System.getPlatform() then
        if not self.m_endgateData then
            local str = self:getString(GameCacheData.ENDGAME_DATA,nil) or EndgateData.s_endgateData;
	        dict_set_string(kEndingUtilNewInit,kEndingUtilNewInit..kparmPostfix,str);
            call_native(kEndingUtilNewInit);
        end
        return self.m_endgateData or {};
    end
end

EndgateData.saveEndgateData = function(self,data)
    self:saveString(GameCacheData.ENDGAME_DATA,data);
--    ChessToastManager.getInstance():showSingle("正在更新残局关卡");
    if "win32"==System.getPlatform() then
        local edata = EndgateData.ChangeTonumber(json.decode(data));
        for i,v in ipairs(edata) do
            self.m_endgateData[i] = v.gate;
            self.m_endgateData[i].chessrecord_size = #v.chessrecord;
            self.m_endgateData[i].chessrecord = v.chessrecord;
        end
    elseif "android"==System.getPlatform() or "ios"==System.getPlatform() then
        dict_set_string(kEndingUtilNewInit,kEndingUtilNewInit..kparmPostfix,data);
        call_native(kEndingUtilNewInit);
    end
end

EndgateData.ChangeTonumber = function(data)
    if data then
        function analyze(t)
            for i,k in pairs(t) do
                if type(k) == "table" then
                    analyze(k);
                else
                    local a = tonumber(k);
                    if a then
                        t[i] = a;
                    end
                end
            end
        end
        analyze(data);
    end
    return data;
end

EndgateData.onNativeCallDone = function(self ,param , ...)
	if self.s_nativeEventFuncMap[param] then
		self.s_nativeEventFuncMap[param](self,...);
	end
end

EndgateData.initData = function(self,status,json_data)
    if not status then
        ChessToastManager.getInstance():showSingle("残局初始化失败！");
        EndgateData.getInstance():saveInt(GameCacheData.ENDGAME_VERSION_NEW,0);
        return ;
    end
    json_data = json.analyzeJsonNode(json_data);
    if not json_data then
        ChessToastManager.getInstance():showSingle("残局数据错误，请联系GM");
        EndgateData.getInstance():saveInt(GameCacheData.ENDGAME_VERSION_NEW,0);
        return ;
    end 
--    if EndgateData.s_isCreateInit == false then
--        ChessToastManager.getInstance():showSingle("残局初始化完成");
--    end
--    EndgateData.s_isCreateInit = false;
    self.m_endgateData = EndgateData.ChangeTonumber(json_data);
end

EndgateData.s_nativeEventFuncMap = {
    [kEndingUtilNewInit]                            = EndgateData.initData;
};

EndgateData.s_endgateData = '[{"gate":{"tid":"17","title":"初入江湖","desc":"兵卒类残局是最简单也是最基本的残局","fee":"0","hp":"0","repentance":"0","revival":"0","prompt":"0","version":"1450412707","status":"3","sort":"0","asset_index":"1","title_img":"https:\/\/cdnsource.17c.cn\/chess\/booth\/5591c42d244989333156d081c846429a.png?v=","gate_img":"https:\/\/cdnsource.17c.cn\/chess\/booth\/bde70f765948cfc2c1f6b47b6bac2aca.png?v=","can_edit":"0","is_publish":"1"},"chessrecord":[{"id":"738","prompt":"1","pay":"0","SubTitle":"马到成功","fen":"3ak4\/4a4\/9\/7N1\/9\/9\/9\/9\/9\/5K3 r","sort":"0","move":{"movelist":[{"src":"00","dst":"00"},{"src":"73","dst":"61"}]}},{"id":"724","prompt":"1","pay":"0","SubTitle":"风雷火炮","fen":"2bakab2\/1R7\/9\/2C6\/9\/4C4\/7c1\/4B4\/4A1r2\/2BAK3c r","sort":"1","move":{"movelist":[{"src":"00","dst":"00"},{"src":"23","dst":"43"}]}},{"id":"739","prompt":"1","pay":"0","SubTitle":"见缝插针","fen":"3ak1r2\/4aPN2\/9\/9\/9\/9\/9\/4B4\/4A4\/3A1KB2 r","sort":"2","move":{"movelist":[{"src":"00","dst":"00"},{"src":"51","dst":"50"}]}},{"id":"716","prompt":"1","pay":"0","SubTitle":"上兵伐谋","fen":"4ka3\/2P1a4\/9\/9\/9\/9\/9\/9\/9\/4K4 r","sort":"3","move":{"movelist":[{"src":"00","dst":"00"},{"src":"21","dst":"31"}]}},{"id":"740","prompt":"1","pay":"0","SubTitle":"身先士卒","fen":"2b1kc3\/3P5\/2N1b4\/9\/9\/9\/9\/9\/9\/3AKA3 r","sort":"4","move":{"movelist":[{"src":"00","dst":"00"},{"src":"31","dst":"41"}]}},{"id":"741","prompt":"1","pay":"0","SubTitle":"龙战鱼骇","fen":"4ka3\/3Pa4\/9\/6R2\/9\/9\/9\/2nA5\/7r1\/4KA3 r","sort":"5","move":{"movelist":[{"src":"00","dst":"00"},{"src":"31","dst":"41"},{"src":"50","dst":"41","sub":["1"]},{"src":"63","dst":"60"}],"submovelist":{"1":[{"src":"40","dst":"30"},{"src":"63","dst":"33"}]}}},{"id":"715","prompt":"1","pay":"0","SubTitle":"紧追不舍","fen":"5a3\/3k3N1\/1R1cba3\/6N2\/5r3\/9\/9\/9\/4p4\/3K2B2 r","sort":"6","move":{"movelist":[{"src":"00","dst":"00"},{"src":"12","dst":"32"},{"src":"31","dst":"41"},{"src":"32","dst":"42"}]}},{"id":"719","prompt":"1","pay":"0","SubTitle":"勇往直前","fen":"2bak1r2\/4aR3\/4b4\/4C4\/9\/2R6\/9\/9\/4pc3\/5K3 r","sort":"7","move":{"movelist":[{"src":"00","dst":"00"},{"src":"51","dst":"41"},{"src":"30","dst":"41"},{"src":"25","dst":"20"}]}},{"id":"725","prompt":"1","pay":"0","SubTitle":"倒载干戈","fen":"3k5\/6R1C\/3c5\/6N2\/6b2\/9\/9\/9\/2r1p1p2\/5K3 r","sort":"8","move":{"movelist":[{"src":"00","dst":"00"},{"src":"61","dst":"60"},{"src":"30","dst":"31"},{"src":"63","dst":"51"}]}},{"id":"717","prompt":"1","pay":"0","SubTitle":"冲锋陷阵","fen":"2R2ab2\/3kac1N1\/2Nr5\/2R6\/9\/9\/9\/9\/1r7\/3AKABc1 r","sort":"9","move":{"movelist":[{"src":"00","dst":"00"},{"src":"20","dst":"30"},{"src":"41","dst":"30"},{"src":"71","dst":"50"}]}},{"id":"721","prompt":"1","pay":"0","SubTitle":"步步紧逼","fen":"3k5\/2P1a4\/1c7\/1r3N3\/9\/9\/6R2\/C8\/4p4\/5K3 r","sort":"10","move":{"movelist":[{"src":"00","dst":"00"},{"src":"66","dst":"60"},{"src":"41","dst":"50"},{"src":"60","dst":"50"}]}},{"id":"704","prompt":"1","pay":"0","SubTitle":"挥戈止日","fen":"2bk1a3\/2R3R2\/4ba3\/9\/9\/9\/3rc4\/4B4\/4A4\/4KAB2 r","sort":"11","move":{"movelist":[{"src":"00","dst":"00"},{"src":"61","dst":"31"},{"src":"36","dst":"31"},{"src":"21","dst":"20"}]}},{"id":"720","prompt":"1","pay":"0","SubTitle":"追风蹑影","fen":"4kab2\/3PaR1N1\/4b4\/9\/9\/9\/9\/2n6\/3r1p3\/2BAKAB2 r","sort":"12","move":{"movelist":[{"src":"00","dst":"00"},{"src":"51","dst":"50"},{"src":"41","dst":"50"},{"src":"71","dst":"52"}]}},{"id":"722","prompt":"1","pay":"0","SubTitle":"放牛归马","fen":"1C2ka3\/2c1a4\/1N2b4\/9\/9\/9\/9\/4BR3\/4p1r2\/5K3 r","sort":"13","move":{"movelist":[{"src":"00","dst":"00"},{"src":"57","dst":"50"},{"src":"41","dst":"50"},{"src":"12","dst":"20"}]}},{"id":"702","prompt":"1","pay":"0","SubTitle":"七夕天河","fen":"2ba1kbRC\/2N1a4\/9\/4p4\/4c1p2\/9\/9\/1p2B4\/4r4\/3K2B2 r","sort":"14","move":{"movelist":[{"src":"00","dst":"00"},{"src":"21","dst":"42","comment":"这是古谱向我们提供的绝好着法，黑方无法解救"},{"src":"20","dst":"42","sub":["1","2","3"]},{"src":"70","dst":"71"}],"submovelist":{"1":[{"src":"17","dst":"27"},{"src":"70","dst":"60"},{"src":"50","dst":"51"},{"src":"42","dst":"63"},{"src":"51","dst":"52"},{"src":"60","dst":"62"},{"src":"52","dst":"51"},{"src":"62","dst":"72"},{"src":"51","dst":"50"},{"src":"72","dst":"70"}],"2":[{"src":"44","dst":"42"},{"src":"70","dst":"71"}],"3":[{"src":"50","dst":"40"},{"src":"70","dst":"60"},{"src":"41","dst":"50"},{"src":"42","dst":"61","sub":["4"]},{"src":"40","dst":"41"},{"src":"80","dst":"81"}],"4":[{"src":"42","dst":"21"},{"src":"40","dst":"41"},{"src":"60","dst":"61"}]}}},{"id":"727","prompt":"1","pay":"0","SubTitle":"连锁效应","fen":"1Cbak4\/3Ra1R2\/4b1n2\/9\/9\/9\/9\/9\/4p1r2\/5K3 r","sort":"15","move":{"movelist":[{"src":"00","dst":"00"},{"src":"61","dst":"41"},{"src":"62","dst":"41"},{"src":"31","dst":"30"}]}},{"id":"718","prompt":"1","pay":"0","SubTitle":"黄雀在后","fen":"2baka3\/2P6\/c3b4\/9\/9\/1C7\/9\/3RB4\/4p1r2\/5KB2 r","sort":"16","move":{"movelist":[{"src":"00","dst":"00"},{"src":"37","dst":"30"},{"src":"40","dst":"30"},{"src":"15","dst":"10"}]}},{"id":"285","prompt":"1","pay":"0","SubTitle":"夹竹栽桃","fen":"3a5\/3k2C2\/2Pa2R2\/9\/9\/2B6\/9\/9\/1p2r4\/3K5 r","sort":"17","move":{"movelist":[{"src":"00","dst":"00"},{"src":"62","dst":"68","comment":"如图的形势:黑方车占花心，横卒隔步成杀；红方炮已控制下二线，黑士不能动，如再控制中路，进兵即胜。现在红方弃车引离黑车，是唯一正确明智的决策。"},{"src":"48","dst":"68"},{"src":"39","dst":"49","comment":"弃炮进帅控制中路，与前着弃车引离相联系，同时远离黑卒一步，长了一口气，铸成独兵制胜的不朽之作。"},{"src":"68","dst":"61"},{"src":"22","dst":"21"}]}},{"id":"732","prompt":"1","pay":"0","SubTitle":"三仙出游","fen":"4ka1R1\/3Ra1rC1\/4b4\/9\/9\/9\/9\/4B3B\/4p1r2\/5K3 r","sort":"18","move":{"movelist":[{"src":"00","dst":"00"},{"src":"31","dst":"41"},{"src":"61","dst":"41"},{"src":"70","dst":"50"}]}},{"id":"728","prompt":"1","pay":"0","SubTitle":"所向披靡","fen":"1r3ab2\/3kaP3\/2R6\/2N6\/2b1p4\/2C6\/9\/1n1AB4\/4A4\/3K5 r","sort":"19","move":{"movelist":[{"src":"00","dst":"00"},{"src":"22","dst":"12"},{"src":"31","dst":"30"},{"src":"12","dst":"10"}]}},{"id":"731","prompt":"1","pay":"0","SubTitle":"如影相随","fen":"2bk1a3\/4a4\/4cc3\/2N1C4\/9\/9\/9\/4B1n2\/5p3\/C3K1B2 r","sort":"20","move":{"movelist":[{"src":"00","dst":"00"},{"src":"23","dst":"11"},{"src":"30","dst":"31"},{"src":"09","dst":"01"}]}},{"id":"729","prompt":"1","pay":"0","SubTitle":"戎马倥傯","fen":"3cka3\/3R5\/9\/3Np4\/C8\/9\/7r1\/9\/4p4\/5K3 r","sort":"21","move":{"movelist":[{"src":"00","dst":"00"},{"src":"04","dst":"44"},{"src":"43","dst":"44"},{"src":"33","dst":"52"}]}},{"id":"733","prompt":"1","pay":"0","SubTitle":"血风肉雨","fen":"4kab1C\/3RaR3\/2n1b4\/9\/4c4\/4r4\/9\/9\/4A1r2\/3AK4 r","sort":"22","move":{"movelist":[{"src":"00","dst":"00"},{"src":"31","dst":"41"},{"src":"44","dst":"41"},{"src":"51","dst":"50"}]}},{"id":"726","prompt":"1","pay":"0","SubTitle":"鸟枪换炮","fen":"4kaR2\/4a4\/4NR3\/9\/9\/2C6\/2c6\/5p3\/4p4\/3p1K3 r","sort":"23","move":{"movelist":[{"src":"00","dst":"00"},{"src":"52","dst":"50"},{"src":"41","dst":"50"},{"src":"25","dst":"45"}]}},{"id":"830","prompt":"1","pay":"0","SubTitle":"诸葛平蛮","fen":"3akab2\/C1R5c\/N2cb4\/9\/7N1\/9\/9\/9\/3p1p1r1\/4K4 r","sort":"24","move":{"movelist":[{"src":"00","dst":"00"},{"src":"01","dst":"00"},{"src":"30","dst":"41"},{"src":"02","dst":"10"},{"src":"32","dst":"30","sub":["1"]},{"src":"10","dst":"31"}],"submovelist":{"1":[{"src":"41","dst":"30"},{"src":"10","dst":"22"},{"src":"30","dst":"41"},{"src":"21","dst":"20"},{"src":"41","dst":"30"},{"src":"20","dst":"30"},{"src":"40","dst":"41"},{"src":"74","dst":"62"},{"src":"41","dst":"51"},{"src":"30","dst":"50"}]}}},{"id":"681","prompt":"1","pay":"0","SubTitle":"鞠躬尽瘁","fen":"2b2k3\/5c3\/cC7\/9\/9\/9\/9\/3C5\/4A4\/4K4 r","sort":"25","move":{"movelist":[{"src":"00","dst":"00"},{"src":"12","dst":"10"},{"src":"20","dst":"42"},{"src":"37","dst":"30"},{"src":"42","dst":"20"},{"src":"30","dst":"31"}]}},{"id":"691","prompt":"1","pay":"0","SubTitle":"釜底抽薪","fen":"2ba5\/5k3\/4ba3\/3N5\/4P4\/8C\/n8\/9\/4p4\/3K5 r","sort":"26","move":{"movelist":[{"src":"00","dst":"00"},{"src":"85","dst":"55"},{"src":"52","dst":"41"},{"src":"33","dst":"52"},{"src":"51","dst":"52"},{"src":"44","dst":"54"}]}},{"id":"695","prompt":"1","pay":"0","SubTitle":"牧羊北海","fen":"4k4\/3Pa4\/4b4\/9\/2b2N3\/7R1\/9\/9\/2rp5\/4KA3 r","sort":"27","move":{"movelist":[{"src":"00","dst":"00"},{"src":"31","dst":"41"},{"src":"40","dst":"41"},{"src":"54","dst":"62"},{"src":"41","dst":"40"},{"src":"75","dst":"70"}]}},{"id":"705","prompt":"1","pay":"0","SubTitle":"两军对垒","fen":"9\/3kaP3\/3ab4\/4R4\/3Rp4\/9\/7rc\/4B4\/4p4\/5KB2 r","sort":"28","move":{"movelist":[{"src":"00","dst":"00"},{"src":"51","dst":"41","comment":" 弃兵，破士引将，是入局的好着。"},{"src":"31","dst":"41"},{"src":"43","dst":"42","comment":" 弃车，吃象引将，是本局成杀的中心环节。"},{"src":"41","dst":"42","comment":" 只好进将吃车，如改走将平，车六进二，红胜。"},{"src":"34","dst":"44","comment":"本局红方连弃二子成杀，体现了双车兵联攻的裸露和简明。"}]}},{"id":"698","prompt":"1","pay":"0","SubTitle":"险峰探胜","fen":"3ak4\/9\/2Ca5\/9\/7R1\/9\/7p1\/4C4\/4p2r1\/2B2K3 r","sort":"29","move":{"movelist":[{"src":"00","dst":"00"},{"src":"74","dst":"70"},{"src":"40","dst":"41"},{"src":"70","dst":"71"},{"src":"41","dst":"40"},{"src":"22","dst":"20"}]}},{"id":"703","prompt":"1","pay":"0","SubTitle":"突破重围","fen":"2bak2r1\/4aP2R\/4b4\/4Cn2p\/9\/2N6\/9\/9\/4p4\/2B2K3 r","sort":"30","move":{"movelist":[{"src":"00","dst":"00"},{"src":"81","dst":"80"},{"src":"70","dst":"80"},{"src":"25","dst":"13"},{"src":"80","dst":"70"},{"src":"13","dst":"21"}]}},{"id":"828","prompt":"1","pay":"0","SubTitle":"劣马奔泉","fen":"1c1k1P3\/4PC3\/4cN3\/9\/9\/4C4\/9\/4p1n2\/3r5\/4K4 r","sort":"31","move":{"movelist":[{"src":"00","dst":"00"},{"src":"50","dst":"40"},{"src":"42","dst":"40"},{"src":"41","dst":"31","comment":"连弃双兵，此着尤妙，既不为对方充当炮架，又逼黑炮为红方利用。"},{"src":"38","dst":"31"},{"src":"51","dst":"50"},{"src":"40","dst":"42"},{"src":"52","dst":"40"}]}},{"id":"706","prompt":"1","pay":"0","SubTitle":"天马行空","fen":"3ak4\/4a2N1\/4c4\/9\/9\/1R7\/9\/9\/2p1r4\/3K1R3 r","sort":"32","move":{"movelist":[{"src":"00","dst":"00"},{"src":"59","dst":"50","comment":"这种杀着俗称“掖车挂”。"},{"src":"41","dst":"50"},{"src":"71","dst":"52"},{"src":"40","dst":"41"},{"src":"15","dst":"11"}]}},{"id":"730","prompt":"1","pay":"0","SubTitle":"矢石之难","fen":"2r1ka3\/3R3P1\/5a3\/9\/9\/9\/n8\/5p3\/9\/2BKC1B2 r","sort":"33","move":{"movelist":[{"src":"00","dst":"00"},{"src":"31","dst":"41"},{"src":"40","dst":"41"},{"src":"29","dst":"47"},{"src":"41","dst":"51"},{"src":"71","dst":"61"}]}},{"id":"734","prompt":"1","pay":"0","SubTitle":"车笠之盟","fen":"4kab2\/4a4\/2N1b4\/9\/9\/1R7\/5r3\/2c1BA3\/6n2\/2BA1KC2 r","sort":"34","move":{"movelist":[{"src":"00","dst":"00"},{"src":"69","dst":"60"},{"src":"42","dst":"60"},{"src":"15","dst":"10"},{"src":"41","dst":"30"},{"src":"10","dst":"30"}]}},{"id":"708","prompt":"1","pay":"0","SubTitle":"山川王气","fen":"C1bakr3\/3RC1R2\/2n1b4\/4p4\/6n2\/9\/9\/4B4\/6p2\/4KABc1 r","sort":"35","move":{"movelist":[{"src":"00","dst":"00"},{"src":"41","dst":"43"},{"src":"64","dst":"43"},{"src":"61","dst":"41"},{"src":"22","dst":"41"},{"src":"31","dst":"30"}]}},{"id":"743","prompt":"1","pay":"0","SubTitle":"左右开攻","fen":"2bk5\/4aR3\/c2cb4\/9\/9\/9\/9\/1C5R1\/2r1p4\/3K5 r","sort":"36","move":{"movelist":[{"src":"00","dst":"00"},{"src":"17","dst":"10"},{"src":"30","dst":"31"},{"src":"51","dst":"41"},{"src":"31","dst":"41"},{"src":"77","dst":"71"}]}},{"id":"736","prompt":"1","pay":"0","SubTitle":"车马骈阗","fen":"4ka3\/1N2a4\/4c4\/9\/9\/7R1\/9\/9\/4r1p2\/3R1K3 r","sort":"37","move":{"movelist":[{"src":"00","dst":"00"},{"src":"39","dst":"30"},{"src":"41","dst":"30"},{"src":"11","dst":"32"},{"src":"40","dst":"41"},{"src":"75","dst":"71"}]}},{"id":"735","prompt":"1","pay":"0","SubTitle":"倒拔垂杨","fen":"3aka3\/9\/9\/6C2\/2n6\/9\/9\/4C4\/9\/4K4 r","sort":"38","move":{"movelist":[{"src":"00","dst":"00"},{"src":"63","dst":"43"},{"src":"24","dst":"45"},{"src":"43","dst":"41","comment":"弃炮禁锢将府，是入局的唯一诀窍。"},{"src":"30","dst":"41"},{"src":"49","dst":"39","comment":"平帅控制肋道。至此黑方无子可动，被红方困杀。"}]}},{"id":"745","prompt":"1","pay":"0","SubTitle":"高沟深垒","fen":"2b1kaR2\/4a4\/9\/4R2N1\/9\/9\/9\/4B4\/3rA4\/2B1KA1rc r","sort":"39","move":{"movelist":[{"src":"00","dst":"00"},{"src":"73","dst":"52"},{"src":"40","dst":"30"},{"src":"60","dst":"50"},{"src":"41","dst":"50"},{"src":"43","dst":"40"}]}},{"id":"742","prompt":"1","pay":"0","SubTitle":"创造时机","fen":"4kaR2\/4aR3\/9\/9\/9\/9\/9\/6C2\/4r1p2\/5K3 r","sort":"40","move":{"movelist":[{"src":"00","dst":"00"},{"src":"60","dst":"50"},{"src":"41","dst":"50"},{"src":"67","dst":"60"},{"src":"50","dst":"41"},{"src":"51","dst":"50"}]}},{"id":"831","prompt":"1","pay":"0","SubTitle":"左右逢源　","fen":"4ka3\/3Pa4\/r6R1\/2C4C1\/9\/9\/8n\/9\/4p3r\/3K3R1 r","sort":"41","move":{"movelist":[{"src":"00","dst":"00"},{"src":"31","dst":"30","comment":"首着进兵，出奇制胜。如改走炮二平五，则士进拦车，黑方获胜。又如改走车二平九，卒平，帅六平五，车平，帅五平四，马进，黑胜。"},{"src":"41","dst":"30"},{"src":"72","dst":"42"},{"src":"02","dst":"42"},{"src":"73","dst":"70","comment":"弃车后发挥双炮的作用，“左右逢源”恰到好处。"},{"src":"50","dst":"41"},{"src":"23","dst":"20","comment":"原图无黑马。首着可走车二平九，虽然也是红胜，但不合题意，与“提示”亦不相符，为此在黑方增添边马。"}]}},{"id":"750","prompt":"1","pay":"0","SubTitle":"啬己奉公","fen":"5ab2\/8R\/3a1k3\/4RcN2\/2b6\/9\/9\/4B4\/3p1r3\/4K4 r","sort":"42","move":{"movelist":[{"src":"00","dst":"00"},{"src":"81","dst":"51"},{"src":"53","dst":"51"},{"src":"43","dst":"42"},{"src":"24","dst":"42"},{"src":"63","dst":"44"}]}},{"id":"748","prompt":"1","pay":"0","SubTitle":"拦截去路","fen":"3ak4\/4a4\/4b4\/2r1C4\/6N2\/9\/9\/5R3\/1p7\/c2K2B2 r","sort":"43","move":{"movelist":[{"src":"00","dst":"00"},{"src":"64","dst":"52"},{"src":"40","dst":"50"},{"src":"52","dst":"71"},{"src":"50","dst":"40"},{"src":"57","dst":"50"}]}},{"id":"749","prompt":"1","pay":"0","SubTitle":"引狼入室","fen":"2bak1b2\/4a4\/4c4\/9\/9\/5R3\/9\/7C1\/4r4\/2B2KB2 r","sort":"44","move":{"movelist":[{"src":"00","dst":"00"},{"src":"77","dst":"70"},{"src":"41","dst":"50"},{"src":"55","dst":"50"},{"src":"40","dst":"41"},{"src":"50","dst":"51"}]}},{"id":"747","prompt":"1","pay":"0","SubTitle":"春风解冻","fen":"9\/3k5\/2Pa1a3\/9\/9\/9\/9\/6C2\/9\/4K4 r","sort":"45","move":{"movelist":[{"src":"00","dst":"00"},{"src":"22","dst":"21","comment":"冲兵直下，控制底线，压缩将的活动范围。"},{"src":"31","dst":"30"},{"src":"21","dst":"20"},{"src":"30","dst":"31"},{"src":"67","dst":"61","comment":"借用士做无形的炮架，控制下二线。黑方欠行，红胜。"}]}},{"id":"751","prompt":"1","pay":"0","SubTitle":"金戈铁马","fen":"5ab2\/3ka4\/2R1n4\/2Nc5\/9\/9\/9\/4B4\/2r1A4\/3AK4 r","sort":"46","move":{"movelist":[{"src":"00","dst":"00"},{"src":"22","dst":"21"},{"src":"31","dst":"32"},{"src":"21","dst":"31"},{"src":"33","dst":"31"},{"src":"23","dst":"44"}]}},{"id":"752","prompt":"1","pay":"0","SubTitle":"柳暗花明","fen":"2ba1a2N\/4k4\/4b3N\/9\/4n1n2\/9\/9\/3K1p3\/3cp4\/7R1 r","sort":"47","move":{"movelist":[{"src":"00","dst":"00"},{"src":"79","dst":"71"},{"src":"41","dst":"40"},{"src":"80","dst":"61"},{"src":"40","dst":"41"},{"src":"61","dst":"53"},{"src":"41","dst":"40"},{"src":"82","dst":"61"}]}},{"id":"753","prompt":"1","pay":"0","SubTitle":"塞翁失马","fen":"3a3nC\/1R4c2\/2C1k2r1\/9\/9\/r6N1\/9\/9\/4p4\/3K5 r","sort":"48","move":{"movelist":[{"src":"00","dst":"00"},{"src":"75","dst":"63"},{"src":"42","dst":"52"},{"src":"11","dst":"51"},{"src":"70","dst":"51"},{"src":"80","dst":"50"}]}},{"id":"699","prompt":"1","pay":"0","SubTitle":"攻其不备","fen":"C3kab2\/4a4\/3rb4\/4p4\/CR7\/6B2\/9\/5An2\/5p3\/4K4 r","sort":"49","move":{"movelist":[{"src":"00","dst":"00"},{"src":"14","dst":"10"},{"src":"41","dst":"30"},{"src":"10","dst":"12","comment":"借炮使车，阻挡黑车解救，是本局制胜的关键。"},{"src":"30","dst":"41"},{"src":"00","dst":"10","comment":"平炮叫杀，与前着挡车相联系，红方胜定。"},{"src":"40","dst":"30"},{"src":"04","dst":"00"},{"src":"30","dst":"31"},{"src":"12","dst":"11"}]}}]}]'
--EndgateData.s_endgateData = '[{"revival":"0","chessrecord_size":50,"title":"初入江湖","title_img":"https://192.168.100.153/runtime/booth_title_img/1-1.png","gate_img":"https://192.168.100.153/runtime/booth_title_img/1.png","hp":"0","desc":"兵卒类残局是最简单也是最基本的残局","asset_index":"1","sort":"0","fee":"0","version":"1449740354","status":"3","prompt":"0","tid":"17","repentance":"0"},{"revival":"0","chessrecord_size":50,"title":"渐入佳境","title_img":"https://192.168.100.153/runtime/booth_title_img/2-1.png","gate_img":"https://192.168.100.153/runtime/booth_title_img/2.png","hp":"0","desc":"实用的攻杀技巧","asset_index":"2","sort":"1","fee":"800","version":"1449714661","status":"3","prompt":"0","tid":"21","repentance":"0"},{"revival":"0","chessrecord_size":50,"title":"小有所成","title_img":"https://192.168.100.153/runtime/booth_title_img/3-1.png","gate_img":"https://192.168.100.153/runtime/booth_title_img/3.png","hp":"0","desc":"精辟分析棋中奥妙","asset_index":"3","sort":"2","fee":"1000","version":"1449714693","status":"3","prompt":"0","tid":"22","repentance":"0"},{"revival":"0","chessrecord_size":50,"title":"古谱精编(一)","title_img":"https://192.168.100.153/runtime/booth_title_img/4-1.png","gate_img":"https://192.168.100.153/runtime/booth_title_img/4.png","hp":"0","desc":"汇集古谱精华，以精妙杀局为主","asset_index":"4","sort":"3","fee":"0","version":"1449714718","status":"3","prompt":"0","tid":"23","repentance":"0"},{"revival":"0","chessrecord_size":50,"title":"古谱精编(二)","title_img":"https://192.168.100.153/runtime/booth_title_img/5-1.png","gate_img":"https://192.168.100.153/runtime/booth_title_img/5.png","hp":"0","desc":"汇集古谱精华，以精妙杀局为主","asset_index":"5","sort":"4","fee":"0","version":"1449714754","status":"3","prompt":"0","tid":"24","repentance":"0"}]'
kEndgateData = EndgateData.getInstance();


