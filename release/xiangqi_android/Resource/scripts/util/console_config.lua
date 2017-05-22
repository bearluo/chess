
require("dialog/leave_tips_dialog");
require("model/exchange_model");

ConsoleConfig = {};

ConsoleConfig.ctor = function (self,obj)
	print_string("ConsoleConfig.ctor");
	self.m_obj = obj;
end

ConsoleConfig.dtor = function(self)
	print_string("ConsoleConfig.dtor");
end

ConsoleConfig.getInstance = function ()
	if not ConsoleConfig.s_instance then
		ConsoleConfig.s_instance = new(ConsoleConfig);
	end
	return ConsoleConfig.s_instance;
end

ConsoleConfig.setIsPasslayer= function(self,ispass)
	self.m_ispass = ispass;
end

ConsoleConfig.getIsPasslayer = function(self)
	return self.m_ispass or false;
end


ConsoleConfig.setMaxPasslayer= function(self,layer)
	self.m_pass_layer = layer;
end

ConsoleConfig.getMaxPasslayer = function(self)
	return self.m_pass_layer or 0;
end
