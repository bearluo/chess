package com.boyaa.entity.common;

import com.boyaa.made.AppActivity;

import android.content.Context;
import android.database.Cursor;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Proxy;
import android.net.Uri;
import android.util.Log;

/**
 * APN工具类
 * <p>
 * 
 * </p>
 */
public class APNUtil {
	private static final String TAG = "APNUtil";
	/**
	 * cmwap
	 */
	public static final int MPROXYTYPE_CMWAP = 1;
	/**
	 * wifi
	 */
	public static final int MPROXYTYPE_WIFI = 2;
	/**
	 * cmnet
	 */
	public static final int MPROXYTYPE_CMNET = 4;
	/**
	 * uninet服务器列表
	 */
	public static final int MPROXYTYPE_UNINET = 8;
	/**
	 * uniwap服务器列表
	 */
	public static final int MPROXYTYPE_UNIWAP = 16;
	/**
	 * net类服务器列表
	 */
	public static final int MPROXYTYPE_NET = 32;
	/**
	 * wap类服务器列表
	 */
	public static final int MPROXYTYPE_WAP = 64;
	/**
	 * 默认服务器列表
	 */
	public static final int MPROXYTYPE_DEFAULT = 128;
	/**
	 * cmda net
	 */
	public static final int MPROXYTYPE_CTNET = 256;
	/**
	 * cmda wap
	 */
	public static final int MPROXYTYPE_CTWAP = 512;

	public static final String ANP_NAME_WIFI = "wifi"; // 中国移动wap APN名称
	public static final String ANP_NAME_CMWAP = "cmwap"; // 中国移动wap APN名称
	public static final String ANP_NAME_CMNET = "cmnet"; // 中国移动net APN名称
	public static final String ANP_NAME_UNIWAP = "uniwap"; // 中国联通wap APN名称
	public static final String ANP_NAME_UNINET = "uninet"; // 中国联通net APN名称
	public static final String ANP_NAME_WAP = "wap"; // 中国电信wap APN名称
	public static final String ANP_NAME_NET = "net"; // 中国电信net APN名称
	public static final String ANP_NAME_CTWAP = "中国电信ctwap服务器列表"; // wap APN名称
	public static final String ANP_NAME_CTNET = "中国电信ctnet服务器列表"; // net APN名称
	public static final String ANP_NAME_NONE = "none"; // net APN名称

	// apn地址
	private static Uri PREFERRED_APN_URI = Uri.parse("content://telephony/carriers/preferapn");

	// apn属性类型
	public static final String APN_PROP_APN = "apn";
	// apn属性代理
	public static final String APN_PROP_PROXY = "proxy";
	// apn属性端口
	public static final String APN_PROP_PORT = "port";

	public static final byte APNTYPE_NONE = 0;// 未知类型
	public static final byte APNTYPE_CMNET = 1;// cmnet
	public static final byte APNTYPE_CMWAP = 2;// cmwap
	public static final byte APNTYPE_WIFI = 3;// WiFi
	public static final byte APNTYPE_UNINET = 4;// uninet
	public static final byte APNTYPE_UNIWAP = 5;// uniwap
	public static final byte APNTYPE_NET = 6;// net类接入点
	public static final byte APNTYPE_WAP = 7;// wap类接入点
	public static final byte APNTYPE_CTNET = 8; // ctnet
	public static final byte APNTYPE_CTWAP = 9; // ctwap
	// jce接入点类型
	public static final int JCE_APNTYPE_UNKNOWN = 0;
	public static final int JCE_APNTYPE_DEFAULT = 1;
	public static final int JCE_APNTYPE_CMNET = 2;
	public static final int JCE_APNTYPE_CMWAP = 4;
	public static final int JCE_APNTYPE_WIFI = 8;
	public static final int JCE_APNTYPE_UNINET = 16;
	public static final int JCE_APNTYPE_UNIWAP = 32;
	public static final int JCE_APNTYPE_NET = 64;
	public static final int JCE_APNTYPE_WAP = 128;
	public static final int JCE_APNTYPE_CTWAP = 512;
	public static final int JCE_APNTYPE_CTNET = 256;

