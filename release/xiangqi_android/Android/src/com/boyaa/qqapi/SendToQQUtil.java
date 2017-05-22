package com.boyaa.qqapi;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.widget.Toast;

import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.chinesechess.platform91.R;
import com.boyaa.chinesechess.platform91.wxapi.Alert.onAlertItemClick;
import com.boyaa.entity.common.Log;
import com.boyaa.entity.common.utils.UtilTool;
import com.boyaa.entity.core.HandMachine;
import com.tencent.connect.UserInfo;
import com.tencent.connect.common.Constants;
import com.tencent.connect.share.QQShare;
import com.tencent.tauth.IUiListener;
import com.tencent.tauth.Tencent;
import com.tencent.tauth.UiError;


public class SendToQQUtil {
	
	public static Tencent mTencent;
	private static IUiListener qqLoginListener;
	private static QQUIListener qqShareListener;
	private static IUiListener qqUserInfoListener;
	private static String scope;
	private static int toastTime = 10000;
	protected static String line = "share_to_qq";
	private static UserInfo userInfo;
	private static String token;
	private static String openId;
	private static String expireTime;
	private static String nickName;
	private static String figureurl_qq_1;
	private static String gender;
	private static String joData;
    public static void onCreate(Context context) {
    	mTencent = Tencent.createInstance(QQConstants.QQ_APP_ID, context);
    	setListener();
    }
    
    private static void setListener() {
    	qqLoginListener = new IUiListener() {
			


			@Override
			public void onError(UiError e) {
				// TODO Auto-generated method stub
				Log.e("onError:", "code:" + e.errorCode + ", msg:"
						+ e.errorMessage + ", detail:" + e.errorDetail);
				String str = "授权失败";
				Toast.makeText(Game.mActivity, str, toastTime).show();
			}
			
			@Override
			public void onComplete(Object o) {
				// TODO Auto-generated method stub
				JSONObject object = (JSONObject) o;  
		        try {  
		            Log.d("qqinfo", "onTencentComplete, object is " + object.toString());  
		            token = object.optString("access_token");  
		            openId = object.optString("openid");  
		            expireTime = object.optString("expires_in");  
		            //设置token
		            mTencent.setAccessToken(token, expireTime);
		            //设置openid
		            mTencent.setOpenId(openId); 
		            getUserInfo();
		            
		        } catch (Exception e) {  
		            e.printStackTrace();  
		        }  
			}
			
			@Override
			public void onCancel() {
				// TODO Auto-generated method stub
				Log.e("onCancel", "取消QQ授权");
				String str = "取消授权";
				Toast.makeText(Game.mActivity, str, toastTime).show();
			}
		};
		
		qqUserInfoListener = new IUiListener() {


			@Override
			public void onError(UiError arg0) {
				// TODO Auto-generated method stub
				
			}
			
			@Override
			public void onComplete(Object arg0) {
				// TODO Auto-generated method stub
				if(arg0 == null){
					return;
				}
				try {
					JSONObject jsonData = (JSONObject) arg0;
					nickName = jsonData.getString("nickname");
					String sex = jsonData.getString("gender");
					figureurl_qq_1 = jsonData.getString("figureurl_qq_1");
					if("男".equals(sex)){
						 gender = "1";
					 }else if("女".equals(sex)){
						 gender = "2";
					 }else{
						 gender = "0";
					 }
					requestLogin();
				} catch (Exception e) {
					// TODO: handle exception
				}
			}
			
			@Override
			public void onCancel() {
				// TODO Auto-generated method stub
				
			}
		}; 
		
    	qqShareListener = new QQUIListener();
		
	}
//	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
//    	if (null != mTencent)
//    	mTencent.onActivityResult(requestCode, resultCode, data);
//    } 
	
