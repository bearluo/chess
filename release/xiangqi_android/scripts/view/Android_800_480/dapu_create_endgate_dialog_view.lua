dapu_create_endgate_dialog_view=
{
	name="dapu_create_endgate_dialog_view",type=0,typeName="View",time=0,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="bg",type=1,typeName="Image",time=100920274,x=0,y=440,width=613,height=369,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/background/dialog_bg_3.png",gridLeft=128,gridRight=128,gridTop=128,gridBottom=128,
		{
			name="title",type=4,typeName="Text",time=100920372,x=0,y=67,width=300,height=30,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=30,textAlign=kAlignLeft,colorRed=80,colorGreen=80,colorBlue=80,string=[[是否花费500金币发布?]]
		},
		{
			name="edit_bg",type=1,typeName="Image",time=100920978,x=0,y=124,width=523,height=62,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/background/input_bg_2.png",gridLeft=33,gridRight=33,gridTop=0,gridBottom=0,
			{
				name="edit",type=6,typeName="EditText",time=100921605,x=12,y=0,width=510,height=90,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=32,textAlign=kAlignLeft,colorRed=80,colorGreen=80,colorBlue=80,string=[[]]
			}
		},
		{
			name="chioce_cancel_btn",type=2,typeName="Button",time=100921145,x=-140,y=210,width=244,height=85,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/button/dialog_btn_8_normal.png",file2="common/button/dialog_btn_4_press.png",
			{
				name="Text1",type=4,typeName="Text",time=100921552,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=40,textAlign=kAlignLeft,colorRed=240,colorGreen=230,colorBlue=210,string=[[取消]]
			}
		},
		{
			name="chioce_sure_btn",type=2,typeName="Button",time=100921504,x=140,y=210,width=244,height=85,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/button/dialog_btn_4_normal.png",file2="common/button/dialog_btn_4_press.png",
			{
				name="Text11",type=4,typeName="Text",time=100921584,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=40,textAlign=kAlignLeft,colorRed=240,colorGreen=230,colorBlue=210,string=[[发布]]
			}
		}
	}
}