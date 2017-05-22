require("core/anim");
require("core/prop");

TranslateShakeAnim = {};
TranslateShakeAnim.amplitude = 0.2;
TranslateShakeAnim.translateBase = 20;
TranslateShakeAnim.shake_translateNum = 2;

--animType  动画类型，nil,0进入(先加速出现，再抖动); 1离开（先抖动，在加速移出）; 
--translateBase 移动基数,一般为距离的因子,越小越顺滑,nil为默认20
--amplitude 抖动幅度,小数值（0-1）,越大幅度越大,nil为默认0.05
--shake_translateNum 抖动次数,整数数值,和translateBase概念相同,nil为默认2;
--needRemoveProp    动画执行完后是否需要移出属性（true不移除，默认移出）
TranslateShakeAnim.play = function(drawing,sequence,animType,startX,endX,startY,endY,time,translateBase,amplitude,shake_translateNum,needRemoveProp)
	if not drawing then
		return;
	end
    TranslateShakeAnim.stopAnimDrawing(drawing,sequence);
    local layoutScale = System.getLayoutScale();
	startX = startX and startX * layoutScale or startX;
	endX = endX and endX * layoutScale or endX;
	startY = startY and startY * layoutScale or startY;
	endY = endY and endY * layoutScale or endY;
    local numArrayX = nil;
    local numArrayY = nil;
    if animType and animType == 1 then
        numArrayX = TranslateShakeAnim.createLeaveArray(startX,endX,translateBase or TranslateShakeAnim.translateBase,amplitude or TranslateShakeAnim.amplitude,shake_translateNum or TranslateShakeAnim.shake_translateNum);
        numArrayY = TranslateShakeAnim.createLeaveArray(startY,endY,translateBase or TranslateShakeAnim.translateBase,amplitude or TranslateShakeAnim.amplitude,shake_translateNum or TranslateShakeAnim.shake_translateNum);
    else
        numArrayX = TranslateShakeAnim.createInArray(startX,endX,translateBase or TranslateShakeAnim.translateBase,amplitude or TranslateShakeAnim.amplitude,shake_translateNum or TranslateShakeAnim.shake_translateNum);
        numArrayY = TranslateShakeAnim.createInArray(startY,endY,translateBase or TranslateShakeAnim.translateBase,amplitude or TranslateShakeAnim.amplitude,shake_translateNum or TranslateShakeAnim.shake_translateNum);
    end
    local animResX = new(ResIntArray,numArrayX);
    local animResY = new(ResIntArray,numArrayY);
    local num = #(numArrayX or {})-1;
    drawing.m_translateShakeAnimX = AnimFactory.createAnimIndex(kAnimNormal, 0, #(numArrayX or {})-1, time, animResX, -1);
    drawing.m_translateShakeAnimY = AnimFactory.createAnimIndex(kAnimNormal, 0, #(numArrayY or {})-1, time, animResY, -1);
    local translateShakeProp = AnimFactory.createTranslate(drawing.m_translateShakeAnimX, drawing.m_translateShakeAnimY);
    ToolKit.setDebugName(drawing.m_translateShakeAnimX , "AnimIndex|TranslateShakeAnim.m_translateShakeAnimX");
    ToolKit.setDebugName(drawing.m_translateShakeAnimY , "AnimIndex|TranslateShakeAnim.m_translateShakeAnimY");
    drawing:addProp(translateShakeProp,sequence);
    drawing.m_translateShakeAnimY:setEvent(nil, function () 
            TranslateShakeAnim.stopAnim(drawing,needRemoveProp,sequence)
        end);
end

TranslateShakeAnim.createInArray = function(startValue,endValue,translateBase,amplitude,shake_translateNum)
    if not startValue or not endValue then
        return;
    end
    --distance 移动距离
    local distance = endValue - startValue;
    if distance == 0 then
        return;
    end
    --shake_distance 抖动距离
    local shake_distance = distance*amplitude;

    if distance < 0 then
        if translateBase > 0 then
            translateBase = 0 - translateBase;
        end
    end
    --totalNum 节点个数
    local totalNum = math.abs(distance)/translateBase;
    local numArray = {};
    for i=1, totalNum do
        if i == 1 then
            numArray[i] = startValue + translateBase;
        else
            if i > (totalNum - 1) then
                numArray[i] = endValue;
            else
                numArray[i] = numArray[i-1] + translateBase;
            end
        end
    end
    --shake_amplitude 抖动幅度变化
    local shake_amplitude = shake_distance/shake_translateNum;
    for i=1, shake_translateNum do
        numArray[#numArray+1] = numArray[#numArray] - shake_distance;
        numArray[#numArray+1] = numArray[#numArray] + shake_distance;
        shake_distance = shake_distance - shake_amplitude;
    end
    return numArray;
end

TranslateShakeAnim.createLeaveArray = function(startValue,endValue,translateBase,amplitude,shake_translateNum)
    if not startValue or not endValue then
        return;
    end
    local distance = endValue - startValue;
    if distance == 0 then
        return;
    end
    local shake_distance = distance*amplitude;

    if distance < 0 then
        if translateBase > 0 then
            translateBase = 0 - translateBase;
        end
    end

    local totalNum = math.abs(distance)/math.abs(translateBase);
    local numArray = {};
    
    local shake_amplitude = shake_distance/shake_translateNum;
    for i=1, shake_translateNum do
        if i == 1 then
            numArray[#numArray+1] = startValue - shake_amplitude;
            numArray[#numArray+1] = numArray[#numArray] - shake_amplitude;
        else
            numArray[#numArray+1] = numArray[#numArray] - shake_amplitude;
            numArray[#numArray+1] = numArray[#numArray] - shake_amplitude;
        end
    end

    for i=#numArray+1, totalNum + shake_translateNum do
        if i == 1 then
            numArray[i] = startValue + translateBase;
        else
            if i > (totalNum + shake_translateNum - 1) then
                numArray[i] = endValue;
            else
                numArray[i] = numArray[i-1] + translateBase;
            end
        end
    end
    return numArray;
end

TranslateShakeAnim.stopAnim = function(drawing,needRemoveProp,sequence)
    if drawing then
        if not needRemoveProp then
            if sequence then
                drawing:removeProp(sequence);
                while sequence > 1 do
                    sequence = sequence - 1;
                    drawing:removeProp(sequence);
                end
            end
        end
        if drawing.m_translateShakeAnimX then
            delete(drawing.m_translateShakeAnimX); 
            drawing.m_translateShakeAnimX = nil;
        end
        if drawing.m_translateShakeAnimY then
            delete(drawing.m_translateShakeAnimY); 
            drawing.m_translateShakeAnimX = nil;
        end
    end
end

TranslateShakeAnim.stopAnimDrawing = function(drawing,sequence)
    if drawing then
        if sequence then
            drawing:removeProp(sequence);
        end
        if drawing.m_translateShakeAnimX then
            delete(drawing.m_translateShakeAnimX); 
            drawing.m_translateShakeAnimX = nil;
        end
        if drawing.m_translateShakeAnimY then
            delete(drawing.m_translateShakeAnimY); 
            drawing.m_translateShakeAnimX = nil;
        end
    end
end