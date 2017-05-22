require("core/anim");
require("core/prop");
require("ui/node");
require("ui/image");
require("ui/textView");
require("animation/animCoord");
require("view/res_img");
require("util/ToolKit");

GongGaoScroll = {};
GongGaoScroll.flag = false;
GongGaoScroll.loaded=false;
GongGaoScroll.playing=false;
GongGaoScroll.open_done=false;
GongGaoScroll.open = true;--标志：true为打开卷轴；false为关闭卷轴；
GongGaoScroll.open_alpha = false;--标志：开始淡入动画
GongGaoScroll.open_scroll = false;--标志：开始滚出动画
GongGaoScroll.close_alpha = false;--标志：开始淡出动画
GongGaoScroll.close_scroll = false;--标志：开始滚回动画

GongGaoScroll.ms=800;--卷动展开时间
GongGaoScroll.beginHeight=60;--高度初始化为8
GongGaoScroll.diffHeight = 35;
GongGaoScroll.acceleration=1;
GongGaoScroll.frame = 0;

GongGaoScroll.diffX = 25;
GongGaoScroll.diffY = 70;

GongGaoScroll.titleSize = 30;
GongGaoScroll.contentSize = 22;



--[[pram
	text: 公告的内容
	x,y : 整个公告的位置
]]--
GongGaoScroll.play = function(flag,text,obj,func,param,x,y)
	if GongGaoScroll.playing then
		return;
	end
	GongGaoScroll.diffX = x or 25;
	GongGaoScroll.diffY = y or 70;


	GongGaoScroll.load();

	GongGaoScroll.flag = flag;

	GongGaoScroll.obj = obj;
	GongGaoScroll.func = func;
	GongGaoScroll.param = param;


	GongGaoScroll.noticeContent:setText(text);
	GongGaoScroll.root:setPos(x,y);
	
	GongGaoScroll.playing = true;
	GongGaoScroll.open_done = false;
	GongGaoScroll.open = true;
	GongGaoScroll.open_alpha = true;
	GongGaoScroll.open_scroll = false;
	GongGaoScroll.frame = 0;

	GongGaoScroll.root:setVisible(true);
	GongGaoScroll.closeBtn:setVisible(true);

	--半透明动画
	GongGaoScroll.animAlpha = new(AnimDouble,kAnimNormal,0.1,1.0,200);
	GongGaoScroll.propAlpha = new(PropTransparency,GongGaoScroll.animAlpha);
	ToolKit.setDebugName(GongGaoScroll.animAlpha , "AnimDouble|GongGaoScroll.animAlpha");
	ToolKit.setDebugName(GongGaoScroll.propAlpha , "PropTransparency|GongGaoScroll.propAlpha");
	GongGaoScroll.topImg:addProp(GongGaoScroll.propAlpha,0);
	GongGaoScroll.bottomImg:addProp(GongGaoScroll.propAlpha,0);
	
	GongGaoScroll.animAlpha:setEvent(GongGaoScroll,GongGaoScroll.onAlpha);
	
	GongGaoScroll.curHeight = GongGaoScroll.beginHeight;--高度初始化为0
	GongGaoScroll.bottomImg:setPos(GongGaoScroll.bottomX,GongGaoScroll.bottomY+GongGaoScroll.curHeight - GongGaoScroll.diffHeight);
	GongGaoScroll.bottomImg:setSize(GongGaoScroll.bottomW,GongGaoScroll.bottomH);
	GongGaoScroll.mainImg:setClip(GongGaoScroll.mainX,GongGaoScroll.mainY,GongGaoScroll.mainW,GongGaoScroll.mainY+GongGaoScroll.curHeight);
	GongGaoScroll.noticeContent:setClip(GongGaoScroll.textX,GongGaoScroll.textY,GongGaoScroll.textW,GongGaoScroll.textY+GongGaoScroll.curHeight);		

	if GongGaoScroll.flag then
		GongGaoScroll.root:addToRoot();
	else
		return GongGaoScroll.root;
	end
end

