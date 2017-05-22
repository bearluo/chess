-- scroller.lua
-- Author: Vicent.Gong
-- Date: 2012-09-24
-- Last modification : 2013-07-25
-- Description: Implemented a scorller

require("core/constants");
require("core/object");
require("core/global");
require("core/anim");

Scroller = class();

Scroller.s_defaultFlippingFrames = 20;
Scroller.s_defalutFlippingSpeedFactor = 0.01;
Scroller.s_defaultFlippingOverFactor = 0.3;
Scroller.s_defaultReboundFrames = 20;
Scroller.s_defaultUnitTurningFactor = 0.35;

Scroller.setDefaultFlippingFrames = function(flippingFrames)
	Scroller.s_flippingFrames = flippingFrames or Scroller.s_defaultFlippingFrames;
end

Scroller.setDefaultFlippingSpeedFactor = function(flippingSpeedFactor)
	Scroller.s_flippingSpeedFactor = flippingSpeedFactor or Scroller.s_defalutFlippingSpeedFactor;
end

Scroller.setDefaultFlippingOverFactor = function(flippingOverFactor)
	Scroller.s_flippingOverFactor = flippingOverFactor or Scorller.s_defaultFlippingOverFactor;
end

Scroller.setDefaultReboundFrames = function(reboundFrames)
	Scroller.s_reboundFrames = reboundFrames or Scroller.s_defaultReboundFrames;
end

Scroller.setDefaultUnitTurningFactor = function(unitTurningFactor)
	Scroller.s_unitTurningFactor = unitTurningFactor or Scroller.s_defaultUnitTurningFactor;
end

Scroller.ctor = function(self, direction, frameLength, viewLength, unitLength)
	self.m_direction = direction or kVertical;
	self.m_frameLength = frameLength or 1;
	self.m_viewLength = viewLength or 1;
	self.m_unitLength = unitLength or 1;
	
	self.m_flippingFrames = Scroller.s_flippingFrames or Scroller.s_defaultFlippingFrames;
	self.m_flippingSpeedFactor = Scroller.s_flippingSpeedFactor or Scroller.s_defalutFlippingSpeedFactor;
	self.m_flippingOverFactor = Scroller.s_flippingOverFactor or Scroller.s_defaultFlippingOverFactor;
	self.m_reboundFrames = Scroller.s_reboundFrames or Scroller.s_defaultReboundFrames;
	self.m_unitTurningFactor = Scroller.s_unitTurningFactor or Scroller.s_defaultUnitTurningFactor;

	self.m_reboundForwardMargin = 0;
	self.m_reboundBackwardMargin = 0;

	self.m_offset = 0;
	self.m_status = kScrollerStatusStop;

	self.m_eventCallback = {};
	self.m_upReboundCallback = {};
	self.m_downReboundCallback = {};
end

Scroller.setFlippingFrames = function(self, frames)
	self.m_flippingFrames = frames 
							or Scroller.s_flippingFrames
							or Scroller.s_defaultFlippingFrames;
end

Scroller.setFlippingSpeedFactor = function(self, factor)
	self.m_flippingSpeedFactor = factor
								or Scroller.s_flippingSpeedFactor
								or Scroller.s_defalutFlippingSpeedFactor;
end

Scroller.setFlippingOverFactor = function(self, factor)
	self.m_flippingOverFactor = factor
								or Scroller.s_flippingOverFactor
								or Scorller.s_defaultFlippingOverFactor;
end

Scroller.setReboundFrames = function(self, frames)
	self.m_reboundFrames = frames
						or Scroller.s_reboundFrames
						or Scroller.s_defaultReboundFrames;
end

Scroller.setUnitTurningFactor = function(self, factor)
	self.m_unitTurningFactor = factor 
							or Scroller.s_unitTurningFactor
							or Scroller.s_defaultUnitTurningFactor;
end

Scroller.setReboundMargin = function(self, forwardMargin, backwardMargin)
	self.m_reboundBackwardMargin = backwardMargin;
	self.m_reboundForwardMargin = forwardMargin;
end

Scroller.stopMarginRebounding = function(self)
    local reboundLength = Scroller.calcReboundLength(self,self.m_offset,true);
    if self:isReboundEnable() and reboundLength ~= 0 then
        Scroller.addRebound(self,reboundLength);
    end
