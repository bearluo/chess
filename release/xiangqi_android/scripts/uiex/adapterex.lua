require("ui/adapter");

Adapter.getTmpView = function(self, index)
    return nil;
end

CacheAdapter.getTmpView = function(self,index)
    local view = self.m_views[index];

	if view and self.m_changedItems[view] then
		self.m_changedItems[view] = nil;
		delete(view);
		self.m_views[index] = nil
	end

    if not self.m_views[index] then 
		self.m_views[index] =  Adapter.getView(self,index);
		self.m_views[index]:setVisible(false);
	end

	return self.m_views[index];
end