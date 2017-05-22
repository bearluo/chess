package com.boyaa.utils;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.telephony.TelephonyManager;
import android.text.TextUtils;

public class EnviromentUtil {

	private static String devicedID;
	private static String versionName;
//	private static String deviceName;
	public static String getDeviceId(){
		return getDeviceId(null);
	}
	public static String getDeviceId(Context context){
		if (TextUtils.isEmpty(devicedID)) {
	//		TelephonyManager telephonyManager= (TelephonyManager) BoyaaApplication.getInstance().getSystemService(Context.TELEPHONY_SERVICE);
			//devicedID  = telephonyManager.getDeviceId();
			if(TextUtils.isEmpty(devicedID)){
				devicedID = "-1";
			}
		}
		return devicedID;
	}
	
	public static String getVersionName(Context mContext) 
	{  
	       if(versionName==null){
	    	    // 获取packagemanager的实例  
		        PackageManager packageManager = mContext.getPackageManager();  
		        // getPackageName()是你当前类的包名，0代表是获取版本信息  
		        PackageInfo packInfo;
				try {
					packInfo = packageManager.getPackageInfo(mContext.getPackageName(),0);
					versionName = packInfo.versionName;  
					
				} catch (NameNotFoundException e) {
					// TODO Auto-generated catch block
					versionName = "1.0";
					e.printStackTrace();
				}
	       }
	        return versionName;  
	}
	public static int getVersionCode(Context mContext) 
	{  
		int versionCode = 1;
	      
	    	// 获取packagemanager的实例  
		        PackageManager packageManager = mContext.getPackageManager();  
		        // getPackageName()是你当前类的包名，0代表是获取版本信息  
		        PackageInfo packInfo;
				try {
					packInfo = packageManager.getPackageInfo(mContext.getPackageName(),0);
					versionCode = packInfo.versionCode;  
					
				} catch (NameNotFoundException e) {
					// TODO Auto-generated catch block
				}  
	        return versionCode;  
	}

	public static String getPhoneNumber() {
		return "12345678901";
//		TelephonyManager telephonyManager = (TelephonyManager)BoyaaApplication.getInstance().getSystemService(Context.TELEPHONY_SERVICE);
//        return telephonyManager.getLine1Number();
    }
	//mac
	public static String getLocalMacAddress(Context context) { 
        WifiManager wifi = (WifiManager)context.getSystemService(Context.WIFI_SERVICE); 
        WifiInfo info = wifi.getConnectionInfo(); 
        return info.getMacAddress(); 
    }
	//imei
	public static String getImeiNum(Context context) {
		String imei = null;
		TelephonyManager telephonyManager = (TelephonyManager)context.getSystemService(Context.TELEPHONY_SERVICE);
		if (telephonyManager != null) {
			imei = telephonyManager.getDeviceId();
		}
		if (imei == null) {
			imei = "";
		}
		return imei;
	}
	//mac
	public static String getMacAddr(Context context) {
		String Mac = null;
		WifiManager mgr = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);
		if (mgr != null) {
			WifiInfo wifiinfo = mgr.getConnectionInfo();
			if (wifiinfo != null) {
				Mac = wifiinfo.getMacAddress();
			}
		}
		if (Mac == null) {
			Mac = "";
		}
		return Mac;
	}
	//ip
	public static String getIpAddr(Context context){
        WifiManager mgr = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);  
        if (!mgr.isWifiEnabled()) {  
        	mgr.setWifiEnabled(true);    
        }  
        WifiInfo wifiInfo = mgr.getConnectionInfo();       
        int ipAddress = wifiInfo.getIpAddress();   
        String ip = intToIp(ipAddress);   
        return ip;
    }     
    private static String intToIp(int i) {       
         
		return  (i & 0xFF) + "." +       
			    ((i >> 8 ) & 0xFF) + "." +       
			    ((i >> 16) & 0xFF) + "." +       
			    ((i >> 24) & 0xFF);  
	}
	public static String getNetWorkName(Context context) {
		ConnectivityManager cm = (ConnectivityManager) context
				.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo info = cm.getActiveNetworkInfo();
		if (info != null)
			return info.getTypeName();
		else
			return "MOBILE";
	}
	public static String getPhoneModel(){
		return Build.MODEL;
	}
	
	public static String getSdkVersion(){
		return Build.VERSION.RELEASE;
	}
}
