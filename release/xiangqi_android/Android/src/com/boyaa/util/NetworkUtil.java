package com.boyaa.util;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiManager;
public class NetworkUtil {
    
    public static int NOT_REACHABLE = 0;
    public static int REACHABLE_VIA_CARRIER_DATA_NETWORK = 1;
    public static int REACHABLE_VIA_WIFI_NETWORK = 2;

    public static final String WIFI = "wifi";
    public static final String WIMAX = "wimax";
    // mobile
    public static final String MOBILE = "mobile";
    // 2G network types
    public static final String GSM = "gsm";
    public static final String GPRS = "gprs";
    public static final String EDGE = "edge";
    // 3G network types
    public static final String CDMA = "cdma";
    public static final String UMTS = "umts";
    public static final String HSPA = "hspa";
    public static final String HSUPA = "hsupa";
    public static final String HSDPA = "hsdpa";
    public static final String ONEXRTT = "1xrtt";
    public static final String EHRPD = "ehrpd";
    // 4G network types
    public static final String LTE = "lte";
    public static final String UMB = "umb";
    public static final String HSPA_PLUS = "hspa+";
    // return types
    public static final String TYPE_UNKNOWN = "unknown";
    public static final String TYPE_ETHERNET = "ethernet";
    public static final String TYPE_WIFI = "wifi";
    public static final String TYPE_2G = "2g";
    public static final String TYPE_3G = "3g";
    public static final String TYPE_4G = "4g";
    public static final String TYPE_NONE = "none";
    
    public static final int NEWWORK_TYPE_UNKNOWN = -1;
    public static final int NEWWORK_TYPE_NONE = -1;
    public static final int NEWWORK_TYPE_WIFI = 1;
    public static final int NEWWORK_TYPE_2G = 2;
    public static final int NEWWORK_TYPE_3G = 3;
    public static final int NEWWORK_TYPE_4G = 4;

    private static final String LOG_TAG = "NetworkManager";

    /**
     * Constructor.
     */
    public NetworkUtil()    {
        
    }


    public static int getNetworkType(Context ctx){
    	ConnectivityManager cm = (ConnectivityManager) ctx.getSystemService(Context.CONNECTIVITY_SERVICE); 
    	NetworkInfo info = cm.getActiveNetworkInfo();
    	return getConnectionInfo(info);
    }
    
    public static String getNetworkName(Context ctx) {
    	ConnectivityManager cm = (ConnectivityManager) ctx.getSystemService(Context.CONNECTIVITY_SERVICE);
    	NetworkInfo info = cm.getActiveNetworkInfo();
    	return info.getTypeName();
    }
    
    
    public static int getNetworkStrength(Context ctx){
    	int rssi = ((WifiManager) ctx.getSystemService(Context.WIFI_SERVICE)).getConnectionInfo().getRssi();
    	int level = WifiManager.calculateSignalLevel(rssi, 4);
//    	if(level <= 60)
//    		return 4;
//    	else if(level <= 70)
//    		return 3;
//    	else if(level <= 90)
//    		return 2;
    	return level + 1;
    }

    /** 
     * Get the latest network connection information
     * 
     * @param info the current active network info
     * @return a JSONObject that represents the network info
     */
    private static int getConnectionInfo(NetworkInfo info) {
        int type = NEWWORK_TYPE_NONE;
        if (info != null) {
            // If we are not connected to any network set type to none
            if (!info.isConnected()) {
                type = NEWWORK_TYPE_NONE;
            }            
            else {
                type = getType(info);
            }
        }
        return type;
    }
    


    private static int getType(NetworkInfo info) {
        if (info != null) {
            String type = info.getTypeName(); 

            if (type.toLowerCase().equals(WIFI)) {
                return NEWWORK_TYPE_WIFI;
            }
            else if (type.toLowerCase().equals(MOBILE)) {
                type = info.getSubtypeName();
                if (type.toLowerCase().equals(GSM) || 
                        type.toLowerCase().equals(GPRS) ||
                        type.toLowerCase().equals(EDGE)) {
                    return NEWWORK_TYPE_2G;
                }
                else if (type.toLowerCase().startsWith(CDMA) || 
                        type.toLowerCase().equals(UMTS)  ||
                        type.toLowerCase().equals(ONEXRTT) ||
                        type.toLowerCase().equals(EHRPD) ||
                        type.toLowerCase().equals(HSUPA) ||
                        type.toLowerCase().equals(HSDPA) ||
                        type.toLowerCase().equals(HSPA)) {
                    return NEWWORK_TYPE_3G;
                }
                else if (type.toLowerCase().equals(LTE) || 
                        type.toLowerCase().equals(UMB) ||
                        type.toLowerCase().equals(HSPA_PLUS)) {
                    return NEWWORK_TYPE_4G;
                }
            }
        }else {
            return NEWWORK_TYPE_NONE;
        }
        return NEWWORK_TYPE_UNKNOWN;
    }
}
