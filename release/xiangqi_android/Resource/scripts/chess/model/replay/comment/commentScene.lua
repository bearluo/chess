
require(BASE_PATH.."chessScene");
require("view/selectButton");
require("dialog/progress_dialog");
require("dialog/create_room_dialog");

CommentScene = class(ChessScene);

CommentScene.s_controls = 
{
    back_btn            = 1;
    content_view        = 2;
}

CommentScene.s_cmds = 
{
    add_comment         = 1;
    get_hot_comment     = 2;
    get_all_comment     = 3;
    get_like_num        = 4;
}

CommentScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = CommentScene.s_controls;
    self:initView();
end 

CommentScene.resume = function(self)
    ChessScene.resume(self);
    self:loadHotCommentList();
    self:loadAllCommentList();
end;

CommentScene.pause = function(self)
	ChessScene.pause(self);
--    call_native(kCommentWebViewClose);
end 


CommentScene.dtor = function(self)

end 


------------------------------function------------------------------
CommentScene.initView = function(self)
    -- title
    self.m_title_view = self.m_root:getChildByName("title_view");
    self.m_back_btn =  self.m_title_view:getChildByName("back_btn");
    self.m_back_btn:setTransparency(0.6);
    -- content
    self.m_comment_view = self.m_root:getChildByName("comment_view");
        -- comment
        self.m_comment = self.m_comment_view:getChildByName("comment");
            -- hot_comment
            self.m_hot_comment_view = self.m_comment:getChildByName("hot_comment_view");
            self.m_hot_comment_view:setSize(630,466);
            -- all_comment
            self.m_all_comment_view = self.m_comment:getChildByName("all_comment_view");
            self.m_all_comment_view:setSize(630,422);
        -- no_comment
        self.m_no_comment = self.m_comment_view:getChildByName("no_comment");
            -- comment_btn
            self.m_comment_btn = self.m_no_comment:getChildByName("comment_btn");
            self.m_comment_btn:setOnClick(self, self.commentRightNow);
    -- bottom
    self.m_bottom_view = self.m_root:getChildByName("bottom_view");
        -- edit_text
        self.m_send_edit = self.m_bottom_view:getChildByName("edit_send");
        self.m_send_edit:setHintText("点击输入评论内容",165,145,120);
        -- send_btn
        self.m_send_btn = self.m_bottom_view:getChildByName("send_btn");

        self.m_send_btn:setOnClick(self,self.sendBtnClick);
    self.m_data = UserInfo.getInstance():getDapuSelData();
    self.m_comment_cost = UserInfo.getInstance():getFPcostMoney().comment_manual;
--    ChessToastManager.getInstance():showSingle("评论棋局花费您".. (self.m_comment_cost or 50) .."金币",2000);
end;

CommentScene.commentRightNow = function(self)
    self.m_no_comment:setVisible(false);
    self.m_comment:setVisible(false);
    self.m_send_edit:showInputDialog();
end;

CommentScene.sendBtnClick = function(self)
    -- php提交评论，成功后扣金币加入view中
    local lenMsg = string.lenutf8(self.m_send_edit:getText());
    if lenMsg <= 140 then
        self:requestCtrlCmd(CommentController.s_cmds.comment_action,self.m_data.manual_id,self.m_send_edit:getText());
    else
        ChessToastManager.getInstance():showSingle("字数超过140了",2000);
    end;

end;

CommentScene.loadHotCommentList = function(self)
    self:requestCtrlCmd(CommentController.s_cmds.hot_comment,self.m_data.manual_id);
end;


CommentScene.loadAllCommentList = function(self)
    self:requestCtrlCmd(CommentController.s_cmds.all_comment,self.m_data.manual_id,0,10);
end;





CommentScene.setLikeThisChess = function(self, chessItem, like)
    self.m_chess_item = chessItem;
    self:requestCtrlCmd(CommentController.s_cmds.set_like,chessItem:getData().comment_id,like);
