require("core/stateMachine");

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
		if StatesMap[state] and StatesMap[state][1] then
				require(StatesMap[state][1]);
				nextState.stateObj = new(_G[StatesMap[state][2]],...);
		end			
	end
		
	return nextState,(not nextStateIndex);
end

StateMachine.getCurrentState = function(self)
    return #self.m_states > 0 and self.m_states[#self.m_states].state or nil;
end

StateMachine.getCurrentController = function(self)
    return #self.m_states > 0 and self.m_states[#self.m_states].stateObj:getController() or nil;
end