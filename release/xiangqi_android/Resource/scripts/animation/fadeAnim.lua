require("core/anim");
require("core/prop");

FadeAnim = {};
FadeAnim.ms = 500;
FadeAnim.drawing = {};

FadeAnim.play = function(drawing,startValue,endValue,time)
	if not drawing then
		return;
	end

	FadeAnim.stopAnim();
	
	if #drawing == 0 then
		if not drawing.m_drawingID then
			return;
		end
		table.insert(FadeAnim.drawing,drawing);
	else
		for _,v in pairs(drawing) do 
			if not v.m_drawingID then
				return;
			end
		end
		FadeAnim.drawing = drawing;
	end

	FadeAnim.startValue = startValue or 0;
	FadeAnim.endValue = endValue or 1;
	FadeAnim.time = time or FadeAnim.ms;

	FadeAnim.animTrans = new(AnimDouble,kAnimNormal,FadeAnim.startValue,FadeAnim.endValue,FadeAnim.time,-1);
	ToolKit.setDebugName(FadeAnim.animTrans , "AnimDouble|FadeAnim.animTrans");
	FadeAnim.propTrans = new(PropTransparency,FadeAnim.animTrans);
	ToolKit.setDebugName(FadeAnim.propTrans , "PropRotate|FadeAnim.propTrans");

	FadeAnim.animTrans:setEvent(FadeAnim,FadeAnim.stopAnim);

	if #FadeAnim.drawing > 0 then
		for _,v in pairs(FadeAnim.drawing) do 
			v:addProp(FadeAnim.propTrans,1);
		end
	end 
end

FadeAnim.removeProp = function(drawing,prop)
	if drawing and prop then
		drawing:removePropByID(prop.m_propID)
	end
end

FadeAnim.stopAnim = function()
	if #FadeAnim.drawing > 0 then
		for _,v in pairs(FadeAnim.drawing) do
			FadeAnim.removeProp(v,FadeAnim.propTrans);
		end
	end

	delete(FadeAnim.propTrans);
	FadeAnim.propTrans = nil;

	delete(FadeAnim.animTrans);
	FadeAnim.animTrans = nil;

	FadeAnim.drawing = {};
	FadeAnim.startValue = nil;
	FadeAnim.endValue = nil;
	FadeAnim.time = nil;
end

FadeAnim.deleteAll = function()
	FadeAnim.stopAnim();
end