GongGaoScroll.load = function()
	if GongGaoScroll.loaded then
		return;
	end

	GongGaoScroll.loaded = true;

	local diff = AnimCoord.gongGao.noticeMainImg;
	GongGaoScroll.mainX = diff.x;
	GongGaoScroll.mainY = diff.y;
	GongGaoScroll.mainW = diff.w;
	GongGaoScroll.mainH = diff.h;

	local diff = AnimCoord.gongGao.noticeBottomImg;
	GongGaoScroll.bottomX = diff.x;
	GongGaoScroll.bottomY = diff.y;
	GongGaoScroll.bottomW = diff.w;
	GongGaoScroll.bottomH = diff.h;

	local diff = AnimCoord.gongGao.noticeTopImg;
	GongGaoScroll.topX = diff.x;
	GongGaoScroll.topY = diff.y;
	GongGaoScroll.topW = diff.w;
	GongGaoScroll.topH = diff.h;

	local diff = AnimCoord.gongGao.noticeMainTx;
	GongGaoScroll.textX = diff.x;
	GongGaoScroll.textY = diff.y;
	GongGaoScroll.textW = diff.w;
	GongGaoScroll.textH = diff.h;

	local diff = AnimCoord.gongGao.noticeTitle;
	GongGaoScroll.titleX = diff.x;
	GongGaoScroll.titleY = diff.y;
	GongGaoScroll.titleW = diff.w;
	GongGaoScroll.titleH = diff.h;




	GongGaoScroll.root = new(Node);

	local screenW = AnimCoord.gongGao.noticeClose.w;
	local screenH = AnimCoord.gongGao.noticeClose.h;
	GongGaoScroll.closeBtn = new(Button,ResImg.public.half_blank);
	GongGaoScroll.closeBtn:setPos(-GongGaoScroll.diffX,-GongGaoScroll.diffY);
	GongGaoScroll.closeBtn:setSize(screenW,screenH);
	GongGaoScroll.closeBtn:setVisible(false);
	GongGaoScroll.closeBtn:setLevel(-1);
	ToolKit.setDebugName(GongGaoScroll.closeBtn , "Button|GongGaoScroll.closeBtn");
	GongGaoScroll.closeBtn:setOnClick(GongGaoScroll.closeBtn,GongGaoScroll.onCloseBtnClick);
	-- GongGaoScroll.closeBtn:addToRoot();

	GongGaoScroll.mainImg = new(Image,ResImg.notice.notice_view);
	GongGaoScroll.mainImg:setPos(GongGaoScroll.mainX,GongGaoScroll.mainY);
	GongGaoScroll.mainImg:setSize(GongGaoScroll.mainW,GongGaoScroll.mainH);
	GongGaoScroll.mainImg:setVisible(false);
	ToolKit.setDebugName(GongGaoScroll.mainImg , "Image|GongGaoScroll.mainImg");

	GongGaoScroll.bottomImg = new(Image,ResImg.notice.notice_stick);
	GongGaoScroll.bottomImg:setPos(GongGaoScroll.bottomX,GongGaoScroll.bottomY);
	GongGaoScroll.bottomImg:setSize(GongGaoScroll.bottomW,GongGaoScroll.bottomH);
	GongGaoScroll.bottomImg:setVisible(true);
	ToolKit.setDebugName(GongGaoScroll.bottomImg , "Image|GongGaoScroll.bottomImg");

	GongGaoScroll.topImg = new(Image,ResImg.notice.notice_stick);
	GongGaoScroll.topImg:setPos(GongGaoScroll.topX,GongGaoScroll.topY);
	GongGaoScroll.topImg:setSize(GongGaoScroll.topW,GongGaoScroll.topH);
	GongGaoScroll.topImg:setVisible(true);
	ToolKit.setDebugName(GongGaoScroll.topImg , "Image|GongGaoScroll.topImg");

	GongGaoScroll.noticeContent=new(TextView,"",GongGaoScroll.textW,GongGaoScroll.textH,kTextAlignTopLeft,"",GongGaoScroll.contentSize,41,36,33);
	GongGaoScroll.noticeContent:setPos(GongGaoScroll.textX,GongGaoScroll.textY);
	GongGaoScroll.noticeContent:setSize(GongGaoScroll.textW,GongGaoScroll.textH);
	GongGaoScroll.noticeContent:setVisible(false);
	ToolKit.setDebugName(GongGaoScroll.noticeContent , "TextView|GongGaoScroll.noticeContent");

	local title= "游戏公告";
	GongGaoScroll.noticeTitle=new(Text,title,GongGaoScroll.titleW,GongGaoScroll.titleH,kTextAlignTopLeft,"",GongGaoScroll.titleSize ,41,36,33);
	GongGaoScroll.noticeTitle:setPos(GongGaoScroll.titleX,GongGaoScroll.titleY);
	GongGaoScroll.noticeTitle:setVisible(false);
	ToolKit.setDebugName(GongGaoScroll.noticeTitle , "TextView|GongGaoScroll.noticeTitle");

	GongGaoScroll.root:addChild(GongGaoScroll.closeBtn);
	GongGaoScroll.root:addChild(GongGaoScroll.mainImg);
	GongGaoScroll.root:addChild(GongGaoScroll.bottomImg);
	GongGaoScroll.root:addChild(GongGaoScroll.topImg);
	GongGaoScroll.root:addChild(GongGaoScroll.noticeContent);
	GongGaoScroll.root:addChild(GongGaoScroll.noticeTitle);
	
	GongGaoScroll.root:setVisible(false);
