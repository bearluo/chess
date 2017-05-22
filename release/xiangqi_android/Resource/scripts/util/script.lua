-----------------------------------------------------------------------------
-- Boyaa Chinese Chess ChessBook support for the Lua language.
-- ChessBook Module
-- Author: Master.G
-- Version: 0.0.1
--
-- USAGE:
-- node = {}
-- node.src = 着法起始位置,必要字段
-- node.dst = 着法落子位置,必要字段
-- node.comment = 着法注释
-- node.sub = {tag1, tag2, tag3 } 着法分支入口
--
-- 创建一个ChessBook实例
-- cb = ChessBook()
--
-- 打印chessbook的信息
-- cb:print()
--
-- 向主干走法中添加着法
-- cb:pushBackMaster(node)
--
-- 向指定分支走法中添加着法
-- cb:pushBackBranch(tag, node)
--
-- 将chessbook恢复至初始状态
-- cb:reset()
--
-- 获取当前着法
-- cb:getCurrentMove()
--
-- 获取下一步着法
-- cb:getNextMove()
--
-- 查询当前是否已经脱谱
-- cb:isOffBook()
--
-- 向chessbook中匹配着法
-- cb:makeMove(src, dst)
--
-- 从chessbook中撤销上一步着法
-- cb:undoMove()
--
-- REQUIREMENTS:
--   compat-5.1 if using Lua 5.0
--
-- CHANGELOG
--   0.0.1 第一版本
-----------------------------------------------------------------------------

require ("util/json")
require ("util/chessbook")

--[[
Functions
--]]

collectgarbage("collect");print (collectgarbage("count"))

function print_t(t)
    if t == nil then
        print("nil")
        return
    end

    for i,v in pairs(t) do
        print(i, v)
    end
end

-- 从一个table中解析着法节点
function extractMoveFromDict(dict)
    node = {}

    if dict ~= nil then
        node.comment = dict["comment"]
        node.src = tonumber(dict["src"])
        node.dst = tonumber(dict["dst"])
        node.sub = dict["sub"]

        if node.sub ~= nil then
            local i = 1
            for i = 1, #node.sub do
                node.sub[i] = tonumber(node.sub[i])
            end
        end

        node.branch = 0
    end

    return node
end

-- 从json字符串创建一个chessbook
function buildChessbookFromJsonString(str)
    print("Start parsing")

    local moveDict = json.decode(str)

    if moveDict == nil then
        print("[buildChessbookFromJsonString]Error: Invalid Json string")
        return nil
    end

    local masterMoveList = moveDict["movelist"]
    local subMoveList = moveDict["submovelist"]

    if masterMoveList == nil then
        print("[buildChessbookFromJsonString]Error: Can't find token 'movelist'")
        return nil
    end

    if subMoveList == nil then
        print("[buildChessbookFromJsonString]Error: Can't find token 'submovelist'")
        return nil
    end

    cb = ChessBook_Create()

    for i,v in pairs(masterMoveList) do
        local move = extractMoveFromDict(v)
        ChessBook_PushBackMaster(cb, move)
    end

    for i,v in pairs(subMoveList) do
        for _,moves in pairs(v) do
            subMove = extractMoveFromDict(moves)
            ChessBook_PushBackBranch(cb, tonumber(i), subMove)
        end
    end
    
    print("Parse End")

    return cb
end

--[[

chessbookstr = "{\"submovelist\":{\"3\":[{\"src\":\"30\",\"dst\":\"40\",\"comment\":\"改弈其他走法，红方均可简胜。\"},{\"src\":\"35\",\"dst\":\"30\"},{\"src\":\"40\",\"dst\":\"30\"},{\"src\":\"64\",\"dst\":\"60\"},{\"src\":\"50\",\"dst\":\"31\"},{\"src\":\"43\",\"dst\":\"22\"}],\"1\":[{\"src\":\"51\",\"dst\":\"31\"},{\"src\":\"43\",\"dst\":\"51\"},{\"src\":\"71\",\"dst\":\"51\",\"sub\":[\"2\"]},{\"src\":\"64\",\"dst\":\"60\"}],\"4\":[{\"src\":\"50\",\"dst\":\"31\"},{\"src\":\"43\",\"dst\":\"22\"}],\"2\":[{\"src\":\"81\",\"dst\":\"51\"},{\"src\":\"64\",\"dst\":\"60\"}]},\"movelist\":[{\"src\":\"00\",\"dst\":\"00\"},{\"src\":\"63\",\"dst\":\"51\"},{\"src\":\"58\",\"dst\":\"51\"},{\"src\":\"34\",\"dst\":\"64\"},{\"src\":\"27\",\"dst\":\"35\",\"sub\":[\"1\",\"3\",\"4\"]},{\"src\":\"64\",\"dst\":\"60\"},{\"src\":\"50\",\"dst\":\"31\"},{\"src\":\"43\",\"dst\":\"22\"}]}"

cb = buildChessbookFromJsonString(chessbookstr)

ChessBook_MakeMove(cb, 63, 51)

print(ChessBook_IsOffBook(cb))
ChessBook_MakeMove(cb, 58, 51)
print(ChessBook_IsOffBook(cb))
ChessBook_MakeMove(cb, 34, 64)
print(ChessBook_IsOffBook(cb))
ChessBook_MakeMove(cb, 30, 40)
print(ChessBook_IsOffBook(cb))
ChessBook_MakeMove(cb, 1, 1)
print(ChessBook_IsOffBook(cb))

ChessBook_Print(cb)

ChessBook_UndoMove(cb)

print(ChessBook_IsOffBook(cb))

cb = nil

collectgarbage("collect");print (collectgarbage("count"))
]]

function get_hint(cb)

	if cb ~= nil then
		local nextMove = ChessBook_GetNextMove(cb)
		if nextMove ~= nil then
			if nextMove.sub ~= nil then
				print("branch count is", #nextMove.sub)
			end
		end
	end

end



--[[

node = {}
node.src = 99
node.dst = 88
node.sub = { 9, 8, 7, 6, 5, 4, 3, 2, 1 }
node.comment = "chessbook 版本1.0"

ass = ChessBook()
ass:pushBackMaster(node)
ass:print()

print_t(ass:getCurrentMove())

ass = nil

--]]

--[[
创建一个新的chessbook实例
cb = ChessBook()

打印chessbook的信息
cb:print()

向主干走法中添加着法
这个操作属于初始化过程
cb:pushBackMaster(node)

向指定分支走法中添加着法
这个操作属于初始化过程
cb:pushBackBranch(tag, node)

将chessbook恢复至初始状态
cb:reset()

获取当前着法
cb:getCurrentMove()

查询当前是否已经脱谱
cb:isOffBook()

向chessbook中匹配着法
cb:makeMove(src, dst)

从chessbook中撤销上一步着法
cb:undoMove()

一个基本的流程可能是这个样子的

创建一个新的chessbook实例

解析json字符串并将着法分别添加到chessbook中的主干和分支中

这个时候chessbook已经创建完毕

当玩家或AI走棋的时候
使用makeMove来同步chessbook

使用getCurrentMove来获取当前着法
使用getNextMove来获取下一步着法，如果已经脱谱或是已经到了分支的末端，返回值为空

当有悔棋的时候，使用undoMove

当需要重置的时候，使用reset

--]]
