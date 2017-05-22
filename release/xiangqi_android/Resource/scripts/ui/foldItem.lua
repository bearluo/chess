--FoldItem.lua
--Date 2016.10.24
-- 滑动折叠
--endregion

FoldItem = class(Node)

FoldItem.DEFAULT_FOLD_STATUS = 0
FoldItem.RETRACT_ITEM = -1
FoldItem.LAUNCH_ITEM = 1
FoldItem.MIN_HEIGHT = 70
FoldItem.ITEM_WIDTH = 600;

--[Comment]
--plist： 配置参数 需要传按钮长宽 和 节点长款
function FoldItem.ctor(self,plist)
    if not plist or type(plist) ~= "table" then return end
    self.item_width = plist.item_width or FoldItem.ITEM_WIDTH
    self.item_height = plist.item_height or FoldItem.MIN_HEIGHT
    self.btn_width = plist.btn_width or FoldItem.ITEM_WIDTH
    self.btn_height = plist.btn_height or FoldItem.MIN_HEIGHT
    self.m_status = plist.status or FoldItem.DEFAULT_FOLD_STATUS
    self:createView()
end

function FoldItem.dtor(self)
    
end

--[Comment]
--标题按钮点击事件
function FoldItem.titleClick(self)
    local w,h = self:getSize();
    if h > self.item_height then
        self.arr_icon:setFile("common/icon/launch_icon.png");
        self:retractItem();
    elseif h <= self.item_height then
        self.arr_icon:setFile("common/icon/up_icon.png");
        self:launchItem();
    end
end

--[Comment]
--展开item
function FoldItem.launchItem(self)
    self.m_status = FoldItem.LAUNCH_ITEM;
    if self.m_launch_anim then 
        delete(self.m_launch_anim);
        self.m_launch_anim = nil;
    end

    self.m_launch_anim = new(AnimInt,kAnimLoop,0,1,1000/60,-1);
    if self.m_launch_anim then
        self.m_launch_anim:setEvent(self,self.addItemHeight);
    end
end

--[Comment]
--折叠item
function FoldItem.retractItem(self)
    self.m_status = FoldItem.RETRACT_ITEM;
    if self.m_launch_anim then 
        delete(self.m_launch_anim);
        self.m_launch_anim = nil;
    end

    self.m_up_anim = new(AnimInt,kAnimLoop,0,1,1000/60,-1);
    if self.m_up_anim then
        self.m_up_anim:setEvent(self,self.reduceItemHeight);
    end
end

--[Comment]
--item展开动画
function FoldItem.addItemHeight(self)
    local w,h = self:getSize();
    local speed = self.scroll_speed or math.ceil((self.item_height + 10)/9);
   
    if h >= self.btn_height and h < (self.item_height + self.btn_height) then
        self.clip_view:setClip(0,0,self.item_width,h + speed);
        self:setSize(self.item_width,h + speed);
    else
        self:stopAnim();
    end
    self:onExecuteCallback()
end

--[Comment]
--折叠动画
function FoldItem.reduceItemHeight(self)
    local w,h = self:getSize();
    local speed = math.ceil((self.item_height + 10)/9);
    if h > self.btn_height then
        self.clip_view:setClip(0,0,self.item_width,h - speed);
        self:setSize(self.item_width,h - speed);
    else
        self:stopAnim();
    end
    self:onExecuteCallback()
end

--[Comment]
--获得当前折叠状态
function FoldItem.getFoldStatus(self)
    return self.m_status
end

function FoldItem.stopAnim(self)
    self.m_status = FoldItem.DEFAULT_FOLD_STATUS;
    
    if self.m_launch_anim then 
        delete(self.m_launch_anim);
        self.m_launch_anim = nil;
    end
    if self.m_up_anim then 
        delete(self.m_up_anim);
        self.m_up_anim = nil;
    end
end

--[Comment]
--设置动画回调事件
function FoldItem.setAnimCallback(self,obj,func)
    self.m_anim_obj = obj
    self.m_anim_func = func
end

function FoldItem.onExecuteCallback(self,...)
    if type(self.m_anim_func) ~= 'function' then return end
    if self.m_anim_func and self.m_anim_obj then
        self.m_anim_func(self.m_anim_obj,...)
    end
end

--[Comment]
--添加自定义界面
function FoldItem.updataItem(self,view)
    if not view then return end
    local node = view
    local w,h = node:getSize()
    self.item_height = h
    self.clip_view:addChild(node)
end

function FoldItem.createView(self)
    self.clip_view = new(Node);
    self.clip_view:setFillParent(true,true);
    self.clip_view:setClip(0,0,self.item_width,self.item_height);
    self.clip_view:setPos(0,0)

    self.title_btn = new(Button,"drawable/blank.png","drawable/blank_press.png")
    self.title_btn:setSize(self.item_width,self.btn_height);
    self.title_btn:setAlign(kAlignTop)
    self.title_btn:setOnClick(self,self.titleClick)
    self.title_btn:setSrollOnClick(nil,function() end);
    self.arr_icon = new(Image,"common/icon/launch_icon.png")
    self.arr_icon:setAlign(kAlignRight)
    self.arr_icon:setPos(10,0)
    self.title_btn:addChild(self.arr_icon)
    self.clip_view:addChild(self.title_btn)
    self:setSize(self.item_width,self.item_height);
    self:setPos(0,0)
    self:setAlign(kAlignTop)
    self:addChild(self.clip_view)
end

function FoldItem.setButtonImg(self,file)
    if not file or type(file) ~= 'table' then return end
    local tab = file
    if not tab[1] then
         return
    end
    self.title_btn:setFile(tab[1],tab[2] or "") 
end

function FoldItem.setArrImg(self,file)
    if not file or type(file) ~= 'string' then return end
    self.arr_icon:setFile(file) 
end