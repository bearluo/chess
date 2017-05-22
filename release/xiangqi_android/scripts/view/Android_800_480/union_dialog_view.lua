union_dialog_view=
{
	name="union_dialog_view",type=0,typeName="View",time=0,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,
	{
		name="bg",type=1,typeName="Image",time=106135897,x=-30,y=17,width=720,height=1080,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/background/dialog_bg_2.png",gridLeft=120,gridRight=120,gridTop=120,gridBottom=120,
		{
			name="hide_btn",type=2,typeName="Button",time=106135942,x=520,y=-44,width=174,height=57,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="common/button/hide_chat_normal.png"
		},
		{
			name="union_view",type=0,typeName="View",time=106279031,x=0,y=0,width=720,height=1080,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignCenter,
			{
				name="title_view",type=0,typeName="View",time=106135898,x=0,y=50,width=666,height=216,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
				{
					name="icon_frame",type=1,typeName="Image",time=106135899,x=-216,y=26,width=150,height=150,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="hall/city_icon.png",
					{
						name="text",type=4,typeName="Text",time=106229627,x=0,y=0,width=200,height=150,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=54,textAlign=kAlignCenter,colorRed=150,colorGreen=75,colorBlue=60,string=[[同城]]
					}
				},
				{
					name="name_bg",type=1,typeName="Image",time=106135900,x=90,y=33,width=420,height=58,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/background/chat_time_bg.png",gridLeft=68,gridRight=68,gridTop=16,gridBottom=16,
					{
						name="name_text",type=4,typeName="Text",time=106135901,x=20,y=0,width=200,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=31,textAlign=kAlignLeft,colorRed=80,colorGreen=80,colorBlue=80,string=[[名称:]]
					},
					{
						name="name",type=4,typeName="Text",time=106135902,x=110,y=0,width=224,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=31,textAlign=kAlignLeft,colorRed=125,colorGreen=80,colorBlue=65,string=[[尚未选择地区]]
					}
				},
				{
					name="member_bg",type=1,typeName="Image",time=106135903,x=90,y=110,width=420,height=58,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/background/chat_time_bg.png",gridLeft=68,gridRight=68,gridTop=16,gridBottom=16,
					{
						name="member_text",type=4,typeName="Text",time=106135904,x=20,y=0,width=200,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=31,textAlign=kAlignLeft,colorRed=80,colorGreen=80,colorBlue=80,string=[[成员:]]
					},
					{
						name="member_num",type=4,typeName="Text",time=106135905,x=110,y=0,width=200,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=31,textAlign=kAlignLeft,colorRed=125,colorGreen=80,colorBlue=65,string=[[无]]
					}
				},
				{
					name="Image2",type=1,typeName="Image",time=106135906,x=0,y=0,width=640,height=20,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="common/decoration/line.png"
				}
			},
			{
				name="content_bg",type=1,typeName="Image",time=106135907,x=0,y=298,width=618,height=722,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/background/line_bg.png",gridLeft=64,gridRight=64,gridTop=64,gridBottom=64,
				{
					name="prompt_textview",type=5,typeName="TextView",time=106135908,x=0,y=120,width=365,height=190,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=36,textAlign=kAlignCenter,colorRed=80,colorGreen=80,colorBlue=80,string=[[同城相关功能需要选择所在地区后才可以使用]]
				},
				{
					name="experience_btn",type=2,typeName="Button",time=106135909,x=0,y=324,width=244,height=85,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/button/dialog_btn_4_normal.png",file2="common/button/dialog_btn_4_press.png",
					{
						name="text",type=4,typeName="Text",time=106135910,x=-6,y=-1,width=200,height=150,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=36,textAlign=kAlignCenter,colorRed=240,colorGreen=230,colorBlue=210,string=[[ 立即体验]]
					}
				},
				{
					name="view",type=0,typeName="View",time=106139864,x=0,y=0,width=618,height=722,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,
					{
						name="item1",type=0,typeName="View",time=106135915,x=-192,y=110,width=190,height=300,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
						{
							name="image",type=1,typeName="Image",time=106135916,x=0,y=0,width=116,height=116,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/background/head_bg_130.png",
							{
								name="vip_frame",type=1,typeName="Image",time=106216758,x=0,y=0,width=110,height=110,visible=0,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,file="vip/vip_110.png"
							}
						},
						{
							name="name",type=4,typeName="Text",time=106135917,x=0,y=128,width=210,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=30,textAlign=kAlignCenter,colorRed=80,colorGreen=80,colorBlue=80,string=[[樱桃小丸子]]
						},
						{
							name="score",type=4,typeName="Text",time=106135918,x=0,y=169,width=191,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=24,textAlign=kAlignCenter,colorRed=80,colorGreen=80,colorBlue=80,string=[[积分:0]]
						},
						{
							name="button",type=2,typeName="Button",time=106135919,x=0,y=15,width=176,height=58,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="common/button/dialog_btn_3_normal.png",file2="common/button/dialog_btn_7_normal.png",gridLeft=64,gridRight=64,gridTop=29,gridBottom=29,
							{
								name="text",type=4,typeName="Text",time=106135920,x=0,y=0,width=200,height=150,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=32,textAlign=kAlignCenter,colorRed=240,colorGreen=230,colorBlue=210,string=[[关注]]
							}
						}
					},
					{
						name="item2",type=0,typeName="View",time=106135921,x=5,y=110,width=190,height=300,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
						{
							name="image",type=1,typeName="Image",time=106135922,x=0,y=0,width=116,height=116,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/background/head_bg_130.png",
							{
								name="vip_frame",type=1,typeName="Image",time=106216818,x=0,y=0,width=110,height=110,visible=0,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,file="vip/vip_110.png"
							}
						},
						{
							name="name",type=4,typeName="Text",time=106135923,x=0,y=128,width=210,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=30,textAlign=kAlignCenter,colorRed=80,colorGreen=80,colorBlue=80,string=[[樱桃小丸子]]
						},
						{
							name="score",type=4,typeName="Text",time=106135924,x=0,y=169,width=191,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=24,textAlign=kAlignCenter,colorRed=125,colorGreen=80,colorBlue=65,string=[[积分:0]]
						},
						{
							name="button",type=2,typeName="Button",time=106135925,x=0,y=15,width=176,height=58,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="common/button/dialog_btn_3_normal.png",file2="common/button/dialog_btn_7_normal.png",gridLeft=64,gridRight=64,gridTop=29,gridBottom=29,
							{
								name="text",type=4,typeName="Text",time=106135926,x=0,y=0,width=200,height=150,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=32,textAlign=kAlignCenter,colorRed=240,colorGreen=230,colorBlue=210,string=[[关注]]
							}
						},
						{
							name="img1",type=1,typeName="Image",time=106135933,x=-4,y=-48,width=1,height=160,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/decoration/line_3.png"
						},
						{
							name="img2",type=1,typeName="Image",time=106135934,x=-3,y=-48,width=1,height=160,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="common/decoration/line_3.png"
						}
					},
					{
						name="item3",type=0,typeName="View",time=106135927,x=201,y=110,width=190,height=300,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
						{
							name="image",type=1,typeName="Image",time=106135928,x=0,y=0,width=116,height=116,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/background/head_bg_130.png",
							{
								name="vip_frame",type=1,typeName="Image",time=106216821,x=0,y=0,width=110,height=110,visible=0,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,file="vip/vip_110.png"
							}
						},
						{
							name="name",type=4,typeName="Text",time=106135929,x=0,y=128,width=210,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=30,textAlign=kAlignCenter,colorRed=80,colorGreen=80,colorBlue=80,string=[[樱桃小丸子]]
						},
						{
							name="score",type=4,typeName="Text",time=106135930,x=0,y=169,width=191,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=24,textAlign=kAlignCenter,colorRed=125,colorGreen=80,colorBlue=65,string=[[积分:0]]
						},
						{
							name="button",type=2,typeName="Button",time=106135931,x=0,y=15,width=176,height=58,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="common/button/dialog_btn_3_normal.png",file2="common/button/dialog_btn_7_normal.png",gridLeft=64,gridRight=64,gridTop=29,gridBottom=29,
							{
								name="text",type=4,typeName="Text",time=106135932,x=0,y=0,width=200,height=150,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=32,textAlign=kAlignCenter,colorRed=240,colorGreen=230,colorBlue=210,string=[[关注]]
							}
						}
					},
					{
						name="member_btn",type=2,typeName="Button",time=106135911,x=0,y=0,width=600,height=93,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="drawable/blank.png",
						{
							name="text",type=4,typeName="Text",time=106135912,x=12,y=0,width=240,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=36,textAlign=kAlignLeft,colorRed=80,colorGreen=80,colorBlue=80,string=[[同城好友推荐]]
						},
						{
							name="Image3",type=1,typeName="Image",time=106135913,x=28,y=0,width=14,height=25,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="common/icon/arrow_r.png"
						}
					},
					{
						name="Image4",type=1,typeName="Image",time=106135914,x=0,y=90,width=585,height=2,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/decoration/name_line.png"
					},
					{
						name="change_button",type=2,typeName="Button",time=106135935,x=-5,y=420,width=150,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="drawable/blank.png",
						{
							name="text",type=4,typeName="Text",time=106135936,x=0,y=0,width=150,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=32,textAlign=kAlignCenter,colorRed=80,colorGreen=80,colorBlue=80,string=[[换一批]]
						},
						{
							name="Image5",type=1,typeName="Image",time=106135937,x=14,y=13,width=128,height=2,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="common/decoration/name_line.png"
						},
						{
							name="Image6",type=1,typeName="Image",time=106135938,x=0,y=0,width=14,height=25,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="common/icon/arrow_r.png"
						}
					},
					{
						name="union_task",type=0,typeName="View",time=106135939,x=0,y=2,width=601,height=207,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,
						{
							name="title_img",type=1,typeName="Image",time=106135940,x=4,y=-3,width=576,height=19,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/decoration/line_4.png"
						},
						{
							name="title",type=4,typeName="Text",time=106135941,x=5,y=-19,width=200,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=32,textAlign=kAlignCenter,colorRed=100,colorGreen=100,colorBlue=100,string=[[同城任务]]
						}
					}
				}
			}
		},
		{
			name="member_view",type=0,typeName="View",time=106279081,x=0,y=0,width=720,height=1080,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,
			{
				name="Image1",type=1,typeName="Image",time=106279329,x=0,y=133,width=615,height=19,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/decoration/line.png"
			},
			{
				name="title",type=4,typeName="Text",time=106279471,x=0,y=0,width=200,height=150,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=40,textAlign=kAlignCenter,colorRed=80,colorGreen=80,colorBlue=80,string=[[联盟成员]]
			},
			{
				name="back_btn",type=2,typeName="Button",time=106279570,x=30,y=36,width=80,height=80,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="drawable/blank.png",
				{
					name="image",type=1,typeName="Image",time=106279644,x=0,y=0,width=35,height=33,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/button/back_normal.png"
				}
			},
			{
				name="member_bg",type=1,typeName="Image",time=106279709,x=0,y=185,width=622,height=860,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/background/line_bg.png",gridLeft=64,gridRight=64,gridTop=64,gridBottom=64
			}
		}
	}
}