	/**
	 * 获取jce协议的接入点类型 老协议的
	 * 
	 * @param context
	 * @return
	 */
	public static int getJceApnType(Context context) {
		int netType = getMProxyType(context);
		if (netType == MPROXYTYPE_WIFI) {
			return JCE_APNTYPE_WIFI;
		} else if (netType == MPROXYTYPE_CMWAP) {
			return JCE_APNTYPE_CMWAP;
		} else if (netType == MPROXYTYPE_CMNET) {
			return JCE_APNTYPE_CMNET;
		} else if (netType == MPROXYTYPE_UNIWAP) {
			return JCE_APNTYPE_UNIWAP;
		} else if (netType == MPROXYTYPE_UNINET) {
			return JCE_APNTYPE_UNINET;
		} else if (netType == MPROXYTYPE_WAP) {
			return JCE_APNTYPE_WAP;
		} else if (netType == MPROXYTYPE_NET) {
			return JCE_APNTYPE_NET;
		} else if (netType == MPROXYTYPE_CTWAP) {
			return JCE_APNTYPE_CTWAP;
		} else if (netType == MPROXYTYPE_CTNET) {
			return JCE_APNTYPE_CTNET;
		}
		return JCE_APNTYPE_DEFAULT;
	}

	/**
	 * 将jce定义的接入点类型转化为普通(老协议定义的)接入点类型
	 * 
	 * @param jceApnType
	 * @return
	 */
	public static byte jceApnTypeToNormalapnType(int jceApnType) {
		if (jceApnType == JCE_APNTYPE_UNKNOWN) {
			return APNTYPE_NONE;
		} else if (jceApnType == JCE_APNTYPE_DEFAULT) {
			return JCE_APNTYPE_CMWAP;
		} else if (jceApnType == JCE_APNTYPE_CMNET) {
			return APNTYPE_CMNET;
		} else if (jceApnType == JCE_APNTYPE_CMWAP) {
			return APNTYPE_CMWAP;
		} else if (jceApnType == JCE_APNTYPE_WIFI) {
			return APNTYPE_WIFI;
		} else if (jceApnType == JCE_APNTYPE_UNINET) {
			return APNTYPE_UNINET;
		} else if (jceApnType == JCE_APNTYPE_UNIWAP) {
			return APNTYPE_UNIWAP;
		} else if (jceApnType == JCE_APNTYPE_NET) {
			return APNTYPE_NET;
		} else if (jceApnType == JCE_APNTYPE_WAP) {
			return APNTYPE_WAP;
		} else if (jceApnType == JCE_APNTYPE_CTWAP) {
			return APNTYPE_CTNET;
		} else if (jceApnType == JCE_APNTYPE_CTNET) {
			return APNTYPE_CTWAP;
		}
		return APNTYPE_NONE;
	}

	/**
	 * 将普通(老协议定义的)接入点类型转化为jce定义的接入点类型 老协议的
	 * 
	 * @param apnType
	 * @return
	 */
	public static int normalApnTypeToJceApnType(byte apnType) {
		if (apnType == APNTYPE_NONE) {
			return JCE_APNTYPE_UNKNOWN;
		} else if (apnType == JCE_APNTYPE_CMWAP) {
			return JCE_APNTYPE_DEFAULT;
		} else if (apnType == APNTYPE_CMNET) {
			return JCE_APNTYPE_CMNET;
		} else if (apnType == APNTYPE_CMWAP) {
			return JCE_APNTYPE_CMWAP;
		} else if (apnType == APNTYPE_WIFI) {
			return JCE_APNTYPE_WIFI;
		} else if (apnType == APNTYPE_UNINET) {
			return JCE_APNTYPE_UNINET;
		} else if (apnType == APNTYPE_UNIWAP) {
			return JCE_APNTYPE_UNIWAP;
		} else if (apnType == APNTYPE_NET) {
			return JCE_APNTYPE_NET;
		} else if (apnType == APNTYPE_WAP) {
			return JCE_APNTYPE_WAP;
		} else if (apnType == APNTYPE_CTWAP) {
			return JCE_APNTYPE_CTWAP;
		} else if (apnType == APNTYPE_CTNET) {
			return JCE_APNTYPE_CTNET;
		}
		return JCE_APNTYPE_UNKNOWN;
	}

