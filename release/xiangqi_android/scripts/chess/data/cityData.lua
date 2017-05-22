--region NewFile_1.lua
--Author : FordFan
--Date   : 2015/10/14
--城市信息
--endregion
require("util/game_cache_data");

CityData = class(GameCacheData,false);

CityData.ctor = function(self)
    self.m_dict = new(Dict,"city_data");
    self.m_dict:load();
end

CityData.getInstance = function()
    if not CityData.instance then
		CityData.instance = new(CityData);
	end
	return CityData.instance; 
end

CityData.dtor = function(self)

end

CityData.saveData = function(self,data)
    self.allCityData = data;
    local allCityData = json.encode(data);
    self:saveString(GameCacheData.ALL_CITY_DATA,allCityData);
    self:saveProvinceData(data);
end

CityData.getAllCityData = function(self)
    if not self.allCityData then
        local jsondata = self:getString(GameCacheData.ALL_CITY_DATA,nil);
        self.allCityData = json.decode(jsondata);
    end
    return self.allCityData;
end

CityData.saveProvinceData = function(self,data)
    local provinceData = {};
    for _,v in pairs(data) do 
        local item = {};
        item.name = v.name;
        item.code = v.code;
        table.insert(provinceData,item);
    end
    self.provinceData = provinceData;
    self:saveString(GameCacheData.PROVINCE_DATA,json.encode(provinceData));
end

CityData.getProvinceData = function(self)
    if not self.provinceData then
        local data = self:getString(GameCacheData.PROVINCE_DATA,"");
        self.provinceData = json.decode(data);
        if not self.provinceData then
            local params = {};
            params.file_version = 0;
            HttpModule.getInstance():execute(HttpModule.s_cmds.getCityConfig,params);
        end
    end
    return self.provinceData ;
end

CityData.getProvinceName = function(self, code)
    local provinceData = self:getProvinceData();
    local provinceName;
    for _,v in pairs(provinceData) do
        if v.code == code then
            provinceName = v.name;
            return provinceName;
        end;
    end;
end;

CityData.getCityData = function(self,code)
    local cityData = {};
    local tempTable = {};
    local allCityData = self:getAllCityData();
    for _,v in pairs(allCityData) do
        if v.code == code then
            tempTable = v.city;
            break;
        end
    end
    
    for _,v in pairs(tempTable) do
        local item = {};
        item.name = v.name;
        item.code = v.code;
        table.insert(cityData,item);
    end

    return cityData;
end