require("core/res")
require("libEffect/easing")
local easing = require('libEffect.easing')

--------------------------------------ResDoubleRase---------------------------------------------

---------------------------------------ResDoubleArraySin-----------------------------------------

--SinIn
ResDoubleArraySinIn = class(ResDoubleArray, false);

ResDoubleArraySinIn.ctor = function(self,duration,startV,endV)
    endV = endV - startV;
    local arr = easing.getEaseArray("easeInSine", duration, startV, endV);
    self.m_arrayLength = #arr;
    super(self, arr);
end

ResDoubleArraySinIn.dtor = function(self)
end

ResDoubleArraySinIn.getLength = function(self)
	return self.m_arrayLength;
end 

--SinOut
ResDoubleArraySinOut = class(ResDoubleArray, false);

ResDoubleArraySinOut.ctor = function(self,duration,startV,endV)
    endV = endV - startV;
	local arr = easing.getEaseArray("easeOutSine", duration, startV, endV);
    self.m_arrayLength = #arr;
    super(self, arr);
end 

ResDoubleArraySinOut.dtor = function(self)
end 

ResDoubleArraySinOut.getLength = function(self)
	return self.m_arrayLength;
end 

--SinInOut
ResDoubleArraySinInOut = class(ResDoubleArray, false);

ResDoubleArraySinInOut.ctor = function(self,duration,startV,endV)
    endV = endV - startV;
	local arr = easing.getEaseArray("easeInOutSine", duration, startV, endV);
    self.m_arrayLength = #arr;
    super(self, arr);
end 

ResDoubleArraySinInOut.dtor = function(self)
end 

ResDoubleArraySinInOut.getLength = function(self)
	return self.m_arrayLength;
end

---------------------------------------ResDoubleArrayExp-----------------------------------------
--ExpIn
ResDoubleArrayExpIn = class(ResDoubleArray, false);

ResDoubleArrayExpIn.ctor = function(self,duration,startV,endV)
	endV = endV - startV;
    local arr = easing.getEaseArray("easeInExpo", duration, startV, endV);
    self.m_arrayLength = #arr;
    super(self, arr);
end 

ResDoubleArrayExpIn.dtor = function(self)
end 

ResDoubleArrayExpIn.getLength = function(self)
	return self.m_arrayLength;
end 

--ExpOut
ResDoubleArrayExpOut = class(ResDoubleArray, false);

ResDoubleArrayExpOut.ctor = function(self,duration,startV,endV)
	endV = endV - startV;
    local arr = easing.getEaseArray("easeOutExpo", duration, startV, endV);
    self.m_arrayLength = #arr;
    super(self, arr);
end 

ResDoubleArrayExpOut.dtor = function(self)
end 

ResDoubleArrayExpOut.getLength = function(self)
	return self.m_arrayLength;
end 

--ExpInOut
ResDoubleArrayExpInOut = class(ResDoubleArray, false);

ResDoubleArrayExpInOut.ctor = function(self,duration,startV,endV)
	endV = endV - startV;
    local arr = easing.getEaseArray("easeInOutExpo", duration, startV, endV);
    self.m_arrayLength = #arr;
    super(self, arr);
end 

ResDoubleArrayExpInOut.dtor = function(self)
end 

ResDoubleArrayExpInOut.getLength = function(self)
	return self.m_arrayLength;
end 



---------------------------------------ResDoubleArrayElastic---------------------------------------
--ElasticIn
ResDoubleArrayElasticIn = class(ResDoubleArray, false);

ResDoubleArrayElasticIn.ctor = function(self,duration,startV,endV,period)
	endV = endV - startV;
    if period == nil or type(period) ~= "number" then
        period = 0.3;
    end
    
    local arr = easing.getEaseArray("easeInElastic", duration, startV, endV, period);
    self.m_arrayLength = #arr;
    super(self, arr);
end 

ResDoubleArrayElasticIn.dtor = function(self)
end 

ResDoubleArrayElasticIn.getLength = function(self)
	return self.m_arrayLength;
end 

--ElasticOut
ResDoubleArrayElasticOut = class(ResDoubleArray, false);

ResDoubleArrayElasticOut.ctor = function(self,duration,startV,endV,period)
	endV = endV - startV;
    if period == nil or type(period) ~= "number" then
        period = 0.3;
    end
    local arr = easing.getEaseArray("easeOutElastic", duration, startV, endV, period);
    self.m_arrayLength = #arr;
    super(self, arr);
