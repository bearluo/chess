--CreateAndCheckSociatyDialog.lua
--Date 2016.8.25
--创建棋社弹窗
--endregion
require(VIEW_PATH .. "create_sociaty_dialog_view");
require(BASE_PATH.."chessDialogScene")
require("dialog/chioce_dialog");
require(MODEL_PATH .. "chessSociatyModule/chessSociatyModuleNode")
require(MODEL_PATH .. "chessSociatyModule/chessSociatyModuleIconNode")

CreateAndCheckSociatyDialog = class(ChessDialogScene,false)

CreateAndCheckSociatyDialog.s_create_mode = 1; --创建棋社
CreateAndCheckSociatyDialog.s_check_mode  = 2;  --查看棋社
CreateAndCheckSociatyDialog.s_modify_mode = 3; --修改棋社

function CreateAndCheckSociatyDialog.ctor(self)
    super(self,create_sociaty_dialog_view)

    self.m_root_view        = self.m_root
    self.m_dialog_bg        = self.m_root_view:getChildByName("dialog_bg");
    self.m_close_btn        = self.m_root_view:getChildByName("dialog_bg"):getChildByName("close_btn");
    self.m_close_btn:setOnClick(self,self.dismiss);
    --创建棋社view
    self.m_create_sociaty_view        = self.m_root_view:getChildByName("dialog_bg"):getChildByName("create_view");
    self.m_name_input                 = self.m_create_sociaty_view:getChildByName("name_view"):getChildByName("name_input");
    self.m_change_name_btn            = self.m_create_sociaty_view:getChildByName("name_view"):getChildByName("change_name_btn");
    self.m_change_name_btn:setOnClick(self,self.onChangeNameBtnClick)
    self.m_notice_input               = self.m_create_sociaty_view:getChildByName("notice_view"):getChildByName("notice_input");
    self.m_icon_list_view             = self.m_create_sociaty_view:getChildByName("icon_view"):getChildByName("icon_list_view");
    self.create_sociaty_btn           = self.m_create_sociaty_view:getChildByName("create_sociaty_btn");
    self.join_check_view              = self.m_create_sociaty_view:getChildByName("check_view")
    self.join_grade_view              = self.m_create_sociaty_view:getChildByName("grade_view")

    local money = UserInfo.getInstance():getSociatyCreateMoney()
    money = string.format("%d万",math.floor(money/10000))
    local str = "#cDC0F0F" .. money .."金币#n创建棋社"
    self.btn_rich_text = new(RichText,str,400,90,kAlignCenter,nil,36,95,15,15,true)
    self.create_sociaty_btn:addChild(self.btn_rich_text);

    self.modify_text = new(Text,"保存修改",nil,nil,nil,nil,36,95,15,15)
    self.modify_text:setAlign(kAlignCenter)
    self.modify_text:setVisible(false)
    self.create_sociaty_btn:addChild(self.modify_text) 

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

    self.create_sociaty_btn:setOnClick(self,self.createSociaty);
    self.m_name_input:setHintText("10字符以内，创建后无法修改");
    self.m_notice_input:setHintText("公告不超过30个字");
    self.m_icon_list = new(ScrollView,0,0,450,110,true)
    self.m_icon_list:setDirection(kHorizontal);
    self.m_icon_list:setAlign(kAlignLeft);
    self.m_icon_list_view:addChild(self.m_icon_list);
    
    --查看公会信息view
    self.m_sociaty_info_veiw         = self.m_root_view:getChildByName("dialog_bg"):getChildByName("sociaty_info_view");
    self.m_sociaty_name              = self.m_sociaty_info_veiw:getChildByName("sociaty_info"):getChildByName("sociaty_name");
    self.m_sociaty_id                = self.m_sociaty_info_veiw:getChildByName("sociaty_info"):getChildByName("sociaty_id");
    self.m_sociaty_member            = self.m_sociaty_info_veiw:getChildByName("sociaty_info"):getChildByName("sociaty_member");
    self.m_sociaty_owner             = self.m_sociaty_info_veiw:getChildByName("sociaty_info"):getChildByName("sociaty_owner");
    self.m_sociaty_icon              = self.m_sociaty_info_veiw:getChildByName("sociaty_info"):getChildByName("icon");
    self.m_sociaty_owner_name        = self.m_sociaty_info_veiw:getChildByName("sociaty_info"):getChildByName("sociaty_name1");
    self.m_sociaty_join_btn          = self.m_sociaty_info_veiw:getChildByName("sociaty_info"):getChildByName("join_btn");
    self.m_sociaty_rank              = self.m_sociaty_info_veiw:getChildByName("active_view"):getChildByName("rank");
    self.m_sociaty_active            = self.m_sociaty_info_veiw:getChildByName("active_view"):getChildByName("active_value");
    self.m_sociaty_week_act          = self.m_sociaty_info_veiw:getChildByName("active_view"):getChildByName("week_active_value");
    self.m_member_list_view          = self.m_sociaty_info_veiw:getChildByName("member_list_view");
    --ScrollView大小和 member_list_view一样
    self.m_member_list = new(ScrollView,0,0,620,470,true)
    self.m_member_list:setAlign(kAlignTop);
    self.m_member_list_view:addChild(self.m_member_list);
    self.m_member_list:setOnScrollEvent(self,self.onGetSociatyMember)
    self.m_sociaty_join_btn:setOnClick(self,self.applyJoinSociaty)

    self:setShieldClick(self,self.dismiss)
    self.m_dialog_bg:setEventTouch(nil,function() end);
    self:initIconList()

    self:setVisible(false);
    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)

