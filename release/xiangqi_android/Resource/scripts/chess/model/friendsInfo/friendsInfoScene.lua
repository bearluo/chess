require(BASE_PATH.."chessScene");
require("dialog/chioce_dialog");
require("dialog/big_head_dialog");
require("dialog/friend_chat_dialog");
require("view/view_config");
require(VIEW_PATH.."friend_info_record_item");
require(VIEW_PATH.."friend_info_honor_item");
--require(MODEL_PATH .. "giftModule/giftModuleScrollList")
require(MODEL_PATH .. "replay/replayChessItem")
require("dialog/create_and_check_sociaty_dialog")

FriendsInfoScene = class(ChessScene);

FriendsInfoScene.s_state_info      = 1; --好友信息
FriendsInfoScene.s_state_recommend = 2; --棋局推荐

FriendsInfoScene.ITEM_HEIGHT = 150  --item的高度

FriendsInfoScene.s_controls = 
{
	back_bn    = 1; --返回
    friendsinfo_icon_mask = 2; --头像背景
    name = 3; --名字
    sex_img = 4; --性别
    level = 5; --等级
    follow_bn  = 6;--关注按钮
    bottome_operate_view = 7;   --底部按钮栏
    send_message_bn = 8;        --发送信息按钮
    send_message_tx =9;         --发送信息文字标识
    challenge_btn = 10;--观战、挑战、不在线按钮
    challenge_tittle = 11;--观战、挑战、不在线文字标识
    reportBad_btn = 12;--举报用户
    content = 13;   --整个用户详细信息页面
    id = 14;
    honor_img = 15;                --荣耀徽章
    recent_login_time_tx = 16;     --最近登录时间
  
    info_view = 17;  --好友个人详细信息介绍
    chess_team_yes = 18;  --加入的社团
    chess_team_no = 19;
    --team_position           = 34;  --社团中的职务
    --btn_view                = 35;

    city_info = 20;
    signature_txv = 21;             --用户签名
    signature_editv = 22;           --个人签名编辑
    --my_intro                = 43;
    add_blacklist_btn = 23;        --添加黑名单
    mor_btn_view = 24;             --更多的信息弹窗
    more_btn = 25;                 --更多按钮

    record_bn = 26;                --战绩             
    honor_bn = 27;                 --荣誉
    replay_bn = 28;                --推荐棋谱

    replay_item = 29;              --战绩页面
    honor_item = 30;               --荣誉页面
    record_item = 31;              --推荐棋谱页面       

} 

--scene定义的暴露给controller调用的接口函数
FriendsInfoScene.s_cmds = 
{
    changeFriendTile    = 1;
    changePaiHang       = 2;
    changeFriendsRank   = 3;
    changeFriendstatus  = 4;
    changeFriendsData   = 5;
    change_userIcon     = 6;
    recv_chat_msg_state = 7;
    friends_num         = 8;
    follow_num          = 9;
    fans_num            = 10;
    get_suggestchess    = 11;
    save_mychess        = 12;
    modify_sign         = 13;
    updataWinCombo      = 14;

    updateRecordData    = 15;

    updateHonorData     = 16;
    setShowUserViewMid  = 17;
}

FriendsInfoScene.matchType = {
    [12] = "挑战赛",
    [13] = "职业赛",
    [14] = "名人赛",
}

FriendsInfoScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = FriendsInfoScene.s_controls;
    FriendsInfoController.friendsID = controller.m_state.m_uid;
    self.expose_emid = controller.m_state.m_uid;
    self.curr_state = FriendsInfoScene.s_state_info;
    if UserInfo.getInstance():getUid() == FriendsInfoController.friendsID then
        self.isMe = true
        self.intent = UserInfo.getInstance()
    else
        self.isMe = false
    end 
    self:init();
end 

FriendsInfoScene.resume = function(self)
    ChessScene.resume(self);
--    self:reset();
--    self:removeAnimProp();
--    self:resumeAnimStart();
end;

FriendsInfoScene.pause = function(self)
	ChessScene.pause(self);
    self:removeAnimProp();
--    self:pauseAnimStart();
end 

FriendsInfoScene.dtor = function(self)
    if self.p_bigHeadDialog then
        delete(self.p_bigHeadDialog);
        self.p_bigHeadDialog = nil;
    end
    if self.m_friend_chat_dialog then
        delete(self.m_friend_chat_dialog);
        self.m_friend_chat_dialog = nil;
    end
    delete(self.m_anim_start);
    delete(self.m_anim_end);
    delete(self.popAnim);
    self.popAnim = nil
end 

FriendsInfoScene.removeAnimProp = function(self)
    self.m_contentView:removeProp(1);
--    self.m_back_btn:removeProp(1);
--    self.m_book_mark:removeProp(1);
    --self.m_leaf_left:removeProp(1);
    --self.m_leaf_right:removeProp(1);
--    self.m_teapot_dec:removeProp(1);
--    self.m_stone:removeProp(1);
--    self.challenge_btn:removeProp(1);
--    self.send_message_bn:removeProp(1);
--    self.challenge_btn:removeProp(1);
end
--[[
FriendsInfoScene.setAnimItemEnVisible = function(self,ret)
    self.m_leaf_left:setVisible(ret);
    self.m_leaf_right:setVisible(ret);
end
]]--
FriendsInfoScene.resumeAnimStart = function(self,lastStateObj,timer)
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;
    delete(self.m_anim_start);
    self.m_anim_start = new(AnimInt,kAnimNormal,0,1,delay,-1);
    if self.m_anim_start then
        self.m_anim_start:setEvent(self,function()
            --self:setAnimItemEnVisible(true);
            delete(self.m_anim_start);
        end);
    end

    self.m_contentView:addPropTransparency(1,kAnimNormal,waitTime,delay,0,1);
    --local lw,lh = self.m_leaf_left:getSize();
    --self.m_leaf_left:addPropTranslate(1, kAnimNormal, waitTime, delay, -lw, 0, -10, 0);
    --local rw,rh = self.m_leaf_right:getSize();
    --local anim = self.m_leaf_right:addPropTranslate(1, kAnimNormal, waitTime, delay, rw, 0, -10, 0);
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

FriendsInfoScene.pauseAnimStart = function(self,newStateObj,timer)
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;
    delete(self.m_anim_end);
    self.m_anim_end = new(AnimInt,kAnimNormal,0,1,delay,-1);
    if self.m_anim_end then
        self.m_anim_end:setEvent(self,function()
            self.m_anim_prop_need_remove = true;
            self:removeAnimProp();
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end  
            delete(self.m_anim_end);
        end);
    end

    self.m_contentView:addPropTransparency(1,kAnimNormal,waitTime,-1,1,0);
    --local lw,lh = self.m_leaf_left:getSize();
    --self.m_leaf_left:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, -lw, 0, -10);
    --local rw,rh = self.m_leaf_right:getSize();
    --local anim = self.m_leaf_right:addPropTranslate(1, kAnimNormal, waitTime, -1,  0, rw, 0, -10);
    if anim then
        anim:setEvent(self,function()
            --self:setAnimItemEnVisible(false);
        end);
    end

end

--格式化时间
FriendsInfoScene.getTime = function(time)
--	if time < 0 then
--		return "一天前";
--	end
    if time then 
	    return os.date("%Y/%m/%d %H:%M",time);--%Y/%m/%d %X
    else 
        return ""
    end
end

