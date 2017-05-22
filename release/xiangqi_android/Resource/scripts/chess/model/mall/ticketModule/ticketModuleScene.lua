--region ticketModuleScene.lua
--Date 2016.11.12
--
--endregion

require("dialog/ticket_check_dialog")
require(BASE_PATH.."chessScene");

TicketModuleScene = class(ChessScene);

TicketModuleScene.s_cmds = 
{
    updata_ticket_list = 1
}


function TicketModuleScene.ctor(self,viewConfig,controller)
    self.m_ctrls = TicketModuleScene.s_controls;
    self:initView();
end

function TicketModuleScene.dtor(self)
    
end

function TicketModuleScene.resume(self)
    ChessScene.resume(self);
end

function TicketModuleScene.pause(self)
    ChessScene.pause(self);
end

function TicketModuleScene.setAnimItemEnVisible(self,ret)
    self.m_left_leaf:setVisible(ret);
    self.m_right_leaf:setVisible(ret);
end

function TicketModuleScene.removeAnimProp(self)
    self.m_left_leaf:removeProp(1);
    self.m_right_leaf:removeProp(1);
end


function TicketModuleScene.resumeAnimStart(self,lastStateObj,timer)
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;
    delete(self.anim_start);
    self.anim_start = new(AnimInt,kAnimNormal,0,1,delay,-1);
    if self.anim_start then
        self.anim_start:setEvent(self,function()
            self:setAnimItemEnVisible(true);
               delete(self.anim_start);
        end);
    end

    local lw,lh = self.m_left_leaf:getSize();
    self.m_left_leaf:addPropTranslate(1,kAnimNormal,waitTime,delay,-lw,0,-10,0);
    local rw,rh = self.m_right_leaf:getSize();
    local anim = self.m_right_leaf:addPropTranslate(1,kAnimNormal,waitTime,delay,rw,0,-10,0);
    if anim then
        anim:setEvent(self,function()
            self.m_anim_prop_need_remove = true;
            self:removeAnimProp();
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end  
        end);   
    end
end

function TicketModuleScene.pauseAnimStart(self,newStateObj,timer)
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;
    delete(self.anim_end);
    self.anim_end = new(AnimInt,kAnimNormal,0,1,delay,-1);
    if self.anim_end then
        self.anim_end:setEvent(self,function()
            self.m_anim_prop_need_remove = true;
            self:removeAnimProp();
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end  
            delete(self.anim_end);
        end);
    end

    local lw,lh = self.m_left_leaf:getSize();
    self.m_left_leaf:addPropTranslate(1,kAnimNormal,waitTime,delay,-lw,0,-10,0);
    local rw,rh = self.m_right_leaf:getSize();
    local anim = self.m_right_leaf:addPropTranslate(1,kAnimNormal,waitTime,delay,rw,0,-10,0);
    if anim then
        anim:setEvent(self,function()
            self:setAnimItemEnVisible(false);
        end);
    end
end

function TicketModuleScene.initView(self)
    
    self.m_top_view = self.m_root:getChildByName("View"):getChildByName("top_view");
    self.m_left_leaf = self.m_root:getChildByName("View"):getChildByName("l_leaf");
    self.m_right_leaf = self.m_root:getChildByName("View"):getChildByName("r_leaf");

    self.m_left_leaf:setFile("common/decoration/left_leaf.png")
    self.m_right_leaf:setFile("common/decoration/right_leaf.png")

    self.m_back_btn = self.m_root:getChildByName("View"):getChildByName("back_btn");
    self.m_tips = self.m_root:getChildByName("View"):getChildByName("tips");
    self.m_back_btn:setOnClick(self,function()
        self:requestCtrlCmd(TicketModuleController.s_cmds.onBack)

    end)

    self.ticket_view = self.m_root:getChildByName("View"):getChildByName("ticket_list")
    self.ticket_scroll_list = new(ScrollView,0,0,640,1110,true)
    self.ticket_scroll_list:setAlign(kAlignTop)
    self.ticket_view:addChild(self.ticket_scroll_list)

end

--更新参赛券列表
function TicketModuleScene.onUpdataTicket(self,data)
    local data = UserInfo.getInstance():getTicketData()
    self.ticket_data = data
    local ticketNum = 0
    