end

ResDoubleArrayElasticOut.dtor = function(self)
end 

ResDoubleArrayElasticOut.getLength = function(self)
	return self.m_arrayLength;
end 

--ElasticInOut
ResDoubleArrayElasticInOut = class(ResDoubleArray, false);

ResDoubleArrayElasticInOut.ctor = function(self,duration,startV,endV,period)
	endV = endV - startV;
    if period == nil or type(period) ~= "number" then
        period = 0.3;
    end
    local arr = easing.getEaseArray("easeInOutElastic", duration, startV, endV, period);
    self.m_arrayLength = #arr;
    super(self, arr);
end 

ResDoubleArrayElasticInOut.dtor = function(self)
end 

ResDoubleArrayElasticInOut.getLength = function(self)
	return self.m_arrayLength;
end 


-----------------------------------------ResDoubleArrayBounce-----------------------------
--BounceIn
ResDoubleArrayBounceIn = class(ResDoubleArray, false)

ResDoubleArrayBounceIn.ctor = function(self,duration,startV,endV)
	endV = endV - startV;
    local arr = easing.getEaseArray("easeInBounce", duration, startV, endV);
    self.m_arrayLength = #arr;
    super(self, arr);
end 

ResDoubleArrayBounceIn.dtor = function(self)
end 

ResDoubleArrayBounceIn.getLength = function(self)
	return self.m_arrayLength;
end 

--BounceOut
ResDoubleArrayBounceOut = class(ResDoubleArray, false)

ResDoubleArrayBounceOut.ctor = function(self,duration,startV,endV)
	endV = endV - startV;
    local arr = easing.getEaseArray("easeOutBounce", duration, startV, endV);
    self.m_arrayLength = #arr;
    super(self, arr);
end

ResDoubleArrayBounceOut.dtor = function(self)
end 

ResDoubleArrayBounceOut.getLength = function(self)
	return self.m_arrayLength;
end


--BounceInOut
ResDoubleArrayBounceInOut = class(ResDoubleArray, false)

ResDoubleArrayBounceInOut.ctor = function(self,duration,startV,endV)
	endV = endV - startV;
    local arr = easing.getEaseArray("easeInOutBounce", duration, startV, endV);
    self.m_arrayLength = #arr;
    super(self, arr);
end 

ResDoubleArrayBounceInOut.dtor = function(self)
end

ResDoubleArrayBounceInOut.getLength = function(self)
	return self.m_arrayLength;
end 

------------------------------------------ResDoubleArrayBack------------------------------------
--BackIn
ResDoubleArrayBackIn = class(ResDoubleArray, false)

ResDoubleArrayBackIn.ctor = function(self,duration,startV,endV)
	endV = endV - startV;
    local arr = easing.getEaseArray("easeInBack", duration, startV, endV);
    self.m_arrayLength = #arr;
    super(self, arr);
end

ResDoubleArrayBackIn.dtor = function(self)
end 

ResDoubleArrayBackIn.getLength = function(self)
	return self.m_arrayLength;
end 

--BackOut
ResDoubleArrayBackOut = class(ResDoubleArray, false)

ResDoubleArrayBackOut.ctor = function(self,duration,startV,endV)
	endV = endV - startV;
    local arr = easing.getEaseArray("easeOutBack", duration, startV, endV);
    self.m_arrayLength = #arr;
    super(self, arr);
end

ResDoubleArrayBackOut.dtor = function(self)
end 

ResDoubleArrayBackOut.getLength = function(self)
	return self.m_arrayLength;
end 

--backInOut
ResDoubleArrayBackInOut = class(ResDoubleArray, false)

ResDoubleArrayBackInOut.ctor = function(self,duration,startV,endV)
	endV = endV - startV;
    local arr = easing.getEaseArray("easeInOutBack", duration, startV, endV);
    self.m_arrayLength = #arr;
    super(self, arr);
end

ResDoubleArrayBackInOut.dtor = function(self)
end 

ResDoubleArrayBackInOut.getLength = function(self)
	return self.m_arrayLength;
end 

---------------------------------------ResDoubleArrayQuad-----------------------------------------

--QuadIn
ResDoubleArrayQuadIn = class(ResDoubleArray, false);

ResDoubleArrayQuadIn.ctor = function(self,duration,startV,endV)
    endV = endV - startV;
    local arr = easing.getEaseArray("easeInQuad", duration, startV, endV);
    self.m_arrayLength = #arr;
    super(self, arr);
