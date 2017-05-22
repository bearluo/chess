--region NewFile_1.lua
--Author : FordFan
--Date   : 2015/10/14
-- 选择城市弹窗
--endregion
require(VIEW_PATH .. "city_locate_pop_dialog");
require(BASE_PATH .."chessDialogScene");
require(DATA_PATH .. "cityData");

CityLocatePopDialog = class(ChessDialogScene,false);

--CityLocatePopDialog.labelData = 
--{
--    {name = "热门城市", itemtype = 1, labeltype = 1},
--    {name = "全部城市", itemtype = 1, labeltype = 2},
--}

--CityLocatePopDialog.hotCityData = 
--{
--    {name = "北京市", code = "110000"},
--    {name = "上海市", code = "310000"},
--    {name = "广州市", code = "440100",procode = "440000"},
--    {name = "深圳市", code = "440300",procode = "440000"},
--}

--otherCity = 
--{
--    {name = "香港", code = "011",itemtype = 2},
--    {name = "台湾", code = "012",itemtype = 2},
--    {name = "澳门", code = "013",itemtype = 2},
--    {name = "海外", code = "020",itemtype = 2},
--}
-- itemtyope = 1 表示标签   =2 表示省级标签
CityLocatePopDialog.ctor = function(self)
    super(self,city_locate_pop_dialog);
    self.m_root_view = self.m_root;
    self.m_bg = self.m_root_view:getChildByName("bg");
    self:setShieldClick(self,self.dismiss);
    self.m_bg:setEventTouch(self.m_bg,function() end);

    self.m_confirm_btn = self.m_bg:getChildByName("confirm");
    self.m_confirm_btn:setOnClick(self,self.onConfirm);
    self.m_close_btn = self.m_bg:getChildByName("close_btn");
    self.m_close_btn:setOnClick(self,self.dismiss);

    self.m_area_view = self.m_bg:getChildByName("area_view");
    self.m_city_view = self.m_bg:getChildByName("city_view");

    local w,h = self.m_area_view:getSize();
    self.m_area_picker = new(ScrollPicker,0,0,w,h);
    self.m_area_picker:setChangeIndexClick(self,self.changeArea);
    self.m_area_view:addChild(self.m_area_picker);
    self.m_area_picker:setChangeFunc(self,self.changeFunc);

    local w,h = self.m_city_view:getSize();
    self.m_city_picker = new(ScrollPicker,0,0,w,h);
    self.m_city_picker:setChangeIndexClick(self,self.changeCity);
    self.m_city_view:addChild(self.m_city_picker);
    self.m_city_picker:setChangeFunc(self,self.changeFunc);
    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
end

CityLocatePopDialog.dtor = function(self)
    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpRequestsCallBack);
end

CityLocatePopDialog.changeFunc = function(self,view,selected)
    if selected then
        if not view:checkAddProp(1) then
            view:removeProp(1);
        end

        if view:checkAddProp(2) then
            view:addPropScale(2,kAnimNormal, 200, -1, 0.8, 1, 0.8, 1, kCenterDrawing);
            view:setColor(80,80,80);
--            view:setTransparency(0.8);
        end
    else
        if not view:checkAddProp(2) then
            view:removeProp(2);
        end

        if view:checkAddProp(1) then
            view:addPropScale(1,kAnimNormal, 200, -1, 1, 0.8, 1, 0.8, kCenterDrawing);
            view:setColor(120,120,120);
--            view:setTransparency(1);
        end
    end
end

CityLocatePopDialog.changeArea = function(self,index)
    local selectIndex = self.m_area_picker:getSelectIndex();
    if index > 0 then
        self.m_cityData = CityData.getInstance():getCityData(self.m_provinceData[selectIndex].code);
        self.provinceCode = self.m_provinceData[selectIndex].code;
        self.provinceName = self.m_provinceData[selectIndex].name;
        if self.m_cityData then
            self.m_cityAdapter = new(CityLocatePopDialogScrollPickerAdapter,self.m_cityData);
            self.m_city_picker:setAdapter(self.m_cityAdapter);
            self:changeCity(self.m_city_picker:getSelectIndex());
        end
    end
end

CityLocatePopDialog.changeCity = function(self,index)
    local selectIndex = self.m_city_picker:getSelectIndex();
    if index > 0 then
        self.cityCode = self.m_cityData[selectIndex].code;
        self.cityName = self.m_cityData[selectIndex].name;
    end
end

