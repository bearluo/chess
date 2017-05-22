--region chessDialogScene.lua
--Author : BearLuo
--Date   : 2015/4/14
require("gameBase/gameLayer");

ChessDialogScene = class(GameLayer);

ChessDialogScene.s_dialogLayer = nil;
ChessDialogScene.s_mask_bg = "drawable/transparent_blank.png"
ChessDialogScene.MASKSHOWING = 1;       --正在渐变显示
ChessDialogScene.MASKDISMISSING = 2;    --正在渐变消失
ChessDialogScene.MASKNOTHING = 0;       --没有状态

ChessDialogScene.FORCE = 3;     --强制弹出，排在当前所有窗口最顶
ChessDialogScene.NORMAL = 2;    --正常弹出，按等级，若当前为强制，则排到第二个，若当前为自动和正常则覆盖在当前窗口之上,当前窗口隐藏,排到第二个
ChessDialogScene.AUTO = 1;      --自动弹出，排序最后等待显示

ChessDialogScene.kHttpLoadingDialog = 1;

ChessDialogScene.ctor = function(self,viewConfig)
    if not ChessDialogScene.s_dialogLayer then
        ChessDialogScene.s_dialogLayer = new(Node);
        ChessDialogScene.s_dialogLayer:addToRoot();
        ChessDialogScene.s_dialogLayer:setLevel(10);
        ChessDialogScene.s_mask = new(Image,ChessDialogScene.s_mask_bg);
        ChessDialogScene.s_mask:setFillParent(true,true);
        ChessDialogScene.s_mask:setVisible(false);
        ChessDialogScene.s_dialogLayer:addChild(ChessDialogScene.s_mask);
        ChessDialogScene.s_dialogLayer:setFillParent(true,true);
    end
    ChessDialogScene.s_dialogLayer:addChild(self);
    self.m_root:setLevel(1);
--    self.m_mask = new(Image,ChessDialogScene.s_mask_bg);
--    self.m_mask:setFillParent(true,true);
--    self:addChild(self.m_mask);
    self:setFillParent(true,true);
    self:setEventDrag(self,self.s_shieldDragClick);
    self:setEventTouch(self,self.s_shieldTouchClick);
    self:setVisible(false);
    self.m_clickCallBack = true;
    self.m_needBackEvent = true;          --是否需要监听回退事件
    self.m_dismissStatus = false;
    self.m_rootFlag = true;
end

ChessDialogScene.dtor = function(self)
    self.m_rootFlag = false;
	ChessDialogScene.dismiss(self);
end

ChessDialogScene.show = function(self,rootFlag,maskFlag,type) --rootFlag标志弹窗是否使用默认动画   true or nil 为默认，false为不使用；  type标志弹窗类型（3强弹，2正常，1自动）
--    if StateMachine.s_runState and (StateMachine.s_runState == 25 or StateMachine.s_runState == 29) then
--        self:setVisible(false);
--        return;
--    end
    self:setVisible(true);
    if ChessDialogManager.show(self,type) == false then	--若此弹窗不需要显示则返回
        return;
    end
    if ChessDialogScene.s_mask and maskFlag ~= false then
        if not ChessDialogScene.s_mask:getVisible() then
            ChessDialogScene.s_mask:setVisible(true);
            self:showAnimFunc();
        else
            if not ChessDialogScene.s_mask:checkAddProp(0) then              --mask有动画状态
                if ChessDialogScene.s_maskStatus == ChessDialogScene.MASKDISMISSING then    --动画为消失
                    ChessDialogScene.s_mask:removeProp(0);          --取消动画，改为显示
                    self:showAnimFunc();
                end
            end
        end
    end

    if rootFlag ~= false then
        if not self.m_root:checkAddProp(1) then
            self.m_root:removeProp(1);
        end
        if not self.m_root:checkAddProp(0) then
            self.m_root:removeProp(0);
        end
        self.m_dismissStatus = false;

