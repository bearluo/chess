require("core/sceneLoader")


function editor_loadCustom(t)
	local node;
	if t.customName == "Custom" then
		node = new(Custom);
		SceneLoader.setBaseInfo(node,t);
		return node;
	end
	return node;
end

Custom = class(Node);

Custom.ctor = function(self)
end

Custom.dtor = function(self)
end
