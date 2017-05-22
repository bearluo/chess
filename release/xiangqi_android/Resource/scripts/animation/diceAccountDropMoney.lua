-- region diceAccountDropMoney.lua
-- Author : BrianLi
-- Date   : 2016/12/27
require("core/anim");
require("common/uiFactory");
require("common/animFactory");
require("animation/particleMoney");
require("swf_anim_pin/money_pin_map");

DiceAccountDropMoney = class(AnimBase);
DiceAccountDropMoney.imageSize = 13;
DiceAccountDropMoney.s_level = 220;
--720
DiceAccountDropMoney.load = function()
    if not DiceAccountDropMoney.root then
        DiceAccountDropMoney.root = UIFactory.createNode();
        DiceAccountDropMoney.root:setSize(System.getScreenScaleWidth(), System.getScreenScaleHeight());
        DiceAccountDropMoney.root:addToRoot();
        DiceAccountDropMoney.root:setPos(0, 0);
        DiceAccountDropMoney.root:setLevel(DiceAccountDropMoney.s_level);
        DiceAccountDropMoney.startAnim();
    end
end

-- 背景变换
DiceAccountDropMoney.startAnim = function()
    -- body
    --MusicController.playEffect(MusicManifest.AUDIO_GOLD_FELL_EFFECT);
    DiceAccountDropMoney.parMoneyNode = ParticleSystem.getInstance():create(money_pin_map, ParticleMoney, 0, 0, nil, kParticleTypeBlast,(DiceAccountDropMoney.coinNum or 50), { ["h"] = System.getScreenScaleHeight() / 2, ["w"] = System.getScreenScaleWidth();["rotation"] = 4;["scale"] = 1;["maxIndex"] = 7; });
    DiceAccountDropMoney.root:addChild(DiceAccountDropMoney.parMoneyNode);
    DiceAccountDropMoney.parMoneyNode:resume();
end


DiceAccountDropMoney.play = function(num)
    Log.d("DiceAccountDropMoney", "play");
    DiceAccountDropMoney.coinNum = num or 50;
    DiceAccountDropMoney.stop();
    DiceAccountDropMoney.load();
end

DiceAccountDropMoney.stop = function()
    if DiceAccountDropMoney.root then
        delete(DiceAccountDropMoney.root);
    end
    DiceAccountDropMoney.root = nil;
end

DiceAccountDropMoney.release = function()
    DiceAccountDropMoney.stop();
end



--掉金币的动画，并且显示金币数量突出提示
DiceAccountDropMoneyAndShowTip = class(DiceAccountDropMoney)

function DiceAccountDropMoneyAndShowTip.ctor(self)
    
end 
function DiceAccountDropMoneyAndShowTip.dtor(self)
    DiceAccountDropMoney.stop()
end 

function DiceAccountDropMoneyAndShowTip.show(self,num)
    DiceAccountDropMoney.play(num)
end 

function DiceAccountDropMoneyAndShowTip.startAnim(self)
    DiceAccountDropMoney.startAnim()
    self:showTip()
end 

function DiceAccountDropMoneyAndShowTip.showTip(self)
    --[[self.tip_bg = new (Image,"")
    self.tip_bg:setSize(450,50)
    self.tip_bg:setAlign(kAlignCenter)
    self.tip_tx = new (Text,"获得"..DiceAccountDropMoney.coinNum.."金币")
    self.tip_tx:setAlign(kAlignCenter)
    self.tip_bg:addChild(self.tip_tx)
    DiceAccountDropMoney.root:addChild(self.tip_bg)
    ]]--
end 
-- endregion