	/**
	 * 获取自定义APN名称
	 * 
	 * @param context
	 * @return
	 */
	public static String getApnName(Context context) {
		int netType = getMProxyType(context);

		if (netType == MPROXYTYPE_WIFI) {
			return ANP_NAME_WIFI;
		} else if (netType == MPROXYTYPE_CMWAP) {
			return ANP_NAME_CMWAP;
		} else if (netType == MPROXYTYPE_CMNET) {
			return ANP_NAME_CMNET;
		} else if (netType == MPROXYTYPE_UNIWAP) {
			return ANP_NAME_UNIWAP;
		} else if (netType == MPROXYTYPE_UNINET) {
			return ANP_NAME_UNINET;
		} else if (netType == MPROXYTYPE_WAP) {
			return ANP_NAME_WAP;
		} else if (netType == MPROXYTYPE_NET) {
			return ANP_NAME_NET;
		} else if (netType == MPROXYTYPE_CTWAP) {
			return ANP_NAME_CTWAP;
		} else if (netType == MPROXYTYPE_CTNET) {
			return ANP_NAME_CTNET;
		}
		// 获取系统apn名称
		String apn = getApn(context);
		if (apn == null || apn.length() == 0)
			return apn;
		return ANP_NAME_NONE;
	}

	public static boolean IsBroadband(Context context) {
		int netType = getMProxyType(context);
		if (netType == MPROXYTYPE_WIFI) {
			return true;
		} else if (netType == MPROXYTYPE_CMWAP) {
			return false;
		} else if (netType == MPROXYTYPE_CMNET) {
			return false;
		} else if (netType == MPROXYTYPE_UNIWAP) {
			return false;
		} else if (netType == MPROXYTYPE_UNINET) {
			return false;
		} else if (netType == MPROXYTYPE_WAP) {
			return false;
		} else if (netType == MPROXYTYPE_NET) {
			return false;
		} else if (netType == MPROXYTYPE_CTWAP) {
			return false;
		} else if (netType == MPROXYTYPE_CTNET) {
			return false;
		} else {
			return true;
		}
	}

	/**
	 * 获取自定义apn类型
	 * 
	 * @param context
	 * @return
	 */
	public static byte getApnType(Context context) {
		int netType = getMProxyType(context);

		if (netType == MPROXYTYPE_WIFI) {
			return APNTYPE_WIFI;
		} else if (netType == MPROXYTYPE_CMWAP) {
			return APNTYPE_CMWAP;
		} else if (netType == MPROXYTYPE_CMNET) {
			return APNTYPE_CMNET;
		} else if (netType == MPROXYTYPE_UNIWAP) {
			return APNTYPE_UNIWAP;
		} else if (netType == MPROXYTYPE_UNINET) {
			return APNTYPE_UNINET;
		} else if (netType == MPROXYTYPE_WAP) {
			return APNTYPE_WAP;
		} else if (netType == MPROXYTYPE_NET) {
			return APNTYPE_NET;
		} else if (netType == MPROXYTYPE_CTWAP) {
			return APNTYPE_CTWAP;
		} else if (netType == MPROXYTYPE_CTNET) {
			return APNTYPE_CTNET;
		}
		return APNTYPE_NONE;
	}

	/**
	 * 获取系统APN
	 * 
	 * @param context
	 * @return
	 */
	public static String getApn(Context context) {
		try{
			Cursor c = context.getContentResolver().query(PREFERRED_APN_URI, null, null, null, null);
			c.moveToFirst();
			if (c.isAfterLast()) {
				return null;
			}
			return c.getString(c.getColumnIndex(APN_PROP_APN));
		} catch (Exception e) {
			Log.e(TAG, e.toString());
			return null;
		}

	}

	/**
	 * 获取系统APN代理IP
	 * 
	 * @param context
	 * @return
	 */
	public static String getApnProxy(Context context) {
		try{
			Cursor c = context.getContentResolver().query(PREFERRED_APN_URI, null, null, null, null);
			c.moveToFirst();
			if (c.isAfterLast()) {
				return Proxy.getDefaultHost();
			}
			return c.getString(c.getColumnIndex(APN_PROP_PROXY));
		}catch(Exception e){
			Log.e(TAG, e.toString());
			//android4.0以上系统，使用用wap网络请求时可能报需要apn写出权限错误，此时重新对ip、port赋值
			return Proxy.getDefaultHost();
		}
	}

	/**
	 * 获取系统APN代理端口
	 * 
	 * @param context
	 * @return
	 */
	public static String getApnPort(Context context) {
		try{
			Cursor c = context.getContentResolver().query(PREFERRED_APN_URI, null, null, null, null);
			c.moveToFirst();
			if (c.isAfterLast()) {
				return null;
			}
			return c.getString(c.getColumnIndex(APN_PROP_PORT));
		}catch (Exception e) {
			Log.e(TAG, e.toString());
			return null;
		}
	}

