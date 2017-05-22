require("config/boardres");
--require("config/boardres1");
--require("config/boardres2");

UserSetInfo = class();

UserSetInfo.getInstance = function()
    if not UserSetInfo.instance then
        UserSetInfo.instance = new(UserSetInfo);
    end
    return UserSetInfo.instance;
end

UserSetInfo.ctor = function(self)
    
end

UserSetInfo.getMySetType = function(self)
    local tab = {};
    local tempType = GameCacheData.getInstance():getString(GameCacheData.HEADFRAME,"sys");
    tab.picture_frame = tempType; --UserSetInfoHeadFrameMapConfig[tempNum].my_set;
    tempType = GameCacheData.getInstance():getString(GameCacheData.CHESSPIECE,"sys");
    tab.piece = tempType; --UserSetInfoChessMapConfig[tempNum].my_set;
    tempType = GameCacheData.getInstance():getString(GameCacheData.BOARDTYPE,"sys");
    tab.board = tempType; --UserSetInfoBoardMapConfig[tempNum].my_set;
    return tab
end

--[Comment]
-- 设置棋子类型
-- chessPieceType: 棋盘類型 string
UserSetInfo.setBoardType = function(self,boardType)
--    self.m_boardType = boardType;
    local _boardType = "sys";
    if boardType and boardType ~= "" then
        _boardType = boardType
    end
    GameCacheData.getInstance():saveString(GameCacheData.BOARDTYPE,_boardType);
end

--[Comment]
-- 获得棋盘类型
UserSetInfo.getBoardType = function(self)
    local _boardType = GameCacheData.getInstance():getString(GameCacheData.BOARDTYPE,"sys");
	return _boardType;
end

--[Comment]
-- 设置棋子类型
-- chessPieceType: 棋子類型 string
UserSetInfo.setChessPieceType = function(self,chessPieceType)
    local _chessPieceType = "sys";
    if chessPieceType and chessPieceType ~= "" then
        _chessPieceType = chessPieceType
    end
    GameCacheData.getInstance():saveString(GameCacheData.CHESSPIECE,_chessPieceType);
end

--[Comment]
-- 获得棋子类型
UserSetInfo.getChessPieceType = function(self)
    local _chessPieceType = GameCacheData.getInstance():getString(GameCacheData.CHESSPIECE,"sys");
	return _chessPieceType;
end

--[Comment]
-- 设置头像框类型
-- headFrameType: 頭像類型 string
UserSetInfo.setHeadFrameType = function(self,headFrameType)
    local _headFrameType = "sys";
    if headFrameType and headFrameType ~= "" then
        _headFrameType = headFrameType
    end
	GameCacheData.getInstance():saveString(GameCacheData.HEADFRAME,_headFrameType);
end

--[Comment]
-- 获得头像框类型
UserSetInfo.getHeadFrameType = function(self)
    local _headFrameType = GameCacheData.getInstance():getString(GameCacheData.HEADFRAME,"sys");
	return _headFrameType;
end

--[Comment]
--获得棋盘类型资源
UserSetInfo.getBoardRes = function(self)
    local boardType = GameCacheData.getInstance():getString(GameCacheData.BOARDTYPE,"sys");
    for k,v in pairs(UserSetInfoBoardMapConfig) do
        if v.my_set == boardType then
            return v.board;
        end
    end
    return "common/background/room_bg.png"
end

--[Comment]
--棋子类型资源
UserSetInfo.getChessRes = function(self)
    local pieceType = GameCacheData.getInstance():getString(GameCacheData.CHESSPIECE,"sys");
    for k,v in pairs(UserSetInfoChessMapConfig) do
        if v.my_set == pieceType then
            return v.piece_res;
        end
    end
    return boardres_map
end

--[Comment]
--头像框类型资源
UserSetInfo.getFrameRes = function(self,frameType)
    local headFrameType = nil
    if frameType then
        headFrameType = frameType
    else
        headFrameType = GameCacheData.getInstance():getString(GameCacheData.HEADFRAME,"sys");
    end
    for k,v in pairs(UserSetInfoHeadFrameMapConfig) do
        if v.my_set == headFrameType then
            return v;
        end
    end
    return UserSetInfoHeadFrameMapConfig[0]
