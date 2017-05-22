require("core/drawing")
require("atomAnim/resEx")

if DrawingBase then 

DrawingBase.removeAtomPropEase = function(self, sequence)
    if self.m_props[sequence] == nil then
        return false;
    end

    if drawing_prop_remove(self.m_drawingID, sequence) ~= 0 then
    	return false;
    end

	if self.m_props[sequence] then
		delete(self.m_props[sequence]["prop"]);
		for _,v in pairs(self.m_props[sequence]["anim"]) do 
			delete(v);
		end
		if self.m_props[sequence]["res"] then
			for _,v in pairs(self.m_props[sequence]["res"]) do 
				delete(v);
			end 
		end
		self.m_props[sequence] = nil;
	end
	return true;
end

DrawingBase.removeAtomPropEaseByID = function(self, propId)
	if drawing_prop_remove_id(self.m_drawingID, propId) ~= 0 then
		return false;
	end

	for k,v in pairs(self.m_props) do 
		if v["prop"]:getID() == propId then
			delete(v["prop"]);
			for _,anim in pairs(v["anim"]) do 
				delete(anim);
			end
			if v["res"] then
				for _,res in pairs(v["res"]) do 
					delete(res);
				end 
			end
			self.m_props[k] = nil;
			break;
		end
	end
	
	return true;
end

---------------------------------------------------------------------------------------
--------------------------function addPropEase-----------------------------------------
---------------------------------------------------------------------------------------
DrawingBase.addAtomPropTransparencyEase = function(self, sequence, animType,EaseType, duration, delay, startValue, endValue, period)
	if EaseType == nil or EaseTypeMap[EaseType] == nil then
		return DrawingBase.addPropTransparency(self, sequence, animType, duration, delay, startValue, endValue)
	end
	return DrawingBase.addAtomPropEase(self,sequence,PropTransparency,nil,nil,nil,animType,EaseType,duration,delay,startValue,endValue, period);
end

--颜色动画
DrawingBase.addAtomPropColorEase = function(self, sequence, animType, EaseType,duration, delay, rStart, rEnd, gStart, gEnd, bStart, bEnd, rPeriod, gPeriod, bPeriod)
	if EaseType == nil or EaseTypeMap[EaseType] == nil then
		return DrawingBase.addPropColor(self, sequence, animType, duration, delay, rStart, rEnd, gStart, gEnd, bStart, bEnd)
	end
	return DrawingBase.addAtomPropEase(self,sequence,PropColor,nil,nil,nil,animType,EaseType,duration,delay,rStart,rEnd,gStart,gEnd,bStart,bEnd,rPeriod, gPeriod, bPeriod);
end

--缩放动画
DrawingBase.addAtomPropScaleEase = function(self, sequence, animType,EaseType, duration, delay, startX, endX, startY, endY, center, x, y, periodX, periodY)
	if EaseType == nil or EaseTypeMap[EaseType] == nil then
		return DrawingBase.addAtomPropScaleEx(self, sequence, animType, duration, delay, startX, endX, startY, endY, center, x, y)
	end
	local layoutScale = System.getLayoutScale();
	x = x and x * layoutScale or x;
	y = y and y * layoutScale or y;
	return DrawingBase.addAtomPropEase(self,sequence,PropScale,center, x, y,animType,EaseType,duration,delay,startX,endX,startY,endY, periodX, periodY)
end

DrawingBase.addAtomPropScaleEx = function(self, sequence, animType, duration, delay, startX, endX, startY, endY, center, x, y)
	local layoutScale = System.getLayoutScale();
    local xScale = System.getScreenWidth() / System.getLayoutWidth();
    local yScale = System.getScreenHeight() / System.getLayoutHeight();
	x = x and x * xScale or x;
	y = y and y * yScale or y;
	return DrawingBase.addAnimProp(self,sequence,PropScale,center, x, y,animType,duration,delay,startX,endX,startY,endY);
end