end

function CreateAndCheckSociatyDialog.dtor(self)
    delete(self.m_root_view)
    self.m_root_view = nil;
    delete(self.m_chioce_dialog)
    self.m_chioce_dialog = nil
    self.mDialogAnim.stopAnim()
end

function CreateAndCheckSociatyDialog.show(self)
    self.super.show(self,self.mDialogAnim.showAnim);
    self:setVisible(true);
end

function CreateAndCheckSociatyDialog.dismiss(self)

    self:setVisible(false);
    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
end

function CreateAndCheckSociatyDialog.isShowing(self)
    return self:getVisible();
end

--[Comment]
--设置棋社弹窗界面状态
function CreateAndCheckSociatyDialog.setDialogStatus(self,mode)
    self.m_view_mode = CreateAndCheckSociatyDialog.s_create_mode
    if not mode or mode == CreateAndCheckSociatyDialog.s_create_mode then   
        self.m_view_mode = CreateAndCheckSociatyDialog.s_create_mode
        self:switchCreateMode()
        return
    end
    if mode == CreateAndCheckSociatyDialog.s_check_mode then
        self.m_view_mode = CreateAndCheckSociatyDialog.s_check_mode
        self:switchCheckMode()
        return
    end
    if mode == CreateAndCheckSociatyDialog.s_modify_mode then
        self.m_view_mode = CreateAndCheckSociatyDialog.s_modify_mode
        self:switchModifyMode()
        return
    end
end

--[Comment]
--切换创建界面状态
function CreateAndCheckSociatyDialog.switchCreateMode(self)
    self.m_create_sociaty_view:setVisible(true)
    self.m_sociaty_info_veiw:setVisible(false)
    self.m_name_input:setText()
    self.m_notice_input:setText()
    self.m_name_input:setPickable(true)
    self.m_change_name_btn:setPickable(false)
    self.create_sociaty_btn:setOnClick(self,self.createSociaty)
	self.grade_list:setIndex(1)
	self.check_list:setIndex(1)
end

--[Comment]
--切换查看界面状态
function CreateAndCheckSociatyDialog.switchCheckMode(self)
    self.m_create_sociaty_view:setVisible(false);
    self.m_sociaty_info_veiw:setVisible(true);
    self:refreshView();
    self:onGetSociatyMemberInfo()
end

--[Comment]
--切换修改界面状态
function CreateAndCheckSociatyDialog.switchModifyMode(self)
    self:onUpdateSociatyData()
    self:onSwitchBaseView()
    self.m_create_sociaty_view:setVisible(true);
    self.m_sociaty_info_veiw:setVisible(false);
    self.m_name_input:setPickable(false)
    self.m_change_name_btn:setPickable(true)
--    self.m_notice_input:setText();
end

function CreateAndCheckSociatyDialog.onSwitchBaseView(self)
    self.btn_rich_text:setVisible(false)
    self.modify_text:setVisible(true)
    self.create_sociaty_btn:setOnClick(self,self.modifyInfo);
end

function CreateAndCheckSociatyDialog.modifyInfo(self)
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

--    self.m_member_list_view:setVisible(false);
--    self.m_apply_list_view:setVisible(true);

    local ret = {};
    ret.notice = notice
    if self.select_index then
        ret.mark = self.select_index
    end
