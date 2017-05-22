package com.boyaa.entity.guest;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.UUID;

import com.boyaa.chinesechess.platform91.Game;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.os.Environment;
import android.util.Log;

public class uuidProxy {
	
	
	public static boolean inited = false;
	public static boolean working = false;
	private static String fileName = ".androidByUUID";
	private static String key = "new_uuid";
	private static String otherFileName = ".androidByOtherUUID";
	private static String otherKey = "new_other_uuid";
	
	
	public static void init() {
		if( inited ) return ;
		inited = true;
		sharedPreferences = Game.mActivity.getSharedPreferences("UUID", Context.MODE_PRIVATE);
		editor = sharedPreferences.edit();
		path = Game.mActivity.getPackageName();
	}
	
	public static void waitWorked() {
		while(working){ try {
			Thread.sleep(100);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} };
	}

	public static String getUUID() {
		waitWorked();
		working = true;
		init();
		
		String ret = getUUIDbySharedPreferences(key);
//		if( ret == null ) {
//			ret = getUUIDbyFiles();
//		}
		if( ret == null ) {
			ret = getUUIDbyExternalStorageFiles(Environment.getExternalStorageDirectory().getAbsolutePath()+"/"+path,fileName);
		}
		if( ret == null ) {
			ret = getUUIDbyExternalStorageFiles(Environment.getExternalStorageDirectory().getAbsolutePath(),fileName);
		}
		if( ret == null ) {
			ret = UUID.randomUUID().toString().replaceAll("-", "");
		}
		working = false;
		return ret;
	}
	
	public static void saveUUID(String uuid) {
		waitWorked();
		working = true;
		init();
		saveUUIDbySharedPreferences(uuid,key);
//		saveUUIDbyFiles(uuid);
		saveUUIDbyExternalStorageFiles(uuid,Environment.getExternalStorageDirectory().getAbsolutePath()+"/"+path,fileName);
		saveUUIDbyExternalStorageFiles(uuid,Environment.getExternalStorageDirectory().getAbsolutePath(),fileName);
		working = false;
	}
	/**
	 * 获得找回的用户id
	 * @return
	 */
	public static String getOtherUUID() {
		waitWorked();
		working = true;
		init();
		
		String ret = getUUIDbySharedPreferences(otherKey);
//		if( ret == null ) {
//			ret = getUUIDbyFiles();
//		}
		if( ret == null ) {
			ret = getUUIDbyExternalStorageFiles(Environment.getExternalStorageDirectory().getAbsolutePath()+"/"+path,otherFileName);
		}
//		if( ret == null ) {
//			ret = getUUIDbyExternalStorageFiles(Environment.getExternalStorageDirectory().getAbsolutePath(),otherFileName);
//		}
//		if( ret == null ) {
//			ret = UUID.randomUUID().toString().replaceAll("-", "");
//		}
		working = false;
		return ret;
	}
	/**
	 * 设置找回的id
	 * @param uuid
	 */
	public static void saveOtherUUID(String uuid) {
		waitWorked();
		working = true;
		init();
		saveUUIDbySharedPreferences(uuid,otherKey);
//		saveUUIDbyFiles(uuid);
		saveUUIDbyExternalStorageFiles(uuid,Environment.getExternalStorageDirectory().getAbsolutePath()+"/"+path,otherFileName);
//		saveUUIDbyExternalStorageFiles(uuid,Environment.getExternalStorageDirectory().getAbsolutePath(),otherFileName);
		working = false;
	}
	
	
	
	
//--------------------data/data/xxx------------------------	
	public static void saveUUIDbySharedPreferences(String uuid,String key) {
		init();
		editor.putString(key, uuid);
		editor.commit();
	}
	public static String getUUIDbySharedPreferences(String key) {
		init();
		return sharedPreferences.getString(key, null);
	}
//--------------------Storage/sdcard/xxx------------------------	
	public static void saveUUIDbyExternalStorageFiles(String uuid,String parentPath,String fileName) {
		init();
		Log.e("uuid","parentPath="+parentPath);
		if( Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED) ) {
			StringBuffer path = new StringBuffer();
			path.append(parentPath);
			File file = new File(path.toString());
			if( !file.exists() ) {
				if(!file.mkdirs()) {
					Log.e("lua android", "saveUUIDbyExternalStorageFiles fail 1");
					return ;
				}
			}
			path.append("/");
			path.append(fileName);
			file = new File(path.toString());
			if ( !file.exists() ) {
				try {
					if ( !file.createNewFile() ) {
						Log.e("lua android", "saveUUIDbyExternalStorageFiles fail 2");
						return ;
					}
				} catch (IOException e) {
					// TODO Auto-generated catch block
					Log.e("lua android", "saveUUIDbyExternalStorageFiles fail 3 "+ e.toString());
					return ;
				}
			}
			try {
				FileOutputStream fileOutputStream = new FileOutputStream(file);
				fileOutputStream.write(uuid.getBytes());
				fileOutputStream.flush();
				fileOutputStream.close();
			} catch (FileNotFoundException e) {
				// TODO Auto-generated catch block
				Log.e("lua android", "saveUUIDbyExternalStorageFiles FileOutputStream fail 4 "+ e.toString());
			} catch (IOException e) {
				// TODO Auto-generated catch block
				Log.e("lua android", "saveUUIDbyExternalStorageFiles FileOutputStream fail 5 "+ e.toString());
			}
			
		}
	}
	
	public static String getUUIDbyExternalStorageFiles(String parentPath,String fileName) {
		init();
		Log.e("uuid","parentPath="+parentPath);
		String ret = null;
		if( Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED) ) {
			StringBuffer path = new StringBuffer();
			path.append(parentPath);
			File file = new File(path.toString());
			if( !file.exists() ) {
				Log.e("lua android", "getUUIDbyExternalStorageFiles fail 1");
				return null;
			}
			path.append("/");
			path.append(fileName);
			file = new File(path.toString());
			if ( !file.exists() ) {
				Log.e("lua android", "getUUIDbyExternalStorageFiles fail 2");
				return null;
			}
			try {
				FileInputStream fileInputStream = new FileInputStream(file);
				int lenght = fileInputStream.available();
				byte[] bs = new byte[lenght];
				fileInputStream.read(bs);
				ret = new String(bs);
			} catch (FileNotFoundException e) {
				// TODO Auto-generated catch block
				Log.e("lua android", "getUUIDbyExternalStorageFiles FileInputStream fail 3 "+ e.toString());
			} catch (IOException e) {
				// TODO Auto-generated catch block
				Log.e("lua android", "getUUIDbyExternalStorageFiles FileInputStream fail 4 "+ e.toString());
			}
		}
		return ret;
	}
