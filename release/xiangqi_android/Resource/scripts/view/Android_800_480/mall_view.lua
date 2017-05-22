mall_view=
{
	name="mall_view",type=0,typeName="View",time=0,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="mall_view_bg",type=1,typeName="Image",time=2185898,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,file="drawable/blank_black.png"
	},
	{
		name="mall_title_view",type=0,typeName="View",time=2185935,x=0,y=0,width=480,height=95,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTop,
		{
			name="mall_title_bg",type=1,typeName="Image",time=2185963,x=0,y=0,width=720,height=116,visible=1,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignTop,file="common/background/chat_title_bg.png"
		},
		{
			name="Text3",type=4,typeName="Text",time=141379535,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=48,textAlign=kAlignLeft,colorRed=225,colorGreen=200,colorBlue=160,string=[[商城]]
		}
	},
	{
		name="mall_type_toggle_bg",type=1,typeName="Image",time=141379905,x=0,y=194,width=644,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/background/tab_bg_3.png",gridLeft=61,gridRight=61,gridTop=0,gridBottom=0,
		{
			name="mall_type_toggle_view",type=0,typeName="RadioButtonGroup",time=80301915,x=0,y=0,width=644,height=74,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop
		}
	},
	{
		name="assets_btn",type=2,typeName="Button",time=114860415,x=0,y=19,width=444,height=96,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="common/button/long_yellow_btn.png",
		{
			name="Text2",type=4,typeName="Text",time=141373935,x=0,y=0,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=36,textAlign=kAlignCenter,colorRed=95,colorGreen=15,colorBlue=15,string=[[我的资产]]
		}
	},
	{
		name="qrcode_btn_bg",type=1,typeName="Image",time=128605663,x=34,y=21,width=60,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="common/icon/gift_icon.png",
		{
			name="qrcode_btn",type=2,typeName="Button",time=128605664,x=0,y=0,width=90,height=90,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="drawable/blank.png"
		}
	},
	{
		name="mall_userinfo_view",type=0,typeName="View",time=15565697,x=0,y=128,width=720,height=68,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
		{
			name="mall_money_info_view",type=0,typeName="View",time=117789705,x=-267,y=0,width=80,height=48,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
			{
				name="num",type=4,typeName="Text",time=15575995,x=61,y=0,width=13,height=26,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=26,textAlign=kAlignLeft,colorRed=255,colorGreen=255,colorBlue=255,string=[[0]]
			},
			{
				name="icon",type=1,typeName="Image",time=141379415,x=0,y=0,width=60,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/icon/gold_icon.png"
			}
		},
		{
			name="mall_userinfo_bccoin",type=0,typeName="View",time=24660466,x=190,y=0,width=35,height=48,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
			{
				name="num",type=4,typeName="Text",time=15576281,x=66,y=0,width=13,height=26,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=26,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[0]]
			},
			{
				name="icon",type=1,typeName="Image",time=141379846,x=0,y=0,width=60,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/icon/bccoin_icon.png"
			}
		},
		{
			name="mall_soul_info_view",type=0,typeName="View",time=128605619,x=-14,y=-4,width=80,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
			{
				name="num",type=4,typeName="Text",time=117789706,x=62,y=0,width=13,height=26,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=26,textAlign=kAlignCenter,colorRed=255,colorGreen=255,colorBlue=255,string=[[0]]
			},
			{
				name="icon",type=1,typeName="Image",time=141379589,x=0,y=0,width=60,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/icon/soul_icon.png"
			}
		}
	},
	{
		name="mall_content_view",type=0,typeName="View",time=2186812,x=0,y=279,width=720,height=875,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
		{
			name="mall_shop_placehold",type=0,typeName="View",time=80302130,x=0,y=0,width=720,height=875,visible=1,fillParentWidth=0,fillParentHeight=1,nodeAlign=kAlignTopLeft
		},
		{
			name="mall_prop_placehold",type=0,typeName="View",time=80302166,x=0,y=0,width=720,height=875,visible=1,fillParentWidth=0,fillParentHeight=1,nodeAlign=kAlignTopLeft
		}
	},
	{
		name="mall_back_btn",type=2,typeName="Button",time=141374109,x=27,y=36,width=60,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottomLeft,file="common/button/hide_dialog_btn.png"
	}
}