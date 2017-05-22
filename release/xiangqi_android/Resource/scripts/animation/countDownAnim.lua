--CountDownAnim.lua
--2016/07/14
--此文件由[BabeLua]插件自动生成
--auther: FordFan
--endregion

CountDownAnim = {};

CountDownAnim.circleScanShaders = require("libEffect.shaders.circleScan");
CountDownAnim.default_time = 10000;
CountDownAnim.AnimPause = false;
CountDownAnim.AnimStop = true
CountDownAnim.m_animPool = {};
-- startTime总时间
-- time 当前倒计时时间
function CountDownAnim.play(imgNote,time,startTime)
    local imgNote = imgNote;
    local animTime = time or CountDownAnim.default_time;
    local animStartTime = startTime or time
    local angle = math.floor( time / startTime * 360 )
    local repeatTime = animTime/angle;
    CountDownAnim.removeAllAnim();
    CountDownAnim.m_animPool = {};
    if imgNote ~= nil then
        local view = imgNote:getChildByName("progress");
        local view1 = imgNote:getChildByName("progress1");
        local view2 = imgNote:getChildByName("progress2");
        view:setTransparency(1);
        view1:setTransparency(1);
        view2:setTransparency(1);
        local progresspoint = imgNote:getChildByName("progresspoint");
        local x,y = view:getSize();
        progresspoint:setVisible(false);
        progresspoint:setPos(0,-(y*0.9)/2);
        progresspoint:setVisible(true);
    
        view1:setVisible(false);
        view2:setVisible(false);
        view:setVisible(true);
        local anim = new(AnimInt,kAnimRepeat,0,0,repeatTime,-1)
        CountDownAnim.m_animPool[#CountDownAnim.m_animPool+1] = anim
        local config = {startAngle = 0,endAngle = 360 - angle, displayClickWiseArea = -1}
        anim:setEvent(nil,function() 
            if CountDownAnim.AnimPause then return end
            config.endAngle = config.endAngle+1
            CountDownAnim.circleScanShaders.applyToDrawing(view,config)
            CountDownAnim.circleScanShaders.applyToDrawing(view1,config)
            CountDownAnim.circleScanShaders.applyToDrawing(view2,config)
            local currentAngle = math.floor(config.endAngle);
            local currentPercent = currentAngle/360;
            local staticPercent = 0.3333;
            local staticPercent1 = 0.6666;
            if  currentPercent >staticPercent and currentPercent<staticPercent1 then
                view1:setVisible(true);
                local yellowpercent = (currentAngle-120)/40;
                if yellowpercent<=1 then 
                    view1:setTransparency(yellowpercent); view:setTransparency(1-yellowpercent);
                end 
            elseif currentPercent >staticPercent1 then 
                view2:setVisible(true);
                view1:setVisible(true);
                local redpercent = (currentAngle-240)/40;
                if redpercent<=1 then 
                    view2:setTransparency(redpercent); view1:setTransparency(1-redpercent);
                end
            end 
            --倒计时新动画
            local a = (y*0.9)/2
            local b = (y*0.9)/2
            local x = b * math.sin(config.endAngle * math.pi/180)
            local y = a * math.cos(config.endAngle * math.pi/180)
            progresspoint:setPos(x,-y)
            -----------------------------------------------------------------
            if config.endAngle - config.startAngle>=360 or config.endAngle-config.startAngle < 0 then
                if view then
                    view:setVisible(false);
                    if progresspoint then 
                        progresspoint:setVisible(false);
                    end 
                end
                CountDownAnim.removeAllAnim()
            end  
        end)
    end
end

function CountDownAnim.resume()
    CountDownAnim.AnimPause = false;
end

function CountDownAnim.pause()
    CountDownAnim.AnimPause = true;
end

function CountDownAnim.stop(imgNote)
    local imgNote = imgNote;
    if imgNote then 
        local view = imgNote:getChildByName("progress");
        view:setVisible(false);
    end
    CountDownAnim.removeAllAnim()
end

function CountDownAnim.removeAllAnim()
    print_string("removeProp ");
    if CountDownAnim.m_animPool ~= nil then
        if #CountDownAnim.m_animPool > 0 then
            for i = 1,#CountDownAnim.m_animPool do
                delete(CountDownAnim.m_animPool[i])
                CountDownAnim.m_animPool[i] = nil
            end
        end  
    end 
end