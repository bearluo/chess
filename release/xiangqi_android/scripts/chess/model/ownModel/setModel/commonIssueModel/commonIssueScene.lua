--Author : FordFan
--Date   : 2016/4/28
--endregion

require(BASE_PATH.."chessScene");


CommonIssueScene = class(ChessScene);


CommonIssueScene.s_controls = 
{
    content_view                = 1;
    back_btn                    = 2;
    issue_view                  = 3;
}

CommonIssueScene.s_cmds = 
{

}


function CommonIssueScene:ctor(viewConfig,controller)
	self.m_ctrls = CommonIssueScene.s_controls;
    self:create();
end 

function CommonIssueScene:resume()
    ChessScene.resume(self);
    if not self.m_init then
        self.m_init = true;
        self:initIssueList();
    end
end

CommonIssueScene.isShowBangdinDialog = false;

function CommonIssueScene:pause()
	ChessScene.pause(self);
    self:removeAnimProp();
end 

function CommonIssueScene:dtor()
    delete(self.anim_start);
    delete(self.anim_end);
end 

function CommonIssueScene:removeAnimProp()
    if self.m_anim_prop_need_remove then
        self.m_book_mark:removeProp(1);
        self.m_leaf_left:removeProp(1);
        self.m_anim_prop_need_remove = false;
    end
end

function CommonIssueScene:setAnimItemEnVisible(ret)
    self.m_leaf_left:setVisible(ret);
end

function CommonIssueScene:resumeAnimStart(lastStateObj,timer)
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

    local lw,lh = self.m_leaf_left:getSize();
    self.m_leaf_left:addPropTranslate(1, kAnimNormal, waitTime, delay, -lw, 0, -10, 0);
    local tw,th = self.m_book_mark:getSize();
    local anim = self.m_book_mark:addPropTranslate(1, kAnimNormal, waitTime, delay, 0, 0, -th, 0);
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

function CommonIssueScene:pauseAnimStart(newStateObj,timer)
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

    local lw,lh = self.m_leaf_left:getSize();
    self.m_leaf_left:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, -lw, 0, -10);
    local w,h = self.m_book_mark:getSize();
    local anim = self.m_book_mark:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, 0, 0, -h);
    if anim then
        anim:setEvent(self,function()
            self:setAnimItemEnVisible(false);
        end);
    end
end

---------------------- func --------------------
function CommonIssueScene:create()
	self.m_back_btn = self:findViewById(self.m_ctrls.back_btn);
	self.m_content_view = self:findViewById(self.m_ctrls.content_view);
	self.m_issue_view = self:findViewById(self.m_ctrls.issue_view);
    self.m_leaf_left = self.m_content_view:getChildByName("left_leaf");
    self.m_book_mark = self.m_content_view:getChildByName("Image2");
end


function CommonIssueScene:onBackAction()
    self:requestCtrlCmd(CommonIssueController.s_cmds.onBack);
end

function CommonIssueScene:initIssueList()

    local w,h = self.m_issue_view:getSize();
    self.m_common_issue_list = new(ScrollView,0,0,w,h,true);
    self.m_issue_view:addChild(self.m_common_issue_list);
    self.m_common_issue_list:setOnScrollEvent(self,self.onScroll);

    local tab = CommonIssueScene.COMMON_TEXT;
    for k,v in pairs(tab) do
        v["handler"] = self;
    end
    for i = 1, #tab do
--    for k,v in pairs(CommonIssueScene.COMMON_TEXT) do
        local item = new(CommonIssueItem,CommonIssueScene.COMMON_TEXT[i]);
        self.m_common_issue_list:addChild(item);
    end
end

function CommonIssueScene:updataScrollerView()
    if self.m_common_issue_list then
        local x,y = self.m_common_issue_list:getScrollViewPos();
        self.m_common_issue_list:updateScrollView();
        local viewLength = self.m_common_issue_list:getViewLength(); -- 界面长度
        local frameLength = self.m_common_issue_list:getFrameLength(); -- 可见区域长度
        if viewLength > frameLength and y < frameLength - viewLength then
            y = frameLength - viewLength;
        elseif viewLength <= frameLength then
            y = 0;
        end
        self.m_common_issue_list:scrollToPos(y + 10);
    end
end

---------------------- config ------------------
CommonIssueScene.s_controlConfig = {
    [CommonIssueScene.s_controls.content_view]                   = {"bg"};
    [CommonIssueScene.s_controls.issue_view]                     = {"bg","issue_view"};
    [CommonIssueScene.s_controls.back_btn]                       = {"bg","back_btn"};

}

CommonIssueScene.s_controlFuncMap = {
    [CommonIssueScene.s_controls.back_btn]                       = CommonIssueScene.onBackAction;
};

