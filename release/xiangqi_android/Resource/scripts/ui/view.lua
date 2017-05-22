-- view.lua
-- Author: Vicent.Gong
-- Date: 2012-05-17
-- Last modification : 2012-10-08
-- Description: Defined the requisite interfaces for a view to be used for ListView or ViewPager

-- Note: 
--      More details in listView

View = class();

---------------------costruct function  -------------------------------------------------
--Parameters: 	data       -- the parameters to construct the view,actually u can pass
--                            any things u need here.
--Return 	:   no return
-----------------------------------------------------------------------------------------
View.ctor = function(self,data)
	
end

--------------------- function getWH ----------------------------------------------------
--Parameters:   no parameters
--Return 	:   return the width and height of the view
-----------------------------------------------------------------------------------------
View.getSize = function(self)
	error("You should Implemente the function getPos in your own View class for listView\n");
end

--------------------- function setXY ----------------------------------------------------
--Parameters:   x,y     -- the x,y of the view's pos
--Return 	:   no return 
-----------------------------------------------------------------------------------------
View.setPos = function(self,x,y)
    error("You should Implemente the function setXY in your own View class for listView\n");
end


--------------------- destructor function  ------------------------------------------------
--Parameters:   isVisible		-- to set the view to be visisble or not
--Return 	:   no return 
-------------------------------------------------------------------------------------------
View.setVisible = function(self,isVisible)
	error("You should Implemente the function setVisible in your own View class for listView\n");
end

--------------------- destructor function  ------------------------------------------------
--Parameters:   no parameters
--Return 	:   no return 
-------------------------------------------------------------------------------------------
View.dtor = function(self)
	
end

	