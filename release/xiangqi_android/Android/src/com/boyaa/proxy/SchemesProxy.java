package com.boyaa.proxy;

import android.content.Intent;
import android.net.Uri;
import android.util.Log;

public class SchemesProxy {
	private static SchemesProxy schemesProxy = new SchemesProxy();
	private static final String SCHEMA = "boyaachess";
	private String json = "";
	public void setIntent(Intent intent) {
		Log.e("url","setIntent");
		try {
			// url 启动解析
			//取得Schema，值为：boyaachess
			String tSchema = intent.getScheme();
			Uri myURI = intent.getData();
			//取得URL
			if( tSchema != null && SCHEMA.contentEquals(tSchema) ) {
				if(myURI != null) 
					json = myURI.toString();
				else
					json = "";
			}else {
				json = "";
			}
		} catch (Exception e) {
			json = "";
		}
		Log.e("url",json);
	}
	
	public static SchemesProxy getInstance() {
		return schemesProxy;
	}
	
	public String getIntentData() {
		return json;
	}
	
	public void clearIntentData() {
		json = "";
	}
}
