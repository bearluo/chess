--region chessDialogScene.lua
--Author : BearLuo
--Date   : 2015/4/14
require("gameBase/gameLayer");

ChessDialogScene = class(GameLayer);

ChessDialogScene.s_dialogLayer = nil;
ChessDialogScene.s_mask_bg = "drawable/blank_black.png"

ChessDialogScene.kHttpLoadingDialog = 1;
ChessDialogScene.kHttpForceLevel    = 1000;
ChessDialogScene.kBaseDialogLevel        = 100;
ChessDialogScene.ctor = function(self,viewConfig)
    if not ChessDialogScene.s_dialogLayer then
        ChessDialogScene.s_dialogLayer = new(Node);
        ChessDialogScene.s_dialogLayer:addToRoot();
        ChessDialogScene.s_dialogLayer:setLevel(10);
        ChessDialogScene.s_mask = new(Image,ChessDialogScene.s_mask_bg)
        ChessDialogScene.s_mask:setFillParent(true,true);
        ChessDialogScene.s_mask:setVisible(false);
        ChessDialogScene.s_dialogLayer:addChild(ChessDialogScene.s_mask);
        ChessDialogScene.s_dialogLayer:setFillParent(true,true);
    end
    ChessDialogScene.s_dialogLayer:addChild(self);
    GameLayer.setLevel(self,ChessDialogScene.kBaseDialogLevel)
    self.m_root:setLevel(10);
    self:setFillParent(true,true);
    self:setEventDrag(self,self.s_shieldDragClick);
    self:setEventTouch(self,self.s_shieldTouchClick);
    self:setVisible(false);
    self.mDialogVisible = false
    self.mNeedMask = true
    self.mNeedEffect = true
end

ChessDialogScene.dtor = function(self)
	ChessDialogScene.dismiss(self);
end

ChessDialogScene.setLevel = function(self,level)
    GameLayer.setLevel(self,ChessDialogScene.kBaseDialogLevel + level)
end

ChessDialogScene.show = function(self,animFunc)
    self.mDialogVisible = true
    if self.mNeedEffect then
	    kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
    end
    if type(animFunc) == "function" then
        animFunc()
    else
        self:setVisible(true)
    end
    self:addDialogManager()
end

ChessDialogScene.dismiss = function(self,animFunc)
    self.mDialogVisible = false
    if type(animFunc) == "function" then
        animFunc()
    else
        self:setVisible(false)
    end
    self:removeDialogManager()
end

ChessDialogScene.callbackEvent = function(self)
    self:dismiss()
    return true
end

ChessDialogScene.s_controls = {};

ChessDialogScene.s_controlConfig = {};

ChessDialogScene.s_shieldDragClick = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
end

ChessDialogScene.s_shieldTouchClick = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
    Log.i("ChessDialogScene.s_shieldTouchClick");
    if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
        if self.m_shield_func then
            self.m_shield_func(self.m_shield_obj);
        end
    end
end
--[Comment]
-- 设置背景点击事件
ChessDialogScene.setShieldClick = function(self,obj,func)
    self.m_shield_obj = obj;
    self.m_shield_func = func;
end

ChessDialogScene.findViewById = function(self,id)
    return self:getControl(id);
end

--[Comment]
-- 设置dialog 回退键事件
ChessDialogScene.setNeedBackEvent = function(self,flag)
    if type(flag) == "function" then
        self.callbackEvent = flag
        return
    end
    if flag then
        self.callbackEvent = ChessDialogScene.callbackEvent
    else
        self.callbackEvent = function() return true end -- 吸收back 事件
    end
end
--[Comment]
-- 是否需要dialog遮罩
ChessDialogScene.setNeedMask = function(self,flag)
    if type(flag) ~= "boolean" then 
        self.mNeedMask = true
    else
        self.mNeedMask = flag
    end
end

ChessDialogScene.isNeedMask = function(self)
    return self.mNeedMask
end

ChessDialogScene.isShowing = function(self)
	return self.mDialogVisible