----------------------------------- function ----------------------------
FriendsInfoScene.init = function(self)
    self.getUserDataTimes = 0
    self.updateRecordDataTimes = 0
    self.updateHonorDataTimes = 0
    self.needGetRecommendData = true   --是否需要获取推荐棋谱信息，true表示需要，false表示不需要
    self.getRecordDataLock = false     --获取战绩信息的锁，一开始是解锁的
    self.getHonorDataLock = false      --获取荣誉信息的锁，一开始是解锁的

    self.m_info_view = self:findViewById(self.m_ctrls.info_view);--棋友信息

    self.icon_mask = self:findViewById(self.m_ctrls.friendsinfo_icon_mask); -- 头像背景
    self.friendsinfo_icon = new(Mask,UserInfo.DEFAULT_ICON[1],"common/background/head_mask_bg_150.png");
    self.friendsinfo_icon:setAlign(kAlignCenter);
    self.friendsinfo_icon:setSize(self.icon_mask:getSize());
    self.icon_mask:addChild(self.friendsinfo_icon);

    --self.no_sociaty_tips = self:findViewById(self.m_ctrls.no_sociaty_tips); -- 头像背景
    self.name = self:findViewById(self.m_ctrls.name); -- 名字
    self.sex_img = self:findViewById(self.m_ctrls.sex_img);-- 性别 1男 2女 
    --self.sex0 = self:findViewById(self.m_ctrls.sex0);--性别 保密
--    self.time = self:findViewById(self.m_ctrls.time);-- 登陆时间
--    self.time:setTransparency(0.6)
    --self.money = self:findViewById(self.m_ctrls.money);--金币
    self.m_id = self:findViewById(self.m_ctrls.id);--ID
    self.honor_img = self:findViewById(self.m_ctrls.honor_img)
    self.recent_login_time_tx = self:findViewById(self.m_ctrls.recent_login_time_tx); 
    self.chessTeam_yes = self:findViewById(self.m_ctrls.chess_team_yes); --社团
   
    --self.chessTeamPosition = self.chessTeam_yes:getChildByName("position_tx") --社团职位
    self.chessTeam_icon = self.chessTeam_yes:getChildByName("chess_icon") --棋社图标
    --现在棋社名称和社团职位合在一起了
    self.chessTeam_name = self.chessTeam_yes:getChildByName("association_name_tx")

    self.chessTeam_no = self:findViewById(self.m_ctrls.chess_team_no)
    --动画控件
    self.m_contentView = self:findViewById(self.m_ctrls.content);  -- 界面
    --self.m_leaf_left = self:findViewById(self.m_ctrls.left_leaf);
    --self.m_teapot_dec = self:findViewById(self.m_ctrls.tea_cup);
    --self.m_leaf_right = self:findViewById(self.m_ctrls.right_leaf);

    --self.m_leaf_left:setFile("common/decoration/left_leaf.png")
    --self.m_leaf_right:setFile("common/decoration/right_leaf.png")

    self.m_back_btn = self:findViewById(self.m_ctrls.back_bn);
    --self.m_stone = self:findViewById(self.m_ctrls.stone);
    self.level = self:findViewById(self.m_ctrls.level);-- 等级
   -- self.charm_num = self:findViewById(self.m_ctrls.charm_num);--魅力值
    --self.gift_num = self:findViewById(self.m_ctrls.gift_num);--礼物数量

    self.city_info = self:findViewById(self.m_ctrls.city_info); 
    self.signature_txv = self:findViewById(self.m_ctrls.signature_txv
    ); --个性签名
    self.signature_editv = self:findViewById(self.m_ctrls.signature_editv); --个性签名编辑
    self.signature_editv:setOnTextChange(self,self.onEditTextChange)

    self.follow_bn = self:findViewById(self.m_ctrls.follow_bn);--关注按钮
    self.follow_bn:setOnClick(self,self.onSelectChangeClick);
    self.follow_tx = self.follow_bn:getChildByName("follow_tx");
    self.follow_img = self.follow_bn:getChildByName("follow_img");

    self.bottome_opearate_view = self:findViewById(self.m_ctrls.bottome_operate_view)
    self.challenge_btn = self:findViewById(self.m_ctrls.challenge_btn);--挑战，观战按钮
    self.challenge_tittle = self:findViewById(self.m_ctrls.challenge_tittle); -- 观战标题
    self.send_message_bn = self:findViewById(self.m_ctrls.send_message_bn);--消息按钮
    self.send_message_tx = self:findViewById(self.m_ctrls.send_message_tx);
    self.reportBad_btn = self:findViewById(self.m_ctrls.reportBad_btn);--举报按钮
    self.mor_btn_view  = self:findViewById(self.m_ctrls.mor_btn_view);--更多界面
    self.mor_btn_view:setVisible(false)
    self.is_show_more_view = false 
    self.more_btn = self:findViewById(self.m_ctrls.more_btn);--更多界面
    self.more_btn:setOnClick(self,function()
        if not self.is_show_more_view then
            self.mor_btn_view:setVisible(true)
        else
            self.mor_btn_view:setVisible(false)
        end
        self.is_show_more_view = not self.is_show_more_view
    end)

    --self:initInfoView()
    self:initTopButton()
    self:initRecordItem()
    self:initHonorItem()
    self:initRecommendView()   
    self:initReplayListView()
    self:initReplayItemRoom()
       
    --vip
    self.m_vip_frame = self.m_contentView:getChildByName("icon_bg"):getChildByName("vip_frame"); 
end

function FriendsInfoScene:setShowUserViewMid(uid)
    --获取用户数据
    local datas = FriendsData.getInstance():getUserData(uid); --用户详细数据
    if not self.isMe then
        local status = FriendsData.getInstance():getUserStatus(uid);
        self:friendsMarkCall(status);--状态
        self:friendsDataCall(datas);--数据
        self.recordItem:updateViewData(rData, datas)
    else
        self:updataInitView()
        self:initSelfData();
        self:friendsDataCall(datas);--数据
        self.recordItem:updateViewData(rData, datas)
    end
end

--初始化个人信息view
function FriendsInfoScene.initInfoView(self)
    local w,h = self:getSize()             --实际屏幕宽高
    
    self.m_info_view:setVisible(true)
    self.m_info_view:setPos(0,nil)
    local mw,mh = self.m_info_view:getSize()   --系统设定的分辨率下的宽高，并不是基于屏幕实际分辨率的宽高
    self.m_info_view:setSize(mw+w-System.getLayoutWidth(),mh+h-System.getLayoutHeight())   --System.getLayoutHeight()是在main.lua里面一开始设定的高度，并不是实际屏幕宽高
end

--初始化棋局顶部按钮
function FriendsInfoScene.initTopButton(self)
    self.record_bn = self:findViewById(self.m_ctrls.record_bn)
    self.record_line = self.record_bn:getChildByName("record_line")
    self.record_tx = self.record_bn:getChildByName("record_tx")

    self.honor_bn = self:findViewById(self.m_ctrls.honor_bn)
    self.honor_line =self.honor_bn:getChildByName("honor_line")
    self.honor_tx = self.honor_bn:getChildByName("honor_tx")

    self.replay_bn = self:findViewById(self.m_ctrls.replay_bn)
    self.replay_line = self.replay_bn:getChildByName("replay_line")
    self.replay_tx = self.replay_bn:getChildByName("replay_tx")
    
    --初始化
    self.record_line:setVisible(true)
    self.honor_line:setVisible(false)
    self.replay_line:setVisible(false)

    self.record_tx:setColor(215,75,45)
    self.honor_tx:setColor(135,100,95)
    self.replay_tx:setColor(135,100,95)
    --设置监听事件
    self.record_bn:setOnClick(self,self.onRecordBnClick)
    self.honor_bn:setOnClick(self,self.onHonorBnClick)
    self.replay_bn:setOnClick(self,self.onReplayBnClick)

end

--初始化棋局推荐view
function FriendsInfoScene.initRecommendView(self)
    local w,h = self:getSize()
    self.replay_item = self:findViewById(self.m_ctrls.replay_item)--棋友推荐view
    self.replay_no_item_tips = self.replay_item:getChildByName("tips")
    self.replay_no_item_tips:setVisible(true)
    self.replay_item:setVisible(true)
    self.replay_item:setPos(2*w,nil)       --在第三个位置
    local mw,mh = self.replay_item:getSize()
    self.replay_item:setSize(mw,mh+h-System.getLayoutHeight())