--旋转动画
DrawingBase.addAtomPropRotateEase = function(self, sequence, animType, EaseType,duration, delay, startValue, endValue, center, x, y, period)
	if EaseType == nil or EaseTypeMap[EaseType] == nil then
		return DrawingBase.addAtomPropRotateEx(self, sequence, animType, duration, delay, startValue, endValue, center, x, y)
	end
	local xScale = System.getScreenWidth() / System.getLayoutWidth();
    local yScale = System.getScreenHeight() / System.getLayoutHeight();
	x = x and x * xScale or x;
	y = y and y * yScale or y;
	return DrawingBase.addAtomPropEase(self,sequence,PropRotate,center, x, y,animType,EaseType,duration,delay,startValue,endValue, period);
end


DrawingBase.addAtomPropRotateEx = function(self, sequence, animType, duration, delay, startValue, endValue, center, x, y)
	local xScale = System.getScreenWidth() / System.getLayoutWidth();
    local yScale = System.getScreenHeight() / System.getLayoutHeight();
	x = x and x * xScale or x;
	y = y and y * yScale or y;
	return DrawingBase.addAnimProp(self,sequence,PropRotate,center, x, y,animType,duration,delay,startValue,endValue);
end


--平移动画
DrawingBase.addAtomPropTranslateEase = function(self,sequence,animType,EaseType,duration,delay,startX,endX,startY,endY, periodX, periodY)
	if EaseType == nil or EaseTypeMap[EaseType] == nil then
		return DrawingBase.addAtomPropTranslateEx(self, sequence, animType, duration, delay, startX, endX, startY, endY)
	end
	local xScale = System.getScreenWidth() / System.getLayoutWidth();
    local yScale = System.getScreenHeight() / System.getLayoutHeight();
	startX = startX and startX * xScale or startX;
	startY = startY and startY * yScale or startY;
    endX = endX and endX * xScale or endX;
	endY = endY and endY * yScale or endY;
	return DrawingBase.addAtomPropEase(self,sequence,PropTranslate,nil,nil,nil,animType,EaseType,duration,delay,startX,endX,startY,endY, periodX, periodY)
end

DrawingBase.addAtomPropTranslateEx = function(self, sequence, animType, duration, delay, startX, endX, startY, endY)
	local xScale = System.getScreenWidth() / System.getLayoutWidth();
    local yScale = System.getScreenHeight() / System.getLayoutHeight();
	startX = startX and startX * xScale or startX;
	startY = startY and startY * yScale or startY;
    endX = endX and endX * xScale or endX;
	endY = endY and endY * yScale or endY;
	return DrawingBase.addAnimProp(self,sequence,PropTranslate,nil,nil,nil,animType,duration,delay,startX,endX,startY,endY);
end

--跳跃动画
DrawingBase.addAtomPropTranslateJump = function(self,sequence,animType,duration,delay,startX,endX,startY,endY,timesX, timesY, jumpX, jumpY)
	local xScale = System.getScreenWidth() / System.getLayoutWidth();
    local yScale = System.getScreenHeight() / System.getLayoutHeight();
	startX = startX and startX * xScale or 0;
    startY = startY and startY * yScale or 0;
	endX = endX and endX * xScale or 0;
	endY = endY and endY * yScale or 0;
	jumpX = jumpX and jumpX * xScale or 0;
    jumpY = jumpY and jumpY * yScale or 0;
	return DrawingBase.addAtomPropJump(self,sequence,PropTranslate,animType,duration,delay,startX,endX,startY,endY,timesX,timesY,jumpX,jumpY)
end 

DrawingBase.addAtomPropJump = function(self,sequence,propClass,animType,duration,delay,startX,endX,startY,endY,timesX,timesY,jumpX,jumpY)
	if not DrawingBase.checkAddProp(self,sequence) then 
		return;
	end

   if timesX <= 0 then
        timesX = 1;
        jumpX = 0;
   end

   if timesY <= 0 then
        timesY = 1;
        jumpY = 0;
   end

	delay = delay or 0;

	local resJump = {};
	local anims = {};

    resJump[1] = new(ResDoubleArrayJumpX,duration,startX,endX,timesX or 0,jumpX);
    resJump[2] = new(ResDoubleArrayJumpY,duration,startY,endY,timesY or 0,jumpY);
    anims[1] = new(AnimIndex,animType,0,resJump[1]:getLength()-1,duration,resJump[1],delay);
    anims[2] = new(AnimIndex,animType,0,resJump[2]:getLength()-1,duration,resJump[2],delay);

	local prop = new(propClass,anims[1],anims[2]);
	if DrawingBase.doAddAtomPropEase(self,prop,sequence,anims[1],anims[2],resJump[1],resJump[2]) then
		return anims[1],anims[2];
	end
