watch_list_dialog=
{
	name="watch_list_dialog",type=0,typeName="View",time=0,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="bg",type=1,typeName="Image",time=137556791,x=0,y=127,width=674,height=1030,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/background/chatroom_bg_2.png",
		{
			name="tab_bg",type=1,typeName="Image",time=137557061,x=0,y=29,width=496,height=72,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/background/tab_bg_2.png",gridLeft=50,gridRight=50,gridTop=0,gridBottom=0,
			{
				name="tab_icon",type=1,typeName="Image",time=137557556,x=7,y=4,width=237,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/button/small_btn_1.png",gridLeft=63,gridRight=63,gridTop=0,gridBottom=0
			},
			{
				name="follow_btn",type=2,typeName="Button",time=137557704,x=0,y=0,width=248,height=71,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="drawable/blank.png",
				{
					name="txt",type=4,typeName="Text",time=137557693,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=32,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[我的关注]]
				}
			},
			{
				name="master_btn",type=2,typeName="Button",time=137563801,x=0,y=0,width=248,height=71,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="drawable/blank.png",
				{
					name="txt",type=4,typeName="Text",time=137563802,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=32,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[大师对局]]
				}
			}
		},
		{
			name="watch_list",type=0,typeName="View",time=137582966,x=0,y=133,width=674,height=851,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
			{
				name="follow_list",type=0,typeName="ListView",time=137573826,x=12,y=0,width=650,height=851,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft
			},
			{
				name="master_list",type=0,typeName="ListView",time=137583054,x=12,y=0,width=650,height=851,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft
			},
			{
				name="no_follow_view",type=0,typeName="View",time=137657137,x=0,y=0,width=650,height=851,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
				{
					name="Image1",type=1,typeName="Image",time=137657140,x=0,y=224,width=286,height=260,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/decoration/player.png"
				},
				{
					name="Text21",type=4,typeName="Text",time=137657393,x=3,y=451,width=688,height=150,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=32,textAlign=kAlignCenter,colorRed=170,colorGreen=135,colorBlue=100,string=[[暂时没有好友对局]]
				},
				{
					name="Text211",type=4,typeName="Text",time=137657393,x=3,y=491,width=688,height=150,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=32,textAlign=kAlignCenter,colorRed=170,colorGreen=135,colorBlue=100,string=[[先去看看精彩的大师对弈吧]]
				}
			},
			{
				name="no_master_view",type=0,typeName="View",time=137657445,x=0,y=0,width=650,height=851,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
				{
					name="Image1",type=1,typeName="Image",time=137657446,x=0,y=224,width=286,height=260,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/decoration/player.png"
				},
				{
					name="Text211",type=4,typeName="Text",time=137657448,x=3,y=491,width=688,height=150,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=32,textAlign=kAlignCenter,colorRed=170,colorGreen=135,colorBlue=100,string=[[自己来一盘吧]]
				},
				{
					name="Text2111",type=4,typeName="Text",time=137657493,x=3,y=451,width=688,height=150,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=32,textAlign=kAlignCenter,colorRed=170,colorGreen=135,colorBlue=100,string=[[暂时没有大师用户在对局]]
				}
			}
		},
		{
			name="Image2",type=1,typeName="Image",time=137564673,x=0,y=133,width=626,height=1,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/decoration/line_9.png"
		},
		{
			name="Image3",type=1,typeName="Image",time=137573889,x=0,y=0,width=674,height=80,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="common/decoration/mask_3.png"
		}
	},
	{
		name="back_btn",type=2,typeName="Button",time=137556871,x=26,y=36,width=60,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottomLeft,file="common/button/hide_dialog_btn.png"
	}
}