-- stateMachine.lua
-- Author: Vicent Gong
-- Date: 2012-07-09
-- Last modification : 2013-05-30
-- Description: Implement a stateMachine to handle state changing in global

require("core/state");
require("core/anim");
require("core/constants");
require("statesConfig");

StateMachine = class();

StateMachine.ISPUSH   = 100;
StateMachine.ISPOP    = 101;
StateMachine.ISCHANGE = 102;

StateMachine.getInstance = function()
	if not StateMachine.s_instance then
		StateMachine.s_instance = new(StateMachine);
	end
	
	return StateMachine.s_instance;
end

StateMachine.releaseInstance = function()
	delete(StateMachine.s_instance);
	StateMachine.s_instance = nil;
end

StateMachine.registerStyle = function(self, func)
	self.m_styleFuncMap[#self.m_styleFuncMap+1] = func;
    return #self.m_styleFuncMap;
end

StateMachine.changeState = function(self, state, style, ...)	
	if not StateMachine.checkState(self,state) then
		return;
	end
		
	local newState,needLoad = StateMachine.getNewState(self,state,...);
	local lastState = table.remove(self.m_states,#self.m_states);
    
	--release all useless states
	for k,v in pairs(self.m_states) do
		StateMachine.cleanState(self,v);
	end

	--Insert new state
	self.m_states = {};
	self.m_states[#self.m_states+1] = newState;
	StateMachine.switchState(self,needLoad,false,lastState,true,style,StateMachine.ISCHANGE);
end

StateMachine.replaceState = function(self, state, style, isPopupState, ...)
    if not StateMachine.checkState(self,state) then
		return;
	end


	local newState,needLoad = StateMachine.getNewState(self,state,...);
	local lastState = table.remove(self.m_states,#self.m_states)

	self.m_states[#self.m_states+1] = newState;

	StateMachine.switchState(self,needLoad,isPopupState,lastState,true,style,StateMachine.ISPUSH);
end

StateMachine.pushState = function(self, state, style, isPopupState, ...)
	if not StateMachine.checkState(self,state) then
		return;
	end
	
	local newState,needLoad = StateMachine.getNewState(self,state,...);
	local lastState = self.m_states[#self.m_states];
    

	self.m_states[#self.m_states+1] = newState;

	StateMachine.switchState(self,needLoad,isPopupState,lastState,false,style,StateMachine.ISPUSH);
end

StateMachine.popState = function(self, style)
	if not StateMachine.canPop(self) then
		return ;
        --error("Error,no state in state stack\n");
	end
	if self.m_changeAnim then
        return ;
        --error("Error,is poping state in state stack\n");
    end
	local lastState = table.remove(self.m_states,#self.m_states);
	StateMachine.switchState(self,false,false,lastState,true,style,StateMachine.ISPOP);
end

---------------------------------private functions-----------------------------------------

StateMachine.ctor = function(self)
	self.m_states 			= {};
	self.m_lastState 		= nil;
	self.m_releaseLastState = false;
	self.m_changeAnim       = false;
	self.m_loadingAnim		= nil;
	self.m_isNewStatePopup	= false;

	StateMachine.m_styleFuncMap = {};
    --add switch anim
    self:registerSwitchAnim();
end

--Check if the current state is the new state and clean unloaded states
StateMachine.checkState = function(self, state)
	delete(self.m_loadingAnim);
	self.m_loadingAnim = nil;
	
	local lastState = self.m_states[#self.m_states];
	if not lastState then
		return true;
	end
	if lastState.state == state then
		return false;
	end

	local lastStateObj = lastState.stateObj;
	if lastStateObj:getCurStatus() <= StateStatus.Loaded then
		StateMachine.cleanState(self,lastState);
		self.m_states[#self.m_states] = nil;
		return StateMachine.checkState(self,state);
	else
		return true;
	end
end

StateMachine.getNewState = function(self, state, ...)
	local nextStateIndex;
	for i,v in ipairs(self.m_states) do 
		if v.state == state then
			nextStateIndex = i;
			break;
		end
	end
	
	local nextState;
	if nextStateIndex then
		nextState = table.remove(self.m_states,nextStateIndex);
	else
		nextState = {};
		nextState.state = state;
		nextState.stateObj = new(StatesMap[state],...);
	end
	
	return nextState,(not nextStateIndex);
end

StateMachine.canPop = function(self)
	if #self.m_states < 2 then
		return false;
	else
		return true;
	end
end

StateMachine.switchState = function(self, needLoadNewState, isNewStatePopup,
										lastState, needReleaseLastState,
										style,changeStyle)	

	self.m_isNewStatePopup = isNewStatePopup;

	self.m_lastState = lastState;
	self.m_releaseLastState = needReleaseLastState;
	self.m_style = style;
    self.m_changeStyle = changeStyle;

	StateMachine.pauseState(self,self.m_lastState);
	
	if needLoadNewState then
		self.m_loadingAnim = new(AnimInt,kAnimRepeat,0,1,1);
		self.m_loadingAnim:setEvent(self,StateMachine.loadAndRun);
        self.m_loadingAnim:setDebugName("StateMachine.loadingAnim");
	else
		StateMachine.run(self);
	end
end

StateMachine.loadAndRun = function(self)
	local stateObj = self.m_states[#self.m_states].stateObj;
	if stateObj:load() then
		delete(self.m_loadingAnim);
		self.m_loadingAnim = nil;
		stateObj:setStatus(StateStatus.Loaded);
		StateMachine.run(self);
	end
end

StateMachine.run = function(self)
	StateMachine.runState(self,self.m_states[#self.m_states]);
	
	local newStateObj = self.m_states[#self.m_states];
	if self.m_lastState and self.m_style and self.m_styleFuncMap[self.m_style] then	
        self.m_changeAnim = true;
		self.m_styleFuncMap[self.m_style](newStateObj,self.m_lastState,self,StateMachine.onSwitchEnd,self.m_changeStyle);
	else
		StateMachine.onSwitchEnd(self);
	end
end

StateMachine.onSwitchEnd = function(self)
    self.m_changeAnim = false;
	if self.m_lastState then
		if self.m_releaseLastState then
			StateMachine.cleanState(self,self.m_lastState);
		elseif self.m_isNewStatePopup then
		
		else
			self.m_lastState.stateObj:stop();
		end
	end

	self.m_lastState = nil;
	self.m_releaseLastState = false;

	local newState = self.m_states[#self.m_states].stateObj;
    local stateNum = self.m_states[#self.m_states].state;
	newState:resume();
    StateMachine.s_runState = stateNum;
end

StateMachine.cleanState = function(self, state)
	if not (state and state.stateObj) then
		return;
	end

	local obj = state.stateObj;
	for _,v in ipairs(State.s_releaseFuncMap[obj:getCurStatus()]) do
		obj[v](obj);
	end
	delete(obj);
end

StateMachine.runState = function(self, state)
	if not (state and state.stateObj) then
		return;
	end

	local obj = state.stateObj;
	if obj:getCurStatus() == StateStatus.Loaded 
		or obj:getCurStatus() == StateStatus.Stoped  then
		obj:run();
	end
end

StateMachine.pauseState = function(self, state)
	if not (state and state.stateObj) then
		return;
	end

	local obj = state.stateObj;
	if obj:getCurStatus() == StateStatus.Resumed then
		obj:pause();
	end
end



StateMachine.dtor = function(self)
	for i,v in pairs(self.m_states) do 
		StateMachine.cleanState(self,v);
	end
	
	self.m_states = {};
end


--------------------- add StateMachine anims -------------------

StateMachine.registerSwitchAnim = function(self)
    StateMachine.STYPE_LEFT_IN = self:registerStyle(self.leftInAnim);
    StateMachine.STYPE_REGHT_OUT = self:registerStyle(self.rightOutAnim);
    StateMachine.STYPE_WAIT = self:registerStyle(self.waitAnim);
    StateMachine.STYPE_FADE_IN = self:registerStyle(self.fadeInAnim);
    StateMachine.STYPE_FADE_OUT = self:registerStyle(self.fadeOutAnim);
    StateMachine.STYPE_CUSTOM_WAIT = self:registerStyle(self.customWaitAnim);

end;
--leftIn
StateMachine.leftInAnim = function(newStateObj,lastStateObj,switchObj,switchFn)
    local lastRoot = lastStateObj.stateObj.m_controller.m_view.m_root;
    local newRoot = newStateObj.stateObj.m_controller.m_view.m_root;
    lastRoot:addPropTranslate(1,kAnimNormal,300,-1,0,-100,nil,nil);
    local anim = newRoot:addPropTranslate(1,kAnimNormal,300,-1,System.getLayoutWidth(),0,nil,nil);
    if anim then
        anim:setEvent(self, function () 
            lastRoot:removeProp(1);
            newRoot:removeProp(1);
            switchFn(switchObj)
            delete(anim);
        end);
    end
end;

--rightOut
StateMachine.rightOutAnim = function(newStateObj,lastStateObj,switchObj,switchFn)
    local newRoot = newStateObj.stateObj.m_controller.m_view.m_root;
    local lastRoot = lastStateObj.stateObj.m_controller.m_view.m_root;
    newRoot:addPropTranslate(2,kAnimNormal,300,-1,-100,0,nil,nil);
    local anim = lastRoot:addPropTranslate(2,kAnimNormal,300,-1,0,System.getLayoutWidth(),nil,nil);
    if anim then
        anim:setEvent(self, function () 
            newRoot:removeProp(2);
            lastRoot:removeProp(2);
            switchFn(switchObj) 
            delete(anim); 
        end);
    end
end;

--渐显
StateMachine.fadeInAnim = function(newStateObj,lastStateObj,switchObj,switchFn)
    local lastRoot = lastStateObj.stateObj.m_controller.m_view.m_root;
    local newRoot = newStateObj.stateObj.m_controller.m_view.m_root;
    lastRoot:addPropTransparency(1,kAnimNormal,400,-1,1,0);
    local anim = newRoot:addPropTransparency(1,kAnimNormal,400,-1,0,1);
    if anim then
        anim:setEvent(self, function () 
            lastRoot:removeProp(1);
            newRoot:removeProp(1);
            switchFn(switchObj)
            delete(anim);
        end);
    end
end;

--渐失
StateMachine.fadeOutAnim = function(newStateObj,lastStateObj,switchObj,switchFn)
    local newRoot = newStateObj.stateObj.m_controller.m_view.m_root;
    local lastRoot = lastStateObj.stateObj.m_controller.m_view.m_root;
    newRoot:addPropTransparency(1,kAnimNormal,400,-1,0,1);
    local anim = lastRoot:addPropTransparency(1,kAnimNormal,400,-1,1,0);
    if anim then
        anim:setEvent(self, function () 
            newRoot:removeProp(2);
            lastRoot:removeProp(2);
            switchFn(switchObj)  
            delete(anim);
        end);
    end
end;

--等待
StateMachine.waitAnim = function(newStateObj,lastStateObj,switchObj,switchFn)
    local lastRoot = lastStateObj.stateObj.m_controller.m_view.m_root;
    local newRoot = newStateObj.stateObj.m_controller.m_view.m_root;
    newRoot:setVisible(false);
    local anim = new(AnimInt,kAnimNormal,0,1,400,-1);
    if anim then
        anim:setEvent(self, function () 
            newRoot:setVisible(true);
            switchFn(switchObj)
            delete(anim);
        end);
    end
end;
--自定义控件滑动1 需要在resume和pause时候写界面的左滑和右滑动画，隐藏动画控件方法, 游戏，发现，我的三个界面切换时需要重写界面移动方向
StateMachine.customWaitAnim = function(newStateObj,lastStateObj,switchObj,switchFn,changeStyle)
    local lastRoot = lastStateObj.stateObj.m_controller.m_view.m_root;
    local newRoot = newStateObj.stateObj.m_controller.m_view.m_root;

    local duration = 400; --切场动画时间
    local waitTime = 300; --竹叶和其他动画播放时间

    local lw,lh = lastStateObj.stateObj.m_controller.m_view:getSize();
    local nw,nh = newStateObj.stateObj.m_controller.m_view:getSize();
    if changeStyle and changeStyle == StateMachine.ISPUSH then
        lastRoot:addPropTranslate(1,kAnimNormal,duration,waitTime,0,-lw,nil,nil);
        newRoot:addPropTranslate(1,kAnimNormal,duration,waitTime,nw,0,nil,nil);
    elseif changeStyle and changeStyle == StateMachine.ISPOP then
        lastRoot:addPropTranslate(1,kAnimNormal,duration,waitTime,0,lw,nil,nil);
        newRoot:addPropTranslate(1,kAnimNormal,duration,waitTime,-nw,0,nil,nil);
    elseif changeStyle and changeStyle == StateMachine.ISCHANGE then
        lastRoot:addPropTranslate(1,kAnimNormal,duration,waitTime,0,lw,nil,nil);
        newRoot:addPropTranslate(1,kAnimNormal,duration,waitTime,-nw,0,nil,nil);
    else
        lastRoot:addPropTranslate(1,kAnimNormal,duration,waitTime,0,-lw,nil,nil);
        newRoot:addPropTranslate(1,kAnimNormal,duration,waitTime,nw,0,nil,nil);
    end

    local obj = {};
    obj.duration = duration;
    obj.waitTime = waitTime;
    if newStateObj.stateObj.m_controller.m_view.setAnimItemEnVisible then
        newStateObj.stateObj.m_controller.m_view.setAnimItemEnVisible(newStateObj.stateObj.m_controller.m_view,false);  
    end
    if newStateObj.stateObj.m_controller.m_view.resumeAnimStart then
        newStateObj.stateObj.m_controller.m_view.resumeAnimStart(newStateObj.stateObj.m_controller.m_view,lastStateObj,obj,changeStyle);  
    end
    if lastStateObj.stateObj.m_controller.m_view.pauseAnimStart then
        lastStateObj.stateObj.m_controller.m_view.pauseAnimStart(lastStateObj.stateObj.m_controller.m_view,newStateObj,obj,changeStyle);
    end
    delete(StateMachine.s_customWaitAnim);
    StateMachine.s_customWaitAnim = new(AnimInt,kAnimNormal,0,1,duration+waitTime,-1);
    if StateMachine.s_customWaitAnim then
        StateMachine.s_customWaitAnim:setEvent(self, function ()
            lastRoot:removeProp(1);
            newRoot:removeProp(1);
            switchFn(switchObj)
            delete(StateMachine.s_customWaitAnim);
        end);
    end
end;