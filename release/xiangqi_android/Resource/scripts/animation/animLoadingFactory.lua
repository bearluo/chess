AnimLoadingFactory = {}

function AnimLoadingFactory.createChessLoadingAnimView()
    return new(ChessLoadingAnim)
end

AnimLoadingBase = class(Node)

function AnimLoadingBase:ctor()
end

function AnimLoadingBase:start()
end

function AnimLoadingBase:resume()
end

function AnimLoadingBase:pause()
end

function AnimLoadingBase:stop()
end

function AnimLoadingBase:dtor()
end

--- 栗子
require(VIEW_PATH .. "chess_loading_anim")
ChessLoadingAnim = class(AnimLoadingBase)

function ChessLoadingAnim:ctor()
    self.mView = SceneLoader.load(chess_loading_anim)
    self.mRealW,self.mRealH = self.mView:getSize()
    self:setSize(self.mRealW,self.mRealH)
    self:addChild(self.mView)
    self.mLoadingBg     = self.mView:getChildByName("loading_bg")
    self.mLoadingView   = self.mLoadingBg:getChildByName("loading_view")
    self.mLoadingTxt    = self.mLoadingBg:getChildByName("loading_txt")
end

function ChessLoadingAnim:start()
    self:stop()
    self.mLoadingView:removeProp(1);
    self.mLoadingView:setFile("common/icon/king_1.png");
    self.mLoadingAnim1 = self.mLoadingView:addPropScale(1, kAnimLoop, 500, -1, 1, 0, 1, 1, kCenterDrawing)
    local index = 1;
    self.mLoadingAnim1:setEvent(nil,function()
            index = index % 2 + 1;
            if index ~= 2 then return end 
            local file = self.mLoadingView:getFile()
            if file == "common/icon/king_1.png" then
                file = "common/icon/king_2.png"
            else
                file = "common/icon/king_1.png"
            end
            self.mLoadingView:setFile(file)
        end);
    self.mLoadingTxt:setFile("animation/loading/loading_4.png");
    local index = 4;
    self.mLoadingAnim2 = AnimFactory.createAnimInt(kAnimLoop, 0, 1, 200, -1);
    self.mLoadingAnim2:setEvent(nil,function()
            index = index % 4 + 1
            self.mLoadingTxt:setFile( string.format("animation/loading/loading_%d.png",index));
        end)
end

function ChessLoadingAnim:resume()
    if self.mLoadingAnim1 then
        self.mLoadingAnim1:resume()
    end
    if self.mLoadingAnim2 then
        self.mLoadingAnim2:resume()
    end
end

function ChessLoadingAnim:pause()
    if self.mLoadingAnim1 then
        self.mLoadingAnim1:pause()
    end
    if self.mLoadingAnim2 then
        self.mLoadingAnim2:pause()
    end
end

function ChessLoadingAnim:stop()
    if self.mLoadingAnim1 then
        delete(self.mLoadingAnim1)
        self.mLoadingAnim1 = nil
    end
    if self.mLoadingAnim2 then
        delete(self.mLoadingAnim2)
        self.mLoadingAnim2 = nil
    end
end

function ChessLoadingAnim:dtor()
    self:stop()
end

function ChessLoadingAnim:setSize(w,h)
    self.super.setSize(self,w,h)
    self.mScale = w / self.mRealW
    if self.mView:checkAddProp(1) then
        self.mView:removeProp(1)
    end
    self.mView:addPropScaleSolid(1, self.mScale, self.mScale, kCenterDrawing)
end