//------------------------ file ----------------
//	public static void saveUUIDbyFiles(String uuid) {
//		StringBuffer path = new StringBuffer();
//		path.append(Environment.getDataDirectory().toString());
////		path.append("/lib");
//		File file = new File(path.toString());
//		if( !file.exists() ) {
//			if(!file.mkdirs()) {
//				Log.e("lua android", "saveUUIDbyFiles fail 1");
//				return ;
//			}
//		}
////		Runtime runtime = Runtime.getRuntime();
////		try {
////			runtime.exec("chmod 777 " + path.toString()).waitFor();
////		} catch (InterruptedException e1) {
////			// TODO Auto-generated catch block
////			e1.printStackTrace();
////		} catch (IOException e1) {
////			// TODO Auto-generated catch block
////			e1.printStackTrace();
////		}
//		path.append("/");
//		path.append("UUID");
//		file = new File(path.toString());
//		if ( !file.exists() ) {
//			try {
//				if ( !file.createNewFile() ) {
//					Log.e("lua android", "saveUUIDbyFiles fail 2");
//					return ;
//				}
//			} catch (IOException e) {
//				// TODO Auto-generated catch block
//				Log.e("lua android", "saveUUIDbyFiles fail 3 "+ e.toString());
//				return ;
//			}
//		}
//		try {
//			FileOutputStream fileOutputStream = new FileOutputStream(file);
//			fileOutputStream.write(uuid.getBytes());
//			fileOutputStream.flush();
//			fileOutputStream.close();
//		} catch (FileNotFoundException e) {
//			// TODO Auto-generated catch block
//			Log.e("lua android", "saveUUIDbyFiles fileOutputStream fail 1 "+ e.toString());
//		} catch (IOException e) {
//			// TODO Auto-generated catch block
//			Log.e("lua android", "saveUUIDbyFiles fileOutputStream fail 2 "+ e.toString());
//		}
//	}
//	
//	
//	public static String getUUIDbyFiles() {
//		String ret = null;
//		StringBuffer path = new StringBuffer();
//		path.append(Environment.getDataDirectory().toString());
////		path.append("/lib");
//		File file = new File(path.toString());
//		if( !file.exists() ) {
//			Log.e("lua android", "getUUIDbyFiles fail 1");
//			return null;
//		}
//		path.append("/");
//		path.append("UUID");
//		file = new File(path.toString());
//		if ( !file.exists() ) {
//			Log.e("lua android", "getUUIDbyFiles fail 2");
//			return null;
//		}
//		try {
//			FileInputStream fileInputStream = new FileInputStream(file);
//			int lenght = fileInputStream.available();
//			byte[] bs = new byte[lenght];
//			fileInputStream.read(bs);
//			ret = new String(bs);
//		} catch (FileNotFoundException e) {
//			// TODO Auto-generated catch block
//			Log.e("lua android", "getUUIDbyFiles FileInputStream fail 3 "+ e.toString());
//		} catch (IOException e) {
//			// TODO Auto-generated catch block
//			Log.e("lua android", "getUUIDbyFiles FileInputStream fail 4 "+ e.toString());
//		}
//		return ret;
//	}
	
	
	private static SharedPreferences sharedPreferences;
	private static Editor editor;
	private static String path;
}
