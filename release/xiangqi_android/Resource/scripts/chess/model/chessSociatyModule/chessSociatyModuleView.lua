--ChessSociatyModuleView.lua
--Date 2016.8.22
--棋社界面
--endregion
require("dialog/create_and_check_sociaty_dialog");
require("dialog/sociaty_manager_dialog");
require("dialog/chioce_dialog");
require("dialog/user_info_dialog2")
require(DIALOG_PATH.."create_room_dialog");
require(VIEW_PATH.."sociaty_view")
require(MODEL_PATH .. "chessSociatyModule/chessSociatyModuleConstant")
require("chess/include/downLoadingScrollView");


ChessSociatyModuleView = class()

ChessSociatyModuleView.mode_join = 2;   --加入棋社状态
ChessSociatyModuleView.mode_unJoin = 1; --未加入棋社状态

ChessSociatyModuleView.s_event = {
    Refresh = EventDispatcher.getInstance():getUserEvent();
}

ChessSociatyModuleView.s_cmds = 
{
    searchCallBack                  = 1;
    recommendCallBack               = 2;
    createSociatyCallBack           = 3;
--    applyJoinSociatyCallBack        = 4;
    modifySociatyInfoCallBack       = 5;
--    getSociatymemberInfoCallBack    = 5;
}


function ChessSociatyModuleView.ctor(self,scene)
    self.mScene = scene
    self.m_root_node = SceneLoader.load(sociaty_view)
    self.mScene.m_sociaty_view:addChild(self.m_root_node);
    self.s_view_mode = ChessSociatyModuleView.mode_unJoin
    self:initView()
end

function ChessSociatyModuleView.resume(self)
    if not self.mRegister then
        self.mRegister = true
        EventDispatcher.getInstance():register(ChessSociatyModuleView.s_event.Refresh,self,self.refreshView);
        EventDispatcher.getInstance():register(Event.Call,self,self.onNativeCallDone);
    end
    self:setSelfSociatyData(UserInfo.getInstance():getUserSociatyData())
end

function ChessSociatyModuleView.pause(self)
    if self.mRegister then
        self.mRegister = false
        EventDispatcher.getInstance():unregister(ChessSociatyModuleView.s_event.Refresh,self,self.refreshView);
        EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeCallDone);
    end
end

function ChessSociatyModuleView.onNativeCallDone(self ,param , ...)
	if self.s_nativeEventFuncMap[param] then
		self.s_nativeEventFuncMap[param](self,...);
	end
end

function ChessSociatyModuleView.setBackAction(self,obj,func)
	self.backObj = obj
	self.backFunc = func
end

function ChessSociatyModuleView.onBack(self)
    if self.backObj and type(self.backFunc) == "function" then
          self.backFunc(self.backObj)
    end
end

function ChessSociatyModuleView.getRootNode(self)
    return self.m_root_node
end



function ChessSociatyModuleView.dtor(self)
    delete(self.m_sociaty_dialog)
    self.m_sociaty_dialog = nil;
    delete(self.m_sociaty_manager_dialog)
    self.m_sociaty_manager_dialog = nil;
    delete(self.m_userInfo_dialog)
    self.m_userInfo_dialog = nil;
    delete(self.m_createroom_dialog)
    self.m_createroom_dialog = nil;
    delete(self.m_chioce_dialog)
    self.m_chioce_dialog = nil;
    delete(self.m_root_node)
    delete(self.m_invite_dialog)
    if self.mRegister then
        self.mRegister = false
        EventDispatcher.getInstance():unregister(ChessSociatyModuleView.s_event.Refresh,self,self.refreshView);
        EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeCallDone);
    end
end

--[Comment]
--根据状态初始化棋社界面
function ChessSociatyModuleView.initView(self)
    --棋社推荐界面
    self.m_recommend_view = self.m_root_node:getChildByName("recommend_view")
    self.m_recommend_view:setVisible(false)
    self.title_view = self.m_recommend_view:getChildByName("title")
    self.title_text = self.title_view:getChildByName("title_text")
    self.back_btn = self.title_view:getChildByName("back_btn")
    self.back_btn:setOnClick(self,self.onBack)

    self.m_create_btn = self.m_recommend_view:getChildByName("bottom_view"):getChildByName("create_sociaty_btn");
    self.m_recommend_list_view = self.m_recommend_view:getChildByName("content_view"):getChildByName("recommend_list");
    self.m_search_view = self.m_recommend_view:getChildByName("search_view")
--    self.m_search_btn = self.m_search_view:getChildByName("input_bg"):getChildByName("search_btn");
    self.m_input_edit = self.m_search_view:getChildByName("input_bg"):getChildByName("search_input");
    self.m_input_edit:setHintText("输入棋社ID",130,95,55);
    self.m_input_edit:setOnTextChange(self, self.searchSociaty);

    self.m_recommend_btn = self.m_search_view:getChildByName("recommend_btn");
    self.m_recommend_btn:setOnClick(self,self.getRecmmendSociaty);
    self.m_sociaty_list = new(ScrollView,0,0,690,916,true)
    self.m_sociaty_list:setPos(0,0);
    self.m_sociaty_list:setAlign(kAlignTop);
    self.m_sociaty_list:setDirection(kVertical);
    self.m_recommend_list_view:addChild(self.m_sociaty_list);
    --我的棋社界面
    self.m_sociaty_view = self.m_root_node:getChildByName("sociaty_view");
    self.m_sociaty_view:setVisible(false)
    self.m_sociaty_info_view = self.m_sociaty_view:getChildByName("sociaty_info_view");
    self.m_sociaty_icon = self.m_sociaty_info_view:getChildByName("sociaty_icon_bg");
    self.m_sociaty_name = self.m_sociaty_info_view:getChildByName("sociaty_name");
    self.m_sociaty_id = self.m_sociaty_info_view:getChildByName("sociaty_id");
    self.m_sociaty_owner = self.m_sociaty_info_view:getChildByName("sociaty_gm");
    self.m_notice_text = self.m_sociaty_info_view:getChildByName("notice_text");
    self.m_join_type_bg = self.m_sociaty_info_view:getChildByName("join_type");
    self.m_join_type_text = self.m_join_type_bg:getChildByName("text");
    self.m_manager_btn = self.m_sociaty_info_view:getChildByName("manager_btn");
--    self.m_msg_icon = self.m_manager_btn:getChildByName("msg");
    self.m_manager_btn_text = self.m_manager_btn:getChildByName("text");