end

Scroller.setOffset = function(self, offset)
	local diff = offset - self.m_offset;
	self.m_offset = offset;
    
	Scroller.changeStatusAndCallBack(self,kScrollerStatusStart,diff);
	Scroller.changeStatusAndCallBack(self,kScrollerStatusStop,0);
end

Scroller.setFrameLength = function(self, frameLength)
	self.m_frameLength = frameLength;
end

Scroller.setViewLength = function(self, viewLength)
	self.m_viewLength = viewLength;
end

Scroller.setUnitLength = function(self, unitLength)
	self.m_unitLength = unitLength;
end

Scroller.setScrollCallback = function(self, obj, func)
	self.m_eventCallback.func = func;
	self.m_eventCallback.obj = obj;
end

Scroller.stop = function(self)
	local diff = 0;
	Scroller.removeFlipping(self);
	Scroller.removeRebound(self);

	if Scroller.isFlipping(self) then
		diff = self.m_flippingSpeed;
	elseif Scroller.isRebounding(self) then
		diff = self.m_reboundSpeed;
	else
		return;
	end

	local newOffset = Scroller.clipOffsetToRegularOffsetRange(self,self.m_offset);
	newOffset = Scroller.clipOffsetToUnitEdge(self,newOffset,diff);
	diff = newOffset - self.m_offset;
	self.m_offset = newOffset;

	Scroller.changeStatusAndCallBack(self,kScrollerStatusStart,diff);
	Scroller.changeStatusAndCallBack(self,kScrollerStatusStop,0);
end

Scroller.scrollToTop = function(self)
	local min,max = self:getRegularOffsetRange();
	local diff = max-self.m_offset;
	self.m_offset = max;
	Scroller.changeStatusAndCallBack(self,kScrollerStatusStart,diff);
	Scroller.changeStatusAndCallBack(self,kScrollerStatusStop,0);
end

Scroller.scrollToBottom = function(self)
	local min,max = self:getRegularOffsetRange();
	local diff = min-self.m_offset;
	self.m_offset = min;
	Scroller.changeStatusAndCallBack(self,kScrollerStatusStart,diff);
	Scroller.changeStatusAndCallBack(self,kScrollerStatusStop,0);
end

Scroller.scrollToPos = function(self,pos)
	local min,max = self:getRegularOffsetRange();
    if pos > max then pos = max end;
    if pos < min then pos = min end;
	local diff = pos-self.m_offset;
	self.m_offset = pos;
	Scroller.changeStatusAndCallBack(self,kScrollerStatusStart,diff);
	Scroller.changeStatusAndCallBack(self,kScrollerStatusStop,0);
end

Scroller.dtor = function(self)
	Scroller.stop(self);
end

---------------------------------private functions-----------------------------------------

Scroller.calcSpeedAndAcceleration = function(self, offset, frames)
	if frames < 1 then
		return -offset,0;
	else
		local acceleration = -2 * offset / (frames^2);
		local speed = -acceleration * frames;

		return speed,acceleration;
	end
end

Scroller.isOffsetOverRange = function(self, offset, minOffset, maxOffset)
	if offset < minOffset then
		return true;
	elseif offset > maxOffset then
		return true;
	else
		return false;
	end
end

Scroller.clipOffsetToRange = function(self, offset, minOffset, maxOffset)
	if offset > maxOffset then 
	    offset = maxOffset;
	elseif offset < minOffset then
	    offset = minOffset;
	end

	return offset;
end

Scroller.getRegularOffsetRange = function(self)
	return math.min(math.floor(self.m_frameLength - self.m_viewLength),0),0;
end

Scroller.getMarginOffsetRange = function(self)
	local regularOffsetMin,regularOffsetMax = self:getRegularOffsetRange();
	return regularOffsetMin - self.m_reboundForwardMargin, regularOffsetMax + self.m_reboundBackwardMargin;
end

Scroller.clipOffsetToRegularOffsetRange = function(self, offset)
	local minOffset,maxOffset = Scroller.getRegularOffsetRange(self);
	return Scroller.clipOffsetToRange(self,offset,minOffset,maxOffset);
end

Scroller.clipOffsetToMarginOffsetRange = function(self, offset)
	local minOffset,maxOffset = Scroller.getMarginOffsetRange(self);
	return Scroller.clipOffsetToRange(self,offset,minOffset,maxOffset);