end

ResDoubleArrayQuadIn.dtor = function(self)
end

ResDoubleArrayQuadIn.getLength = function(self)
	return self.m_arrayLength;
end 

--QuadOut
ResDoubleArrayQuadOut = class(ResDoubleArray, false);

ResDoubleArrayQuadOut.ctor = function(self,duration,startV,endV)
    endV = endV - startV;
	local arr = easing.getEaseArray("easeOutQuad", duration, startV, endV);
    self.m_arrayLength = #arr;
    super(self, arr);
end 

ResDoubleArrayQuadOut.dtor = function(self)
end 

ResDoubleArrayQuadOut.getLength = function(self)
	return self.m_arrayLength;
end 

--QuadInOut
ResDoubleArrayQuadInOut = class(ResDoubleArray, false);

ResDoubleArrayQuadInOut.ctor = function(self,duration,startV,endV)
    endV = endV - startV;
	local arr = easing.getEaseArray("easeInOutQuad", duration, startV, endV);
    self.m_arrayLength = #arr;
    super(self, arr);
end

ResDoubleArrayQuadInOut.dtor = function(self)
end 

ResDoubleArrayQuadInOut.getLength = function(self)
	return self.m_arrayLength;
end

---------------------------------------ResDoubleArrayCubic-----------------------------------------

--CubicIn
ResDoubleArrayCubicIn = class(ResDoubleArray, false);

ResDoubleArrayCubicIn.ctor = function(self,duration,startV,endV)
    endV = endV - startV;
    local arr = easing.getEaseArray("easeInCubic", duration, startV, endV);
    self.m_arrayLength = #arr;
    super(self, arr);
end

ResDoubleArrayCubicIn.dtor = function(self)
end

ResDoubleArrayCubicIn.getLength = function(self)
	return self.m_arrayLength;
end 

--CubicOut
ResDoubleArrayCubicOut = class(ResDoubleArray, false);

ResDoubleArrayCubicOut.ctor = function(self,duration,startV,endV)
    endV = endV - startV;
	local arr = easing.getEaseArray("easeOutCubic", duration, startV, endV);
    self.m_arrayLength = #arr;
    super(self, arr);
end 

ResDoubleArrayCubicOut.dtor = function(self)
end 

ResDoubleArrayCubicOut.getLength = function(self)
	return self.m_arrayLength;
end 

--CubicInOut
ResDoubleArrayCubicInOut = class(ResDoubleArray, false);

ResDoubleArrayCubicInOut.ctor = function(self,duration,startV,endV)
    endV = endV - startV;
	local arr = easing.getEaseArray("easeInOutCubic", duration, startV, endV);
    self.m_arrayLength = #arr;
    super(self, arr);
end

ResDoubleArrayCubicInOut.dtor = function(self)
end 

ResDoubleArrayCubicInOut.getLength = function(self)
	return self.m_arrayLength;
end
---------------------------------------ResDoubleArrayQuart-----------------------------------------

--QuartIn
ResDoubleArrayQuartIn = class(ResDoubleArray, false);

ResDoubleArrayQuartIn.ctor = function(self,duration,startV,endV)
    endV = endV - startV;
    local arr = easing.getEaseArray("easeInQuart", duration, startV, endV);
    self.m_arrayLength = #arr;
    super(self, arr);
end

ResDoubleArrayQuartIn.dtor = function(self)
end

ResDoubleArrayQuartIn.getLength = function(self)
	return self.m_arrayLength;
end

--QuartOut
ResDoubleArrayQuartOut = class(ResDoubleArray, false);

ResDoubleArrayQuartOut.ctor = function(self,duration,startV,endV)
    endV = endV - startV;
	local arr = easing.getEaseArray("easeOutQuart", duration, startV, endV);
    self.m_arrayLength = #arr;
    super(self, arr);
end

ResDoubleArrayQuartOut.dtor = function(self)
end 

ResDoubleArrayQuartOut.getLength = function(self)
	return self.m_arrayLength;
end 

--QuartInOut
ResDoubleArrayQuartInOut = class(ResDoubleArray, false);

ResDoubleArrayQuartInOut.ctor = function(self,duration,startV,endV)
    endV = endV - startV;
	local arr = easing.getEaseArray("easeInOutQuart", duration, startV, endV);
    self.m_arrayLength = #arr;
    super(self, arr);
end 

ResDoubleArrayQuartInOut.dtor = function(self)
end 

