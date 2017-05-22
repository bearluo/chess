--region progressBar.lua
--Date 2017.1.22
--进度条
--endregion


ProgressBar = class(Node)

ProgressBar.horizontal = 1 --水平
ProgressBar.vertical = 2 --

ProgressBar.default_width = 400
ProgressBar.default_height = 50


function ProgressBar.ctor(self,w,h,img,direction)
    self.progressDirection = direction or ProgressBar.horizontal

    self.default_width = ProgressBar.default_width 
    self.default_height = ProgressBar.default_height 
    if self.progressDirection == ProgressBar.vertical then
        self.default_width = ProgressBar.default_height 
        self.default_height = ProgressBar.default_width 
    end
    self.progressWidth = w or self.default_width
    self.progressHeight = h or self.default_height
    local progressBgImg = img or ""
    self.progressBg = new(Image,progressBgImg)
    self.progressBg:setSize(self.progressWidth,self.progressHeight)
    self.progressBg:setAlign(kAlignCenter)
    self:addChild(self.progressBg)

    self.progressIcon = new(Image,"drawable/input_error_icon.png")
    self.progressIcon:setAlign(kAlignLeft)
    self.progressIcon:setSize(20,50)
    self.progressBg:addChild(self.progressBg)

    self.scheduleSize = 20
end 

function ProgressBar.ctor(self)

end

function ProgressBar.updateProgress(self,schedule)
    if not schedule then return end
    if self.progressDirection == ProgressBar.horizontal then
        self.scheduleSize = self.progressWidth * schedule
        self.progressIcon:setSize(self.scheduleSize,self.progressHeight)
    elseif self.progressDirection == ProgressBar.vertical then
        self.scheduleSize = self.progressHeight * schedule
        self.progressIcon:setSize(self.progressWidth,self.scheduleSize)
    end
end