--	    local anim = self.m_root:addPropScale(1, kAnimNormal, 100, 0, 0.9,1,0.9,1,kCenterDrawing);
        local anim = self.m_root:addPropScaleWithEasing(1,kAnimNormal,200,0,"easeInSine","easeInSine",0.9,0.2,kCenterDrawing);
        if anim then
            anim:setDebugName("ChessDialogScene,anim1");
	        anim:setEvent(nil,function()
                if not self.m_root:checkAddProp(1) then
                    self.m_root:removeProp(1);
                end
                if not self.m_root:checkAddProp(0) then
                    self.m_root:removeProp(0);
                end
	        end);
        end
    else
        self.m_rootFlag = false;
    end
end

ChessDialogScene.dismiss = function(self,rootFlag)
    Log.i("ChessDialogScene.dismiss");
    if (rootFlag ~= false) then
        if not self.m_root:checkAddProp(1) then
            self.m_root:removeProp(1);
        end
        if not self.m_root:checkAddProp(0) then
            self.m_root:removeProp(0);
        end
        self.m_dismissStatus = false;

--	    local anim = self.m_root:addPropScale(1, kAnimNormal, 100, 0, 1,0.8,1,0.8,kCenterDrawing);
        local anim = self.m_root:addPropScaleWithEasing(1,kAnimNormal,100,0,"easeOutSine","easeOutSine",1.1,-0.2,kCenterDrawing);
        self.m_root:addPropTransparency(0, kAnimNormal, 100, 1, 1, 0.5);
        if anim then
            self.m_dismissStatus = true;
            anim:setDebugName("ChessDialogScene,anim2");
	        anim:setEvent(nil,function()
                if not self.m_root:checkAddProp(1) then
                    self.m_root:removeProp(1);
                end
                if not self.m_root:checkAddProp(0) then
                    self.m_root:removeProp(0);
                end
                self:setVisible(false);
                self.m_dismissStatus = false;
                if not ChessDialogManager.existShowingDialog() then
                    ChessDialogScene.s_mask:setVisible(false);
                end
	        end);
        end
    end
    ChessDialogManager.dismiss(self);
    if not ChessDialogManager.existShowingDialog() then
        if ChessDialogScene.s_mask then
            if ChessDialogScene.s_mask:getVisible() then    
                if ChessDialogScene.s_maskStatus ~= ChessDialogScene.MASKDISMISSING then
                    self:dismissAnimFunc();
                end
            end
        end
    end
end

ChessDialogScene.showAnimFunc = function(self)
    if not ChessDialogScene.s_mask:checkAddProp(0) then
        ChessDialogScene.s_mask:removeProp(0);
    end
    local anim_mask = ChessDialogScene.s_mask:addPropTransparency(0, kAnimNormal, 100, 1, 0, 1);
    if anim_mask then 
        ChessDialogScene.s_maskStatus = ChessDialogScene.MASKSHOWING;
        anim_mask:setDebugName("ChessDialogScene,anim_mask1");
        anim_mask:setEvent(self, function()
            ChessDialogScene.s_mask:removeProp(0);
            ChessDialogScene.s_mask:setVisible(true);  
            ChessDialogScene.s_maskStatus = ChessDialogScene.MASKNOTHING;             
        end)
    end
end

ChessDialogScene.dismissAnimFunc = function(self)
    if not ChessDialogScene.s_mask:checkAddProp(0) then
        ChessDialogScene.s_mask:removeProp(0);
    end
    local anim_mask = ChessDialogScene.s_mask:addPropTransparency(0, kAnimNormal, 100, 1, 1, 0);
    if anim_mask then 
        ChessDialogScene.s_maskStatus = ChessDialogScene.MASKDISMISSING;
        anim_mask:setDebugName("ChessDialogScene,anim_mask2");
        anim_mask:setEvent(self, function()
            ChessDialogScene.s_mask:removeProp(0);
            ChessDialogScene.s_mask:setVisible(false);
            ChessDialogScene.s_maskStatus = ChessDialogScene.MASKNOTHING;
        end)
    end
end

ChessDialogScene.s_controls = 
{

};

ChessDialogScene.s_controlConfig = 
{
	--[ChessDialogScene.s_controls.***] = {"***","***","***"};
};

