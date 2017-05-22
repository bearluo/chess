--SociatyManagerDialog.lua
--Date 2016.8.29
--公会管理弹窗
--endregion

require(VIEW_PATH .. "sociaty_manager_dialog_view");
require(BASE_PATH.."chessDialogScene")
require("dialog/chioce_dialog");
require(MODEL_PATH .. "chessSociatyModule/chessSociatyModuleNode")
require(MODEL_PATH .. "chessSociatyModule/chessSociatyModuleIconNode")


SociatyManagerDialog = class(ChessDialogScene,false)

SociatyManagerDialog.s_member_node = 1;
SociatyManagerDialog.s_apply_node  = 2;

function SociatyManagerDialog.ctor(self)
    super(self,sociaty_manager_dialog_view)

    self.applyMsg = {}
    self.memberListNum = 0
    self.applyListNum = 0
    self.my_sociaty_data = UserInfo.getInstance():getUserSociatyData();
    self.guild_id = tonumber(self.my_sociaty_data.guild_id)

    self.m_root_view            = self.m_root
    self.m_dialog_bg            = self.m_root_view:getChildByName("view");
    self.m_close_btn            = self.m_dialog_bg:getChildByName("close_btn");
    self.m_close_btn:setOnClick(self,self.dismiss)

    self.m_sociaty_name         = self.m_dialog_bg:getChildByName("name_view"):getChildByName("text");
--    self.m_sociaty_member       = self.m_dialog_bg:getChildByName("member_view"):getChildByName("text");
    self.m_notice_input         = self.m_dialog_bg:getChildByName("notice_view"):getChildByName("input_text");
    self.m_notice_input:setHintText("公告不超过30个字",165,145,125);

--    self.m_select_join_type     = self.m_dialog_bg:getChildByName("join_type_view"):getChildByName("select_join_type");
    self.m_icon_list_view       = self.m_dialog_bg:getChildByName("manager_view"):getChildByName("modify_view"):getChildByName("icon_view"):getChildByName("icon_list_view");
    self.join_check_view        = self.m_dialog_bg:getChildByName("manager_view"):getChildByName("modify_view"):getChildByName("check_view");
    self.join_grade_view        = self.m_dialog_bg:getChildByName("manager_view"):getChildByName("modify_view"):getChildByName("grade_view");

    self.m_member_btn           = self.m_dialog_bg:getChildByName("manager_view"):getChildByName("member_btn");
    self.m_member_line          = self.m_member_btn:getChildByName("line");
    self.m_member_text          = self.m_member_btn:getChildByName("text");
    self.m_member_btn:setOnClick(self,self.onCheckMemberManager);

    self.m_apply_btn            = self.m_dialog_bg:getChildByName("manager_view"):getChildByName("apply_btn");
    self.m_apply_line           = self.m_apply_btn:getChildByName("line");
    self.m_apply_text           = self.m_apply_btn:getChildByName("text");
    self.m_apply_btn:setOnClick(self,self.onCheckApplyManager);

    self.m_modify_btn           = self.m_dialog_bg:getChildByName("manager_view"):getChildByName("set_btn");
    self.m_modify_line          = self.m_modify_btn:getChildByName("line");
    self.m_modify_text          = self.m_modify_btn:getChildByName("text");
    self.m_modify_btn:setOnClick(self,self.onCheckModifyManager);

    self.m_modify_info_btn      = self.m_dialog_bg:getChildByName("modify_btn");
    self.m_modify_info_btn:setOnClick(self,self.onModifySociatyInfo);

    self.m_member_list_view     = self.m_dialog_bg:getChildByName("manager_view"):getChildByName("member_list_view");
    self.m_apply_list_view      = self.m_dialog_bg:getChildByName("manager_view"):getChildByName("apply_list_view");
    self.m_modify_view          = self.m_dialog_bg:getChildByName("manager_view"):getChildByName("modify_view");

    self.m_member_lit = new(ScrollView,0,0,626,426,true)
    self.m_member_lit:setAlign(kAlignTop);
    self.m_member_list_view:addChild(self.m_member_lit);
    self.m_member_lit:setOnScrollEvent(self,self.onGetMemberInfo)

    self.m_apply_lit = new(ScrollView,0,0,626,426,true)
    self.m_apply_lit:setAlign(kAlignTop);
    self.m_apply_list_view:addChild(self.m_apply_lit);
    self.m_apply_lit:setOnScrollEvent(self,self.onGetApplyInfo)

    self.m_icon_list = new(ScrollView,0,0,450,110,true)
    self.m_icon_list:setAlign(kAlignLeft);
    self.m_icon_list:setDirection(kHorizontal);
    self.m_icon_list_view:addChild(self.m_icon_list);

