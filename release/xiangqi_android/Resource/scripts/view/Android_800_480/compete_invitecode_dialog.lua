compete_invitecode_dialog=
{
	name="compete_invitecode_dialog",type=0,typeName="View",time=0,x=0,y=0,width=720,height=1280,visible=1,fillParentWidth=1,fillParentHeight=1,nodeAlign=kAlignTopLeft,
	{
		name="bg_img",type=1,typeName="Image",time=128829873,x=0,y=266,width=640,height=723,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/background/dialog_bg_2.png",gridLeft=50,gridRight=50,gridTop=50,gridBottom=50
	},
	{
		name="bg",type=0,typeName="View",time=129106738,x=0,y=-10,width=640,height=733,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,
		{
			name="title",type=0,typeName="View",time=128830083,x=0,y=0,width=553,height=150,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
			{
				name="txt",type=4,typeName="Text",time=128830131,x=0,y=-4,width=230,height=150,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=46,textAlign=kAlignCenter,colorRed=80,colorGreen=80,colorBlue=80,string=[[特约赛报名]]
			},
			{
				name="line",type=1,typeName="Image",time=128830258,x=0,y=20,width=550,height=19,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="common/decoration/line.png"
			},
			{
				name="close",type=2,typeName="Button",time=128830349,x=-2,y=42,width=60,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTopRight,file="common/button/btn_close.png"
			}
		},
		{
			name="code",type=0,typeName="View",time=128830090,x=0,y=152,width=560,height=157,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,
			{
				name="tips",type=4,typeName="Text",time=128830491,x=0,y=-4,width=448,height=28,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=28,textAlign=kAlignCenter,colorRed=135,colorGreen=100,colorBlue=95,string=[[请输入本场比赛的邀请码]]
			},
			{
				name="code_bg",type=1,typeName="Image",time=128830818,x=0,y=21,width=510,height=88,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="common/background/input_bg_2.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
				{
					name="hide",type=0,typeName="View",time=129695685,x=0,y=0,width=200,height=70,visible=0,fillParentWidth=1,fillParentHeight=0,nodeAlign=kAlignCenter,
					{
						name="txt11",type=4,typeName="Text",time=129695696,x=15,y=0,width=60,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=56,textAlign=kAlignCenter,colorRed=165,colorGreen=145,colorBlue=125,string=[[请]]
					},
					{
						name="txt21",type=4,typeName="Text",time=129695701,x=97,y=0,width=60,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=56,textAlign=kAlignCenter,colorRed=165,colorGreen=145,colorBlue=125,string=[[输]]
					},
					{
						name="txt31",type=4,typeName="Text",time=129695706,x=184,y=0,width=60,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=56,textAlign=kAlignCenter,colorRed=165,colorGreen=145,colorBlue=125,string=[[入]]
					},
					{
						name="txt41",type=4,typeName="Text",time=129695710,x=182,y=0,width=60,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,fontSize=56,textAlign=kAlignCenter,colorRed=165,colorGreen=145,colorBlue=125,string=[[邀]]
					},
					{
						name="txt51",type=4,typeName="Text",time=129695713,x=95,y=0,width=60,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,fontSize=56,textAlign=kAlignCenter,colorRed=165,colorGreen=145,colorBlue=125,string=[[请]]
					},
					{
						name="txt61",type=4,typeName="Text",time=129695719,x=15,y=0,width=60,height=60,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,fontSize=56,textAlign=kAlignCenter,colorRed=165,colorGreen=145,colorBlue=125,string=[[码]]
					}
				},
				{
					name="line1",type=1,typeName="Image",time=128831282,x=85,y=0,width=2,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/line_4.png"
				},
				{
					name="line2",type=1,typeName="Image",time=128831424,x=167,y=0,width=2,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/line_4.png"
				},
				{
					name="line3",type=1,typeName="Image",time=128831428,x=0,y=0,width=2,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="common/line_4.png"
				},
				{
					name="line4",type=1,typeName="Image",time=128831431,x=167,y=0,width=2,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="common/line_4.png"
				},
				{
					name="line5",type=1,typeName="Image",time=128831436,x=85,y=0,width=2,height=64,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,file="common/line_4.png"
				}
			},
			{
				name="num1",type=4,typeName="Text",time=128831693,x=55,y=13,width=28,height=56,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=56,textAlign=kAlignLeft,colorRed=80,colorGreen=80,colorBlue=80,string=[[]]
			},
			{
				name="num2",type=4,typeName="Text",time=128832424,x=136,y=13,width=0,height=0,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=56,textAlign=kAlignLeft,colorRed=80,colorGreen=80,colorBlue=80,string=[[]]
			},
			{
				name="num3",type=4,typeName="Text",time=128832451,x=223,y=13,width=28,height=56,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,fontSize=56,textAlign=kAlignLeft,colorRed=80,colorGreen=80,colorBlue=80,string=[[]]
			},
			{
				name="num4",type=4,typeName="Text",time=128832457,x=223,y=13,width=28,height=56,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,fontSize=56,textAlign=kAlignLeft,colorRed=80,colorGreen=80,colorBlue=80,string=[[]]
			},
			{
				name="num5",type=4,typeName="Text",time=128832460,x=136,y=13,width=0,height=0,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,fontSize=56,textAlign=kAlignLeft,colorRed=80,colorGreen=80,colorBlue=80,string=[[]]
			},
			{
				name="num6",type=4,typeName="Text",time=128832852,x=55,y=13,width=0,height=0,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignRight,fontSize=56,textAlign=kAlignLeft,colorRed=80,colorGreen=80,colorBlue=80,string=[[]]
			}
		},
		{
			name="pad",type=0,typeName="View",time=128830112,x=0,y=56,width=546,height=376,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,
			{
				name="bg",type=1,typeName="Image",time=128832920,x=0,y=0,width=530,height=334,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="common/background/line_bg.png",gridLeft=30,gridRight=30,gridTop=30,gridBottom=30,
				{
					name="line1",type=1,typeName="Image",time=128838227,x=0,y=84,width=530,height=3,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/decoration/name_line.png"
				},
				{
					name="line2",type=1,typeName="Image",time=128839460,x=0,y=169,width=530,height=3,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/decoration/name_line.png"
				},
				{
					name="line3",type=1,typeName="Image",time=128839489,x=0,y=254,width=530,height=3,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="common/decoration/name_line.png"
				},
				{
					name="line4",type=1,typeName="Image",time=128838259,x=177,y=0,width=2,height=334,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/line_4.png"
				},
				{
					name="line5",type=1,typeName="Image",time=128839749,x=354,y=0,width=2,height=334,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignLeft,file="common/line_4.png"
				}
			},
			{
				name="tips",type=4,typeName="Text",time=128833087,x=0,y=0,width=384,height=24,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=24,textAlign=kAlignLeft,colorRed=200,colorGreen=40,colorBlue=40,string=[[您输入的邀请码有误，请核对后再试]]
			},
			{
				name="num1",type=2,typeName="Button",time=128839807,x=-177,y=43,width=177,height=84,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="ui/button.png",file2="compete/num_pre.png",
				{
					name="txt",type=4,typeName="Text",time=128839903,x=0,y=0,width=177,height=84,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=48,textAlign=kAlignCenter,colorRed=125,colorGreen=80,colorBlue=65,string=[[1]]
				}
			},
			{
				name="num2",type=2,typeName="Button",time=128840130,x=1,y=43,width=177,height=84,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="ui/button.png",file2="compete/num_pre.png",
				{
					name="txt",type=4,typeName="Text",time=128840131,x=0,y=0,width=177,height=84,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=48,textAlign=kAlignCenter,colorRed=125,colorGreen=80,colorBlue=65,string=[[2]]
				}
			},
			{
				name="num3",type=2,typeName="Button",time=128840158,x=178,y=43,width=177,height=84,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="ui/button.png",file2="compete/num_pre.png",
				{
					name="txt",type=4,typeName="Text",time=128840159,x=0,y=0,width=177,height=84,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=48,textAlign=kAlignCenter,colorRed=125,colorGreen=80,colorBlue=65,string=[[3]]
				}
			},
			{
				name="num4",type=2,typeName="Button",time=128840229,x=-177,y=127,width=177,height=84,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="ui/button.png",file2="compete/num_pre.png",
				{
					name="txt",type=4,typeName="Text",time=128840230,x=0,y=0,width=177,height=84,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=48,textAlign=kAlignCenter,colorRed=125,colorGreen=80,colorBlue=65,string=[[4]]
				}
			},
			{
				name="num5",type=2,typeName="Button",time=128840282,x=1,y=127,width=177,height=84,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="ui/button.png",file2="compete/num_pre.png",
				{
					name="txt",type=4,typeName="Text",time=128840283,x=0,y=0,width=177,height=84,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=48,textAlign=kAlignCenter,colorRed=125,colorGreen=80,colorBlue=65,string=[[5]]
				}
			},
			{
				name="num6",type=2,typeName="Button",time=128840300,x=178,y=127,width=177,height=84,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="ui/button.png",file2="compete/num_pre.png",
				{
					name="txt",type=4,typeName="Text",time=128840301,x=0,y=0,width=177,height=84,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=48,textAlign=kAlignCenter,colorRed=125,colorGreen=80,colorBlue=65,string=[[6]]
				}
			},
			{
				name="num7",type=2,typeName="Button",time=128840344,x=-177,y=212,width=177,height=84,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="ui/button.png",file2="compete/num_pre.png",
				{
					name="txt",type=4,typeName="Text",time=128840345,x=0,y=0,width=177,height=84,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=48,textAlign=kAlignCenter,colorRed=125,colorGreen=80,colorBlue=65,string=[[7]]
				}
			},
			{
				name="num8",type=2,typeName="Button",time=128840379,x=1,y=212,width=177,height=84,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="ui/button.png",file2="compete/num_pre.png",
				{
					name="txt",type=4,typeName="Text",time=128840380,x=0,y=0,width=177,height=84,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=48,textAlign=kAlignCenter,colorRed=125,colorGreen=80,colorBlue=65,string=[[8]]
				}
			},
			{
				name="num9",type=2,typeName="Button",time=128840401,x=178,y=212,width=177,height=84,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="ui/button.png",file2="compete/num_pre.png",
				{
					name="txt",type=4,typeName="Text",time=128840402,x=0,y=0,width=177,height=84,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=48,textAlign=kAlignCenter,colorRed=125,colorGreen=80,colorBlue=65,string=[[9]]
				}
			},
			{
				name="clear",type=2,typeName="Button",time=128840459,x=-177,y=296,width=177,height=84,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="ui/button.png",file2="compete/num_pre.png",
				{
					name="txt",type=4,typeName="Text",time=128840460,x=0,y=0,width=177,height=84,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=36,textAlign=kAlignCenter,colorRed=125,colorGreen=80,colorBlue=65,string=[[清空]]
				}
			},
			{
				name="num0",type=2,typeName="Button",time=128840513,x=1,y=296,width=177,height=84,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="ui/button.png",file2="compete/num_pre.png",
				{
					name="txt",type=4,typeName="Text",time=128840514,x=0,y=0,width=177,height=84,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=48,textAlign=kAlignCenter,colorRed=125,colorGreen=80,colorBlue=65,string=[[0]]
				}
			},
			{
				name="del",type=2,typeName="Button",time=128840790,x=178,y=296,width=177,height=84,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,file="ui/button.png",file2="compete/num_pre.png",
				{
					name="img",type=1,typeName="Image",time=128840802,x=0,y=0,width=60,height=36,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,file="compete/del_btn.png"
				}
			}
		},
		{
			name="confirm",type=0,typeName="View",time=129106234,x=0,y=0,width=560,height=145,visible=0,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,
			{
				name="sure",type=2,typeName="Button",time=129106291,x=0,y=11,width=310,height=85,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignBottom,file="common/button/dialog_btn_1_normal.png",file2="common/button/dialog_btn_1_press.png",gridLeft=20,gridRight=20,gridTop=20,gridBottom=20,
				{
					name="txt",type=4,typeName="Text",time=129106562,x=0,y=-3,width=200,height=150,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignCenter,fontSize=38,textAlign=kAlignCenter,colorRed=240,colorGreen=230,colorBlue=210,string=[[参加比赛]]
				}
			},
			{
				name="tips",type=4,typeName="Text",time=129106458,x=0,y=7,width=384,height=24,visible=1,fillParentWidth=0,fillParentHeight=0,nodeAlign=kAlignTop,fontSize=24,textAlign=kAlignCenter,colorRed=0,colorGreen=208,colorBlue=0,string=[[验证成功]]
			}
		}
	}
}