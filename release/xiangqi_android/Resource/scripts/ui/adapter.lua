-- adapter.lua
-- Author: Vicent.Gong
-- Date: 2012-05-17
-- Last modification : 2013-07-01
-- Description: Implemented an adapter,which now is for listView and ViewPager

require("core/object");

---------------------------------------------------------------------------------------------
--------------------------[INTERFACE] AdapterDataChangeListener------------------------------
---------------------------------------------------------------------------------------------

AdapterDataChangeListener = class();

AdapterDataChangeListener.onAppendData = function(self)
	
end

AdapterDataChangeListener.onChangeData = function(self)
	
end

AdapterDataChangeListener.onUpdateData = function(self,index)
	
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] Adapter-------------------------------------------
---------------------------------------------------------------------------------------------

Adapter = class();

Adapter.ctor = function(self, view, data)
	self.m_view = view;
	self.m_data = data;
end

Adapter.setEventListener = function(self, listener)
	self.m_listener = listener;
end

Adapter.getData = function(self)
	return self.m_data;
end

Adapter.appendData = function(self, data)
	for _,v in pairs(data) do
		self.m_data[#self.m_data+1] = v;
	end

	if self.m_listener and self.m_listener.onAppendData  then
		self.m_listener.onAppendData(self.m_listener);
	end
end

Adapter.changeData = function(self, data)
	self.m_data = data;

	if self.m_listener and self.m_listener.onChangeData  then
		self.m_listener.onChangeData(self.m_listener);
	end
end

Adapter.updateData = function(self, index, dataItem)
	self.m_data[index] = dataItem;

	if self.m_listener and self.m_listener.onUpdateData  then
		self.m_listener.onUpdateData(self.m_listener,index);
	end
end

Adapter.getView = function(self, index)
    if not self.m_data[index] then
        return nil;
    end
	local view =  new(self.m_view,self.m_data[index]);
	return view;
end

Adapter.releaseView = function(self, v)
	delete(v);
end

Adapter.getCount = function(self)
    return #self.m_data;
end

Adapter.dtor = function(self)
	self.m_view = nil;
	self.m_data = nil;
end

---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] Adapter-------------------------------------------
---------------------------------------------------------------------------------------------

CacheAdapter = class(Adapter)

CacheAdapter.ctor = function(self, view, data)
	self.m_views = {};
	self.m_changedItems = {};
end

CacheAdapter.perloadAll = function(self)
	for i=1,self:getCount() do 
		self:getView(i);
	end
end

CacheAdapter.updateData = function(self, index, dataItem)
	if self.m_views[index] then
		self.m_changedItems[ self.m_views[index] ] = index;
	end
	
	Adapter.updateData(self,index,dataItem);
end

CacheAdapter.changeData = function(self, data)
	for k,v in pairs(self.m_views) do 
		self.m_changedItems[v] = k;
	end

	Adapter.changeData(self,data);
end

CacheAdapter.getView = function(self, index)
	local view = self.m_views[index];

	if view and self.m_changedItems[view] then
		self.m_changedItems[view] = nil;
		delete(view);
		self.m_views[index] = nil
	end

    if self.m_views[index] then 
        self.m_views[index]:setVisible(true);
    else
		self.m_views[index] =  Adapter.getView(self,index);
	end

	return self.m_views[index];
end

CacheAdapter.releaseView = function(self, v)	
	local index = self.m_changedItems[v];
	if index then
		self.m_changedItems[v] = nil;
		delete(v);
		self.m_views[index] = nil;
	else
		v:setVisible(false);
	end
end

CacheAdapter.dtor = function(self)
    for _,v in pairs(self.m_views) do 
        delete(v);
    end

    self.m_views = {};
    self.m_changedItems = {};
end

----bearluo ---
CacheAdapter.isHasView = function(self,index)
    if self.m_views then
        return self.m_views[index] and true or false;
    end
    return false
end