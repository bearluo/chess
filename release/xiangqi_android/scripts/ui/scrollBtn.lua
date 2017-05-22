require("ui/button")
require("ui/text")

ScrollButton = class(Button,false);

ScrollButton.s_maxClickOffset = 10;

-- { "驰骋沙场", "骁勇善战", "横扫千军", "运畴帷幄", "叱诧风云", "震古烁今", "问鼎中原" }
ScrollButton.level = {"ccsc","xysz","hsqj","ycww","ccfy","zgsj","wdzy"}

ScrollButton.ctor = function(self,index,locked)
	self:setIndex(index);
	self:setLocked(locked);
	super(self,"common/button/qipu_item_btn.png","common/button/qipu_item_btn_press.png")
	self:addChild(self.m_title);
    self:addChild(self.m_title_num);
	self:addChild(self.m_locked_icon);
    self:addChild(self.m_locked_mask);
    if self.m_locked then
        self.m_locked_icon:setVisible(false);
        self.m_locked_mask:setVisible(false);
    else
        self.m_locked_icon:setVisible(true);
        self.m_locked_mask:setVisible(true);    
    end; 
	self:addChild(self.m_title);
    self:addChild(self.m_title_num);
end

ScrollButton.onClick = function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
	
	local index = 0;
	
	if finger_action==kFingerDown then
	    index = 1;
	    self.m_startX = x;
		self.m_startY = y;
	elseif finger_action==kFingerMove then
		if drawing_id_first==drawing_id_current then
			index = 1;
		end
	end
	self:setImageIndex(index);
--	self:setColor(color,color,color);
	
	if finger_action==kFingerUp then
		if math.abs(y-self.m_startY) < ScrollButton.s_maxClickOffset then
			if drawing_id_first==drawing_id_current then
                if self.m_eventCallback.func then
                    kEffectPlayer:playEffect(Effects.AUDIO_BUTTON_CLICK);
                    self.m_eventCallback.func(self.m_eventCallback.obj,self:getIndex());
                end	
			end
		end
	elseif finger_action==kFingerCancel then
		
	end
end


ScrollButton.setIndex = function(self,index)
	self.m_index = index;
	self.m_index_text = ScrollButton.level[index+1];
end
ScrollButton.getIndex = function(self,index)
	return self.m_index or 0;
end

--pram locked   true - unlock   false - lock
ScrollButton.setLocked = function(self,locked)
	self.m_locked = locked;
	self.m_locked_text = self.m_locked and "unlock" or "lock";
	if not self.m_title and not self.m_title_num 
        and not self.m_locked_icon and not self.m_locked_mask then
        -- button_title
        self.m_title_num = new(Image, "console/gate_"..self.m_index..".png");
        self.m_title     = new(Image, "console/gate_name"..self.m_index..".png");
        self.m_title_num:setAlign(kAlignCenter);
        self.m_title:setAlign(kAlignCenter);
        self.m_title_num:setPos(-130,nil);
        self.m_title:setPos(60,-10);
        
        -- locked
        self.m_locked_icon = new(Image, "console/lock_icon.png");
        self.m_locked_mask = new(Image, "console/lock_mask.png");
        self.m_locked_icon:setPos(35,25);
	else
--		self.m_title:setText(User.CONSOLE_TITLE[self.m_index]);
	end

    if locked then
        self.m_locked_icon:setVisible(false);
        self.m_locked_mask:setVisible(false);
    end
end

ScrollButton.isUnLocked = function(self)
	return self.m_locked ;
end