end;
--CommentScene.showShareListWebView = function(self)
--	local width_content,height_content = self.m_content_holder:getSize();
--    local absoluteX,absoluteY = self.m_content_holder:getAbsolutePos();
--    local x = absoluteX*System.getLayoutScale();
--    local y = 70*System.getLayoutScale();
--    local width = width_content*System.getLayoutScale();
--    local height = height_content*System.getLayoutScale() - 70*System.getLayoutScale();
--    NativeEvent.getInstance():showCommentWebView(x,y,width,height);
--end;

CommentScene.onBackActionBtnClick = function(self)
    self:requestCtrlCmd(CommentController.s_cmds.back_action);
end;

-- 增加评论
CommentScene.onAddComment = function(self,addItem)
    if not addItem then return end
    if self.m_all_list then
        self.m_all_list:removeAllChildren();
    end;
    table.insert(self.m_all_data_list,1,addItem);
    for index = 1,#self.m_all_data_list do
        local allItem = new(CommentSceneItem,self.m_all_data_list[index],self);
        self.m_all_list:addChild(allItem);
    end
    self.m_all_comment_view:addChild(self.m_all_list);
    ChessToastManager.getInstance():showSingle(GameString.convert2UTF8("评论成功！"),2000);
    self.m_send_edit:setText(nil);
    self.m_no_comment:setVisible(false);
    self.m_comment:setVisible(true);
end;



CommentScene.onGetHotComment = function(self, data)
    Log.i("CommentScene.onGetHotComment");
    self.m_hot_data_total = data.total;
    self.m_hot_data_list  = data.list;
    table.sort(self.m_hot_data_list, function(a,b)
        return tonumber(a.like_num) > tonumber(b.like_num); 
    end)
    
    self.m_hot_list = new(ScrollView,0,0,630,466,true);
    for index = 1,#self.m_hot_data_list do
        local hotItem = new(CommentSceneItem,self.m_hot_data_list[index],self,1);
        self.m_hot_list:addChild(hotItem);
    end
    self.m_hot_comment_view:addChild(self.m_hot_list);
    if #self.m_hot_data_list == 0 then
        self.m_no_comment:setVisible(true)
        self.m_comment:setVisible(false);
    else
        self.m_no_comment:setVisible(false)
        self.m_comment:setVisible(true);       
    end;
end;


CommentScene.onGetAllComment = function(self, data)
    Log.i("CommentScene.onGetAllComment");
    self.m_all_data_total = data.total;
    self.m_all_data_list  = data.list;
    table.sort(self.m_all_data_list, function(a,b)
        return tonumber(a.add_time) > tonumber(b.add_time); 
    end)
    
    self.m_all_list = new(ScrollView,0,0,630,422,true);
    for index = 1,#self.m_all_data_list do
        local allItem = new(CommentSceneItem,self.m_all_data_list[index],self,2);
        self.m_all_list:addChild(allItem);
    end
    self.m_all_comment_view:addChild(self.m_all_list);
    if #self.m_all_data_list == 0 then
        self.m_no_comment:setVisible(true)
        self.m_comment:setVisible(false);
    else
        self.m_no_comment:setVisible(false)
        self.m_comment:setVisible(true);   
    end;
end;


CommentScene.onGetLikeComment = function(self, data)
    self.m_chess_item:setLikeType(data.is_like,data.like_num);
    self.m_chess_item:synAllandHotLikeType();
end;

