-- itemScene.lua
-- Author: ChaoYuan
-- Date:   2017-03-24
-- Last modification : 2017-03-24
-- Description: 碎片化的界面，用于在一个scene里面实现界面切换时，管理这个被切换的界面
-- 2017-03-24更新：没有加入对这个碎片化界面的生命周期管理，所以还是得依赖父scene的生命
--                 周期管理，这样有个问题就是每次在主scene绘制的时候这个界面也要被绘制
--                 ，而且要依赖于父scene的生命周期，不够灵活，以后可以考虑加入自己的生
--                 命周期管理

require("core/object")
require("gameBase/gameLayer")

ItemScene = class (GameLayer,false)

--isResize 是否需要重新计算尺寸，以消除黑边情况，true为是
--scene 如果isResize
ItemScene.s_controls={}
ItemScene.ctor = function (self, viewConfig, controller, isResize, view, scene)
    super( self, viewConfig)
    --所属的view的父节点
    self.m_scene = scene 
    --所属的view    
    self.m_controller = controller   
    if view ~=nil then    
        self.m_view = view 
        self.m_view:addChild(self)
        self:resizeToFitScreen(isResize)
    end 
end

ItemScene.dtor = function (self)
    self.m_controller = nil
end

--调整size，防止出现黑边现象
function ItemScene.resizeToFitScreen(self,isResize)
    ItemScene.setFillParent(self,true,true)
    if isResize then 
        local w,h = self.m_scene:getSize()                              --实际屏幕宽高
        local mw,mh = self.m_view:getSize()                        --系统设定的分辨率下的宽高，并不是基于屏幕实际分辨率的宽高
        self.m_view:setSize(mw,mh+h-System.getLayoutHeight())      --System.getLayoutHeight()是在main.lua里面一开始设定的高度，并不是实际屏幕宽高
    end 
end 

--合并itemScene和父Scene的s_controls和s_controlConfig,便于父scene通过findViewById找到控件的对象
function ItemScene.mergeSceneCtrls(self)
    if self.m_scene then        
        ItemScene.s_controls = CombineTables(self.m_scene.s_controls,
	ItemScene.s_controls or {})
        ItemScene.s_controlConfig = CombineTables(self.m_scene.s_controlConfig , 
    ItemScene.s_controlConfig or {})
    end 
end 
GameScene.getController = function(self)
	return self.m_controller
end

GameScene.requestCtrlCmd = function(self, cmd, ...)
	if not self.m_controller then
		return
	end

	return self.m_controller:handleCmd(cmd, ...)
end

ItemScene.s_controlConfig = {}