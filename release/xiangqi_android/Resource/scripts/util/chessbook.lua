USER_BRANCH_TAG = -1
MASTER_BRANCH   = 0

--[[-----------------------------------------------------
-- MoveListNode
--]]-----------------------------------------------------
function MoveListNode_Create(src, dst, comment)
    local node = {}
    node.src = src
    node.dst = dst
    node.comment = comment
    node.sub = {}
    node.branch = 0
    
    node.next = nil

    return node
end

function MoveListNode_AddSubListEntry(node, entries)
    if node == nil or entries == nil then
        return
    end

    node.sub = entries
end

function MoveListNode_EqualsMove(node, src, dst)
    if node == nil then
        return false
    end

    return (node.src == src and node.dst == dst)
end

function MoveListNode_Print(node)
    print("movelist_node_t |", node)
    if node == nil then
        return
    end
    print("--- src: ", node.src)
    print("--- dst: ", node.dst)
    print("--- next: ", node.next)
    if node.sub ~= nil then
        local i
        for i = 1, #node.sub do
            print("--- sub: ", node.sub[i])
        end
    end
    print("--- comment: ", node.comment)
    print("-----------------------")
end

--[[-----------------------------------------------------
-- MoveList
--]]-----------------------------------------------------
function MoveList_PushBackMove(list, src, dst, entries, comment)
    if list == nil then
        return
    end

    move = MoveListNode_Create(src, dst, comment)

    if entries ~= nil then
        move.sub = entries
    end

    local tail = list
    while tail.next ~= nil do
        tail = tail.next
    end

    tail.next = move
end

function MoveList_Print(l)
    local node = l

    while node ~= nil do
        MoveListNode_Print(node)
        node = node.next
    end
end

--[[-----------------------------------------------------
-- MoveStack
--]]-----------------------------------------------------
function MoveStack_Create()
    local stack = {}
    stack.move = nil
    stack.next = nil

    return stack
end

--[[-----------------------------------------------------
-- ChessBook
--]]-----------------------------------------------------

function ChessBook_Create()
    local cb = {}
    cb.masterMoveList = nil
    cb.branches = nil
    cb.historyStack = nil
    cb.currentMove = nil

    return cb
end

function ChessBook_PushBackMaster(cbook, move)
    if cbook == nil then
        return
    end

    if cbook.masterMoveList == nil then
        cbook.masterMoveList = move
        cbook.currentMove= move
        ChessBook_PushHistory(cbook, move)
        return
    end

    local tail = cbook.masterMoveList
    while tail.next ~= nil do
        tail = tail.next
    end

    tail.next = move

end

function ChessBook_CreateBranch(cbook, tag, move)
    if cbook == nil or move == nil then
        return
    end

    if cbook.branches == nil then
        local branch = {}
        branch.tag = tag
        branch.movelist = move
        cbook.branches = branch
    else
        local branchIter = cbook.branches
        while branchIter ~= nil do
            if branchIter.tag == tag then
                branchIter.movelist = nil
                branchIter.movelist = move
                break
            end

            branchIter = branchIter.next
        end

        if branchIter == nil then
            branchIter = {}
            branchIter.tag = tag
            branchIter.movelist = move

            branchIter.next = cbook.branches
            cbook.branches = branchIter
        end
    end
end

function ChessBook_FindBranch(cbook, tag)
    local ret = nil

    if cbook == nil or tag == 0 then
        return ret
    end

    ret = cbook.branches
    while ret ~= nil do
        if ret.tag == tag then
            break
        else
            ret = ret.next
        end
    end

    return ret
end

function ChessBook_PushBackBranch(cbook, tag, move)
    if cbook == nil or move == nil then
        return
    end

    local branch = ChessBook_FindBranch(cbook, tag)

    if branch == nil then
        ChessBook_CreateBranch(cbook, tag, move)
    else
        if branch.movelist == nil then
            branch.movelist = move
        else
            local tail = branch.movelist
            while tail.next ~= nil do
                tail = tail.next
            end

            tail.next = move
        end
    end
    
end

function ChessBook_PushHistory(cbook, move)
    if cbook == nil then
        return
    end

    local m = {}
    m.move = move
    m.next = nil

    if cbook.historyStack == nil then
        cbook.historyStack = m
        return
    else 
        m.next = cbook.historyStack
        cbook.historyStack = m
    end