--    self.m_manager_btn:setOnClick(self,self.managerSociaty);

    self.m_sociaty_modify_btn = self.m_sociaty_view:getChildByName("title"):getChildByName("modify_btn")
    self.m_sociaty_back_btn = self.m_sociaty_view:getChildByName("back_btn")
    self.m_sociaty_modify_btn:setOnClick(self,self.modifySociatyInfo)
    self.m_sociaty_back_btn:setOnClick(self,self.onBack)
    --我的棋社活跃
    self.m_sociaty_rank = self.m_sociaty_info_view:getChildByName("rank_view"):getChildByName("rank_num");
    self.m_active_num = self.m_sociaty_info_view:getChildByName("rank_view"):getChildByName("active_num");
    self.m_week_active_num = self.m_sociaty_info_view:getChildByName("rank_view"):getChildByName("week_active_num");
    --我的棋社成员列表

    self.m_sociaty_member_list_view = self.m_sociaty_view:getChildByName("sociaty_member_list_view");
    self.m_sociaty_member_list = new(ScrollView,0,66,640,540,true)
    self.m_sociaty_member_list:setAlign(kAlignTop);
    self.m_sociaty_member_list_view:addChild(self.m_sociaty_member_list);
    self.m_sociaty_member_list:setOnScrollEvent(self,self.onGetMemberInfo)

    self.m_invite_btn = self.m_sociaty_member_list_view:getChildByName("invite_btn");
    self.m_invite_btn:setOnClick(self,self.showInviteDialog)
    self.m_invite_btn_tip = self.m_sociaty_member_list_view:getChildByName("tip");
    self.m_invite_btn_tip:setVisible(false)
    self.m_sociaty_member = self.m_sociaty_member_list_view:getChildByName("sociaty_member");

    --转让社长界面
    self.m_transfer_sociaty_view = self.m_sociaty_view:getChildByName("transfer_sociaty_view");
    self.m_transfer_bg = self.m_transfer_sociaty_view:getChildByName("View1");
    self.cancel_btn = self.m_transfer_sociaty_view:getChildByName("View1"):getChildByName("cancel_btn")
    self.cancel_btn:setOnClick(self,function()
        self.m_transfer_sociaty_view:setVisible(false)
    end)
    self.transfer_btn = self.m_transfer_sociaty_view:getChildByName("View1"):getChildByName("transfer_btn")
    self.transfer_btn:setOnClick(self,function()
        self:confirmChangeVp()
    end)
    self.transfer_list_view = self.m_transfer_sociaty_view:getChildByName("View1"):getChildByName("list_view")
    self.transfer_empty_view =self.m_transfer_sociaty_view:getChildByName("View1"):getChildByName("empty_view") 
    self.transfer_empty_view:setVisible(false)
    self.transfer_list = new(ListView,0,0,450,250)
    self.transfer_list:setAlign(kAlignTop);
    self.transfer_list:setDirection(kVertical);
    self.transfer_list_view:addChild(self.transfer_list)
    self.m_transfer_sociaty_view:setEventTouch(self,function()
        self.m_transfer_sociaty_view:setVisible(false)
    end)
    self.m_transfer_sociaty_view:setEventDrag(nil,nil)
    self.m_transfer_bg:setEventTouch(self,function() end)

end

--[Comment]
--进入棋社界面时显示界面
function ChessSociatyModuleView.switchView(self)
    if self.s_view_mode == ChessSociatyModuleView.mode_unJoin then
        self:switchUnJoinView()
    elseif self.s_view_mode == ChessSociatyModuleView.mode_join then
        self:switchSociatyView()
    end
end

--[Comment]
--切换加入棋社后状态界面
function ChessSociatyModuleView.switchSociatyView(self)
--    if self.s_view_mode == ChessSociatyModuleView.mode_join then 
--        return 
--    end
    self.s_view_mode = ChessSociatyModuleView.mode_join

    self.m_recommend_view:setVisible(false)
    self.m_sociaty_view:setVisible(true)
    
    if self.mSelfSociatyData then
        SociatyModuleData.getInstance():onCheckSociatyData(self.mSelfSociatyData.guild_id)
        SociatyModuleData.getInstance():clearSociatyMemberData()
    end

    if self.m_sociaty_member_list then
        self.m_sociaty_member_list:removeAllChildren(true)
        self.memberListNum = 0
        self.m_sociaty_member_list_tab = {}
    end
    self:getSociatyMember(0);
    self:getApplyMsg()
    self:updateViewByRole(self.mSelfSociatyData.guild_role)
end

--[Comment]
--切换未加入棋社状态界面
function ChessSociatyModuleView.switchUnJoinView(self)
--    if self.s_view_mode == ChessSociatyModuleView.mode_unJoin then 
--        return 
--    end
    self.s_view_mode = ChessSociatyModuleView.mode_unJoin
    self.m_recommend_view:setVisible(true)
    self.m_sociaty_view:setVisible(false)
    self.m_create_btn:setOnClick(self,function()
        --创建棋社
        self:createSociaty()
    end)
    self:getRecmmendSociaty()
end

--临时 提示申请消息
function ChessSociatyModuleView.getApplyMsg(self)
    if not self.mSelfSociatyData then 
--        self.m_msg_icon:setVisible(false)
        return 
    end

    local tab = {}
    tab.guild_id = self.mSelfSociatyData.guild_id
    tab.limit = 10
    tab.offset = 0;
    local post = {}
    post.param = tab
    HttpModule.getInstance():execute2(HttpModule.s_cmds.getSociatyApplyMsg,post,function(isSuccess,resultStr)--,httpRequest)
        if isSuccess then
            local jsonData = json.decode(resultStr)
            local data = jsonData.data
            if type(data) ~= "table" then return end
            if next(data) == nil then return end
            if self.mSelfSociatyData then
                local role = tonumber(self.mSelfSociatyData.guild_role)
                if role == ChesssociatyModuleConstant.ROLE_GM or role == ChesssociatyModuleConstant.ROLE_VP then
                    self.m_invite_btn_tip:setVisible(true)
                end
            end
        end
    end);
end

--[Comment]
-- 根据权限更新界面
function ChessSociatyModuleView:updateViewByRole(player_role)
    local role = tonumber(player_role)
    if not role then return end
    if self.mPlayerRole ~= role then
        FriendsData.getInstance():sendCheckUserData(UserInfo.getInstance():getUid())
    end
    self.mPlayerRole = player_role
    if role ~= ChesssociatyModuleConstant.ROLE_GM then
        self.m_manager_btn:setOnClick(self,self.quitSociaty)
        self.m_manager_btn_text:setText("退出棋社");
    else
        self.can_transfer = false
        self.m_manager_btn:setOnClick(self,self.transferSociaty)
        self.m_manager_btn_text:setText("转让棋社");
    end
    if role == ChesssociatyModuleConstant.ROLE_GM or role == ChesssociatyModuleConstant.ROLE_VP then
        self.m_sociaty_modify_btn:setVisible(true)
    else
        self.m_sociaty_modify_btn:setVisible(false)
    end
end

--[Comment]
--设置自己的棋社数据
function ChessSociatyModuleView:setSelfSociatyData(data)
    --根据玩家是否加入公会来判断
