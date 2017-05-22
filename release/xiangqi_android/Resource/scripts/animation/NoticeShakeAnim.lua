require("core/anim");
require("core/prop");

NoticeShake = {};
NoticeShake.ms = 1800;
NoticeShake.drawing = {};

NoticeShake.play = function(drawing)
	if not drawing then
		return;
	end

	NoticeShake.stopAnim();
	if #drawing == 0 then
		if not drawing.m_drawingID then
			return;
		end
		table.insert(NoticeShake.drawing,drawing);
	else
		for _,v in pairs(drawing) do 
			if not v.m_drawingID then
				return;
			end
		end
		NoticeShake.drawing = drawing;
	end

	local x,y = NoticeShake.drawing[1]:getPos();
	local w,h = NoticeShake.drawing[1]:getSize();
	NoticeShake.animShake = new(AnimDouble,kAnimLoop,6,-6,NoticeShake.ms,-1);
	ToolKit.setDebugName(NoticeShake.animShake , "AnimDouble|NoticeShake.animShake");
	NoticeShake.propShake = new(PropRotate,NoticeShake.animShake,kCenterXY,w/2,y);
	ToolKit.setDebugName(NoticeShake.propShake , "PropRotate|NoticeShake.propShake");

	if #NoticeShake.drawing > 0 then
		for _,v in pairs(NoticeShake.drawing) do 
			v:addProp(NoticeShake.propShake,0);
		end
	end
end

NoticeShake.removeProp = function(drawing,prop)
	if drawing and prop then
		drawing:removePropByID(prop.m_propID)
	end
end

NoticeShake.stopAnim = function()
	if #NoticeShake.drawing > 0 then
		for _,v in pairs(NoticeShake.drawing) do
			NoticeShake.removeProp(v,NoticeShake.propShake);
		end
	end

	delete(NoticeShake.propShake);
	NoticeShake.propShake = nil;

	delete(NoticeShake.animShake);
	NoticeShake.animShake = nil;

	NoticeShake.drawing = {};
end

NoticeShake.deleteAll = function()
	NoticeShake.stopAnim();
end