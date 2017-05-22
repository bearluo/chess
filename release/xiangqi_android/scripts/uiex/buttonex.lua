require("ui/button");

Button.onClick = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
	if not self.m_enable then
		return;
	end
	if finger_action == kFingerDown then
	   self.m_showEnbaleFunc(self,false);
	elseif finger_action == kFingerMove then
		if not (self.m_responseType == kButtonUpInside and drawing_id_first ~= drawing_id_current) then
			self.m_showEnbaleFunc(self,false);
		else
			self.m_showEnbaleFunc(self,true);
		end
	elseif finger_action == kFingerUp then
		
		
		self.m_showEnbaleFunc(self,true);
		
		local responseCallback = function()
			if self.m_eventCallback.func then
                kEffectPlayer:playEffect(Effects.AUDIO_BUTTON_CLICK);
                self.m_eventCallback.func(self.m_eventCallback.obj,finger_action,x,y,
                	drawing_id_first,drawing_id_current);
            end	
		end

		if self.m_responseType == kButtonUpInside then
			if drawing_id_first == drawing_id_current then
				responseCallback();
			end
	    elseif self.m_responseType == kButtonUpOutside then
	    	if drawing_id_first ~= drawing_id_current then
				responseCallback();
			end
		else
			responseCallback();
		end
	elseif finger_action==kFingerCancel then
		self.m_showEnbaleFunc(self,true);
	end
end