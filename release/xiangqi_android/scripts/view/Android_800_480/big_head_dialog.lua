big_head_dialog=
{
	name="big_head_dialog",type=0,typeName="View",time=0,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="bg",type=1,typeName="Image",time=98005795,x=0,y=0,width=720,height=610,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignBottom,file="common/background/dialog_bg_1.png",gridLeft=128,gridRight=128,gridTop=128,gridBottom=128,
		{
			name="save_btn",type=2,typeName="Button",time=98005897,x=0,y=198,width=571,height=97,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/button/dialog_btn_6_normal.png",file2="common/button/dialog_btn_6_press.png",
			{
				name="text",type=4,typeName="Text",time=98005965,x=0,y=0,width=200,height=150,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=38,textAlign=kAlignCenter,colorRed=240,colorGreen=230,colorBlue=210,string=[[保存图片]]
			}
		},
		{
			name="icon_bg",type=1,typeName="Image",time=98005961,x=0,y=-62,width=270,height=270,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/background/head_bg_270.png",
			{
				name="icon_mask",type=1,typeName="Image",time=98006508,x=0,y=0,width=260,height=260,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/background/head_mask_bg_260.png"
			}
		},
		{
			name="loading",type=1,typeName="Image",time=98007495,x=0,y=-59,width=100,height=100,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="drawable/loading.png"
		},
		{
			name="close_btn",type=2,typeName="Button",time=102136496,x=43,y=47,width=60,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="common/button/btn_close.png"
		}
	}
}