ticket_view=
{
	name="ticket_view",type=0,typeName="View",time=0,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTop,
	{
		name="bg",type=1,typeName="Image",time=128924354,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTop,file="common/background/model_bg.png"
	},
	{
		name="View",type=0,typeName="View",time=128924379,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTop,
		{
			name="l_leaf",type=1,typeName="Image",time=128924455,x=0,y=0,width=78,height=163,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="common/decoration/bamboo_left.png"
		},
		{
			name="r_leaf",type=1,typeName="Image",time=128924474,x=0,y=0,width=77,height=137,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="common/decoration/bamboo_right.png"
		},
		{
			name="top_view",type=0,typeName="View",time=128943005,x=0,y=0,width=720,height=150,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
			{
				name="r_cloud",type=1,typeName="Image",time=128924979,x=110,y=68,width=28,height=20,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="relation/l_cloud.png"
			},
			{
				name="l_cloud",type=1,typeName="Image",time=128926598,x=-110,y=68,width=28,height=20,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="relation/l_cloud.png"
			},
			{
				name="line1",type=1,typeName="Image",time=128926661,x=186,y=78,width=124,height=1,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="relation/cloud_line.png"
			},
			{
				name="line2",type=1,typeName="Image",time=128926744,x=-186,y=78,width=124,height=1,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="relation/cloud_line.png"
			},
			{
				name="title",type=4,typeName="Text",time=128926911,x=0,y=0,width=200,height=146,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=42,textAlign=kAlignCenter,colorRed=135,colorGreen=100,colorBlue=95,string=[[参赛券]]
			}
		},
		{
			name="ticket_list",type=0,typeName="View",time=128927070,x=0,y=141,width=640,height=1110,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop
		},
		{
			name="back_btn",type=2,typeName="Button",time=128945703,x=20,y=20,width=86,height=91,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="common/button/back_btn.png",file2="common/button/back_btn_press.png"
		},
		{
			name="tips",type=4,typeName="Text",time=129785640,x=0,y=-40,width=200,height=0,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=30,textAlign=kAlignCenter,colorRed=120,colorGreen=120,colorBlue=120,string=[[暂未得到参赛券]]
		}
	}
}