--    if self.mSelfSociatyData == data then 
--        return 
--    end
    self.mSelfSociatyData = data
    if type(data) ~= "table" or next(data) == nil or not data.guild_id then
        self:switchUnJoinView()
    else
        self:switchSociatyView()
    end
end

--[Comment]
--推荐棋社
function ChessSociatyModuleView.getRecmmendSociaty(self)
    ChessSociatyModuleController.getInstance():onGetChessSociatyRecommend();
end

--[Comment]
--推荐棋社
function ChessSociatyModuleView.onGetMemberInfo(self,scroll_status,diff, totalOffset)
    local lvW, lvH = self.m_sociaty_member_list:getSize();
    local trueOffset = self.memberListNum * SociatyMemberNode.s_h - lvH;
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

--[Comment]
--获得棋社成员信息
function ChessSociatyModuleView.getSociatyMember(self,offset)
    --根据我所在的棋社id
    if not self.mSelfSociatyData then return end
    local ret = {};
    ret.guild_id = tonumber(self.mSelfSociatyData.guild_id) or 0;
    ret.limit = 10;
    ret.offset = offset or 0;
    ChessSociatyModuleController.getInstance():onGetSociatyMemberInfo(ret)
end

--[Comment]
--跳转房间，roomType: 房间类型  data: 好友数据
require(DIALOG_PATH.."create_room_dialog");
function ChessSociatyModuleView.nodeBtnClick(self,roomType,data)
    if not roomType or not data then return end
    if UserInfo.getInstance():isFreezeUser() then return end;
    if roomType == SociatyMemberNode.check_node then
        --查看好友
        delete(self.m_userInfo_dialog)
        self.m_userInfo_dialog = new(UserInfoDialog2)
        if self.m_userInfo_dialog:isShowing() then return end
        local retType = UserInfoDialog2.SHOW_TYPE.SOCIATY
        local id = tonumber(data.mid) or 0
        if UserInfo.getInstance():getUid() == id then
            retType = UserInfoDialog2.SHOW_TYPE.ONLINE_ME
        end
        self.m_userInfo_dialog:setShowType(retType)
--        if id == UserInfo.getInstance():getUid() then

--        end
        local user = FriendsData.getInstance():getUserData(id);
        self.m_userInfo_dialog:show(user,id);
--        if tonumber(data.mid) == UserInfo.getInstance():getUid() then
--            self.m_userInfo_dialog:setForbidVisible(false);
--            self.m_userInfo_dialog:setFightBtnVisible(false);
--            self.m_userInfo_dialog:setReportBtn(false);
--            self.m_userInfo_dialog:setAddBtn(false);
--        else
--            self.m_userInfo_dialog:setForbidVisible(false);
--            self.m_userInfo_dialog:setFightBtnVisible(true);
--            self.m_userInfo_dialog:setReportBtn(true);
--            self.m_userInfo_dialog:setAddBtn(true);
--        end
    elseif roomType == SociatyMemberNode.challenge_user then
        --挑战
        self.challenge = data
        if not tonumber(self.challenge.mid) then return end
--        local isCanCreate = RoomProxy.getInstance():canAccessRoom(RoomConfig.ROOM_TYPE_FRIEND_ROOM,UserInfo.getInstance():getMoney());
--        if not isCanCreate then
--            ChessToastManager.getInstance():show("金币不足或超出上限，发起挑战失败", 1000);
--            return;
--        end
--        UserInfo.getInstance():setTargetUid(tonumber(self.challenge.mid));
--        local post_data = {};
--        post_data.uid = tonumber(UserInfo.getInstance():getUid());
--        post_data.level = 320;
--        OnlineSocketManager.getHallInstance():sendMsg(CLIENT_HALL_CREATE_FRIENDROOM,post_data,nil,1);
        local money = UserInfo.getInstance():getMoney();
        local config = RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_PRIVATE_ROOM)
        local minmoney = config.minmoney or 500
 	    if  money < minmoney then
 		    self:show_tips_action( string.format("您携带的金币不足%d，无法创建房间，请移步新手场或其他版块游戏。",minmoney));
 		    return;
 	    end
        if not self.m_createroom_dialog then
            self.m_createroom_dialog = new(CreateRoomDialog,50,260,370,286,self);
        end;
        self.m_createroom_dialog:show();    
    end
end

function ChessSociatyModuleView.customCreateRoom(self, data)
    --{round_time=600 target_uid=10000043 sec_time=0 step_time=30 uid=10000092 name="6666的房间" level=300 password="smart" basechip=800 }
    data.target_uid = tonumber(self.challenge.mid) or 0
    -- 挑战邀请加默认密码，防止等待过程其他玩家进入
    math.randomseed(os.time());
    if data.password and data.password == "" then data.password = math.random(100000,999999).."" end;
    UserInfo.getInstance():setCustomRoomData(data);
    UserInfo.getInstance():setCustomRoomType(3)
    OnlineSocketManager.getHallInstance():sendMsg(CLIENT_HALL_CREATE_PRIVATEROOM,data);
    
end

require(DIALOG_PATH.."chioce_dialog");
function ChessSociatyModuleView.show_tips_action(self,msg)
	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end
   	self.m_chioce_dialog:setMode(ChioceDialog.MODE_OK,"知道了");
	self.m_chioce_dialog:setMessage(msg);
	self.m_chioce_dialog:setPositiveListener(nil,nil);
	self.m_chioce_dialog:show();
end

--[Comment]
--退出棋社
function ChessSociatyModuleView.quitSociaty(self)
    if not self.m_chioce_dialog then
        self.m_chioce_dialog = new(ChioceDialog)
    end
    self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE);
    local name = self.my_sociaty_data.name or ""
    local tips = "是否确定退出" .. name .. "？退出后24小时内将不能加入棋社"
    self.m_chioce_dialog:setMessage(tips);
    self.m_chioce_dialog:setPositiveListener(self,function()
        if not self.mSelfSociatyData then return end
        ChessSociatyModuleController.getInstance():onQuitSociaty(tonumber(self.mSelfSociatyData.guild_id))
    end)
    self.m_chioce_dialog:show();
end

--[Comment]
--转让棋社
function ChessSociatyModuleView.transferSociaty(self)
    self:checkSociatyViceChairMan()
    self.m_transfer_sociaty_view:setVisible(true)
end

