setting_dialog_view=
{
	name="setting_dialog_view",type=0,typeName="View",time=0,x=0,y=0,width=480,height=800,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="setting_content_view",type=0,typeName="View",time=1733838,x=0,y=-1,width=720,height=751,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,
		{
			name="setting_content_bg",type=1,typeName="Image",time=3375789,x=0,y=0,width=720,height=751,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="common/background/dialog_bg_1.png",gridLeft=128,gridRight=128,gridTop=128,gridBottom=128
		},
		{
			name="Text1",type=4,typeName="Text",time=96112319,x=0,y=56,width=110,height=44,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=44,textAlign=kAlignLeft,colorRed=80,colorGreen=80,colorBlue=80,string=[[设 置]]
		},
		{
			name="Image2",type=1,typeName="Image",time=96112383,x=0,y=116,width=640,height=19,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/decoration/line.png"
		},
		{
			name="sound_seekbar_view",type=0,typeName="View",time=96112907,x=0,y=146,width=619,height=103,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
			{
				name="title",type=4,typeName="Text",time=96112698,x=20,y=0,width=80,height=33,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=32,textAlign=kAlignLeft,colorRed=80,colorGreen=80,colorBlue=80,string=[[音 效]]
			},
			{
				name="reduction_btn",type=2,typeName="Button",time=96112867,x=140,y=0,width=66,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/button/round_normal.png",file2="common/button/round_press.png",
				{
					name="icon",type=1,typeName="Image",time=96113395,x=0,y=-3,width=40,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/button/reduce_vol_btn.png"
				}
			},
			{
				name="add_btn",type=2,typeName="Button",time=96113111,x=534,y=0,width=66,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/button/round_normal.png",file2="common/button/round_press.png",
				{
					name="icon",type=1,typeName="Image",time=96113363,x=0,y=-3,width=40,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/button/add_vol_btn.png"
				}
			},
			{
				name="seekbar_bbg",type=1,typeName="Image",time=96115997,x=235,y=0,width=270,height=33,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/background/seekbar_bbg.png",
				{
					name="seekbar_fbg",type=1,typeName="Image",time=96116067,x=13,y=0,width=243,height=18,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/background/seekbar_fbg.png"
				}
			},
			{
				name="seekbar",type=0,typeName="Slider",time=96113136,x=268,y=0,width=205,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft
			},
			{
				name="line",type=1,typeName="Image",time=96113276,x=0,y=-8,width=619,height=2,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignBottom,file="common/decoration/line_2.png"
			}
		},
		{
			name="music_seekbar_view",type=0,typeName="View",time=96113258,x=0,y=270,width=619,height=87,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
			{
				name="title",type=4,typeName="Text",time=96113259,x=20,y=0,width=64,height=33,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=32,textAlign=kAlignLeft,colorRed=80,colorGreen=80,colorBlue=80,string=[[音 乐]]
			},
			{
				name="reduction_btn",type=2,typeName="Button",time=96113260,x=140,y=0,width=66,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/button/round_normal.png",file2="common/button/round_press.png",
				{
					name="icon",type=1,typeName="Image",time=96113466,x=0,y=-3,width=40,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/button/reduce_vol_btn.png"
				}
			},
			{
				name="add_btn",type=2,typeName="Button",time=96113261,x=534,y=0,width=66,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/button/round_normal.png",file2="common/button/round_press.png",
				{
					name="icon",type=1,typeName="Image",time=96113470,x=0,y=-3,width=40,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/button/add_vol_btn.png"
				}
			},
			{
				name="seekbar_bbg",type=1,typeName="Image",time=96116182,x=235,y=0,width=270,height=33,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/background/seekbar_bbg.png",
				{
					name="seekbar_fbg",type=1,typeName="Image",time=96116183,x=13,y=0,width=243,height=18,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/background/seekbar_fbg.png"
				}
			},
			{
				name="seekbar",type=0,typeName="Slider",time=96113262,x=268,y=0,width=205,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft
			},
			{
				name="line",type=1,typeName="Image",time=96113309,x=0,y=-6,width=619,height=2,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignBottom,file="common/decoration/line_2.png"
			}
		},
		{
			name="sound_toggle_view",type=0,typeName="View",time=96113484,x=0,y=337,width=619,height=93,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
			{
				name="title",type=4,typeName="Text",time=96113485,x=20,y=0,width=64,height=33,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=32,textAlign=kAlignLeft,colorRed=80,colorGreen=80,colorBlue=80,string=[[音 效]]
			},
			{
				name="line",type=1,typeName="Image",time=96113491,x=0,y=-8,width=619,height=2,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignBottom,file="common/decoration/line_2.png"
			},
			{
				name="toggle_btn",type=2,typeName="Button",time=96113553,x=240,y=6,width=167,height=41,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/button/toggle_bg.png",
				{
					name="close",type=1,typeName="Image",time=96113656,x=23,y=0,width=58,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="common/icon/close.png"
				},
				{
					name="open",type=1,typeName="Image",time=96113684,x=20,y=0,width=64,height=31,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/icon/open.png"
				},
				{
					name="toggle_icon",type=1,typeName="Image",time=96113709,x=-55,y=-1,width=96,height=71,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/decoration/choice_icon.png"
				}
			}
		},
		{
			name="music_toggle_view",type=0,typeName="View",time=96113868,x=0,y=437,width=619,height=93,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
			{
				name="title",type=4,typeName="Text",time=96113869,x=20,y=0,width=64,height=33,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=32,textAlign=kAlignLeft,colorRed=80,colorGreen=80,colorBlue=80,string=[[音 乐]]
			},
			{
				name="toggle_btn",type=2,typeName="Button",time=96113871,x=240,y=6,width=167,height=41,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/button/toggle_bg.png",
				{
					name="close",type=1,typeName="Image",time=96113872,x=23,y=0,width=58,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="common/icon/close.png"
				},
				{
					name="open",type=1,typeName="Image",time=96113873,x=20,y=0,width=64,height=31,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/icon/open.png"
				},
				{
					name="toggle_icon",type=1,typeName="Image",time=96113874,x=-55,y=-1,width=96,height=71,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/decoration/choice_icon.png"
				}
			}
		},
		{
			name="vibrate_toggle_view",type=0,typeName="View",time=96724320,x=-1,y=458,width=619,height=93,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
			{
				name="title",type=4,typeName="Text",time=96724321,x=20,y=0,width=80,height=33,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=32,textAlign=kAlignLeft,colorRed=80,colorGreen=80,colorBlue=80,string=[[振 动]]
			},
			{
				name="line",type=1,typeName="Image",time=96724322,x=0,y=0,width=619,height=2,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignBottom,file="common/decoration/line_2.png"
			},
			{
				name="toggle_btn",type=2,typeName="Button",time=96724323,x=240,y=6,width=167,height=41,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/button/toggle_bg.png",
				{
					name="close",type=1,typeName="Image",time=96724324,x=23,y=0,width=58,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="common/icon/close.png"
				},
				{
					name="open",type=1,typeName="Image",time=96724325,x=20,y=0,width=64,height=31,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/icon/open.png"
				},
				{
					name="toggle_icon",type=1,typeName="Image",time=96724326,x=-55,y=-1,width=96,height=71,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/decoration/choice_icon.png"
				}
			}
		},
		{
			name="dark_toggle_view",type=0,typeName="View",time=122808133,x=-1,y=552,width=619,height=93,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
			{
				name="title",type=4,typeName="Text",time=122808134,x=20,y=0,width=80,height=33,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=32,textAlign=kAlignLeft,colorRed=80,colorGreen=80,colorBlue=80,string=[[夜间模式]]
			},
			{
				name="line",type=1,typeName="Image",time=122808135,x=0,y=0,width=619,height=2,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignBottom,file="common/decoration/line_2.png"
			},
			{
				name="toggle_btn",type=2,typeName="Button",time=122808136,x=240,y=6,width=167,height=41,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/button/toggle_bg.png",
				{
					name="close",type=1,typeName="Image",time=122808137,x=23,y=0,width=58,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="common/icon/close.png"
				},
				{
					name="open",type=1,typeName="Image",time=122808138,x=20,y=0,width=64,height=31,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/icon/open.png"
				},
				{
					name="toggle_icon",type=1,typeName="Image",time=122808139,x=-55,y=-1,width=96,height=71,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/decoration/choice_icon.png"
				}
			}
		},
		{
			name="chat_toggle_view",type=0,typeName="View",time=96113915,x=0,y=363,width=619,height=93,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
			{
				name="title",type=4,typeName="Text",time=96113916,x=20,y=0,width=64,height=33,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=32,textAlign=kAlignLeft,colorRed=80,colorGreen=80,colorBlue=80,string=[[聊天语音]]
			},
			{
				name="toggle_btn",type=2,typeName="Button",time=96113918,x=240,y=6,width=167,height=41,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/button/toggle_bg.png",
				{
					name="close",type=1,typeName="Image",time=96113919,x=23,y=0,width=58,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="common/icon/close.png"
				},
				{
					name="open",type=1,typeName="Image",time=96113920,x=20,y=0,width=64,height=31,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/icon/open.png"
				},
				{
					name="toggle_icon",type=1,typeName="Image",time=96113921,x=-55,y=-1,width=96,height=71,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/decoration/choice_icon.png"
				}
			},
			{
				name="line",type=1,typeName="Image",time=96113870,x=0,y=0,width=619,height=2,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignBottom,file="common/decoration/line_2.png"
			}
		},
		{
			name="switch_move_way_view",type=0,typeName="View",time=112419099,x=0,y=650,width=619,height=93,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
			{
				name="title",type=4,typeName="Text",time=112419224,x=20,y=0,width=80,height=33,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=32,textAlign=kAlignLeft,colorRed=80,colorGreen=80,colorBlue=80,string=[[操 作]]
			},
			{
				name="btn1",type=2,typeName="Button",time=112420878,x=142,y=0,width=223,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="drawable/blank.png",
				{
					name="check_img1",type=1,typeName="Image",time=112419833,x=2,y=0,width=52,height=52,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/check_bg.png"
				},
				{
					name="select1",type=1,typeName="Image",time=112420181,x=3,y=14,width=56,height=43,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="common/checked.png"
				},
				{
					name="move_one",type=4,typeName="Text",time=112419979,x=74,y=0,width=150,height=33,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=32,textAlign=kAlignLeft,colorRed=135,colorGreen=100,colorBlue=82,string=[[一步划子]]
				}
			},
			{
				name="btn2",type=2,typeName="Button",time=112421031,x=385,y=0,width=223,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="drawable/blank.png",
				{
					name="check_img2",type=1,typeName="Image",time=112420060,x=6,y=0,width=52,height=52,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/check_bg.png"
				},
				{
					name="select2",type=1,typeName="Image",time=112420224,x=6,y=0,width=56,height=43,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/checked.png"
				},
				{
					name="move_two",type=4,typeName="Text",time=112420083,x=76,y=0,width=150,height=33,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=32,textAlign=kAlignLeft,colorRed=135,colorGreen=100,colorBlue=82,string=[[两步走子]]
				}
			}
		},
		{
			name="close_btn",type=2,typeName="Button",time=102140507,x=38,y=50,width=60,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="common/button/btn_close.png"
		}
	}
}