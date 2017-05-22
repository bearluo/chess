--ChessSociatyModuleNode.lua
--Date 2016.8.26
-- 棋社管理和弹窗成员信息node
--endregion

require(VIEW_PATH .. "sociaty_module_node")

ChessSociatyModuleNode = class(Node)

ChessSociatyModuleNode.s_w = 636
ChessSociatyModuleNode.s_h = 132
ChessSociatyModuleNode.s_check_mode   = 1; --查看弹窗node
ChessSociatyModuleNode.s_member_mode  = 2; --成员管理
ChessSociatyModuleNode.s_vice_mode    = 4; --副社长管理
ChessSociatyModuleNode.s_apply_mode   = 3; --申请管理


function ChessSociatyModuleNode.ctor(self,data,nodeType,handler)
    if not data then return end
--    if index then 
--        self.index = index
--    end
    self.handler = handler
    self.data = data
    self.nodeType = nodeType or ChessSociatyModuleNode.s_check_mode

    self:setSize(ChessSociatyModuleNode.s_w,ChessSociatyModuleNode.s_h)
    self:setAlign(kAlignTop)
    self:setPos(0,0)

    self.root_view = SceneLoader.load(sociaty_module_node);
    self.node = self.root_view:getChildByName("view");
    self:addChild(self.root_view);
    
    self.icon_bg = self.node:getChildByName("icon_bg");
    self.icon = new(Mask,"common/background/head_mask_bg_86.png","common/background/head_mask_bg_86.png");
    self.icon:setSize(84,84);
    self.icon:setAlign(kAlignCenter);
    self.icon_bg:addChild(self.icon)
    self.name = self.node:getChildByName("name");
    self.level = self.node:getChildByName("level");
    self.score = self.node:getChildByName("score");
    --职位view
    self.active_view = self.node:getChildByName("active_view");
    self.position = self.active_view:getChildByName("position");
    self.active_value = self.active_view:getChildByName("active_value");
    --按钮view
    self.button_view = self.node:getChildByName("button_view");
    self.left_btn = self.button_view:getChildByName("Button1");
    self.left_btn:setOnClick(self,self.onLeftBtnClick)
    self.left_btn_text = self.left_btn:getChildByName("text");
    self.right_btn = self.button_view:getChildByName("Button2");
    self.right_btn:setOnClick(self,self.onRightBtnClick)
    self.right_btn_text = self.right_btn:getChildByName("text");
    self.left_btn:setSrollOnClick()
    self.right_btn:setSrollOnClick()

    self:refreshView()
end

function ChessSociatyModuleNode.dtor(self)
    delete(self.node)
    self.node = nil;
end

--[Comment]
--刷新界面
function ChessSociatyModuleNode.refreshView(self)
    if self.nodeType == ChessSociatyModuleNode.s_check_mode then
        self.active_view:setPos(468,nil)
        self.active_view:setVisible(true)
        self.button_view:setVisible(false);
    elseif self.nodeType == ChessSociatyModuleNode.s_member_mode then
        self.active_view:setPos(308,nil)
        self.active_view:setVisible(true)
        self.button_view:setVisible(true);
--        self.right_btn:setFile({"common/button/dialog_btn_7_normal.png","common/button/dialog_btn_7_press.png"});
        self.left_btn_text:setText("提升");
        self.right_btn_text:setText("踢出");
        --判断成员类型 1是会长，2是副会长，3是普通成员
        if self.data.role then
            local role = tonumber(self.data.role)
            if role == 1 then
                self.left_btn:setVisible(false);
                self.right_btn:setVisible(false);
            elseif role == 2 then
                self.left_btn:setVisible(true);
                self.right_btn:setVisible(true);
                self.left_btn_text:setText("降级");
            elseif role == 3 then
                self.left_btn:setVisible(true);
                self.right_btn:setVisible(true);
                self.left_btn_text:setText("提升")
            end
        end 
    elseif self.nodeType == ChessSociatyModuleNode.s_apply_mode then
        self.active_view:setPos(308,nil)
        self.button_view:setVisible(true);
        self.active_view:setVisible(false)
--        self.right_btn:setFile({"common/button/dialog_btn_3_normal.png","common/button/dialog_btn_3_press.png"});
        self.left_btn_text:setText("拒绝");
        self.right_btn_text:setText("通过");
    elseif self.nodeType == ChessSociatyModuleNode.s_vice_mode then
        self.active_view:setPos(308,nil)
        self.active_view:setVisible(true)
        self.button_view:setVisible(true);
        if self.data.role then
            local role = tonumber(self.data.role) or 3
            if role == 3 then
                self.right_btn:setVisible(true);
            else
                self.right_btn:setVisible(false);
            end
        end 