--    self:initMemberList()
    self:initTextColor()
    self:initIconList()
    self:initModifyView();

    self:setShieldClick(self,self.dismiss)
    self.m_dialog_bg:setEventTouch(nil,function() end);
    self:setVisible(false);

    self.mDialogAnim = AnimDialogFactory.createMoveUpAnim(self)
end

function SociatyManagerDialog.dtor(self)
    delete(self.m_root_view)
    self.m_root_view = nil;
    delete(self.animInt)
    self.animInt = nil
    self.mDialogAnim.stopAnim()
end

function SociatyManagerDialog.show(self)
    EventDispatcher.getInstance():register(Event.Call,self,self.onNativeCallDone);
    SociatyModuleData.getInstance():clearSociatyMemberData()
    if self.m_member_lit then
        self.m_member_lit:removeAllChildren(true)
        self.memberListNum = 0
    end
    self.animInt = new(AnimInt,kAnimNormal, 0,1,400,-1)
    self.animInt:setEvent(self,function()
        self:getSociatyMember()
        delete(self.animInt)
        self.animInt = nil
    end)
    self:onCheckMemberManager()
    self.super.show(self,self.mDialogAnim.showAnim);
    self:setVisible(true);
end

function SociatyManagerDialog.dismiss(self)
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeCallDone);
    if self.obj and self.func  then
        self.func(self.obj)
    end
    self:setVisible(false);
    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
end

function SociatyManagerDialog.isShowing(self)
    return self:getVisible();
end

function SociatyManagerDialog.setCallBackFuc(self,obj,func)
    self.obj = obj
    self.func = func
end


function SociatyManagerDialog.onNativeCallDone(self ,param , ...)
	if self.s_nativeEventFuncMap[param] then
		self.s_nativeEventFuncMap[param](self,...);
	end
end

function SociatyManagerDialog.onGetApplyInfo(self,scroll_status,diff, totalOffset)
    local lvW, lvH = self.m_apply_lit:getSize();
    local trueOffset = self.applyListNum * ChessSociatyModuleNode.s_h - lvH;
    if totalOffset and trueOffset > 0 then
        if (math.abs(tonumber(totalOffset)) >  trueOffset + 50) then
            if not self.m_is_loading_apply then
                self.m_is_loading_apply = true;
                self:getApplyMsg(self.applyListNum); 
            end;
        elseif math.abs(tonumber(totalOffset)) > trueOffset then
            self.m_is_loading_apply = false;
        end;
    end;
end


function SociatyManagerDialog.onGetMemberInfo(self,scroll_status,diff, totalOffset)
    local lvW, lvH = self.m_member_lit:getSize();
    local trueOffset = self.memberListNum * ChessSociatyModuleNode.s_h - lvH;
    if totalOffset and trueOffset > 0 then
        if (math.abs(tonumber(totalOffset)) >  trueOffset + 50) then
            if not self.m_is_loading_suggest then
                self.m_is_loading_suggest = true;
                self:getSociatyMember(self.memberListNum); 
            end;
        elseif math.abs(tonumber(totalOffset)) > trueOffset then
            self.m_is_loading_suggest = false;
        end;
    end;
end

function SociatyManagerDialog.getSociatyMember(self,index)
    local ret = {};
    ret.guild_id = self.guild_id or 0;
    ret.limit = 10;
    ret.offset = index or 0;
    ChessSociatyModuleController.getInstance():onGetSociatyMemberInfo(ret)
end

function SociatyManagerDialog.onUpdateSociatyMemberList(self,data)
    if not data or type(data) ~= "table" then return end
    if self.m_member_lit then
        for k,v in pairs(data) do
            if v then
                self.memberListNum = self.memberListNum + 1
                v.guild_id = self.guild_id 
                local node_type = ChessSociatyModuleNode.s_member_mode
                local role = tonumber(self.my_sociaty_data.guild_role) or 3
                if role and role == 2 then
                    node_type = ChessSociatyModuleNode.s_vice_mode
                end
                local node = new(ChessSociatyModuleNode,v,node_type,self)
                self.m_member_lit:addChild(node);
            end
        end
    end
end

--[Comment]
--设置管理弹窗棋社数据
function SociatyManagerDialog.onUpdateSociatyData(self,data)
    if not data then return end
    self.sociatyData = data
    self.guild_id = tonumber(self.sociatyData.id)
    self.m_sociaty_name:setText(self.sociatyData.name or "");

