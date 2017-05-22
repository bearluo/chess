package com.boyaa.common;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

import com.boyaa.pointwall.PointWallActivity;

public class NetworkUtil {
	
	private static Context mContext;
//
//	public NetworkUtil(Context context){
//		this.mContext = context;
//	}
	
	/** 妫�煡鏄惁鏈夌綉缁�*/
	public static boolean isNetworkAvailable() {
		NetworkInfo info = getNetworkInfo();
		if (info != null) {
			return info.isAvailable();
		}
		return false;
	}

	/** 妫�煡鏄惁鏄疻IFI */
	public static boolean isWifi() {
		NetworkInfo info = getNetworkInfo();
		if (info != null) {
			if (info.getType() == ConnectivityManager.TYPE_WIFI)
				return true;
		}
		return false;
	}

	/** 妫�煡鏄惁鏄Щ鍔ㄧ綉缁�*/
	public static boolean isMobile() {
		NetworkInfo info = getNetworkInfo();
		if (info != null) {
			if (info.getType() == ConnectivityManager.TYPE_MOBILE)
				return true;
		}
		return false;
	}

	private static NetworkInfo getNetworkInfo() {
		mContext = PointWallActivity.getInstance().getApplicationContext();
		ConnectivityManager cm = (ConnectivityManager)mContext.getSystemService(Context.CONNECTIVITY_SERVICE);
		return cm.getActiveNetworkInfo();
	}
}