ChessDialogScene.s_shieldDragClick = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
--    Log.i("ChessDialogScene.s_shieldDragClick");
--    if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
--        if self.m_shield_func then
--            self.m_shield_func(self.m_shield_obj);
--        end
--    end
end

ChessDialogScene.s_shieldTouchClick = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
    Log.i("ChessDialogScene.s_shieldTouchClick");
    if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
        if self.m_shield_func then
            self.m_shield_func(self.m_shield_obj);
        end
    end
end

ChessDialogScene.setShieldClick = function(self,obj,func)
    self.m_shield_obj = obj;
    self.m_shield_func = func;
end

ChessDialogScene.findViewById = function(self,id)
    return self:getControl(id);
end

ChessDialogScene.setClickCallBack = function(self,flag)
    self.m_clickCallBack = flag;
end

ChessDialogScene.setNeedBackEvent = function(self,flag)
    self.m_needBackEvent = flag;
end

ChessDialogScene.isShowing = function(self)
	return self:getVisible();
end

--ChessDialogScene.setMaskVisible = function(self,flag)
--    self.m_mask:setVisible(flag);
--end

ChessDialogScene.setBgOnTouchClick = function(self,func)
    self:setEventDrag(self,func);
    self:setEventTouch(self,func);
end


------------------------ ChessDialogSceneManager -------------------

ChessDialogManager = class()

ChessDialogManager.s_dialogList = {};

ChessDialogManager.show = function(obj,type)   --type弹窗类型
    local num = ChessDialogManager.getListLength();

    if num > 0 and ChessDialogManager.s_dialogList then  -- 重复图片清理
        for i,v in pairs(ChessDialogManager.s_dialogList) do
            if v.obj == obj then
                return false;
            end
        end
    end

    if typeof(obj,HttpLoadingDialog) then return false end -- http 请求 不进入管理

    if type == ChessDialogScene.FORCE then   --强制
        if ChessDialogManager.s_dialogList and num > 0 then
            ChessDialogManager.s_dialogList[1].obj:setVisible(false);
        end
        local dialogData = {};
        dialogData.obj = obj;
        dialogData.type = ChessDialogScene.FORCE;
        table.insert(ChessDialogManager.s_dialogList,1,dialogData);
        return true;
    elseif type == ChessDialogScene.AUTO then  --自动
        if ChessDialogManager.s_dialogList and num > 0 then 
            obj:setVisible(false);
            ChessDialogManager.s_dialogList[num+1].obj = obj;
            ChessDialogManager.s_dialogList[num+1].type = ChessDialogScene.AUTO;
            return false;
        else
            obj:setVisible(true); 
            ChessDialogManager.s_dialogList[1] = {};
            ChessDialogManager.s_dialogList[1].obj = obj;
            ChessDialogManager.s_dialogList[1].type = ChessDialogScene.AUTO;
            return true;
        end
    else       
        --正常弹窗处理     
        if ChessDialogManager.s_dialogList and num > 0 then
            if ChessDialogManager.s_dialogList[1].type < ChessDialogScene.FORCE then
                ChessDialogManager.s_dialogList[1].obj:setVisible(false);
            else
                obj:setVisible(false);
                local dialogData = {};
                dialogData.obj = obj;
                dialogData.type = ChessDialogScene.NORMAL;
                table.insert(ChessDialogManager.s_dialogList,2,dialogData);
                return;
            end
        end
        local dialogData = {};
        dialogData.obj = obj;
        dialogData.type = ChessDialogScene.NORMAL;
        table.insert(ChessDialogManager.s_dialogList,1,dialogData);
        return true;
    end
end

ChessDialogManager.dismiss = function(obj)
    local num = ChessDialogManager.getListLength();
    if ChessDialogManager.s_dialogList and num > 1 then
        if ChessDialogManager.s_dialogList[1].obj == obj then
            table.remove(ChessDialogManager.s_dialogList,1);
            ChessDialogManager.s_dialogList[1].obj:setVisible(true);
        else
            for i = num, 2, -1 do 
                if ChessDialogManager.s_dialogList[i].obj == obj then
                    table.remove(ChessDialogManager.s_dialogList,i);
                end
            end
        end
    elseif num == 1 and ChessDialogManager.s_dialogList[1].obj ~= obj then
        return;
    else
        ChessDialogManager.s_dialogList = {};
    end