	public static void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (requestCode == Constants.REQUEST_LOGIN) {
			if (resultCode == Constants.ACTIVITY_OK) {
				Tencent.handleResultData(data, qqLoginListener);
			}
		}
	}
	
    /**
     * 判断qq是否可用
     * 
     * @param context
     * @return
     */
    protected static boolean isQQClientAvailable(Context context) {
        final PackageManager packageManager = context.getPackageManager();
        List<PackageInfo> pinfo = packageManager.getInstalledPackages(0);
        if (pinfo != null) {
            for (int i = 0; i < pinfo.size(); i++) {
                String pn = pinfo.get(i).packageName;
                if (pn.equals("com.tencent.mobileqq")) {
                    return true;
                }
            }
        }
        return false;
    }
    
    /**
     * QQ授权登陆
     */
    public static void qqAuthLogin(){
    	if (isQQInstalled()) {
            //提醒用户没有安装QQ
            return;
        }
    	scope = "all";
    	mTencent.login(Game.mActivity, scope, qqLoginListener);
    }
    
    public static boolean isQQInstalled(){
    	if (!isQQClientAvailable(Game.mActivity)) {
            //提醒用户没有安装QQ
			Game.mActivity.runOnUiThread(new Runnable() {
				@Override
				public void run() {
					// TODO Auto-generated method stub
					Toast.makeText(Game.mActivity, "请先安装QQ", Toast.LENGTH_LONG).show();
				}
			});
            return true;
        }
		return false;	
    }
    
    /**
     * 直接分享文本或链接
     * 
     * @param context
     * @return
     */
    public static void shareTextToQQ(String json,String imgStr) {
    	if (isQQInstalled()) {
            //提醒用户没有安装QQ
            return;
        }
    	
    	String webpageUrl = null;
		String description = "博雅中国象棋";
		try {
			JSONObject jsonObject = new JSONObject(json);
			webpageUrl = jsonObject.getString("download_url");
			description = jsonObject.optString("description","博雅中国象棋");
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			dataNull();
			return;
		}
    	
//    	UtilTool.sendCountToMain(line);
    	
		String path =  Game.mActivity.getResources().getString(R.string.boyaa_qq_share);  //qq分享图片链接地址
		String title = "博雅中国象棋";
		
        final Bundle params = new Bundle();
        params.putInt(QQShare.SHARE_TO_QQ_KEY_TYPE, QQShare.SHARE_TO_QQ_TYPE_DEFAULT);
        params.putString(QQShare.SHARE_TO_QQ_TITLE, title);
        params.putString(QQShare.SHARE_TO_QQ_SUMMARY,  description);
        params.putString(QQShare.SHARE_TO_QQ_TARGET_URL,  webpageUrl);
        params.putString(QQShare.SHARE_TO_QQ_IMAGE_URL,path);
        params.putString(QQShare.SHARE_TO_QQ_APP_NAME, null);
        params.putInt(QQShare.SHARE_TO_QQ_EXT_INT,  QQShare.SHARE_TO_QQ_FLAG_QZONE_ITEM_HIDE);		
        mTencent.shareToQQ(Game.mActivity, params, qqShareListener);
    }
    
    /**
     * 分享文本或链接
     * 
     * @param context
     * @return
     */
	
	public static class SendWebPageToQQ implements onAlertItemClick{

		@Override
		public void onClick(Bundle bundle) {
			// TODO Auto-generated method stub
			if (isQQInstalled()) {
	            //提醒用户没有安装QQ
	            return;
	        }
			
			UtilTool.sendCountToMain(line);
			
			String webpageUrl = bundle.getString("url");
			String title = bundle.getString("title");
			if ( title == null ) {
				title = "博雅中国象棋";
			}
			
			String path = Game.mActivity.getResources().getString(R.string.boyaa_qq_share);
			
	        final Bundle params = new Bundle();
	        params.putInt(QQShare.SHARE_TO_QQ_KEY_TYPE, QQShare.SHARE_TO_QQ_TYPE_DEFAULT);
	        params.putString(QQShare.SHARE_TO_QQ_TITLE, "残局："+title+"（博雅中国象棋）");
	        params.putString(QQShare.SHARE_TO_QQ_SUMMARY,  "残局："+title+"（博雅中国象棋）");
	        params.putString(QQShare.SHARE_TO_QQ_TARGET_URL,  webpageUrl);
	        params.putString(QQShare.SHARE_TO_QQ_IMAGE_URL,path);
	        params.putString(QQShare.SHARE_TO_QQ_APP_NAME, null);
	        params.putInt(QQShare.SHARE_TO_QQ_EXT_INT,  QQShare.SHARE_TO_QQ_FLAG_QZONE_ITEM_HIDE);		
	        mTencent.shareToQQ(Game.mActivity, params, new QQUIListener());
		}
	}
	
	 /**
     * 分享复盘
     * 
     * @param context
     * @return
     */
	public static class SendFPWebPageToQQ implements onAlertItemClick{

		@Override
		public void onClick(Bundle bundle) {
			// TODO Auto-generated method stub
			if (isQQInstalled()) {
	            //提醒用户没有安装QQ
	            return;
	        }
			
			UtilTool.sendCountToMain(line);
			
			String webpageUrl = bundle.getString("url");
			String title = "复盘演练（博雅中国象棋）";
			String description = "复盘让您回顾精彩对局";
			String path = Game.mActivity.getResources().getString(R.string.boyaa_qq_share);
			
	        final Bundle params = new Bundle();
	        params.putInt(QQShare.SHARE_TO_QQ_KEY_TYPE, QQShare.SHARE_TO_QQ_TYPE_DEFAULT);
	        params.putString(QQShare.SHARE_TO_QQ_TITLE, title);
	        params.putString(QQShare.SHARE_TO_QQ_SUMMARY,  description);
	        params.putString(QQShare.SHARE_TO_QQ_TARGET_URL,  webpageUrl);
	        params.putString(QQShare.SHARE_TO_QQ_IMAGE_URL,path);
	        params.putString(QQShare.SHARE_TO_QQ_APP_NAME, null);
	        params.putInt(QQShare.SHARE_TO_QQ_EXT_INT,  QQShare.SHARE_TO_QQ_FLAG_QZONE_ITEM_HIDE);		
	        mTencent.shareToQQ(Game.mActivity, params, new QQUIListener());
		}
	}
	
	
    public static void shareToQQ(String json,String imgStr) {
    	if (isQQInstalled()) {
            //提醒用户没有安装QQ
            return;
        }
    	
    	String webpageUrl = null;
		String description = "博雅中国象棋";
		String title = "博雅中国象棋";
		
		try {
			JSONObject jsonObject = new JSONObject(json);
			webpageUrl = jsonObject.getString("url");
			description = jsonObject.optString("description","博雅中国象棋");
			title = jsonObject.optString("title","博雅中国象棋");
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			dataNull();
			return;
		}
    	
//    	UtilTool.sendCountToMain(line);
    	
		String path =  Game.mActivity.getResources().getString(R.string.boyaa_qq_share);  //qq分享图片链接地址
		
        final Bundle params = new Bundle();
        params.putInt(QQShare.SHARE_TO_QQ_KEY_TYPE, QQShare.SHARE_TO_QQ_TYPE_DEFAULT);
        params.putString(QQShare.SHARE_TO_QQ_TITLE, title);
        params.putString(QQShare.SHARE_TO_QQ_SUMMARY,  description);
        params.putString(QQShare.SHARE_TO_QQ_TARGET_URL,  webpageUrl);
        params.putString(QQShare.SHARE_TO_QQ_IMAGE_URL,path);
        params.putString(QQShare.SHARE_TO_QQ_APP_NAME, null);
        params.putInt(QQShare.SHARE_TO_QQ_EXT_INT,  QQShare.SHARE_TO_QQ_FLAG_QZONE_ITEM_HIDE);		
        mTencent.shareToQQ(Game.mActivity, params, new QQUIListener());
    }
	
    public static void shareStartAdImg(String path){
    	if (isQQInstalled()) {
            //提醒用户没有安装QQ
            return;
        }
    	if (path == null){
    		return;
    	}
        final Bundle params = new Bundle();
        params.putString(QQShare.SHARE_TO_QQ_IMAGE_LOCAL_URL, path);
        params.putString(QQShare.SHARE_TO_QQ_APP_NAME,"博雅中国象棋");
        params.putInt(QQShare.SHARE_TO_QQ_KEY_TYPE, QQShare.SHARE_TO_QQ_TYPE_IMAGE);
        params.putInt(QQShare.SHARE_TO_QQ_EXT_INT,  QQShare.SHARE_TO_QQ_FLAG_QZONE_ITEM_HIDE);
        mTencent.shareToQQ(Game.mActivity, params, new QQUIListener());	
    }
    
	/**
	 * json解析错误，提示分享失败
	 */
	public static void dataNull(){
		Game.mActivity.runOnUiThread(new Runnable() {
			
			@Override
			public void run() {
				// TODO Auto-generated method stub
				Toast.makeText(Game.mActivity, "分享失败", Toast.LENGTH_LONG).show();
			}
		});
        return;
	}
	
	/**
	 * 获得QQ用户信息
	 */
	public static void getUserInfo(){
		userInfo = new UserInfo(Game.mActivity, mTencent.getQQToken());
		userInfo.getUserInfo(qqUserInfoListener);
	}

	/**
	 * 获得QQ用户信息成功后回调
	 */
	public static void requestLogin(){
		Map<String, Object>jsonMap = new HashMap<String, Object>();
		jsonMap.put("nickName", nickName);
		jsonMap.put("gender",gender);
		jsonMap.put("figureurl_qq_1",figureurl_qq_1);
		jsonMap.put("openId",openId);
		jsonMap.put("token",token);
		jsonMap.put("expireTime",expireTime);
		JSONObject obj = new JSONObject(jsonMap);
		joData = obj.toString();
		try{
			Game.mActivity.runOnLuaThread(new Runnable() {
				@Override
				public void run() {
					HandMachine.getHandMachine().luaCallEvent(HandMachine.kQQConnectLogin, joData);
				}
			});
			
		}catch (Exception e) {
			// TODO: handle exception
		}
	}
	
}