end

--初始化棋友推荐列表listview
function FriendsInfoScene.initReplayListView(self)
    local w,h = self:getSize()
    local mw,mh = self.replay_item:getSize()

    self.m_suggest_list_num = 0;
    self.m_replay_list = new(ListView,0,0,630,1)
    --self.m_replay_list:setFillParent(doFillParentWidth,true)
    self.m_replay_list:setAlign(kAlignBottom);
    self.m_replay_list:setDirection(kVertical);
    self.m_replay_list:setPos(0,0)
    self.m_replay_list:setSize(630,mh+h-System.getLayoutHeight())
    self.m_replay_list:setOnScroll(self, self.onSuggestLVScroll);
    self.m_replay_list:setOnItemClick(self, self.onSuggestItemClick);
    self.replay_item:addChild(self.m_replay_list)
end

--初始化棋友推荐状态
function FriendsInfoScene.initReplayItemRoom(self)
    ReplayChessItem.s_room = self;
    ReplayChessItem.s_type = ReplayScene.SUGGEST;
end

require(MODEL_PATH.."friendsInfo/friendsinfo_item/friendsinfoRecordItem")
--初始化战绩界面
function FriendsInfoScene.initRecordItem(self)
    
    --[[
    local w,h = self:getSize()
    self.record_item = self:findViewById(self.m_ctrls.record_item)
    --战绩页面
    self.recordItem = new (FriendsinfoRecordItem,friend_info_record_item,self.m_controller)    
    self.recordItem:setName("recordItem")
    self.record_item:addChild(self.recordItem)
    self.record_item:setVisible(true)
    self.record_item:setPos(0,FriendsInfoScene.ITEM_HEIGHT)
    local mw,mh = self.record_item:getSize()
    self.record_item:setSize(mw,mh+h-System.getLayoutHeight())  --屏幕适配
    ]]--
    self.record_item = self:findViewById(self.m_ctrls.record_item)
    self.recordItem = new (FriendsinfoRecordItem,friend_info_record_item,controller,self,self.record_item) 
    self.record_item:setVisible(true)
    self.record_item:setPos(0,FriendsInfoScene.ITEM_HEIGHT)
    self:getRecordData()   
end

require(MODEL_PATH.."friendsInfo/friendsinfo_item/friendsinfoHonorItem")
--初始化荣誉界面
function FriendsInfoScene.initHonorItem(self)
    --[[
    local w,h = self:getSize()
    self.honor_item = self:findViewById(self.m_ctrls.honor_item)
    --荣誉页面
    self.honorItem = new (FriendsinfoHonorItem , friend_info_honor_item , self.m_controller)
    self.honorItem:setName("honorItem")
    self.honor_item:addChild(self.honorItem)
    self.honor_item:setVisible(true)
    self.honor_item:setPos(w,FriendsInfoScene.ITEM_HEIGHT)
    local mw,mh = self.honor_item:getSize()
    self.honor_item:setSize(mw,mh+h-System.getLayoutHeight())
    ]]--
    local w,h = self:getSize()
    self.honor_item = self:findViewById(self.m_ctrls.honor_item)
    --荣誉页面
    self.honorItem = new (FriendsinfoHonorItem , friend_info_honor_item , controller, self, self.honor_item)
    self.honor_item:setVisible(true)
    self.honor_item:setPos(w,FriendsInfoScene.ITEM_HEIGHT)
end

--------------------------------even callback function---------------------------------


--推荐棋局列表滑动事件
function FriendsInfoScene.onSuggestLVScroll(self,scroll_status,diff, totalOffset)
    local lvW, lvH = self.m_replay_list:getSize();
    local trueOffset = self.m_suggest_list_num * ReplayChessItem.HEIGHT - lvH;
    if totalOffset and trueOffset > 0 then
        if (math.abs(tonumber(totalOffset)) >  trueOffset + 100) then
            if not self.is_loading then
                self.is_loading = true;
                self:getSuggestChess(self.m_suggest_list_num,5); 
            end;
        elseif math.abs(tonumber(totalOffset)) > trueOffset then
            self.is_loading = false;
        end;
    end;
end

--获取棋友动态
--start：开始位置  num：拉取数量
function FriendsInfoScene.getSuggestChess(self,start,num)
    self:requestCtrlCmd(FriendsInfoController.s_cmds.get_usersuggestchess,start, num,nil,FriendsInfoController.friendsID);
end

--更新自己用户信息
function FriendsInfoScene.initSelfData(self)
    if not self.intent then return end
    local myRecordData = {}
    self.name:setText(self.intent:getName())
    self:setSex(self.intent:getSex())
    self:setLevel(self.intent:getScore())
    self:setID(self.intent:getUid())
    --self:setMoneyData(self.intent:getMoney())
    local wintimees = self.intent:getWintimes()
    local losetimees = self.intent:getLosetimes()
    local drawtimes = self.intent:getDrawtimes()
    myRecordData.losetimes = losetimees
    myRecordData.drawtimes = drawtimes
    myRecordData.wintimes = wintimees
    myRecordData.money = self.intent:getMoney()
    myRecordData.score = self.intent:getScore()
    --self:setWinrateData(losetimees,wintimees,drawtimes)
    self:setChessTeam(self.intent:getUserSociatyData())
    --self:setGiftData(self.intent:getGift())
    local d1 = FriendsData.getInstance():getFansNum()
    local d2 = FriendsData.getInstance():getFollowNum()
    --self:setFriendNum(d1,d2)
    local icon_url = self.intent:getIcon()
    local icon_type = self.intent:getIconType()
    local my_set = self.intent:getUserSet()
    self:setUserIcon(icon_url,icon_type,my_set)
    local province = self.intent:getProvinceName()
    local cityName = self.intent:getCityName()
    local str = province .. cityName
    self:setCityData(str)
    local str = self.intent:getSignAture()
    self:setSignData(str)
    if self.intent:getIsVip() == 0 then
        --self.no_sociaty_tips:setVisible(true)
        --self.m_vip_frame:setVisible(false);
        self.honor_img:setVisible(false)
    end
    self.recordItem:updateViewData(rData, myRecordData) 
end
--设置当前个人信息是我自身时的界面显示
function FriendsInfoScene.updataInitView(self)
    self.follow_bn:setVisible(false)
    self.challenge_btn:setVisible(false)
    self.send_message_bn:setVisible(false)
    self.more_btn:setVisible(false)
    self.signature_txv:setVisible(false)
    self.signature_editv:setVisible(true)
end

--初始化礼物模块
--function FriendsInfoScene.initGiftView(self)
--    self.m_gift_view = self.m_contentView:getChildByName("receive_gift");
--    self.item_view = self.m_gift_view:getChildByName("item_view");
--    self.m_scroll_list = new(GiftModuleScrollList,650,160,GiftModuleItem.s_mode_user);
--    self.m_scroll_list:initScrollView(GiftModuleScrollList.s_lsize);
--    self.m_scroll_list:setAlign(kAlignLeft);
--    self.item_view:addChild(self.m_scroll_list);
--end

FriendsInfoScene.setBtnOntouch = function(self)
    local func =  function(view,enable)
        local tip = view:getChildByName("text");
        if tip then
            if not enable then
                tip:setColor(255,255,255);
                tip:addPropScaleSolid(1,1.1,1.1,1);
            else
                tip:setColor(240,230,210);
                tip:removeProp(1);
            end
        end
    end
    
    self.challenge_btn:setOnTuchProcess(self.challenge_btn,func);
    self.send_message_bn:setOnTuchProcess(self.send_message_bn,func);
