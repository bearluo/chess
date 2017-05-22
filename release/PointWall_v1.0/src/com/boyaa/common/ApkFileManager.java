package com.boyaa.common;

import com.boyaa.php.Secret;

public class ApkFileManager {
	public static String createApkFilePath(String apkUrl) {
		int index = apkUrl.lastIndexOf("/");
		int index2 = apkUrl.lastIndexOf("\\");
		index = index > index2 ? index : index2;
		String fileName;
		if (index > 0 && apkUrl.endsWith(".apk")) {
			fileName = apkUrl.substring(index + 1);
		} else {
			fileName = Secret.md5(apkUrl) + ".apk";
		}

		return Config.APK_PATH + fileName;
	}
}
