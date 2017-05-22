--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23

require(BASE_PATH.."chessScene");


HelpScene = class(ChessScene);

HelpScene.step = 0.1;   --每次加减声音的大小
HelpScene.max  = 1.0;   --最大音量
HelpScene.min  = 0.0;    -- 最小音量

HelpScene.s_controls = 
{
    content_view                = 1;
    back_btn                    = 2;
    title_icon                  = 3;
    top_view                    = 4;
    version_text                = 5;
    bottom_view                 = 6;
    content_text                = 7;
}

HelpScene.s_cmds = 
{
}


HelpScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = HelpScene.s_controls;
    self:create();
end 

HelpScene.resume = function(self)
    ChessScene.resume(self);
--    self:removeAnimProp();
--    self:resumeAnimStart();
end

HelpScene.isShowBangdinDialog = false;

HelpScene.pause = function(self)
	ChessScene.pause(self);
    self:removeAnimProp();
--    self:pauseAnimStart();
end 

HelpScene.dtor = function(self)
    delete(self.anim_start);
    delete(self.anim_end);
end 

HelpScene.removeAnimProp = function(self)
    if self.m_anim_prop_need_remove then
--        self.m_content_view:removeProp(1);
        self.m_title_icon:removeProp(1);
--        self.m_back_btn:removeProp(1);
--        self.m_top_view:removeProp(1);
    --    self.m_more_btn:removeProp(1);
--        self.m_bottom_view:removeProp(1);
        self.m_leaf_left:removeProp(1);
        self.m_anim_prop_need_remove = false;
    end
end

HelpScene.setAnimItemEnVisible = function(self,ret)
    self.m_leaf_left:setVisible(ret);
end

HelpScene.resumeAnimStart = function(self,lastStateObj,timer)
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

--    self.m_content_view:addPropTransparency(1,kAnimNormal,waitTime,delay,0,1);
--    self.m_top_view:addPropTransparency(1,kAnimNormal,waitTime,delay,0,1);
--    self.m_bottom_view:addPropTransparency(1,kAnimNormal,waitTime,delay,0,1);
    local lw,lh = self.m_leaf_left:getSize();
    self.m_leaf_left:addPropTranslate(1, kAnimNormal, waitTime, delay, -lw, 0, -10, 0);
    local tw,th = self.m_title_icon:getSize();
    local anim = self.m_title_icon:addPropTranslate(1, kAnimNormal, waitTime, delay, 0, 0, -th, 0);
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

HelpScene.pauseAnimStart = function(self,newStateObj,timer)
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

--    self.m_content_view:addPropTransparency(1,kAnimNormal,waitTime,-1,0,1);
--    self.m_top_view:addPropTransparency(1,kAnimNormal,waitTime,-1,0,1);
--    self.m_bottom_view:addPropTransparency(1,kAnimNormal,waitTime,-1,0,1);
    local lw,lh = self.m_leaf_left:getSize();
    self.m_leaf_left:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, -lw, 0, -10);
    local w,h = self.m_title_icon:getSize();
    local anim = self.m_title_icon:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, 0, 0, -h);
    if anim then
        anim:setEvent(self,function()
            self:setAnimItemEnVisible(false);
        end);
    end
end

---------------------- func --------------------
HelpScene.create = function(self)
	self.m_back_btn = self:findViewById(self.m_ctrls.back_btn);
	self.m_title_icon = self:findViewById(self.m_ctrls.title_icon);
	self.m_content_view = self:findViewById(self.m_ctrls.content_view);
	self.m_top_view = self:findViewById(self.m_ctrls.top_view);
    self.m_version_text = self.m_top_view:getChildByName("version_text");
	if kPlatform == kPlatformIOS then
        if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
            self.m_version_text:setVisible(true); 
            self.m_version_text:setText("版本号:"..kLuaVersion);
        else
            self.m_version_text:setVisible(false);
        end;
    else
        self.m_version_text:setVisible(true);
        self.m_version_text:setText("版本号:"..kLuaVersion);
    end;
	self.m_bottom_view = self:findViewById(self.m_ctrls.bottom_view);
    self.m_leaf_left = self.m_root:getChildByName("bamboo_left");
    self.m_leaf_left:setFile("common/decoration/left_leaf.png")

    self.m_chess_name = {"游戏介绍",
		                 "联网对战",
		                 "积分和棋力等级",
                         "抢先",
		                 "让子",
		                 "好友对战和私人房",
		                 "棋局观战",
                         "复盘演练",
                         "街边残局"};
	self.m_chess_introduce = {[1] = "    博雅中国象棋立志成为棋友最喜欢的中国象棋。为棋友提供「联网对战」、「残局闯关」、「单机闯关」、「复盘演练」、「街边残局」和「棋局观战」等多种对弈和学习的功能，全面展现中国象棋的魅力。",
	                          [2] = "    棋友在联网对战可以匹配棋力相当的对手对弈，赢取积分提高自己的棋力等级；赢取游戏金币获得更多的游戏功能。双方棋力等级相差越大，积分赢取越多；底注和倍数越高，赢取游戏金币越多。",
	                          [3] = {},
                              [4] = "    联网对战中，可以通过抢先来获得‘执红先行’的机会。默认初始倍数为1倍，每次抢先在现有的倍数基础上再x2倍或x4倍,结算时输赢金币数为‘最终倍数*房间底注’ 。倍数越高，最终赢取金币越多。",
	                          [5] = "    联网对局中，执红先行的一方可以选择让子提高游戏的刺激性和趣味性，让子翻倍规则如下：让马x2倍、让炮x3倍、让车x5倍。",
	                          [6] = "    互相观战的玩家可相互关注，结为好友。联网游戏中，玩家可以向好友发起挑战，也可以创建私人房间，与陌生的棋友一起切磋棋艺。",
                              [7] = "    观看高手对局是很好的学习象棋的方式，联网游戏下方可以进入棋局观战，观战中会显示三级大师以上的对局和好友的对局，可以点击进入观看棋手对弈，还可以和其他旁观玩家交流互动。",
	                          [8] = "    观战及对战的棋局都会保存至「复盘演练」中的「最近棋局」中，默认保留最近的棋局，玩家可随时管理所保存的棋局。所有被收藏的棋局会在是「我的收藏」中展示。在「发现」的「动态」中，可查看好友公开收藏的所有棋局。",
                              [9] = "    创建残局或挑战非常规性残局有益于全局思考能力的培养，可有效提升棋艺。挑战人数越多，该街边残局的累计奖金越丰厚，首位破解残局的棋友可以获得所有的累计奖金。街边残局会定期更新换代，收藏喜欢的残局可以随时查看。"};
    local data = UserInfo.getInstance():getDanGrading();
    if data then
        self.m_chess_introduce[3][1] = string.format("%s=%d-%d      %s=%d-%d",data[1].name,data[1].min,data[1].max,data[6].name,data[6].min,data[6].max);
        self.m_chess_introduce[3][2] = string.format("%s=%d-%d   %s=%d-%d",data[2].name,data[2].min,data[2].max,data[7].name,data[7].min,data[7].max); 
        self.m_chess_introduce[3][3] = string.format("%s=%d-%d   %s=%d-%d",data[3].name,data[3].min,data[3].max,data[8].name,data[8].min,data[8].max); 
        self.m_chess_introduce[3][4] = string.format("%s=%d-%d   %s=%d及以上",data[4].name,data[4].min,data[4].max,data[9].name,data[9].min); 
        self.m_chess_introduce[3][5] = string.format("%s=%d-%d",data[5].name,data[5].min,data[5].max); 
    end
    local w,h = self.m_content_view:getSize();
    self.m_rule_content_scroll_view = new(ScrollView, 0, 0, w-100, h-20, false)
    self.m_rule_content_scroll_view:setAlign(kAlignCenter);
    self.m_content_view:addChild(self.m_rule_content_scroll_view);
    self:initContentView();
