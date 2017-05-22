package com.boyaa.common;

public class SDCardUtil {

	public static boolean isSDCardAvailable() {
		if (android.os.Environment.getExternalStorageState().equals(android.os.Environment.MEDIA_MOUNTED)) {
			return true;
		}
		return false;
	}

}