end

    
FriendsInfoScene.friendsDataCall = function(self,datas) 
    self.getUserDataTimes = self.getUserDataTimes + 1
    if self.isMe then
        local matchBest = {}
        if datas then
            matchBest = datas.match_best
            self:setRecentLoginTime(datas.mactivetime)
        end
        --self:setMatchBestRank(matchBest)
        --self:setCharmData(charmValue)
        --self:setPassMission(booth_gate)       
        return
    end
    if datas~= nil then
        self.getUserDataTimes = 0
        --设置昵称
        self:setNickName(datas.mnick)
        --性别
        self:setSex(datas.sex)
        --等级
        self:setLevel(tonumber(datas.score))  
        -- ID
        self:setID(datas.mid)
        --社团
        self:setChessTeam(datas.guild)
        --定位信息
        self:setCityData(datas.geo)
        --比赛最佳排名
        --self:setMatchBestRank(datas.match_best)

--        if datas.rank and datas.rank~= 0 then
--            local rk = ""..0 .. "名";
--           if datas.rank <= 999 then  -- <=
--                rk = ""..datas.rank.."名";
--           else
--                rk = "999+名";
--           end
--           self.master_rank.setText(self.master_rank,rk);
--        end

--        if datas.fans_rank and datas.fans_rank ~= 0 then
--            local rk = "" .. 0 .. "名";
--            if datas.fans_rank <= 999 then -- <=
--                rk = ""..datas.fans_rank .."名";
--            else
--                rk = "999+名";
--            end

--            self.charm_rank.setText(self.charm_rank,rk);
--        end

        --头像
        self:setUserIcon(datas.icon_url,datas.iconType,datas.my_set)
--        if self.m_scroll_list then
--            self.m_scroll_list:onUpdateItem(datas);
--        end
        --个性签名
        self:setSignData(datas.signature)
        self:setRecentLoginTime(datas.mactivetime)
        if datas.is_vip == 0 then
            --self.no_sociaty_tips:setVisible(true)
            --self.m_vip_frame:setVisible(false);
            self.honor_img:setVisible(false)
        end
   else
        if self.getUserDataTimes <= 3 then
            FriendsData.getInstance():getUserData(FriendsInfoController.friendsID);
            --FriendsData.getInstance():getRecordFriendsData(FriendsInfoController.friendsID);
            FriendsData.getInstance():getUserStatus(FriendsInfoController.friendsID);
       
        end
   end
   
   
end

--主要设置两部分，一部分是是否关注，一部分是对这个用户可以进行的发送信息或者观战，挑战等操作
FriendsInfoScene.friendsMarkCall = function(self,status)

   local friend = FriendsData.getInstance():isYourFriend(FriendsInfoController.friendsID);
   local follow = FriendsData.getInstance():isYourFollow(FriendsInfoController.friendsID);
   local fans = FriendsData.getInstance():isYourFans(FriendsInfoController.friendsID);
   
   local followImg = "chessfriends/add_follow.png";
   local isfollowImg = "chessfriends/is_follow.png";
   if friend ~= -1 then
       self.follow_img:setFile(isfollowImg);
       self.follow_tx:setText("已关注");
       self.follow_tx:setColor(170,150,145)
        self.attention = 0;
   elseif follow ~= -1 then
        self.follow_img:setFile(isfollowImg);
        self.follow_tx:setText("已关注");
        self.follow_tx:setColor(170,150,145)
        self.attention = 0;
   elseif fans ~= -1 then
        self.follow_img:setFile(followImg);
        self.follow_tx:setText("关注");
        self.follow_tx:setColor(135,100,95)
        self.attention = 1;
   else
        self.follow_img:setFile(followImg);
        self.follow_tx:setText("关注");
        self.follow_tx:setColor(135,100,95)
        self.attention = 1;
   end

   -----------------------------------------------------------------------
   if status ~= nil then
        if status.hallid <=0 then --离线
            --不在线        
            self.challenge_tittle:setText("不在线");
            self.challenge_btn:setPickable(false);
            self.challenge_btn:setFile("chessfriends/offline.png");
--            self.challenge_gz:setVisible(false);
--            self.challenge_noonline:setVisible(true); 
            self.send_message_tx:setText("发送留言");

        else
            if RoomConfig.getInstance():isPlaying(status) then  --tid, >0标识用户在下棋 level, 下棋所在的场次
                --观战
--                local strname = FriendsInfoScene.onGetScreenings(status.level);
                self.challenge_tittle:setText("观战");
                self.challenge_btn:setPickable(true);
                self.challenge_btn:setFile({"chessfriends/watch_nor.png","chessfriends/watch_pre.png"});
--                self.time_tile:setText(strname);
--                self.challenge_gz:setVisible(true);
--                self.challenge_tz:setVisible(false);
--                self.challenge_noonline:setVisible(false);      
            else
                
--                self.time_tile:setText("在线");
                --挑战
--                self.challenge_gz:setVisible(false);
--                self.challenge_tz:setVisible(true);
--                self.challenge_noonline:setVisible(false);
                self.challenge_tittle:setText("挑战");
                self.challenge_btn:setPickable(true);
                self.challenge_btn:setFile({"chessfriends/challenge_nor.png","chessfriends/challenge_pre.png"});
    
                if FriendsData.getInstance():isYourFriend(FriendsInfoController.friendsID) == -1 then   
                    --self.challenge_btn:setFile("friends/noonline_btn.png");
                end
            end
            self.send_message_tx:setText("私聊");
--            self.time:setVisible(false);
        end

--        local datas = FriendsData.getInstance():getFrendsListData();
--        for _,id in pairs(datas) do
--            if id ~= FriendsInfoController.friendsID then
--               --留言
--               self.mes_sendmessage:setVisible(false);
--               self.mes_sendwords:setVisible(true);    
--            else
--                 --聊天 
--               self.mes_sendmessage:setVisible(true);
--               self.mes_sendwords:setVisible(false);
--               break;
--            end
--        end 
       --self.time.setText(self.time,"");    
   end
    
end
--FriendsInfoScene.reset = function(self)
--    --查询单个用户的好友榜排名
--    local data = {};
--    data.id = UserInfo.getInstance():getUid();
--    data.target_uid = FriendsInfoController.friendsID;

--    if data.target_uid == nil or data.id == nil then --ZHENGYI
--        return;
--    end

--    self:requestCtrlCmd(FriendsInfoController.s_cmds.changeFriends,data);
--end


FriendsInfoScene.callsCallBack = function(self)
	StateMachine.getInstance():pushState(States.Exchange,StateMachine.STYPE_CUSTOM_WAIT);
end
---------------------------------------------------------------------------------
---------------------  view的touch事件（包括点击事件） --------------------------
---------------------------------------------------------------------------------
FriendsInfoScene.onRecordBnClick = function (self)
    local w,h = self:getSize()
    self.record_item:setPos(0,nil)
    self.honor_item:setPos(w,nil)
    self.replay_item:setPos(2*w,nil)

    --处理底部操作栏的可见性
    self.bottome_opearate_view:setVisible(true)
    --处理点击效果
    self.record_line:setVisible(true)
    self.honor_line:setVisible(false)
    self.replay_line:setVisible(false)

    self.record_tx:setColor(215,75,45)
    self.honor_tx:setColor(135,100,95)
    self.replay_tx:setColor(135,100,95)


end

FriendsInfoScene.onHonorBnClick = function (self)
    self:getHonorData()
    local w,h = self:getSize()
    self.record_item:setPos(0-w,nil)
    self.honor_item:setPos(0,nil)
    self.replay_item:setPos(2*w-w,nil)
     --处理底部操作栏的可见性
    self.bottome_opearate_view:setVisible(true)
    --处理点击效果
    self.record_line:setVisible(false)
    self.honor_line:setVisible(true)
    self.replay_line:setVisible(false)

    self.record_tx:setColor(135,100,95)
    self.honor_tx:setColor(215,75,45)
    self.replay_tx:setColor(135,100,95)