CommentScene.synAllandHotLikeType = function(self, commentItem)
    self.m_comment_item = commentItem;
    if self.m_comment_item:getCommentType() == 1 then
        local all_comment_child = self.m_all_list:getChildren();
        for index = 1, #all_comment_child do
            if tonumber(all_comment_child[index]:getData().comment_id) == tonumber(self.m_comment_item:getCommentId()) then
                all_comment_child[index]:setLikeType(self.m_comment_item:getData().is_like,self.m_comment_item:getData().like_num);
            end;
        end;
    elseif self.m_comment_item:getCommentType() == 2 then
        local hot_comment_child = self.m_hot_list:getChildren();
        for index = 1, #hot_comment_child do
            if tonumber(hot_comment_child[index]:getData().comment_id) == tonumber(self.m_comment_item:getCommentId()) then
                hot_comment_child[index]:setLikeType(self.m_comment_item:getData().is_like,self.m_comment_item:getData().like_num);
            end;
        end;       
    end;
end;


---------------------------------config-------------------------------
CommentScene.s_controlConfig = 
{
	[CommentScene.s_controls.back_btn]         = {"title_view","back_btn"};
    [CommentScene.s_controls.content_view]     = {"content_view","content_holder"};
};

--定义控件的触摸响应函数
CommentScene.s_controlFuncMap =
{
	[CommentScene.s_controls.back_btn]        = CommentScene.onBackActionBtnClick;
};

CommentScene.s_cmdConfig = 
{
    [CommentScene.s_cmds.add_comment]         =    CommentScene.onAddComment;  
    [CommentScene.s_cmds.get_hot_comment]     =    CommentScene.onGetHotComment;   
    [CommentScene.s_cmds.get_all_comment]     =    CommentScene.onGetAllComment;          
    [CommentScene.s_cmds.get_like_num]        =    CommentScene.onGetLikeComment; 
    
    
                          
}




CommentSceneItem = class(Node);



CommentSceneItem.ctor = function(self, data, room, commentType)
    if not data then return end;
    self.m_data = data;
    self.m_room = room;
    self.m_comment_type = commentType;--1hot,2all
    --------------view--------------
    -- line
    self.m_title_line = new(Image,"common/decoration/name_line.png");
    self.m_title_line:setSize(630,nil);
    self.m_title_line:setAlign(kAlignTop);
    self:addChild(self.m_title_line);
    -- title
    self.m_title_view = new(Node)
    self.m_title_view:setSize(630,80);
    self:addChild(self.m_title_view);
        -- icon_frame
        self.m_icon_frame = new(Image,"userinfo/icon_5151_frame.png");
        self.m_icon_frame:setPos(nil,20);
        self.m_title_view:addChild(self.m_icon_frame);
        -- user_name
        self.m_user_name = new(Text, "Just gogogo",0,0,nil,nil,28,65,120,190);
        self.m_user_name:setPos(70,25);
        self.m_title_view:addChild(self.m_user_name);
        -- msg_order
        self.m_msg_order = new(Text, 1 .."楼",0,0,kAlignLeft,nil,28,120,120,120);
        self.m_msg_order:setPos(150,0);
        self.m_msg_order:setAlign(kAlignRight);
        self.m_title_view:addChild(self.m_msg_order);
        -- like_img
        self.m_like_img = new(Button,"replay/like_normal.png");
        self.m_like_img:setAlign(kAlignRight);
        self.m_like_img:setPos(70,0);
        self.m_like_img:setOnClick(self, self.onLikeImgTouch);
        self.m_title_view:addChild(self.m_like_img);
            -- like_txt
            self.m_like_txt =new(Text, "28",0,0,kAlignLeft,nil,28,120,120,120);
            self.m_like_txt:setPos(40,0);
            self.m_like_txt:setAlign(kAlignCenter);           
            self.m_like_img:addChild(self.m_like_txt);

    -- content
    local msg = self.m_data.comment_text;
    self.m_content_txt = new(TextView, msg or "",570,0,nil,nil,28,80,80,80);
    self.m_content_txt:setPos(60,80);
