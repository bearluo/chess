daily_sign_dialog=
{
	name="daily_sign_dialog",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignCenter,
	{
		name="Image1",type=1,typeName="Image",time=137208006,x=0,y=129,width=720,height=918,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/background/sign_bg.png"
	},
	{
		name="view",type=0,typeName="View",time=135073957,x=0,y=174,width=628,height=824,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
		{
			name="item_view1",type=0,typeName="View",time=135073991,x=0,y=320,width=450,height=240,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop
		},
		{
			name="item_view2",type=0,typeName="View",time=135074147,x=0,y=564,width=600,height=240,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop
		},
		{
			name="activity_view",type=0,typeName="View",time=136263669,x=2,y=4,width=600,height=300,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
			{
				name="default_btn",type=2,typeName="Button",time=137218624,x=0,y=0,width=600,height=300,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/decoration/vip_dec.png"
			}
		},
		{
			name="close_btn",type=2,typeName="Button",time=136263406,x=0,y=-85,width=60,height=60,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="common/button/btn_close.png"
		}
	},
	{
		name="Image4",type=1,typeName="Image",time=137228008,x=0,y=129,width=720,height=84,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/decoration/sign_title_icon.png"
	},
	{
		name="title",type=4,typeName="Text",time=136263376,x=0,y=131,width=120,height=40,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=40,textAlign=kAlignCenter,colorRed=250,colorGreen=235,colorBlue=200,string=[[早上好]]
	},
	{
		name="get_btn",type=2,typeName="Button",time=136263437,x=0,y=43,width=444,height=96,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="common/button/long_yellow_btn.png",
		{
			name="text",type=4,typeName="Text",time=136263475,x=0,y=0,width=72,height=36,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=36,textAlign=kAlignCenter,colorRed=95,colorGreen=15,colorBlue=15,string=[[领取]]
		},
		{
			name="logo",type=1,typeName="Image",time=136362688,x=70,y=0,width=46,height=38,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="vip/vip_logo.png"
		}
	},
	{
		name="vip_tips",type=0,typeName="View",time=137208777,x=0,y=1056,width=297,height=50,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
		{
			name="Image3",type=1,typeName="Image",time=137208785,x=4,y=0,width=46,height=38,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="vip/vip_logo.png"
		},
		{
			name="text",type=4,typeName="Text",time=137208877,x=67,y=0,width=0,height=0,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=30,textAlign=kAlignLeft,colorRed=255,colorGreen=230,colorBlue=130,string=[[VIP签到双倍奖励]]
		}
	}
}