end

FriendsInfoScene.onReplayBnClick = function (self)
    --获取棋谱数据
    self:getRecommendData()

    local w,h = self:getSize()
    self.record_item:setPos(-w-w,nil)
    self.honor_item:setPos(-w,nil)
    self.replay_item:setPos(2*w-w-w,nil)
     --处理底部操作栏的可见性
    self.bottome_opearate_view:setVisible(false)
    --处理点击效果
    self.record_line:setVisible(false)
    self.honor_line:setVisible(false)
    self.replay_line:setVisible(true)

    self.record_tx:setColor(135,100,95)
    self.honor_tx:setColor(135,100,95)
    self.replay_tx:setColor(215,75,45)
    
end

FriendsInfoScene.onSelectChangeClick = function(self)
   local data = {};
   data.target_uid = FriendsInfoController.friendsID;
   data.op = self.attention;
   if UserInfo.getInstance():getUid() ~= FriendsInfoController.friendsID then
        self:requestCtrlCmd(FriendsInfoController.s_cmds.attentionTo,data);
   end

end

FriendsInfoScene.onFriendsBackBtnClick = function(self) --返回
    self:requestCtrlCmd(FriendsInfoController.s_cmds.back_action);
end

FriendsInfoScene.onFriendsChallengeBtnClick = function(self) --挑战，观战,不在线
    Log.d("onFriendsChallengeBtnClick");
    if UserInfo.getInstance():isFreezeUser() then return end;
    local status = FriendsData.getInstance():getUserStatus(FriendsInfoController.friendsID);

    if status ~= nil then
        if status.hallid <=0 then --离线
        --不在线
 
        else
            if RoomConfig.getInstance():isPlaying(status) then  
            --观战
                
                local isSuccess,msg = RoomProxy.getInstance():followUserByStatus(status)
                if not isSuccess then
                    ChessToastManager.getInstance():showSingle(msg)
                end
            else
            --挑战 
                if UserInfo.getInstance():getUid() == FriendsInfoController.friendsID then
                    --ChessToastManager.getInstance():show("不能挑战自己！",500);
                else
                    if FriendsData.getInstance():isYourFriend(FriendsInfoController.friendsID) ~= -1 then
                        UserInfo.getInstance():setTargetUid(FriendsInfoController.friendsID);
                        local post_data = {};
                        post_data.uid = tonumber(UserInfo.getInstance():getUid());
                        post_data.level = 320;
                        self:requestCtrlCmd(FriendsInfoController.s_cmds.challenge,post_data);
                    else    
                        ChessToastManager.getInstance():show("非好友不能挑战！",500);
                    end
                end
            end
        end

    end
    
end

FriendsInfoScene.onFriendsMesBtnClick = function(self) --聊天，留言
    Log.d("onFriendsMesBtnClick");
    local status = FriendsData.getInstance():getUserStatus(FriendsInfoController.friendsID);
    local datas = FriendsData.getInstance():getUserData(FriendsInfoController.friendsID);

    if status ~= nil then

        if status.hallid <=0 then --离线
            --留言

        else
            --聊天 

        end

    end

    if UserInfo.getInstance():getUid() == FriendsInfoController.friendsID then
        --ChessToastManager.getInstance():show("不能和自己聊天！",500);
    else
        if datas~= nil then
            delete(self.m_friend_chat_dialog)
            self.m_friend_chat_dialog = new(FriendChatDialog,datas)
            self.m_friend_chat_dialog:show();
        end
    end

end

FriendsInfoScene.onReportBadBtnClick = function(self) --举报用户
    Log.d("onReportBadBtnClick");
    if not self.m_report_dialog then
        self.m_report_dialog = new(ReportDialog);
    end;
    self.m_report_dialog:show(self.expose_emid);
    self.is_show_more_view = false 
    self.mor_btn_view:setVisible(false)
end

--加入黑名单
function FriendsInfoScene.addBlackList(self)
    local func =  function()
        local tab = {}
        local param = {}
        param.target_mid = self.expose_emid
        tab.param = param
        HttpModule.getInstance():execute(HttpModule.s_cmds.addBlackList,tab)
        self.is_show_more_view = false 
        self.mor_btn_view:setVisible(false)
    end
    if not self.mChioceDialog then
        self.mChioceDialog = new(ChioceDialog)
        self.mChioceDialog:setMode(ChioceDialog.MODE_SURE)
        self.mChioceDialog:setMessage("是否确定把对方拉黑？可在好友黑名单管理中取消拉黑")
    end
    self.mChioceDialog:setPositiveListener(self,func);
    self.mChioceDialog:setNegativeListener()
    self.mChioceDialog:show()
end

FriendsInfoScene.onFriendsinfoiconClick = function(self,finger_action,x,y,drawing_id_first,drawing_id_last) --点击显示大头像
    if finger_action == kFingerUp and drawing_id_first == drawing_id_last then
        Log.d("onFriendsinfoiconClick");
        if not self.p_bigHeadDialog then
            self.p_bigHeadDialog = new(BigHeadDialog);
        end
        self.p_bigHeadDialog:show(self.p_iconFile,self.p_iconType,self.p_iconLoading);
    end
end

--棋社的点击事件
FriendsInfoScene.onChessTeamYesClick = function (self )
    local data = {}
    local guild = {}
    if self.isMe then 
        data = self.intent:getUserSociatyData()
    else 
        --获取用户数据,
        data = FriendsData.getInstance():getUserData(FriendsInfoController.friendsID); --用户详细数据 
        guild = data.guild or {}
    end
    if not self.m_sociaty_dialog then
        self.m_sociaty_dialog = new(CreateAndCheckSociatyDialog);     --棋社详细信息的弹窗
    end
    self.m_sociaty_dialog:setSociatyData(data)
    self.m_sociaty_dialog:setDialogStatus(CreateAndCheckSociatyDialog.s_check_mode);
    self.m_sociaty_dialog:show();
end

--重置棋局点击事件
function FriendsInfoScene.resetListViewItemClick(self, flag)
    if flag then
        self.m_replay_list:setOnItemClick(self, function() end);
    else
        self.m_replay_list:setOnItemClick(self, self.onSuggestItemClick);
    end  
end

--推荐棋局点击事件
function FriendsInfoScene.onSuggestItemClick(self,adapter,view,index,viewX,viewY)
    UserInfo.getInstance():setDapuSelData(view:getData());
    RoomProxy.getInstance():gotoReplayRoom();
end

-- 收藏到我的收藏
function FriendsInfoScene.saveChesstoMysave(self,item)
    self.m_chess_item = item;
    self:requestCtrlCmd(FriendsInfoController.s_cmds.save_mychess,item:getChioceDlgCheckState(),item:getData());
end

require("dialog/common_share_dialog");

--分享棋谱
--data: 复盘数据
function FriendsInfoScene.shareChess(self,data)
    if not data then return end
    if not self.commonShareDialog then
        self.commonShareDialog = new(CommonShareDialog);
    end
    self.commonShareDialog:setShareDate(data,"manual_share");
    self.commonShareDialog:show();
end

--好友信息按钮点击
function FriendsInfoScene.onInfoBtnClick(self)
    if self.curr_state == FriendsInfoScene.s_state_info then return end
    self.curr_state = FriendsInfoScene.s_state_info;
    self.m_bottom_line:setPos(0,0)
    self.m_info_btn_text:setColor(215,75,45);
    self.m_recommend_btn_text:setColor(135,100,95);
--    self.m_recommend_btn:setEnable(true);
--    self.m_info_btn:setEnable(false);
    if self.m_info_view then
        local w,h = self.m_info_view:getSize()
        local x,y = self.m_info_view:getPos()
        self:startMoveAnim(-x)    --刚好移出界面
    end