end

--[Comment]
--更新设置
--data: 用户设置数据
UserSetInfo.updataSelectData = function(self,data)
    self:setHeadFrameType(data.picture_frame);
    self:setChessPieceType(data.piece);  
    self:setBoardType(data.board);
end

--棋盘、棋子、头像框 列表
--[Comment]
--获得所有棋盘，棋子，头像框的数据
UserSetInfo.getAllSelectRes = function(self)
    local list = {};
    list[1] = UserSetInfoHeadFrameMapConfig;
    list[2] = UserSetInfoChessMapConfig;
    list[3] = UserSetInfoBoardMapConfig;
    local _,new_prop_info = UserInfo.getInstance():getNewPropInfo();
    --更新棋盘解锁状态
    for k,v in pairs(new_prop_info) do
        if v and tonumber(v.is_enabled) == 1 then
            local boardItem = list[3][tonumber(v.prop_id)];
            if boardItem then
                boardItem['is_enabled']  = 1;
            end
            local frameItem = list[1][tonumber(v.prop_id)];
            if frameItem then
                frameItem['is_enabled']  = 1;
            end
            local chessItem = list[2][tonumber(v.prop_id)];
            if chessItem then
                chessItem['is_enabled']  = 1;
            end
        end
    end

    --如果是vip则改变 is_enabled 属性状态
    local ret = UserInfo.getInstance():getIsVip()
    if ret and ret == 1 then
        for i = 1,3 do
            list[i][1]['is_enabled'] = ret;
        end
    end

    return list;
end

function UserSetInfo.getBgImgRes(self)
    local boardType = GameCacheData.getInstance():getString(GameCacheData.BOARDTYPE,"sys");
    for k,v in pairs(UserSetInfoBoardMapConfig) do
        if v.my_set == boardType then
            return v.bg_img;
        end
    end
end

--[Comment]
--更新个性装扮选择状态
function UserSetInfo.updateSelectItem(self)
    local tab,_ = UserInfo.getInstance():getNewPropInfo();
    local boardType = self:getBoardType();
    if boardType == "sys" or boardType == "vip" then

    else
        if not tab or next(tab) == nil then
            self:setBoardType();
            return
        end
        for k,v in pairs(tab) do
            if tonumber(v.is_enabled) == 0  then
                if v.my_set == boardType then
                    self:setBoardType();
                end
            end
        end
    end
end

--[Comment]
--更新个性装扮设置状态
function UserSetInfo.updateSelectStatus(self)
    local _,tab = UserInfo.getInstance():getNewPropInfo()
    self:updateBoardStatus(tab);
    self:updateChessStatus(tab);
    self:updateHeadStatus(tab);
end

function UserSetInfo.updateBoardStatus(self,tab)
    local boardType = self:getBoardType();
    if boardType == "sys" or boardType == "vip" then
        if UserInfo.getInstance():getIsVip() == 0 then
            self:setBoardType();
        end
    else
        if not tab or next(tab) == nil then
            self:setBoardType();
            return
        end
        for k,v in pairs(tab) do
            if tonumber(v.is_enabled) == 0  then
                local id = tonumber(v.prop_id)
                if not id then return end
                if UserSetInfoBoardMapConfig[id] and UserSetInfoBoardMapConfig[id].my_set == boardType then
                    self:setBoardType();
                end
            end
        end
    end
end

function UserSetInfo.updateChessStatus(self,tab)
    local chessType = self:getChessPieceType();
    if chessType == "sys" or chessType == "vip" then
        if UserInfo.getInstance():getIsVip() == 0 then
            self:setChessPieceType();
        end
    else
        if not tab or next(tab) == nil then
            self:setChessPieceType();
            return
        end
        for k,v in pairs(tab) do
            if tonumber(v.is_enabled) == 0  then
                local id = tonumber(v.prop_id)
                if not id then return end
                if UserSetInfoChessMapConfig[id] and UserSetInfoChessMapConfig[id].my_set == chessType then
                    self:setChessPieceType();
                end
            end
        end
    end
