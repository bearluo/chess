

ScrollAnim = {};





ScrollAnim.SCROLL_SEQ = 1;  --画卷滚动属性seq

ScrollAnim.scroll_time = 150; --画卷展开收起时间

ScrollAnim.SCROLL_SEQ = 0;

ScrollAnim.MODE_DOWN = 2;
ScrollAnim.MODE_UP = 1;



--弹开
ScrollAnim.play = function(img,mode,endVisible, obj, fn)

	if not img then
		print_string("ScrollAnim.play but not img");
		return
	end

	ScrollAnim.clearAndReset();

	ScrollAnim.animImg = img;
    ScrollAnim.animImg:setVisible(true); --播放的动画一定要显示出来
    ScrollAnim.endVisible = endVisible == nil or endVisible;
	ScrollAnim.posX ,ScrollAnim.posY = img:getPos();
	ScrollAnim.width,ScrollAnim.height = img:getSize();
    ScrollAnim.obj = obj;
    ScrollAnim.fn = fn;


	if	not mode then
		print_string("ScrollAnim.play not mode");
		return
	elseif mode == ScrollAnim.MODE_UP then
		local posY = ScrollAnim.posY - ScrollAnim.height
		local diff = (ScrollAnim.posY - posY) * System.getLayoutScale(); --起点减终点
		ScrollAnim.animX = nil
		ScrollAnim.animY = new(AnimInt,kAnimNormal,0,-diff,ScrollAnim.scroll_time,-1); 
		ScrollAnim.animY:setDebugName("ScrollAnim.animY");
		ScrollAnim.animY:setEvent(ScrollAnim, function() 
            ScrollAnim.animImg:setPos(ScrollAnim.posX ,posY);
            ScrollAnim.endScroll();
        end)
		ScrollAnim.animImg:setVisible(true);
	elseif mode == ScrollAnim.MODE_DOWN then
		local posY = ScrollAnim.posY + ScrollAnim.height
		local diff = (posY - ScrollAnim.posY) * System.getLayoutScale(); --终点减起点
		ScrollAnim.animX = nil
		ScrollAnim.animY = new(AnimInt,kAnimNormal,0,diff,ScrollAnim.scroll_time,-1); 
		ScrollAnim.animY:setDebugName("ScrollAnim.animY");
		ScrollAnim.animY:setEvent(ScrollAnim,function() 
            ScrollAnim.animImg:setPos(ScrollAnim.posX ,posY);
            ScrollAnim.endScroll();
        end)
	end

	ScrollAnim.animImg:setVisible(true);
	ScrollAnim.propScroll = new(PropTranslate,ScrollAnim.animX,ScrollAnim.animY);
	ScrollAnim.animImg:addProp(ScrollAnim.propScroll,ScrollAnim.SCROLL_SEQ);



end



ScrollAnim.endScroll = function()
	ScrollAnim.clearAndReset();
    if ScrollAnim.obj and ScrollAnim.fn then
        ScrollAnim.fn(ScrollAnim.obj);
    end;
end


ScrollAnim.clearAndReset = function()
	
	if ScrollAnim.propScroll then
		ScrollAnim.animImg:removeProp(ScrollAnim.SCROLL_SEQ);
        ScrollAnim.animImg:setVisible(ScrollAnim.endVisible);--动画播完后是否还显示
		delete(ScrollAnim.propScroll);
		ScrollAnim.propScroll = nil;
	end

	if ScrollAnim.animX  then
		delete(ScrollAnim.animX);
		ScrollAnim.animX = nil;
	end


	if ScrollAnim.animY then
		delete(ScrollAnim.animY);
		ScrollAnim.animY = nil;
	end

end


ScrollAnim.deleteAll = function()
	ScrollAnim.stopAnim();
end

