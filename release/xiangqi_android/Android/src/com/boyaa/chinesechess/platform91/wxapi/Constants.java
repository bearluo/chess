package com.boyaa.chinesechess.platform91.wxapi;

public class Constants {
    public static final String APP_ID = "wx30b4c195169be98b";
    public static final String APP_key = "a2a891d9584784393a16bfaa07b87499";
    public static final String PARTNER_ID = "1296270401";
    public static final String SIGN = "bc6905af2d833185906b0882362ab5e5";
    
    public static String url = 
    		"https://api.weixin.qq.com/sns/oauth2/access_token?"
    		+ "appid="
    		+ APP_ID
    		+ "&secret="
    		+ APP_key
    		+ "&code=CODE&grant_type=authorization_code";
    
    public static String userInfoUrl = "https://api.weixin.qq.com/sns/userinfo?access_token=ACCESS_TOKEN&openid=OPENID";
    
    public static class ShowMsgActivity {
		public static final String STitle = "showmsg_title";
		public static final String SMessage = "showmsg_message";
		public static final String BAThumbData = "showmsg_thumb_data";
	}
    
    
}
