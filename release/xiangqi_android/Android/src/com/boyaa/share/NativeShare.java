package com.boyaa.share;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.ActivityNotFoundException;
import android.content.ComponentName;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Bitmap.CompressFormat;
import android.net.Uri;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.Log;
import android.widget.Toast;

import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.chinesechess.platform91.R;
import com.boyaa.entity.common.SDTools;
import com.boyaa.made.FileUtil;
import com.boyaa.until.ScreenShot;

public class NativeShare {
	
	
	/**
	 * 截屏
	 */
	public static void takeShot(String img_name){
		System.out.println("NativeShare.takeShot");
		int mHeight = Game.mActivity.mHeight;
		int mWidth = Game.mActivity.mWidth;
		Bitmap bmp = ScreenShot.createBitmapFromGLSurface(0,0,mWidth,mHeight);
		SDTools.saveBitmapJPG(Game.mActivity, FileUtil.getmStrImagesPath(), img_name, bmp);
	}
	
	public static void shareImg(String img_name){
		
	      Intent intent=new Intent(Intent.ACTION_SEND);
	      
	      intent.setType("image/*");

	      String  path = FileUtil.getmStrImagesPath()+ img_name;
	      File f = new File(path);
	      Uri uri = Uri.fromFile(f);
	      
	      intent.putExtra(Intent.EXTRA_STREAM, uri);

//	      intent.putExtra(Intent.EXTRA_SUBJECT, "博雅中国象棋");
//	      intent.putExtra(Intent.EXTRA_TEXT, "博雅中国象棋");
//	      intent.putExtra(Intent.EXTRA_TITLE, "我是标题");  
	      Game.mActivity.startActivityForResult(Intent.createChooser(intent,"博雅中国象棋"),11);
		
	}