--查看vp列表
function ChessSociatyModuleView.checkSociatyViceChairMan(self)
    if not self.mSelfSociatyData then return end
    self.transfer_list:setAdapter();
    self.transfer_empty_view:setVisible(true)
    local data = {}
    data.guild_id = self.mSelfSociatyData.guild_id or 0 
    HttpModule.getInstance():execute2(HttpModule.s_cmds.getSociatyVp,data,function(isSuccess,resultStr)
        if isSuccess then
            local jsonData = json.decode(resultStr)
            local errorMsg = jsonData.error

            if errorMsg then
                if jsonData.flag ~= 23 then
                    ChessToastManager.getInstance():showSingle(errorMsg or "获得数据失败，请稍后再试") 
                end
                return
            end
            local data = jsonData.data
            if not data or type(data) ~= "table" then return end
            if self then
                self:initMemberList(data)
            end
        end
    end)
end

--初始化vp列表
function ChessSociatyModuleView.initMemberList(self,data)
    if #data > 0 then
        delete(self.m_adapter)
        local index = 1
        for k,v in pairs(data) do
            if v then 
                self.can_transfer = true
                v.handler = self
                v.index = index
                index = index + 1
            end
        end
        self.m_adapter = new(CacheAdapter,SociatyTransferNode,data);
        self.transfer_list:setAdapter(self.m_adapter);
        self.transfer_empty_view:setVisible(false)
    end
end

--更新vp列表选择状态
function ChessSociatyModuleView.updataVpList(self,index)
    if not index then return end
    local children = self.transfer_list:getChildren()
    for k,v in pairs(children) do
        if v then
            if v.index == index then
                v:onSelect(true)
            else
                v:onSelect(false)
            end
        end
    end
end

--转让社长
function ChessSociatyModuleView.confirmChangeVp(self)
    if not self.can_transfer then 
        ChessToastManager.getInstance():showSingle("操作无效，棋社需转让给副会长")
        return 
    end
    local children = self.transfer_list:getChildren()
    for k,v in pairs(children) do
        if v then
            if v.isSelect then
                self.select_uid,self.select_name = v:getSelectInfo()
                break
            end
        end
    end
    if not self.select_uid or not self.select_name then
        ChessToastManager.getInstance():showSingle("数据缺失，刷新后再试")
        return 
    end
    if not self.m_chioce_dialog then
        self.m_chioce_dialog = new(ChioceDialog)
    end
    self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE);
    local tips = "确定把棋社转让给 " .. self.select_name .. " 吗？"
    self.m_chioce_dialog:setMessage(tips);
    self.m_chioce_dialog:setPositiveListener(self,function()
        self:sendChangeVp()
    end)
    self.m_chioce_dialog:show();
end

--转让社长
function ChessSociatyModuleView.sendChangeVp(self)
    if not self.select_uid then return end
    local temp = {}
    temp.guild_id = tonumber(self.my_sociaty_data.id) or 0
    temp.target_mid = tonumber(self.select_uid ) or 0
    temp.op = ChesssociatyModuleConstant.s_manager_active["OP_TO_GM"];
    ChessSociatyModuleController.getInstance():onManagerSociaty(temp)
    self.m_transfer_sociaty_view:setVisible(false)
end

--[Comment]
--管理棋社
function ChessSociatyModuleView.managerSociaty(self)
    --显示棋社管理弹窗
    if not self.m_sociaty_manager_dialog then
        self.m_sociaty_manager_dialog = new(SociatyManagerDialog)
    end
    self.m_sociaty_manager_dialog:onUpdateSociatyData(self.my_sociaty_data)
    self.m_sociaty_manager_dialog:setCallBackFuc(self,self.resetMemberList)
    self.m_sociaty_manager_dialog:show()
end

--[Comment]
--重置成员list
function ChessSociatyModuleView.resetMemberList(self)
    if self.m_sociaty_member_list then
        self.m_sociaty_member_list:removeAllChildren(true);
        self.memberListNum = 0
        self.m_sociaty_member_list_tab = {}
    end
    local data = SociatyModuleData.getInstance():getSociatyMemberData()
    for k,v in pairs(data) do
        if v then
            self.memberListNum = self.memberListNum + 1
            local node = new(SociatyMemberNode,v,k,self)
            self.m_sociaty_member_list_tab[self.memberListNum] = node
            self.m_sociaty_member_list:addChild(node)
        end
    end
end

--[Comment]
--更新成员列表
function ChessSociatyModuleView.onUpdateSociatyMemberList(self,data)
    if not self.m_sociaty_member_list then return end
    if not data then 
        self:resetMemberList()
        return 
    end
    local data = SociatyModuleData.getInstance():getSociatyMemberData()

    for i=1,#data do
        if not self.m_sociaty_member_list_tab[i] then
            self.memberListNum = self.memberListNum + 1
            local node = new(SociatyMemberNode,data[self.memberListNum],self.memberListNum,self)
            self.m_sociaty_member_list_tab[self.memberListNum] = node
            self.m_sociaty_member_list:addChild(node)
        else
            self.m_sociaty_member_list_tab[i]:setItemData(data[i])
        end
    end
    local len = #self.m_sociaty_member_list_tab
    for i=#data+1,len do
        delete(self.m_sociaty_member_list_tab[i])
        self.m_sociaty_member_list_tab[i] = nil
    end

--    if #data > self.memberListNum then
--        for i = (self.memberListNum + 1), #data do
--            self.memberListNum = self.memberListNum + 1
--            local node = new(SociatyMemberNode,data[self.memberListNum],self.memberListNum,self)
--            self.m_sociaty_member_list_tab[self.memberListNum] = node
--            self.m_sociaty_member_list:addChild(node)
--        end
--        return
--    end

--    for k,v in pairs(data) do
--        if v then
--            self.memberListNum = self.memberListNum + 1
--            local node = new(SociatyMemberNode,v,k,self)
--            self.m_sociaty_member_list:addChild(node)
--        end
--    end
end

--[Comment]
--搜索棋社
function ChessSociatyModuleView.searchSociaty(self,str)
    local id = str or "0"
--    if self.m_input_edit then
--        id = self.m_input_edit:getText();
--    end

    --对id进行判断 
    local id = ToolKit.delStrBlank(id)
    if id and id ~= "" and self:islegal(id) then

	else
        local msg = "ID输入错误，请重新输入"
        ChessToastManager.getInstance():showSingle(msg);
        return
	end
    SociatyModuleData.getInstance():onCheckSociatyData(id)
end

--[Comment]
--id 是否合法
function ChessSociatyModuleView.islegal(self,str)
	local date = "%D"
	if not string.find(str, date) then --非数字
		return true;
	else
		return false;
	end
end

--[Comment]
--创建棋社
function ChessSociatyModuleView.createSociaty(self)
    HttpModule.getInstance():execute2(HttpModule.s_cmds.GuildCheckCreateGuildRight,{},function(isSuccess,resultStr)--,httpRequest)
        if isSuccess then
            local jsonData = json.decode(resultStr)
            if jsonData.flag ~= 10000 then ChessToastManager.getInstance():showSingle(jsonData.error or "不符合创建条件") return end
            if not self.m_sociaty_dialog then
                self.m_sociaty_dialog = new(CreateAndCheckSociatyDialog);
            end
            self.m_sociaty_dialog:setDialogStatus(CreateAndCheckSociatyDialog.s_create_mode);
            self.m_sociaty_dialog:show();
        else
            ChessToastManager.getInstance():showSingle("查询创建资格失败")
        end
    end)
