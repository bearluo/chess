package com.boyaa.common;

import java.io.File;
import java.io.FileOutputStream;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.BitmapFactory.Options;
import android.os.Environment;
import android.text.TextUtils;

import com.boyaa.php.Secret;


public class ImageFileManager {
	public static final String IMAGE_PATH = Environment.getExternalStorageDirectory() +"/boyaa/pwall/images/";
	public static final String IMAGE_SUFFIX = ".by";

	private static int[] sampleSize = {2, 4, 8, 16, 32, 64};

	public static String getImagePath(String url) {
		String imageFileName = Secret.md5(url);
		return IMAGE_PATH + imageFileName + IMAGE_SUFFIX;
	}
	
	public static void saveImage(Bitmap bitmap, String url) {
		if (bitmap == null || bitmap.isRecycled() || TextUtils.isEmpty(url)) return;
		
		if (!SDCardUtil.isSDCardAvailable()) return;
		
		String imagePath = getImagePath(url);
		
		FileUtil.createDirectoryIfNotExist(IMAGE_PATH);

		if (FileUtil.existFile(imagePath)) return;

		FileOutputStream fos = null;
		try {
			fos = new FileOutputStream(imagePath);
			bitmap.compress(Bitmap.CompressFormat.PNG, 100, fos);
			fos.flush();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (fos != null) {
				try {
					fos.close();
				} catch (Exception e) {}
			}
		}
	}

	public static void saveImage(Bitmap bitmap, String directory, String imageFileName) {
		if (bitmap == null || bitmap.isRecycled() || TextUtils.isEmpty(imageFileName)) return;
		
		if (!SDCardUtil.isSDCardAvailable()) return;
		
		FileUtil.createDirectoryIfNotExist(directory);

		if (FileUtil.existFile(directory + imageFileName)) return;

		FileOutputStream fos = null;
		try {
			fos = new FileOutputStream(directory + imageFileName);
			bitmap.compress(Bitmap.CompressFormat.PNG, 100, fos);
			fos.flush();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (fos != null) {
				try {
					fos.close();
				} catch (Exception e) {}
			}
		}
	}

	public static void saveImage(byte[] bytes, String url) {
		if (bytes == null || TextUtils.isEmpty(url)) return;
		
		if (!SDCardUtil.isSDCardAvailable()) return;
		
		String imagePath = getImagePath(url);
		
		FileUtil.createDirectoryIfNotExist(IMAGE_PATH);

		if (FileUtil.existFile(imagePath)) return;

		FileOutputStream fos = null;
		try {
			fos = new FileOutputStream(imagePath);
			fos.write(bytes);
			fos.flush();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (fos != null) {
				try {
					fos.close();
				} catch (Exception e) {}
			}
		}
	}
	
	public static Bitmap getImage(String url) {
		return getImage(url, -1);
	}

	public static Bitmap getImage(String url, int maxBytes) {
		Bitmap bitmap = null;
		if (!SDCardUtil.isSDCardAvailable()) return bitmap;

		String imagePath = getImagePath(url);
		
		File imageFile = new File(imagePath);
		if (!imageFile.exists() || !imageFile.isFile()) {
			return bitmap;
		}
		long existFileSize = imageFile.length();
		
		if (existFileSize <= 0) return bitmap;

		Options mOptions = null;
		if (maxBytes != -1 && maxBytes < existFileSize) {
			int scale = 0;
			long length = existFileSize;
			while (length > maxBytes) {
				length = length / 4;
				scale++;
			}
			mOptions = new Options();
			mOptions.inSampleSize = sampleSize[scale];
		}
		bitmap = BitmapFactory.decodeFile(imagePath, mOptions);
		return bitmap;
	}

}