--    ret.mark = self.select_index or 10
    ret.guild_id = tonumber(self.m_sociaty_data.id) or 0   
    ret.join_type = review + 1
    ret.join_min_level = 10 - grade 
    ChessSociatyModuleController.getInstance():onModifySociatyInfo(ret)
    self:dismiss()
end

require(DIALOG_PATH .. "changeSociatyNameDialog")
function CreateAndCheckSociatyDialog:onChangeNameBtnClick()

    if not self.mChangeSociatyNameDialog then
        self.mChangeSociatyNameDialog = new(ChangeSociatyNameDialog)
    end
    self.mChangeSociatyNameDialog:setTipsNum(UserInfo.getInstance():getModifyUserMnickCost(),true)
    self.mChangeSociatyNameDialog:setConfirmCallBack(self,self.contentTextChangeByMoney)
    self.mChangeSociatyNameDialog:show()
end

function CreateAndCheckSociatyDialog:contentTextChangeByMoney(text)
    ChessSociatyModuleController.getInstance():modifyGuildName(tonumber(self.m_sociaty_data.id) or 0,text)
end

function CreateAndCheckSociatyDialog:onUpdateSociatyName(name)
    self.m_sociaty_data.name = name
    self.m_name_input:setText(self.m_sociaty_data.name or "");
end
--[Comment]
--设置管理弹窗棋社数据
function CreateAndCheckSociatyDialog.onUpdateSociatyData(self)
    if not self.m_sociaty_data then return end
--    self.sociatyData = data
--    self.guild_id = tonumber(self.m_sociaty_data.id)
    self.m_name_input:setText(self.m_sociaty_data.name or "");
--    self.m_sociaty_name:setText(self.sociatyData.name or "");

--    local member_num = self.sociatyData.member_num or "1"
--    local max_num = self.sociatyData.max_member or "30"
--    self.m_sociaty_member:setText(member_num .. "/" .. max_num);

    if self.m_sociaty_data.notice and self.m_sociaty_data.notice ~= "" then
        self.m_notice_input:setText(self.m_sociaty_data.notice)
    end

    local levelLimit = tonumber(self.m_sociaty_data.join_min_level)
    if not levelLimit or levelLimit == 0 then
        levelLimit = 1
    end
    self.grade_list:setIndex(10 - levelLimit)

    local joinType = tonumber(self.m_sociaty_data.join_type) or 3
    self.check_list:setIndex(joinType - 1)


    local mark = tonumber(self.m_sociaty_data.mark) or 10
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

function CreateAndCheckSociatyDialog.onGetSociatyMember(self,scroll_status,diff, totalOffset)
    local lvW, lvH = self.m_member_list:getSize();
    local trueOffset = self.memberLisstNum * ChessSociatyModuleNode.s_h - lvH;
    if totalOffset and trueOffset > 0 then
        if (math.abs(tonumber(totalOffset)) >  trueOffset + 50) then
            if not self.m_is_loading_member then
                self.m_is_loading_member = true;
                self:onGetSociatyMemberInfo(self.memberLisstNum); 
            end;
        elseif math.abs(tonumber(totalOffset)) > trueOffset then
            self.m_is_loading_member = false;
        end;
    end;
end

--[Comment]
--获得成员棋社信息
function CreateAndCheckSociatyDialog.onGetSociatyMemberInfo(self,index)
    if not index then 
        self.isFirstSend = true 
    else
        self.isFirstSend = false 
    end
    local params = {};
    local ret = {};
    ret.guild_id = tonumber(self.m_sociaty_data.id) or 0;
    ret.limit = 10;
    ret.offset = index or 0;
    params.param = ret;
    HttpModule.getInstance():execute2(HttpModule.s_cmds.getSociatyMemberInfo,params,function(isSuccess,resultStr)--,httpRequest)
        if isSuccess then
            local jsonData = json.decode(resultStr)
            local data = jsonData.data
            if type(data) ~= "table" then return end
            if next(data) == nil then return end
            if self.isFirstSend then
                self.memberLisstNum = 0
                self.m_member_list:removeAllChildren(true)
            end
            for k,v in pairs(data) do
                if v then
                    self.memberLisstNum = self.memberLisstNum + 1
                    v.guild_id = self.m_sociaty_data.id
                    local node = new(ChessSociatyModuleNode,v,ChessSociatyModuleNode.s_check_mode,self)
                    self.m_member_list:addChild(node)
                end
            end
        else
            ChessToastManager.getInstance():showSingle("获得棋社成员失败")
        end
    end);
end

