package com.boyaa.entity.update;

/**
 * 
 * @FileName: 	 AppSyncSystem.java
 * @Author:   	 Jayshon.Liu
 * @Date:     	 2012.09.17
 * @Description: Application synchronization controler
 * 
 */

import java.util.List;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;

public class AppSyncSystem{
	private static final String LOG_TAG = "AppSyncSystem";
	private static final String MY_PACK_NAME = "com.boyaa.application";
	private static Context	mainContext = null;
	private static Activity curActivity = null;
	private static PackageManager pm = null;
	private static AppSyncSystem instance = null;
	
	private AppSyncSystem(Context context){
		this.setMainContext(context);
		curActivity = (Activity)context;
		pm = mainContext.getPackageManager();
	}
	
	
	public void setMainContext(Context mainContext){
		AppSyncSystem.mainContext = mainContext;
	}
	
	
	public void setCurActivity(Activity curActivity){
		AppSyncSystem.curActivity = curActivity;
	}
	
	
	
	public static AppSyncSystem sharedAppSyncSystem(Context curContext){
		return (null == instance ? new AppSyncSystem(curContext) : instance);
	}
	
	
	
	/**
	 * 根据包名启动另一个APP
	
	 * @Title: startOtherApp
	
	 * @Description: TODO(这里用一句话描述这个方法的作用)
	
	 * @param: @param packName   
	
	 * @return: void   
	
	 * @throws
	 */
	public boolean startAppWithPackName(String packName){
		if(null == packName || packName.equals("")){
			return false;
		}
		
		System.out.println("A");
		
		try{
			//不要自己启动自己(掉进死循环)
			if(packName.equals(MY_PACK_NAME)){
				System.out.println("AA");
				return false;
			}
		}catch(Exception e){
			e.printStackTrace();
		}
		
		
		try{
			PackageInfo pinfo = pm.getPackageInfo(packName, 0);
			
			Intent resolveIntent = new Intent(Intent.ACTION_MAIN,null);
			resolveIntent.addCategory(Intent.CATEGORY_LAUNCHER);
			resolveIntent.setPackage(pinfo.packageName);
			List<ResolveInfo> apps = pm.queryIntentActivities(resolveIntent, 0);
			
			while(true){
				ResolveInfo ri = apps.iterator().next();
				if(null != ri){
					String packageName = ri.activityInfo.packageName;
					//System.out.println(LOG_TAG + ".packageName: " + packageName);
					if(packageName.equals(packName)){
						String className = ri.activityInfo.name;
						Intent intent = new Intent(Intent.ACTION_MAIN);
						intent.addCategory(Intent.CATEGORY_LAUNCHER);
						ComponentName cn = new ComponentName(packageName,className);
						intent.setComponent(cn);
						Thread.sleep(2000);
						mainContext.startActivity(intent);
						break;
					}
				}else{
					break;
				}
			}
			
		}catch(Exception e){
			e.printStackTrace();
		}
		return true;
	}
	
	
	
	/**
	 * 重启当前APP
	
	 * @Title: reStartCurApp
	
	 * @Description: TODO(这里用一句话描述这个方法的作用)
	
	 * @param:    
	
	 * @return: void   
	
	 * @throws
	 */
	public void reStartCurApp(){
		if(null == curActivity){
			return;
		}
		
		Intent i = curActivity.getBaseContext().getPackageManager().getLaunchIntentForPackage(curActivity.getBaseContext().getPackageName());  
		i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);  
		curActivity.startActivity(i);
		
	}
}