end

GongGaoScroll.callBack = function()
	if GongGaoScroll.func then
		GongGaoScroll.func(GongGaoScroll.obj,GongGaoScroll.param);
	end
end

GongGaoScroll.onCloseBtnClick = function()
	if GongGaoScroll.playing then
		return;
	end
	if not GongGaoScroll.open_done then
		return;
	end

	GongGaoScroll.playing=true;
	GongGaoScroll.open = false;
	GongGaoScroll.close_alpha = false;
	GongGaoScroll.close_scroll = true;
	GongGaoScroll.frame = 0;
	
	--创建一个定时器
	GongGaoScroll.animTimer = new(AnimInt,kAnimRepeat,0,1,1);
	ToolKit.setDebugName(GongGaoScroll.animTimer , "AnimInt|GongGaoScroll.animTimer");
	GongGaoScroll.animTimer:setEvent(GongGaoScroll,GongGaoScroll.onTimer);	
end

GongGaoScroll.clearAndReset=function(hide)
	if GongGaoScroll.playing then
		GongGaoScroll.playing = false;
		if hide then
			GongGaoScroll.root:setVisible(false);
			GongGaoScroll.closeBtn:setVisible(false);
		end

		if GongGaoScroll.open then
			if GongGaoScroll.open_alpha then
				GongGaoScroll.open_alpha = false;
				GongGaoScroll.removeProp(GongGaoScroll.topImg,GongGaoScroll.propAlpha);
				GongGaoScroll.removeProp(GongGaoScroll.bottomImg,GongGaoScroll.propAlpha);
				delete(GongGaoScroll.animAlpha);
				GongGaoScroll.animAlpha=nil;
				delete(GongGaoScroll.propAlpha);
				GongGaoScroll.propAlpha=nil;
			end
			
			if GongGaoScroll.open_scroll then
				GongGaoScroll.open_scroll = false;
				delete(GongGaoScroll.animTimer);
				GongGaoScroll.animTimer=nil;
			end
		else
			if GongGaoScroll.close_alpha then
				GongGaoScroll.close_alpha = false;
				GongGaoScroll.removeProp(GongGaoScroll.topImg,GongGaoScroll.propAlpha);
				GongGaoScroll.removeProp(GongGaoScroll.bottomImg,GongGaoScroll.propAlpha);
				delete(GongGaoScroll.animAlpha);
				GongGaoScroll.animAlpha=nil;
				delete(GongGaoScroll.propAlpha);
				GongGaoScroll.propAlpha=nil;
			end
			
			if GongGaoScroll.close_scroll then
				GongGaoScroll.close_scroll = false;
				delete(GongGaoScroll.animTimer);
				GongGaoScroll.animTimer=nil;
			end			
		end
	end
