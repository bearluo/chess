-- commentStar.lua
-- by LeoLi 
-- data 2015/12/10


CommentStar = class(Node)

CommentStar.ctor = function(self, starNum)
    self.m_star_num = starNum;
    self:initView();
end;

CommentStar.dtor = function(self)
    
end;

CommentStar.setStarClickCallback = function(self, obj, fn)
    self.m_click_call_back_fn = fn;
    self.m_click_call_back_obj = obj;
end;

------------------------------- function -------------------------------
CommentStar.initView = function(self)
    self.m_stars = {};
    for index = 1, self.m_star_num do
        local newStar = new(StarItem, index,self, "ui/star_normal.png","ui/star_press.png");
        newStar:setPos(50 * (index - 1));
        self.m_stars[index] = newStar;
        self:addChild(newStar);
    end;
    self:setSize(50 * self.m_star_num, 50);
end;


CommentStar.setStar = function(self, star)
    for index = 1, self.m_star_num do
        self.m_stars[index]:setFile("ui/star_normal.png");
    end;     
    for index = 1, star do
        self.m_stars[index]:setFile("ui/star_press.png");
    end;
    if self.m_click_call_back_fn and self.m_click_call_back_obj then
        self.m_click_call_back_fn(self.m_click_call_back_obj,star);
    end;
end;



CommentStar.setStarClickable = function(self, enable)
    for index = 1, self.m_star_num do
        self.m_stars[index]:setPickable(enable);
    end;    
end;



------------------------------- starItem -------------------------------
StarItem = class(Button,false)

StarItem.ctor = function(self, index,parent, normal, press)
    super(self, normal, press);
    self.m_index = index;
    self.m_parent = parent;
    self:setOnClick(self, self.onStarItemClick);
end;

StarItem.dtor = function(self)

end;

StarItem.onStarItemClick = function(self)
    self.m_parent:setStar(self.m_index);
end;