end


HelpScene.onBackAction = function(self)
    self:requestCtrlCmd(HelpController.s_cmds.onBack);
end

HelpScene.TEXT_LEFT = 10;
HelpScene.TEXT_SPACE = 10;
HelpScene.TEXT_SPACE_M = 40;
HelpScene.TEXT_WIDTH = 520;
HelpScene.FONTSIZE   = 28;
HelpScene.CHESS_NUM  = 9;

HelpScene.initContentView = function(self)
	

	local y_pos = 40;

	for index = 1,HelpScene.CHESS_NUM do
		local chess_name = new(Text, self.m_chess_name[index], nil, nil, kAlignLeft,nil,HelpScene.FONTSIZE,255, 128, 64);
		chess_name:setPos(HelpScene.TEXT_LEFT, y_pos);
		chess_name:setVisible(true);
        self.m_rule_content_scroll_view:addChild(chess_name);

		local w,h = chess_name:getSize();
		y_pos = y_pos + HelpScene.TEXT_SPACE + h;
		print_string(string.format("y_pos = %d , h = %d",y_pos,h));
        if index == 3 then
            for i = 1, HelpScene.CHESS_NUM do
                if self.m_chess_introduce[index][i] then 
                    local chess_introduce = new(TextView,self.m_chess_introduce[index][i],HelpScene.TEXT_WIDTH,nil,kAlignLeft,nil,23,135,100,95);
		        
		            chess_introduce:setPos(HelpScene.TEXT_LEFT, y_pos);
		            chess_introduce:setVisible(true);
                    self.m_rule_content_scroll_view:addChild(chess_introduce);
            
		            local w,h = chess_introduce:getSize();
		            y_pos = y_pos + HelpScene.TEXT_SPACE + h;
                end
            end;
		    print_string(string.format("y_pos = %d , h = %d",y_pos,h));
        else
            local chess_introduce = new(TextView,self.m_chess_introduce[index],HelpScene.TEXT_WIDTH,nil,kAlignLeft,nil,HelpScene.FONTSIZE,135,100,95);
		    		
		    chess_introduce:setPos(HelpScene.TEXT_LEFT,y_pos);
		    chess_introduce:setVisible(true);
            self.m_rule_content_scroll_view:addChild(chess_introduce);

		    w,h = chess_introduce:getSize();
		    y_pos = y_pos + HelpScene.TEXT_SPACE_M + h;
		    print_string(string.format("y_pos = %d , h = %d",y_pos,h));
        end
	end
end

---------------------- config ------------------
HelpScene.s_controlConfig = {
    [HelpScene.s_controls.content_view]                      = {"content_view"};
    [HelpScene.s_controls.content_text]                      = {"content_view","content_text"};
    [HelpScene.s_controls.back_btn]                          = {"back_btn"};
    [HelpScene.s_controls.title_icon]                        = {"title_icon"};
    [HelpScene.s_controls.top_view]                          = {"top_view"};
    [HelpScene.s_controls.version_text]                      = {"top_view","version_text"};
    [HelpScene.s_controls.bottom_view]                       = {"bottom_view"};

}

HelpScene.s_controlFuncMap = {
    [HelpScene.s_controls.back_btn]                        = HelpScene.onBackAction;
};

HelpScene.s_cmdConfig =
{
}