evaluate_dialog=
{
	name="evaluate_dialog",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="bg",type=1,typeName="Image",time=131102339,x=0,y=-88,width=620,height=470,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/background/dialog_bg_2.png",gridLeft=50,gridRight=50,gridTop=50,gridBottom=50,
		{
			name="l_cloud",type=1,typeName="Image",time=131103014,x=-180,y=120,width=170,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/decoration/cloud_2.png"
		},
		{
			name="r_cloud",type=1,typeName="Image",time=131103024,x=180,y=120,width=170,height=34,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/decoration/cloud_1.png"
		},
		{
			name="logo",type=1,typeName="Image",time=131103159,x=0,y=44,width=130,height=130,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/icon/logo.png"
		},
		{
			name="txt1",type=4,typeName="Text",time=131103330,x=15,y=0,width=620,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=60,textAlign=kAlignCenter,colorRed=255,colorGreen=40,colorBlue=40,string=[[喜欢这款游戏吗？]]
		},
		{
			name="txt2",type=4,typeName="Text",time=131103392,x=0,y=70,width=620,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=32,textAlign=kAlignCenter,colorRed=80,colorGreen=80,colorBlue=80,string=[[您的鼓励是我们更大的动力]]
		},
		{
			name="sug_btn",type=2,typeName="Button",time=131103695,x=68,y=40,width=218,height=79,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottomLeft,file="common/button/dialog_btn_7_normal.png",file2="common/button/dialog_btn_7_press.png",gridLeft=10,gridRight=10,gridTop=10,gridBottom=10,
			{
				name="txt",type=4,typeName="Text",time=131104140,x=0,y=-3,width=200,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=38,textAlign=kAlignCenter,colorRed=240,colorGreen=230,colorBlue=210,string=[[我有建议]]
			}
		},
		{
			name="eva_btn",type=2,typeName="Button",time=131103697,x=68,y=40,width=218,height=79,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottomRight,file="common/button/dialog_btn_3_normal.png",file2="common/button/dialog_btn_3_press.png",gridLeft=10,gridRight=10,gridTop=10,gridBottom=10,
			{
				name="txt",type=4,typeName="Text",time=131104243,x=0,y=-3,width=200,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=38,textAlign=kAlignCenter,colorRed=240,colorGreen=230,colorBlue=210,string=[[写评论]]
			}
		},
		{
			name="cls_btn",type=2,typeName="Button",time=131104282,x=30,y=-40,width=44,height=52,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="common/button/close_btn.png"
		}
	}
}