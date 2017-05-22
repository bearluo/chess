--region activityAnim.lua
--Date 2016.12.30
--活动动画
--endregion

ActivityAnim = {}

function ActivityAnim.ctor(self)
    ActivityAnim.propIndex = 0
    ActivityAnim.propIdTab = {}
    ActivityAnim.propAnim = {}
end

function ActivityAnim.dtor(self)
    ActivityAnim.propIndex = 1
end

function ActivityAnim.getInstance()
    if not ActivityAnim.s_instance then
		ActivityAnim.s_instance = new(ActivityAnim)
	end
	return ActivityAnim.s_instance
end

function ActivityAnim.openBtnAnim(model)
	if next(ActivityAnim.propAnim) == nil then
        ActivityAnim.propIndex = 0;
        ActivityAnim.startBtnAnim(model);
	end
end

function ActivityAnim.startBtnAnim(view)
    if ActivityAnim.propIndex == 2 then
        ActivityAnim.propIndex = 0
    end
    ActivityAnim.propIndex = ActivityAnim.propIndex + 1;
    if ActivityAnim.propTab[ActivityAnim.propIndex] then
        local propAnimTab = ActivityAnim.propTab[ActivityAnim.propIndex]
        local n = #propAnimTab
        for i = 1,n do
            if not view:checkAddProp(i) then
                view:removeProp(i)
            end
        end
        ActivityAnim.animView = view
        for i = 1,n do 
            ActivityAnim.propIdTab[i] = i 
            ActivityAnim.propAnim[i] = propAnimTab[i].func(view,unpack(propAnimTab[i].params));
        end
        ActivityAnim.propAnim[1]:setEvent(view,ActivityAnim.startBtnAnim)
    end
end

ActivityAnim.s_scalePropAnim1 = {
    func = DrawingBase.addPropRotate,
    params = {
        2, kAnimNormal, 600, -1, 0, -5, kCenterDrawing
    }
}

ActivityAnim.s_scalePropAnim2 = {
    func = DrawingBase.addPropRotate,
    params = {
        2, kAnimNormal, 150, -1, -3, 0, kCenterDrawing
    }
}

ActivityAnim.s_translatePropAnim1 = {
    func = DrawingBase.addPropTranslate,
    params = {
        1, kAnimNormal, 600, -1, 0,-1,0,-9
    }
}

ActivityAnim.s_translatePropAnim2 = {
    func = DrawingBase.addPropTranslate,
    params = {
        1, kAnimNormal, 400, -1, -1,0,-9,0
    }
}

ActivityAnim.propTab = {
    [1] = {
        ActivityAnim.s_translatePropAnim1,
        ActivityAnim.s_scalePropAnim1,
    },
    [2] = {
        ActivityAnim.s_translatePropAnim2,
        ActivityAnim.s_scalePropAnim2,
    },
}

function ActivityAnim.deleteBtnAnim()
    local n = #ActivityAnim.propAnim
    for i = 1,n do
        if ActivityAnim.propAnim[i] then
		    delete(ActivityAnim.propAnim[i]);
		    ActivityAnim.propAnim[i] = nil;
	    end
    end
    if ActivityAnim.animView then
        for i = 1 ,n do 
            if not ActivityAnim.animView:checkAddProp(i) then
                ActivityAnim.animView:removeProp(i);
            end
        end
        ActivityAnim.animView = nil;
    end
    ActivityAnim.propIndex = 0
    ActivityAnim.propIdTab = {}
    ActivityAnim.propAnim = {}
end