end

--[Comment]
--查看棋社信息
function ChessSociatyModuleView.onCheckSociaty(self,data)
    self.check_sociaty_data = data
    if not self.m_sociaty_dialog then
        self.m_sociaty_dialog = new(CreateAndCheckSociatyDialog);
    end
    self.m_sociaty_dialog:setSociatyData(data)
    self.m_sociaty_dialog:setDialogStatus(CreateAndCheckSociatyDialog.s_check_mode);
    self.m_sociaty_dialog:show();
end

--[Comment]
--更新界面
function ChessSociatyModuleView.refreshView(self,cmd, ...)
    if not self.s_cmdConfig[cmd] then
		return;
	end

	return self.s_cmdConfig[cmd](self,...)
end

--[Comment]
--推荐棋社回调
function ChessSociatyModuleView.onRecommendhDataCallBack(self,data)
    if not data or next(data) == nil then return end
    self:updataSociatyList(data)
end

--[Comment]
--更新棋社列表
function ChessSociatyModuleView.updataSociatyList(self,data)
    if self.m_sociaty_list then
        self.m_sociaty_list:removeAllChildren(true)
    end
    for k,v in pairs(data) do 
        local child = new(SociatyRecommendItem, v,self);
        self.m_sociaty_list:addChild(child);
    end
end

--[Comment]
--更新棋社界面
function ChessSociatyModuleView.updataSociatyInfo(self,data)
    if not data or type(data) ~= "table" then return end
    self.my_sociaty_data = data

    local name = self.my_sociaty_data.name or ""
    self.m_sociaty_name:setText(name);
--    local w,h = self.m_sociaty_name:getSize()

    local id = self.my_sociaty_data.id or 0
    self.m_sociaty_id:setText("(ID:)" .. id);
--    self.m_sociaty_id:setPos(,nil)

    local member_num = self.my_sociaty_data.member_num or "1"
    local max_num = self.my_sociaty_data.max_member or "30"
    self.m_sociaty_member:setText("成员:" .. member_num .. "/" .. max_num);

    local mnick = self.my_sociaty_data.gm_mnick or "博雅象棋"
    self.m_sociaty_owner:setText(mnick)

    local notice = self.my_sociaty_data.notice or ""
    self.m_notice_text:setText(notice)

    local week_active = self.my_sociaty_data.week_active or "0"
    self.m_week_active_num:setText(week_active)

    local week_rank = "未上榜";
    if self.my_sociaty_data.week_rank and tonumber(self.my_sociaty_data.week_rank) ~= 0 then
        week_rank = self.my_sociaty_data.week_rank
    end
    self.m_sociaty_rank:setText(week_rank)

    local active = self.my_sociaty_data.total_active or "0"
    self.m_active_num:setText(active)

    local join_type = tonumber(self.my_sociaty_data.join_type) or 3
    self.m_join_type_bg:setFile(ChesssociatyModuleConstant.join_type[join_type].icon) 
    self.m_join_type_text:setText(ChesssociatyModuleConstant.join_type[join_type].text) 

    local icon_mark = tonumber(self.my_sociaty_data.mark) or 10
    for k,v in pairs(ChesssociatyModuleConstant.sociaty_icon) do
        if v.index == icon_mark then
            self.m_sociaty_icon:setFile(v.file);
        end
    end
end

--[Comment]
--创建棋社回调,若金币不足则弹购买金币弹窗
function ChessSociatyModuleView.onCreateSociatyCallBack(self,data)
    if not data or next(data) == nil then return end
    if data.isSuccess then
        if self.m_sociaty_dialog then
            self.m_sociaty_dialog:dismiss();
        end
        ChessToastManager.getInstance():showSingle("棋社创建成功")
        FriendsData.getInstance():sendCheckUserData(UserInfo.getInstance():getUid())
        self:setSelfSociatyData(UserInfo.getInstance():getUserSociatyData())
        return
    end
--    local money = UserInfo.getInstance():getSociatyCreateMoney() - UserInfo.getInstance():getMoney()
--    local goods = MallData.getInstance():getGoodsByMoreMoney(money)
--    if not goods then return end
--    if next(goods) == nil then return end
--    local payData = {}
--    payData.pay_scene = PayUtil.s_pay_scene.create_sociaty_recommend
--    ChessSociatyModuleView.m_PayInterface = PayUtil.getPayInstance(PayUtil.s_defaultType);
--	goods.position = MALL_COINS_GOODS;
--	ChessSociatyModuleView.m_pay_dialog = ChessSociatyModuleView.m_PayInterface:buy(goods,payData);
end

--[Comment]
--修改棋社信息回调
function ChessSociatyModuleView.onModifySociatyData(self,data)
    if not data then return end

    if data.name then
        self.m_sociaty_name:setText(data.name);
        if self.m_sociaty_dialog then
            self.m_sociaty_dialog:onUpdateSociatyName(data.name)
        end
    end

    local notice = data.notice
    if notice then
        self.my_sociaty_data.notice = notice
        self.m_notice_text:setText(notice)
    end

    --修改公会徽章
    local icon_mark = tonumber(data.mark)
    if icon_mark then
        self.my_sociaty_data.mark = icon_mark
        for k,v in pairs(ChesssociatyModuleConstant.sociaty_icon) do
            if v.index == icon_mark then
                self.m_sociaty_icon:setFile(v.file);
            end
        end
    end

    --修改公会加入方式
    local join_type = tonumber(data.join_type)
    if join_type then
        self.my_sociaty_data.join_type = join_type
        self.m_join_type_bg:setFile(ChesssociatyModuleConstant.join_type[join_type].icon) 
        self.m_join_type_text:setText(ChesssociatyModuleConstant.join_type[join_type].text) 
    end

    --修改加入公会等级
    local join_min_level = tonumber(data.join_min_level)
    if join_min_level then
        self.my_sociaty_data.join_min_level = join_min_level
    end

    self.my_sociaty_data = SociatyModuleData.getInstance():getSociatyData()

    ChessToastManager.getInstance():showSingle("棋社信息修改成功")
end

--[Comment]
--更新棋社信息
function ChessSociatyModuleView.onUpdateSociatyData(self,data)
    if not data or type(data) ~= "table" then return end 
    --未加入棋社
    -- 因为这里是传的引用 所以 userinfo 的 数据更新这里也会更新
    self:updateViewByRole(self.mSelfSociatyData.guild_role)
    if self.s_view_mode == ChessSociatyModuleView.mode_unJoin then
        local tab = {};
        table.insert(tab,data)
        self:updataSociatyList(tab)
    end
    --已经加入加入棋社
    if self.s_view_mode == ChessSociatyModuleView.mode_join then
        self:updataSociatyInfo(data)
    end
