local M ={}
--[Comment]
-- http://cubic-bezier.com/
-- x1,y1,x2,y2 参数从上网站获取
-- params : x1,y1,x2,y2,retNum
-- retNum 划分为几个点
function M.getCubicBezierTab(x1,y1,x2,y2,retNum)
    local ret = {}
    for i=1,retNum do
        ret[i] = M.cubicBezier(x1,y1,x2,y2,i/retNum)
    end
    return ret
end
--[Comment]
-- x1,y1,x2,y2 参数从上网站获取
-- params : x1,y1,x2,y2,t
-- t 时间 [0,1]
function M.cubicBezier(x1,y1,x2,y2,t)
    local x0,y0 = 0,0
    x1,y1 = x1 or 0,y1 or 0
    x2,y2 = x2 or 0,y2 or 0
    local x4,y4 = 1,1
    local ret = {}
    ret.x = x0*math.pow(1-t,3) + 3*x1*t*math.pow(1-t,2) + 3*x2*math.pow(t,2)*(1-t) + x4*math.pow(t,3)
    ret.y = y0*math.pow(1-t,3) + 3*y1*t*math.pow(1-t,2) + 3*y2*math.pow(t,2)*(1-t) + y4*math.pow(t,3)
    return ret
end

return M