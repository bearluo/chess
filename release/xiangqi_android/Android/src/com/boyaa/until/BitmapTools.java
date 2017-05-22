package com.boyaa.until;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

public class BitmapTools {
	
	public static BitmapFactory.Options getBitmapSize(String path) {
		BitmapFactory.Options options = new BitmapFactory.Options();
		options.inJustDecodeBounds = true; // 只加载图片大小
		BitmapFactory.decodeFile(path, options);
		return options;
	}
	
	public static Bitmap getScaleBitmapBySize(String path,int width,int height) {
		BitmapFactory.Options options = getBitmapSize(path);
		options.inSampleSize = calculateInSampleSize(options,width,height);
		options.inJustDecodeBounds = false;
		return BitmapFactory.decodeFile(path, options);
	}
	
	//计算图片的缩放值
	public static int calculateInSampleSize(BitmapFactory.Options options,int reqWidth, int reqHeight) {
	    final int height = options.outHeight;
	    final int width = options.outWidth;
	    int inSampleSize = 1;

	    if (height > reqHeight || width > reqWidth) {
	             final int heightRatio = Math.round((float) height/ (float) reqHeight);
	             final int widthRatio = Math.round((float) width / (float) reqWidth);
	             inSampleSize = heightRatio < widthRatio ? heightRatio : widthRatio;
	    }
        return inSampleSize;
	}
}