end

--棋局推荐按钮点击
function FriendsInfoScene.onRecommendBtnClick(self)
    if self.curr_state == FriendsInfoScene.s_state_recommend then return end
    self.curr_state = FriendsInfoScene.s_state_recommend;
    self.m_bottom_line:setPos(234,0)
    self.m_info_btn_text:setColor(135,100,95);
    self.m_recommend_btn_text:setColor(215,75,45);
--    self.m_info_btn:setEnable(true);
--    self.m_recommend_btn:setEnable(false);

    if self.replay_item then
        local w,h = self.replay_item:getSize()
        local x,y = self.replay_item:getPos()
        self:startMoveAnim(-x)
    end
end

-------------------- view的touch事件（包括点击事件）----------------------
--------------------------------end --------------------------------------


function FriendsInfoScene.startMoveAnim(self,len)
    self:stopPopAnim();
    self.popAnim = new(AnimInt, kAnimLoop, 0, 1, 1000/60, -1);
    self.popAnim:setEvent(self,function()
        --当距离目标界限小于5时，则 直接移动到界限上
        if math.abs(len) < 5 then
            if self.m_info_view then
                local x,y = self.m_info_view:getPos();
                self.m_info_view:setPos(x+len,nil);
            end

            if self.replay_item then
                local x,y = self.replay_item:getPos();
                self.replay_item:setPos(x+len,nil);
            end
            self:stopPopAnim();
            self:getRecommendData()
            return ;
        end
        local move = len * 0.4;--每个时间单位移动0.4总长度的距离
        len = len - move;
        --左右两个node一起移动
        if self.m_info_view then
            local x,y = self.m_info_view:getPos();
            self.m_info_view:setPos(x+move,nil);
        end

        if self.replay_item then
            local x,y = self.replay_item:getPos();
            self.replay_item:setPos(x+move,nil);
        end
    end);
end

function FriendsInfoScene.stopPopAnim(self)
    delete(self.popAnim);
end

function FriendsInfoScene.getRecordData(self)
    if not self.getRecordDataLock then
        self.getRecordDataLock = true  --锁住
        self:requestCtrlCmd(FriendsInfoController.s_cmds.getRecordData,FriendsInfoController.friendsID);
    end 
end
function FriendsInfoScene.getHonorData(self)
    if not self.getHonorDataLock then
        self.getHonorDataLock = true  --锁住
        self:requestCtrlCmd(FriendsInfoController.s_cmds.getHonorData,FriendsInfoController.friendsID);
    end 

end
function FriendsInfoScene.getRecommendData(self)
    if self.needGetRecommendData then
        self.needGetRecommendData = false
        self:requestCtrlCmd(FriendsInfoController.s_cmds.get_usersuggestchess,0, 10,nil,FriendsInfoController.friendsID);
    end
end
----------------------------------------------------------------------------------
---------------------------- 设置view的具体数据 ----------------------------------
----------------------------------------------------------------------------------
function FriendsInfoScene.setNickName(self,s)
    if s then
        local lenth = string.lenutf8(GameString.convert2UTF8( s ));
        if lenth > 10 then    
            local str  = string.subutf8( s ,1,7).."...";
            self.name.setText(self.name,str);
        else
            self.name.setText(self.name, s );
        end
    else
        self.name.setText(self.name,"博雅象棋");
    end
end

function FriendsInfoScene.setSex(self,sexData)
    local sex = sexDat or 0
    if sex == 0 then --性别保密
        self.sex_img:setFile("chessfriends/friend_secret.png")
    elseif sex == 1 then
        self.sex_img:setFile("chessfriends/friend_man.png");
    else
        self.sex_img:setFile("chessfriends/friend_women.png");
    end 
end

function FriendsInfoScene.setLevel(self,scoreData)
    local score = scoreData or 1
    --self.points.setText(self.points,score);
    self.level:setFile("common/icon/big_level_" .. 10 - UserInfo.getInstance():getDanGradingLevelByScore(score) .. ".png" )
end

function FriendsInfoScene.setID(self,userid)
    local id = userid or "0";
    id = "ID " .. id ;
    self.m_id:setText(id);
end

function FriendsInfoScene.setChessTeam(self,guildData)
    local guild = guildData or {}
    if not guild or type(guild) ~= "table" or next(guild) == nil then
        self.chessTeam_no:setVisible(true)
        self.chessTeam_yes:setVisible(false)
        return 
    else
        self.chessTeam_no:setVisible(false)  --
        self.chessTeam_yes:setVisible(true)
    end
    local name = guild.guild_name or ""
    --社团职位
    local role = tonumber(guild.guild_role) or 0
    local chessteam_position = " （"..ChesssociatyModuleConstant.role[role].."）" or ""
    self.chessTeam_name:setText(name..chessteam_position);
    
    --self.chessTeamPosition:setText(chessteam_position);
    --社团图标
    local guild_icon = tonumber(guild.mark)
    if guild_icon then
        self.chessTeam_icon:setVisible(true)
        self.chessTeam_icon:setFile(ChesssociatyModuleConstant.sociaty_icon[guild_icon] or "sociaty_about/r_scholar.png")
    else
        self.chessTeam_icon:setVisible(false)
    end
end

function FriendsInfoScene.setGiftData(self,giftData)
    local temp = giftData or {}
    local num = 0
    for k,v in pairs(temp) do
        if v then
            num = num + tonumber(v)
        end
    end
    self.gift_num:setText(num);
end

function FriendsInfoScene.setCharmData(self,charmData)
    local charm_num = tonumber(charmData) or 0
    self.charm_num:setText(charm_num);
end

--[[
function FriendsInfoScene.setFriendNum(self,fansNumData,followNumData)
--        local friends_num = datas.friends_num or 0;
        local fans_num = fansNumData or 0;
        local follow_num = followNumData or 0;
--        self.m_friends_num:setText(friends_num .. "人");
        self.m_follow_num:setText(follow_num .. "人");
        self.m_fans_num:setText(fans_num .. "人");
end
]]--
--设置用户头像
function FriendsInfoScene.setUserIcon(self,iconUrl,iconType,my_set)
    self.p_iconFile = iconUrl;
    self.p_iconType = iconType;
    local mySet = my_set or {}
    if self.p_iconType == -1 then
        self.friendsinfo_icon:setUrlImage(self.p_iconFile);
    else
        self.friendsinfo_icon:setFile(UserInfo.DEFAULT_ICON[self.p_iconType] or UserInfo.DEFAULT_ICON[1]);
    end
    if mySet then
        local frameRes = UserSetInfo.getInstance():getFrameRes(my_set.picture_frame or "sys");
        local fw,fh = self.m_vip_frame:getSize();
        fw=180
        if frameRes.frame_res then
            self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
        end
        self.m_vip_frame:setVisible(frameRes.visible);
    end
end
--设置地区位置
function FriendsInfoScene.setCityData(self,geoData)
    local geo = "未知"
    if geoData ~=nil and geoData~="" then
        geo ="" 
        for w in string.gmatch(geoData ,"([^',']+)") do --按照“，”分割字符串
            geo = geo..w.." "
        end
    end
    self.city_info:setText(geo)
end
--设置个人签名
function FriendsInfoScene.setSignData(self,signData)
    if self.isMe then
        if not signData or signData == ""then
            self.signature_editv:setHintText(GameString.convert2UTF8("个性签名：这个家伙很懒，什么都没有留下"),165,145,120);
        else
            signData = "个性签名："..signData
            self.signature_editv:setText(signData)
        end
    else
        local str = signData
        if not signData or signData == "" then
            str = "这个家伙很懒，什么都没有留下"
        end
        str = "个性签名："..str
        self.signature_txv:setText(str)
    end
end

--设置最近登录时间
function FriendsInfoScene.setRecentLoginTime(self,s)
    if s then 
        self.recent_login_time_tx:setText(FriendsInfoScene.getTime(s))
    end
