-- darkModeLayer.lua
-- author: LeoLi
-- date: 2016/09/02
-- note: 夜间模式
require(VIEW_PATH.."dark_mode_view");
DarkModeLayer = class(GameLayer);
DarkModeLayer.instance = nil;
DarkModeLayer.ctor = function(self)
    self.m_root_view = SceneLoader.load(dark_mode_view);
    self.m_root_view:setVisible(false);
    self.m_root_view:setLevel(1000);
    self.m_bg = self.m_root_view:getChildByName("bg");
    self.m_bg:setTransparency(0.32);
end;

DarkModeLayer.dtor = function(self)
    
end;

DarkModeLayer.getInstance = function(self)
    if not DarkModeLayer.instance then
        DarkModeLayer.instance = new(DarkModeLayer);
    end;
    return DarkModeLayer.instance;
end;

DarkModeLayer.show = function(self)
    self.m_root_view:setVisible(true);
end;

DarkModeLayer.hide = function(self)
    self.m_root_view:setVisible(false);
end;