-- friendsinfoRecordItem.lua
-- Author: ChaoYuan
-- Date:   2017-03-24
-- Last modification : 2017-03-24
-- Description: 战绩界面
require(BASE_PATH.."itemScene")
FriendsinfoRecordItem = class ( ItemScene,false)

FriendsinfoRecordItem.s_controls = {
    human_machine_tx = 1;   --单机关数
    chess_mess_tx = 2;      --残局关数
    game_num_tx = 3;        --总局数
    win_num_tx = 4;         --胜利局数
    lose_num_tx = 5;        --失败局数
    draw_num_tx = 6;        --平局局数
    gold_num_tx = 7;        --金币数
    score_num_tx = 8;       --积分数

    winrate_decimal_num_tx = 9;   --胜率小数部分，记得前面带上. 后面带上%
    winrate_integer_num_tx = 10;  --胜率整数部分
    winrate_img = 11;             --胜率条
}

FriendsinfoRecordItem.defaultvalue={HUMAN_MACHINE,CHESS_MESS}
FriendsinfoRecordItem.defaultvalue.HUMAN_MACHINE = "初出茅庐"
FriendsinfoRecordItem.defaultvalue.CHESS_MESS = "初入江湖-第1关"
FriendsinfoRecordItem.ctor = function (self,viewConfig,controller,scene,view)
    super(self,viewConfig,controller,true,view,scene)
    self.ctrls = FriendsinfoRecordItem.s_controls 
    self:initView()
    self:initDefaultViewData()
end
 
FriendsinfoRecordItem.dtor = function (self)
    
end

FriendsinfoRecordItem.initView = function (self)
    --获得view的对象
    self.human_machine_tx =self:findViewById(self.ctrls.human_machine_tx)
    self.chess_mess_tx =self:findViewById(self.ctrls.chess_mess_tx)
    self.game_num_tx =self:findViewById(self.ctrls.game_num_tx)
    self.win_num_tx =self:findViewById(self.ctrls.win_num_tx)
    self.lose_num_tx =self:findViewById(self.ctrls.lose_num_tx)
    self.draw_num_tx =self:findViewById(self.ctrls.draw_num_tx)
    self.gold_num_tx =self:findViewById(self.ctrls.gold_num_tx)
    self.score_num_tx =self:findViewById(self.ctrls.score_num_tx)
    self.winrate_decimal_num_tx =self:findViewById(self.ctrls.winrate_decimal_num_tx)
    self.winrate_integer_num_tx =self:findViewById(self.ctrls.winrate_integer_num_tx)
    self.winrate_img = self:findViewById(self.ctrls.winrate_img)
end

FriendsinfoRecordItem.initDefaultViewData = function (self)
    self:setHumanMachine(FriendsinfoRecordItem.defaultvalue.HUMAN_MACHINE)
    self:setChessMess(FriendsinfoRecordItem.defaultvalue.CHESS_MESS)
    self:setGoldNum(0)
    self:setWinrateData(0,0,0)
    self:setScoreNum(0)
end

FriendsinfoRecordItem.updateViewData  = function (self, recordData, normalData)
    local rData =recordData
    local nData = normalData
    if rData then 
        self:setHumanMachine(rData.single_game_name)
        self:setChessMess(rData.booth_gate_name)
    end
    if nData then 
        self:setGoldNum(nData.money)
        self:setWinrateData(nData.losetimes, nData.wintimes, nData.drawtimes)
        self:setScoreNum(nData.score)
    end
end

------------------------设置数据------------------------------
FriendsinfoRecordItem.setHumanMachine = function (self,s)
    if s == nil or s == "" then 
        self.human_machine_tx:setText(FriendsinfoRecordItem.defaultvalue.HUMAN_MACHINE)
    else 
        self.human_machine_tx:setText(s )
    end
end

FriendsinfoRecordItem.setChessMess = function (self,s)
    if s == nil or s == "" then 
        self.chess_mess_tx:setText( FriendsinfoRecordItem.defaultvalue.CHESS_MESS)
    else 
        self.chess_mess_tx:setText(s )
    end
end

FriendsinfoRecordItem.setGameNum = function (self,num)
    local n = tonumber(num) or 0
    self.game_num_tx:setText(n.."局")
end

FriendsinfoRecordItem.setWinNum = function (self,num)
    local n = tonumber(num) or 0
    self.win_num_tx:setText(n.."局")
end

FriendsinfoRecordItem.setLoseNum = function (self,num)
    local n = tonumber(num) or 0
    self.lose_num_tx:setText(n.."局")
end

FriendsinfoRecordItem.setDrawNum = function (self,num)
    local n = tonumber(num) or 0
    self.draw_num_tx:setText(n.."局")
end

FriendsinfoRecordItem.setGoldNum = function (self,num)
    local money = ToolKit.getMoneyStr(num) or 0;
    self.gold_num_tx:setText(money)
end

