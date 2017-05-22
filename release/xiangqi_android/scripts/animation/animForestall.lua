-- file: 'animForestall.lua'
-- desc: 抢先动画


-- begin declare
require("ui/node");

ForestallAnim = {};

ForestallAnim.loaded = false;
ForestallAnim.show_time = 1.5*1000;
ForestallAnim.anim_time = 0.5*1000;

ForestallAnim.mulx_x = 20;
ForestallAnim.mulx_y = 50;
ForestallAnim.forestall_x = -110;
ForestallAnim.forestall_y = 50;

ForestallAnim.mul_num_seq = 1;
ForestallAnim.mulx_num_x = 0;
ForestallAnim.mulx_num_y = 50;

ForestallAnim.play =  function(root,forestall,mul,onlyMul)
    if mul >= 10 then
        ForestallAnim.forestall_x = -120;
        ForestallAnim.mulx_x = 0;
        ForestallAnim.mulx_num_x = -25;
    else
        ForestallAnim.forestall_x = -90;
        ForestallAnim.mulx_x = 40;
        ForestallAnim.mulx_num_x = 15;
    end
	ForestallAnim.load(root);

	ForestallAnim.reset();
	if onlyMul then
		ForestallAnim.forestall:setVisible(false);
	else
		ForestallAnim.forestall:setVisible(true);
		if forestall then
			ForestallAnim.forestall:setFile("animation/forestall_sure.png")
			kEffectPlayer:playEffect(Effects.AUDIO_FORESTALL);
		else
			ForestallAnim.forestall:setFile("animation/forestall_cancel.png");
			kEffectPlayer:playEffect(Effects.AUDIO_UNFORESTALL);
		end
		local w,h = ForestallAnim.forestall:getSize();
		ForestallAnim.forestall:addPropScale(ForestallAnim.mul_num_seq,kAnimNormal,ForestallAnim.anim_time,0,0,1,0,1,kCenterXY,w/2,h/2);
	end

	w,h = ForestallAnim.mul_x:getSize();
	ForestallAnim.mul_x:addPropScale(ForestallAnim.mul_num_seq,kAnimNormal,ForestallAnim.anim_time,0,0,1,0,1,kCenterXY,w/2,h/2);
	local index = 1;
	repeat
		local mul_num = mul%10;
		mul = math.floor(mul/10);
		if ForestallAnim.mul_num_img[index] then  --有值，修改图片
			print_string("ForestallAnim.mul_num_img[index]" .. index);
			ForestallAnim.mul_num_img[index]:setFile(string.format("animation/mul%d.png",mul_num));
		else  --没有申请新的
			print_string("not ForestallAnim.mul_num_img[index]" .. index);
			ForestallAnim.mul_num_img[index]= new(Image,string.format("animation/mul%d.png",mul_num));
			ForestallAnim.m_root:addChild(ForestallAnim.mul_num_img[index]);
		end
		ForestallAnim.mul_num_img[index]:setVisible(false);
		index = index + 1;
	until mul < 1;

	index = index - 1;
	for key = index, 1,-1 do
		value = ForestallAnim.mul_num_img[key];

		if value then
			value:setVisible(true);
			local w,h = value:getSize();
			value:addPropScale(ForestallAnim.mul_num_seq,kAnimNormal,ForestallAnim.anim_time,0,0,1,0,1,kCenterXY,w/2,h/2);
            value:setAlign(kAlignTop);
			value:setPos(ForestallAnim.mulx_num_x,ForestallAnim.mulx_num_y);
			--value:setVisible(true);
			ForestallAnim.mulx_num_x = ForestallAnim.mulx_num_x + w;
		end
	end

	ForestallAnim.m_root:setVisible(true);



	ForestallAnim.stopAnim = new(AnimInt,kAnimNormal,0,1,ForestallAnim.show_time,-1); --多四秒，预防延迟
	ForestallAnim.stopAnim:setDebugName("ForestallAnim.stopAnim");
	ForestallAnim.stopAnim:setEvent(ForestallAnim,ForestallAnim.reset);
end



ForestallAnim.reset = function()

	if ForestallAnim.stopAnim then
		delete(ForestallAnim.stopAnim);
		ForestallAnim.stopAnim = nil;
	end

	for key , value in pairs(ForestallAnim.mul_num_img ) do
		print_string("ForestallAnim.reset key = " .. key);
		value:removeProp(ForestallAnim.mul_num_seq);
		value:setVisible(false);
	end

	ForestallAnim.mulx_num_x = ForestallAnim.mulx_x  + ForestallAnim.mul_x:getSize();

	ForestallAnim.mulx_num_y = ForestallAnim.mulx_y;


	ForestallAnim.forestall:removeProp(ForestallAnim.mul_num_seq);
	ForestallAnim.mul_x:removeProp(ForestallAnim.mul_num_seq);

	ForestallAnim.m_root:setVisible(false);

end

ForestallAnim.load = function(root)

	if ForestallAnim.loaded then
		print_string("ForestallAnim.loaded");
        if ForestallAnim.forestall then
            ForestallAnim.forestall:setPos(ForestallAnim.forestall_x,ForestallAnim.forestall_y);
        end
        if ForestallAnim.mul_x then
            ForestallAnim.mul_x:setPos(ForestallAnim.mulx_x,ForestallAnim.mulx_y);
        end
		return
	end

    ForestallAnim.m_root = new(Node);
    ForestallAnim.m_root:setSize(480,800);
	--ForestallAnim.m_root:setSize(AnimBroadcast.bgImgW,AnimBroadcast.bgImgH);
    ForestallAnim.m_root:setAlign(kAlignCenter);
    ForestallAnim.m_root:setLevel(20);
	ForestallAnim.m_root:addToRoot();

	ForestallAnim.mul_num_img = {};

	ForestallAnim.forestall = new(Image,"animation/forestall_sure.png");
    ForestallAnim.forestall:setAlign(kAlignTop)
    ForestallAnim.forestall:setPos(ForestallAnim.forestall_x,ForestallAnim.forestall_y);
	ForestallAnim.m_root:addChild(ForestallAnim.forestall);

	ForestallAnim.mul_x = new(Image,"animation/mulx.png");
    ForestallAnim.mul_x:setAlign(kAlignTop)
	ForestallAnim.mul_x:setPos(ForestallAnim.mulx_x,ForestallAnim.mulx_y);
	ForestallAnim.m_root:addChild(ForestallAnim.mul_x);

	ForestallAnim.m_root:setVisible(false);

	ForestallAnim.loaded = true; 
end

--退出房间时调用
ForestallAnim.deleteAll = function()
    if ForestallAnim.loaded then 
	    ForestallAnim.loaded = false;
	    ForestallAnim.reset();
	end


end
