relationship_dialog=
{
	name="relationship_dialog",type=0,typeName="View",time=0,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="title_bg",type=1,typeName="Image",time=136606167,x=0,y=-22,width=720,height=140,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTop,file="common/background/chat_title_bg.png",
		{
			name="Text1",type=4,typeName="Text",time=136606233,x=0,y=52,width=120,height=48,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=48,textAlign=kAlignLeft,colorRed=225,colorGreen=200,colorBlue=160,string=[[我的好友]]
		},
		{
			name="blacklist_btn",type=2,typeName="Button",time=136606285,x=6,y=26,width=105,height=105,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="drawable/blank.png",
			{
				name="Image2",type=1,typeName="Image",time=136606388,x=0,y=0,width=60,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/icon/blacklist_icon.png"
			}
		}
	},
	{
		name="content_view",type=0,typeName="View",time=136606754,x=0,y=118,width=705,height=1050,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
		{
			name="list_bg",type=1,typeName="Image",time=136606808,x=0,y=90,width=674,height=948,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/background/chatroom_bg_3.png",
			{
				name="follow_view",type=0,typeName="View",time=136624532,x=0,y=70,width=650,height=774,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
				{
					name="invite_btn",type=2,typeName="Button",time=136624598,x=0,y=-80,width=349,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="drawable/blank.png",
					{
						name="Text4",type=4,typeName="Text",time=136624629,x=12,y=0,width=224,height=33,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,fontSize=32,textAlign=kAlignLeft,colorRed=245,colorGreen=115,colorBlue=15,string=[[邀请好友一起玩]]
					},
					{
						name="Image6",type=1,typeName="Image",time=137127293,x=14,y=0,width=60,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/button/add_btn_5.png"
					}
				},
				{
					name="invite_friends_view",type=0,typeName="View",time=136630846,x=0,y=0,width=200,height=150,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTop,
					{
						name="btn",type=2,typeName="Button",time=136630847,x=0,y=700,width=444,height=96,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/button/long_yellow_btn.png",
						{
							name="Text3",type=4,typeName="Text",time=136630848,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=36,textAlign=kAlignLeft,colorRed=95,colorGreen=15,colorBlue=15,string=[[邀请好友]]
						}
					},
					{
						name="Image1",type=1,typeName="Image",time=136630849,x=0,y=224,width=286,height=260,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/decoration/player.png"
					},
					{
						name="Text2",type=4,typeName="Text",time=136630850,x=0,y=449,width=480,height=150,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=32,textAlign=kAlignCenter,colorRed=170,colorGreen=135,colorBlue=100,string=[[快点击“邀请好友”邀请一起玩吧]]
					}
				},
				{
					name="num",type=4,typeName="Text",time=136607715,x=0,y=-49,width=48,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=26,textAlign=kAlignCenter,colorRed=125,colorGreen=80,colorBlue=65,string=[[]]
				},
				{
					name="mask",type=1,typeName="Image",time=137127909,x=0,y=0,width=676,height=60,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignBottom,file="common/decoration/mask_1.png"
				},
				{
					name="line",type=1,typeName="Image",time=137127970,x=0,y=-3,width=650,height=1,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTop,file="common/decoration/line_9.png"
				}
			},
			{
				name="fans_view",type=0,typeName="View",time=136630423,x=0,y=70,width=650,height=774,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
				{
					name="invite_btn",type=2,typeName="Button",time=136630424,x=0,y=-80,width=349,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="drawable/blank.png",
					{
						name="Text4",type=4,typeName="Text",time=136630425,x=12,y=0,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,fontSize=32,textAlign=kAlignLeft,colorRed=245,colorGreen=115,colorBlue=15,string=[[邀请好友一起玩]]
					},
					{
						name="Image61",type=1,typeName="Image",time=137127366,x=14,y=0,width=60,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/button/add_btn_5.png"
					}
				},
				{
					name="invite_friends_view",type=0,typeName="View",time=136630849,x=0,y=0,width=200,height=150,visible=0,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTop,
					{
						name="btn",type=2,typeName="Button",time=136630850,x=0,y=700,width=444,height=96,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/button/long_yellow_btn.png",
						{
							name="Text3",type=4,typeName="Text",time=136630851,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=36,textAlign=kAlignLeft,colorRed=95,colorGreen=15,colorBlue=15,string=[[邀请好友]]
						}
					},
					{
						name="Image1",type=1,typeName="Image",time=136630852,x=0,y=224,width=286,height=260,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/decoration/player.png"
					},
					{
						name="Text2",type=4,typeName="Text",time=136630853,x=0,y=449,width=480,height=150,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=32,textAlign=kAlignCenter,colorRed=170,colorGreen=135,colorBlue=100,string=[[快点击“邀请好友”邀请一起玩吧]]
					}
				},
				{
					name="num",type=4,typeName="Text",time=136607677,x=0,y=-49,width=48,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=26,textAlign=kAlignCenter,colorRed=125,colorGreen=80,colorBlue=65,string=[[]]
				},
				{
					name="mask",type=1,typeName="Image",time=137127486,x=0,y=0,width=676,height=60,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignBottom,file="common/decoration/mask_1.png"
				},
				{
					name="line",type=1,typeName="Image",time=137127996,x=0,y=-3,width=650,height=1,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTop,file="common/decoration/line_9.png"
				}
			},
			{
				name="recent_player_view",type=0,typeName="View",time=136630864,x=0,y=25,width=650,height=878,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
				{
					name="no_recent_player_view",type=0,typeName="View",time=136609973,x=0,y=0,width=200,height=150,visible=0,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTop,
					{
						name="btn",type=2,typeName="Button",time=136609974,x=0,y=700,width=444,height=96,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/button/long_yellow_btn.png",
						{
							name="Text3",type=4,typeName="Text",time=136609975,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=36,textAlign=kAlignLeft,colorRed=95,colorGreen=15,colorBlue=15,string=[[快速对战]]
						}
					},
					{
						name="Image1",type=1,typeName="Image",time=136609976,x=0,y=224,width=286,height=260,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/decoration/pk.png"
					},
					{
						name="Text2",type=4,typeName="Text",time=136609977,x=3,y=449,width=480,height=150,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=32,textAlign=kAlignLeft,colorRed=170,colorGreen=135,colorBlue=100,string=[[快点击“快速对战”发起一场对弈吧]]
					}
				},
				{
					name="mask_1",type=1,typeName="Image",time=137128217,x=0,y=-25,width=674,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/decoration/mask_2.png"
				},
				{
					name="mask_2",type=1,typeName="Image",time=137128264,x=0,y=-44,width=674,height=80,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="common/decoration/mask_3.png"
				}
			}
		},
		{
			name="follow_btn",type=2,typeName="Button",time=136607266,x=42,y=26,width=204,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="common/button/table_nor_5.png",gridLeft=30,gridRight=30,gridTop=0,gridBottom=0,
			{
				name="title",type=4,typeName="Text",time=136607628,x=0,y=0,width=60,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=30,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[关注]]
			},
			{
				name="new_bg",type=1,typeName="Image",time=136951146,x=24,y=-12,width=47,height=26,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="chessfriends/new_friend_bg.png",
				{
					name="new_add_num",type=4,typeName="Text",time=136951147,x=0,y=0,width=50,height=40,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[+1]]
				}
			},
			{
				name="Image4",type=1,typeName="Image",time=137126991,x=-60,y=0,width=28,height=20,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/decoration/cloud_l.png"
			},
			{
				name="Image5",type=1,typeName="Image",time=137127048,x=60,y=0,width=28,height=20,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/decoration/cloud_r.png"
			}
		},
		{
			name="fans_btn",type=2,typeName="Button",time=136607415,x=252,y=26,width=200,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="common/button/table_nor_5.png",gridLeft=30,gridRight=30,gridTop=0,gridBottom=0,
			{
				name="title",type=4,typeName="Text",time=136607712,x=0,y=0,width=60,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=30,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[粉丝]]
			},
			{
				name="new_bg",type=1,typeName="Image",time=136951193,x=24,y=-12,width=47,height=26,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="chessfriends/new_friend_bg.png",
				{
					name="new_add_num",type=4,typeName="Text",time=136951194,x=0,y=0,width=50,height=40,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[+1]]
				}
			},
			{
				name="Image41",type=1,typeName="Image",time=137127069,x=-60,y=0,width=28,height=20,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/decoration/cloud_l.png"
			},
			{
				name="Image51",type=1,typeName="Image",time=137127070,x=60,y=0,width=28,height=20,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/decoration/cloud_r.png"
			}
		},
		{
			name="recent_player_btn",type=2,typeName="Button",time=136607417,x=460,y=26,width=200,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="common/button/table_nor_5.png",gridLeft=30,gridRight=30,gridTop=0,gridBottom=0,
			{
				name="title",type=4,typeName="Text",time=136607714,x=0,y=0,width=60,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=30,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[对手]]
			},
			{
				name="Image42",type=1,typeName="Image",time=137127071,x=-60,y=0,width=28,height=20,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/decoration/cloud_l.png"
			},
			{
				name="Image52",type=1,typeName="Image",time=137127073,x=60,y=0,width=28,height=20,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/decoration/cloud_r.png"
			}
		}
	},
	{
		name="cancel_btn",type=2,typeName="Button",time=136606921,x=27,y=38,width=60,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottomLeft,file="common/button/hide_dialog_btn.png"
	}
}