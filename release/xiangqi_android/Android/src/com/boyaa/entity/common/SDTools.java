package com.boyaa.entity.common;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Environment;
import android.text.TextUtils;
import android.util.Log;

import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.chinesechess.platform91.R;
import com.boyaa.made.AppActivity;

public class SDTools {
	
	
	public static final String PNG_SUFFIX = ".png";
	public static final String JPG_SUFFIX = ".JPG";


	private static final String versionCode = "versionCode";
	private static final String versionName = "versionName";
	private static final String versionUG = "versionUG";
	private static byte[] sync = new byte[0];

	private final static String DICT_NAME = "TerminalInfoTable";
	private final static String DICT_KEY_SDCARD_STATE = "sdcard_state";
	private final static String DICT_KEY_INTERNAL_UPDATE_PATH = "internal_update_path";
	//保存png 图片
	public static boolean saveBitmap(Context context, String filePath , String fileName , Bitmap bmp ) {
		synchronized (sync) {
			
			if (null == filePath || 0 == filePath.length())
				return false;
			if (null == fileName || 0 == fileName.length())
				return false;
			if (null == bmp)
				return false;
			if (bmp.isRecycled())
				return false;
			
			
			// 生成新的
			String fullPath = filePath + fileName + PNG_SUFFIX;
			Log.i("DEBUG", "filePath = "  +filePath +  " fileName = " + fileName);
			
			if (deleteFile(fullPath)){
				Log.i("DEBUG", "deleteFile = true " + fileName );
			}else{
				Log.i("DEBUG", "deleteFile = false" + fileName );
			}
			File file = new File(fullPath);
			try {
				file.createNewFile();
			} catch (IOException e) {
				Log.e("SDTools", e.toString());
				return false;
			}
			FileOutputStream fOut = null;
			try {
				fOut = new FileOutputStream(file);
			} catch (FileNotFoundException e) {
				Log.e("SDTools", e.toString());
				return false;
			}
			bmp.compress(Bitmap.CompressFormat.PNG, 100, fOut);
			try {
				fOut.flush();
				fOut.close();
				fOut = null;
			} catch (IOException e) {
				Log.e("SDTools", e.toString());
				return false;
			} finally {
				try {
					if (null != fOut)
						fOut.close();
				} catch (Exception e) {
					return false;
				}
			}
			return true;
		}
	}
	
	//保存png 图片
		public static boolean saveBitmapJPG(Context context, String filePath , String fileName , Bitmap bmp) {
			synchronized (sync) {
				
				if (null == filePath || 0 == filePath.length())
					return false;
				if (null == fileName || 0 == fileName.length())
					return false;
				if (null == bmp)
					return false;
				if (bmp.isRecycled())
					return false;
				
				
				// 生成新的
				String fullPath = filePath + fileName;
				deleteFile(fileName);
				File file = new File(fullPath);
				try {
					file.createNewFile();
				} catch (IOException e) {
					Log.e("SDTools", e.toString());
					return false;
				}
				FileOutputStream fOut = null;
				try {
					fOut = new FileOutputStream(file);
				} catch (FileNotFoundException e) {
					Log.e("SDTools", e.toString());
					return false;
				}
				bmp.compress(Bitmap.CompressFormat.JPEG, 100, fOut);
				try {
					fOut.flush();
					fOut.close();
					fOut = null;
				} catch (IOException e) {
					Log.e("SDTools", e.toString());
					return false;
				} finally {
					try {
						if (null != fOut)
							fOut.close();
					} catch (Exception e) {
						return false;
					}
				}
				return true;
			}
		}
	
	//删除文件
	private static boolean deleteFile(String name) {
		File file = new File(name);
		if (file.exists()) {
			return file.delete();
		}
		return false;
	}
	
	//批量保存png 图片
	public static void batchSaveBmp(Context context, String path){
		
		//判断当前版本 与 数据库中版本是否相等
		SharedPreferences pref = AppActivity.mActivity.getSharedPreferences(versionUG, -1);
		if(Game.versionCode == pref.getInt(versionCode,-2)){
			return;
		}
		Map<Integer , String> map = new HashMap<Integer , String>();
		map.put(R.drawable.start_screen, "start_screen");
//		map.put(R.drawable.background, "background");
//		map.put(R.drawable.jiesuan_bg, "jiesuan_bg");
//		map.put(R.drawable.sc_room_bg, "sc_room_bg");
//		map.put(R.drawable.login_bg, "login_bg");
//		map.put(R.drawable.women, "women");
		Bitmap bitmap = null;
		for(Integer key : map.keySet()){
			
			bitmap = BitmapFactory.decodeResource(context.getResources(), key);
			Bitmap output = Bitmap.createScaledBitmap(bitmap, 800, 480, true);
		
			saveBitmap(context , path , map.get(key) , output);
		}
		SharedPreferences.Editor edit = AppActivity.mActivity.getSharedPreferences(versionUG, -1).edit();
		edit.putInt(versionCode,Game.versionCode);
		edit.putString(versionName,Game.versionName);
		edit.commit();
	}
	
