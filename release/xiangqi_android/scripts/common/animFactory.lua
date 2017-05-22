require("core/anim");
require("core/prop");

AnimFactory = class();

AnimFactory.createAnimDouble = function(animType, startValue, endValue, duration, delay)
	return AnimFactory.createAnim(AnimDouble, animType, startValue, endValue, duration, delay);
end 

AnimFactory.createAnimInt = function(animType, startValue, endValue, duration, delay)
	return AnimFactory.createAnim(AnimInt, animType, startValue, endValue, duration, delay);
end 

AnimFactory.createAnimIndex = function(animType, startValue, endValue, duration, res, delay)
	return AnimFactory.createAnim(AnimIndex, animType, startValue, endValue, duration, res, delay);
end 

AnimFactory.createTranslate = function(animX, animY)
	return AnimFactory.createProp(PropTranslate, animX, animY);
end 

AnimFactory.createRotate = function(anim, center, x, y)
	return AnimFactory.createProp(PropRotate, anim, center, x, y);
end 

AnimFactory.createScale = function(animX, animY, center, x, y)
	return AnimFactory.createProp(PropScale, animX, animY, center, x, y);
end

AnimFactory.createPropColor = function(animR, animG, animB)
	return AnimFactory.createProp(PropColor, animR, animG, animB);
end 

AnimFactory.createTransparency = function(anim)
	return AnimFactory.createProp(PropTransparency, anim);
end 

AnimFactory.createPropClip = function(animX, animY, animW, animH)
	return AnimFactory.createProp(PropClip, animX, animY, animW, animH);
end 

AnimFactory.createImageIndex = function(anim)
	return AnimFactory.createProp(PropImageIndex, anim);
end

AnimFactory.createTranslateSolid = function(x, y)
	return AnimFactory.createProp(PropTranslateSolid, x, y);
end 

AnimFactory.createRotateSolid = function(angle360, center, x, y)
	return AnimFactory.createProp(PropRotateSolid, angle360, center, x, y);
end

AnimFactory.createScaleSolid = function(scaleX, scaleY, center, x, y)
	return AnimFactory.createProp(PropScaleSolid, scaleX, scaleY, center, x, y);
end 
-----------------------------------------------------------------------------------------------------------
AnimFactory.createAnim = function(classType, animType, startValue, endValue, ...)
	local anim = nil;
	if startValue and endValue then
		anim = new(classType, animType, startValue, endValue, ...);		
	end 
	return anim;
end 

AnimFactory.createProp = function(classType,...)
	local prop = new(classType,...);
	return prop;
end 