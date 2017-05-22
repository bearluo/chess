require(VIEW_PATH .. "arena_help_dialog_view");
require(BASE_PATH.."chessDialogScene")

ArenaTipsDialog = class(ChessDialogScene,false);

ArenaTipsDialog.ctor = function(self)
    super(self,arena_help_dialog_view);
    
    self.mRootView  = self.m_root;
    self.mBg        = self.mRootView:getChildByName("bg");
    self.mTime1     = self.mBg:getChildByName("time1"):getChildByName("num");
    self.mTime2     = self.mBg:getChildByName("time2"):getChildByName("num");
    self.mTime3     = self.mBg:getChildByName("time3"):getChildByName("num");
    self.mRichTextHandler = self.mBg:getChildByName("rich_text_handler");
    self.mCloseBtn  = self.mBg:getChildByName("close_btn");
    self.mCloseBtn:setOnClick(self,self.dismiss);
    self.mNoTips    = self.mBg:getChildByName("no_tips");
    self.mNoTips:setOnClick(self,self.changeArenaTipsBoolean);
    self.mNoTipsChecked = self.mNoTips:getChildByName("checked");
    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)
end

ArenaTipsDialog.dtor = function(self)
    self.mDialogAnim.stopAnim()
end

function ArenaTipsDialog.show(self,params)
    self.super.show(self,self.mDialogAnim.showAnim);
    local uid = UserInfo.getInstance():getUid() or 0;
    local isTrue = GameCacheData.getInstance():getBoolean(GameCacheData.ARENA_TIPS_ .. uid,false);
    self.mNoTipsChecked:setVisible(isTrue);

    self.mTime1:setText(self:getTimeTxt(params.time1,"0秒"));
    self.mTime2:setText(self:getTimeTxt(params.time2,"0秒"));
    self.mTime3:setText(self:getTimeTxt(params.time3,"不读秒"));
    self.mRichTextHandler:removeAllChildren(true);
    local width,height = self.mRichTextHandler:getSize();
    local str = string.format("每局收取#c199B28%d金币#n台费,步时、读秒超时均算负。红黑方由系统随机分配。#l*本场次获胜均可获得奖杯,每周获得奖杯数最多的#c199B28前100名棋友#n可以获得棋魂奖励，棋魂可以兑换话费。",params.money);
    local richText = new(RichText, str, width-10, height, kAlignTopLeft, fontName, 28, 80, 80, 80, true,10);

    self.mRichTextHandler:addChild(richText);
end

function ArenaTipsDialog.dismiss(self)
    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
end

function ArenaTipsDialog.changeArenaTipsBoolean(self)
    local uid = UserInfo.getInstance():getUid() or 0;
    local isTrue = GameCacheData.getInstance():getBoolean(GameCacheData.ARENA_TIPS_ .. uid,false);
    isTrue = not isTrue;
    self.mNoTipsChecked:setVisible(isTrue);
    GameCacheData.getInstance():saveBoolean(GameCacheData.ARENA_TIPS_ .. uid,isTrue);
end

function ArenaTipsDialog.getTimeTxt(self,time,def)
    if not time then return def end
    local ret = time .. "秒";
    time = tonumber(time);
    if time == 0 then return def end
    if not time then return ret end
    if time >= 60 then 
        time = time/60
        ret = time .. "分"
    end
    if time >= 60 then 
        time = time/60
        ret = time .. "时"
    end
    return ret;
end