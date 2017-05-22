-- friendshipWarData.lua
-- Author: ChaoYuan
-- Date:   2017-05-12
-- Last modification : 2017-05-12
-- Description: 友谊战数据管理
require(BASE_PATH.."gameDataBase")
FriendshipWarData = class(GameDataBase,false)

function FriendshipWarData.ctor(self)
    self.mWarDatas = {}
end 

function FriendshipWarData.dtor(self)

end 

function FriendshipWarData.addWarData(self,datas)
    if not datas or type(datas)~="table" then 
        return nil
    end 
    for k,v in ipairs(datas) do 
        table.insert(self.mWarDatas,v)
    end 
    self.mWarDatas = FriendshipWarData.processData(self.mWarDatas)
    return self.mWarDatas
end 

--以优先级：等待应战->观战->结束重新排序数据
function FriendshipWarData.processData(datas)
    if not datas or type(datas)~="table" then 
        return nil
    end 
   
    local waitData = {}    --等待应战数据
    local watchData = {}   --观战数据
    local endData = {}     --结束数据
    for k,v in ipairs(datas) do 
        local other = json.decode(v.other)
        if other == nil then 
            table.insert(endData,v)
        else 
            if other.status then 
                if other.status == 1 then 
                    table.insert(waitData,v)
                elseif other.status == 3 then 
                    table.insert(watchData,v)
                else 
                    table.insert(endData,v)
                end  
            else 
                table.insert(endData,v)
            end 
        end 
    end 
    for k,v in ipairs(watchData) do 
        table.insert(endData,v)
    end 
    for k,v in ipairs(waitData) do 
        table.insert(endData,v)
    end 
    return endData
end 

function FriendshipWarData.deleteItem(self,id)
    if self.mWarDatas and id then 
        for k,v in pairs(self.mWarDatas) do 
            if v.msg_id and v.msg_id == id then 
                table.remove(self.mWarDatas,k)
                return 
            end 
        end 
    end 
end 