end

Scroller.getFlippingExtraOffset = function(self)
	return self.m_frameLength*self.m_flippingOverFactor;
end

Scroller.getFlippingOffsetRange = function(self)
	local regularMinOffset,regularMaxOffset = Scroller.getRegularOffsetRange(self);

	local flippingExtraOffset = Scroller.getFlippingExtraOffset(self);

	local flippingMinOffset = regularMinOffset - flippingExtraOffset;
	local flippingMaxOffset = regularMaxOffset + flippingExtraOffset;

	return flippingMinOffset,flippingMaxOffset;
end

Scroller.clipOffsetToFlippingOffsetRange = function(self, offset)
	local minOffset,maxOffset = Scroller.getFlippingOffsetRange(self);
	return Scroller.clipOffsetToRange(self,offset,minOffset,maxOffset);
end

Scroller.clipOffsetToUnitEdge = function(self, offset, diff)
    local offset = offset + diff;
	local remainder = math.abs(offset) % self.m_unitLength;

	local minUnitTurningOffset;
	if diff < 0 then
		minUnitTurningOffset = self.m_unitTurningFactor * self.m_unitLength;
	else
		minUnitTurningOffset = (1-self.m_unitTurningFactor) * self.m_unitLength;
	end

	local patch;
	if remainder >= minUnitTurningOffset then
		patch = remainder - self.m_unitLength ;
	else
		patch = remainder;
	end
	
	if offset > 0 then
		offset = offset - patch;
	else
		offset = offset + patch;
	end

	return offset;
end

Scroller.calcOffset = function(self, offset, diff)
	offset = offset + diff;

	if not Scroller.isReboundEnable(self) then
		return Scroller.clipOffsetToRegularOffsetRange(self,offset);
	else
		return Scroller.clipOffsetToFlippingOffsetRange(self,offset);
	end
end

--Flip

Scroller.isFlippingEnable = function(self)
	return self.m_flippingFrames >= 1;
end

Scroller.isFlipping = function(self)
	return self.m_flippingAnim ~= nil;
end

Scroller.isFlippingOver = function(self, offset)
	local flippingMinOffset,flippingMaxOffset = Scroller.getFlippingOffsetRange(self);
	return Scroller.isOffsetOverRange(self,offset,flippingMinOffset,flippingMaxOffset);
end

Scroller.calcFlippingLength = function(self, totalOffset, timeDiff)
	local speed = totalOffset / timeDiff * self.m_flippingSpeedFactor;
	local acceleration = -speed / self.m_flippingFrames;
	
	local timeSquare = self.m_flippingFrames * self.m_flippingFrames;
	
	local totalFlippingOffset = -acceleration * timeSquare /2;
	local afterFlippingOffset = totalFlippingOffset + self.m_offset;

	local clipingOffset = afterFlippingOffset;
	if not Scroller.isReboundEnable(self) then
		clipingOffset = Scroller.clipOffsetToRegularOffsetRange(self,afterFlippingOffset);
	elseif Scroller.isFlippingOver(self,afterFlippingOffset) then
		clipingOffset = Scroller.clipOffsetToFlippingOffsetRange(self,afterFlippingOffset);
	end

	if not Scroller.isFlippingOver(self,afterFlippingOffset) then
		clipingOffset = Scroller.clipOffsetToUnitEdge(self,self.m_offset,clipingOffset - self.m_offset);
	end

	if totalFlippingOffset * (clipingOffset - self.m_offset) > 0 then
		totalFlippingOffset = clipingOffset - self.m_offset;
	else
		totalFlippingOffset = 0;
	end

	return totalFlippingOffset;
end

Scroller.addFlipping = function(self, flippingLength)
	self.m_afterFlippingOffset = self.m_offset + flippingLength;
	self.m_flippingSpeed,self.m_flippingAcceleration 
		= Scroller.calcSpeedAndAcceleration(self,flippingLength,self.m_flippingFrames);
	
	self.m_flippingTimerCount = 0;
    self.m_flippingAnim = new(AnimDouble,kAnimRepeat,0.0,1.0,1);
    self.m_flippingAnim:setEvent(self,self.onFlippingTimer);
end