end

ChessDialogManager.getListLength = function()
    local num = 0;
    if ChessDialogManager.s_dialogList then
        for i,v in pairs(ChessDialogManager.s_dialogList) do 
            num = num + 1;
        end
    end
    return num;
end

ChessDialogManager.dismissDialog = function(flag)
    if not ChessDialogScene.s_dialogLayer then
        return false;
    end
    local childs = ChessDialogScene.s_dialogLayer:getChildren();
    local dismissChild;
    for _,child in pairs(childs) do
        if child and child.isShowing and child.dismiss then
            if child:isShowing() and child.m_dismissStatus == false then
                if dismissChild == nil or child:getLevel() >= dismissChild:getLevel() then
                    dismissChild = child;
                end
            end
        end
    end
    if (dismissChild and flag) or (dismissChild and dismissChild.m_needBackEvent) then
        if dismissChild.m_clickCallBack or flag then
            dismissChild:dismiss();
        end
        return true;
    end
    return false;
end

ChessDialogManager.dismissAllDialog = function()
    repeat
        local flag = ChessDialogManager.dismissDialog(true);    --true为ChessDialogManager强制执行的dismiss
    until not flag;
end

ChessDialogManager.existShowingDialog = function()     --判断是否存在show and dismissing的dialog
    local showingNum = 0;
    if not ChessDialogScene.s_dialogLayer then
        return false;
    end
    local childs = ChessDialogScene.s_dialogLayer:getChildren();
    local dismissChild;
    for _,child in pairs(childs) do
        if child and child.isShowing and child.dismiss and not typeof(child,HttpLoadingDialog) then
            if child:isShowing() and child.m_dismissStatus == false and child.m_rootFlag then
                return true;
            end
        end
    end
    return false;
end

------------------------ ChessToastScene ---------------------------
require(VIEW_PATH.."toast");

ChessToastScene = class(GameLayer,false);
ChessToastScene.s_ToastLayer = nil;

ChessToastScene.s_defaultShowTime = 1000;
ChessToastScene.s_defaultTransparencyTime = 500;
ChessToastScene.s_defaultW = 332;
ChessToastScene.s_MaxW = 600;
ChessToastScene.s_defaultH = 30;
ChessToastScene.s_addW = 28;

ChessToastScene.ctor = function(self,tip,time)
    super(self,toast);
    if not ChessToastScene.s_ToastLayer then
        ChessToastScene.s_ToastLayer = new(Node);
        ChessToastScene.s_ToastLayer:addToRoot();
        ChessToastScene.s_ToastLayer:setLevel(11);
        ChessToastScene.s_ToastLayer:setFillParent(true,true);
    end
    ChessToastScene.s_ToastLayer:addChild(self);
    self:setFillParent(true,true);

    
    self.m_tip = tip or "";
    self.m_time = time or ChessToastScene.s_defaultShowTime;

    self.m_toast_bg = self.m_root:getChildByName("toast_bg");
    self.m_tip_view = self.m_toast_bg:getChildByName("tip");


    self:resetView(self.m_tip);

    self:setVisible(false);
end

ChessToastScene.resetView = function(self,tip)

    self.m_tip_view.m_res.m_align = kAlignCenter; --底层没有开放这个接口 先用着
    self.m_tip_view.m_res.m_multiLines = kTextSingleLine; --重新定义 test 为 多行文本

    self.m_tip_view:setText(tip);
    local w,h = self.m_tip_view:getSize();

    if w > ChessToastScene.s_MaxW-ChessToastScene.s_addW then
        self.m_tip_view.m_res.m_align =  kAlignTopLeft;
        self.m_tip_view.m_res.m_multiLines = kTextMultiLines; --重新定义 test 为 多行文本
        self.m_tip_view:setText(tip,ChessToastScene.s_MaxW-ChessToastScene.s_addW,0);
        w,h = self.m_tip_view:getSize();
        self.m_toast_bg:setSize(ChessToastScene.s_MaxW,h+ChessToastScene.s_defaultH);
    elseif w > ChessToastScene.s_defaultW-ChessToastScene.s_addW then
        self.m_toast_bg:setSize(ChessToastScene.s_MaxW,h+ChessToastScene.s_defaultH);
    else
        self.m_toast_bg:setSize(ChessToastScene.s_defaultW,h+ChessToastScene.s_defaultH);
    end

