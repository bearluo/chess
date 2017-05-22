require("core/anim");
require("core/prop");

CoverGoodsAnim = {};
CoverGoodsAnim.ms = 500;
CoverGoodsAnim.drawing = {};
CoverGoodsAnim.m_imgs = {};

CoverGoodsAnim.play = function(drawing)
	if not drawing then
		return;
	end

	CoverGoodsAnim.drawing = drawing;

	CoverGoodsAnim.removeAnim();
    --CoverGoodsAnim.drawing:setFile(CoverGoodsAnim.animRes[CoverGoodsAnim.index]);
    for i = 1, #CoverGoodsAnim.animRes do
			CoverGoodsAnim.m_imgs[i] = new(Image, CoverGoodsAnim.animRes[i]);
			CoverGoodsAnim.drawing:addChild(CoverGoodsAnim.m_imgs[i]);
		    CoverGoodsAnim.m_imgs[i]:setVisible(false);
	end
    CoverGoodsAnim.m_curIndex = 1
	CoverGoodsAnim.animCover = new(AnimInt,kAnimRepeat,0,1,500,-1);
	CoverGoodsAnim.animCover:setEvent(CoverGoodsAnim,CoverGoodsAnim.onPlay);
end

CoverGoodsAnim.removeAnim = function()

 	if CoverGoodsAnim.drawing then
 		CoverGoodsAnim.drawing:setVisible(false)
        CoverGoodsAnim.drawing:removeAllChildren();
 	end
 	
	if CoverGoodsAnim.animCover then
		delete(CoverGoodsAnim.animCover);
		CoverGoodsAnim.animCover = nil;
	end
end

CoverGoodsAnim.animRes = {"animation/anim_rotation1.png","animation/anim_rotation2.png","animation/anim_rotation3.png"
							,"animation/anim_rotation4.png","animation/anim_rotation5.png","animation/anim_rotation6.png"
							,"animation/anim_rotation7.png","animation/anim_rotation8.png","animation/anim_rotation9.png"};

CoverGoodsAnim.onPlay = function(self)

	if CoverGoodsAnim.drawing then

		CoverGoodsAnim.drawing:setVisible(true)
		--CoverGoodsAnim.drawing:setFile(CoverGoodsAnim.animRes[CoverGoodsAnim.m_curIndex]);
        if CoverGoodsAnim.m_curIndex == 1 then
		    CoverGoodsAnim.m_imgs[1]:setVisible(true);
	    elseif CoverGoodsAnim.m_curIndex <= #CoverGoodsAnim.animRes then
		    CoverGoodsAnim.m_imgs[CoverGoodsAnim.m_curIndex-1]:setVisible(false);
		    CoverGoodsAnim.m_imgs[CoverGoodsAnim.m_curIndex]:setVisible(true);
	    else
		    CoverGoodsAnim.m_imgs[CoverGoodsAnim.m_curIndex-1]:setVisible(false);
            CoverGoodsAnim.m_curIndex = 2;
            CoverGoodsAnim.m_imgs[1]:setVisible(true);
            return;
	    end
	    CoverGoodsAnim.m_curIndex = CoverGoodsAnim.m_curIndex+1;
	end
end