end

GongGaoScroll.onAlpha=function(self,anim_type, anim_id, repeat_or_loop_num)
	if GongGaoScroll.open then
		--删除alpha
		GongGaoScroll.open_alpha = false;
		GongGaoScroll.removeProp(GongGaoScroll.topImg,GongGaoScroll.propAlpha);
		GongGaoScroll.removeProp(GongGaoScroll.bottomImg,GongGaoScroll.propAlpha);
		delete(GongGaoScroll.animAlpha);
		GongGaoScroll.animAlpha=nil;
		delete(GongGaoScroll.propAlpha);
		GongGaoScroll.propAlpha=nil;
		
		--创建一个定时器
		GongGaoScroll.open_scroll = true;
		GongGaoScroll.animTimer = new(AnimInt,kAnimRepeat,0,1,1);
		GongGaoScroll.animTimer:setEvent(GongGaoScroll,GongGaoScroll.onTimer);
	else
		GongGaoScroll.clearAndReset(true);
		GongGaoScroll.callBack();
		-- if GongGaoScroll.callBack then
		-- 	GongGaoScroll.callBack:setNoticeBtnVisible(true);
		-- end		
	end	
end

GongGaoScroll.onTimer=function(self,anim_type, anim_id, repeat_or_loop_num)	
	local topX = GongGaoScroll.topX;
	local topY = GongGaoScroll.topY;
	local topW = GongGaoScroll.topW;
	local topH = GongGaoScroll.topH;

	local bottomX = GongGaoScroll.bottomX;
	local bottomY = GongGaoScroll.bottomY;
	local bottomW = GongGaoScroll.bottomW;
	local bottomH = GongGaoScroll.bottomH;
	
	local mainX = GongGaoScroll.mainX;
	local mainY = GongGaoScroll.mainY;
	local mainW = GongGaoScroll.mainW;
	local mainH = GongGaoScroll.mainH;
	
	local textX = GongGaoScroll.textX;
	local textY = GongGaoScroll.textY;
	local textW = GongGaoScroll.textW;
	local textH = GongGaoScroll.textH;
	
	GongGaoScroll.mainImg:setVisible(true);
	
	if GongGaoScroll.open then

		if GongGaoScroll.curHeight < GongGaoScroll.mainH - GongGaoScroll.diffHeight then
			GongGaoScroll.bottomImg:setPos(bottomX,bottomY+GongGaoScroll.curHeight);
			GongGaoScroll.bottomImg:setSize(bottomW,bottomH);
			GongGaoScroll.curHeight = GongGaoScroll.curHeight + 10 + GongGaoScroll.acceleration * GongGaoScroll.frame/2;
			GongGaoScroll.frame = GongGaoScroll.frame + 1;
			GongGaoScroll.mainImg:setClip(mainX,mainY,mainW,GongGaoScroll.curHeight);
			-- GongGaoScroll.noticeContent:setClip(textX,textY,textW,GongGaoScroll.curHeight);
			local contentH = GongGaoScroll.curHeight > GongGaoScroll.textH and GongGaoScroll.textH or GongGaoScroll.curHeight;
			GongGaoScroll.noticeContent:setClip(textX,textY,textW,contentH);
			GongGaoScroll.noticeTitle:setClip(GongGaoScroll.titleX,GongGaoScroll.titleY,GongGaoScroll.titleW,GongGaoScroll.curHeight);
		else
			GongGaoScroll.noticeContent:setSize(GongGaoScroll.textW,GongGaoScroll.textH);
			GongGaoScroll.noticeContent:setVisible(true);
			GongGaoScroll.noticeTitle:setVisible(true);
			GongGaoScroll.clearAndReset(false);
			GongGaoScroll.open_done = true;
		end
	else
		-- print_string("----------------------GongGaoScroll close animation--------------------");
		if GongGaoScroll.curHeight > 8 then
			GongGaoScroll.bottomImg:setPos(bottomX,bottomY+GongGaoScroll.curHeight-GongGaoScroll.diffHeight);
			GongGaoScroll.bottomImg:setSize(bottomW,bottomH);

			GongGaoScroll.curHeight = GongGaoScroll.curHeight - 10 - GongGaoScroll.acceleration * GongGaoScroll.frame/2;
			GongGaoScroll.frame = GongGaoScroll.frame + 1;
			if GongGaoScroll.curHeight<0 then
				GongGaoScroll.curHeight=0;
			end

			GongGaoScroll.mainImg:setClip(mainX,mainY,mainW,GongGaoScroll.curHeight);
			local contentH = GongGaoScroll.curHeight > GongGaoScroll.textH and GongGaoScroll.textH or GongGaoScroll.curHeight;
			GongGaoScroll.noticeContent:setClip(textX,textY,textW,contentH);
			GongGaoScroll.noticeTitle:setClip(GongGaoScroll.titleX,GongGaoScroll.titleY,GongGaoScroll.titleW,GongGaoScroll.curHeight);

		else
			GongGaoScroll.mainImg:setVisible(false);
			GongGaoScroll.noticeContent:setVisible(false);
			GongGaoScroll.noticeTitle:setVisible(false);
			
			GongGaoScroll.close_scroll = false;
			GongGaoScroll.close_alpha = true;			
			delete(GongGaoScroll.animTimer);
			
			GongGaoScroll.animAlpha = new(AnimDouble,kAnimNormal,1.0,0.0,300);
            GongGaoScroll.animAlpha:setDebugName("GongGaoScroll.animAlpha");
			GongGaoScroll.propAlpha = new(PropTransparency,GongGaoScroll.animAlpha);
			GongGaoScroll.topImg:addProp(GongGaoScroll.propAlpha,0);
			GongGaoScroll.bottomImg:addProp(GongGaoScroll.propAlpha,0);

			GongGaoScroll.animAlpha:setEvent(GongGaoScroll,GongGaoScroll.onAlpha);			
		end
	end