CityLocatePopDialog.loadList = function(self)
    self.m_provinceData = CityData.getInstance():getProvinceData();
    if not self.m_provinceData then return end

    local code = GameCacheData.getInstance():getInt(GameCacheData.LOCATE_CITY_CODE,self.saveCode);
    local nowCity =  nil;
    local preData = self.m_provinceData;
    self.m_provinceData = {};
    for _,city in ipairs(preData) do
        if code == city.code then
            nowCity = city;
        else
            self.m_provinceData[#self.m_provinceData+1] = city;
        end
    end

    if nowCity then
        table.insert(self.m_provinceData,1,nowCity);
    end
    
    self.m_area_picker:removeAllChildren();
    delete(self.m_privinceAdapter);
    self.m_city_picker:removeAllChildren();
    delete(self.m_cityAdapter);

    self.m_privinceAdapter = new(CityLocatePopDialogScrollPickerAdapter,self.m_provinceData);
    self.m_area_picker:setAdapter(self.m_privinceAdapter);
    self:changeArea(self.m_area_picker:getSelectIndex());

end

CityLocatePopDialog.show = function(self,room)
    self.m_room = room;
    self:loadList();
    kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
    for i = 1,3 do 
        if not self.m_bg:checkAddProp(i) then
            self.m_bg:removeProp(i);
        end 
    end
    local w,h = self.m_bg:getSize();
    local anim = self.m_bg:addPropTranslateWithEasing(1,kAnimNormal, 400, -1, nil, "easeOutBounce", 0,0, h, -h);
    if anim then
        anim:setEvent(self,function()
            self.m_bg:removeProp(1);
        end);
    end
    self:setVisible(true);
    self.super.show(self,false);
end;


CityLocatePopDialog.dismiss = function(self)
    local w,h = self.m_bg:getSize();
    for i = 1,3 do 
        if not self.m_bg:checkAddProp(i) then
            self.m_bg:removeProp(i);
        end 
    end
    local anim = self.m_bg:addPropTranslate(2,kAnimNormal,300,-1,0,0,0,h);
    self.m_bg:addPropTransparency(3,kAnimNormal,200,-1,1,0);
    anim:setEvent(self,
    function()
        self:setRootUnVisible();
        self.m_bg:removeProp(2);
        self.m_bg:removeProp(3);
    end);
    self.super.dismiss(self,false);
end

CityLocatePopDialog.setDismissCallBack = function(self,obj,func)
    self.m_dismissEventCallBack = {};
    self.m_dismissEventCallBack.obj = obj;
    self.m_dismissEventCallBack.func = func;
end


CityLocatePopDialog.setRootUnVisible = function(self)
    self:setVisible(false);
    if self.m_dismissEventCallBack and self.m_dismissEventCallBack.func then
        self.m_dismissEventCallBack.func(self.m_dismissEventCallBack.obj);
    end
end

CityLocatePopDialog.onCancel = function(self)
    self:dismiss();
end

CityLocatePopDialog.onConfirm = function(self)
--    if self.cityName then
--        local str = "";
--        if not self.provinceCode then
--            if self.cityCode == 440100 or self.cityCode == 440300 then
--                self.saveCode = 440000;
--                self.saveStr = "广州";
--            else
--                self.saveCode = self.cityCode;
--                self.saveStr = self.cityName;
--            end
--            str = ToolKit.utf8_sub(self.saveStr,1,2);
--        end

        if self.provinceCode then
            self.saveCode = self.provinceCode;
            self.saveStr = self.provinceName;
            if self.provinceCode == 150000 or self.provinceCode == 230000 then
                self.saveStr = ToolKit.utf8_sub(self.saveStr,1,3);
            else 
                self.saveStr = ToolKit.utf8_sub(self.saveStr,1,2);
            end     
            -- 上传php省份代码
            local post_data = {};
            post_data.province_code = self.provinceCode;
	        post_data.city_code = self.cityCode;
            local tip = "更新中...";
            HttpModule.getInstance():execute(HttpModule.s_cmds.saveUserInfo,post_data,tip);
        end
--    end
        self:dismiss();
end

CityLocatePopDialog.onSaveUserInfoCityResponse = function(self,isSuccess,message)
    if isSuccess then
        if not self.saveStr or not self.saveCode then
            return
        end

        UserInfo.getInstance():setCityCode(self.saveCode);
        UserInfo.getInstance():setCityName(self.saveStr);

        GameCacheData.getInstance():saveString(GameCacheData.LOCATE_CITY_NAME,self.saveStr);
        GameCacheData.getInstance():saveInt(GameCacheData.LOCATE_CITY_CODE,self.saveCode);

        if self.m_room and self.m_room.m_chat_room_tittle then
            self.m_room.m_chat_room_tittle:setText(self.saveStr .. "棋友聊天室");
        elseif self.m_room and self.m_room.setCityName then
            self.m_room:setCityName(self.saveStr);
        end

        if self.m_confirmEventCallBack and self.m_confirmEventCallBack.func then
            self.m_confirmEventCallBack.func(self.m_confirmEventCallBack.obj);
        end
    end;
end;

CityLocatePopDialog.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.saveUserInfo]    = CityLocatePopDialog.onSaveUserInfoCityResponse;
};


CityLocatePopDialog.onHttpRequestsCallBack = function(self,command,...)
	Log.i("CityLocatePopDialog.onHttpRequestsCallBack");
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self,...);
	end 
end

function CityLocatePopDialog:setConfirmCallBack(obj,func)
    self.m_confirmEventCallBack = {};
    self.m_confirmEventCallBack.obj = obj;
    self.m_confirmEventCallBack.func = func;
end

-------------------------------------------------------------
CityLocatePopDialogScrollPickerAdapter = class(ScrollPickerAdapter);

CityLocatePopDialogScrollPickerAdapter.ctor = function(self,data)
    self.m_datas = data;
    self.m_views = {};
end

CityLocatePopDialogScrollPickerAdapter.dtor = function(self)
    for i,v in ipairs(self.m_views) do
        delete(v);
    end
end

CityLocatePopDialogScrollPickerAdapter.getView = function(self,position,convertView,parent)
    local w,h = parent:getSize();
    if not self.m_views[position] then
        self.m_views[position] = new(Text,self.m_datas[position].name, w, 60, kAlignCenter, nil, 40,80,80,80);
    end
    return self.m_views[position];
end

---------------------------- 