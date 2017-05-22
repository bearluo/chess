package com.boyaa.common;

import java.lang.ref.SoftReference;
import java.util.HashMap;

import android.graphics.Bitmap;

public class BitmapPool {
//	private static final Object LOCK = new Object();
	private static HashMap<String, SoftReference<Bitmap>> bitmapCacheMap = new HashMap<String, SoftReference<Bitmap>>();
	
	public static Bitmap getBitmap(String url) {
		Bitmap bitmap = null;
		SoftReference<Bitmap> ref = bitmapCacheMap.get(url);
		if (ref != null) {
			bitmap = ref.get();
			if (bitmap != null && !bitmap.isRecycled()) {
				return bitmap;
			}
		}
		bitmap = ImageFileManager.getImage(url);
		if (bitmap != null) {
			bitmapCacheMap.put(url, new SoftReference<Bitmap>(bitmap));
		}
		return bitmap;
	}
}
