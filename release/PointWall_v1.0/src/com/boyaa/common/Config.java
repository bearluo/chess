package com.boyaa.common;

import android.os.Environment;

public class Config {
	public static final String APK_PATH = Environment.getExternalStorageDirectory()+"/boyaa/pwall/apks/";
	public static final String TEMP_PIC_PATH = Environment.getExternalStorageDirectory()+"/boyaa/pwall/pic/";
	public static final String TEMP_LOG = Environment.getExternalStorageDirectory()+"/boyaa/pwall/logs/";
	public static final int HTTP_CONNECT_TIME_OUT = 30000;
	
	public static final int VALUE_QQ_LOGIN = 1;
	public static final int VALUE_BOYAA_LOGIN = 2;
	public static final int VALUE_SINA_LOGIN = 3;
	public static final int VALUE_NULL_LOGIN = 0;
}
