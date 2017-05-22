AnimDialogFactory = {}

function AnimDialogFactory.createNormalAnim(dialog)
    local status = 0
    local showAnim,dismiss,stopAnim
    local anim,prop
    local cubicBezier = require("libs.cubicBezier")
    showAnim = function()
        dialog:setVisible(true)
        Log.i("showAnim"..status)
        
        if status == 2 then
            stopAnim()
        end

        if status == 0 then
            local index = 20
            local curIndex = 0
            local pos = cubicBezier.getCubicBezierTab(0.17,0.67,0.68,1.15,index)
            local array = {}
            for i,val in ipairs(pos) do
                array[i] = val.y
            end
	        local scale = new(ResDoubleArray, array);
	        anim = new(AnimIndex , kAnimNormal, 1 , index-1, index*1000/60 , scale, 0);
            prop = new(PropScale, anim, anim, kCenterDrawing)
            dialog.m_root:addProp(prop,1000)
            dialog.m_root:addPropTransparency(1001, kAnimNormal, index*1000/60/2, 0, 0, 1)
            anim:setEvent(nil,function()
                stopAnim()
            end)
        elseif status == 1 then
        end
        status = 1
        Log.i("showAnim"..status)
    end
    dismissAnim = function()
        Log.i("dismissAnim"..status)
        if status == 1 then
            stopAnim()
        end

        if status == 0 then
            local index = 26
            local curIndex = 0
            local pos = cubicBezier.getCubicBezierTab(0.17,0.67,0.68,1.15,index)
            local array = {}
            for i,val in ipairs(pos) do
                array[#pos-i+1] = val.y
            end
	        local scale = new(ResDoubleArray, array);
	        anim = new(AnimIndex , kAnimNormal, 1 , index-1, index*1000/60 , scale, 0);
            prop = new(PropScale, anim, anim, kCenterDrawing)
            dialog.m_root:addProp(prop,1000)
            dialog.m_root:addPropTransparency(1001, kAnimNormal, index*1000/60/4, 0, 1, 0)
            anim:setEvent(nil,function()
                dialog:setVisible(false)
                stopAnim()
            end)
        elseif status == 2 then
        end
        status = 2
        Log.i("dismissAnim"..status)
    end
    stopAnim = function()
        Log.i("stopAnim"..status)
        if status == 1 then
            --dialog:setVisible(true)
        elseif status == 2 then
            dialog:setVisible(false)
        end
        delete(anim)
        delete(prop)
        dialog.m_root:removeProp(1000)
        dialog.m_root:removeProp(1001)
        status = 0
        Log.i("stopAnim"..status)
    end
    local normalAnim = {
        showAnim = showAnim,
        dismissAnim  = dismissAnim,
        stopAnim = stopAnim
    }
    return normalAnim
end


function AnimDialogFactory.createMoveUpAnim(dialog)
    local status = 0
    local showAnim,dismiss,stopAnim
    local anim,prop
    local cubicBezier = require("libs.cubicBezier")
    showAnim = function()
        dialog:setVisible(true)
        Log.i("showAnim"..status)
        
        if status == 2 then
            stopAnim()
        end

        if status == 0 then
            local index = 30
            local curIndex = 0
            local pos = cubicBezier.getCubicBezierTab(0,0.61,0.8,1,index)
            local array = {}
            local _,h = dialog.m_root:getSize()
            for i,val in ipairs(pos) do
                array[i] = (1 - val.y) * h
            end
	        local scale = new(ResDoubleArray, array);
	        anim = new(AnimIndex , kAnimNormal, 1 , index-1, index*1000/60 , scale, 0);
            prop = new(PropTranslate, nil, anim)
            dialog.m_root:addProp(prop,1000)
            dialog.m_root:addPropTransparency(1001, kAnimNormal, index*1000/60/2, 0, 0, 1)
            anim:setEvent(nil,function()
                stopAnim()
            end)
        elseif status == 1 then
        end
        status = 1
        Log.i("showAnim"..status)
    end
    dismissAnim = function()
        Log.i("dismissAnim"..status)
        if status == 1 then
            stopAnim()
        end

        if status == 0 then
            local index = 26
            local curIndex = 0
            local pos = cubicBezier.getCubicBezierTab(0,0.42,0.3,1,index)
            local array = {}
            local _,h = dialog.m_root:getSize()
            for i,val in ipairs(pos) do
                array[i] = val.y * h
            end
	        local scale = new(ResDoubleArray, array);
	        anim = new(AnimIndex , kAnimNormal, 1 , index-1, index*1000/60 , scale, 0);
            prop = new(PropTranslate, nil, anim)
            dialog.m_root:addProp(prop,1000)
            dialog.m_root:addPropTransparency(1001, kAnimNormal, index*1000/60/4, 0, 1, 0)
            anim:setEvent(nil,function()
                dialog:setVisible(false)
                stopAnim()
            end)
        elseif status == 2 then
        end
        status = 2
        Log.i("dismissAnim"..status)
    end
    stopAnim = function()
        Log.i("stopAnim"..status)
        if status == 1 then
            --dialog:setVisible(true)
        elseif status == 2 then
            dialog:setVisible(false)
        end
        delete(anim)
        delete(prop)
        dialog.m_root:removeProp(1000)
        dialog.m_root:removeProp(1001)
        status = 0
        Log.i("stopAnim"..status)
    end
    local normalAnim = {
        showAnim = showAnim,
        dismissAnim  = dismissAnim,
        stopAnim = stopAnim
    }
    return normalAnim
end