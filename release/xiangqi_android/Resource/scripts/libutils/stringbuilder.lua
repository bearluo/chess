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

M.create = function (initialValue)
  local t = { initialValue }
  local finalString = nil
  local sb

  sb = {
    append = function (...)
      -- both support sb:append(s) and sb.append(s)
      -- TODO type check
      local s

      if select(1, ...) == sb then
        s = select(2, ...)
      else
        s = select(1, ...)
      end

      table.insert(t,s)

      finalString = nil

      return sb
    end,

    toString = function ()
      if finalString == nil then
        finalString = table.concat(t)
      end

      return finalString
    end
  }

  setmetatable(sb,{
    __tostring = sb.toString()
  })

  return sb
end

return M

