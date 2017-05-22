--GiftDialog.lua
--Date 2016.8.4
--我的界面礼物弹窗
--endregion

require(VIEW_PATH .. "gift_dialog_view");
require(BASE_PATH.."chessDialogScene");

GiftDialog = class(ChessDialogScene,false);

function GiftDialog.ctor(self)
    super(self,gift_dialog_view);
    self.m_root_view = self.m_root;
    self:initView();
end

function GiftDialog.dtor(self)
    self.m_bg:removeProp(1)
    delete(self.m_root_view)
    self.m_root_view = nil
    self.mDialogAnim:stopAnim()
end

function GiftDialog.show(self)
    self:getGiftRankList()
    self.super.show(self,self.mDialogAnim.showAnim);
end

function GiftDialog.dismiss(self)
    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
end

function GiftDialog.isShowing(self)
    return self:getVisible();
end

function GiftDialog.initView(self)
    
    self.m_bg = self.m_root_view:getChildByName("bg")
    self.m_bg:setEventTouch(self,function() end);
    self:setShieldClick(self,self.dismiss)

    self.m_item_view = self.m_bg:getChildByName("item_view");
    self.rank_view = self.m_bg:getChildByName("list_view"):getChildByName("rank_view")

    self.gift_rank_list = new(ScrollView,0,0,604,640,true)
    self.gift_rank_list:setAlign(kAlignTop)
    self.rank_view:addChild(self.gift_rank_list)

    self.m_tips = self.m_bg:getChildByName("list_view"):getChildByName("tips")
    self.m_tips:setVisible(false)

    local scrSize = {w = 620,h = 150}
    local itemSize = {w = 150,h = 150}
    local bgSize = {w = 120,h = 40}
    self.giftScroller = new(GiftModuleScrollList,scrSize,itemSize,bgSize,GiftModuleItem.s_mode_user,self)
--    self.giftScroller:initScrollView(GiftModuleScrollList.s_lsize);
    self.m_item_view:addChild(self.giftScroller);
    local userGift = UserInfo.getInstance():getGift()
    self.giftScroller:onUpdateItem(userGift);
    self:setVisible(false);

    self.mDialogAnim = AnimDialogFactory.createMoveUpAnim(self)
end

function GiftDialog.getGiftRankList(self)
    local params = {};
    HttpModule.getInstance():execute2(HttpModule.s_cmds.getGiftWeekRank,params,function(isSuccess,resultStr)--,httpRequest)
        if isSuccess then
            local jsonData = json.decode(resultStr)
            local errorMsg = jsonData.error
            if errorMsg then
                ChessToastManager.getInstance():showSingle(errorMsg or "获得数据失败，请稍后再试") 
                return
            end
            local data = jsonData.data
--            local rankData = data.list
            if not data or type(data) ~= "table" then return end
            if self then
                self:updataRankList(data)
            end
        end
    end);
end

function GiftDialog.updataRankList(self,data)
    if next(data) == nil then 
        self.m_tips:setVisible(true)
        return 
    end
--    local data = {
--        [1] = { rank = 1,
--                mid = 1214,
--                icon_url = "http://192.168.100.157/cdn/chess/user_icon/1214/1214_icon.jpg?v=1473236971",
--                mnick = "haha ",
--                gift_num = 10,
--                score = 1000,
--               },
--        [2] = { rank = 2,
--                mid = 1214,
--                icon_url = "http://192.168.100.157/cdn/chess/user_icon/1214/1214_icon.jpg?v=1473236971",
--                mnick = "haha ",
--                gift_num = 10,
--                score = 1800,
--                },
--        [3] = { rank = 3,
--                mid = 1214,
--                icon_url = "http://192.168.100.157/cdn/chess/user_icon/1214/1214_icon.jpg?v=1473236971",
--                mnick = "haha ",
--                gift_num = 10,
--                score = 1900,
--                },
--        [4] = { rank = 4,
--                mid = 1214,
--                icon_url = "http://192.168.100.157/cdn/chess/user_icon/1214/1214_icon.jpg?v=1473236971",
--                mnick = "haha ",
--                gift_num = 10,
--                score = 1900,
--                },
--    }
    if self.gift_rank_list then
        self.gift_rank_list:removeAllChildren(true)
    end
    for k,v in ipairs(data) do
        if v then 
            local node = new(GiftRankItem,v)
            self.gift_rank_list:addChild(node)
        end 
    end
    self.m_tips:setVisible(false)