	/**
	 * 获取系统APN代理端口
	 * 
	 * @param context
	 * @return
	 */
	public static int getApnPortInt(Context context) {
		try {
			Cursor c = context.getContentResolver().query(PREFERRED_APN_URI, null, null, null, null);
			c.moveToFirst();
			if (c.isAfterLast()) {
				return Proxy.getDefaultPort() == -1 ? 80 : Proxy.getDefaultPort();
			}
			return c.getInt(c.getColumnIndex(APN_PROP_PORT));
		} catch (Exception e) {
			Log.e(TAG, e.toString());
//			android4.0以上系统，使用用wap网络请求时可能报需要apn写出权限错误，此时重新对ip、port赋值
			return Proxy.getDefaultPort() == -1 ? 80 : Proxy.getDefaultPort();
		}
	}

	/**
	 * 是否有网关代理
	 * 
	 * @param context
	 * @return
	 */
	public static boolean hasProxy(Context context) {
		int netType = getMProxyType(context);
		// #if ${polish.debug}
		Log.d(TAG, "netType:" + netType);
		// #endif
		if (netType == MPROXYTYPE_CMWAP || netType == MPROXYTYPE_UNIWAP || netType == MPROXYTYPE_WAP || netType == MPROXYTYPE_CTWAP) {
			return true;
		}
		return false;
	}

	/**
	 * 获取自定义当前联网类型
	 * 
	 * @param act
	 *            当前活动Activity
	 * @return 联网类型 -1表示未知的联网类型, 正确类型： MPROXYTYPE_WIFI | MPROXYTYPE_CMWAP |
	 *         MPROXYTYPE_CMNET
	 */
	public static int getMProxyType(Context act) {

		int type = MPROXYTYPE_DEFAULT;
		ConnectivityManager cm = (ConnectivityManager) act.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo info = cm.getActiveNetworkInfo();
		if (null != info) {
			String typeName = info.getTypeName();// never null
			String extraInfo = info.getExtraInfo();// maybe null
			if (null == extraInfo) {
				extraInfo = "unknown";
			} else {
				extraInfo = extraInfo.toLowerCase();
			}

			if (typeName.toUpperCase().equals("WIFI")) { // wifi网络
				type = MPROXYTYPE_WIFI;
			} else {
				if (extraInfo.startsWith("cmwap")) { // cmwap
					type = MPROXYTYPE_CMWAP;
				} else if (extraInfo.startsWith("cmnet") || extraInfo.startsWith("epc.tmobile.com")) { // cmnet
					type = MPROXYTYPE_CMNET;
				} else if (extraInfo.startsWith("uniwap")) {
					type = MPROXYTYPE_UNIWAP;
				} else if (extraInfo.startsWith("uninet")) {
					type = MPROXYTYPE_UNINET;
				} else if (extraInfo.startsWith("wap")) {
					type = MPROXYTYPE_WAP;
				} else if (extraInfo.startsWith("net")) {
					type = MPROXYTYPE_NET;
				} else if (extraInfo.startsWith("#777")) { // cdma
					String proxy = getApnProxy(act);
					if (proxy != null && proxy.length() > 0) {
						type = MPROXYTYPE_CTWAP;
					} else {
						type = MPROXYTYPE_CTNET;
					}
				} else if (extraInfo.startsWith("ctwap")) {
					type = MPROXYTYPE_CTWAP;
				} else if (extraInfo.startsWith("ctnet")) {
					type = MPROXYTYPE_CTNET;
				} else {
				}

			}
		}
		return type;
	}

	/**
	 * @param context
	 * @return
	 */
	public static String getNetWorkName(Context context) {
		ConnectivityManager cm = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo info = cm.getActiveNetworkInfo();
		if (info != null)
			return info.getTypeName();
		else
			return "unknow";

//			return "MOBILE";
	}

	/**
	 * 检测是否有网络
	 * 
	 * @param c
	 * @return
	 */
	public static boolean isNetworkAvailable(Context act) {
		ConnectivityManager cm = (ConnectivityManager) act.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo info = cm.getActiveNetworkInfo();
		if (info != null && info.getState() == NetworkInfo.State.CONNECTED)
			return true;
		return false;
	}

	/**
	 * 活动网络是否有效
	 * 
	 * @param ctx
	 * @return
	 */
	public static boolean isActiveNetworkAvailable(Context ctx) {
		ConnectivityManager cm = (ConnectivityManager) ctx.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo info = cm.getActiveNetworkInfo();
		if (info != null)
			return info.isAvailable();
		return false;
	}
}