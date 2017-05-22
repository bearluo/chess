require("core/system")

--[[
kScreen480x320="480x320" -- ios/android
kScreen960x640="960x640"
kScreen1024x768="1024x768"
kScreen2048x1536="2048x1536"

--android
kScreen1280x720="1280x720"
kScreen1280x800="1280x800"
kScreen1024x600="1024x600"
kScreen960x540="960x540"
kScreen854x480="854x480"
kScreen800x480="800x480"
kScreen480x800="480x800"
--]]


-- if System.getResolution() == kScreen480x800 then
	VIEW_PATH = "view/Android_800_480/";

	local time_pre = os.clock();
	-- require("view/Android_800_480/hall_view")
	-- require("view/Android_800_480/console_view")
	-- require("view/Android_800_480/online_view")
	-- require("view/Android_800_480/userinfo_view")
	-- require("view/Android_800_480/help_view")
	-- require("view/Android_800_480/feedback_view");
	-- require("view/Android_800_480/setting_dialog_view");
	-- require("view/Android_800_480/account_dialog_view");
	-- require("view/Android_800_480/chioce_dialog_view");
	-- require("view/Android_800_480/time_set_dialog_view");
	-- require("view/Android_800_480/time_picker_dialog_view");
	-- require("view/Android_800_480/room_menu_dialog_view");
	-- require("view/Android_800_480/loading_dialog_view");
	-- require("view/Android_800_480/login_reward_dialog_view");
	-- require("view/Android_800_480/rank_view");
	-- require("view/Android_800_480/activity_view");
	-- require("view/Android_800_480/handicap_dialog_view");
	-- require("view/Android_800_480/mall_view");
	-- require("view/Android_800_480/pay_dialog_view");
	-- require("view/Android_800_480/forestall_dialog_view");
	-- require("view/Android_800_480/watch_view");
	-- require("view/Android_800_480/dapu_view");
	-- require("view/Android_800_480/dapu_room_view");
	-- require("view/Android_800_480/forestall_dialog_view");
	-- require("view/Android_800_480/create_room_dialog_view");
	-- require("view/Android_800_480/dapu_view");
	-- require("view/Android_800_480/dapu_room_view");
	-- require("view/Android_800_480/follow_person_view");
	-- require("view/Android_800_480/custom_dialog_view");
	-- require("view/Android_800_480/custom_input_pwd_dialog_view");
	-- require("view/Android_800_480/endgate_view");
	-- require("view/Android_800_480/endgate_sub_view");
	-- require("view/Android_800_480/ending_room_view");
	-- require("view/Android_800_480/invite_friends_view");
	-- require("view/Android_800_480/buy_undo_props_dialog");
	-- require("view/Android_800_480/tips_dialog_view");
	-- require("view/Android_800_480/submove_dialog_view");
	-- require("view/Android_800_480/ending_win_dialog_view");
	-- require("view/Android_800_480/ending_result_dialog_view");
	local time_after = os.clock();
	sys_set_int("win32_console_color",10);
    print_string("load xml time = " .. (time_after - time_pre));
	sys_set_int("win32_console_color",9);

-- end
