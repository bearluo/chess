console_boss_view=
{
	name="console_boss_view",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,
	{
		name="bg",type=1,typeName="Image",time=100683014,x=0,y=0,width=378,height=775,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="console/console_boss_bg.png",
		{
			name="boss_img",type=0,typeName="View",time=100683233,x=-2,y=69,width=310,height=470,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
			{
				name="img",type=1,typeName="Image",time=100683390,x=0,y=0,width=310,height=470,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="console/console_boss_1.png"
			}
		},
		{
			name="boss_name",type=0,typeName="View",time=100683260,x=0,y=145,width=240,height=70,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,
			{
				name="name",type=1,typeName="Image",time=100683520,x=0,y=0,width=240,height=62,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="console/gate_name1.png"
			}
		},
		{
			name="boss_zhanji",type=0,typeName="View",time=100683294,x=0,y=95,width=300,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,
			{
				name="zhanji",type=4,typeName="Text",time=100683805,x=0,y=0,width=280,height=150,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,fontSize=28,textAlign=kAlignCenter,colorRed=64,colorGreen=106,colorBlue=59,string=[[]]
			}
		}
	},
	{
		name="lock_bg",type=1,typeName="Image",time=100950733,x=0,y=0,width=378,height=775,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopLeft,file="console/locked.png"
	}
}