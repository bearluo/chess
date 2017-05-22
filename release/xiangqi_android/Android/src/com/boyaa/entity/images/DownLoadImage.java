package com.boyaa.entity.images;
import java.util.TreeMap;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.graphics.Bitmap;
import android.util.Log;

import com.boyaa.entity.common.OnThreadTask;
import com.boyaa.entity.common.SDTools;
import com.boyaa.entity.common.ThreadTask;
import com.boyaa.entity.common.utils.JsonUtil;
import com.boyaa.entity.core.HandMachine;
import com.boyaa.entity.php.PHPPost;
import com.boyaa.made.AppActivity;
import com.boyaa.made.FileUtil;

public class DownLoadImage {
	
	private String strDicName;
	public DownLoadImage(){
		
	}
	public DownLoadImage(String strDicName ){
		this.strDicName = strDicName;
	}
	private String imageName = "";
	private boolean savesucess = false;
	
	public void doDownLoadPic(String loadData){
		
		JSONObject jsonResult = null;
		
		try {
			jsonResult = new JSONObject(loadData);
			imageName = jsonResult.getString("ImageName");
			final String imageUrl = jsonResult.getString("ImageUrl");
			//final String imageUrl = "http://tp4.sinaimg.cn/2040481282/50/5604388985/1";
			
			
			if (imageUrl.length() > 5) {
				// this.setPic(PHPPost.loadPic(picUri));
				/* 从URI地址拉图片过来 */
				ThreadTask.start(AppActivity.mActivity , "",  false, new OnThreadTask() {
				    boolean savesucess = false;
					@Override
					public void onThreadRun() {
						Bitmap bitmap = PHPPost.loadPic(imageUrl);
						if (null != bitmap) {
							Log.i("DEBUG", "imageUrl = " + imageUrl + " big width = " + bitmap.getWidth()
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

			}else{
				savesucess = false;
				sendImageName(savesucess);
			}
			
			
			
			
			
		} catch (JSONException e) {
			savesucess = false;
			sendImageName(savesucess);
		}
		
		
	}
	
	public void sendImageName(final boolean savesucess){
		AppActivity.mActivity.runOnLuaThread(new Runnable() {
			@Override
			public void run() {
				if (savesucess){
					Log.i("sendImageName", "ndImageName savesucess!!!");
					TreeMap<String, Object> map = new TreeMap<String, Object>();
					map.put("ImageName", imageName);
					JsonUtil json = new JsonUtil(map);
					String imageName = json.toString();
					HandMachine.getHandMachine().luaCallEvent(strDicName , imageName);
				}else{
					HandMachine.getHandMachine().luaCallEvent(strDicName , null);
				} 
			}
		});
	}
	
	
}