FriendsinfoRecordItem.setScoreNum = function (self,num)
    local n = tonumber(num) or 0
    self.score_num_tx:setText(n)
end

FriendsinfoRecordItem.setWinrateDecimalNum =function (self,num)
    local n = num or 0
    self.winrate_decimal_num_tx:setText(n)
end

FriendsinfoRecordItem.setWinrateIntegerNum =function (self,num)
    local n = tonumber(num) or 0
    self.winrate_integer_num_tx:setText(n)
end

--设置胜率圆形进度表以及胜负数
FriendsinfoRecordItem.setWinrateData = function (self,losetimesData,wintimesData,drawtimesData)
    local losetimes = losetimesData or 0
    local wintimes = wintimesData or 0
    local drawtimes = drawtimesData or 0
    --胜率
    self:setWinrateIntegerNum(self:getRateInteger(losetimes,wintimes,drawtimes))
    self:setWinrateDecimalNum(self:getRateDecimal(losetimes,wintimes,drawtimes))
    --self.winrate:setText(self:getRate(losetimes,wintimes,drawtimes));
    --胜率条
    local winrate = self:getRateNum(losetimes,wintimes,drawtimes)
    local CircleProgress = require("chess.include.circleProgress")
    local circleProgress = new(CircleProgress)
    local w,h = self.winrate_img:getSize()
    circleProgress:changeProgressFile("common/background/winrate_bg.png",w,h,"common/icon/red_point.png",25,25)
    circleProgress:setProgress(winrate*360)
    self.winrate_img:addChild(circleProgress)
    --对局数
    --local str = string.format("胜 %d/败 %d/和 %d",wintimes,losetimes,drawtimes)
    --self.chess_num_info:setText(str);
    self:setDrawNum(drawtimes)
    self:setWinNum(wintimes)
    self:setLoseNum(losetimes)

    local total_num = wintimes + drawtimes + losetimes
    self:setGameNum(total_num)
    --[[
    if self.numText then
        delete(self.numText)
        self.numText = nil
    end
    self.numText = new(RichText,"#c87645F总局数#n "..total_num .. "局",nil, nil, kAlignCenter, nil, 28, 120, 120, 120,false,2)
    self.numText:setAlign(kAlignCenter)
    self.chess_num:addChild(self.numText)

--    self.chess_num:setText(total_num .. "局")
    ]]--
end

------------------------------一些辅助计算功能函数-----------------------------------
--计算胜率
FriendsinfoRecordItem.getRateNum = function(self,m_losetimes,m_wintimes,m_drawtimes)
	local total = m_losetimes + m_wintimes+m_drawtimes
	local rate = total <= 0 and 0 or m_wintimes/total;
	return rate
end
--取胜率的整数部分
FriendsinfoRecordItem.getRateInteger = function(self,m_losetimes,m_wintimes,m_drawtimes) --胜率
	local total = m_losetimes + m_wintimes+m_drawtimes
	local rate = total <= 0 and 0 or math.floor(m_wintimes*100/total)  --取整数部分
	return rate
end
--取胜率的小数部分
FriendsinfoRecordItem.getRateDecimal =function(self,m_losetimes,m_wintimes,m_drawtimes)
    local rate = self:getRateNum(m_losetimes,m_wintimes,m_drawtimes)
    local rate_decimal = rate*100 - math.floor(rate*100)
    rate_decimal = "."..math.floor(rate_decimal*100).."%"
    return rate_decimal
end

FriendsinfoRecordItem.s_controlConfig = {
    [FriendsinfoRecordItem.s_controls.human_machine_tx] = {"human_machine_node","human_machine_tx"};
    [FriendsinfoRecordItem.s_controls.chess_mess_tx] = {"chess_mess_node" ,"chess_mess_tx"};
    [FriendsinfoRecordItem.s_controls.game_num_tx] = {"game_num_node","game_num_tx"};
    [FriendsinfoRecordItem.s_controls.win_num_tx] = {"game_num_node","win_num_tx"};
    [FriendsinfoRecordItem.s_controls.lose_num_tx] = {"game_num_node","lose_num_tx"};
    [FriendsinfoRecordItem.s_controls.draw_num_tx] = {"game_num_node","draw_num_tx"};
    [FriendsinfoRecordItem.s_controls.gold_num_tx] = {"game_num_node","gold_num_tx"};
    [FriendsinfoRecordItem.s_controls.score_num_tx] = {"game_num_node","score_num_tx"};
    [FriendsinfoRecordItem.s_controls.winrate_decimal_num_tx] = {"winrate_node","winrate_tx_node","winrate_num_node","winrate_decimal_num_tx"};
    [FriendsinfoRecordItem.s_controls.winrate_integer_num_tx] = {"winrate_node","winrate_tx_node","winrate_num_node","winrate_integer_num_tx"};
    [FriendsinfoRecordItem.s_controls.winrate_img] = {"winrate_node","winrate_img"};
}
