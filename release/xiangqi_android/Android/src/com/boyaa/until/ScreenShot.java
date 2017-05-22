package com.boyaa.until;


import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.IntBuffer;

import javax.microedition.khronos.opengles.GL10;

import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.Bitmap.Config;
import android.graphics.Canvas;
import android.opengl.GLES10;
import android.os.Environment;
import android.util.Log;
import android.view.View;

import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.entity.common.SDTools;
import com.boyaa.made.FileUtil;

public class ScreenShot {

	/**
	 * 创建截图。必须是gl线程
	 * 
	 * @param x
	 * @param y
	 * @param w
	 * @param h
	 * @return
	 */
	public static Bitmap createBitmapFromGLSurface(int x, int y, int w, int h) {
		long time = System.currentTimeMillis();
		int bitmapBuffer[] = new int[w * h];
		int bitmapSource[] = new int[w * h];
		IntBuffer intBuffer = IntBuffer.wrap(bitmapBuffer);
		intBuffer.position(0);

		try {
			GLES10.glReadPixels(x, y, w, h, GL10.GL_RGBA, GL10.GL_UNSIGNED_BYTE, intBuffer);
			int offset1, offset2;
			for (int i = 0; i < h; i++) {
				offset1 = i * w;
				offset2 = (h - i - 1) * w;
				for (int j = 0; j < w; j++) {
					int texturePixel = bitmapBuffer[offset1 + j];
					int blue = (texturePixel >> 16) & 0xff;
					int red = (texturePixel << 16) & 0x00ff0000;
					int pixel = (texturePixel & 0xff00ff00) | red | blue;
					bitmapSource[offset2 + j] = pixel;
				}
			}
		} catch (Exception e) {
			return null;
		}
		Bitmap bmp = Bitmap.createBitmap(bitmapSource, w, h, Bitmap.Config.RGB_565);
		int width = bmp.getWidth();
		int height = bmp.getHeight();
		if (width > 480) {
			float scale = (float) bmp.getWidth() / (float) bmp.getHeight();
			width = 600;
			height = (int) (width / scale);
			bmp = Bitmap.createScaledBitmap(bmp, width, height, true);
		}
		time = System.currentTimeMillis() - time;
		Log.d("LuaEvent", "截屏耗时:" + time);
		return bmp;
	}

	public static Bitmap takeScreenShot(Activity activity) {
		View view = activity.getWindow().getDecorView();
		int width = view.getWidth();
		int height = view.getHeight();
		Log.d("ScreenShot", "width:" + width + ",height:" + height);
		Bitmap bmp = Bitmap.createBitmap(width, height, Config.ARGB_8888);
		Canvas c = new Canvas(bmp);
		view.draw(c);
		
		SDTools.saveBitmap(activity, FileUtil.getmStrImagesPath(), "takeScreenShot3", bmp);
		return bmp;
	}

	private static void savePic(Bitmap b, String strFileName, CompressFormat format) {
		FileOutputStream fos = null;
		try {
			fos = new FileOutputStream(strFileName);
			if (null != fos) {
				b.compress(format, 90, fos);
				fos.flush();
				fos.close();
			}
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public static void shoot(Activity a) {
		ScreenShot.savePic(ScreenShot.takeScreenShot(a), "sdcard/xx.png", Bitmap.CompressFormat.PNG);
	}

	/**
	 * 截屏，保存到sd卡
	 * 
	 * @param fileName
	 * @return 返回保存的图片的路径
	 */
	public static String saveScreenShot(String fileName) {
		File file = new File(Environment.getExternalStorageDirectory(), fileName);
		if (!file.exists()) {
			try {
				file.createNewFile();
			} catch (IOException e) {
			}
		}
		Bitmap bmp = takeScreenShot(Game.mActivity);
		savePic(bmp, file.getAbsolutePath(), Bitmap.CompressFormat.PNG);
		return file.getAbsolutePath();
	}

	public static File saveBitmapAsFile(Bitmap bmp, String fileName) {
		File file = new File(Environment.getExternalStorageDirectory(), fileName);
		if (!file.exists()) {
			try {
				file.createNewFile();
			} catch (IOException e) {
			}
		}
		savePic(bmp, file.getAbsolutePath(), Bitmap.CompressFormat.PNG);
		return file;
	}

	public static String saveBitmap(Bitmap bmp, String filePath, String fileName) {
		String path = null;
		if (null == filePath || 0 == filePath.length())
			return path;
		if (null == fileName || 0 == fileName.length())
			return path;
		if (null == bmp)
			return path;
		if (bmp.isRecycled())
			return path;

		String fullPath = filePath + fileName;

		File file = new File(fullPath);
		try {
			if(file.exists()){
				file.delete();
			}
			file.createNewFile();
		} catch (IOException e) {
			Log.e("SDTools", e.toString());
			return path;
		}
		path = file.getAbsolutePath();
		savePic(bmp, path, Bitmap.CompressFormat.JPEG);
		return path;
	}
}