end

--[Comment]
--通过棋社申请加入棋社
function ChessSociatyModuleView.onJoinSociaty(self)
    if self.s_view_mode == ChessSociatyModuleView.mode_join then return end
    self:setSelfSociatyData(UserInfo.getInstance():getUserSociatyData())
end

--[Comment]
--退出棋社
function ChessSociatyModuleView.onQuitSociaty(self)
    if self.s_view_mode == ChessSociatyModuleView.mode_unJoin then return end
    if self.m_sociaty_manager_dialog then 
        self.m_sociaty_manager_dialog:dismiss()
    end
    self:setSelfSociatyData(UserInfo.getInstance():getUserSociatyData())
end

--[Comment]
--更新用户信息弹窗
function ChessSociatyModuleView.onUpdateUserData(self,status,data)
    if status then
        if type(status) ~= "table" or #status == 0 then
            return 
        end
        if self.m_userInfo_dialog then
            local ret = self.m_userInfo_dialog:setUserData(status[1]);
            if ret then
--              print_string("setUserData success");
            end
        end
        local children = self.transfer_list:getChildren()
        for k,v in pairs(children) do
            if v then
                v:updataItemData(status[1])
            end
        end
        local children = self.m_sociaty_member_list:getChildren()
        for k,v in pairs(children) do
            if v then
                local id = v:getUid()
                if id == tonumber(status[1].mid) then 
                    v:updataItem(status[1])
                end
            end
        end
    end
end

--[Comment]
-- 显示邀请dialog
require(DIALOG_PATH .. "sociatyInviteDialog")
function ChessSociatyModuleView:showInviteDialog()
    delete(self.m_invite_dialog)
    self.m_invite_dialog = new(SociatyInviteDialog)
    self.m_invite_dialog:setData(SociatyModuleData.getInstance():getSociatyData())
    self.m_invite_dialog:setCallBackFunc(self,self.resetMemberList)
    self.m_invite_dialog:show()
    self.m_invite_btn_tip:setVisible(false)
end

--[Comment]
--更新用户信息
function ChessSociatyModuleView.onUpdateStatus(self,status,data)
    if status then
        if type(status) ~= "table" or #status == 0 then
            return 
        end
        local tab = {}
        for k,v in pairs(status) do
            tab[v.uid] = v
        end

        local children = self.m_sociaty_member_list:getChildren()
        for k,v in pairs(children) do
            if v then
                local info = tab[v.mid]
                v:updataViewStatus(info)
            end
        end
    end
end

--[Comment]
--修改棋社信息
function ChessSociatyModuleView.modifySociatyInfo(self)
    if not self.mSelfSociatyData then return end
    local role = tonumber(self.mSelfSociatyData.guild_role) or 3
    if not role or role == 3 then return end
    if not self.m_sociaty_dialog then
        self.m_sociaty_dialog = new(CreateAndCheckSociatyDialog);
    end
    self.m_sociaty_dialog:setSociatyData(SociatyModuleData.getInstance():getSociatyData())
    self.m_sociaty_dialog:setDialogStatus(CreateAndCheckSociatyDialog.s_modify_mode);
    self.m_sociaty_dialog:show();  
end

ChessSociatyModuleView.s_cmdConfig = 
{
--    [ChessSociatyModuleView.s_cmds.searchCallBack]                 = ChessSociatyModuleView.onSearchDataCallBack;
    [ChessSociatyModuleView.s_cmds.recommendCallBack]              = ChessSociatyModuleView.onRecommendhDataCallBack;
    [ChessSociatyModuleView.s_cmds.createSociatyCallBack]          = ChessSociatyModuleView.onCreateSociatyCallBack;
--    [ChessSociatyModuleView.s_cmds.applyJoinSociatyCallBack]       = ChessSociatyModuleView.onApplyJoinSociatyCallBack;
--    [ChessSociatyModuleView.s_cmds.modifySociatyInfoCallBack]      = ChessSociatyModuleView.onModifySociatyInfoCallBack;

    
--    [ChessSociatyModuleView.s_cmds.getSociatymemberInfoCallBack]   = ChessSociatyModuleView.onGetSociatyMemberInfoCallBack;


}

ChessSociatyModuleView.s_nativeEventFuncMap = {
    [kSociaty_updataSociatyData]          = ChessSociatyModuleView.onUpdateSociatyData;
    [kSociaty_joinSociaty]                = ChessSociatyModuleView.onJoinSociaty;
    [kSociaty_quitSociaty]                = ChessSociatyModuleView.onQuitSociaty;
    [kSociaty_updataSociatyMemberData]    = ChessSociatyModuleView.onUpdateSociatyMemberList;
    [kSociaty_modifySociatyData]          = ChessSociatyModuleView.onModifySociatyData;
    [kFriend_UpdateUserData]              = ChessSociatyModuleView.onUpdateUserData;
    [kFriend_UpdateStatus]                = ChessSociatyModuleView.onUpdateStatus;
    [kStranger_isOnline]                  = ChessSociatyModuleView.onUpdateStatus;
}

---------------------private node------------------------
--棋社推荐item
SociatyRecommendItem = class(Node)

SociatyRecommendItem.s_w = 680
SociatyRecommendItem.s_h = 168

function SociatyRecommendItem.ctor(self,data,handler)
    if not data or type(data) ~= "table" or next(data) == nil then return end
    self.data = data
    self.handler = handler
    self:setSize(SociatyRecommendItem.s_w ,SociatyRecommendItem.s_h)
    self:setAlign(kAlignTop);
    self:setPos(0,0);

    self.item_bg = new(Image,"common/background/list_item_bg.png")
--    self.item_bg:setSize(90,90)
    self.item_bg:setVisible(true)
    self.item_bg:setAlign(kAlignCenter)
    self:addChild(self.item_bg);

    self.sociaty_icon = new(Image,"sociaty_about/r_scholar.png")
    self.sociaty_icon:setSize(90,90)
    self.sociaty_icon:setPos(33,-5)
    self.sociaty_icon:setAlign(kAlignLeft)
    self:addChild(self.sociaty_icon);

--    self.bottom_line = new(Image,"common/decoration/line_2.png");
--    self.bottom_line:setSize(568,2)
--    self.bottom_line:setPos(0,-2)
--    self.bottom_line:setAlign(kAlignBottom)
--    self:addChild(self.bottom_line);

    self.sociaty_name = new(Text,"",nil,nil,nil,nil,36,80,80,80)
    self.sociaty_name:setPos(140,35);
    self.sociaty_name:setAlign(kAlignTopLeft);
    self:addChild(self.sociaty_name);

    self.sociaty_owner_name = new(Text,"",nil,nil,nil,nil,24,125,80,65)
    self.sociaty_owner_name:setPos(184,96);
    self.sociaty_owner_name:setAlign(kAlignTopLeft);
    self:addChild(self.sociaty_owner_name);

