--
-- @@LIB_NAME@@, Version: @@Version@@
--
-- This file is a part of @@LIB_NAME@@.
--
-- Author:
-- Xiaofeng Yang     2015
--
--

---
-- @module ui2.util.queue
local M = {}

---
-- 创建一个新的空队列并返回。
--
-- @return #Queue 返回一个新创建的队列。
M.create = function ()
    ---
    -- 一个队列。其最大元素个数小于2147483648个。
    --
    -- @type Queue
    local q = {}
    
    local h = 0
    local t = 0
    local data = {}
    local MAX_SIZE = 2147483648
    
    ---
    -- 将x加入到队列末尾。
    --
    -- @param x 要入队的数据。  
    -- @return #Queue 返回队列本身。
    function q.enqueue(x)
        data[t] = x
        t = (t + 1) % MAX_SIZE
        return q        
    end 
    
    ---
    -- @return #boolean 若队列为空，则返回true；否则，返回false。
    function q.isEmpty()
        return h == t 
    end
    
    ---
    -- 将队列顶部元素出队。
    --
    -- @return #nil 若队列为空，返回nil。
    -- @return 若队列不为空，则返回队列顶部元素。
    function q.dequeue()
        if h == t then 
            return nil
        else
            local x = data[h] 
            data[h] = nil
            h = (h + 1) % MAX_SIZE
            return x
        end 
    end 
    
    ---
    -- 返回队列顶部元素。
    --
    -- @return #nil 若队列为空，则返回nil。
    -- @return 若队列不为空，则返回队列顶部元素。
    function q.front()
        return data[h]
    end
    
    ---
    -- 返回队列尾部元素。
    --
    -- @return #nil 若队列为空，则返回nil。
    -- @return 若队列不为空，则返回队列尾部元素。
    function q.back()
        return data[t]
    end
    
    ---
    -- 返回队列长度。
    -- 
    -- @return #number 队列长度。
    function q.size()
        if t >= h then 
            return t - h
        else
            return t + MAX_SIZE - h
        end
    end
    
    ---
    -- 返回用于 for 循环的 迭代器. 
    -- 
    -- 在循环过程中，不应该改变队列的内容。
    -- 
    --      for k, v in q.iterator() do
    --          print(k, v)    -- k为从1开始的整数。v为队列元素的值。 
    --      end 
    -- 
    -- @return #function 用于for循环的迭代器。
    function q.iterator()
        local initial = h
        local index = h 
        local last = t
        return function ()
            if index == last then 
                return nil 
            else
                local x = data[index]
                local pIndex 
                if index >= initial then
                    pIndex = index - initial + 1
                else
                    pIndex = index + MAX_SIZE - initial + 1                     
                end
                index = (index + 1) % MAX_SIZE
                return pIndex, x                
            end  
        end          
    end 

    ---
    -- 将队列中所有 ```test(elem) == true``` ，替换成 new .
    -- 其中，elem 为队列中的元素。
    -- 
    -- @param new 任意lua值。
    -- @param #function test 一个函数。
    function q.replaceAll(test, new)
        if q.isEmpty() then 
            return 
        end 
        
        local index = h 
        local last = t

        while index ~= last do
            if test(data[index]) then
                data[index] = new                                                                
            end  
            
            index = (index + 1) % MAX_SIZE
        end         
    end 
    
    return q
end 

return M


--[[

Demo code:

(function ()
    local q = M.create()
    q.enqueue(3).enqueue(4).enqueue(5)
    q.dequeue()
    q.dequeue()
    q.enqueue(8).enqueue(9).enqueue(10).enqueue(11)
    for k, v in q.iterator() do
        print(k, v)
    end
    
    print('-------------------------------------------------------------------')
    
    q.dequeue()
    q.dequeue()
    q.dequeue()
    q.dequeue()
    q.enqueue(12).enqueue(13).enqueue(14)
    
    for k, v in q.iterator() do
        print(k, v)
    end
end)()

]]