end
--[[
--设置职业赛排名
function FriendsInfoScene.setMatchBestRank(self,matchData)
    local matchInfo = matchData
    if not matchInfo or type(matchInfo) ~= "table" then
        matchInfo = {}
    end
    local matchName = "职业赛"
    local matchRank = "暂无排名"
    for k,v in pairs(matchInfo) do
        if k then
            matchName = FriendsInfoScene.matchType[k] or "职业赛"
        end
        matchRank = tonumber(v) or "暂无排名"
    end
    self.match_name:setText(matchName)
    self.match_best_rank:setText(matchRank)
end
]]--
--[[
function FriendsInfoScene.setComboData(self,comboData)
    local str = comboData or "1"
    self.win_combo:setText(str)
end
]]--
--[[
function FriendsInfoScene.setPassMission(self,passData)
    local str = passData or "0"
    self.pass_mission:setText(str)
end
]]--
function FriendsInfoScene.onEditTextChange(self,str)
    local userSign = self.intent:getSignAture()
    if not str then
        self:setSignData(userSign)
        return 
    end
    local len = ToolKit.utfstrlen(str)
    if len == 0 then
        self:setSignData(userSign)
        return
    end
    if len > 15 then
        ChessToastManager.getInstance():showSingle("签名不能超过15个字！")
        self:setSignData(userSign)
        return
    end
    self:setSignData(str)
    self:modifyInfo(str)
end

function FriendsInfoScene.modifyInfo(self,str)
    self:requestCtrlCmd(FriendsInfoController.s_cmds.modifyUserInfo,str);
end


-----------------------------------------------------------------------------
--------------------开放给controller调用的函数-------------------------------
-----------------------------------------------------------------------------
FriendsInfoScene.updateUserIcon = function(self,data)
    Log.i("FriendsInfoScene.updateUserIcon: "..(data.ImageName or "null"));
--    if tonumber(data.what) == FriendsInfoController.friendsID and data.ImageName then
--        self.friendsinfo_icon:setFile(data.ImageName);
--        self.p_iconFile = data.ImageName;
--        self.p_iconLoading = false;
--        if self.p_bigHeadDialog then
--            self.p_bigHeadDialog:update(data.ImageName);
--        end
--    end
end

---------个人信息数据更新接口
FriendsInfoScene.changeDataCall = function(self, datas) 
    self:friendsDataCall(datas);            --更新主页面数据 
    self.recordItem:updateViewData(rData, datas)  

end

--战绩信息更新接口
function FriendsInfoScene.updateRecordData(self, rData, nData)
    self.updateRecordDataTimes = self.updateRecordDataTimes + 1
    if rData then           
        if FriendsInfoController.friendsID == tonumber(rData.mid) then
            self.updateRecordDataTimes = 0
            self.recordItem:updateViewData(rData, nData) 
        end
    else 
        if self.updateRecordDataTimes < 2 then 
            self:requestCtrlCmd(FriendsInfoController.s_cmds.getRecordData,FriendsInfoController.friendsID)
        end
    end     
end

--荣誉信息更新接口
function FriendsInfoScene.updateHonorData(self, datas)
    self.updateHonorDataTimes = self.updateHonorDataTimes + 1
    if datas then         
        if FriendsInfoController.friendsID == tonumber(datas.mid) then
            self.updateHonorDataTimes = 0
            self.honorItem:updateViewData(datas)          
        end
    else 
        if self.updateHonorDataTimes < 2 then 
            self:requestCtrlCmd(FriendsInfoController.s_cmds.getHonorData,FriendsInfoController.friendsID)
        end
    end
end

--------状态更新接口
FriendsInfoScene.changeStatusCall = function(self,status)
    for _,sdata in pairs(status) do
        if FriendsInfoController.friendsID == tonumber(sdata.uid) then
            self:friendsMarkCall(sdata);--状态       
            break;
        end
    end
end


FriendsInfoScene.changeFriendTileCall = function(self,info)

    if not info then return end   --0,陌生人,=1粉丝，=2关注，=3好友
    local followImg = "chessfriends/add_follow.png";
    local isfollowImg = "chessfriends/is_follow.png";
    if info.ret == 0 then
        if info.relation >= 2 then
            self.follow_img:setFile(isfollowImg);
            self.follow_tx:setText("已关注");
            self.follow_tx:setColor(170,150,145)
            self.attention = 0;
        else
            self.follow_img:setFile(followImg);
            self.follow_tx:setText("关注");
            self.follow_tx:setColor(135,100,95)
            self.attention = 1;
        end
    end

end

--更新friend_chat_dialog 聊天状态
FriendsInfoScene.onReceChatMsgState = function(self,data)
--    if data.ret and tonumber(data.ret) then
--        self.m_friend_chat_dialog:updataStatus(data.ret);
--    end;
end

function FriendsInfoScene:onChangeFriendsNum(data)
--    if not data then return end
--    if not data.num then return end
--    self.m_friends_num:setText(tonumber(data.num));
end

function FriendsInfoScene:onChangeFollowNum(num)
    --self.m_follow_num:setText(data .. "人");
    self.honorItem:setAttentionRank(num)
end


function FriendsInfoScene:onChangeFansNum(num)
    --self.m_fans_num:setText(data .. "人");
    self.honorItem:setFansRank(num)
end

--获得推荐棋局回调
function FriendsInfoScene.onGetSuggestCallBack(self,data)
    if not data or not next(data) then 
--        self.m_suggest_tips:setText("...");
--        self.m_suggest_empty_tips:setVisible(true);
        self.replay_no_item_tips:setVisible(false)
        return 
    else
        ChessToastManager.getInstance():clearAllToast();
        self.m_suggest_total_num = data.total;
--        self.m_suggest_empty_tips:setVisible(false);
    end

    local suggestData = {}
    if not self.m_suggest_list_num then self.m_suggest_list_num = 0 end
    if data.list then
        self.m_suggest_list_num = self.m_suggest_list_num + #data.list;
    else
        return
    end
    for i = 1 ,#data.list do
        table.insert(suggestData,json.encode(data.list[i]));
    end;
    if self.m_suggest_list_num > #data.list then
        if self.m_suggest_adapter then
            self.m_suggest_adapter:appendData(suggestData);
        end;
    else
        -- 每次需重新加载收藏，有可能新增加收藏
        if not next(suggestData) then 
            self.replay_no_item_tips:setVisible(true)
            return 
        end;
        self.replay_no_item_tips:setVisible(false)
        delete(self.m_suggest_adapter);
        self.m_suggest_adapter = nil;
        self.m_replay_list:removeAllChildren(true)
        self.m_suggest_adapter = new(CacheAdapter,ReplayChessItem,suggestData);
        self.m_replay_list:setAdapter(self.m_suggest_adapter);
    end;
end

--收藏棋谱回调
function FriendsInfoScene.onSaveMychessCallBack(self,data)
    if not data then return end;
    if data.cost then
        if data.cost >= 0 then 
            ChessToastManager.getInstance():showSingle("收藏成功！",2000);
            if self.m_chess_item then
                if self.m_chess_item.m_type == ReplayScene.REPLAY then
                    self.m_chess_item:setReplayIsCollect();
                elseif self.m_chess_item.m_type == ReplayScene.MYSAVE then
                    -- 已经收藏了
                elseif self.m_chess_item.m_type == ReplayScene.SUGGEST then
                    self.m_chess_item:setSuggestIsCollect();
                end;
            end;
        elseif data.cost == -1 then
            -- -1是老版本本地棋谱上传成功
        end;
    end;
end;

function FriendsInfoScene.onSaveSignCallBack(self,str)
    self:setSignData(str)
end

function FriendsInfoScene.onWinComboCallBack(self,data)
    local num = data or 1 
    --self:setComboData(num)
