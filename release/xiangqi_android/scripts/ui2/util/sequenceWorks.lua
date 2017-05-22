--
-- UI2 Library, Version: 1.0 Alpha (0.99.2.2058-SNAPSHOT)
-- 
-- This file is a part of UI2 Library.
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
        return 
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