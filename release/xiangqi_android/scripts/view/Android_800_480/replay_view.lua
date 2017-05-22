replay_view=
{
	name="replay_view",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="replay_view_bg",type=1,typeName="Image",time=2185898,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="common/background/model_bg.png",gridLeft=0,gridRight=0,gridTop=0,gridBottom=32
	},
	{
		name="title_content",type=0,typeName="View",time=94470929,x=0,y=0,width=200,height=130,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTop,
		{
			name="title_bg",type=1,typeName="Image",time=94471282,x=0,y=0,width=720,height=106,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="common/background/title_bg.png"
		},
		{
			name="title_subbg",type=1,typeName="Image",time=94471338,x=0,y=0,width=484,height=132,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/decoration/top_cloth_blue.png",
			{
				name="title",type=1,typeName="Image",time=111656785,x=0,y=-16,width=212,height=54,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="replay/replay_title.png"
			}
		},
		{
			name="clear_all_bg",type=1,typeName="Image",time=111645112,x=39,y=-20,width=82,height=150,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="common/decoration/top_cloth_5.png",
			{
				name="clear_all_btn",type=2,typeName="Button",time=111641580,x=0,y=20,width=84,height=90,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="replay/clear_all_nor.png",file2="replay/clear_all_pres.png"
			}
		}
	},
	{
		name="btns_content",type=0,typeName="View",time=111641132,x=0,y=143,width=630,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
		{
			name="replay_btn",type=0,typeName="View",time=111642004,x=0,y=0,width=210,height=165,visible=1,fillParentWidth=0,fillParentHeight=1,nodeAlign=kAlignLeft,
			{
				name="bg",type=1,typeName="Image",time=111642038,x=0,y=0,width=210,height=112,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="replay/btn_bg.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20
			},
			{
				name="btn",type=2,typeName="Button",time=111641569,x=0,y=0,width=195,height=102,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="ui/button.png",
				{
					name="btn_txt",type=4,typeName="Text",time=111642424,x=0,y=15,width=144,height=36,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=36,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[]]
				}
			},
			{
				name="tips",type=4,typeName="Text",time=111642071,x=0,y=9,width=70,height=28,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,fontSize=28,textAlign=kAlignCenter,colorRed=100,colorGreen=100,colorBlue=100,string=[[]]
			},
			{
				name="select_line",type=1,typeName="Image",time=111643143,x=0,y=0,width=140,height=4,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignBottom,file="drawable/blank_red.png"
			}
		},
		{
			name="dapu_btn",type=0,typeName="View",time=111643288,x=-1,y=0,width=210,height=150,visible=1,fillParentWidth=0,fillParentHeight=1,nodeAlign=kAlignCenter,
			{
				name="bg",type=1,typeName="Image",time=111643289,x=0,y=0,width=210,height=150,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="replay/btn_bg.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20
			},
			{
				name="btn",type=2,typeName="Button",time=111643290,x=0,y=0,width=210,height=100,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTop,file="ui/button.png",
				{
					name="btn_txt",type=4,typeName="Text",time=111643291,x=0,y=15,width=144,height=36,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=36,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[]]
				}
			},
			{
				name="tips",type=4,typeName="Text",time=111643292,x=0,y=9,width=70,height=28,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,fontSize=28,textAlign=kAlignCenter,colorRed=100,colorGreen=100,colorBlue=100,string=[[]]
			},
			{
				name="select_line",type=1,typeName="Image",time=111643293,x=0,y=0,width=140,height=4,visible=0,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignBottom,file="drawable/blank_red.png"
			}
		},
		{
			name="suggest_btn",type=0,typeName="View",time=111643321,x=2,y=0,width=211,height=150,visible=1,fillParentWidth=0,fillParentHeight=1,nodeAlign=kAlignRight,
			{
				name="bg",type=1,typeName="Image",time=111643322,x=0,y=0,width=210,height=150,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="replay/btn_bg.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20
			},
			{
				name="btn",type=2,typeName="Button",time=111643323,x=14,y=0,width=211,height=112,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTop,file="ui/button.png",
				{
					name="btn_txt",type=4,typeName="Text",time=111643324,x=0,y=15,width=144,height=36,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=36,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[]]
				}
			},
			{
				name="tips",type=4,typeName="Text",time=111643325,x=0,y=9,width=112,height=28,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,fontSize=28,textAlign=kAlignCenter,colorRed=100,colorGreen=100,colorBlue=100,string=[[]]
			},
			{
				name="select_line",type=1,typeName="Image",time=111643326,x=0,y=0,width=140,height=4,visible=0,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignBottom,file="drawable/blank_red.png"
			}
		}
	},
	{
		name="replay_content",type=0,typeName="View",time=94460741,x=0,y=0,width=630,height=1020,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,
		{
			name="replayList_view",type=0,typeName="ListView",time=94460646,x=0,y=0,width=630,height=1020,visible=1,fillParentWidth=0,fillParentHeight=1,nodeAlign=kAlignTop
		},
		{
			name="enpty_tips",type=5,typeName="TextView",time=111831871,x=0,y=300,width=495,height=180,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=35,textAlign=kAlignTop,colorRed=120,colorGreen=85,colorBlue=65,string=[[联网对战、观战、单机对局、过关残局都会默认保存在这里]]
		}
	},
	{
		name="dapu_content",type=0,typeName="View",time=94460901,x=0,y=0,width=630,height=1020,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,
		{
			name="dapuList_view",type=0,typeName="ListView",time=94461182,x=0,y=0,width=630,height=1020,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTop
		},
		{
			name="enpty_tips",type=5,typeName="TextView",time=111832117,x=0,y=300,width=558,height=180,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=35,textAlign=kAlignTop,colorRed=120,colorGreen=85,colorBlue=65,string=[[棋谱被收藏后可以一直保留，方便随时演练，喜欢的棋谱要记得收藏哦~]]
		}
	},
	{
		name="suggest_content",type=0,typeName="View",time=111641007,x=0,y=0,width=630,height=1020,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,
		{
			name="suggestList_view",type=0,typeName="ListView",time=111641008,x=0,y=0,width=630,height=950,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTop
		},
		{
			name="enpty_tips",type=5,typeName="TextView",time=111832122,x=0,y=300,width=495,height=180,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=35,textAlign=kAlignTop,colorRed=120,colorGreen=85,colorBlue=65,string=[[暂时没有棋谱被推荐，快去收藏几个好棋谱推荐给好友吧]]
		}
	},
	{
		name="bottom_view",type=0,typeName="View",time=96773412,x=0,y=0,width=720,height=150,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignBottom
	},
	{
		name="tea_dec",type=1,typeName="Image",time=94644293,x=0,y=0,width=85,height=252,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottomLeft,file="common/decoration/teapot_dec.png"
	},
	{
		name="bamboo_left_dec",type=1,typeName="Image",time=94699134,x=-40,y=0,width=131,height=253,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="common/decoration/bamboo_left.png"
	},
	{
		name="stone_dec",type=1,typeName="Image",time=94699008,x=0,y=178,width=26,height=32,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="common/decoration/stone_dec.png"
	},
	{
		name="back_btn",type=2,typeName="Button",time=94471309,x=20,y=20,width=86,height=91,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="common/button/back_btn.png",file2="common/button/back_btn_press.png"
	},
	{
		name="bamboo_right_dec",type=1,typeName="Image",time=94794405,x=0,y=0,width=81,height=152,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="common/decoration/bamboo_right.png"
	},
	{
		name="help_btn",type=2,typeName="Button",time=112342679,x=-144,y=-19,width=82,height=126,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/button/help_nor2.png",file2="common/button/help_pre2.png"
	}
}