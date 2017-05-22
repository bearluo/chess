require(VIEW_PATH.."recently_player_item_view");

RecentlyPlayerItem2 = class(Node)

RecentlyPlayerItem2.ctor = function(self,data)
    self.root = SceneLoader.load(recently_player_item_view);
    self:addChild(self.root);
    local w,h = self.root:getSize();
    self:setSize(w,h);
    self.data = data;
    self.headView = self.root:getChildByName("head_view");
    self.name = self.root:getChildByName("name");
    self.score = self.root:getChildByName("score");
    self.followBtn = self.root:getChildByName("follow_btn");
    self.unfollowBtn = self.root:getChildByName("unfollow_btn");
    self.followBtn:setOnClick(self,self.onFollowBtnClick);
    self.followBtn:setSrollOnClick();
    self.unfollowBtn:setOnClick(self,self.onFollowBtnClick);
    self.followBtn:setSrollOnClick();
    local name = data.mnick or "";
    self.name:setText(name);
    
    local score = data.score or "";
    self.score:setText("积分 "..score);

    local w,h = self.headView:getSize();
    self.headIcon = new(Mask,UserInfo.DEFAULT_ICON[1],"common/background/head_mask_bg_86.png")
    self.headIcon:setSize(w,h);
    if data.iconType == -1 and data.icon_url ~= nil then
        self.headIcon:setUrlImage(data.icon_url);
	else
        if not data.iconType or data.iconType <= 0 or data.iconType>4 then
            data.iconType = 1;
        end
		self.headIcon:setFile(UserInfo.DEFAULT_ICON[data.iconType]);
    end
    self.headView:addChild(self.headIcon);

    self:updateRelation(data.relation);
end

RecentlyPlayerItem2.updateRelation = function(self,relation)
    self.data.relation = tonumber(relation) or self.data.relation;
    if self.data.relation == 0 or self.data.relation == 1 then
        self.followBtn:setVisible(true);
        self.unfollowBtn:setVisible(false);
    else
        self.followBtn:setVisible(false);
        self.unfollowBtn:setVisible(true);
    end
end

RecentlyPlayerItem2.getTargetMid = function(self)
    return tonumber(self.data.mid);
end

RecentlyPlayerItem2.setFollowBtnClick = function(self,obj,func)
    self.followBtnClickObj = obj;
    self.followBtnClickFunc = func;
end

RecentlyPlayerItem2.onFollowBtnClick= function(self)
    if self.followBtnClickFunc then
        self.followBtnClickFunc(self.followBtnClickObj,self.data);
    end
end