ResDoubleArrayQuartInOut.getLength = function(self)
	return self.m_arrayLength;
end 

---------------------------------------ResDoubleArrayQuint-----------------------------------------

--QuintIn
ResDoubleArrayQuintIn = class(ResDoubleArray, false);

ResDoubleArrayQuintIn.ctor = function(self,duration,startV,endV)
    endV = endV - startV;
    local arr = easing.getEaseArray("easeInQuint", duration, startV, endV);
    self.m_arrayLength = #arr;
    super(self, arr);
end

ResDoubleArrayQuintIn.dtor = function(self)
end

ResDoubleArrayQuintIn.getLength = function(self)
	return self.m_arrayLength;
end 

--QuintOut
ResDoubleArrayQuintOut = class(ResDoubleArray, false);

ResDoubleArrayQuintOut.ctor = function(self,duration,startV,endV)
    endV = endV - startV;
	local arr = easing.getEaseArray("easeOutQuint", duration, startV, endV);
    self.m_arrayLength = #arr;
    super(self, arr);
end 

ResDoubleArrayQuintOut.dtor = function(self)
end 

ResDoubleArrayQuintOut.getLength = function(self)
	return self.m_arrayLength;
end 

--QuintInOut
ResDoubleArrayQuintInOut = class(ResDoubleArray, false);

ResDoubleArrayQuintInOut.ctor = function(self,duration,startV,endV)
    endV = endV - startV;
	local arr = easing.getEaseArray("easeInOutQuint", duration, startV, endV);
    self.m_arrayLength = #arr;
    super(self, arr);
end

ResDoubleArrayQuintInOut.dtor = function(self)
end 

ResDoubleArrayQuintInOut.getLength = function(self)
	return self.m_arrayLength;
end 

---------------------------------------ResDoubleArrayCirc-----------------------------------------

--CircIn
ResDoubleArrayCircIn = class(ResDoubleArray, false);

ResDoubleArrayCircIn.ctor = function(self,duration,startV,endV)
    endV = endV - startV;
    local arr = easing.getEaseArray("easeInCirc", duration, startV, endV);
    self.m_arrayLength = #arr;
    super(self, arr);
end

ResDoubleArrayCircIn.dtor = function(self)
end

ResDoubleArrayCircIn.getLength = function(self)
	return self.m_arrayLength;
end

--CircOut
ResDoubleArrayCircOut = class(ResDoubleArray, false);

ResDoubleArrayCircOut.ctor = function(self,duration,startV,endV)
    endV = endV - startV;
	local arr = easing.getEaseArray("easeOutCirc", duration, startV, endV);
    self.m_arrayLength = #arr;
    super(self, arr);
end 

ResDoubleArrayCircOut.dtor = function(self)
end 

ResDoubleArrayCircOut.getLength = function(self)
	return self.m_arrayLength;
end 

--CircInOut
ResDoubleArrayCircInOut = class(ResDoubleArray, false);

ResDoubleArrayCircInOut.ctor = function(self,duration,startV,endV)
    endV = endV - startV;
	local arr = easing.getEaseArray("easeInOutCirc", duration, startV, endV);
    self.m_arrayLength = #arr;
    super(self, arr);
end

ResDoubleArrayCircInOut.dtor = function(self)
end

ResDoubleArrayCircInOut.getLength = function(self)
	return self.m_arrayLength;
end 

------------------------------------------ResDoubleExtra----------------------------------------

ResDoubleArrayCurve = class(ResBase)

ResDoubleArrayCurve.ctor = function(self,duration,startV,endV,control)
	self.m_arrayLength = math.floor(60 * duration / 1000);
	res_create_double_array_curve(0,self.m_resID,self.m_arrayLength,startV,endV,control);
end 

ResDoubleArrayCurve.getLength = function(self)
	return self.m_arrayLength;
end 

ResDoubleArrayCurve.dtor = function(self)
	res_delete(self.m_resID);
end

ResDoubleArrayEllipseX = class(ResBase);

ResDoubleArrayEllipseX.ctor = function(self,duration,centerX,axisX,startAngle,endAngle)
	self.m_arrayLength = math.floor(60 * duration / 1000);
	res_create_double_array_ellipseX(0,self.m_resID,self.m_arrayLength,centerX,axisX,startAngle,endAngle);
end 

ResDoubleArrayEllipseX.getLength = function(self)
	return self.m_arrayLength;
end 

