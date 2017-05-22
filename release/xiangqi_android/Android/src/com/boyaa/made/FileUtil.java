package com.boyaa.made;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;


import android.content.Context;
import android.content.res.AssetManager;
import android.os.Environment;
import android.util.Log;

public class FileUtil {
	private static String packagePath;
	private static String imagesPath;
	public static String getmStrImagesPath() {
		return imagesPath;
	}
	public static boolean readySDCard() {
		if (android.os.Environment.getExternalStorageState().equals(android.os.Environment.MEDIA_MOUNTED)) {
			return true;
		}
		return false;
	}
	private static String getSDPath() {
		return Environment.getExternalStorageDirectory().getAbsolutePath() + File.separator + "." + packagePath + File.separator;
	}
	public static String getSubPath(String subPath) {
		return getSDPath() + subPath + File.separator;
	}
	private static String createSubPath(String subPath) {
		String strPath = getSubPath( subPath);
		File file = new File(strPath);
		file.mkdir();
		return strPath;
	}
	public static String initFile(Context context, String strPackage) {
		packagePath = strPackage;
		if (!FileUtil.readySDCard())
			return "";
		String strPath = getSDPath();
		File file = new File(strPath);
		if (!file.exists()) {
			file.mkdir();
			// copyFileOrDir(context,"", strPath);
		}
		imagesPath = createSubPath("images");
		createSubPath("scripts");
		createSubPath("xml");
		createSubPath("log");
		//此处将start_screen.jpg写到sdcard/com.boyaa.application/images/start_screen.png
		return strPath;
	}
	private static void copyFileOrDir(Context context, String path, String strSDAppPath) {
		AssetManager assetManager = context.getAssets();
		String assets[] = null;
		try {
			assets = assetManager.list(path);
			if (assets.length == 0) {
				copyFile(context, path, strSDAppPath);
			} else {
				String fullPath = strSDAppPath + path;
				File dir = new File(fullPath);
				if (!dir.exists()) {
					if (!dir.mkdirs()) {
						Log.i("Boyaa", "could not create dir " + fullPath);
					}
				}

				for (int i = 0; i < assets.length; ++i) {
					String p;
					if (path.equals("")) {
						p = "";
					} else {
						p = path + "/";
					}
					copyFileOrDir(context, p + assets[i], strSDAppPath);
				}
			}
		} catch (IOException ex) {
			Log.e("Boyaa", "I/O Exception", ex);
		}
	}

	private static void copyFile(Context context, String filename, String strSDAppPath) {
		if (!filename.endsWith(".lua") && !filename.endsWith(".xml")) {
			return;
		}

		AssetManager assetManager = context.getAssets();

		InputStream in = null;
		OutputStream out = null;
		String newFileName = null;
		try {
			Log.i("Boyaa", "copyFile() " + filename);
			in = assetManager.open(filename);
			if (filename.endsWith(".jpg")) // extension was added to avoid
											// compression on APK file
				newFileName = strSDAppPath + filename.substring(0, filename.length() - 4);
			else
				newFileName = strSDAppPath + filename;
			out = new FileOutputStream(newFileName);

			byte[] buffer = new byte[1024];
			int read;
			while ((read = in.read(buffer)) != -1) {
				out.write(buffer, 0, read);
			}
			in.close();
			in = null;
			out.flush();
			out.close();
			out = null;
		} catch (Exception e) {
			Log.e("Boyaa", "Exception in copyFile() of " + newFileName);
			Log.e("Boyaa", "Exception in copyFile() " + e.toString());
		}
	}

}
