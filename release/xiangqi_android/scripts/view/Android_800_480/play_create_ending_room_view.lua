play_create_ending_room_view=
{
	name="play_create_ending_room_view",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="ending_room_bg",type=1,typeName="Image",time=1351133460,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="common/background/room_bg.png"
	},
	{
		name="ending_share_btn",type=2,typeName="Button",time=108534574,x=290,y=24,width=86,height=91,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/button/share_btn_2.png"
	},
	{
		name="ending_title_view",type=0,typeName="View",time=16275838,x=0,y=0,width=720,height=175,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
		{
			name="ending_title_bg",type=1,typeName="Image",time=20339246,x=0,y=61,width=370,height=106,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/background/title_bg_3.png",
			{
				name="ending_title",type=4,typeName="Text",time=16275866,x=0,y=0,width=294,height=86,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=52,textAlign=kAlignCenter,colorRed=234,colorGreen=170,colorBlue=116,string=[[]]
			}
		},
		{
			name="ending_room_leave_btn",type=2,typeName="Button",time=96626764,x=20,y=20,width=86,height=91,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="common/button/back_btn.png"
		},
		{
			name="ending_room_note_bg",type=1,typeName="Image",time=20338779,x=0,y=0,width=720,height=151,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/decoration/tu_song_bg.png",
			{
				name="ending_room_note_text",type=5,typeName="TextView",time=20339044,x=0,y=0,width=566,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=32,textAlign=kAlignTop,colorRed=80,colorGreen=80,colorBlue=80,string=[[此着，以退为进，辗转于侧翼，是最有力的攻法。此着，以退为进，辗转于侧翼，是最有力的攻法。]]
			}
		}
	},
	{
		name="ending_board",type=0,typeName="View",time=1350614405,x=0,y=175,width=720,height=800,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
		{
			name="ending_board_bg",type=1,typeName="Image",time=1350614428,x=0,y=0,width=720,height=868,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="chess_board.png",packFile="config/boardres.lua"
		}
	},
	{
		name="ending_room_menu",type=0,typeName="View",time=1351735563,x=219,y=63,width=267,height=130,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,
		{
			name="ending_tips_btn",type=2,typeName="Button",time=20340538,x=0,y=0,width=88,height=130,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="common/button/tip_normal.png",file2="common/button/tip_press.png",
			{
				name="ending_tips_num_bg",type=1,typeName="Image",time=20345624,x=-13,y=-8,width=35,height=38,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="common/prop_num_bg.png",
				{
					name="ending_tips_num_text",type=4,typeName="Text",time=20345766,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignCenter,colorRed=235,colorGreen=180,colorBlue=140,string=[[0]]
				}
			},
			{
				name="tip_bg",type=1,typeName="Image",time=96629186,x=-340,y=-49,width=410,height=68,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="common/background/tip_bg_1.png",gridLeft=133,gridRight=133,gridTop=0,gridBottom=0,
				{
					name="Text1",type=4,typeName="Text",time=96629187,x=0,y=-8,width=224,height=28,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=28,textAlign=kAlignLeft,colorRed=85,colorGreen=50,colorBlue=30,string=[[帮你走出当前局面最佳的一步]]
				}
			}
		},
		{
			name="ending_undo_btn",type=2,typeName="Button",time=20340270,x=0,y=0,width=88,height=130,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/button/undo_normal.png",file2="common/button/undo_press.png",
			{
				name="ending_undo_num_bg",type=1,typeName="Image",time=20345361,x=-13,y=-8,width=35,height=38,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="common/prop_num_bg.png",
				{
					name="ending_undo_num_text",type=4,typeName="Text",time=20345509,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignCenter,colorRed=235,colorGreen=180,colorBlue=140,string=[[0]]
				}
			},
			{
				name="tip_bg",type=1,typeName="Image",time=96628327,x=-199,y=-49,width=266,height=68,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="common/background/tip_bg_1.png",
				{
					name="Text1",type=4,typeName="Text",time=96629128,x=0,y=-8,width=224,height=28,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=28,textAlign=kAlignLeft,colorRed=85,colorGreen=50,colorBlue=30,string=[[帮你恢复到前一步]]
				}
			}
		},
		{
			name="ending_submove_img",type=1,typeName="Image",time=20340768,x=-15,y=-96,width=128,height=94,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="common/background/tips_bg_1.png",
			{
				name="ending_submove_img_text",type=4,typeName="Text",time=20341213,x=0,y=-9,width=96,height=33,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=32,textAlign=kAlignCenter,colorRed=135,colorGreen=100,colorBlue=95,string=[[有变招]]
			},
			{
				name="ending_tips_img_text",type=4,typeName="Text",time=20698205,x=0,y=-9,width=72,height=24,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=32,textAlign=kAlignCenter,colorRed=135,colorGreen=100,colorBlue=95,string=[[有注释]]
			}
		},
		{
			name="ending_submove_view_bg",type=1,typeName="Image",time=20341589,x=-15,y=-96,width=380,height=94,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="common/background/tips_bg_1.png",gridLeft=64,gridRight=64,gridTop=0,gridBottom=0,
			{
				name="ending_submove1_btn",type=2,typeName="Button",time=20341703,x=23,y=11,width=100,height=52,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="common/background/line_bg.png",
				{
					name="ending_submove1_btn_text",type=4,typeName="Text",time=20343017,x=0,y=0,width=110,height=52,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=30,textAlign=kAlignCenter,colorRed=0,colorGreen=0,colorBlue=0,string=[[变招1]]
				}
			},
			{
				name="ending_submove2_btn",type=2,typeName="Button",time=20342540,x=131,y=11,width=110,height=52,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="common/background/line_bg.png",
				{
					name="ending_submove2_btn_text",type=4,typeName="Text",time=20343090,x=0,y=0,width=110,height=52,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=30,textAlign=kAlignCenter,colorRed=0,colorGreen=0,colorBlue=0,string=[[变招2]]
				}
			},
			{
				name="ending_submove3_btn",type=2,typeName="Button",time=20342929,x=250,y=11,width=110,height=52,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="common/background/line_bg.png",
				{
					name="ending_submove3_btn_text",type=4,typeName="Text",time=20343133,x=0,y=0,width=110,height=52,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=30,textAlign=kAlignCenter,colorRed=0,colorGreen=0,colorBlue=0,string=[[变招3]]
				}
			}
		},
		{
			name="change_flag_btn",type=2,typeName="Button",time=112262179,x=0,y=0,width=142,height=122,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="common/button/change_flag_nor.png",file2="common/button/change_flag_pre.png"
		}
	},
	{
		name="ending_room_restart_btn",type=2,typeName="Button",time=20343286,x=-265,y=63,width=84,height=126,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="common/button/restart_normal.png",file2="common/button/restart_press.png"
	},
	{
		name="ending_room_set_btn",type=2,typeName="Button",time=20343359,x=-143,y=63,width=84,height=126,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="common/button/set_normal.png",file2="common/button/set_press.png"
	},
	{
		name="ending_room_info",type=0,typeName="View",time=96630594,x=0,y=70,width=134,height=110,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,
		{
			name="info_bg",type=1,typeName="Image",time=100928812,x=0,y=0,width=162,height=110,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,file="common/background/info_bg_10.png"
		},
		{
			name="min_step_text",type=4,typeName="Text",time=100929593,x=0,y=59,width=134,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=30,textAlign=kAlignCenter,colorRed=240,colorGreen=230,colorBlue=210,string=[[]]
		},
		{
			name="step_text",type=4,typeName="Text",time=100929623,x=0,y=0,width=244,height=0,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottomLeft,fontSize=30,textAlign=kAlignLeft,colorRed=255,colorGreen=170,colorBlue=120,string=[[]]
		},
		{
			name="Text2",type=4,typeName="Text",time=108540670,x=0,y=21,width=120,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=30,textAlign=kAlignCenter,colorRed=240,colorGreen=230,colorBlue=210,string=[[最快破解]]
		}
	},
	{
		name="menu_bg",type=1,typeName="Image",time=106106005,x=0,y=-17,width=720,height=274,visible=0,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignBottom,file="online/room/menu/menu_bg.png",
		{
			name="start_btn",type=2,typeName="Button",time=100939625,x=0,y=0,width=436,height=144,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/button/start_nor.png",file2="common/button/start_press.png",
			{
				name="title",type=4,typeName="Text",time=100942489,x=0,y=-12,width=200,height=150,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=48,textAlign=kAlignCenter,colorRed=255,colorGreen=215,colorBlue=155,string=[[金币挑战]]
			}
		},
		{
			name="report_btn",type=2,typeName="Button",time=106106156,x=34,y=0,width=56,height=172,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="common/button/report_nor.png",file2="common/button/report_pre.png"
		}
	}
}