--    self.sociaty_id = new(Text,"ID:0",nil,nil,nil,nil,28,120,120,120)
--    self.sociaty_id:setSize(220,50);
--    self.sociaty_id:setPos(118,58);
--    self.sociaty_id:setAlign(kAlignTopLeft);
--    self:addChild(self.sociaty_id);

    self.sociaty_member_num = new(Text,"成员:0/30",nil,nil,nil,nil,24,125,80,65)
    self.sociaty_member_num:setPos(360,96);
    self.sociaty_member_num:setAlign(kAlignTopLeft);
    self:addChild(self.sociaty_member_num);

    self.sociaty_chief = new(Image,"common/icon/temp_vp.png")
    self.sociaty_chief:setPos(137,85);
    self.sociaty_chief:setAlign(kAlignTopLeft);
    self:addChild(self.sociaty_chief);

--    self.sociaty_text = new(Text,"本周活跃",130,50,kAlignCenter,nil,24,120,120,120)
--    self.sociaty_text:setPos(330,36);
--    self.sociaty_text:setAlign(kAlignTopLeft);
--    self:addChild(self.sociaty_text);

    self.sociaty_activity_value = new(Text,"活跃度:0",nil,nil,nil,nil,24,125,80,65)
    self.sociaty_activity_value:setPos(520,96);
    self.sociaty_activity_value:setAlign(kAlignTopLeft);
    self:addChild(self.sociaty_activity_value);

    self.check_btn = new(Button,"drawable/blank.png");
    self.check_btn:setSize(SociatyRecommendItem.s_w ,SociatyRecommendItem.s_h);

--    self.btn_text = new(Text,"查看",nil,nil,kAlignCenter,nil,32,240,230,210);
--    self.btn_text:setAlign(kAlignCenter);
--    self.check_btn:addChild(self.btn_text);
    self.check_btn:setOnClick(self,self.checkDetailSociatyInfo);
    self.check_btn:setSrollOnClick()
    self:addChild(self.check_btn);

    self:onRefreshView(data)
end

function SociatyRecommendItem.dtor(self)
    
end

--[Comment]
--刷新推荐item
function SociatyRecommendItem.onRefreshView(self,data)
    local sociaty_name = data.name or ""
    self.sociaty_name:setText(sociaty_name)
    
--    local id = data.id or 0
--    self.sociaty_id:setText("ID:" .. id);
    local total_num = data.member_num or 0
    local max_num = data.max_member or 30
    self.sociaty_member_num:setText("成员:" .. total_num .. "/" .. max_num);
    local gm_name = data.gm_mnick or "博雅象棋"
    self.sociaty_owner_name:setText(gm_name);
    local week_active = data.week_active or 0
    self.sociaty_activity_value:setText("活跃度:" .. week_active);
    local mark =  tonumber(data.mark) or 10
    for k,v in pairs(ChesssociatyModuleConstant.sociaty_icon) do
        if v.index == mark then
            self.sociaty_icon:setFile(v.file);
        end
    end
end

--[Comment]
--查看棋社详细信息
function SociatyRecommendItem.checkDetailSociatyInfo(self)
    if self.handler then
        self.handler:onCheckSociaty(self.data)
    end
end

---------------------private node------------------------
--棋社成员node
require(VIEW_PATH .. "sociaty_view_member_node");
SociatyMemberNode = class(Node)

--SociatyMemberNode.s_watch_room = 10;
--SociatyMemberNode.s_challenge_room = 11;
SociatyMemberNode.check_node = 12;
SociatyMemberNode.challenge_user = 13;
SociatyMemberNode.s_h = 140

function SociatyMemberNode.ctor(self,data,index,handler)
    if not data then return end
    self.data = data 
    self.index = index
    self.handler = handler

    self.node = SceneLoader.load(sociaty_view_member_node)
    self:setSize(620,140)
    self:addChild(self.node);

    self.view        = self.node:getChildByName("view");
    self.rank        = self.view:getChildByName("rank");
    self.rank_img    = self.view:getChildByName("rank_img");
    self.self_bg     = self.view:getChildByName("self_bg");
    self.rank_img:setVisible(false)
    self.self_bg:setVisible(false)

    self.icon_bg     = self.view:getChildByName("icon_bg");
    self.icon = new(Mask,"common/background/head_mask_bg_86.png","common/background/head_mask_bg_86.png");
    self.icon:setSize(84,84);
    self.icon:setAlign(kAlignCenter);
    self.icon_bg:addChild(self.icon)
    self.name        = self.view:getChildByName("name");
    self.role        = self.view:getChildByName("role");
    self.level       = self.view:getChildByName("level");
    self.score       = self.view:getChildByName("score");
    self.active      = self.view:getChildByName("active");
    self.button      = self.view:getChildByName("Button");
    self.button_text = self.button:getChildByName("text");
    self.button:setSrollOnClick()

    self.check_btn   = self.view:getChildByName("check_btn");
    self.check_btn:setOnClick(self,function()
        if self.handler then
            self.handler.nodeBtnClick(self.handler,SociatyMemberNode.check_node,self.data);
        end
    end)
    self.check_btn:setSrollOnClick()

    self:updataView()
end

function SociatyMemberNode.dtor(self)
    delete(self.node)
    self.node = nil
end

function SociatyMemberNode.getUid(self)
    return tonumber(self.data.mid) or 0
end
--[Comment]
-- 用户数据 -> 棋社数据
function SociatyMemberNode.updataItem(self,data)
    if not data then return end
    self.data.mid = data.mid
    self.data.score = data.score
    self.data.iconType = data.iconType
    self.data.role = data.guild.guild_role
    self.data.icon_url = data.icon_url
    self.data.mnick = data.mnick
    self:updataView()
end

function SociatyMemberNode.setItemData(self,data)
    if not data then return end
    self.data = data
    self:updataView()
end