CommonIssueScene.s_cmdConfig =
{
    
}

CommonIssueScene.COMMON_TEXT = 
{
    [1] = {
        ["title"] = "支付不成功或不到账问题",
        ["text"]  = "网络不好、付费限制等原因都可能导致支付不成功，请更换网络后重新尝试，如支付成功却没到账，可能是由于网络等原因造成延时，若最终仍没到账，请联系客服，我们会尽快处理。"
    },
    [2] = {
        ["title"] = "没有好友怎么办",
        ["text"]  = "关注棋友成为对方的粉丝，可以围观对方对局、给对方留言和挑战对方 。互相关注的棋友会成为好友，好友间可以随时交流、对弈，查看对手收藏的棋谱。"},
    [3] = {
        ["title"] = "怎么赚取更多金币呢？",
        ["text"]  = "小雅每天为您提供丰厚的登陆奖励、任务奖励和破产补助，联网游戏、过关单机或残局、参与活动都能获得奖励。成为会员每天还有额外的免费奖励和专属的会员视觉装扮。"},
    [4] = {
        ["title"] = "象棋基本说明",
        ["text"]  = "“棋盘”上各线段相交形成九十个交叉点，棋子需摆在交叉点上。第五、第六两横线之间称为“河界”，棋盘以此分为两半；双方各占一边，分执棋子进行对弈，将帅直接坐镇“九宫”，即“米”字方格内。"},
    [5] = {
        ["title"] = "棋子的基本走法",
        ["text"]  = "将/帅--每步可在九宫内平行移动一点。#l士/仕--每步可沿九宫内对角线移动一点。#l相/象--每步可在己方侧沿对角线移动两点，不可穿越障碍。#l马--每步可平行移动一点，再沿对角线左右移动，不可穿越障碍。#l车--每步可平行移动任意个无阻碍的点。#l炮--每步可平行移动任意个无阻碍的点，需跳过一个棋子才可吃子。#l兵--在己侧每步只能向前移动一点，过河后，每步可向前或左右移动一点。"},
    [6] = {
        ["title"] = "棋局的局时、步时和读秒",
        ["text"]  = "棋局中，局时内，每步都必须在步时规定时间内完成，走下一步时，步时重新计算。局时超时后，每步都必须在读秒规定时间内完成。“步时”与“读秒”超时，棋局结束，超时者判负。不读秒时，局时超时判负。"},
    [7] = {
        ["title"] = "胜负的判别基准",
        ["text"]  = "1）对局时，以下情况判负，对方取胜:#l 被“将死”，被对方将军却无法应将;#l 被“困毙”，虽未被将死，却无子可走;#l 一方认输#l 长将不变算负。#l 步时或读秒超时#l2）以下情况算和局: 一方提议作和，对方同意;#l 任意一步始，六十回合内双方均无吃子。#l3）单机模式中，重来算负。双方均无获胜可能算和。"},
    [8] = {
        ["title"] = "联网对战的积分规则",
        ["text"]  = "为了保证积分的公平合理，每场联网对弈所获得或损失的积分，都是根据双方的棋力、积分、胜率等综合计算的。"},
    [9] = {
        ["title"] = "平、进、退",
        ["text"]  = "棋盘上下九格，进是向对方走，退是向自己走；左右九格，移动叫平，从右往左起排序如兵五进一，表示中兵前进一步；车二进六表示二路车向前走六步"},
}


CommonIssueItem = class(Node);

CommonIssueItem.ITEM_WIDTH = 545;
CommonIssueItem.MIN_HEIGHT = 70; --item最小高度
CommonIssueItem.LAUNCH_ITEM = 1;
CommonIssueItem.RETRACT_ITEM = -1;
CommonIssueItem.DEFAULT_STATUS = 0;
CommonIssueItem.ANIM_TIME = 160;


function CommonIssueItem:ctor(data)
    if not data then return end
    
    self:setPos(0,0);
    self.m_data = data;
    self.handler = self.m_data["handler"];