end

function UserSetInfo.updateHeadStatus(self,tab)
    local headType = self:getHeadFrameType();
    if headType == "sys" or headType == "vip" then
        if UserInfo.getInstance():getIsVip() == 0 then
            self:setHeadFrameType();
        end
    else
        if not tab or next(tab) == nil then
            self:setHeadFrameType();
            return
        end
        for k,v in pairs(tab) do
            if tonumber(v.is_enabled) == 0  then
                local id = tonumber(v.prop_id)
                if not id then return end
                if UserSetInfoHeadFrameMapConfig[id] and UserSetInfoHeadFrameMapConfig[id].my_set == headType then
                    self:setHeadFrameType();
                end
            end
        end
    end
end

function UserSetInfo.checkExistBoardRes(typeStr)
    for key,value in pairs(UserSetInfoBoardMapConfig) do
        if typeStr == value.my_set then return true end
    end
    return false
end

function UserSetInfo.checkExistHeadFrameRes(typeStr)
    for key,value in pairs(UserSetInfoHeadFrameMapConfig) do
        if typeStr == value.my_set then return true end
    end
    return false
end

function UserSetInfo.checkExistChessMapRes(typeStr)
    for key,value in pairs(UserSetInfoChessMapConfig) do
        if typeStr == value.my_set then return true end
    end
    return false
end
--[Comment]
--    if value1 > value2 then return 1 end
--    if value1 == value2 then return 0 end
--    if value1 < value2 then return -1 end
function UserSetInfo.comparisonResValue(typeStr1,typeStr2)
    local valueMap = {
        ['sys'] = 0,
        ['huai_jiu'] = 1,
        ['hu_pan'] = 2,
        ['zhu_lin'] = 3,
        ['vip'] = 4,
    }
    local value1 = valueMap[typeStr1] or -1
    local value2 = valueMap[typeStr2] or -1
    if value1 > value2 then return 1 end
    if value1 == value2 then return 0 end
    return -1
end
--[Comment]
-- 根据类型获取棋盘配置
function UserSetInfo.getChessBoardRes(typeStr)
    if not UserSetInfo.checkExistBoardRes(typeStr) then typeStr = 'sys' end
    for key,value in pairs(UserSetInfoBoardMapConfig) do
        if typeStr == value.my_set then return value end
    end
end

--[Comment]
-- 根据类型获取头像框配置
function UserSetInfo.getHeadFrameRes(typeStr)
    if not UserSetInfo.checkExistHeadFrameRes(typeStr) then typeStr = 'sys' end
    for key,value in pairs(UserSetInfoHeadFrameMapConfig) do
        if typeStr == value.my_set then return value end
    end
    return false
end

--[Comment]
-- 根据类型获取棋子配置
function UserSetInfo.getChessMapRes(typeStr)
    if not UserSetInfo.checkExistChessMapRes(typeStr) then typeStr = 'sys' end
    for key,value in pairs(UserSetInfoChessMapConfig) do
        if typeStr == value.my_set then return value end
    end
    return false
end


