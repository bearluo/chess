hall_view=
{
	name="hall_view",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="hall_bg",type=1,typeName="Image",time=93433130,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="common/background/model_bg.png"
	},
	{
		name="logo",type=1,typeName="Image",time=93435986,x=0,y=144,width=369,height=71,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="hall/logo.png"
	},
	{
		name="hall_switch_server",type=2,typeName="Button",time=93516613,x=0,y=-461,width=128,height=41,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/button/dialog_btn_7_normal.png",
		{
			name="switch_text",type=4,typeName="Text",time=93516711,x=1,y=0,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=240,colorGreen=230,colorBlue=210,string=[[Text1]]
		}
	},
	{
		name="userinfo_view",type=0,typeName="View",time=93433187,x=-75,y=15,width=350,height=126,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
		{
			name="userinfo_view_bg",type=1,typeName="Image",time=93433358,x=120,y=27,width=230,height=49,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/background/info_bg_6.png",gridLeft=30,gridRight=30,gridTop=0,gridBottom=0,
			{
				name="money_view",type=0,typeName="View",time=93507055,x=0,y=0,width=166,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft
			},
			{
				name="add_money_btn",type=2,typeName="Button",time=110366757,x=5,y=0,width=40,height=40,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="common/button/add_btn_2_nor.png",file2="common/button/add_btn_2_pre.png"
			}
		},
		{
			name="name",type=4,typeName="Text",time=93499509,x=119,y=-27,width=155,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=30,textAlign=kAlignLeft,colorRed=80,colorGreen=80,colorBlue=80,string=[[无敌小次郎]]
		},
		{
			name="level_img",type=1,typeName="Image",time=93500098,x=285,y=-26,width=52,height=26,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/icon/level_1.png"
		},
		{
			name="icon_frame_stroke",type=1,typeName="Image",time=93434400,x=0,y=0,width=110,height=110,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="hall/icon_frame_stroke.png",
			{
				name="icon_frame_mask",type=2,typeName="Button",time=93584568,x=0,y=0,width=104,height=104,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="hall/icon_frame_mask.png"
			},
			{
				name="vip_frame",type=1,typeName="Image",time=100353067,x=0,y=0,width=90,height=90,visible=0,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,file="vip/vip_90.png"
			},
			{
				name="Image1",type=1,typeName="Image",time=110371714,x=0,y=-6,width=60,height=24,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="common/decoration/change.png"
			}
		}
	},
	{
		name="leaf_left",type=1,typeName="Image",time=93496609,x=0,y=0,width=131,height=253,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="common/decoration/bamboo_left_1.png"
	},
	{
		name="leaf_right",type=1,typeName="Image",time=93496641,x=0,y=0,width=81,height=152,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="common/decoration/bamboo_right_1.png"
	},
	{
		name="more_btn_bg",type=1,typeName="Image",time=110366244,x=277,y=-23,width=82,height=150,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/decoration/top_cloth_5.png",
		{
			name="more_btn",type=2,typeName="Button",time=93496887,x=0,y=0,width=80,height=84,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="hall/more_nor.png",file2="hall/more_pre.png",
			{
				name="pos",type=1,typeName="Image",time=99558972,x=52,y=25,width=22,height=26,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="dailytask/redPoint.png"
			}
		}
	},
	{
		name="friends_btn_bg",type=1,typeName="Image",time=110366526,x=172,y=-23,width=82,height=150,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/decoration/top_cloth_5.png",
		{
			name="friends_btn",type=2,typeName="Button",time=110366061,x=0,y=0,width=80,height=84,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="hall/friends_nor.png",file2="hall/friends_pre.png",
			{
				name="pos",type=1,typeName="Image",time=110366062,x=52,y=25,width=22,height=26,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="dailytask/redPoint.png"
			}
		}
	},
	{
		name="content_view",type=0,typeName="View",time=93435893,x=0,y=-69,width=700,height=830,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,
		{
			name="online_btn",type=2,typeName="Button",time=93436156,x=55,y=49,width=259,height=380,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="hall/online_btn_normal.png",file2="hall/online_btn_press.png"
		},
		{
			name="endgate_btn",type=2,typeName="Button",time=93436228,x=56,y=50,width=259,height=380,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="hall/endgate_btn_normal.png",file2="hall/endgate_btn_press.png"
		},
		{
			name="console_btn",type=2,typeName="Button",time=93436351,x=55,y=6,width=259,height=380,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottomLeft,file="hall/console_btn_normal.png",file2="hall/console_btn_press.png"
		},
		{
			name="dapu_btn",type=2,typeName="Button",time=93496401,x=55,y=6,width=259,height=380,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottomRight,file="hall/dapu_btn_normal.png",file2="hall/dapu_btn_press.png"
		}
	},
	{
		name="bottom_menu",type=0,typeName="View",time=94723368,x=0,y=0,width=720,height=182,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignBottom
	},
	{
		name="hall_version",type=4,typeName="Text",time=93517153,x=306,y=184,width=10,height=20,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,fontSize=20,textAlign=kAlignLeft,colorRed=145,colorGreen=140,colorBlue=126,string=[[]]
	},
	{
		name="hall_chat_btn",type=2,typeName="Button",time=97665916,x=0,y=135,width=60,height=174,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="common/button/hall_normal.png",file2="common/button/hall_press.png",
		{
			name="hall_chat_unread_msg",type=1,typeName="Image",time=106474898,x=-2,y=4,width=22,height=26,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="dailytask/redPoint.png"
		}
	},
	{
		name="hall_union_btn",type=2,typeName="Button",time=106230090,x=0,y=349,width=60,height=174,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="common/button/hall_union_normal.png",file2="common/button/hall_union_press.png"
	},
	{
		name="quick_play_btn",type=2,typeName="Button",time=110367055,x=0,y=404,width=358,height=110,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="hall/quick_play_btn_nor.png",file2="hall/quick_play_btn_pre.png"
	},
	{
		name="activity_btn",type=2,typeName="Button",time=112435058,x=40,y=142,width=98,height=82,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="common/decoration/act_daily_icon.png"
	}
}