--    self.m_content_txt:setSize(570,28);
    self:addChild(self.m_content_txt);
    -- time
    self.m_time_txt = new(Text, "54分钟前",0,0,kAlignLeft,nil,20,120,120,120);
    
    self:addChild(self.m_time_txt);
    -------------view end--------------

    self:initTitle();
    self:initContent();
    local contentW,contentH = self.m_content_txt:getSize();
    self.m_time_txt:setPos(60,contentH + 80 + 10);-- 80是titile高，10是时间与content空隙距离
    -- 80是titile高，20是时间与content空隙距离,20是时间高，20是下边距
    self:setSize(630,contentH + 80 + 20 + 20 + 20);
end;

-- 初始化title
CommentSceneItem.initTitle = function(self)
    local icon = self.m_data.icon_url;
    if not self.m_user_icon then
        if not icon then 
            if self.m_data.iconType and self.m_data.iconType >0  then
                icon = UserInfo.DEFAULT_ICON[self.m_data.iconType] or UserInfo.DEFAULT_ICON[1];
            else
                icon = UserInfo.DEFAULT_ICON[4]
            end;
            self.m_user_icon = new(Mask,icon ,"userinfo/icon_4646_mask.png");
        else
            self.m_user_icon = new(Mask,"drawable/blank.png" ,"userinfo/icon_4646_mask.png");
            self.m_user_icon:setUrlImage(icon,"userinfo/man_head01.png");            
        end;
        self.m_user_icon:setSize(46,46);
        self.m_user_icon:setAlign(kAlignCenter);
        self.m_icon_frame:addChild(self.m_user_icon)
    else
        if not icon then 
            if self.m_data.iconType and self.m_data.iconType >0 then
                icon = UserInfo.DEFAULT_ICON[self.m_data.iconType] or UserInfo.DEFAULT_ICON[1];
            else
                icon = UserInfo.DEFAULT_ICON[4]
            end;
            self.m_user_icon:setFile(icon);
        else
            self.m_user_icon:setUrlImage(icon);            
        end;   
    end    
    self.m_user_name:setText(self.m_data.mnick or "博雅象棋");
    self.m_msg_order:setText((self.m_data.floor_num or 0) .."楼");
    self.m_like_txt:setText(self.m_data.like_num or 0);
    if self.m_data.is_like then
        if tonumber(self.m_data.is_like) == 0 then
            self.m_like_img:setFile("replay/like_normal.png");
        elseif tonumber(self.m_data.is_like) == 1 then
            self.m_like_img:setFile("replay/like_press.png");
        end;
    end;
end;

-- 初始化内容
CommentSceneItem.initContent = function(self)
    local w, h = self.m_content_txt:getSize();
    self.m_content_txt:setSize(nil,h);
    local easyTime = ToolKit.getEasyTime(self.m_data.add_time or 0);
    self.m_time_txt:setText(easyTime);
end;



CommentSceneItem.onLikeImgTouch = function(self)
    if tonumber(self.m_data.is_like) == 0 then
        self.m_room:setLikeThisChess(self,1);
    elseif tonumber(self.m_data.is_like) == 1 then
        self.m_room:setLikeThisChess(self,0);
    end;
end;


CommentSceneItem.setLikeType = function(self,islike,like_num)
    if self.m_data.is_like then
        if islike == 0 then
            if like_num > 0 then
                self.m_like_img:setFile("replay/like_press.png");
            else
                self.m_like_img:setFile("replay/like_normal.png");
            end;
        elseif islike == 1 then
            self.m_like_img:setFile("replay/like_press.png");
        end;
        self.m_data.is_like = islike;
        self.m_data.like_num = like_num;
        self.m_like_txt:setText(like_num);
    end;
end;



CommentSceneItem.getData = function(self)
    return self.m_data;
end;

-- 同步全部评论和热门评论赞状态
CommentSceneItem.synAllandHotLikeType = function(self)
    self.m_room:synAllandHotLikeType(self);
end;



CommentSceneItem.getCommentType = function(self)
    return self.m_comment_type;
end;


CommentSceneItem.getCommentId = function(self)
    return self.m_data.comment_id;
end;