end 


--椭圆动画
DrawingBase.addAtomPropTranslateEllipse = function(self,sequence,animType,duration,delay,centerX,centerY,axisX,axisY,startAngleX,startAngleY,endAngleX,endAngleY)
	local xScale = System.getScreenWidth() / System.getLayoutWidth();
    local yScale = System.getScreenHeight() / System.getLayoutHeight();
	centerX = centerX and centerX * xScale or centerX;
	centerY = centerY and centerY * yScale or centerY;
	axisX = axisX and axisX * xScale or axisX;
	axisY = axisY and axisY * yScale or axisY;
	return DrawingBase.addAtomPropEllipse(self,sequence,PropTranslate,animType,duration,delay,centerX,centerY,axisX,axisY,startAngleX,startAngleY,endAngleX,endAngleY);
end 

DrawingBase.addAtomPropEllipse = function(self,sequence,propClass,animType,duration,delay,centerX,centerY,axisX,axisY,startAngleX,startAngleY,endAngleX,endAngleY)
	if not DrawingBase.checkAddProp(self,sequence) then 
		return;
	end

	delay = delay or 0;

	local resEllipse = {};
	local anims = {};

    if centerX ~= nil then
	    resEllipse[1] = new(ResDoubleArrayEllipseX,duration,centerX,axisX,startAngleX, endAngleX);
        anims[1] = new(AnimIndex,animType,0,resEllipse[1]:getLength()-1,duration,resEllipse[1],delay);
	end

    if centerY ~= nil then 
        resEllipse[2] = new(ResDoubleArrayEllipseY,duration,centerY,axisY,startAngleY, endAngleY);
        anims[2] = new(AnimIndex,animType,0,resEllipse[2]:getLength()-1,duration,resEllipse[2],delay);
    end

	local prop = new(propClass,anims[1],anims[2]);
	if DrawingBase.doAddAtomPropEase(self,prop,sequence,anims[1],anims[2],resEllipse[1],resEllipse[2]) then
		return anims[1],anims[2];
	end
end 

--贝塞尔曲线
DrawingBase.addAtomPropTranslateCurve = function(self,sequence,animType,duration,delay,startX,endX,startY,endY,controlX,controlY)
	local xScale = System.getScreenWidth() / System.getLayoutWidth();
    local yScale = System.getScreenHeight() / System.getLayoutHeight();
	startX = startX and startX * xScale or startX;
	startY = startY and startY * yScale or startY;
    endX = endX and endX * xScale or endX;
	endY = endY and endY * yScale or endY;
	controlX = controlX and controlX * xScale or controlX;
	controlY = controlY and controlY * yScale or controlY;
	return DrawingBase.addAtomPropCurve(self,sequence,PropTranslate,animType,duration,delay,startX,endX,startY,endY,controlX,controlY)
end 

DrawingBase.addAtomPropCurve = function(self,sequence,propClass,animType,duration,delay,startX,endX,startY,endY,controlX,controlY)
	if not DrawingBase.checkAddProp(self,sequence) then 
		return;
	end

	delay = delay or 0;

	local resCurve = {};
	local anims = {}

    if startX ~= nil then
	    resCurve[1] = new(ResDoubleArrayCurve,duration,startX,endX,controlX);
        anims[1] = new(AnimIndex,animType,0,resCurve[1]:getLength()-1,duration,resCurve[1],delay);
    end

    if startY ~= nil then
	    resCurve[2] = new(ResDoubleArrayCurve,duration,startY,endY,controlY);
        anims[2] = new(AnimIndex,animType,0,resCurve[2]:getLength()-1,duration,resCurve[2],delay);
    end

	local prop = new(propClass,anims[1],anims[2]);
	if DrawingBase.doAddAtomPropEase(self,prop,sequence,anims[1],anims[2],resCurve[1],resCurve[2]) then
		return anims[1],anims[2];
	end
