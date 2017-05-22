--SociatyModuleData.lua
--Date 2016.8.30
--棋社相关数据
--endregion

SociatyModuleData = class()

SociatyModuleData.s_manager = nil

function SociatyModuleData.getInstance()
    if not SociatyModuleData.s_manager then 
		SociatyModuleData.s_manager = new(SociatyModuleData);
	end
	return SociatyModuleData.s_manager;
end

function SociatyModuleData.releaseInstance()
    delete(ChessSociatyModuleController.s_manager);
    SociatyModuleData.s_manager = nil
end

function SociatyModuleData.ctor(self)
    self.sociaty_data = {}
    self.sociaty_member_data = {}

end

function SociatyModuleData.dtor(self)
    
end

function SociatyModuleData.setSociatyData(self,data)
    self.sociaty_data = data
end

function SociatyModuleData.getSociatyData(self)
    return self.sociaty_data
end

function SociatyModuleData.setSociatyMemberData(self,data)
    self.sociaty_member_data = data
end

function SociatyModuleData.getSociatyMemberData(self)
    return self.sociaty_member_data or {}
end

function SociatyModuleData.clearSociatyMemberData(self)
    self.sociaty_member_data = {}
end

function SociatyModuleData.updataMemberData(self,data)
    if self.sociaty_data then
        if self.sociaty_data.member_num then
             self.sociaty_data.member_num = tonumber(self.sociaty_data.member_num) + data
             EventDispatcher.getInstance():dispatch(Event.Call,kSociaty_updataSociatyData,self.sociaty_data);
        end
    end
end

function SociatyModuleData.updataMemberInfo(self,data)
    local id = tonumber(data.uid) or 0 
    for k,v in pairs(self.sociaty_member_data) do 
        if v and v.mid == id then
            self.sociaty_member_data[k] = data
        end
    end
end
--[Comment]
-- 用于自己棋社信息查询
function SociatyModuleData.onCheckSociatyData(self,id)
    local id = tonumber(id)
    if not id then return end
    local params = {};
    local ret = {};
    ret.guild_id = id;
    params.param = ret;
    HttpModule.getInstance():execute2(HttpModule.s_cmds.getSociatyInfo,params,function(isSuccess,resultStr)--,httpRequest)
        if isSuccess then
            local jsonData = json.decode(resultStr)
            local errorMsg = jsonData.error
            if errorMsg then
                ChessToastManager.getInstance():showSingle(errorMsg or "棋社不存在") 
                return
            end
            local data = jsonData.data
            if type(data) ~= "table" then return end
            self:setSociatyData(data)
            EventDispatcher.getInstance():dispatch(Event.Call,kSociaty_updataSociatyData,self.sociaty_data);
        end
    end);
end
--[Comment]
-- 用于其他棋社信息查询
function SociatyModuleData.onCheckSociatyData2(self,id)
    local id = tonumber(id)
    if not id then return end
    local params = {};
    local ret = {};
    ret.guild_id = id;
    params.param = ret;
    HttpModule.getInstance():execute2(HttpModule.s_cmds.getSociatyInfo,params,function(isSuccess,resultStr)--,httpRequest)
        if isSuccess then
            local jsonData = json.decode(resultStr)
            local errorMsg = jsonData.error
            if errorMsg then
                ChessToastManager.getInstance():showSingle(errorMsg or "棋社不存在") 
                return
            end
            local data = jsonData.data
            if type(data) ~= "table" then return end
            self:setSociatyData(data)
            EventDispatcher.getInstance():dispatch(Event.Call,kSociaty_updataSociatyData2,self.sociaty_data);
        end
    end);
end

function SociatyModuleData.onModifySociatyData(self,data)
    --修改公会名称
    local name = data.name
    if name then
        self.sociaty_data.name = name
    end

    --修改公会公告
    local notice = data.notice
    if notice then
        self.sociaty_data.notice = notice
    end

    --修改公会徽章
    local icon_mark = tonumber(data.mark)
    if icon_mark then
        self.sociaty_data.mark = icon_mark
    end

    --修改公会加入方式
    local join_type = tonumber(data.join_type)
    if join_type then
        self.sociaty_data.join_type = join_type
    end

    --修改公会加入等级
    local join_min_level = tonumber(data.join_min_level)
    if join_min_level then
        self.sociaty_data.join_min_level = join_min_level
    end

    local mData = UserInfo.getInstance():getUserSociatyData()
    if mData and tonumber(self.sociaty_data.id) == tonumber(mData.guild_id) then
        local params = {}
        params.mark = self.sociaty_data.mark
        params.guild_name = self.sociaty_data.name
        UserInfo.getInstance():setUserSociatyData2(params)
    end
    EventDispatcher.getInstance():dispatch(Event.Call,kSociaty_modifySociatyData,self.sociaty_data);
end


function SociatyModuleData.updataSociatyMemberData(self,data)
    if not self.sociaty_member_data then 
        self.sociaty_member_data = {}
    end
    if not data or type(data) ~= "table" then return end
    if next(data) == nil then 
        
        return 
    end

--    local index = #self.sociaty_member_data
    for k,v in pairs(data) do 
        if v then
            table.insert(self.sociaty_member_data,v)
        end
    end
    EventDispatcher.getInstance():dispatch(Event.Call,kSociaty_updataSociatyMemberData,data)
end

function SociatyModuleData.deleteSociatyMember(self,id)
    if not self.sociaty_member_data then  return end
    if not id then return end
    for k,v in pairs(self.sociaty_member_data) do
        if v then
            local mid = tonumber(v.mid)
            if mid and mid == id then
                table.remove(self.sociaty_member_data,k);
                EventDispatcher.getInstance():dispatch(Event.Call,kSociaty_updataSociatyMemberData)
                return
            end
        end 
    end

--    EventDispatcher.getInstance():dispatch(Event.Call,kSociaty_updataSociatyMemberData,self.sociaty_member_data,data)
end

--function SociatyModuleData.addSociatyMember(self,id)
--    if not self.sociaty_member_data then  return end
--    if not id then return end
--    for k,v in pairs(self.sociaty_member_data) do
--        if v then
--            if v.id == id then
--                table.remove(self.sociaty_member_data,k);
--                return
--            end
--        end 
--    end

----    EventDispatcher.getInstance():dispatch(Event.Call,kSociaty_updataSociatyMemberData,self.sociaty_member_data,data)
--end