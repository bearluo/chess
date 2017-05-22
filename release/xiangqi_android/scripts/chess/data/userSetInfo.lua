require("config/boardres");

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
    local tempNum = GameCacheData.getInstance():getInt(GameCacheData.HEADFRAME,0);
    tab.picture_frame = UserSetInfoHeadFrameMapConfig[tempNum].my_set;
    tempNum = GameCacheData.getInstance():getInt(GameCacheData.CHESSPIECE,0);
    tab.piece = UserSetInfoChessMapConfig[tempNum].my_set;
    tempNum = GameCacheData.getInstance():getInt(GameCacheData.BOARDTYPE,0);
    tab.board = UserSetInfoBoardMapConfig[tempNum].my_set;

    return tab
end
-- 设置棋盘类型
UserSetInfo.setBoardType = function(self,boardType)
    self.m_boardType = boardType;
	GameCacheData.getInstance():saveInt(GameCacheData.BOARDTYPE,boardType);
end
-- 获得棋盘类型
UserSetInfo.getBoardType = function(self)
    local n = UserInfo.getInstance():getIsVip();
    if not n then n = 0 end
    self.m_boardType = GameCacheData.getInstance():getInt(GameCacheData.BOARDTYPE,n);
	return self.m_boardType;
end
-- 设置棋子类型
UserSetInfo.setChessPieceType = function(self,chessPieceType)
    self.m_chessPieceType = chessPieceType;
	GameCacheData.getInstance():saveInt(GameCacheData.CHESSPIECE,chessPieceType);
end
-- 获得棋子类型
UserSetInfo.getChessPieceType = function(self)
    local n = UserInfo.getInstance():getIsVip();
    if not n then n = 0 end
    self.m_chessPieceType = GameCacheData.getInstance():getInt(GameCacheData.CHESSPIECE,n);
	return self.m_chessPieceType;
end
-- 设置头像框类型
UserSetInfo.setHeadFrameType = function(self,headFrameType)
    self.m_headFrameType = headFrameType;
	GameCacheData.getInstance():saveInt(GameCacheData.HEADFRAME,headFrameType);
end
-- 获得头像框类型
UserSetInfo.getHeadFrameType = function(self)
    local n = UserInfo.getInstance():getIsVip();
    if not n then n = 0 end
    self.m_headFrameType = GameCacheData.getInstance():getInt(GameCacheData.HEADFRAME,n);
	return self.m_headFrameType;
end
--获得棋盘类型资源
UserSetInfo.getBoardRes = function(self)
    local n = UserInfo.getInstance():getIsVip();
    self.m_boardType = GameCacheData.getInstance():getInt(GameCacheData.BOARDTYPE,n);
    return UserSetInfoBoardMapConfig[self.m_boardType].board;
end

--更新设置
UserSetInfo.updataSelectData = function(self)
    self.m_select_set = UserInfo.getInstance():getUserSet();
    if not self.m_select_set then return end
    for i =1,3 do
        if self.m_select_set[i].typeName == "picture_frame" then
            if self.m_select_set[i].setType == "sys" then
                self:setHeadFrameType(0);
            elseif self.m_select_set[i].setType == "vip" then
                self:setHeadFrameType(1);
            end
        elseif  self.m_select_set[i].typeName == "piece" then
            if self.m_select_set[i].setType == "sys" then
                self:setChessPieceType(0);
            elseif self.m_select_set[i].setType == "vip" then
                self:setChessPieceType(1);
            end
        elseif self.m_select_set[i].typeName == "board" then
            if self.m_select_set[i].setType == "sys" then
                self:setBoardType(0);
            elseif self.m_select_set[i].setType == "vip" then
                self:setBoardType(1);
            end
        end
    end
end

--棋子类型资源
UserSetInfo.getChessRes = function(self)
    local n = UserInfo.getInstance():getIsVip();
    self.m_chessPieceType = GameCacheData.getInstance():getInt(GameCacheData.CHESSPIECE,n);
    return UserSetInfoChessMapConfig[self.m_chessPieceType].piece_res;