--    local data = {
--        [1] = {
--            prop_id = 2,
--            prop_num = 11,
--            start_time = "1478593729",
--            end_time = "1498013325",
--            pid = 109, 
--            is_enabled = 1,
--            imgurl = "",
--            desc = "呵呵",
--            name = "华为特约邀请赛参赛券",
--        }
--    }
    if not data or next(data) == nil then 
        self.m_tips:setVisible(true)
        return 
    end
    if self.ticket_scroll_list then
        self.ticket_scroll_list:removeAllChildren(true)
    end

    for k,v  in pairs(data) do
        if v then
            v.handler = self
            local node = new(TicketNode,v)
            self.ticket_scroll_list:addChild(node)
        end
    end
    local tab = self.ticket_scroll_list:getChildren()
    if tab and #tab < 1 then
        self.m_tips:setVisible(true)
    else
        self.m_tips:setVisible(false)
    end
end

--查看参赛券
function TicketModuleScene.checkTicket(self,data)
    if not self.ticket_check_dialog then
        self.ticket_check_dialog = new(TicketCheckDialog)
    end
    if self.ticket_check_dialog:isShowing() then return end
    self.ticket_check_dialog:setData(data)
    self.ticket_check_dialog:setStyle(tonumber(data.pid))
    self.ticket_check_dialog:show()
end


TicketModuleScene.s_cmdConfig =
{   
    [TicketModuleScene.s_cmds.updata_ticket_list]                   = TicketModuleScene.onUpdataTicket;
}


TicketNode = class(Node)

function TicketNode.ctor(self,data)
    if not data then return end
    self.data = data
    self.handler = data.handler
    self:setSize(638,210)
    self:setPos(kAlignTop)
    self.switch = {
        [109] = function()
            self:initOnlineView()
        end,
        [111] = function()
            self:initOfflineView()
        end,
    }
    self:setStyle()
    self.button = new(Button,"drawable/blank.png")
    self.button:setSize(638,182)
    self.button:setOnClick(self,self.itemClick)
    self:addChild(self.button)
end

function TicketNode.dtor(self)

end

function TicketNode.setStyle(self)
    local style = tonumber(self.data.pid) or 109
    local f = self.switch[style]
    if f then
        f()
    end
end

--设置线上参赛券
function TicketNode.initOnlineView(self)
    local start_time = tonumber(self.data.start_time ) or  0
    local end_time = tonumber(self.data.end_time ) or  0
    local img = "mall/online_ticket.png"
    if end_time > start_time then
        
    else
        img = "mall/online_ticket_timeout.png"
    end
    self.ticket_bg = new(Image,img)
    self.ticket_bg:setPos(0,-2)
    self:addChild(self.ticket_bg)

    self.icon = new(Image,"mall/chess_icon.png")
    self.icon:setPos(36,32)
    self:addChild(self.icon)

    local name = self.data.goods_name or ""
    self.title = new(Text,name,nil,nil,nil,nil,40,255,255,255)
    self.title:setPos(222,30)
    self:addChild(self.title)

    local start_str = os.date("%Y.%m.%d",start_time)
    local end_str = os.date("%Y.%m.%d",end_time)
    local str = start_str .. "-" .. end_str
    self.time = new(Text,str,nil,nil,nil,nil,24,255,255,255)
    self.time:setPos(222,130)
    self:addChild(self.time)

    self.offline = new(Text,"线上邀请赛",nil,nil,nil,nil,24,255,255,255)
    self.offline:setPos(222,100)
    self:addChild(self.offline)
end

--设置线下参赛券
function TicketNode.initOfflineView(self)
    local start_time = tonumber(self.data.start_time ) or  0
    local end_time = tonumber(self.data.end_time ) or  0
    local img = "mall/offline_ticket.png"
    if end_time > start_time then
        
    else
        img = "mall/offline_ticket_timeout.png"
    end
    self.ticket_bg = new(Image,img)
    self.ticket_bg:setPos(0,-2)
    self:addChild(self.ticket_bg)

    self.icon = new(Image,"mall/chess_icon.png")
    self.icon:setPos(36,10)
    self:addChild(self.icon)

    local name = self.data.goods_name or ""
    self.title = new(Text,name,nil,nil,nil,nil,40,255,255,255)
    self.title:setPos(182,32)
    self:addChild(self.title)

    local start_str = os.date("%Y.%m.%d",start_time)
    local end_str = os.date("%Y.%m.%d",end_time)
    local str = start_str .. "-" .. end_str
    self.time = new(Text,str,nil,nil,nil,nil,24,255,255,255)
    self.time:setPos(190,88)
    self:addChild(self.time)

    self.offline = new(Text,"线下邀请赛",nil,nil,nil,nil,24,130,130,130)
    self.offline:setPos(42,166)
    self:addChild(self.offline)
end

function TicketNode.itemClick(self)
    if self.handler then
        self.handler:checkTicket(self.data)
    end
end