-- 棋盘
--flag 1：免费 2：vip 3：限时
UserSetInfoBoardMapConfig = 
{
    [0] = {
        ['board'] = boardres_map['chess_board.png'];
        ['board_img'] = "settingicon/normal_board.png",
        ['board_res'] = boardres_map,
        ['bg_img'] = "common/background/room_bg.png",
        ['name'] = "普通棋盘",
        ['settype']   = 3,
        ['property']  = 0,
        ['is_enabled']  = 1,
        ['my_set'] = "sys",
        ['flag'] = 0,
    },
    [1] = {
        ['board'] = boardres_map1['chess_board.png'];
        ['board_img'] = "settingicon/vip_board.png",
        ['board_res'] = boardres_map1,
        ['bg_img'] = "common/background/room_bg.png",
        ['name'] = "会员棋盘",
        ['settype']   = 3,
        ['property']  = 1,
        ['is_enabled']  = -1,
        ['my_set'] = "vip",
        ['flag'] = 1,
    },
    [14] = {
        ['board'] = board_res_map['zhulin_board.png'];
        ['board_img'] = "settingicon/zhu_lin.png",
        ['board_res'] = boardres_map1,
        ['bg_img'] = "common/background/zhulin_bg.png",
        ['name'] = "竹林棋盘",
        ['settype']   = 3,
        ['property']  = 1,
        ['is_enabled']  = 0,
        ['my_set'] = "zhu_lin",
        ['flag'] = 2,
    },
    [15] = {
        ['board'] = board_res_map['hupan_board.png'];
        ['board_img'] = "settingicon/hu_pan.png",
        ['board_res'] = boardres_map1,
        ['bg_img'] = "common/background/hupan_bg.png",
        ['name'] = "湖畔棋盘",
        ['settype']   = 3,
        ['property']  = 1,
        ['is_enabled']  = 0,
        ['my_set'] = "hu_pan",
        ['flag'] = 2,
    },
    [25] = {
        ['board'] = old_board_res_map["chess_board.png"],
        ['board_img'] = "settingicon/huai_jiu.png",
        ['board_res'] = old_board_res_map,
        ['bg_img'] = "common/background/old_room_bg.png",
        ['name'] = "怀旧棋盘",
        ['settype']   = 3,
        ['property']  = 1,
        ['is_enabled']  = 0,
        ['my_set'] = "huai_jiu",
        ['flag'] = 2,
    },
}

-- 头像框
UserSetInfoHeadFrameMapConfig = 
{
    [0] = {
        ['frame_res'] = nil,
        ['name'] = "普通框",
        ['visible']   = false,
        ['settype']   = 1,
        ['property']  = 0,
        ['is_enabled']  = 1,
        ['my_set'] = "sys",
        ['flag'] = 0,
    },
    [1] = {
        ['frame_res'] = "vip/vip_%d.png",
        ['name'] = "黄金框",
        ['visible']   = true,
        ['settype']   = 1,
        ['property']  = 1,
        ['is_enabled']  = -1,
        ['my_set'] = "vip",
        ['flag'] = 1,
    },
    [21] = {
        ['frame_res'] = "vip/sliver_%d.png",
        ['name'] = "白银框",
        ['visible']   = true,
        ['settype']   = 1,
        ['property']  = 1,
        ['is_enabled']  = 0,
        ['my_set'] = "sliver",
        ['flag'] = 2,
    },
}
-- 棋子
UserSetInfoChessMapConfig = 
{
    [0] = {
        ['piece_res']  = boardres_map,
        ['name'] = "普通棋子",
        ['piece_bg']   = boardres_map["piece.png"],
        ['piece_img']  = boardres_map["rking.png"],
        ['settype']   = 2,
        ['property']  = 0,
        ['is_enabled']  = 1,
        ['my_set'] = "sys",
        ['flag'] = 0,
    },
    [1] = {
        ['piece_res'] = boardres_map1,
        ['name'] = "会员棋子",
        ['piece_bg']   = boardres_map1["piece.png"],
        ['piece_img']  = boardres_map1["rking.png"],
        ['settype']   = 2,
        ['property']  = 1,
        ['is_enabled']  = -1,
        ['my_set'] = "vip",
        ['flag'] = 1,
    },
    [25] = {
        ['piece_res'] = old_board_res_map,
        ['name'] = "怀旧棋子",
        ['piece_bg']   = old_board_res_map["piece.png"],
        ['piece_img']  = old_board_res_map["rking.png"],
        ['settype']   = 2,
        ['property']  = 1,
        ['is_enabled']  = 0,
        ['my_set'] = "huai_jiu",
        ['flag'] = 2,
    },
}

UserSetInfo.getInstance();