--[Comment]
--切换查看界面状态
function CreateAndCheckSociatyDialog.refreshView(self)
    local name = self.m_sociaty_data.name or "加载中..."
    self.m_sociaty_name:setText(name,0,0)
    local x,y = self.m_sociaty_name:getPos()
    local w,h = self.m_sociaty_name:getSize()

    local id = self.m_sociaty_data.id or ""
    self.m_sociaty_id:setText("(ID:" .. id .. ")")
    self.m_sociaty_id:setPos((x+w+10),nil)

    local member_num = self.m_sociaty_data.member_num or "1"
    local max_num = self.m_sociaty_data.max_member or "30"
    self.m_sociaty_member:setText("成员:" .. member_num .. "/" .. max_num)

    --设置职位
    local mnick = self.m_sociaty_data.gm_mnick or "博雅象棋"
    self.m_sociaty_owner_name:setText(mnick)

    local week_active = self.m_sociaty_data.week_active or "0"
    self.m_sociaty_week_act:setText(week_active)

    local week_rank = "未上榜";
    if self.m_sociaty_data.week_rank and tonumber(self.m_sociaty_data.week_rank) ~= 0 then
        week_rank = self.m_sociaty_data.week_rank
    end
    self.m_sociaty_rank:setText(week_rank)

    local active = self.m_sociaty_data.total_active or "0"
    self.m_sociaty_active:setText(active)

    local iconType = tonumber(self.m_sociaty_data.mark) or 10
    self.m_sociaty_icon:setFile(ChesssociatyModuleConstant.sociaty_icon[iconType] or "sociaty_about/r_scholar.png")
end

--[Comment]
--创建棋社
function CreateAndCheckSociatyDialog.createSociaty(self)
    local ret = {}
    --判断公会名字
    local name = self.m_name_input:getText()
    name = ToolKit.delStrBlank(name)
    local len = ToolKit.utfstrlen(name)
    if len < 1 or len > 8 then
        ChessToastManager.getInstance():showSingle("公会名字不合法，请重新输入");
        return
    end
    --判断公告名字
    local notice = self.m_notice_input:getText()
    notice = ToolKit.delStrBlank(notice)
    len = ToolKit.utfstrlen(notice)
    if len > 30 then
        ChessToastManager.getInstance():showSingle("公告文字过多，请重新输入");
        return
    end

    --判断审核条件
    local review = self.check_list:getSelectIndex() or 2
    --判断棋力条件
    local grade = self.grade_list:getSelectIndex() or 1


    --判断加入方式
--    local join_type = self.m_check_view:getResult()
--    if not join_type then
--        ChessToastManager.getInstance():showSingle("请选择加入公会方式");
--        return
--    end
    --判断公会徽章
    local mark = self.select_index
    if not mark then
        ChessToastManager.getInstance():showSingle("请选择公会徽章");
        return
    end  
    ret.name = name
    ret.notice = notice
    ret.join_type = review + 1
    ret.join_min_level = 10 - grade 
    ret.mark = mark

    -- 判断金币数量
    local money = UserInfo.getInstance():getSociatyCreateMoney() - UserInfo.getInstance():getMoney()
    if money > 0 then
        ChessToastManager.getInstance():showSingle("您的金币不足")
        local goods = MallData.getInstance():getGoodsByMoreMoney(money)
        if not goods then return end
        if next(goods) == nil then return end
        local payData = {}
        payData.pay_scene = PayUtil.s_pay_scene.create_sociaty_recommend
        local payInterface = PayUtil.getPayInstance(PayUtil.s_defaultType);
	    local pay_dialog = payInterface:buy(goods,payData);
        return
    end
    
    --检测创建棋社参数
    local params = {}
    params.param = ret
    HttpModule.getInstance():execute2(HttpModule.s_cmds.GuildCheckGuildDataLegal,params,function(isSuccess,resultStr)--,httpRequest)
        if isSuccess then
            local jsonData = json.decode(resultStr)
            if jsonData.flag ~= 10000 then ChessToastManager.getInstance():showSingle(jsonData.error or "不符合创建条件") return end
            if not self.m_chioce_dialog then
                self.m_chioce_dialog = new(ChioceDialog)
            end
            self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE,"确定","返回修改")
            self.m_chioce_dialog:setMessage("创建棋社后部分信息不可修改，确定继续提交吗？")
            self.m_chioce_dialog:setPositiveListener(self,function()
                ChessSociatyModuleController.getInstance():onCreateSociaty(ret);
            end);
            self.m_chioce_dialog:show()  
        else
            ChessToastManager.getInstance():showSingle("查询创建资格失败")
        end
    end)