--    local member_num = self.sociatyData.member_num or "1"
--    local max_num = self.sociatyData.max_member or "30"
--    self.m_sociaty_member:setText(member_num .. "/" .. max_num);

    if self.sociatyData.notice and self.sociatyData.notice ~= "" then
        self.m_notice_input:setText(self.sociatyData.notice)
    end

    local levelLimit = tonumber(self.sociatyData.join_min_level)
    if not levelLimit or levelLimit == 0 then
        levelLimit = 1
    end
    self.grade_list:setIndex(10 - levelLimit)

    local joinType = tonumber(self.sociatyData.join_type) or 3
    self.check_list:setIndex(joinType - 1)


    local mark = tonumber(self.sociatyData.mark) or 10
    for k,v in pairs(self.icon_node_tab) do
        if v then
            if k == mark then
                self.select_index = k
                v:setSelectStatus(true)
            else
                v:setSelectStatus()
            end
        end
    end
end

--[Comment]
--初始化棋社图标
function SociatyManagerDialog.initIconList(self)
    if not self.m_icon_list then return end
    self.icon_node_tab = {}
    for k,v in pairs(ChesssociatyModuleConstant.sociaty_icon) do
        if v then
            local node = new(ChessSociatyModuleIconNode,v,self,k)
            table.insert(self.icon_node_tab,node)
            self.m_icon_list:addChild(node)
        end
    end
end

--[Comment]
--初始化按钮颜色
function SociatyManagerDialog.initTextColor(self)
    self.m_member_text:setColor(215,75,45)
    self.m_apply_text:setColor(135,100,95)
    self.m_modify_text:setColor(135,100,95)
end


--[Comment]
--选择图标后更新图标列表状态
function SociatyManagerDialog.updataSelectStatus(self,index)
    if not self.icon_node_tab then return end
    self.select_index = 10
    if index then self.select_index = index end
    for k,v in pairs(self.icon_node_tab) do
        if v then
            if k ~= self.select_index then
                v:updataSelectStatus()
            end
        end
    end
end

function SociatyManagerDialog.initMemberList(self)
    local memberData = SociatyModuleData.getInstance():getSociatyMemberData()
    if not memberData or type(memberData) ~= "table" then return end
    if self.m_member_lit then
        self.m_member_lit:removeAllChildren(true)
    end
    for k,v in pairs(memberData) do
        if v then
            self.memberListNum = self.memberListNum + 1
            v.guild_id = self.guild_id 
            local node_type = ChessSociatyModuleNode.s_member_mode
            local role = tonumber(self.my_sociaty_data.guild_role) or 3
            if role and role == 2 then
                node_type = ChessSociatyModuleNode.s_vice_mode
            end
            local node = new(ChessSociatyModuleNode,v,node_type,self)
            self.m_member_lit:addChild(node);
        end
    end
end

function SociatyManagerDialog.resetMemberList(self)
    if self.m_member_lit then
        self.m_member_lit:removeAllChildren(true);
    end
    self:getSociatyMember()
end

--[Comment]
--获得棋社申请信息
function SociatyManagerDialog.getApplyMsg(self,offset)
    if not self.sociatyData then return end
    if not offset then 
        self.isFirstSend = true 
    else
        self.isFirstSend = false 
    end
    local tab = {}
    tab.guild_id = self.sociatyData.id 
    tab.limit = 10
    tab.offset = offset or 0;
    local post = {}
    post.param = tab
    HttpModule.getInstance():execute2(HttpModule.s_cmds.getSociatyApplyMsg,post,function(isSuccess,resultStr)--,httpRequest)
        if isSuccess then
            local jsonData = json.decode(resultStr)
            local data = jsonData.data
            if type(data) ~= "table" then return end
            if next(data) == nil then return end
            if not self.m_apply_lit then return end
            if self.isFirstSend then
                self.applyMsg = {}
                self.applyListNum = 0
                self.m_apply_lit:removeAllChildren(true)
            end
            for k,v in pairs(data) do
                if v then
                    self.applyListNum = self.applyListNum + 1
                    v.guild_id = self.guild_id 
                    table.insert(self.applyMsg,v)
                    local node = new(ChessSociatyModuleNode,v,ChessSociatyModuleNode.s_apply_mode,self)
                    self.m_apply_lit:addChild(node)
                end
            end
        end
    end);
end

--[Comment]
--踢出成员/管理申请
function SociatyManagerDialog.delMemberTab(self,nodeType,nodeHandler,id)
    if not nodeType or not nodeHandler then return end
    if nodeType == ChessSociatyModuleNode.s_member_mode or nodeType == ChessSociatyModuleNode.s_vice_mode then
        self.m_member_lit:removeChild(nodeHandler,true)
        self.m_member_lit:updateScrollView()
        if self.memberListNum > 0 then
            self.memberListNum = self.memberListNum - 1
        end
        SociatyModuleData.getInstance():deleteSociatyMember(id)
    elseif nodeType == ChessSociatyModuleNode.s_apply_mode then
        self.m_apply_lit:removeChild(nodeHandler,true)
        self.m_apply_lit:updateScrollView()
        for k,v in pairs(self.applyMsg) do
            if v then
                if tonumber(v.mid) == id then
                    table.remove(self.applyMsg,k);
                    if self.memberListNum > 0 then
                        self.applyListNum = self.applyListNum - 1
                    end
                    return
                end
            end 
        end
    end
