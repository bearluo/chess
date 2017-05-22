
local circleScan = require("libEffect.shaders.circleScan")
local cubicBezier = require("libs.cubicBezier")

local CircleProgress = class(Node)
CircleProgress.s_default_bg_img = "common/background/winrate_bg.png"
CircleProgress.s_default_w = 246
CircleProgress.s_default_h = 246
CircleProgress.s_default_duration = 1000/60
CircleProgress.s_default_time = 700
function CircleProgress:ctor()
    self.mBg = new(Image,CircleProgress.s_default_bg_img)
    self:setSize(CircleProgress.s_default_w,CircleProgress.s_default_h)
    self.mBg:setSize(CircleProgress.s_default_w,CircleProgress.s_default_h)
    self:addChild(self.mBg)
    self.mPoint = {}              --作用是保证环形进度条的两端是弧形的，而不是平直的
    for i=1,2 do
        self.mPoint[i] = new(Image,"common/icon/red_point.png")
        self.mPoint[i]:setAlign(kAlignCenter)
        self:addChild(self.mPoint[i])
    end
    
    self:setTime(CircleProgress.s_default_time)
    self:setProgress(0)
end

function CircleProgress:changeProgressFile(file,w,h,pointFile,pw,ph)
    if file then
        self.mBg:setFile(file)
        self:setSize(w,h)
        self.mBg:setSize(w,h)
    end

    if pointFile then
        for i=1,2 do
            self.mPoint[i]:setFile(pointFile)
            self.mPoint[i]:setSize(pw,ph)
        end
    end
end

function CircleProgress:setProgress(progress)
    self.mCurProgress = self.mCurProgress or 0
    self.mProgress = tonumber(progress) or self.mProgress

    self:setAngle(0,self.mCurProgress)
    self.mTime = self.mTime or CircleProgress.s_default_time
    self.mCurTime = 0
    self.mChangeProgress = self.mProgress - self.mCurProgress

    if self.mCurProgress ~= self.mProgress then
        delete(self.mProgressAnim)
        self.mProgressAnim = AnimFactory.createAnimInt(kAnimLoop, 0, 1, CircleProgress.s_default_duration, -1)
        self.mProgressAnim:setEvent(self,function()
            self.mCurTime = self.mCurTime + CircleProgress.s_default_duration

            self.mCurProgress = self.mProgress - self.mChangeProgress + self.mChangeProgress*cubicBezier.cubicBezier(0,0.16,0.28,1.5,self.mCurTime/self.mTime).y

            if self.mCurTime >= self.mTime then
                self.mCurProgress = self.mProgress
                delete(self.mProgressAnim)
            end
            self:setAngle(0,self.mCurProgress)
        end)
    end
end

function CircleProgress:countDown(time,callback)
    self.mTime = time
    self.mCurTime = 0
    self.mCurProgress = 0
    self.mProgress    = 360
    self.mChangeProgress = 360
    self:setAngle(self.mCurProgress,self.mProgress)
    delete(self.mProgressAnim)
    self.mProgressAnim = AnimFactory.createAnimInt(kAnimLoop, 0, 1, CircleProgress.s_default_duration, -1)
    self.mProgressAnim:setEvent(self,function()
        self.mCurTime = self.mCurTime + CircleProgress.s_default_duration

        self.mCurProgress = self.mChangeProgress*cubicBezier.cubicBezier(0,0,1,1,self.mCurTime/self.mTime).y

        if self.mCurTime >= self.mTime then
            self.mCurProgress = self.mProgress
            if type(callback) == "function" then
                callback(self.mTime)
            end
            delete(self.mProgressAnim)
        else
            if type(callback) == "function" then
                callback(self.mCurTime)
            end
        end
        self:setAngle(self.mCurProgress,self.mProgress)
    end)
end

function CircleProgress:setAngle(startAngle,endAngle)
    local config = {startAngle = startAngle,endAngle = endAngle, displayClickWiseArea = 1}
    config.startAngle = startAngle
    config.endAngle   = endAngle
    config.displayClickWiseArea = 1

    local w,h = self:getSize()
    local pw,ph = self.mPoint[1]:getSize()
    local a = (w - pw)/2
    local b = (h - ph)/2
    local x = b * math.sin(startAngle * math.pi/180)
    local y = a * math.cos(startAngle * math.pi/180)

    self.mPoint[1]:setPos(x,-y)

    local x = b * math.sin(endAngle * math.pi/180)
    local y = a * math.cos(endAngle * math.pi/180)

    self.mPoint[2]:setPos(x,-y)

    circleScan.applyToDrawing(self.mBg,config)
end

function CircleProgress:setTime(time)
    self.mTime = tonumber(time) or self.mTime
end

function CircleProgress:dtor()
    delete(self.mProgressAnim)
end

return CircleProgress