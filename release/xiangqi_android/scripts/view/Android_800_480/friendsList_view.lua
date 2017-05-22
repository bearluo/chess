friendsList_view=
{
	name="friendsList_view",type=0,typeName="View",time=0,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="friendsList_view_bg",type=1,typeName="Image",time=86769170,x=0,y=0,width=480,height=800,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="hall/hall_bg.png",gridLeft=32,gridRight=32,gridTop=32,gridBottom=32
	},
	{
		name="friends_title_view",type=0,typeName="View",time=86769813,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTopLeft,
		{
			name="friends_title_bg",type=1,typeName="Image",time=86769939,x=0,y=0,width=480,height=95,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="common/activity_center_top_title_bg.png"
		},
		{
			name="friends_back_btn",type=2,typeName="Button",time=86770043,x=-5,y=3,width=62,height=62,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="common/ending_back.png"
		},
		{
			name="friends_add_btn",type=2,typeName="Button",time=86770528,x=5,y=5,width=54,height=58,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="friends/addtobg.png",
			{
				name="add",type=1,typeName="Image",time=86771322,x=0,y=0,width=44,height=26,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="friends/add.png"
			},
			{
				name="addtile",type=1,typeName="Image",time=86771379,x=-8,y=-3,width=26,height=26,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="friends/addtile.png",
				{
					name="newnum",type=4,typeName="Text",time=88843482,x=3,y=-3,width=12,height=12,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=12,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[0]]
				}
			}
		},
		{
			name="friends_title_select",type=0,typeName="RadioButtonGroup",time=86840561,x=0,y=0,width=372,height=65,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop
		}
	},
	{
		name="friends_list_view",type=0,typeName="View",time=86773966,x=0,y=0,width=480,height=800,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,
		{
			name="friends_menu_bg",type=1,typeName="Image",time=86775492,x=0,y=0,width=480,height=90,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignBottomLeft,file="friends/friendsmenubg.png",
			{
				name="friends_btn",type=2,typeName="Button",time=88397342,x=-150,y=10,width=146,height=58,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="friends/rankingbtn_press.png",
				{
					name="friends",type=1,typeName="Image",time=88397357,x=0,y=0,width=58,height=31,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="friends/friends.png"
				},
				{
					name="friends_press",type=1,typeName="Image",time=88397359,x=0,y=0,width=58,height=31,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="friends/friends_press.png"
				},
				{
					name="friends_newadd_num",type=4,typeName="Text",time=88397397,x=49,y=0,width=36,height=24,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=20,textAlign=kAlignLeft,colorRed=125,colorGreen=70,colorBlue=30,string=[[+0]]
				}
			},
			{
				name="att_btn",type=2,typeName="Button",time=88397798,x=0,y=10,width=146,height=58,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="friends/btn_normal.png",
				{
					name="attention",type=1,typeName="Image",time=88397801,x=0,y=0,width=58,height=31,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="friends/attention.png"
				},
				{
					name="attention_press",type=1,typeName="Image",time=88397803,x=0,y=0,width=58,height=31,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="friends/attention_press.png"
				}
			},
			{
				name="fans_btn",type=2,typeName="Button",time=88397948,x=150,y=10,width=146,height=58,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="friends/btn_normal.png",
				{
					name="fans",type=1,typeName="Image",time=88397953,x=0,y=0,width=58,height=31,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="friends/fans.png"
				},
				{
					name="fans_press",type=1,typeName="Image",time=88397955,x=0,y=0,width=58,height=31,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="friends/fans_press.png"
				},
				{
					name="fans_newadd_num",type=4,typeName="Text",time=88397957,x=48,y=0,width=36,height=24,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=20,textAlign=kAlignLeft,colorRed=80,colorGreen=190,colorBlue=130,string=[[+0]]
				}
			}
		},
		{
			name="friends_list",type=0,typeName="ListView",time=86858133,x=0,y=80,width=480,height=640,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTop,
			{
				name="friends_num",type=4,typeName="Text",time=89438182,x=0,y=5,width=60,height=20,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=20,textAlign=kAlignLeft,colorRed=100,colorGreen=100,colorBlue=100,string=[[好友：]]
			}
		},
		{
			name="fans_list",type=0,typeName="ListView",time=86858182,x=0,y=80,width=450,height=640,visible=0,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTop,
			{
				name="fans_num",type=4,typeName="Text",time=89441765,x=0,y=5,width=30,height=12,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=20,textAlign=kAlignLeft,colorRed=100,colorGreen=100,colorBlue=100,string=[[粉丝：]]
			}
		},
		{
			name="attention_list",type=0,typeName="ListView",time=86858213,x=0,y=80,width=450,height=640,visible=0,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTop,
			{
				name="follow_num",type=4,typeName="Text",time=89441768,x=0,y=5,width=30,height=12,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=20,textAlign=kAlignLeft,colorRed=100,colorGreen=100,colorBlue=100,string=[[关注：]]
			}
		}
	},
	{
		name="ranking_list_view",type=0,typeName="View",time=86773992,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
		{
			name="friendsranking_menu_bg",type=1,typeName="Image",time=86841369,x=0,y=0,width=480,height=90,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignBottomLeft,file="friends/friendsmenubg.png",
			{
				name="friendslist_btn",type=2,typeName="Button",time=88394160,x=-150,y=10,width=146,height=58,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="friends/rankingbtn_press.png",
				{
					name="friendslist",type=1,typeName="Image",time=88394309,x=32,y=15,width=83,height=31,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="friends/friendslist.png"
				},
				{
					name="friendslist_press",type=1,typeName="Image",time=88394311,x=32,y=15,width=83,height=31,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="friends/friendslist_press.png"
				}
			},
			{
				name="charmlist_btn",type=2,typeName="Button",time=88394927,x=0,y=10,width=146,height=58,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="friends/btn_normal.png",
				{
					name="charmlist",type=1,typeName="Image",time=88394938,x=32,y=15,width=83,height=31,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="friends/charmlist.png"
				},
				{
					name="charmlist_press",type=1,typeName="Image",time=88394940,x=32,y=15,width=83,height=31,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="friends/charmlist_press.png"
				}
			},
			{
				name="masterlist_btn",type=2,typeName="Button",time=88395196,x=150,y=10,width=146,height=58,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="friends/btn_normal.png",
				{
					name="masterlist",type=1,typeName="Image",time=88395199,x=32,y=15,width=83,height=31,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="friends/masterlist.png"
				},
				{
					name="masterlist_press",type=1,typeName="Image",time=88395202,x=32,y=15,width=83,height=31,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="friends/masterlist_press.png"
				}
			}
		},
		{
			name="friendslist_view",type=0,typeName="ListView",time=88133648,x=0,y=80,width=480,height=640,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTop
		},
		{
			name="charmlist_view",type=0,typeName="ListView",time=88133661,x=0,y=80,width=450,height=640,visible=0,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTop
		},
		{
			name="masterlist_view",type=0,typeName="ListView",time=88133663,x=0,y=80,width=450,height=640,visible=0,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTop
		},
		{
			name="my_rank_bg",type=1,typeName="Image",time=93430784,x=0,y=82,width=456,height=93,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="friends/my_rank_bg.png",gridLeft=15,gridRight=15,gridTop=15,gridBottom=15,
			{
				name="icon_frame",type=1,typeName="Image",time=93431041,x=17,y=9,width=74,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="friends/friend_icon_frame.png"
			},
			{
				name="name",type=4,typeName="Text",time=93431100,x=104,y=8,width=200,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=28,textAlign=kAlignLeft,colorRed=255,colorGreen=230,colorBlue=180,string=[[加载中...]]
			},
			{
				name="num",type=4,typeName="Text",time=93431186,x=105,y=44,width=200,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=20,textAlign=kAlignLeft,colorRed=185,colorGreen=155,colorBlue=110,string=[[加载中...]]
			},
			{
				name="rank_icon",type=1,typeName="Image",time=93431272,x=334,y=4,width=88,height=88,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="friends/my_rank_icon.png",
				{
					name="my_rank_text",type=4,typeName="Text",time=93431328,x=0,y=2,width=100,height=80,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=24,textAlign=kAlignCenter,colorRed=160,colorGreen=10,colorBlue=10,string=[[0]]
				}
			}
		}
	}
}