end

GongGaoScroll.close=function()
	if GongGaoScroll.playing then
		return;
	end
	if not GongGaoScroll.open_done then
		return;
	end
	
	GongGaoScroll.playing=true;
	GongGaoScroll.open = false;
	GongGaoScroll.close_alpha = false;
	GongGaoScroll.close_scroll = true;
	GongGaoScroll.frame = 0;
	
	--创建一个定时器
	GongGaoScroll.animTimer = new(AnimInt,kAnimRepeat,0,1,1);
	GongGaoScroll.animTimer:setEvent(GongGaoScroll,GongGaoScroll.onTimer);	
end

GongGaoScroll.stop = function()
	GongGaoScroll.playing=true;
	GongGaoScroll.open = false;
	GongGaoScroll.close_alpha = false;
	GongGaoScroll.close_scroll = false;
	GongGaoScroll.clearAndReset(true);
	GongGaoScroll.callBack();
end

GongGaoScroll.removeProp = function(drawing,prop)
    if drawing and prop then 
        drawing:removePropByID(prop.m_propID);
    end
end

GongGaoScroll.release = function()
	delete(GongGaoScroll.closeBtn);
	GongGaoScroll.closeBtn = nil;

	if GongGaoScroll.flag then
		delete(GongGaoScroll.noticeContent);
		GongGaoScroll.noticeContent = nil;

		delete(GongGaoScroll.noticeTitle);
		GongGaoScroll.noticeTitle = nil;

		delete(GongGaoScroll.bottomImg);
		GongGaoScroll.bottomImg = nil;

		delete(GongGaoScroll.mainImg);
		GongGaoScroll.mainImg = nil;

		delete(GongGaoScroll.topImg);
		GongGaoScroll.topImg = nil;

		delete(GongGaoScroll.root);
		GongGaoScroll.root = nil;
	end

	GongGaoScroll.loaded = false;
	GongGaoScroll.flag = false;
end

GongGaoScroll.deleteAll =function()
	GongGaoScroll.clearAndReset();
	GongGaoScroll.release();
	
	GongGaoScroll.loaded = false;
	GongGaoScroll.flag = false;
end