end

--[Comment]
--根据缓动类型创建对应的动画
--animType      动画类型 取值范围kAnimNormal,kAnimRepeat,kAnimLoop
--EaseType      加速度类型
--duration      时长
--delay         延迟
--startValue    开始值
--endValue      结束值
--period        Elastic控制参数 只有EaseType= {ElasticIn,ElasticOut,ElasticInOut}时,才可设置此参数.
DrawingBase.createAtomAnimEase = function(self, animType, EaseType, duration, delay, startValue, endValue, period)
	local resEase,anim;
	if startValue and endValue then
        if EaseType ~= nil and EaseTypeMap[EaseType] ~= nil then
		    resEase = new(EaseTypeMap[EaseType],duration,startValue,endValue, period);
            anim = new(AnimIndex,animType,0,resEase:getLength()-1,duration,resEase,delay);
        end
		return resEase,anim; 
	end 
end 

DrawingBase.addAtomPropEase = function(self,sequence,propClass,center,x,y,animType,EaseType,duration,delay,...)
	if not DrawingBase.checkAddProp(self,sequence) then 
		return;
	end

	delay = delay or 0;

	local nAnimArgs = select("#",...);
	local nAnims = math.floor(nAnimArgs/3);

	local anims = {};
	local resEase = {};

	for i=1,nAnims do 
		local startValue,endValue = select(i*2-1,...);
		local period = select(nAnims * 2 + i, ...);
		resEase[i],anims[i] = DrawingBase.createAtomAnimEase(self,animType,EaseType,duration,delay,startValue,endValue, period);
	end

	if nAnims == 1 then
		local prop = new(propClass,anims[1],center,x,y);
		if DrawingBase.doAddAtomPropEase(self,prop,sequence,anims[1],resEase[1]) then
			return anims[1];
		end
	elseif nAnims == 2 then
		local prop = new(propClass,anims[1],anims[2],center,x,y);
		if DrawingBase.doAddAtomPropEase(self,prop,sequence,anims[1],anims[2],resEase[1],resEase[2]) then
			return anims[1],anims[2];
		end
	elseif nAnims == 3 then
		local prop = new(propClass,anims[1],anims[2],anims[3],center,x,y);
		if DrawingBase.doAddAtomPropEase(self,prop,sequence,anims[1],anims[2],anims[3],resEase[1],resEase[2],resEase[3]) then
			return anims[1],anims[2],anims[3];
		end
	elseif nAnims == 4 then
		local prop = new(propClass,anims[1],anims[2],anims[3],anims[4],center,x,y);
		if DrawingBase.doAddAtomPropEase(self,prop,sequence,anims[1],anims[2],anims[3],anims[4],resEase[1],resEase[2],resEase[3],resEase[4]) then
			return anims[1],anims[2],anims[3],anims[4];
		end
	else
		for _,v in pairs(anims) do 
			delete(v);
		end
		for _,v in pairs(resEase) do
			delete(v);
		end 
		error("There is not such a prop that requests more than 4 anims");
	end

end 

DrawingBase.doAddAtomPropEase = function(self,prop,sequence, ...)
	local nums = select("#",...) / 2;
	local anims = {};
	local reses = {};
	for i = 1,nums do 
		local anim = select(i,...);
		table.insert(anims,anim);
		local res = select(nums + i,...);
		table.insert(reses,res);
	end 
	if DrawingBase.addProp(self,prop,sequence) then 
		self.m_props[sequence] = {["prop"] = prop;["anim"] = anims;["res"] = reses};
		return true;
	else
		delete(prop);
		for _,v in pairs(anims) do 
			delete(v);
		end 
		for _,v in pairs(reses) do 
			delete(v);
		end 
		return false;
	end 
end 


end 