--region http_loading_dialog.lua
--Author : BearLuo
--Date   : 2015/4/14
require(VIEW_PATH.."http_loading_dialog");
require(BASE_PATH.."chessDialogScene");

HttpLoadingDialogFactory = class();

HttpLoadingDialogFactory.createLoadingDialog = function(Type,tip,canCancel)
    local dialog = new(HttpLoadingDialog);
    dialog:setType(Type,tip,canCancel);
    return dialog;
end

HttpLoadingDialog = class(ChessDialogScene,false);

HttpLoadingDialog.s_duration = 1000;
HttpLoadingDialog.s_tip_w = 163;
HttpLoadingDialog.s_loading_bg_w = 200;


HttpLoadingDialog.s_type = {
    Normel = 1;
    Simple = 2;
};

HttpLoadingDialog.ctor = function(self)
    super(self,http_loading_dialog);
    self.m_loading_view = self:findViewById(HttpLoadingDialog.s_controls.loading_view);
    self.m_tip = self:findViewById(HttpLoadingDialog.s_controls.tip);
    self.m_loading_bg = self:findViewById(HttpLoadingDialog.s_controls.loading_bg);
    self.m_cancel = self:findViewById(HttpLoadingDialog.s_controls.cancel);
    self:setLevel(ChessDialogScene.kHttpLoadingDialog);
    self:reset();
end

HttpLoadingDialog.dtor = function(self)
    self:dismiss();
end

HttpLoadingDialog.getInstance = function()
    if not HttpLoadingDialog.s_instance then
        HttpLoadingDialog.s_instance = new(HttpLoadingDialog);
    end
    return HttpLoadingDialog.s_instance;
end

HttpLoadingDialog.reset = function(self)
    self.m_loading_view:setAlign(kAlignCenter);
    self.m_tip:setVisible(false);
    self.m_loading_bg:setSize(HttpLoadingDialog.s_loading_bg_w);
    self.m_cancel:setVisible(true);
end

HttpLoadingDialog.setType = function(self,Type,tip,canCancel)
    self:reset();
    if canCancel == nil then
        canCancel = false;
    end

    if ( not tip or tip == "" ) and Type == HttpLoadingDialog.s_type.Normel then
        Type = HttpLoadingDialog.s_type.Simple;
    end

    if Type == HttpLoadingDialog.s_type.Normel then
        self.m_loading_view:setAlign(kAlignBottom);
        self.m_tip:setVisible(true);
        self.m_tip:setText(tip,HttpLoadingDialog.s_tip_w);
        local w,h = self.m_tip:getSize();
        self.m_loading_bg:setSize(HttpLoadingDialog.s_loading_bg_w-HttpLoadingDialog.s_tip_w+w);
    elseif Type == HttpLoadingDialog.s_type.Simple then
        self.m_loading_view:setAlign(kAlignCenter);
        self.m_tip:setVisible(false);
    end

    self.m_cancel:setVisible(canCancel);
end

HttpLoadingDialog.show = function(self,rootFlag,maskFlag)
    if self:isShowing() then return ;end 
    self:setVisible(true);
    self.super.show(self,false,maskFlag);
    if self.m_loading_view then
        self.m_loading_view:addPropRotate(1,kAnimRepeat,HttpLoadingDialog.s_duration,-1,0,-360,1);
    end
end

HttpLoadingDialog.dismiss = function(self)
    if not self:isShowing() then return ;end 
    self.super.dismiss(self,false);
    self:setVisible(false);
    if self.m_loading_view then
        self.m_loading_view:removePropByID(1);
    end
end

HttpLoadingDialog.isShowing = function(self)
    return self:getVisible();
end

HttpLoadingDialog.onCancelClick = function(self)
    Log.i("HttpLoadingDialog.onCancelClick");
    self:dismiss();
end

HttpLoadingDialog.s_controls = 
{
    loading_bg = 1;
    loading_view = 2;
    tip = 3;
    cancel = 4;
};

HttpLoadingDialog.s_controlConfig = 
{
	[HttpLoadingDialog.s_controls.loading_bg] = {"loading_bg"};
	[HttpLoadingDialog.s_controls.loading_view] = {"loading_bg","loading_view"};
	[HttpLoadingDialog.s_controls.tip] = {"loading_bg","tip"};
	[HttpLoadingDialog.s_controls.cancel] = {"loading_bg","cancel"};
};

HttpLoadingDialog.s_controlFuncMap = 
{
	[HttpLoadingDialog.s_controls.cancel] = HttpLoadingDialog.onCancelClick;
};