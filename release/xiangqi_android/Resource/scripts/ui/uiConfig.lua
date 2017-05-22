-- uiConfig.lua
-- Author: Vicent Gong
-- Date: 2013-06-27
-- Last modification : 2013-06-27
-- Description: Global configs for ui 

require("core/object");

require("ui/checkBox");
require("ui/radioButton");
require("ui/editText");
require("ui/editTextView");
require("ui/tableView");
require("ui/viewPager");
require("ui/listView");
require("ui/scrollView");
require("ui/scrollBar");
require("ui/scroller");
require("ui/slider");
require("ui/switch");
require("ui/mask");
require("ui/scrollPicker");
require("ui/gallery");
require("ui/commentStar");
require("ui/customNode")
require("ui/switchSelectNode")
UIConfig = class();

UIConfig.setCheckBoxImages = function(unCheckedFile, checkedFile)
	CheckBox.setDefaultImages({unCheckedFile,checkedFile});
end


UIConfig.setRadioButtonImages = function(unCheckedFile, checkedFile)
	RadioButton.setDefaultImages({unCheckedFile,checkedFile});
end


UIConfig.setEditTextHintText = function(hintText, r, g, b)
	EditText.setDefaultHintText(hintText,r,g,b);
end

UIConfig.setEditTextMaxClickOffset = function(maxClickOffset)
	EditText.setDefaultMaxClickOffset(maxClickOffset);
end


UIConfig.setEditTextViewHintText = function(hintText, r, g, b)
	EditTextView.setDefaultHintText(hintText,r,g,b);
end

UIConfig.setEditTextViewMaxClickOffset = function(maxClickOffset)
	EditTextView.setDefaultMaxClickOffset(maxClickOffset);
end


UIConfig.setTableViewScorllBarWidth = function(width)
	TableView.setDefaultScrollBarWidth(width);
end

UIConfig.setTableViewMaxClickOffset = function(maxClickOffset)
	TableView.setDefaultMaxClickOffset(maxClickOffset);
end


UIConfig.setListViewScrollBarWidth = function(width)
	ListView.setDefaultScrollBarWidth(width);
end

UIConfig.setListViewMaxClickOffset = function(maxClickOffset)
	ListView.setDefaultMaxClickOffset(maxClickOffset);
end


UIConfig.setViewPagerScrollBarWidth = function(width)
	ViewPager.setDefaultScrollBarWidth(width);
end

UIConfig.setViewPagerMaxClickOffset = function(maxClickOffset)
	ViewPager.setDefaultMaxClickOffset(maxClickOffset);
end


UIConfig.setScrollViewScrollBarWidth = function(width)
	ScrollView.setDefaultScrollBarWidth(width);
end


UIConfig.setScrollBarImage = function(filePath)
	ScrollBar.setDefaultImage(filePath);
end

UIConfig.setScrollBarInvisibleTime = function(time)
	ScrollBar.setDefaultInvisibleTime(time);
end

UIConfig.setScrollBarSmallestLength = function(smallestLength)
	ScrollBar.setDefaultSmallestLength(smallestLength);
end


UIConfig.setScrollerFlippingFrames = function(flippingFrames)
	Scroller.setDefaultFlippingFrame(flippingFrames);
end

UIConfig.setScrollerFlippingSpeedFactor = function(flippingSpeedFactor)
	Scroller.setDefaultFlippingSpeedFactor(flippingSpeedFactor);
end

UIConfig.setScrollerFlippingOverFactor = function(flippingOverFactor)
	Scroller.setDefaultFlippingOverFactor(flippingOverFactor);
end

UIConfig.setScrollerReboundFrames = function(reboundFrames)
	Scroller.setDefaultReboundFrames(reboundFrames);
end

UIConfig.setScrollerUnitTurningFactor = function(unitTurningFactor)
	Scroller.setDefaultUnitTurningFactor(unitTurningFactor);
end


UIConfig.setSliderImages = function(bgImage, fgImage, buttonImage)
	Slider.setDefaultImages(bgImage,fgImage,buttonImage);
end

UIConfig.setSwitchImages = function(onFile, offFile, buttonFile)
	Switch.setDefaultImages(onFile,offFile,buttonFile);
end