end

ChessToastScene.findViewById = function(self,id)
    return self:getControl(id);
end

ChessToastScene.show = function(self)
    self:setVisible(true);
    require("common/animFactory");
    self.m_showAnim = AnimFactory.createAnimInt(kAnimNormal, 0, 1, self.m_time, -1);
    self.m_showAnim:setEvent(self,self.dismiss);
    self.m_showAnim:setDebugName("ChessToastScene:m_showAnim");
end

ChessToastScene.isShowing = function(self)
    return self:getVisible();
end

ChessToastScene.addChessToastManager = function(self,manager)
    self.m_managerHandler = manager;
end

ChessToastScene.dismiss = function(self)
    if self.m_showAnim then
        delete(self.m_showAnim);
        self.m_showAnim = nil;
    end
    self.m_transparencyAnim = AnimFactory.createAnimDouble(kAnimNormal,1.0,0.0,ChessToastScene.s_defaultTransparencyTime,-1);
    self.m_transparencyAnim:setEvent(self,self.destroy);
    self.m_transparencyAnim:setDebugName("ChessToastScene:m_transparencyAnim");
    local prop = AnimFactory.createTransparency(self.m_transparencyAnim);
    self:addProp(prop,1);
end

ChessToastScene.destroy = function(self)
    if self.m_showAnim then
        delete(self.m_showAnim);
        self.m_showAnim = nil;
    end
    if self.m_transparencyAnim then
        delete(self.m_transparencyAnim);
        self.m_transparencyAnim = nil;
    end
    if self.m_managerHandler then
        self.m_managerHandler:removeToast(self);
    end
    delete(self);
end

----------------------- ChessToastManager -------------------------

ChessToastManager = class();

ChessToastManager.ctor = function(self)
    self.m_toastQueue = {};
end

ChessToastManager.dtor = function(self)
    for _,v in pairs(self.m_toastQueue) do
        v:destroy();
    end
    self.m_toastQueue = nil;
end

ChessToastManager.getInstance = function(self)
    if not ChessToastManager.s_instance then
        ChessToastManager.s_instance = new(ChessToastManager);
    end
    return ChessToastManager.s_instance;
end

ChessToastManager.show = function(self,tip,time)
    local toast = new(ChessToastScene,tip,time);
    toast:addChessToastManager(self);
    self:addToast(toast);
end

ChessToastManager.showSingle = function(self,tip,time)
    if ChessToastManager.s_toast then 
        ChessToastManager.s_toast:destroy();
        ChessToastManager.s_toast = nil;
    end
    ChessToastManager.s_toast = new(ChessToastScene,tip,time);
    ChessToastManager.s_toast:show();
end

ChessToastManager.addToast = function(self,toast)
    table.insert(self.m_toastQueue,toast);
    if #self.m_toastQueue > 0 and not self.m_toastQueue[1]:isShowing() then
        self.m_toastQueue[1]:show();
    end
end

ChessToastManager.removeToast = function(self,toast)
    for i,v in pairs(self.m_toastQueue) do
        if toast == v then
            table.remove(self.m_toastQueue,i);
        end
    end
    if #self.m_toastQueue > 0 and not self.m_toastQueue[1]:isShowing() then
        self.m_toastQueue[1]:show();
    end
end

ChessToastManager.clearAllToast = function(self)
    for _,v in pairs(self.m_toastQueue) do
        v:destroy();
    end
    self.m_toastQueue = {};
    if ChessToastManager.s_toast then 
        ChessToastManager.s_toast:destroy();
        ChessToastManager.s_toast = nil;
    end
end

ChessToastManager.isEmpty = function(self)
    return #self.m_toastQueue == 0;
end