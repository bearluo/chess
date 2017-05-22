city_locate_pop_dialog=
{
	name="city_locate_pop_dialog",type=0,typeName="View",time=0,x=0,y=0,width=480,height=653,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignBottom,
	{
		name="bg",type=1,typeName="Image",time=94701116,x=0,y=0,width=675,height=842,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/background/dialog_bg_new.png",gridLeft=128,gridRight=128,gridTop=128,gridBottom=128,
		{
			name="close_btn",type=2,typeName="Button",time=102138659,x=30,y=60,width=60,height=60,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="common/button/btn_close.png"
		},
		{
			name="locate_fail",type=0,typeName="View",time=136376778,x=0,y=69,width=630,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
			{
				name="txt",type=4,typeName="Text",time=136376693,x=45,y=0,width=140,height=28,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=28,textAlign=kAlignLeft,colorRed=130,colorGreen=100,colorBlue=55,string=[[定位失败！]]
			},
			{
				name="locate",type=2,typeName="Button",time=136376933,x=185,y=0,width=150,height=40,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="drawable/blank.png",
				{
					name="txt",type=4,typeName="Text",time=136376948,x=0,y=0,width=140,height=28,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=28,textAlign=kAlignCenter,colorRed=40,colorGreen=110,colorBlue=165,string=[[请点击重试]]
				},
				{
					name="line",type=1,typeName="Image",time=136377198,x=-4,y=0,width=140,height=1,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="common/green_low_dot.png"
				}
			}
		},
		{
			name="line",type=1,typeName="Image",time=136376624,x=0,y=115,width=580,height=32,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/decoration/new_line.png"
		},
		{
			name="area_txt",type=4,typeName="Text",time=97138464,x=-145,y=155,width=96,height=48,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=48,textAlign=kAlignLeft,colorRed=135,colorGreen=100,colorBlue=55,string=[[地区]]
		},
		{
			name="city_txt",type=4,typeName="Text",time=97138502,x=115,y=155,width=96,height=48,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=48,textAlign=kAlignLeft,colorRed=135,colorGreen=100,colorBlue=55,string=[[城市]]
		},
		{
			name="line1",type=1,typeName="Image",time=136376332,x=0,y=220,width=560,height=2,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/decoration/line_2.png"
		},
		{
			name="area_view",type=0,typeName="View",time=97138136,x=-145,y=10,width=220,height=390,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter
		},
		{
			name="arrow",type=1,typeName="Image",time=136378089,x=-80,y=10,width=16,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/decoration/select_city.png"
		},
		{
			name="city_view",type=0,typeName="View",time=97138223,x=106,y=10,width=349,height=390,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter
		},
		{
			name="down_mask",type=1,typeName="Image",time=97329192,x=0,y=85,width=460,height=170,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/decoration/item_down_mas.png"
		},
		{
			name="up_mask",type=1,typeName="Image",time=97329080,x=0,y=-85,width=460,height=170,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/decoration/item_up_mask.png"
		},
		{
			name="line2",type=1,typeName="Image",time=136377813,x=0,y=214,width=580,height=32,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/decoration/new_line.png"
		},
		{
			name="confirm",type=2,typeName="Button",time=136375858,x=0,y=80,width=444,height=96,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="common/button/long_yellow_btn.png",
			{
				name="txt",type=4,typeName="Text",time=136375889,x=0,y=-2,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=36,textAlign=kAlignCenter,colorRed=95,colorGreen=15,colorBlue=15,string=[[保存]]
			}
		}
	}
}