function SociatyMemberNode.updataView(self)
    if self.index and self.index < 4 then
        self.rank_img:setVisible(true)
        self.rank:setVisible(false)
        self.rank_img:setFile("common/icon/temp_rank_icon_" .. self.index .. ".png")
    else
        self.rank_img:setVisible(false)
        self.rank:setVisible(true)
        self.rank:setText(self.index or "0");
    end

    local name = self.data.mnick or"博雅象棋"
    if name == "" then
        name = "博雅象棋"
    end
    local lenth = string.lenutf8(GameString.convert2UTF8(name));
    if lenth > 6 then    
        name  = string.subutf8(name,1,7).."...";
    end
    self.name:setText(name);
    local role = tonumber(self.data.role) or 3
    self.role:setText(ChesssociatyModuleConstant.role[role] or "社员")
    self.level:setFile(string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevelByScore(self.data.score)));
    local score = self.data.score or "0"
    self.score:setText("积分:" .. score)
    local week_active = self.data.week_active or "0"
    self.active:setText("活跃:" .. week_active);
   
    --头像
    local iconFile = UserInfo.DEFAULT_ICON[1]
    if self.data.iconType == -1 then
        if not self.data.icon_url or self.data.icon_url == "" then
            self.icon:setFile(iconFile);
        else
            self.icon:setUrlImage(self.data.icon_url);
        end
    else
        iconFile = UserInfo.DEFAULT_ICON[self.data.iconType] or iconFile;
        self.icon:setFile(iconFile);
    end

    local id = tonumber(self.data.mid) or 0;
    if id == UserInfo.getInstance():getUid() then
        self.button:setVisible(false);
        self.self_bg:setVisible(true)
    else
        self.self_bg:setVisible(false)
    end

    local status = FriendsData.getInstance():getUserStatus(tonumber(self.data.mid) or 0) 
    self:updataViewStatus(status)
end

function SociatyMemberNode.updataViewStatus(self,status)
    if status ~= nil then
         if status.hallid <=0 then
            self.icon:setGray(true)
            self.button_text:setText("离线");
            self.button:setFile({"common/button/gray_btn_1.png","common/button/gray_btn_1.png"})
            self.button:setOnClick(self,function()
                ChessToastManager.getInstance():showSingle("玩家不在线")
            end)
        else
            if RoomConfig.getInstance():isPlaying(status) then -- 用户在下棋 
                --追踪观战
                self.button:setFile({"common/button/dialog_btn_7_normal.png","common/button/dialog_btn_7_press.png"});
                self.button_text:setText("观战");
                self.button:setOnClick(self,function()
                    local isSuccess,msg = RoomProxy.getInstance():followUserByStatus(status)
                    if not isSuccess then
                        ChessToastManager.getInstance():showSingle(msg)
                    end
                end)
            else
                --挑战
                self.button:setFile({"common/button/dialog_btn_3_normal.png","common/button/dialog_btn_3_press.png"});
                self.button_text:setText("挑战");
                self.button:setOnClick(self,function()
                    if self.handler then
                        self.handler.nodeBtnClick(self.handler,SociatyMemberNode.challenge_user,self.data);
                    end
                end)
            end
        end
    else
        local temp = self.data.hall_id or 0
        if temp == 0 then
            self.icon:setGray(true)
            self.button_text:setText("离线");
            self.button:setFile({"common/button/gray_btn_1.png","common/button/gray_btn_1.png"})
            self.button:setOnClick(self,function()
                ChessToastManager.getInstance():showSingle("玩家不在线")
            end)
        else
            self.button:setFile({"common/button/dialog_btn_3_normal.png","common/button/dialog_btn_3_press.png"});
            self.button_text:setText("挑战");
            self.button:setOnClick(self,function()
                if self.handler then
                    self.handler.nodeBtnClick(self.handler,SociatyMemberNode.challenge_user,self.data);
                end
            end)
        end
    end
end

--转让node
SociatyTransferNode = class(Node)

function SociatyTransferNode.ctor(self,data)
    if not data then return end
    
    self.data = data
    self.handler = self.data.handler
    self.index = self.data.index

    self.uid = tonumber(self.data.mid) or 0
    self.user_data = FriendsData.getInstance():getUserData(self.uid)
    
    self.icon_bg = new(Image,"common/background/head_bg_92.png")
    self.icon_bg:setAlign(kAlignTopLeft)
    self.icon_bg:setPos(118,3)
    self:addChild(self.icon_bg)

    self.m_icon = new(Mask,"userinfo/icon_8484_mask.png","userinfo/icon_8484_mask.png");
    self.m_icon:setAlign(kAlignCenter);
    self.icon_bg:addChild(self.m_icon)

    self.level = new(Image,"common/icon/level_9.png")
    self.level:setAlign(kAlignTopLeft)
    self.level:setPos(138,72)
    self:addChild(self.level)

    self.name = new(Text,"",nil,nil,nil,nil,28,220,130,55)
    self.name:setAlign(kAlignTopLeft)
    self.name:setPos(228,14)
    self:addChild(self.name)

    self.active_value = new(Text,"",nil,nil,nil,nil,24,220,130,55)
    self.active_value:setAlign(kAlignTopLeft)
    self.active_value:setPos(227,58)
    self:addChild(self.active_value)

    self.select_button = new(Button,"ui/radioButton1.png","ui/radioButton2.png")
    self.select_button:setAlign(kAlignTopLeft)
    self.select_button:setPos(20,24)
    self:addChild(self.select_button)
    self.select_button:setOnClick(self,function()
        if self.handler then
            self.handler:updataVpList(self.index)
        end
    end)
    if self.index and self.index == 1 then
        self.select_button:setEnable(false)
        self.isSelect = true
    end

    self:setSize(450,120)
    self:setAlign(kAlignTop)
    self:updataView()
end

function SociatyTransferNode.dtor(self)
    
end

function SociatyTransferNode.onSelect(self,ret)
    self.select_button:setEnable(not ret)
    self.isSelect = ret
end


function SociatyTransferNode.getSelectInfo(self)
    return self.uid,self.select_user_name
end

function SociatyTransferNode.updataView(self)
    if not self.user_data then return end
    local name = "博雅象棋"
    if self.user_data.mnick and type(self.user_data.mnick) == "string" and self.user_data.mnick ~= ""  then
        name = self.user_data.mnick
    end
    self.select_user_name = name
    self.name:setText(name)

    self.level:setFile(string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevelByScore(self.user_data.score)));

    --头像
    local iconFile = UserInfo.DEFAULT_ICON[1]
    if self.user_data.iconType == -1 then
        if not self.user_data.icon_url or self.user_data.icon_url == "" then
            self.m_icon:setFile(iconFile);
        else
            self.m_icon:setUrlImage(self.user_data.icon_url);
        end
    else
        iconFile = UserInfo.DEFAULT_ICON[self.user_data.iconType] or iconFile;
        self.m_icon:setFile(iconFile);
    end

    local active_value = self.data.week_active or 0
    active_value = "活跃: " .. active_value
    self.active_value:setText(active_value)
end

function SociatyTransferNode.setViewData(self,data)
    if not data then return end
    self.user_data = data
    self:updataView()
end

--function SociatyTransferNode.setNodeSelect(self,data)
--    if not data then return end
--    self.user_data = data
--    self:updataView()
--end

function SociatyTransferNode.updataItemData(self,data)
    if not data then return end
    if data.uid == self.uid then
        self.user_data = data
        self:updataView()
    end
end
