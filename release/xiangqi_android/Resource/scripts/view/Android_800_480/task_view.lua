task_view=
{
	name="task_view",type=0,typeName="View",time=0,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="bg",type=1,typeName="Image",time=106294270,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTop,file="common/background/model_bg.png"
	},
	{
		name="top_view",type=0,typeName="View",time=106294519,x=0,y=0,width=200,height=206,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTop,
		{
			name="top_board",type=1,typeName="Image",time=106294526,x=0,y=0,width=720,height=106,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTop,file="common/background/title_bg.png"
		},
		{
			name="top_title_bg",type=1,typeName="Image",time=106294527,x=0,y=0,width=484,height=132,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/decoration/top_cloth.png",
			{
				name="top_title",type=1,typeName="Image",time=106294528,x=0,y=26,width=208,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="dailytask/daily_task_choose.png"
			}
		},
		{
			name="refresh_bg",type=1,typeName="Image",time=117875995,x=284,y=-20,width=82,height=150,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/decoration/top_cloth_5.png",
			{
				name="refresh_btn",type=2,typeName="Button",time=111312747,x=0,y=36,width=80,height=84,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/button/reflash_btn.png",file2="common/button/reflash_btn_press.png"
			}
		}
	},
	{
		name="btns_content",type=0,typeName="View",time=122702423,x=0,y=156,width=640,height=71,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
		{
			name="daily",type=0,typeName="View",time=122702430,x=0,y=0,width=320,height=150,visible=1,fillParentWidth=0,fillParentHeight=1,nodeAlign=kAlignLeft,
			{
				name="bg",type=1,typeName="Image",time=122702431,x=0,y=0,width=210,height=150,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="replay/btn_bg.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20
			},
			{
				name="btn",type=2,typeName="Button",time=122702432,x=0,y=0,width=214,height=71,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTop,file="drawable/blank.png",
				{
					name="btn_txt",type=4,typeName="Text",time=122702433,x=0,y=0,width=144,height=36,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=36,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[每日任务]]
				},
				{
					name="hint",type=1,typeName="Image",time=122712818,x=20,y=3,width=22,height=26,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="dailytask/redPoint.png"
				}
			},
			{
				name="select_line",type=1,typeName="Image",time=122702435,x=0,y=0,width=140,height=4,visible=0,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignBottom,file="drawable/blank_red.png"
			}
		},
		{
			name="grow",type=0,typeName="View",time=122702436,x=2,y=0,width=320,height=150,visible=1,fillParentWidth=0,fillParentHeight=1,nodeAlign=kAlignRight,
			{
				name="bg",type=1,typeName="Image",time=122702437,x=0,y=0,width=210,height=150,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="replay/btn_bg.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20
			},
			{
				name="btn",type=2,typeName="Button",time=122702438,x=0,y=0,width=320,height=71,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTop,file="drawable/blank.png",
				{
					name="btn_txt",type=4,typeName="Text",time=122702439,x=0,y=0,width=144,height=36,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=36,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[成长任务]]
				},
				{
					name="hint",type=1,typeName="Image",time=138162021,x=20,y=3,width=22,height=26,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="dailytask/redPoint.png"
				}
			},
			{
				name="select_line",type=1,typeName="Image",time=122702441,x=0,y=0,width=140,height=4,visible=0,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignBottom,file="drawable/blank_red.png"
			}
		}
	},
	{
		name="leaf_left",type=1,typeName="Image",time=106294566,x=0,y=0,width=78,height=163,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="common/decoration/bamboo_left.png"
	},
	{
		name="leaf_right",type=1,typeName="Image",time=106294576,x=0,y=0,width=77,height=137,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="common/decoration/bamboo_right.png"
	},
	{
		name="stone_dec",type=1,typeName="Image",time=106294593,x=0,y=229,width=26,height=32,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="common/decoration/stone_dec.png"
	},
	{
		name="teapot_dec",type=1,typeName="Image",time=106294605,x=0,y=195,width=85,height=252,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottomLeft,file="common/decoration/teapot_dec.png"
	},
	{
		name="back_btn",type=2,typeName="Button",time=106294507,x=20,y=20,width=86,height=91,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="common/button/back_btn.png",file2="common/button/back_btn_press.png"
	},
	{
		name="daily_task_view",type=0,typeName="View",time=111219940,x=0,y=0,width=640,height=1040,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom
	},
	{
		name="grow_task_view",type=0,typeName="View",time=122703153,x=0,y=0,width=640,height=1040,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom
	}
}