--    self.m_show_status = false;
    self.m_button = new(Button,"drawable/blank.png","drawable/blank_press.png");
    self.m_button:setSize(CommonIssueItem.ITEM_WIDTH,65);
    self.m_button:setAlign(kAlignTop);
    local msg = self.m_data["title"];
    self.m_button_text = new(Text,msg,nil,nil,nil,nil,36,135,100,95);
    self.m_button_text:setAlign(kAlignLeft);
    self.m_button:addChild(self.m_button_text);
    self.m_button_status_img = new(Image,"common/icon/launch_icon.png");
    self.m_button_status_img:setAlign(kAlignRight);
    self.m_button:addChild(self.m_button_status_img);
    self.m_button:setOnClick(self,self.btnClick);
    self.m_button:setSrollOnClick(nil,function() end);

    


    self.m_bottom_line = new(Image,"common/decoration/line_2.png");
    self.m_bottom_line:setSize(556,2);
    self.m_bottom_line:setAlign(kAlignBottom);

    self.m_status = CommonIssueItem.DEFAULT_STATUS;
    self:setSize(CommonIssueItem.ITEM_WIDTH,CommonIssueItem.MIN_HEIGHT);
    self.m_clip_view = new(Node);
    self.m_clip_view:setFillParent(true,true);
    self.m_clip_view:addChild(self.m_bottom_line);
    self.m_clip_view:addChild(self.m_button);
    self:addChild(self.m_clip_view);
    self.m_clip_view:setClip(0,0,CommonIssueItem.ITEM_WIDTH,CommonIssueItem.MIN_HEIGHT);
end

function CommonIssueItem:dtor()

end

function CommonIssueItem:initItem()

end

function CommonIssueItem:launchText()
    self.m_status = CommonIssueItem.LAUNCH_ITEM;
    if self.m_launch_anim then 
        delete(self.m_launch_anim);
        self.m_launch_anim = nil;
    end
    if self.m_anim_timer then 
        delete(self.m_anim_timer);
        self.m_anim_timer = nil;
    end

    self.m_launch_anim = new(AnimInt,kAnimLoop,0,1,1000/60,-1);
    if self.m_launch_anim then
        self.m_launch_anim:setEvent(self,self.addItemHeight);
    end

end

function CommonIssueItem:retractText()
    self.m_status = CommonIssueItem.RETRACT_ITEM;
    if self.m_launch_anim then 
        delete(self.m_launch_anim);
        self.m_launch_anim = nil;
    end
    if self.m_anim_timer then 
        delete(self.m_anim_timer);
        self.m_anim_timer = nil;
    end

    self.m_up_anim = new(AnimInt,kAnimLoop,0,1,1000/60,-1);
    if self.m_up_anim then
        self.m_up_anim:setEvent(self,self.reduceItemHeight);
    end
end

function CommonIssueItem:addItemHeight()
    if not self.m_issue_text then 
        print_string("self.m_issue_text not init");
        return;
    end
    local w,h = self:getSize();
    local speed = math.ceil((self.m_text_h + 10)/9);
   
    if h >= CommonIssueItem.MIN_HEIGHT and h < (CommonIssueItem.MIN_HEIGHT+self.m_text_h) then
        self.m_clip_view:setClip(0,0,CommonIssueItem.ITEM_WIDTH,h + speed);
        self:setSize(CommonIssueItem.ITEM_WIDTH,h + speed);
    else
        self:stopAnim();
    end
    self.handler:updataScrollerView();
end

function  CommonIssueItem:reduceItemHeight()
    if not self.m_issue_text then 
        print_string("self.m_issue_text not init");
        return;
    end
    local w,h = self:getSize();
    local speed = math.ceil((self.m_text_h + 10)/9);
    if h > CommonIssueItem.MIN_HEIGHT then
        self.m_clip_view:setClip(0,0,CommonIssueItem.ITEM_WIDTH,h - speed);
        self:setSize(CommonIssueItem.ITEM_WIDTH,h - speed);
    else
        self:stopAnim();
    end
    self.handler:updataScrollerView();
end

function CommonIssueItem:stopAnim()
    self.m_status = CommonIssueItem.DEFAULT_STATUS;
    
    if self.m_launch_anim then 
        delete(self.m_launch_anim);
        self.m_launch_anim = nil;
    end
    if self.m_up_anim then 
        delete(self.m_up_anim);
        self.m_up_anim = nil;
    end
end

function CommonIssueItem:btnClick()
    local w,h = self:getSize();
    if self.m_status == CommonIssueItem.RETRACT_ITEM or self.m_status == CommonIssueItem.LAUNCH_ITEM then
        return
    end
    self:createIssueText();
    if h > CommonIssueItem.MIN_HEIGHT then
        self.m_button_status_img:setFile("common/icon/launch_icon.png");
        self:retractText();
    elseif h <= CommonIssueItem.MIN_HEIGHT then
        self.m_button_status_img:setFile("common/icon/up_icon.png");
        self:launchText();
    end
end

function CommonIssueItem:createIssueText()
    if not self.m_issue_text then
        self.m_issue_text = new(RichText,self.m_data["text"],545,nil,kAlignTopLeft,nil,28,80,80,80,true,10);
        self.m_issue_text:setAlign(kAlignTop);
        self.m_issue_text:setPos(0,72);
        local w,h = self.m_issue_text:getSize();
        self.m_text_h = h;
        self.m_clip_view:addChild(self.m_issue_text);
    end
end