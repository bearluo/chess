require("core/anim");
require("core/prop");
require("util/ToolKit");

HeadTurnAnim = {};
HeadTurnAnim.ms = 600;
HeadTurnAnim.drawing = {};

HeadTurnAnim.play = function(drawing)
	if not drawing then
		return;
	end

	HeadTurnAnim.stopAnim();
	
	if #drawing == 0 then
		if not drawing.m_drawingID then
			return;
		end
		table.insert(HeadTurnAnim.drawing,drawing);
	else
		for _,v in pairs(drawing) do 
			if not v.m_drawingID then
				return;
			end
		end
		HeadTurnAnim.drawing = drawing;
	end

	HeadTurnAnim.animScale = new(AnimDouble,kAnimNormal,0,1,HeadTurnAnim.ms,-1);
	ToolKit.setDebugName(HeadTurnAnim.animScale , "AnimDouble|HeadTurnAnim.animScale");
	HeadTurnAnim.propScale = new(PropScale,HeadTurnAnim.animScale,HeadTurnAnim.animScale,kCenterDrawing);
	ToolKit.setDebugName(HeadTurnAnim.propScale , "PropScale|HeadTurnAnim.propScale");

	HeadTurnAnim.animRotate = new(AnimDouble,kAnimNormal,0,360,HeadTurnAnim.ms,-1);
	ToolKit.setDebugName(HeadTurnAnim.animRotate , "AnimDouble|HeadTurnAnim.animRotate");
	HeadTurnAnim.propRotate = new(PropRotate,HeadTurnAnim.animRotate,kCenterDrawing);
	ToolKit.setDebugName(HeadTurnAnim.propRotate , "PropRotate|HeadTurnAnim.propRotate");

	if #HeadTurnAnim.drawing > 0 then
		for _,v in pairs(HeadTurnAnim.drawing) do 
			v:addProp(HeadTurnAnim.propScale,0);
			v:addProp(HeadTurnAnim.propRotate,1);
		end
	end
    
	HeadTurnAnim.animRotate:setEvent(HeadTurnAnim,HeadTurnAnim.stopAnim);
end

HeadTurnAnim.removeProp = function(drawing,prop)
	if drawing and prop then
		drawing:removePropByID(prop.m_propID)
	end
end

HeadTurnAnim.stopAnim = function()
	if #HeadTurnAnim.drawing > 0 then
		for _,v in pairs(HeadTurnAnim.drawing) do
			HeadTurnAnim.removeProp(v,HeadTurnAnim.propScale);
			HeadTurnAnim.removeProp(v,HeadTurnAnim.propRotate);
		end
	end

	delete(HeadTurnAnim.propScale);
	HeadTurnAnim.propScale = nil;

	delete(HeadTurnAnim.animScale);
	HeadTurnAnim.animScale = nil;

	delete(HeadTurnAnim.propRotate);
	HeadTurnAnim.propRotate = nil;
	
	delete(HeadTurnAnim.animRotate);
	HeadTurnAnim.animRotate = nil;

	HeadTurnAnim.drawing = {};
end

HeadTurnAnim.deleteAll = function()
	HeadTurnAnim.stopAnim();
end