end

GiftRankItem = class(Node)

function GiftRankItem.ctor(self,data)
    if not data then return end
    self.data = data
    self:initView()
    self:updataView()
end

function GiftRankItem.dtor(self)
    

end

function GiftRankItem.initView(self)
    self:setSize(600,132)
    self:setAlign(kAlignTop)
    self:setPos(0,0)

    self.rank_img = new(Image,"")
    self.rank_img:setAlign(kAlignLeft)
    self.rank_img:setSize(70,80)
    self:addChild(self.rank_img)

    self.rankText = new(Text,"",nil,nil,nil,nil,30,80,80,80)
    self.rankText:setAlign(kAlignLeft)
    self.rankText:setPos(30,0)
    self:addChild(self.rankText)

    self.line = new(Image,"common/decoration/line_8.png")
    self.line:setAlign(kAlignLeft)
    self.line:setSize(1,110)
    self.line:setPos(92,0)
    self:addChild(self.line)

    self.icon = new(Image,"common/background/head_bg_92.png")
    self.icon:setAlign(kAlignLeft)
    self.icon:setPos(105,0)
    self:addChild(self.icon)

    self.mask = new(Mask,"common/background/head_mask_bg_86.png","common/background/head_mask_bg_86.png")
    self.mask:setAlign(kAlignCenter)
    self.icon:addChild(self.mask)

    self.level = new(Image,"common/icon/level_9.png")
    self.level:setAlign(kAlignBottom)
    self.level:setPos(0,-3)
    self.icon:addChild(self.level)

    self.name = new(Text,"",nil,nil,kAlignLeft,nil,30,80,80,80)
    self.name:setAlign(kAlignLeft)
    self.name:setPos(206,-28)
    self:addChild(self.name)

    self.text = new(Text,"赠送礼物总数:",nil,nil,kAlignLeft,nil,30,135,100,95)
    self.text:setAlign(kAlignLeft)
    self.text:setPos(206,26)
    self:addChild(self.text)

    self.gift_num = new(Text,"",nil,nil,kAlignLeft,nil,30,25,125,45)
    self.gift_num:setAlign(kAlignLeft)
    self.gift_num:setPos(414,26)
    self:addChild(self.gift_num)
end


function GiftRankItem.updataView(self)
    if not self.data then return end
    local name = self.data.mnick or ""
    self.name:setText(name)

    local num = self.data.gift_num or 1
    self.gift_num:setText(num)

    local iconFile = UserInfo.DEFAULT_ICON[1]
    if self.data.iconType == -1 then
        if not self.data.icon_url or self.data.icon_url == "" then
            self.mask:setFile(iconFile);
        else
            self.mask:setUrlImage(self.data.icon_url);
        end
    else
        iconFile = UserInfo.DEFAULT_ICON[self.data.iconType] or iconFile;
        self.mask:setFile(iconFile);
    end
    local score = self.data.score or 1000
    self.level:setFile("common/icon/level_"..(10 - UserInfo.getInstance():getDanGradingLevelByScore(score))..".png")

    local rank = self.data.rank or 0
    if rank then 
        if rank > 3 then
            self.rankText:setText(rank .. "")
            self.icon:setSize(70,70)
            self.mask:setSize(64,64)
            self.icon:setPos(115,0)
        elseif rank == 0 then

        else
            self.rank_img:setFile("rank/rank_medal" .. rank .. ".png")
        end
    end
end