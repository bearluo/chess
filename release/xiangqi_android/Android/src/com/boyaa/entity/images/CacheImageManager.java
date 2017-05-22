package com.boyaa.entity.images;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Date;
import java.util.TreeMap;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.Log;
import android.widget.Toast;

import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.entity.common.OnThreadTask;
import com.boyaa.entity.common.SDTools;
import com.boyaa.entity.common.ThreadTask;
import com.boyaa.entity.common.utils.JsonUtil;
import com.boyaa.entity.core.HandMachine;
import com.boyaa.entity.php.PHPPost;
import com.boyaa.made.AppActivity;
import com.boyaa.made.FileUtil;

public class CacheImageManager {
	
	public static void doDownLoadImage(String json) throws JSONException {
		JSONObject jsonResult = new JSONObject(json);
		String imageName = jsonResult.getString("ImageName");
		String imageUrl = jsonResult.getString("ImageUrl");
		String what = jsonResult.getString("what");
		new DownLoadImage(imageUrl, what, imageName).start();
	}
	
	private static class DownLoadImage {
		private static final String TAG = DownLoadImage.class.getSimpleName();
		private String urlString;
		private String what;
		private String imageName;
		
		public DownLoadImage(String urlString,String what,String imageName) {
			this.urlString = urlString;
			this.what = what;
			this.imageName = imageName;
		}
		
		public void start() {
			if(isExist()) {
				Log.e("aaa", "imageUrl:"+urlString+" imageName:"+imageName+" exist true");
				sendImageName(true);
				return ;
			}
			Log.e("aaa", "imageUrl:"+urlString+" imageName:"+imageName+" exist false");
			download();
		}
		
		public void download() {
			ThreadTask.start(AppActivity.mActivity , "",  false, new OnThreadTask() {
			    boolean savesucess = false;
				@Override
				public void onThreadRun() {
					Bitmap bitmap = PHPPost.loadPic(urlString);
					if (null != bitmap) {
						Log.i("DEBUG", "imageUrl = " + urlString + " big width = " + bitmap.getWidth()
								+ " height = " + bitmap.getHeight());
						savesucess = SDTools.saveBitmap(
								AppActivity.mActivity, FileUtil.getmStrImagesPath(), imageName , bitmap);
						bitmap.recycle();
						bitmap = null;
					}
				}

				@Override
				public void onAfterUIRun() {
					sendImageName(savesucess);
				}

				@Override
				public void onUIBackPressed() {
				
				}
			});
		}
		
		public boolean isExist() {
			String path = FileUtil.getmStrImagesPath() + imageName + ".png";
			Log.e(TAG,"fileName");
			File file = new File(path);
			if(file.exists()) {
				return true;
			}
			return false;
		}
		
		public void sendImageName(final boolean savesucess){
			AppActivity.mActivity.runOnLuaThread(new Runnable() {
				@Override
				public void run() {
					if (savesucess){
						Log.i(TAG, "sendImageName savesucess!!!");
						JSONObject jsonObject = new JSONObject();
						try {
							jsonObject.put("ImageName", imageName + ".png");
							jsonObject.put("what", what);
							jsonObject.put("urlString", urlString);
						} catch (JSONException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
							Log.i(TAG, "sendImageName savesucess!!! but json error");
							HandMachine.getHandMachine().luaCallEvent("CacheImageManager" , null);
						}
						HandMachine.getHandMachine().luaCallEvent("CacheImageManager" , jsonObject.toString());
					}else{
						HandMachine.getHandMachine().luaCallEvent("CacheImageManager" , null);
					} 
				}
			});
		}
	}
	
	public static void saveImageDCIM(String jsonData){
//		Date now = new Date();
//		long time = now.getTime();
		String imageName;
		int imageType;
		
		InputStream fosfrom;
		
		try{
			JSONObject jsonObject = new JSONObject(jsonData);
			imageName = jsonObject.optString("imageFile","");
			imageType = jsonObject.optInt("imageType",-2);
		}catch (JSONException e) {
			Toast.makeText(Game.mActivity, "抱歉，无法保存图片", 1000).show();
			return;
		}
        
		if(imageType == -1){
			String sourcePath = FileUtil.getmStrImagesPath() + imageName;
			Log.i("saveImageDCIM", "saveImageDCIM 源路径 " + sourcePath);
			File fromFile = new File(sourcePath);
			if(!fromFile.exists()){  
				Toast.makeText(Game.mActivity, "抱歉，保存失败，图片不存在", 1000).show();
				return;
	        }  
	          
	        if(!fromFile.isFile()){  
	        	Toast.makeText(Game.mActivity, "抱歉，保存失败，文件不存在", 1000).show();
	            return;  
	        }  
	        if(!fromFile.canRead()){
	        	Toast.makeText(Game.mActivity, "抱歉，保存失败，文件不可读", 1000).show();
	            return;  
	        }  
	        try {  
	        	fosfrom = new FileInputStream(fromFile); 
	        	FileDeal(fosfrom,imageName);
	        }catch (FileNotFoundException e) {  
	            // TODO Auto-generated catch block  
	        	Toast.makeText(Game.mActivity, "抱歉，保存失败，读取异常", 1000).show();
	            e.printStackTrace();
	        }
		}else if(imageType > -1){
			try { 
				fosfrom = Game.mActivity.getAssets().open("images" + File.separator + imageName);
				FileDeal(fosfrom,imageName);
			}catch (IOException e) {  
	            // TODO Auto-generated catch block 
	        	Toast.makeText(Game.mActivity, "抱歉，保存失败，读取异常。", 1000).show();
	            e.printStackTrace();  
	        }
		}else{
			return;
		}
	}
	
	public static void FileDeal(InputStream fosfrom, String imageName){
		String savePath = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DCIM).toString() + File.separator + "BoyaaChineseChess" + File.separator + imageName;
		Log.i("saveImageDCIM", "saveImageDCIM 保存路径 " + savePath);
		File toFile = new File(savePath);
        if(!toFile.getParentFile().exists()){  
            toFile.getParentFile().mkdirs();  
        }  
        if(toFile.exists()){  
        	Toast.makeText(Game.mActivity, "图片已存在", 1000).show();
        	return;
        }  
        
		try {  
            FileOutputStream fosto = new FileOutputStream(toFile);  
              
            byte[] bt = new byte[1024];  
            int c;  
            while((c=fosfrom.read(bt)) > 0){  
                fosto.write(bt,0,c);  
            }  
            //关闭输入、输出流  
            fosfrom.close();  
            fosto.close();  
            Toast.makeText(Game.mActivity, "图片已保存至"+savePath, 5000).show();
            
         // 其次把文件插入到系统图库
            try {
                MediaStore.Images.Media.insertImage(Game.mActivity.getContentResolver(),
                		toFile.getAbsolutePath(), "boyaa_"+imageName, null);
            } catch (FileNotFoundException e) {
                e.printStackTrace();
            }
         // 最后通知图库更新
            Game.mActivity.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.fromFile(new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DCIM).toString()))));
        } catch (FileNotFoundException e) {  
            // TODO Auto-generated catch block  
        	Toast.makeText(Game.mActivity, "抱歉，保存失败，读取异常！", 1000).show();
            e.printStackTrace();
        } catch (IOException e) {  
            // TODO Auto-generated catch block 
        	Toast.makeText(Game.mActivity, "抱歉，保存失败，读取异常.", 1000).show();
            e.printStackTrace();  
        }
	}
}