   /**
    * sd卡是否可写
    * @return
    */
	public static boolean isExternalStorageWriteable() {

		return Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED);
	}

	
	/**
	 * 给与指定的宽与高, 缩放加载指定路径的图片, 以节约内存.
	 * 注意: 此函数调用频率高, 故未进行容错判断, 默认调用源的参数都是正确的
	 * @param path 图片的路径
	 * @param reqWidth 缩放到的参考宽度
	 * @param reqHeight 缩放到的参考高度
	 * @return 缩放后的图片
	 */
	public static Bitmap decodeFile(String path, int reqWidth, int reqHeight) {
		// inJustDecodeBounds为true是, decode不会加载图片, 而是获得图片的长宽等参数
		final BitmapFactory.Options options = new BitmapFactory.Options();
	    options.inJustDecodeBounds = true;
	    BitmapFactory.decodeFile(path, options);

	    // 计算缩放级别
	    options.inSampleSize = calculateInSampleSize(options, reqWidth, reqHeight);
	    
	    // Decode bitmap with inSampleSize set
	    options.inJustDecodeBounds = false;
	    return BitmapFactory.decodeFile(path, options);
	}
	
	/**
	 * 计算加载图片适合的缩放级别
	 * @param options 读取到了图片的长宽参数的Option
	 * @param reqWidth 要缩放到的宽度
	 * @param reqHeight 要缩放到的高度
	 * @return 合适的缩放级别, 不变则为1
	 */
	private static int calculateInSampleSize(
            BitmapFactory.Options options, int reqWidth, int reqHeight) {
		// Raw height and width of image
		final int height = options.outHeight;
		final int width = options.outWidth;
		int inSampleSize = 1;

		if (height > reqHeight || width > reqWidth) {
			if (width > height) {
				inSampleSize = Math.round((float)height / (float)reqHeight);
			} else {
				inSampleSize = Math.round((float)width / (float)reqWidth);
			}
		}
		return inSampleSize;
	}
	
	/**
	 * 返回SD卡状态给Lua
	 * flag == 0 未知(其他情况，没插，正在扫描，等等)
	 * flag == 1 可读可写
	 * flag == 2 仅可读
	 */
	public static void getSDCardStateForLua() {
		String state = Environment.getExternalStorageState();
		int flag = 0; 
		if (state.equals(Environment.MEDIA_MOUNTED)) {
			flag = 1;
		} else if (state.equals(Environment.MEDIA_MOUNTED_READ_ONLY)) {
			flag = 2;
		}
		AppActivity.dict_set_int(DICT_NAME, DICT_KEY_SDCARD_STATE, flag);
	}
	
	public static void getInternalUpdatePathForLua(Context context) {
		String path = getInternalUpdatePath(context);
		AppActivity.dict_set_string(DICT_NAME, DICT_KEY_INTERNAL_UPDATE_PATH, path);
	}
	
	/**
	 * 缓存ROM上面的升级文件存储路径
	 */
	private static String internalUpdatePath = null;
	
	/**
	 * 获取ROM上面的升级文件存储路径，用于当SD不可写的情况
	 * "/data/data/包名/app_apkUpdate/"
	 * @return
	 */
	public static String getInternalUpdatePath(Context context) {
		if (TextUtils.isEmpty(internalUpdatePath)) {
			final String updatePath = "apkUpdate";
			File dir = context.getDir(updatePath, Context.MODE_WORLD_WRITEABLE);
			if (!dir.exists()) {
				dir.mkdirs();
			}
			//chmod("777", dir.getAbsolutePath());
			internalUpdatePath = dir.getAbsolutePath();
			if (!internalUpdatePath.endsWith(File.separator)) {
				internalUpdatePath = internalUpdatePath + File.separator;
			}
		}
		return internalUpdatePath;
	}
}
