package com.boyaa.log;

//import com.boyaa.BoyaaApplication;

public class Log {
	public static final String ERROR_TAG = "ERROR";

//	private static final int VERBOSE = 0x0001;
	private static final int DEBUG = 0x0002;
	private static final int INFO = 0x0004;
	private static final int WARN = 0x0008;
	private static final int ERROR = 0x0010;

	private static final int RELEASE = 0x0000;

	//发正式包时改为RELEASE
	private static int LEVEL = RELEASE;
	
	static {
		//if (BoyaaApplication.isDebug) LEVEL = VERBOSE | DEBUG | INFO | WARN | ERROR;
	}
	
	public static void d(String tag, String log) {
		if (permission(DEBUG)) {
			android.util.Log.d(tag, log);
		}
	}

	public static void i(String tag, String log) {
		if (permission(INFO)) {
			android.util.Log.i(tag, log);
		}
	}

	public static void w(String tag, String log) {
		if (permission(WARN)) {
			android.util.Log.w(tag, log);
		}
	}
	
	public static void e(String tag, String log) {
		if (permission(ERROR)) {
			android.util.Log.e(tag, log);
		}
	}
	
	private static boolean permission(int level) {
		if ((level | LEVEL) > 0) {
			return true;
		}
		return false;
	}
}
