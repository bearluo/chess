dapu_create_endgate_view=
{
	name="dapu_create_endgate_view",type=0,typeName="View",time=0,x=0,y=0,width=480,height=800,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="bg_img",type=1,typeName="Image",time=90469073,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="common/background/room_bg.png"
	},
	{
		name="title_view",type=0,typeName="View",time=90469149,x=0,y=64,width=200,height=100,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
		{
			name="title_bg",type=1,typeName="Image",time=90469254,x=0,y=0,width=476,height=102,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/background/create_endgate_title_bg.png",
			{
				name="title3",type=4,typeName="Text",time=91513451,x=0,y=0,width=318,height=68,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=48,textAlign=kAlignCenter,colorRed=240,colorGreen=230,colorBlue=210,string=[[创建残局]]
			}
		}
	},
	{
		name="room_time_bg",type=1,typeName="Image",time=91522721,x=-200,y=0,width=82,height=53,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="online/room/time_bg.png",gridLeft=16,gridRight=16,gridTop=0,gridBottom=0,
		{
			name="room_time",type=4,typeName="Text",time=91522722,x=0,y=9,width=60,height=24,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=24,textAlign=kAlignCenter,colorRed=185,colorGreen=140,colorBlue=105,string=[[00:00]]
		}
	},
	{
		name="content_view",type=0,typeName="View",time=90469673,x=0,y=144,width=720,height=800,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
		{
			name="chess_board",type=1,typeName="Image",time=90469717,x=0,y=0,width=720,height=868,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="chess_board.png",packFile="config/boardres.lua"
		}
	},
	{
		name="chess_box_view",type=0,typeName="View",time=90484918,x=0,y=1033,width=701,height=204,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
		{
			name="chess_box_bg",type=1,typeName="Image",time=90469918,x=-2,y=8,width=701,height=204,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="dapu/chess_box_bg.png"
		},
		{
			name="chess_rpawn",type=0,typeName="View",time=90485030,x=59,y=102,width=60,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
			{
				name="num",type=1,typeName="Image",time=92399401,x=-10,y=-9,width=27,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="online/room/userinfo/dead_num_bg.png",
				{
					name="Text1",type=4,typeName="Text",time=100755822,x=1,y=-2,width=11,height=22,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignLeft,colorRed=235,colorGreen=180,colorBlue=140,string=[[0]]
				}
			},
			{
				name="view",type=0,typeName="View",time=100779438,x=0,y=0,width=200,height=150,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter
			}
		},
		{
			name="chess_rcannon",type=0,typeName="View",time=100760429,x=163,y=102,width=64,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
			{
				name="num",type=1,typeName="Image",time=100760432,x=-10,y=-9,width=27,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="online/room/userinfo/dead_num_bg.png",
				{
					name="Text1",type=4,typeName="Text",time=100760433,x=1,y=-2,width=11,height=22,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignLeft,colorRed=235,colorGreen=180,colorBlue=140,string=[[0]]
				}
			},
			{
				name="view1",type=0,typeName="View",time=100779460,x=0,y=0,width=200,height=150,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter
			}
		},
		{
			name="chess_rrook",type=0,typeName="View",time=100760722,x=267,y=102,width=64,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
			{
				name="num",type=1,typeName="Image",time=100760725,x=-10,y=-9,width=27,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="online/room/userinfo/dead_num_bg.png",
				{
					name="Text1",type=4,typeName="Text",time=100760726,x=1,y=-2,width=11,height=22,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignLeft,colorRed=235,colorGreen=180,colorBlue=140,string=[[0]]
				}
			},
			{
				name="view2",type=0,typeName="View",time=100779463,x=0,y=0,width=200,height=150,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter
			}
		},
		{
			name="chess_rhorse",type=0,typeName="View",time=100760785,x=371,y=102,width=64,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
			{
				name="num",type=1,typeName="Image",time=100760788,x=-10,y=-9,width=27,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="online/room/userinfo/dead_num_bg.png",
				{
					name="Text1",type=4,typeName="Text",time=100760789,x=1,y=-2,width=11,height=22,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignLeft,colorRed=235,colorGreen=180,colorBlue=140,string=[[0]]
				}
			},
			{
				name="view3",type=0,typeName="View",time=100779466,x=0,y=0,width=200,height=150,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter
			}
		},
		{
			name="chess_relephant",type=0,typeName="View",time=100760897,x=476,y=102,width=64,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
			{
				name="num",type=1,typeName="Image",time=100760900,x=-10,y=-9,width=27,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="online/room/userinfo/dead_num_bg.png",
				{
					name="Text1",type=4,typeName="Text",time=100760901,x=1,y=-2,width=11,height=22,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignLeft,colorRed=235,colorGreen=180,colorBlue=140,string=[[0]]
				}
			},
			{
				name="view4",type=0,typeName="View",time=100779468,x=0,y=0,width=200,height=150,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter
			}
		},
		{
			name="chess_rbishop",type=0,typeName="View",time=100764256,x=580,y=102,width=64,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
			{
				name="num",type=1,typeName="Image",time=100764259,x=-10,y=-9,width=27,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="online/room/userinfo/dead_num_bg.png",
				{
					name="Text1",type=4,typeName="Text",time=100764260,x=1,y=-2,width=11,height=22,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignLeft,colorRed=235,colorGreen=180,colorBlue=140,string=[[0]]
				}
			}
		},
		{
			name="chess_bpawn",type=0,typeName="View",time=100764438,x=57,y=25,width=64,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
			{
				name="num",type=1,typeName="Image",time=100764441,x=-10,y=-9,width=27,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="online/room/userinfo/dead_num_bg.png",
				{
					name="Text1",type=4,typeName="Text",time=100764442,x=1,y=-2,width=11,height=22,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignLeft,colorRed=235,colorGreen=180,colorBlue=140,string=[[0]]
				}
			}
		},
		{
			name="chess_bcannon",type=0,typeName="View",time=100764507,x=161,y=25,width=64,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
			{
				name="num",type=1,typeName="Image",time=100764510,x=-10,y=-9,width=27,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="online/room/userinfo/dead_num_bg.png",
				{
					name="Text1",type=4,typeName="Text",time=100764511,x=1,y=-2,width=11,height=22,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignLeft,colorRed=235,colorGreen=180,colorBlue=140,string=[[0]]
				}
			}
		},
		{
			name="chess_brook",type=0,typeName="View",time=100764561,x=267,y=25,width=64,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
			{
				name="num",type=1,typeName="Image",time=100764564,x=-10,y=-9,width=27,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="online/room/userinfo/dead_num_bg.png",
				{
					name="Text1",type=4,typeName="Text",time=100764565,x=1,y=-2,width=11,height=22,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignLeft,colorRed=235,colorGreen=180,colorBlue=140,string=[[0]]
				}
			}
		},
		{
			name="chess_bhorse",type=0,typeName="View",time=100764783,x=372,y=25,width=64,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
			{
				name="num",type=1,typeName="Image",time=100764786,x=-10,y=-9,width=27,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="online/room/userinfo/dead_num_bg.png",
				{
					name="Text1",type=4,typeName="Text",time=100764787,x=1,y=-2,width=11,height=22,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignLeft,colorRed=235,colorGreen=180,colorBlue=140,string=[[0]]
				}
			}
		},
		{
			name="chess_belephant",type=0,typeName="View",time=100764912,x=475,y=25,width=64,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
			{
				name="num",type=1,typeName="Image",time=100764915,x=-10,y=-9,width=27,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="online/room/userinfo/dead_num_bg.png",
				{
					name="Text1",type=4,typeName="Text",time=100764916,x=1,y=-2,width=11,height=22,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignLeft,colorRed=235,colorGreen=180,colorBlue=140,string=[[0]]
				}
			}
		},
		{
			name="chess_bbishop",type=0,typeName="View",time=100764954,x=580,y=25,width=64,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
			{
				name="num",type=1,typeName="Image",time=100764957,x=-10,y=-9,width=27,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="online/room/userinfo/dead_num_bg.png",
				{
					name="Text1",type=4,typeName="Text",time=100764958,x=1,y=-2,width=11,height=22,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=22,textAlign=kAlignLeft,colorRed=235,colorGreen=180,colorBlue=140,string=[[0]]
				}
			}
		}
	},
	{
		name="mask",type=1,typeName="Image",time=108530394,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="drawable/blank.png"
	},
	{
		name="back_btn",type=2,typeName="Button",time=100754522,x=23,y=22,width=86,height=91,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="common/button/back_btn.png",file2="common/button/back_btn_press.png"
	},
	{
		name="release_btn",type=2,typeName="Button",time=100841986,x=302,y=18,width=90,height=90,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/button/release_nor.png",file2="common/button/release_pre.png"
	},
	{
		name="top_view",type=0,typeName="View",time=90469759,x=110,y=0,width=206,height=135,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
		{
			name="undo_btn",type=2,typeName="Button",time=90470995,x=0,y=0,width=84,height=84,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/button/revoke_2_nor.png",file2="common/button/revoke_2_pre.png",gridLeft=10,gridRight=10,gridTop=10,gridBottom=10
		},
		{
			name="menu_btn",type=2,typeName="Button",time=108529086,x=0,y=0,width=84,height=84,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="online/room/menu_3_nor.png",file2="online/room/menu_3_pre.png"
		},
		{
			name="menu_bg",type=1,typeName="Image",time=108529381,x=-30,y=133,width=380,height=214,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/background/menu_bg.png",
			{
				name="clear_all_btn",type=2,typeName="Button",time=90470487,x=80,y=41,width=90,height=130,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/button/empty_nor.png",file2="common/button/empty_pre.png"
			},
			{
				name="full_btn",type=2,typeName="Button",time=90470719,x=-80,y=41,width=90,height=130,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/button/full_nor.png",file2="common/button/full_pre.png"
			}
		}
	}
}