package com.boyaa.qqapi;


public class QQConstants {
		
	    public static final String QQ_APP_ID = "100748287";
	    public static final String QQ_APP_key = "e1fb8cec768cf9d706f20509cd0dc768";
	    
	    public static String url = 
	    		"https://api.weixin.qq.com/sns/oauth2/access_token?"
	    		+ "appid="
	    		+ QQ_APP_ID
	    		+ "&secret="
	    		+ QQ_APP_key
	    		+ "&code=CODE&grant_type=authorization_code";
	    public static class ShowMsgActivity {
			public static final String STitle = "showmsg_title";
			public static final String SMessage = "showmsg_message";
			public static final String BAThumbData = "showmsg_thumb_data";
	    }
    	
}
