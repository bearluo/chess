require("core/object");
require("core/constants");
require("ui/image");
require("config/chess_config")
require("config/roomres");
require("config/boardres")
Chess = class(DrawingEmpty);



Chess.ctor = function ( self,pc,chessSize,flipped)
	self.m_pc = pc;
    self.chessSize = chessSize;
    self.m_flipped = flipped;

    local chess_bg = Board.boardres_map["piece.png"];
    local selected = Board.boardres_map["down_piece_selected.png"];

    self.m_chessSize = chessSize;


	self.imgbg = new(Image,chess_bg);
    self.imgbg_2 = new(Image,selected);
    self.imgbg:setAlign(kAlignCenter);
    self.imgbg_2:setAlign(kAlignCenter);
	self:addChild(self.imgbg_2);
	self:addChild(self.imgbg);
    self.imgbg_2:setVisible(false);
	if not drawable_resource_id[pc] then
	    return 0;
	end
	local file = drawable_resource_id[pc].. ".png";--piece_resource_id[pc].. ".png" ;
    local cFile = drawable_choose_resource_id[pc+200].. ".png";

	if file then
		file = Board.boardres_map[file];
	end
    if cFile then
		cFile = Board.boardres_map[cFile];
	end

	self.m_imgtext = new(Image,file);
    self.m_imgtextchoose = new(Image,cFile);
	self.imgbg:addChild(self.m_imgtext);
	self.imgbg_2:addChild(self.m_imgtextchoose);
    if UserInfo.getInstance():getIsVip() == 1 then
--        self.m_imgtextchoose:setPos(1,-14);
    else
--        self.m_imgtextchoose:setPos(1,-14);
    end
    local scale = chessSize/80;

    self:setSize(80,80);
    local prop = new(PropScaleSolid, scale, scale,kCenterDrawing,0,0);
	self:addProp(prop,1001);

    self:setLevel(CHESS_LEVEL);
--	self:setEventTouch(self,self.onTouch);
end

Chess.setScale = function(self,scale)
	if scale == 1 then
	    self:removeProp(1000);
	    delete(self.prop);
	    self.prop = nil;
	else
		self.prop = new(PropScaleSolid, scale, scale,kCenterDrawing,0,0);
		self:addProp(self.prop,1000);
	end
end

Chess.selected = function(self)
	self.imgbg:setVisible(false);
	self.imgbg_2:setVisible(true);
	self:setLevel(CHESS_SELECTED_LEVEL);
    self.m_isPop = true;
    if Chess.s_selected then
        if Chess.s_selected ~= self then 
            Chess.s_selected.m_isPop = false;
            Chess.s_selected:normal();
            Chess.s_selected = self;
        end;
    else
        Chess.s_selected = self;
    end;
end

Chess.normal = function(self)
	self.imgbg:setVisible(true);
	self.imgbg_2:setVisible(false);
	self:setLevel(CHESS_LEVEL);
    self.m_isPop = false;
    if Chess.s_selected then
        if Chess.s_selected == self then 
            Chess.s_selected = nil;
        end;
    end
end


Chess.setMove = function(self,fromX,fromY,obj,func)

	self.m_obj = obj;
	self.m_func = func;

	local moveTime = 300;
	local toX,toY = self:getPos();

	local diffX  = fromX - toX;
	local diffY  = fromY - toY;

	-- local y,height = self.m_image_front.m_y,self.m_image_front.m_y+self.m_image_front.m_height;
	self.m_animY = new(AnimInt,kAnimNormal,diffY,0,moveTime,-1); 
	self.m_animY:setDebugName("Chess.setMove.m_animY");
	self.m_animY:setEvent(self,self.moveEnd);

	self.m_animX = new(AnimInt,kAnimNormal,diffX,0,moveTime,-1);
	self.m_animX:setDebugName("Chess.setMove.m_animX");

	self.m_prop = new(PropTranslate,self.m_animX,self.m_animY);
	self:addProp(self.m_prop,10);
	self:setLevel(CHESS_SELECTED_LEVEL);


end

Chess.moveEnd = function(self)

	if self.m_obj and self.m_func then
		self.m_func(self.m_obj);
		self.m_obj = nil;
		self.m_func = nil;
	end

    self:removeProp(10);
    delete(self.m_prop);
	self.m_prop = nil;

	if self.m_animX then
		-- print_string(" delete(self.m_animX) ");
		delete(self.m_animX);
		-- print_string(" delete(self.m_animX) ");
		self.m_animX = nil;
	end

	if self.m_animY then
		-- print_string(" delete(self.m_animY) ");
		delete(self.m_animY);
		-- print_string(" delete(self.m_animY) ");
		self.m_animY = nil;
	end

	self:setLevel(CHESS_LEVEL);
	
end


Chess.onTouch = function(self,finger_action,x,y,drawing_id_first,drawing_id_current)

	if finger_action == kFingerDown then
        if not self.m_isPop then
            self:selected();  
        else
            self:normal();
        end;
	elseif finger_action == kFingerUp then
	end
end


Chess.isPopState = function(self)
    return self.m_isPop;
end;
--Chess.onTouch = function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
--	if finger_action == kFingerDown then
--		self.m_down = true;
--		self.m_downX = x;
--		self.m_downY = y;
--	else
--		if not self.m_down then return end;

--		local diffX = x - self.m_downX;
--		local diffY = y - self.m_downY;

--		self:setPos(self.m_x + diffX,self.m_y + diffY);

--		self.m_downX,self.m_downY = x,y;

--		if finger_action ~= kFingerMove then
--			self.m_down = nil;
--		end
--	end
--end

Chess.getPC = function(self)
	return self.m_pc or 0;
end

Chess.dtor = function ( self )
    if Chess.s_selected then
        Chess.s_selected = nil;
    end;                                                                     
end