end

function SociatyManagerDialog.updataSociatyMember(self,num)
    
end

--[Comment]
--切换到成员列表
function SociatyManagerDialog.onCheckMemberManager(self)
    self.m_member_btn:setEnable(false)
    self.m_modify_btn:setEnable(true)
    self.m_apply_btn:setEnable(true)
    self.m_member_line:setVisible(true);
    self.m_apply_line:setVisible(false);
    self.m_modify_line:setVisible(false);
    self.m_member_text:setColor(215,75,45)
    self.m_apply_text:setColor(135,100,95)
    self.m_modify_text:setColor(135,100,95)
    self.m_member_list_view:setVisible(true);
    self.m_apply_list_view:setVisible(false);
    self.m_modify_view:setVisible(false)
end

--[Comment]
--切换到申请列表
function SociatyManagerDialog.onCheckApplyManager(self)
    self.m_member_btn:setEnable(true)
    self.m_modify_btn:setEnable(true)
    self.m_apply_btn:setEnable(false)
    self.m_member_line:setVisible(false);
    self.m_apply_line:setVisible(true);
    self.m_modify_line:setVisible(false);
    self.m_member_text:setColor(135,100,95)
    self.m_apply_text:setColor(215,75,45)
    self.m_modify_text:setColor(135,100,95)
    self.m_member_list_view:setVisible(false);
    self.m_apply_list_view:setVisible(true);
    self.m_modify_view:setVisible(false)
    self:getApplyMsg()
end

--[Comment]
--切换到修改界面
function SociatyManagerDialog.onCheckModifyManager(self)
    self.m_member_btn:setEnable(true)
    self.m_apply_btn:setEnable(true)
    self.m_modify_btn:setEnable(false)
    self.m_member_line:setVisible(false);
    self.m_apply_line:setVisible(false);
    self.m_modify_line:setVisible(true);
    self.m_member_text:setColor(135,100,95)
    self.m_apply_text:setColor(135,100,95)
    self.m_modify_text:setColor(215,75,45)
    self.m_member_list_view:setVisible(false);
    self.m_apply_list_view:setVisible(false);
    self.m_modify_view:setVisible(true)
end

--[Comment]
--修改社团信息
function SociatyManagerDialog.onModifySociatyInfo(self)
    local notice = self.m_notice_input:getText() or ""
    --判断notice是否超过30
    local slen,cn,en = ToolKit.utf8_len(notice)
    local len = slen or 0
    if cn and en then
        len = cn * 2 + en
    end
    if len > 30 then
        ChessToastManager.getInstance():showSingle("公告内容过长，请修改")
        return
    end

    local review = self.check_list:getSelectIndex()
    local grade = self.grade_list:getSelectIndex()

    self.m_member_list_view:setVisible(false);
    self.m_apply_list_view:setVisible(true);

    local ret = {};
    ret.notice = notice
    if self.select_index then
        ret.mark = self.select_index
    end
--    ret.mark = self.select_index or 10
    ret.guild_id = self.guild_id or 0   
    ret.join_type = review + 1
    ret.join_min_level = 10 - grade 
    ChessSociatyModuleController.getInstance():onModifySociatyInfo(ret)
    self:dismiss()
end

--[Comment]
--初始化修改棋社界面
function SociatyManagerDialog.initModifyView(self)
    local check_plist = {"需要审批","无需审批"}
    local grade_plist = {"无限制","8级及以上","7级及以上","6级及以上","5级及以上","4级及以上","3级及以上","2级及以上","1级及以上"}
    self.check_list = new(SwitchSelectNode,check_plist)
    self.check_list:setPos(136,0)
    self.check_list:setIndex(2)
    self.join_check_view:addChild(self.check_list);
    self.grade_list = new(SwitchSelectNode,grade_plist)
    self.grade_list:setPos(136,0)
    self.grade_list:setIndex(1)
    self.join_grade_view:addChild(self.grade_list);
end

SociatyManagerDialog.s_nativeEventFuncMap = {
    [kSociaty_updataSociatyData]         = SociatyManagerDialog.onUpdateSociatyData;
    [kSociaty_updataSociatyMemberData]   = SociatyManagerDialog.onUpdateSociatyMemberList;
}