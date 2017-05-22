--
-- @@LIB_NAME@@, Version: @@Version@@
--
-- This file is a part of @@LIB_NAME@@.
--
-- Author:
-- Xiaofeng Yang     2015
--
--

local M = {}

local goNext = function (sequence)
    if sequence.alreadyTerminated then
        return
    end

    sequence.currentIndex = sequence.currentIndex + 1
    if sequence.terminated or ( sequence.currentIndex > #(sequence.fnSeq) ) then
        sequence.onTerminate()
        sequence.alreadyTerminated = true
    else
        sequence.fnSeq[sequence.currentIndex]()
    end
end


M.create = function ()
    return {
        fnSeq = {},
        currentIndex = 1,
        terminated = false,
        alreadyTerminated = false,
        onTerminate = function () end,
    }
end

M.terminate = function ( sequence )
    sequence.terminated = true
end

M.isTerminated = function ( sequence )
    return sequence.alreadyTerminated
end

M.addWork = function ( sequence, fn )
    table.insert(sequence.fnSeq, function ()
        fn(function ()
            goNext(sequence)
        end)
    end)
end

M.resume = function ( sequence )
    goNext(sequence)
end




return M