end

-------------------开放给controller调用的接口函数------------------------
---------------------------end-------------------------------------------


-----------------------------------view config ------------------------------------------------------------
--view id map name
FriendsInfoScene.s_controlConfig = 
{
    [FriendsInfoScene.s_controls.info_view] = {"info_view"};
    [FriendsInfoScene.s_controls.content] = {"info_view","bg_line"};
	[FriendsInfoScene.s_controls.back_bn] = {"back_btn"};--返回
    [FriendsInfoScene.s_controls.more_btn] = {"more_btn"};--更多按钮
    --[FriendsInfoScene.s_controls.left_leaf]                           = {"left_leaf"};
    --[FriendsInfoScene.s_controls.right_leaf]                          = {"right_leaf"};
    --[FriendsInfoScene.s_controls.stone]                               = {"stone_dec"};
    --[FriendsInfoScene.s_controls.tea_cup]                             = {"teapot_dec"};

    ----个人信息
    [FriendsInfoScene.s_controls.friendsinfo_icon_mask] = {"info_view","bg_line","icon_bg","icon_mask"};--头像背景
    [FriendsInfoScene.s_controls.name] = {"info_view","bg_line","name"};--名字
    [FriendsInfoScene.s_controls.sex_img] = {"info_view","bg_line","sex_img"};--性别男，女
    --[FriendsInfoScene.s_controls.sex0] = {"info_view","bg_line","sex0"};--性别保密
    [FriendsInfoScene.s_controls.level] = {"info_view","bg_line","level"};--等级
    

    [FriendsInfoScene.s_controls.follow_bn]              = {"info_view","bg_line","follow_btn"};--关注按钮

    [FriendsInfoScene.s_controls.bottome_operate_view]                       = {"bottome_operate_view"};
    [FriendsInfoScene.s_controls.challenge_btn]                       = {"bottome_operate_view","watch_btn"};--观战，挑战，不在线
    [FriendsInfoScene.s_controls.challenge_tittle]                    = {"bottome_operate_view","watch_btn","text"};
    [FriendsInfoScene.s_controls.send_message_bn] = {"bottome_operate_view","send_message_bn"};  
    [FriendsInfoScene.s_controls.send_message_tx] = {"bottome_operate_view","send_message_bn","send_message_tx"};   
    [FriendsInfoScene.s_controls.reportBad_btn]                       = {"info_view","bg_line","more_btn_view","user_info_report_btn"};--举报用户
    [FriendsInfoScene.s_controls.add_blacklist_btn]                   = {"info_view","bg_line","more_btn_view","add_blacklist_btn"};--添加黑名单
    [FriendsInfoScene.s_controls.mor_btn_view]                        = {"info_view","bg_line","more_btn_view"};--更多界面
    
    
--    [FriendsInfoScene.s_controls.time]                                = {"info_view","bg_line","time"};  --好友登录时间
    --[FriendsInfoScene.s_controls.money]                               = {"info_view","bg_line","money_num","gold_num"};  --好友金币
    [FriendsInfoScene.s_controls.id] = {"info_view","bg_line","id_node","id_tx"};  --好友id
    [FriendsInfoScene.s_controls.honor_img] = {"info_view","bg_line","honor_img"};  --荣耀徽章
    [FriendsInfoScene.s_controls.recent_login_time_tx] = {"info_view","bg_line","recent_login_time_node","recent_login_time_tx"}; --最近登录时间
    [FriendsInfoScene.s_controls.chess_team_yes] = {"info_view","bg_line","association_info_node","chess_team_yes_node"};  
    [FriendsInfoScene.s_controls.chess_team_no] = {"info_view","bg_line","association_info_node","chess_team_no_node"};

    [FriendsInfoScene.s_controls.city_info] = {"info_view","bg_line","city_info"};--城市信息
    --[FriendsInfoScene.s_controls.chess_num_info]                      = {"info_view","bg_line","chess_num_info"};--胜负和
    [FriendsInfoScene.s_controls.signature_txv] = {"info_view","bg_line","signature_txv"};--个性签名
    [FriendsInfoScene.s_controls.signature_editv] = {"info_view","bg_line","signature_editv"};--个性签名
    --[FriendsInfoScene.s_controls.my_intro]                            = {"info_view","bg_line","sign_bg","my_intro"};--个性签名
    --界面切换
    [FriendsInfoScene.s_controls.replay_item] = {"replay_item"};--棋局推荐
    [FriendsInfoScene.s_controls.record_item] = {"record_item"};--战绩
    [FriendsInfoScene.s_controls.honor_item] = {"honor_item"};--荣誉

    [FriendsInfoScene.s_controls.record_bn] = {"top_btn_node","record_bn"};    --切换战绩界面的按钮
    [FriendsInfoScene.s_controls.honor_bn] = {"top_btn_node","honor_bn"};      --切换荣誉界面的按钮
    [FriendsInfoScene.s_controls.replay_bn] = {"top_btn_node","replay_bn"};    --切换推荐棋谱界面的按钮

}
--view event map function
FriendsInfoScene.s_controlFuncMap =
{
	[FriendsInfoScene.s_controls.back_bn] = FriendsInfoScene.onFriendsBackBtnClick;
    [FriendsInfoScene.s_controls.challenge_btn] = FriendsInfoScene.onFriendsChallengeBtnClick;
    [FriendsInfoScene.s_controls.send_message_bn] = FriendsInfoScene.onFriendsMesBtnClick;
    [FriendsInfoScene.s_controls.reportBad_btn] = FriendsInfoScene.onReportBadBtnClick;
    [FriendsInfoScene.s_controls.add_blacklist_btn] = FriendsInfoScene.addBlackList;
    [FriendsInfoScene.s_controls.friendsinfo_icon_mask] = FriendsInfoScene.onFriendsinfoiconClick;
    [FriendsInfoScene.s_controls.chess_team_yes] = FriendsInfoScene.onChessTeamYesClick;
};

--control cmd map function
--开放给controller的接口
FriendsInfoScene.s_cmdConfig =
{
    
    [FriendsInfoScene.s_cmds.changeFriendTile]    = FriendsInfoScene.changeFriendTileCall;

    [FriendsInfoScene.s_cmds.changeFriendsData]   = FriendsInfoScene.changeDataCall;
    [FriendsInfoScene.s_cmds.updateRecordData] = FriendsInfoScene.updateRecordData;
    [FriendsInfoScene.s_cmds.updateHonorData] = FriendsInfoScene.updateHonorData;
    [FriendsInfoScene.s_cmds.changeFriendstatus]  = FriendsInfoScene.changeStatusCall; 
    
    [FriendsInfoScene.s_cmds.change_userIcon]     = FriendsInfoScene.updateUserIcon;
    [FriendsInfoScene.s_cmds.recv_chat_msg_state] = FriendsInfoScene.onReceChatMsgState;
    [FriendsInfoScene.s_cmds.friends_num]         = FriendsInfoScene.onChangeFriendsNum;
    [FriendsInfoScene.s_cmds.follow_num]          = FriendsInfoScene.onChangeFollowNum;
    [FriendsInfoScene.s_cmds.fans_num]            = FriendsInfoScene.onChangeFansNum;
    [FriendsInfoScene.s_cmds.get_suggestchess]    = FriendsInfoScene.onGetSuggestCallBack;
    [FriendsInfoScene.s_cmds.save_mychess]        = FriendsInfoScene.onSaveMychessCallBack;
    [FriendsInfoScene.s_cmds.modify_sign]         = FriendsInfoScene.onSaveSignCallBack;
    [FriendsInfoScene.s_cmds.updataWinCombo]        = FriendsInfoScene.onWinComboCallBack;
    [FriendsInfoScene.s_cmds.setShowUserViewMid]    = FriendsInfoScene.setShowUserViewMid;
    
}