end

function ChessBook_PopHistory(cbook)
    if cbook == nil or cbook.historyStack == nil then
        return nil
    end

    local m = cbook.historyStack.move
    cbook.historyStack = cbook.historyStack.next
    return m
end

function ChessBook_Print(cbook)
    print("chessbook_t |", cbook)
    print("---------- current ----------")
    MoveListNode_Print(cbook.currentMove)

    print("---------- master ----------")
    MoveList_Print(cbook.masterMoveList)

    print("---------- branches ----------")
    local branch = cbook.branches
    while branch ~= nil do
        print(" tag : ", branch.tag)
        MoveList_Print(branch.movelist)
        branch = branch.next
    end

    print("---------- history ----------")
    local historyMove = cbook.historyStack.next
    while historyMove ~= nil do
        MoveListNode_Print(historyMove.move)
        historyMove = historyMove.next
    end

    print("-----------------------")
end

function ChessBook_Reset(cbook)
    if cbook == nil then
        return
    end

    cbook.currentMove= cbook.masterMoveList
    cbook.historyStack = nil
    ChessBook_PushHistory(cbook, cbook.masterMoveList)

    local branch = cbook.branches
    while branch ~= nil do
        if branch.tag == USER_BRANCH_TAG then
            branch.movelist = {}
            break
        end

        branch = branch.next
    end
end

function ChessBook_MakeMove(cbook, src, dst)
    if cbook == nil then
        return
    end

    if cbook.currentMove == nil then
        return
    end

    local curMove = cbook.currentMove
    local nextMove = cbook.currentMove.next
    local move = nil

    if nextMove == nil then
        move = MoveListNode_Create(src, dst, NULL)       
        ChessBook_PushHistory(cbook, move)

        ChessBook_PushBackBranch(cbook, USER_BRANCH_TAG, move)
        move.branch = USER_BRANCH_TAG

        cbook.currentMove = move
    else
        if MoveListNode_EqualsMove(nextMove, src, dst) then
            ChessBook_PushHistory(cbook, nextMove)
            cbook.currentMove= nextMove
        else
            local i = 0
            if nextMove.sub ~= nil then
                for i = 1, #nextMove.sub do
                    local branch = ChessBook_FindBranch(cbook, nextMove.sub[i])
                    if branch ~= nil and MoveListNode_EqualsMove(branch.movelist, src, dst) then
                        ChessBook_PushHistory(cbook, branch.movelist)
                        cbook.currentMove = branch.movelist
                        return 
                    end
                end
            end

            if i == 0 or i > #nextMove.sub then
                move = MoveListNode_Create(src, dst, nil)
                ChessBook_PushHistory(cbook, move)

                ChessBook_PushBackBranch(cbook, USER_BRANCH_TAG, move)
                move.branch = USER_BRANCH_TAG
                cb.currentMove = move
            end

        end
    end

end

function ChessBook_CanUndoMove(cbook)
    if cbook == nil or cbook.historyStack == nil then
        return false
    end

    if MoveListNode_EqualsMove(cbook.historyStack.move, 0, 0) then
        return false
    end
    return true;
end


function ChessBook_UndoMove(cbook)
    local node = nil

    if cbook == nil or cbook.historyStack == nil then
        return false
    end

    if MoveListNode_EqualsMove(cbook.historyStack.move, 0, 0) then
        return false
    end

    ChessBook_PopHistory(cbook)
    cbook.currentMove = cbook.historyStack.move

    return true

    --[[
    node = MoveStack_Pop(cbook.historyStack)

    if node ~= nil then
        if MoveListNode_EqualsMove(cbook.currentMove, node.src, node.dst) then
            node = MoveStack_Pop(cbook.historyStack)
        end

        cbook.currentMove= node
        return true
    else
        return false
    end
    --]]
end

function ChessBook_IsOffBook(cbook)
    if cbook == nil or cbook.currentMove== nil then
        return false
    end

    if cbook.currentMove.branch ~= MASTER_BRANCH then
        return true
    else
        return false
    end
end

function ChessBook_GetNextMove(cbook)
    if cbook == nil or cbook.currentMove == nil then
        return nil
    end

    return cbook.currentMove.next
end

function ChessBook_GetCurrentMove(cbook)
    if cbook == nil then
        return nil
    end

    return cbook.currentMove
end