ResDoubleArrayEllipseX.dtor = function(self)
	res_delete(self.m_resID);
end 

ResDoubleArrayEllipseY = class(ResBase);

ResDoubleArrayEllipseY.ctor = function(self,duration,centerY,axisY,startAngle,endAngle)
	self.m_arrayLength = math.floor(60 * duration / 1000);
	res_create_double_array_ellipseY(0,self.m_resID,self.m_arrayLength,centerY,axisY,startAngle,endAngle);
end 

ResDoubleArrayEllipseY.getLength = function(self)
	return self.m_arrayLength;
end 

ResDoubleArrayEllipseY.dtor = function(self)
	res_delete(self.m_resID);
end 

ResDoubleArrayJumpX = class(ResBase);

ResDoubleArrayJumpX.ctor = function(self,duration,startX,endX,times,height)
	self.m_arrayLength = math.floor(60 * duration / 1000);
	res_create_double_array_jumpX(0,self.m_resID,self.m_arrayLength,startX,endX, times, height);
end 

ResDoubleArrayJumpX.getLength = function(self)
	return self.m_arrayLength;
end 

ResDoubleArrayJumpX.dtor = function(self)
	res_delete(self.m_resID);
end 

ResDoubleArrayJumpY = class(ResBase);

ResDoubleArrayJumpY.ctor = function(self,duration,startY,endY,times,height)
	self.m_arrayLength = math.floor(60 * duration / 1000);
	res_create_double_array_jumpY(0,self.m_resID,self.m_arrayLength,startY,endY,times,height);
end 

ResDoubleArrayJumpY.getLength = function(self)
	return self.m_arrayLength;
end 

ResDoubleArrayJumpY.dtor = function(self)
	res_delete(self.m_resID);
end 

--------------------------EaseType索引---------------------
EaseTypeMap = {};
EaseTypeMap["Nil"]              = nil;

EaseTypeMap["SinIn"]            = ResDoubleArraySinIn;
EaseTypeMap["SinOut"]           = ResDoubleArraySinOut;
EaseTypeMap["SinInOut"]         = ResDoubleArraySinInOut;
EaseTypeMap["ExpIn"]            = ResDoubleArrayExpIn;
EaseTypeMap["ExpOut"]           = ResDoubleArrayExpOut;
EaseTypeMap["ExpInOut"]         = ResDoubleArrayExpInOut;
EaseTypeMap["ElasticIn"]        = ResDoubleArrayElasticIn;
EaseTypeMap["ElasticOut"]       = ResDoubleArrayElasticOut;
EaseTypeMap["ElasticInOut"]     = ResDoubleArrayElasticInOut;
EaseTypeMap["BounceIn"]         = ResDoubleArrayBounceIn;
EaseTypeMap["BounceOut"]        = ResDoubleArrayBounceOut;
EaseTypeMap["BounceInOut"]      = ResDoubleArrayBounceInOut;
EaseTypeMap["BackIn"]           = ResDoubleArrayBackIn;
EaseTypeMap["BackOut"]          = ResDoubleArrayBackOut;
EaseTypeMap["BackInOut"]        = ResDoubleArrayBackInOut;
EaseTypeMap["CircIn"]           = ResDoubleArrayCircIn;
EaseTypeMap["CircOut"]          = ResDoubleArrayCircOut;
EaseTypeMap["CircInOut"]        = ResDoubleArrayCircInOut;
EaseTypeMap["CubicIn"]          = ResDoubleArrayCubicIn;
EaseTypeMap["CubicOut"]         = ResDoubleArrayCubicOut;
EaseTypeMap["CubicInOut"]       = ResDoubleArrayCubicInOut;
EaseTypeMap["QuadIn"]           = ResDoubleArrayQuadIn;
EaseTypeMap["QuadOut"]          = ResDoubleArrayQuadOut;
EaseTypeMap["QuadInOut"]        = ResDoubleArrayQuadInOut;
EaseTypeMap["QuartIn"]          = ResDoubleArrayQuartIn;
EaseTypeMap["QuartOut"]         = ResDoubleArrayQuartOut;
EaseTypeMap["QuartInOut"]       = ResDoubleArrayQuartInOut;
EaseTypeMap["QuintIn"]          = ResDoubleArrayQuintIn;
EaseTypeMap["QuintOut"]         = ResDoubleArrayQuintOut;
EaseTypeMap["QuintInOut"]       = ResDoubleArrayQuintInOut;