	public static void shareText(String text) {
		Intent intent=new Intent(Intent.ACTION_SEND);
		intent.setType("text/plain");
		intent.putExtra(Intent.EXTRA_SUBJECT, "博雅中国象棋");
		intent.putExtra(Intent.EXTRA_TEXT, text); 
		intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK); 
		Game.mActivity.startActivity(Intent.createChooser(intent,"博雅中国象棋"));
	}
	public static void shareTextAndImg(String text,String img_name) {
		Intent intent=new Intent(Intent.ACTION_SEND);
		intent.setType("image/*");
		String  path = FileUtil.getmStrImagesPath()+ img_name;
	    File f = new File(path);
	    Uri uri = Uri.fromFile(f);
	    intent.putExtra(Intent.EXTRA_STREAM, uri);
		intent.putExtra(Intent.EXTRA_SUBJECT, "博雅中国象棋");
		intent.putExtra(Intent.EXTRA_TEXT, text); 
		intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK); 
		Game.mActivity.startActivity(Intent.createChooser(intent,"博雅中国象棋"));
	}
	
	public static void shareTextToWeiBo(String json) {
		if (checkPackage("com.sina.weibo")) {
			String webpageUrl = null;
			String description = "";
			try {
				JSONObject jsonObject = new JSONObject(json);
				webpageUrl = jsonObject.getString("url");
				description = jsonObject.optString("description","");
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			String str = description + "  " + webpageUrl + "。";
			
			Intent intent=new Intent(Intent.ACTION_SEND);
			intent.setType("text/plain");
			intent.putExtra(Intent.EXTRA_SUBJECT, "博雅中国象棋");
			intent.putExtra(Intent.EXTRA_TEXT, str); 
			intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK); 
			intent.setPackage("com.sina.weibo");
			Game.mActivity.startActivity(Intent.createChooser(intent,"博雅中国象棋"));
		}else{
			Game.mActivity.runOnUiThread(new Runnable() {
				@Override
				public void run() {
					// TODO Auto-generated method stub
					Toast.makeText(Game.mActivity, "请先安装微博", Toast.LENGTH_SHORT).show();
					
				}
			});
		}
	}
	
	public static void shareImgToWeiBo(String path) {
		if (checkPackage("com.sina.weibo")) {
			Intent intent=new Intent(Intent.ACTION_SEND);
			intent.setType("image/*");
			intent.putExtra(Intent.EXTRA_SUBJECT, "博雅中国象棋");
			intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK); 
	        intent.setType("image/*"); 
	        File file = new File(path);
	        Uri u = Uri.fromFile(file);  
	        intent.putExtra(Intent.EXTRA_STREAM, u); 
			intent.setPackage("com.sina.weibo");
			Game.mActivity.startActivity(Intent.createChooser(intent,"博雅中国象棋"));
		}else{
			Game.mActivity.runOnUiThread(new Runnable() {
				@Override
				public void run() {
					// TODO Auto-generated method stub
					Toast.makeText(Game.mActivity, "请先安装微博", Toast.LENGTH_SHORT).show();
				}
			});
		}
	}
	
	public static void shareTextToSMS(String json) {
		String webpageUrl = null;
		String description = "";
		try {
			JSONObject jsonObject = new JSONObject(json);
			webpageUrl = jsonObject.getString("url");
			description = jsonObject.optString("description", "");
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		String str = description + "  " + webpageUrl;
		
		Uri smsToUri = Uri.parse("smsto:");
		Intent intent=new Intent(Intent.ACTION_VIEW,smsToUri);
		intent.putExtra("sms_body", str); 
		intent.setType("vnd.android-dir/mms-sms");
//		intent.setType("text/plain");
//		intent.putExtra(Intent.EXTRA_SUBJECT, "博雅中国象棋");
//		intent.putExtra(Intent.EXTRA_TEXT, text); 
		intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		Game.mActivity.startActivity(Intent.createChooser(intent,"博雅中国象棋"));
	}
	
	public static void shareImageToSMS(String path) {
		Intent intent=new Intent(Intent.ACTION_SEND);
		intent.setType("image/*");
		intent.putExtra(Intent.EXTRA_SUBJECT, "博雅中国象棋");
		intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK); 
        intent.setType("image/*"); 
        File file = new File(path);
        Uri u = Uri.fromFile(file);  
        intent.putExtra(Intent.EXTRA_STREAM, u); 
        intent.setPackage("com.android.mms"); 
		Game.mActivity.startActivity(Intent.createChooser(intent,"博雅中国象棋"));
	}
	
	public static void shareTextToPYQ(String text,String img) {
		Intent intent=new Intent(Intent.ACTION_SEND);
		ComponentName comp = new ComponentName("com.tencent.mm",                              
				   "com.tencent.mm.ui.tools.ShareToTimeLineUI");
		intent.setType("image/*");
		String  path = FileUtil.getmStrImagesPath() + img;
		Log.i("boyaa","share img:"+path);
		File f = new File(path);
		intent.putExtra(Intent.EXTRA_SUBJECT, "博雅中国象棋");
		intent.putExtra(Intent.EXTRA_TEXT, text); 
		intent.putExtra(Intent.EXTRA_STREAM, Uri.fromFile(f));
		intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK); 
		intent.setComponent(comp);
		Game.mActivity.startActivity(Intent.createChooser(intent,"博雅中国象棋"));
	}
	
	public static void shareTextToWeichat(String text,String img) {
		Intent intent=new Intent(Intent.ACTION_SEND);
		String  path = FileUtil.getmStrImagesPath() + img;
		Log.i("boyaa","share img:"+path);
		intent.setType("text/plain");
		File f = new File(path);
		
		ComponentName comp = new ComponentName("com.tencent.mm",                              
				   "com.tencent.mm.ui.tools.ShareImgUI");
		intent.putExtra(Intent.EXTRA_SUBJECT, "博雅中国象棋");
		intent.putExtra(Intent.EXTRA_TEXT, text);
//		if( f.exists() ) {
//			intent.putExtra(Intent.EXTRA_STREAM, Uri.fromFile(f));
//		}
		intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK); 
		intent.setComponent(comp);
		Game.mActivity.startActivity(Intent.createChooser(intent,"博雅中国象棋"));
	}
	
	public static void shareImageToLocal(String path, Bitmap bmp) {
	    String fileName = System.currentTimeMillis() + ".png";
	    File file = new File(path);
	    try {
	        FileOutputStream fos = new FileOutputStream(file);
	        bmp.compress(CompressFormat.PNG, 100, fos);
	        fos.flush();
	        fos.close();
	    } catch (FileNotFoundException e) {
	        e.printStackTrace();
	    } catch (IOException e) {
	        e.printStackTrace();
		}
	    
	    // 其次把文件插入到系统图库
	    try {
	        MediaStore.Images.Media.insertImage(Game.mActivity.getContentResolver(),
					file.getAbsolutePath(), fileName, null);
	    } catch (FileNotFoundException e) {
	        e.printStackTrace();
	    }
	    // 最后通知图库更新
	    Game.mActivity.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.parse("file://" + path)));
	    Toast.makeText(Game.mActivity, "保存成功", Toast.LENGTH_SHORT).show();
	}

	/**
	 * 
	 * 检测该包名所对应的应用是否存在
	 * 
	 * @param packageName
	 * 
	 * @return
	 */
	public static boolean checkPackage(String packageName)
	{
		if (packageName == null || "".equals(packageName))
			return false;
		try
		{
			Game.mActivity.getPackageManager().getApplicationInfo(packageName,
					PackageManager.GET_UNINSTALLED_PACKAGES);
			return true;
		}
		catch (NameNotFoundException e)
		{
			return false;
		}
	}
}
