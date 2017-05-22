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
    self.m_loading_bg = self:findViewById(HttpLoadingDialog.s_controls.loading_bg);
    self.m_loading_txt = self:findViewById(HttpLoadingDialog.s_controls.loading_txt);
    self:setLevel(ChessDialogScene.kHttpLoadingDialog);
    self:reset();
    self:setNeedBackEvent(false)
    self:setNeedMask(true)
    self:setMaskDialog(true)
    self.mNeedEffect = false
    
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
end

HttpLoadingDialog.setType = function(self,Type,tip,canCancel)
    self:reset();
    
    self.m_loading_view:setAlign(kAlignCenter);

--    self.m_cancel:setVisible(canCancel);
end

HttpLoadingDialog.show = function(self)
    if self:isShowing() then return ;end 
    self.super.show(self);
    if self.m_loading_view then
        self.m_loading_view:removeProp(1);
        self.m_loading_view:setFile("common/icon/king_1.png");
        local anim = self.m_loading_view:addPropScale(1, kAnimLoop, 500, -1, 1, 0, 1, 1, kCenterDrawing)
        local index = 1;
        anim:setEvent(nil,function()
                index = index % 2 + 1;
                if index ~= 2 then return end 
                local file = self.m_loading_view:getFile()
                if file == "common/icon/king_1.png" then
                    file = "common/icon/king_2.png"
                else
                    file = "common/icon/king_1.png"
                end
                self.m_loading_view:setFile(file)
            end);
    end
    if self.m_loading_txt then
        delete(self.mLoadingAnim);
        self.mLoadingAnim = AnimFactory.createAnimInt(kAnimLoop, 0, 1, 200, -1);
        self.m_loading_txt:setFile("animation/loading/loading_4.png");
        local index = 4;
        self.mLoadingAnim:setEvent(nil,function()
                        index = index % 4 + 1
                         self.m_loading_txt:setFile( string.format("animation/loading/loading_%d.png",index));
                    end)
    end
end

HttpLoadingDialog.dismiss = function(self)
    if not self:isShowing() then return ;end 
    self.super.dismiss(self);
    if self.m_loading_view then
        self.m_loading_view:removeProp(1);
    end
    if self.m_loading_txt then
        delete(self.mLoadingAnim);
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
    loading_bg      = 1;
    loading_view    = 2;
    loading_txt     = 3;
};

HttpLoadingDialog.s_controlConfig = 
{
	[HttpLoadingDialog.s_controls.loading_bg]       = {"loading_bg"};
	[HttpLoadingDialog.s_controls.loading_view]     = {"loading_bg","loading_view"};
	[HttpLoadingDialog.s_controls.loading_txt]      = {"loading_bg","loading_txt"};
};

HttpLoadingDialog.s_controlFuncMap = 
{
};