end
--头像框类型资源
UserSetInfo.getFrameRes = function(self)
    local n = UserInfo.getInstance():getIsVip();
    self.m_headFrameType = GameCacheData.getInstance():getInt(GameCacheData.HEADFRAME,n);
    return UserSetInfoHeadFrameMapConfig[self.m_headFrameType];
end
--棋盘、棋子、头像框 列表
UserSetInfo.getAllSelectRes = function(self)
    local list = {};
    list[1] = UserSetInfoHeadFrameMapConfig;
    list[2] = UserSetInfoChessMapConfig;
    list[3] = UserSetInfoBoardMapConfig;
    return list;
end

--传入两个参数： 设置类型和选择类型 settype -- > itemType,property -- >
--UserSetInfo.getSetGray = function(self,setType,itemType)
--    if not setType then return end
--    local selectItem = 1;
--    if itemType then 
--        selectItem = itemType;
--    end
--    -- itemType  1 头像框  2 棋子 3 棋盘
--    if setType == 1 then
--        local ret = 0;
--        for k,v in pairs(UserSetInfoHeadFrameMapConfig) do
--            if v.property == selectItem then
--                ret = v.can_click;
--                break;
--            end
--        end
--        if UserInfo.getInstance():getIsVip() ~= 1 and ret == 0 then
--            return true
--        end
--        return false;
--    elseif setType == 2 then
--        local ret = 0;
--        for k,v in pairs(UserSetInfoChessMapConfig) do
--            if v.property == selectItem then
--                ret = v.can_click;
--                break;
--            end
--        end
--        if UserInfo.getInstance():getIsVip() ~= 1 and ret == 0 then
--            return true
--        end
--        return false;
--    elseif setType == 3 then
--    local ret = 0;
--        for k,v in pairs(UserSetInfoBoardMapConfig) do
--            if v.property == selectItem then
--                ret = v.can_click;
--                break;
--            end
--        end
--        if UserInfo.getInstance():getIsVip() ~= 1 and ret == 0 then
--            return true
--        end
--        return false;
--    end
--end

-- 棋盘
UserSetInfoBoardMapConfig = 
{
    [0] = {
        ['board'] = boardres_map['chess_board.png'];
        ['board_img'] = "common/board_03.png",
        ['board_res'] = boardres_map,
        ['name'] = "默认",
        ['settype']   = 3,
        ['property']  = 0,
        ['can_click']  = 1, 
        ['my_set'] = "sys",
    },
    [1] = {
        ['board'] = boardres_map1['chess_board.png'];
        ['board_img'] = "common/vip_board_03.png",
        ['board_res'] = boardres_map1,
        ['name'] = "会员专享",
        ['settype']   = 3,
        ['property']  = 1,
        ['can_click']  = 0,
        ['my_set'] = "vip",
    },
}

-- 头像框
UserSetInfoHeadFrameMapConfig = 
{
    [0] = {
        ['frame_res'] = nil,
        ['name'] = "默认",
        ['visible']   = false,
        ['settype']   = 1,
        ['property']  = 0,
        ['can_click']  = 1,
        ['my_set'] = "sys",

    },
    [1] = {
        ['frame_res'] = "vip/vip_%d.png",
        ['name'] = "会员专享",
        ['visible']   = true,
        ['settype']   = 1,
        ['property']  = 1,
        ['can_click']  = 0,
        ['my_set'] = "vip",

    },
}
-- 棋子
UserSetInfoChessMapConfig = 
{
    [0] = {
        ['piece_res']  = boardres_map,
        ['name'] = "默认",
        ['piece_bg']   = boardres_map["piece.png"],
        ['piece_img']  = boardres_map["rking.png"],
        ['settype']   = 2,
        ['property']  = 0,
        ['can_click']  = 1,
        ['my_set'] = "sys",

    },
    [1] = {
        ['piece_res'] = boardres_map1,
        ['name'] = "会员专享",
        ['piece_bg']   = boardres_map1["piece.png"],
        ['piece_img']  = boardres_map1["rking.png"],
        ['settype']   = 2,
        ['property']  = 1,
        ['can_click']  = 0,
        ['my_set'] = "vip",

    },
}

UserSetInfo.getInstance();