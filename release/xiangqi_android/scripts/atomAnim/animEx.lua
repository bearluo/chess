require("core/anim")
--region NewFile_1.lua
--Author : KimWang
--Date   : 2015/6/11
--此文件由[BabeLua]插件自动生成
if AnimBase ~= nil then
    AnimBase.pause = function(self)
        if anim_set_pause ~= nil then
            anim_set_pause(self.m_animID,1);
        end
    end

    AnimBase.resume = function(self)
        if anim_set_pause ~= nil then
            anim_set_pause(self.m_animID,0);
        end
    end
end
--endregion