Scroller.removeFlipping = function(self)
    delete(self.m_flippingAnim);
    self.m_flippingAnim = nil;
	self.m_flippingTimerCount = 0;
end

Scroller.onFlippingTimer = function(self, anim_type, anim_id, repeat_or_loop_num)
	self.m_flippingTimerCount = self.m_flippingTimerCount + 1;
	local lastOffset = self.m_offset;
    self.m_offset = self.m_offset + self.m_flippingSpeed;
	local speed = self.m_flippingSpeed + self.m_flippingAcceleration;

	if speed * self.m_flippingSpeed <= 0 
		or self.m_flippingTimerCount >= self.m_flippingFrames then

		self.m_offset = self.m_afterFlippingOffset;

		local reboundLength = Scroller.calcReboundLength(self,self.m_offset - lastOffset);
    	if reboundLength ~= 0 then
    		Scroller.addRebound(self,reboundLength);
    		Scroller.changeStatusAndCallBack(self,kScrollerStatusMoving,self.m_offset - lastOffset);
    	else
			Scroller.changeStatusAndCallBack(self,kScrollerStatusStop,self.m_offset - lastOffset);
		end

		Scroller.removeFlipping(self);
	else
		Scroller.changeStatusAndCallBack(self,kScrollerStatusMoving,self.m_flippingSpeed);
		self.m_flippingSpeed = speed;
	end
end

--Rebound

Scroller.isRebounding = function(self)
	return self.m_reboundAnim ~= nil;
end

Scroller.isReboundEnable = function(self)
	return self.m_reboundFrames >= 1;
end

Scroller.isBoundOver = function(self, offset)
	local minOffset,maxOffset = Scroller.getRegularOffsetRange(self);
	return Scroller.isOffsetOverRange(self,offset,minOffset,maxOffset);
end

Scroller.getBoundOverLength = function(self, offset, ignoreMarginRebounding)
	local newOffset = Scroller.clipOffsetToRegularOffsetRange(self,offset);
	local regularReboundLength = newOffset - offset;

	newOffset = Scroller.clipOffsetToMarginOffsetRange(self,offset);
	local marginReboundLength = newOffset - offset;

	if marginReboundLength * regularReboundLength > 0 and (not ignoreMarginRebounding) then
		self.m_isMarginRebounding = true;
		return marginReboundLength;
	else
		self.m_isMarginRebounding = false;
		return regularReboundLength;
	end
end

Scroller.calcReboundLength = function(self, diff, ignoreMarginRebounding)
	local reboundLength = 0;
	if Scroller.isReboundEnable(self) and Scroller.isBoundOver(self,self.m_offset) then
		reboundLength = Scroller.getBoundOverLength(self,self.m_offset,ignoreMarginRebounding);
	else
		local newOffset = Scroller.clipOffsetToUnitEdge(self,self.m_offset - diff,diff);
		reboundLength = newOffset - self.m_offset;
	end

	return reboundLength; 
end


Scroller.setUpReboundCallback = function(self, func, obj)
	self.m_upReboundCallback.func = func;
	self.m_upReboundCallback.obj = obj;
end

Scroller.setDownReboundCallback = function(self, func, obj)
	self.m_downReboundCallback.func = func;
	self.m_downReboundCallback.obj = obj;
end

Scroller.addRebound = function(self, reboundLength)
	Scroller.removeRebound(self);

	self.m_afterReboundingOffset = self.m_offset + reboundLength;
	self.m_reboundSpeed,self.m_reboundAcceleration = 
		Scroller.calcSpeedAndAcceleration(self,reboundLength,self.m_reboundFrames);

	self.m_reboundTimerCount = 0;
	self.m_reboundAnim = new(AnimDouble,kAnimRepeat,0.0,1.0,1);
	self.m_reboundAnim:setEvent(self,self.onReboundTimer);

	--反弹触发事件
	if reboundLength < 0 and self.m_upReboundCallback.func then
		self.m_upReboundCallback.func(self.m_upReboundCallback.obj);
	elseif reboundLength >= 0 and self.m_downReboundCallback.func then
		self.m_downReboundCallback.func(self.m_downReboundCallback.obj);
	end
end

Scroller.removeRebound = function(self)
     delete(self.m_reboundAnim);
     self.m_reboundAnim = nil;
	 self.m_reboundTimerCount = 0;
