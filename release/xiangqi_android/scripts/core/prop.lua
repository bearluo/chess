-- prop.lua
-- Author: Vicent Gong
-- Date: 2012-09-21
-- Last modification : 2013-5-29
-- Description: provide basic wrapper for attributes which will be attached to a drawing

require("core/object");
require("core/constants");

---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] PropBase------------------------------------------
---------------------------------------------------------------------------------------------

PropBase = class();

property(PropBase,"m_propID","ID",true,false);

PropBase.ctor = function(self)
    self.m_propID = prop_alloc_id();
end

PropBase.dtor = function(self)
    prop_free_id(self.m_propID);
end

PropBase.setDebugName = function(self, name)
	prop_set_debug_name(self.m_propID,name or "");
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] PropTranslate-------------------------------------
---------------------------------------------------------------------------------------------

PropTranslate = class(PropBase);

PropTranslate.ctor = function(self, animX, animY)
    prop_create_translate(0, self.m_propID, 
							animX and animX:getID() or -1,
							animY and animY:getID() or -1
							);
end

PropTranslate.dtor = function(self)
	prop_delete(self.m_propID);
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] PropRotate----------------------------------------
---------------------------------------------------------------------------------------------

PropRotate = class(PropBase);

PropRotate.ctor = function(self, anim, center, x, y)
    prop_create_rotate(0, self.m_propID, anim:getID(), 
						center or kNotCenter, x or 0, y or 0);
end

PropRotate.dtor = function(self)
	prop_delete(self.m_propID);
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] PropScale-----------------------------------------
---------------------------------------------------------------------------------------------

PropScale = class(PropBase);

PropScale.ctor = function(self, animX, animY, center, x, y)
    prop_create_scale(0, self.m_propID, 
						animX and animX:getID() or -1, 
						animY and animY:getID() or -1,
						center or kNotCenter, x or 0, y or 0);
end

PropScale.dtor = function(self)
	prop_delete(self.m_propID);
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] PropTranslateSolid--------------------------------
---------------------------------------------------------------------------------------------

PropTranslateSolid = class(PropBase);

PropTranslateSolid.ctor = function(self, x, y)
    prop_create_translate_solid(0, self.m_propID, x, y);
end

PropTranslateSolid.set = function(self, x, y)
	prop_set_translate_solid(0, self.m_propID, x, y);
end

PropTranslateSolid.dtor = function(self)
	prop_delete(self.m_propID);
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] PropRotateSolid-----------------------------------
---------------------------------------------------------------------------------------------

PropRotateSolid = class(PropBase)

PropRotateSolid.ctor = function(self, angle360, center, x, y)
    prop_create_rotate_solid(0, self.m_propID, angle360,
								center or KNotCenter,x or 0,y or 0);
end

PropRotateSolid.set = function(self, angle360)
	prop_set_rotate_solid(0, self.m_propID, angle360);
end

PropRotateSolid.dtor = function(self)
	prop_delete(self.m_propID);
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] PropScaleSolid------------------------------------
---------------------------------------------------------------------------------------------

PropScaleSolid = class(PropBase)

PropScaleSolid.ctor = function(self, scaleX, scaleY, center, x, y)
    prop_create_scale_solid(0, self.m_propID, scaleX, scaleY,
									center or kNotCenter,x or 0,y or 0);
end

PropScaleSolid.set = function(self, scaleX, scaleY)
    prop_set_scale_solid(0, self.m_propID, scaleX, scaleY);
end

PropScaleSolid.dtor = function(self)
	prop_delete(self.m_propID);
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] PropColor-----------------------------------------
---------------------------------------------------------------------------------------------

PropColor = class(PropBase);

PropColor.ctor = function(self, animR, animG, animB)
    prop_create_color(0, self.m_propID, 
				animR and animR:getID() or -1, 
				animG and animG:getID() or -1, 
				animB and animB:getID() or -1);
end

PropColor.dtor = function(self)
	prop_delete(self.m_propID);
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] PropTransparency----------------------------------
---------------------------------------------------------------------------------------------

PropTransparency = class(PropBase);

PropTransparency.ctor = function(self, anim)
    prop_create_transparency(0, self.m_propID, anim:getID());
end

PropTransparency.dtor = function(self)
	prop_delete(self.m_propID);
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] PropClip------------------------------------------
---------------------------------------------------------------------------------------------

PropClip = class(PropBase)

PropClip.ctor = function(self, animX, animY, animW, animH)
    prop_create_clip(0, self.m_propID, 
						animX and animX:getID() or -1,
						animY and animY:getID() or -1,
						animW and animW:getID() or -1,
						animH and animH:getID() or -1);
end

PropClip.dtor = function(self)
	prop_delete(self.m_propID);
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] PropImageIndex------------------------------------
---------------------------------------------------------------------------------------------

PropImageIndex = class(PropBase)

PropImageIndex.ctor = function(self, anim)
    prop_create_image_index(0, self.m_propID, anim:getID());
end

PropImageIndex.dtor = function(self)
	prop_delete(self.m_propID);
end
