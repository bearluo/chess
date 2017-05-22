package com.boyaa.entity.sysInfo;

import android.content.Intent;
import android.net.Uri;

import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.entity.common.Log;
import com.boyaa.entity.core.HandMachine;
import com.boyaa.made.AppActivity;

public class SystemInfo {
	
	public SystemInfo(){
	
	}
	
	public static int versionCode = 0;
	public static String versionName = "";
	public void setVersion(){
		
        AppActivity.dict_set_string(HandMachine.kVersion_sync,HandMachine.kversionCode, Game.versionCode + "");
        AppActivity.dict_set_string(HandMachine.kVersion_sync,HandMachine.kversionName , Game.versionName );
		  
	}
	

	public void updateVersion(String url,String type) {
		if (url == null || "".equals(url)) {
			Log.i("SystemInfo", "not url");
			return;
		}else{
			Log.i("SystemInfo", " url = " + url + "type = " + type);
		}
		
		Intent intent = new Intent(Intent.ACTION_VIEW);
		intent.setData(Uri.parse(url));
		intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		AppActivity.mActivity.startActivity(intent);
		
		if(type != null && "1".equals(type)){
			
			AppActivity.mActivity.finish();
		}
		
		AppActivity.mActivity.finish();

	}
	
	
	public void toWebPage(String url){
		System.out.print("SystemInfo.toWebPage url = " + url);

		if(url == null || "".equals(url)){
			Log.i("SystemInfo", "not url");
			return;
		}else{
			Log.i("SystemInfo", " url = " + url);
		}
		
		try{
			Intent intent = new Intent(Intent.ACTION_VIEW);
			intent.setData(Uri.parse(url));
			intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			AppActivity.mActivity.startActivity(intent);
			
		}catch (Exception e) {
			System.out.println("no webrower");
		}

		
	}
}