end

Scroller.onReboundTimer = function(self, anim_type, anim_id, repeat_or_loop_num)
    self.m_reboundTimerCount = self.m_reboundTimerCount + 1;
	
	local lastOffset = self.m_offset;
	self.m_offset = self.m_offset + self.m_reboundSpeed;
    
    local reboundEnd = false;
    local speed = self.m_reboundSpeed + self.m_reboundAcceleration;

    if self.m_reboundTimerCount >= self.m_reboundFrames 
    	or speed*self.m_reboundSpeed <= 0
    	or (self.m_offset - self.m_afterReboundingOffset) * (lastOffset - self.m_afterReboundingOffset) <= 0 then 

        self.m_offset = self.m_afterReboundingOffset;
        reboundEnd = true;
    else
		self.m_reboundSpeed = speed;
    end
    if reboundEnd then
        Scroller.removeRebound(self);
		Scroller.changeStatusAndCallBack(self,kScrollerStatusStop,self.m_offset - lastOffset);
    else
		Scroller.changeStatusAndCallBack(self,kScrollerStatusMoving,self.m_offset - lastOffset);
	end
end

Scroller.onEventTouch = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
	local curPos = (self.m_direction == kVertical) and y or x;

	if kFingerDown == finger_action then
		Scroller.stop(self);

		self.m_startTime = os.clock();
		self.m_lastPos = curPos;
		self.m_startPos = curPos;
		self.m_lastDiff = 0;
		self.m_touching = true;
		self.m_isMarginRebounding = false;
	elseif self.m_touching then 
		local diff = curPos - self.m_lastPos;
		self.m_lastPos = curPos;
        
		local offset = Scroller.calcOffset(self,self.m_offset,diff);
		diff = offset - self.m_offset;
		self.m_offset = offset;
		
		if self.m_status == kScrollerStatusStop then 
			Scroller.changeStatusAndCallBack(self,kScrollerStatusStart,diff);
		else
			Scroller.changeStatusAndCallBack(self,kScrollerStatusMoving,diff);
		end
		
	    if kFingerMove ~= finger_action then 
            self.m_touching = false;

            local timeDiff = os.clock() - self.m_startTime;
			
			--Not need flipping
            if not Scroller.isFlippingEnable(self) --set not to flip
            	or Scroller.isFlippingOver(self,offset)
            	or timeDiff <=  0.001 -- time is too short 
            	or math.abs(self.m_lastDiff) <= 8 -- scroll region is too short
            	or self.m_lastDiff * diff < 0 
            	or (curPos-self.m_startPos)*diff < 0 then -- change direction in scrolling 
            	local reboundLength = Scroller.calcReboundLength(self,curPos-self.m_startPos);
            	if reboundLength ~= 0 then
            	    if self:isReboundEnable() then  
            		    Scroller.addRebound(self,reboundLength);
            		else
            		    Scroller.changeStatusAndCallBack(self,kScrollerStatusStop,reboundLength);
            		end
            	else
					Scroller.changeStatusAndCallBack(self,kScrollerStatusStop,0);
				end
            else
				--flipping
				local offset = curPos - self.m_startPos;  
				local flippingLength = Scroller.calcFlippingLength(self,offset,timeDiff);
				local reboundLength = Scroller.calcReboundLength(self,curPos-self.m_startPos);
				if math.abs(flippingLength) > 1 and math.abs(reboundLength) < 1 then
					Scroller.addFlipping(self,flippingLength);
				else
            	    if reboundLength ~= 0 then
            		    if self:isReboundEnable() then
                            Scroller.addRebound(self,reboundLength);
                        else
                            Scroller.changeStatusAndCallBack(self,kScrollerStatusStop,reboundLength);
                        end
            	    else
					    Scroller.changeStatusAndCallBack(self,kScrollerStatusStop,0);
				    end
				end
			end
        end
        
        self.m_lastDiff = diff;
	end
end

Scroller.changeStatusAndCallBack = function(self, status, diff)
	self.m_status = status;
	if self.m_eventCallback.func then 
		self.m_eventCallback.func(self.m_eventCallback.obj,self.m_status,diff,self.m_offset,self.m_isMarginRebounding);
	end	
end

function Scroller:isTouching()
    return self.m_touching;
end
