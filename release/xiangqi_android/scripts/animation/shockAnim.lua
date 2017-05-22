
require("core/anim");
require("core/prop");

ShockAnim = {};
ShockAnim.drawing = {};

ShockAnim.play = function(drawing,time,num,rd)
	if not drawing then
		return;
	end

	ShockAnim.stopAnim();
	if #drawing == 0 then
		if not drawing.m_drawingID then
			return;
		end
		table.insert(ShockAnim.drawing,drawing);
	else
		for _,v in pairs(drawing) do 
			if not v.m_drawingID then
				return;
			end
		end
		ShockAnim.drawing = drawing;
	end

	local x,y = ShockAnim.drawing[1]:getPos();
	local w,h = ShockAnim.drawing[1]:getSize();
	ShockAnim.propShake,ShockAnim.animShake = ShockAnim.createBomb(time,num,rd);
	if #ShockAnim.drawing > 0 then
		for _,v in pairs(ShockAnim.drawing) do 
			v:addProp(ShockAnim.propShake,0);
		end
	end
end

ShockAnim.removeProp = function(drawing,prop)
	if drawing and prop then
		drawing:removePropByID(prop.m_propID)
	end
end

ShockAnim.stopAnim = function()
	if #ShockAnim.drawing > 0 then
		for _,v in pairs(ShockAnim.drawing) do
			ShockAnim.removeProp(v,ShockAnim.propShake);
		end
	end

	delete(ShockAnim.propShake);
	ShockAnim.propShake = nil;

    delete(ShockAnim.animShake);
    ShockAnim.animShake = nil;

	delete(ShockAnim.animShake);
	ShockAnim.animShake = nil;

	ShockAnim.drawing = {};
end

ShockAnim.deleteAll = function()
	ShockAnim.stopAnim();
end


-- --!!!you must delete all of the return value by yourself
-- --!!!所有返回值都必须手动删除（delete）
-- ShockAnim.createBomb = function()
-- 	--check params
-- 	local standframe =  0;
-- 	local ms = 400;
-- 	local defaultframe =  60;

-- 	--create array
-- 	local arrayX = {};
-- 	local len = math.floor(defaultframe*ms/1000);

-- 	local ran = {6,-4,2,-8,4,-6,8,-2};
-- 	for i = standframe+1 , standframe+len*10 do
-- 		arrayX[i] = ran[math.random(1,#ran)];
-- 	end

-- 	arrayX[#arrayX+1] = 0;

-- 	--create animations
-- 	local resX = new(ResDoubleArray, arrayX);
-- 	animTranslatex = new(AnimIndex , kAnimNormal, 1 , #arrayX-1, ms , resX, 0);
--     propTranslate = new(PropTranslate , animTranslatex , nil);

-- 	return propTranslate;
-- end

--!!!you must delete all of the return value by yourself
--!!!所有返回值都必须手动删除（delete）
ShockAnim.createBomb = function(time,num,rd)
	--check params
	local ms = time or 400;

	--create array
	local arrayX = {};
	local len = num or 15;

	local ran = rd or {6,-4,2,-8,4,-6,8,-2};
	for i = 1 , len*10 do
		arrayX[i] = ran[math.random(1,#ran)];
	end

	arrayX[#arrayX+1] = 0;

	--create animations
	local resX = new(ResDoubleArray, arrayX);
	animTranslatex = new(AnimIndex , kAnimNormal, 1 , #arrayX-1, ms , resX, 0);
    animTranslatex:setDebugName("ShockAnim.animTranslatex");
    propTranslate = new(PropTranslate , animTranslatex , nil);

	return propTranslate,animTranslatex;
end