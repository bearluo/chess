union_module_view=
{
	name="union_module_view",type=0,typeName="View",time=0,x=0,y=0,width=628,height=946,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
	{
		name="union_view",type=0,typeName="View",time=121940148,x=0,y=0,width=628,height=946,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
		{
			name="icon_frame",type=1,typeName="Image",time=121940204,x=4,y=2,width=150,height=150,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="hall/city_icon.png",
			{
				name="text",type=4,typeName="Text",time=121941309,x=0,y=0,width=150,height=150,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=54,textAlign=kAlignCenter,colorRed=150,colorGreen=75,colorBlue=60,string=[[同城]]
			}
		},
		{
			name="name_bg",type=1,typeName="Image",time=121941368,x=90,y=9,width=436,height=58,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/background/chat_time_bg.png",gridLeft=68,gridRight=68,gridTop=16,gridBottom=16,
			{
				name="name_text",type=4,typeName="Text",time=121941467,x=20,y=0,width=110,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=32,textAlign=kAlignLeft,colorRed=80,colorGreen=80,colorBlue=80,string=[[名称：]]
			},
			{
				name="name",type=4,typeName="Text",time=121941564,x=110,y=0,width=200,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=32,textAlign=kAlignLeft,colorRed=125,colorGreen=80,colorBlue=65,string=[[尚未选择地区]]
			}
		},
		{
			name="member_bg",type=1,typeName="Image",time=121941637,x=90,y=88,width=436,height=58,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/background/chat_time_bg.png",gridLeft=68,gridRight=68,gridTop=16,gridBottom=16,
			{
				name="member_text",type=4,typeName="Text",time=121941724,x=20,y=0,width=200,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=32,textAlign=kAlignLeft,colorRed=80,colorGreen=80,colorBlue=80,string=[[成员：]]
			},
			{
				name="member_num",type=4,typeName="Text",time=121941774,x=110,y=0,width=200,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=32,textAlign=kAlignLeft,colorRed=125,colorGreen=80,colorBlue=65,string=[[无]]
			}
		},
		{
			name="Image2",type=1,typeName="Image",time=121941841,x=0,y=174,width=636,height=19,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/decoration/line.png"
		},
		{
			name="line_bg",type=1,typeName="Image",time=121941909,x=0,y=225,width=620,height=718,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/background/line_bg.png",gridLeft=64,gridRight=64,gridTop=64,gridBottom=64,
			{
				name="prompt_textview",type=5,typeName="TextView",time=121942061,x=0,y=136,width=366,height=190,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=36,textAlign=kAlignCenter,colorRed=80,colorGreen=80,colorBlue=80,string=[[同城相关功能需要选择所在地区后才可以使用]]
			},
			{
				name="experience_btn",type=2,typeName="Button",time=121942182,x=0,y=352,width=244,height=85,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/button/dialog_btn_4_normal.png",file2="common/button/dialog_btn_4_press.png",
				{
					name="text",type=4,typeName="Text",time=121942215,x=0,y=0,width=200,height=80,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=36,textAlign=kAlignCenter,colorRed=240,colorGreen=230,colorBlue=210,string=[[立即体验]]
				}
			},
			{
				name="view",type=0,typeName="View",time=121942591,x=0,y=0,width=620,height=718,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
				{
					name="recommend_view",type=0,typeName="View",time=121942631,x=0,y=108,width=578,height=292,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop
				},
				{
					name="member_btn",type=2,typeName="Button",time=121942669,x=0,y=2,width=600,height=92,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="drawable/blank.png",
					{
						name="text",type=4,typeName="Text",time=121942706,x=12,y=0,width=200,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=36,textAlign=kAlignLeft,colorRed=80,colorGreen=80,colorBlue=80,string=[[同城好友推荐]]
					},
					{
						name="Image3",type=1,typeName="Image",time=121942748,x=28,y=0,width=14,height=25,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="common/icon/arrow_r.png"
					}
				},
				{
					name="Image4",type=1,typeName="Image",time=121942912,x=0,y=90,width=585,height=2,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/decoration/name_line.png"
				},
				{
					name="change_button",type=2,typeName="Button",time=121942956,x=0,y=420,width=150,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="drawable/blank.png",
					{
						name="text",type=4,typeName="Text",time=121943019,x=0,y=0,width=150,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=32,textAlign=kAlignCenter,colorRed=80,colorGreen=80,colorBlue=80,string=[[换一批]]
					},
					{
						name="Image5",type=1,typeName="Image",time=121943223,x=14,y=13,width=128,height=2,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="common/decoration/name_line.png"
					},
					{
						name="Image6",type=1,typeName="Image",time=121943262,x=0,y=0,width=14,height=25,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="common/icon/arrow_r.png"
					}
				}
			},
			{
				name="union_task",type=0,typeName="View",time=121943342,x=0,y=0,width=600,height=208,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,
				{
					name="title_img",type=1,typeName="Image",time=121943453,x=0,y=-5,width=576,height=19,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/decoration/line_4.png"
				},
				{
					name="title",type=4,typeName="Text",time=121943491,x=0,y=-20,width=200,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=32,textAlign=kAlignCenter,colorRed=80,colorGreen=80,colorBlue=80,string=[[同城任务]]
				}
			}
		}
	},
	{
		name="member_view",type=0,typeName="View",time=121943710,x=0,y=0,width=628,height=946,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
		{
			name="title",type=4,typeName="Text",time=121943838,x=0,y=-6,width=200,height=150,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=40,textAlign=kAlignCenter,colorRed=80,colorGreen=80,colorBlue=80,string=[[联盟成员]]
		},
		{
			name="Image7",type=1,typeName="Image",time=121943900,x=0,y=116,width=640,height=19,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/decoration/line.png"
		},
		{
			name="back_btn",type=2,typeName="Button",time=121943936,x=30,y=36,width=80,height=80,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="drawable/blank.png",
			{
				name="image",type=1,typeName="Image",time=121943979,x=0,y=0,width=35,height=33,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/button/back_normal.png"
			}
		},
		{
			name="member_bg",type=1,typeName="Image",time=121944020,x=0,y=186,width=622,height=759,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/background/line_bg.png",gridLeft=64,gridRight=64,gridTop=64,gridBottom=64
		}
	}
}