end
--[Comment]
-- 设置是否遮挡其他dialog
ChessDialogScene.setMaskDialog = function(self,flag)
    self.mDialogTypeIsMask = flag
end

ChessDialogScene.isMaskDialog = function(self)
    return self.mDialogTypeIsMask
end

ChessDialogScene.setBgOnTouchClick = function(self,func)
    self:setEventDrag(self,func);
    self:setEventTouch(self,func);
end

function ChessDialogScene:addDialogManager()
    self:removeDialogManager()
    self._pri_manager_index = ChessDialogManager.addDialog(self)
end

function ChessDialogScene:removeDialogManager()
    if self._pri_manager_index then ChessDialogManager.removeDialog(self._pri_manager_index) end
    self._pri_manager_index = nil
end

------------------------ ChessDialogSceneManager -------------------
local function DialogManagerInstantiation()

local M = {}
local dialogQueue = {}
M.s_dialogQueue = dialogQueue
local clearIndex = 0
local curShowDialog = nil
function M.addDialog(dialog)
    dialog:setVisible(false)
    dialogQueue[#dialogQueue+1] = dialog
    clearIndex = clearIndex + 1
    M.autoShowDialog()
    return #dialogQueue
end

function M.removeDialog(index)
    local dismissDialog = dialogQueue[index]
    dialogQueue[index] = false
    clearIndex = clearIndex - 1
    if clearIndex == 0 then -- 计数器为0 的时候清理队列 提高效率
        dialogQueue = {}
    end
    if dismissDialog == curShowDialog then
        curShowDialog = nil
        M.autoShowDialog()
    end
end

function M.dismissDialog()
    if curShowDialog and type(curShowDialog.dismiss) == "function" then
        curShowDialog:dismiss()
    end
end

function M.callbackEvent()
    if curShowDialog and type(curShowDialog.callbackEvent) == "function" then
        return curShowDialog:callbackEvent()
    end
    return false
end

function M.autoShowDialog()
    local showDialog = nil
    for _,dialog in pairs(dialogQueue) do
        if type(dialog) == "table" and type(dialog.getLevel) == "function" then
            if showDialog == nil or dialog:getLevel() >= showDialog:getLevel() then
                showDialog = dialog;
            end
        end
    end

    if curShowDialog and curShowDialog == showDialog then return end
    if curShowDialog then 
        if showDialog and not showDialog:isMaskDialog() then
            curShowDialog:setVisible(false)
        end
    end

    curShowDialog = showDialog
    
    local maskDialog = nil
    for _,dialog in pairs(dialogQueue) do
        if type(dialog) == "table" and type(dialog.getLevel) == "function" then
            if showDialog ~= dialog and dialog:getVisible() and dialog:isNeedMask() and (maskDialog == nil or dialog:getLevel() >= maskDialog:getLevel()) then
                maskDialog = dialog;
            end
        end
    end

    if curShowDialog then
        curShowDialog:setVisible(true)
        ChessDialogScene.s_mask:setVisible(true)
        if curShowDialog:isNeedMask() then
            curShowDialog:addChild(ChessDialogScene.s_mask)
        else
            if not maskDialog then
                ChessDialogScene.s_mask:setVisible(false)
                ChessDialogScene.s_dialogLayer:addChild(ChessDialogScene.s_mask)
            else
                maskDialog:addChild(ChessDialogScene.s_mask)
            end
        end
    else
        ChessDialogScene.s_mask:setVisible(false)
        ChessDialogScene.s_dialogLayer:addChild(ChessDialogScene.s_mask)
    end
end


function M.dismissAllDialog()
    for _,dialog in pairs(dialogQueue) do
        if type(dialog) == "table" and type(dialog.dismiss) == "function" then
            dialog:dismiss()
        end
    end
end

return M

end

ChessDialogManager = DialogManagerInstantiation()

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

require("common/animFactory");
ChessToastScene.show = function(self)
    self:setVisible(true);
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