end


--[Comment]
--重置界面状态
function CreateAndCheckSociatyDialog.resetView(self)
    self.m_name_input:setText();
    self.m_notice_input:setText();
end

--[Comment]
--初始化棋社图标
function CreateAndCheckSociatyDialog.initIconList(self)
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
--选择图标后更新图标列表状态
function CreateAndCheckSociatyDialog.updataSelectStatus(self,index)
    if not self.icon_node_tab then return end
    if not self.select_index then
        self.select_index = 10
    end
    if index then self.select_index = index end

    for k,v in pairs(self.icon_node_tab) do
        if v then
            if k ~= self.select_index then
                v:updataSelectStatus()
            end
        end
    end
end

--[Comment]
--设置棋社数据
function CreateAndCheckSociatyDialog.setSociatyData(self,data)
    if not data then return end
    self.m_sociaty_data = data
end

--[Comment]
--设置棋社数据
function CreateAndCheckSociatyDialog.applyJoinSociaty(self)
    if not self.m_sociaty_data then 
        self:dismiss()
        return 
    end
    ChessSociatyModuleController.getInstance():onApplyJoinChessSociaty(self.m_sociaty_data);
    self:dismiss()
end




--SwitchSelectNode = class(Node)

--function SwitchSelectNode.ctor(self,plist)
--    if not plist then return end
--    self.plist = plist

--    self:setSize(458,92)
--    self:setAlign(kAlignTopLeft)

--    self.textBg = new(Image,"common/background/input_bg_1.png",nil,nil,32,32,30,30)
--    self.textBg:setAlign(kAlignCenter)
--    self.textBg:setSize(390,60)
--    self:addChild(self.textBg)

--    self.text = new(Text,"",nil,nil,kAlignCenter,nil,32,135,100,95)
--    self.text:setAlign(kAlignCenter)
--    self.textBg:addChild(self.text)

--    self.rightBtn = new(Button,"sociaty_about/btn_normal.png","sociaty_about/btn_press.png")
--    local tab = {"common/button/add_btn_2_nor.png",""}
--    self.rightBtn:setFile(tab)
--    self.rightBtn:setAlign(kAlignRight)
--    self.rightBtn:setPos(0,0)
--    self.right_arr = new(Image,"sociaty_about/right_arr.png")
--    self.right_arr:setAlign(kAlignCenter);
--    self.rightBtn:addChild(self.right_arr)
--    self:addChild(self.rightBtn)

--    self.leftBtn = new(Button,"sociaty_about/btn_normal.png","sociaty_about/btn_press.png")
--    self.leftBtn:setAlign(kAlignLeft)
--    self.leftBtn:setPos(0,0)
--    self.left_arr = new(Image,"sociaty_about/left_arr.png")
--    self.left_arr:setAlign(kAlignCenter);
--    self.leftBtn:addChild(self.left_arr)
--    self:addChild(self.leftBtn)


--    local func = function(view,enable)
----        local title = view:getChildByName("title");
--        if view then
--            if enable then
--                view:removeProp(1);
--            else
--                view:addPropScaleSolid(1,1.1,1.1,1);
--            end
--        end
--    end
--    self.leftBtn:setOnClick(self,self.leftBtnClick)
--    self.leftBtn:setOnTuchProcess(self.leftBtn,func);
--    self.rightBtn:setOnClick(self,self.rightBtnClick)
--    self.rightBtn:setOnTuchProcess(self.rightBtn,func);

--end

----[Comment]
----左侧按钮点击
--function SwitchSelectNode.leftBtnClick(self)
--    if not self.index or self.index == 1 then
--        print_string("已经在最左边了")
--        return
--    end
--    self.index = self.index - 1
--    self:setSelectText()
--end

----[Comment]
----右侧按钮点击
--function SwitchSelectNode.rightBtnClick(self)
--    local maxIndex = #self.plist
--    if not self.index or self.index == maxIndex then
--        print_string("已经在最右边了")
--        return
--    end
--    self.index = self.index + 1
--    self:setSelectText()
--end

----[Comment]
----设置当前位置
--function SwitchSelectNode.setIndex(self,index)
--    self.index = index or 1
--    self:setSelectText()
--end

----[Comment]
----设置当前位置文本
--function SwitchSelectNode.setSelectText(self,index)
--    local index = self.index or 1
--    local text = self.plist[index] or ""
--    self.text:setText(text)
--end

----[Comment]
----获得当前选择
--function SwitchSelectNode.getSelectIndex(self)
--    return self.index or 1
--end