thansize_dialog_view=
{
	name="thansize_dialog_view",type=0,typeName="View",time=0,x=0,y=0,width=480,height=800,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="bgview",type=0,typeName="View",time=143886745,x=0,y=951,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTop,
		{
			name="bgTexture",type=0,typeName="View",time=143886821,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTopLeft,
			{
				name="jiantou",type=1,typeName="Image",time=144485187,x=176,y=176,width=24,height=14,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="littlegame/thansizexiaoyouxijiantou.png"
			},
			{
				name="bg",type=1,typeName="Image",time=143886838,x=0,y=0,width=720,height=183,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="littlegame/thansizebg.png"
			},
			{
				name="Image8",type=1,typeName="Image",time=144986529,x=0,y=0,width=73,height=183,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="littlegame/thansizewanfawenzi.png"
			},
			{
				name="erxunyi",type=1,typeName="Image",time=144325174,x=14,y=35,width=41,height=106,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="littlegame/thansizeerxuanyi.png"
			},
			{
				name="vs",type=1,typeName="Image",time=144385480,x=33,y=54,width=74,height=47,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="littlegame/thansizevs.png"
			},
			{
				name="redciclered",type=1,typeName="Image",time=143888156,x=-113,y=-1,width=191,height=151,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="littlegame/thansizexuanzhongguang.png",gridLeft=30,gridRight=30,gridTop=30,gridBottom=30
			},
			{
				name="redcicleblack",type=1,typeName="Image",time=143888158,x=173,y=-1,width=191,height=151,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="littlegame/thansizexuanzhongguang.png",gridLeft=30,gridRight=30,gridTop=30,gridBottom=30
			},
			{
				name="Image10",type=1,typeName="Image",time=144988323,x=172,y=17,width=151,height=114,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="littlegame/thansizeredpiecebg.png",gridLeft=12,gridRight=12,gridTop=12,gridBottom=12
			},
			{
				name="Image9",type=1,typeName="Image",time=144986612,x=-113,y=17,width=151,height=114,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="littlegame/thansizeblackpiecebg.png",gridLeft=12,gridRight=12,gridTop=12,gridBottom=12
			}
		},
		{
			name="bgText",type=0,typeName="View",time=143886989,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
			{
				name="Text4",type=4,typeName="Text",time=143887295,x=32,y=142,width=312,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=18,textAlign=kAlignCenter,colorRed=82,colorGreen=39,colorBlue=15,string=[[玩法：将>士>象>车>马>炮>兵]]
			}
		},
		{
			name="ButtonRed",type=2,typeName="Button",time=143887623,x=-111,y=26,width=110,height=110,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/button/piece_btn.png",
			{
				name="piece",type=1,typeName="Image",time=143891170,x=-1,y=-8,width=82,height=80,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="rrook.png",packFile="config/boardres.lua"
			}
		},
		{
			name="ButtonBlack",type=2,typeName="Button",time=143887615,x=175,y=26,width=110,height=110,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/button/piece_btn.png",
			{
				name="piece",type=1,typeName="Image",time=143891403,x=-1,y=-8,width=82,height=80,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="rbishop.png",packFile="config/boardres.lua"
			}
		},
		{
			name="result",type=0,typeName="View",time=144386226,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
			{
				name="he",type=0,typeName="View",time=144386330,x=0,y=0,width=720,height=1280,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
				{
					name="Image1",type=1,typeName="Image",time=144386431,x=224,y=66,width=344,height=87,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="littlegame/thansizeanse.png"
				},
				{
					name="Image2",type=1,typeName="Image",time=144386517,x=320,y=82,width=108,height=57,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="littlegame/thansizeheju.png"
				}
			},
			{
				name="fail",type=0,typeName="View",time=144386348,x=0,y=0,width=720,height=1280,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
				{
					name="Image3",type=1,typeName="Image",time=144386616,x=224,y=66,width=344,height=87,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="littlegame/thansizeanse.png"
				},
				{
					name="Image4",type=1,typeName="Image",time=144386705,x=293,y=81,width=108,height=57,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="littlegame/thansizeluobai.png"
				},
				{
					name="gold",type=4,typeName="Text",time=144386779,x=343,y=35,width=200,height=150,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=40,textAlign=kAlignCenter,colorRed=227,colorGreen=106,colorBlue=28,string=[[-300]]
				}
			},
			{
				name="win",type=0,typeName="View",time=144386366,x=0,y=0,width=720,height=1280,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
				{
					name="Image6",type=1,typeName="Image",time=144387322,x=149,y=-71,width=469,height=230,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="littlegame/thansizeguang.png"
				},
				{
					name="Image5",type=1,typeName="Image",time=144387251,x=224,y=66,width=344,height=87,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="littlegame/thansizehuoshengbeijing.png"
				},
				{
					name="Image7",type=1,typeName="Image",time=144387466,x=281,y=81,width=108,height=57,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="littlegame/thansizehusheng.png"
				},
				{
					name="gold",type=4,typeName="Text",time=144387567,x=339,y=36,width=200,height=150,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,fontSize=40,textAlign=kAlignCenter,colorRed=227,colorGreen=106,colorBlue=28,string=[[+300]]
				}
			}
		}
	}
}