--        self.right_btn:setFile({"common/button/dialog_btn_7_normal.png","common/button/dialog_btn_7_press.png"});
        self.left_btn:setVisible(false)
        self.right_btn_text:setText("踢出");
        local id = tonumber(self.data.mid) or 0
        if id == UserInfo.getInstance():getUid() then
            self.right_btn:setVisible(true);
            self.right_btn_text:setText("退出");
        end
    end

    local name = "博雅象棋"
    if self.data.mnick and type(self.data.mnick) == "string" and self.data.mnick ~= ""  then
        name = self.data.mnick
    end
    self.name:setText(name)
    self.level:setFile(string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevelByScore(self.data.score)));

    local score = self.data.score or "0"
    self.score:setText("积分:" .. score)

    local week_active = self.data.week_active or "0"
    self.active_value:setText("活跃:" .. week_active)

    local role = tonumber(self.data.role) or 3
    self.position:setText(ChesssociatyModuleConstant.role[role] or "普通成员")

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
end

function ChessSociatyModuleNode.onLeftBtnClick(self)
    if self.nodeType == ChessSociatyModuleNode.s_apply_mode then
        --拒绝添加成员
        if self.data then 
            local temp = {}
            temp.guild_id = tonumber(self.data.guild_id) or 0
            temp.target_mid = tonumber(self.data.mid )
            temp.op = ChesssociatyModuleConstant.s_manager_active["OP_REFUSE_MEMBER"];
            ChessSociatyModuleController.getInstance():onManagerSociaty(temp)
        end
        if self.handler then 
            self.handler:delMemberTab(ChessSociatyModuleNode.s_apply_mode,self,tonumber(self.data.mid) or 0 )
        end
        return
    end
    if self.nodeType == ChessSociatyModuleNode.s_member_mode then
        --升级或者降职（只有社长才能操作）
        local role = tonumber(self.data.role)
        if not role then return end
        local op = ChesssociatyModuleConstant.s_manager_active["OP_DEL_VP"] 
        if role == 1 then
            
        elseif role == 2 then
            op = ChesssociatyModuleConstant.s_manager_active["OP_DEL_VP"] 
        elseif role == 3 then
            op = ChesssociatyModuleConstant.s_manager_active["OP_ADD_VP"]
        end

        if self.data then 
            local temp = {}
            temp.guild_id = tonumber(self.data.guild_id) or 0 
            temp.target_mid = tonumber(self.data.mid) or 0
            temp.op = op
            local tab = {}
            tab.param = temp 
            HttpModule.getInstance():execute2(HttpModule.s_cmds.managerSociaty,tab,function(isSuccess,resultStr)
                if isSuccess then
                    local data = json.decode(resultStr)
                    if not data or data.error then 
                        local msg = data.error or "操作失败！"
                        ChessToastManager.getInstance():showSingle(msg) 
                        return
                    end
                    self:updataLeftBtnStatus()
                else 
                    ChessToastManager.getInstance():showSingle("操作失败！")
                end
            end);
        end
    end
end

function ChessSociatyModuleNode.onRightBtnClick(self)
    if self.nodeType == ChessSociatyModuleNode.s_apply_mode then
        --同意添加成员
        if self.data then 
            local temp = {}
            temp.guild_id = tonumber(self.data.guild_id) or 0 
            temp.target_mid = tonumber(self.data.mid) or 0 
            temp.op = ChesssociatyModuleConstant.s_manager_active["OP_ADD_MEMBER"];
            ChessSociatyModuleController.getInstance():onManagerSociaty(temp)
        end
        SociatyModuleData.getInstance():updataMemberData(1)
        if self.handler then 
            local memberData = SociatyModuleData.getInstance():getSociatyMemberData()
            if #memberData < 10 then
                SociatyModuleData.getInstance():clearSociatyMemberData()
                self.handler:resetMemberList()
            end
            self.handler:delMemberTab(ChessSociatyModuleNode.s_apply_mode,self,tonumber(self.data.mid) or 0)
        end
        return
    end
    if self.nodeType == ChessSociatyModuleNode.s_member_mode or self.nodeType == ChessSociatyModuleNode.s_vice_mode then
        --踢人
        if self.data then 
            local id = tonumber(self.data.mid) or 0 
            if tonumber(self.data.mid) == UserInfo.getInstance():getUid() then
                ChessSociatyModuleController.getInstance():onQuitSociaty(tonumber(self.data.guild_id))
                return
            end
            
            local temp = {}
            temp.guild_id = tonumber(self.data.guild_id) or 0
            temp.target_mid = id
            temp.op = ChesssociatyModuleConstant.s_manager_active["OP_DEL_MEMBER"];
            ChessSociatyModuleController.getInstance():onManagerSociaty(temp)
            SociatyModuleData.getInstance():updataMemberData(-1)
        end
        if self.handler then 
            self.handler:delMemberTab(ChessSociatyModuleNode.s_member_mode,self,tonumber(self.data.mid) or 0)
        end
        return
    end
end

function ChessSociatyModuleNode.updataLeftBtnStatus(self)
    local role = tonumber(self.data.role)
    if role == 2 then
        self.data.role = 3
        self.left_btn_text:setText("提升")
    elseif role == 3 then
        self.data.role = 2
        self.left_btn_text:setText("降级");
    end
    self.position:setText(ChesssociatyModuleConstant.role[self.data.role] or "普通成员")
end