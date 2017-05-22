package com.boyaa.chinesechess.platform91.wxapi;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.Map;
import java.util.UUID;

import org.json.JSONException;
import org.json.JSONObject;


import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.BitmapFactory.Options;
import android.os.Build;
import android.os.Bundle;
import android.widget.Toast;

import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.chinesechess.platform91.R;
import com.boyaa.made.FileUtil;
import com.tencent.mm.opensdk.modelbiz.OpenWebview;
import com.tencent.mm.opensdk.modelmsg.SendAuth;
import com.tencent.mm.opensdk.modelmsg.SendMessageToWX;
import com.tencent.mm.opensdk.modelmsg.WXImageObject;
import com.tencent.mm.opensdk.modelmsg.WXMediaMessage;
import com.tencent.mm.opensdk.modelmsg.WXTextObject;
import com.tencent.mm.opensdk.modelmsg.WXWebpageObject;
import com.tencent.mm.opensdk.modelpay.PayReq;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;
//import android.text.ClipboardManager;

@TargetApi(Build.VERSION_CODES.HONEYCOMB)
public class SendToWXUtil {
	
	public static IWXAPI api;
	public static String state;
	protected static String line = "share_to_wechat";
	
	protected static String webpageUrl = null;
	protected static String description = "博雅中国象棋";
	protected static String title = "博雅中国象棋";	
	
    public static void onCreate(Context context) {
    	api = WXAPIFactory.createWXAPI(context, Constants.APP_ID, false);
    	api.registerApp(Constants.APP_ID);
    }
    
    public static IWXAPI getApi(){
    	return api;
    }
    
    public static WXMediaMessage.IMediaObject getIMediaObjectById(final int type,final Bundle data) {
    	switch(type) {
	    	case WXMediaMessage.IMediaObject.TYPE_IMAGE:{
	    		WXImageObject imageObject = new WXImageObject();
	    		imageObject.imagePath = data.getString("imageUrl");
	    		return imageObject;
	    	}
//	    	break;
	    	case WXMediaMessage.IMediaObject.TYPE_TEXT:{
	    		WXTextObject textObject = new WXTextObject();
	    		textObject.text = data.getString("text");
	    		return textObject;
	    	}
//	    	break;
	    	case WXMediaMessage.IMediaObject.TYPE_URL:{
	    		WXWebpageObject webpageObject = new WXWebpageObject();
	    		webpageObject.webpageUrl = data.getString("webpageUrl");
	    		return webpageObject;
	    	}
//	    	break;
    	}
    	return null;
    }
    
    @SuppressLint("NewApi")
	public static boolean WXSend(Bundle data){

		// TODO Auto-generated method stub
		if (isWXAppInstalled()) {
            //提醒用户没有按照微信
            return false;
        }
		WXMediaMessage.IMediaObject mediaObject = getIMediaObjectById(data.getInt("type", 0),data);
		if ( mediaObject == null || mediaObject.checkArgs() == false) {
			Game.mActivity.runOnUiThread(new Runnable() {
				@Override
				public void run() {
					// TODO Auto-generated method stub
					Toast.makeText(Game.mActivity, "数据错误,发送失败", Toast.LENGTH_LONG).show();
				}
			});
			return false;
		}
		WXMediaMessage msg = new WXMediaMessage(mediaObject);
		Bitmap thumb = BitmapFactory.decodeResource(Game.mActivity.getResources(), R.drawable.shareicon);
		msg.setThumbImage(thumb);
		msg.description = data.getString("description","");
		msg.title = data.getString("title");
		SendMessageToWX.Req req = new SendMessageToWX.Req();
		req.transaction = buildTransaction("webpage");
		req.message = msg;
		req.scene = data.getInt("isTimeline") == 1 ? SendMessageToWX.Req.WXSceneTimeline : SendMessageToWX.Req.WXSceneSession;
		if (!api.sendReq(req)) {
			Game.mActivity.runOnUiThread(new Runnable() {
				@Override
				public void run() {
					// TODO Auto-generated method stub
					Toast.makeText(Game.mActivity, "发送失败", Toast.LENGTH_LONG).show();
				}
			});
			return false;
		}
		return true;
	}
    
    public static String buildTransaction(final String type) {
		return (type == null) ? String.valueOf(System.currentTimeMillis()) : type + System.currentTimeMillis();
	}
	
	public static void SendAuthToGetToken(){
		if (isWXAppInstalled()) {
            //提醒用户没有按照微信
            return;
        }
		SendAuth.Req req = new SendAuth.Req();
		req.scope = "snsapi_userinfo";
		state = UUID.randomUUID().toString();
		req.state = state;
		api.sendReq(req);
		
	}
	
	public static boolean isWXAppInstalled() {
		if (!api.isWXAppInstalled()) {
            //提醒用户没有按照微信
			Game.mActivity.runOnUiThread(new Runnable() {
				
				@Override
				public void run() {
					// TODO Auto-generated method stub
					Toast.makeText(Game.mActivity, "请先安装微信", Toast.LENGTH_LONG).show();
				}
			});
            return true;
        }
		return false;
	}
	
	@SuppressLint("DefaultLocale")
	public static boolean weixinPay (Map content){
		if (isWXAppInstalled()) {
            //提醒用户没有按照微信
            return false;
        }
    	JSONObject json;
		try {
			json = new JSONObject(content);
//			Log.i("weixinPay--start",json.toString());
			String appId 		=  json.getString("appId");
			String partnerId 	=  json.getString("partnerId");
			String prepayId 	=  json.getString("prepayId");
			String nonceStr 	=  json.getString("nonceStr");
			String timeStamp 	=  json.getString("timeStamp");
			String packageValue =  json.getString("packageValue");
			String extData 		=  json.getString("extData");
			String sign 		=  json.getString("sign");
			PayReq req = new PayReq();
			req.appId			= appId;
			req.partnerId		= partnerId;
			req.prepayId		= prepayId;
			req.nonceStr		= nonceStr;
			req.timeStamp		= timeStamp;
			req.packageValue	= packageValue;
			req.extData			= "";
			req.sign			= sign;
			api.sendReq(req);		
            return true;
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} 
        return false;
	}
	
	/**
	 * 分享微信好友
	 * @param json
	 * @param imgStr
	 * @data 2016.6.12
	 * @return
	 */
	public static boolean shareToWECHAT(String json,String imgStr) {
		if (isWXAppInstalled()) {
            //提醒用户没有按照微信
            return false;
        }
		if (!analyzeJsonData(json)){
			return false;
		}
		String  path = FileUtil.getmStrImagesPath() + imgStr;
		Bitmap thumb = BitmapFactory.decodeFile(path);
		String type = "weixin";
		weixinApi(thumb,setShareData(thumb),type);
		return true;
	}
	
	/**
	 * 分享朋友圈
	 * @param json
	 * @param imgStr
	 * @return
	 */
	public static boolean shareToPYQ(String json,String imgStr) {
		if (isWXAppInstalled()) {
            //提醒用户没有按照微信
            return false;
        }		
		if (!analyzeJsonData(json)){
			return false;
		}
		String  path = FileUtil.getmStrImagesPath() + imgStr;
		Bitmap thumb = BitmapFactory.decodeFile(path);
		String type = "pyq";
		weixinApi(thumb,setShareData(thumb),type);
		return true;
	}
	
	/**
	 * json数据解析并赋值
	 */
	protected static boolean analyzeJsonData(String jsonData){
		try {
			JSONObject jsonObject = new JSONObject(jsonData);
			webpageUrl = jsonObject.optString("url",""); //getString("url");
			description = jsonObject.optString("description", "博雅中国象棋"); //getString("description");
			title = jsonObject.optString("title","博雅中国象棋"); //getString("title");
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			dataNull();
			return false;
		}
		return true;
	}
	
	/**
	 * 分享数据内容
	 * @return 
	 */
	protected static WXMediaMessage setShareData(Bitmap thumb){
		WXWebpageObject webpage = new WXWebpageObject();
		webpage.webpageUrl = webpageUrl;
		WXMediaMessage msg = new WXMediaMessage(webpage);
		msg.title = title;
		msg.description = description;
		Options options = new Options();
		if( thumb == null) thumb = BitmapFactory.decodeResource(Game.mActivity.getResources(), R.drawable.shareicon);
		msg.setThumbImage(thumb);
		return msg;
	}
	
	/**
	 * 微信api
	 */
	protected static void weixinApi(Bitmap thumb,WXMediaMessage msg,String type){
		int temp = SendMessageToWX.Req.WXSceneSession;
		if (type == "weixin"){
			temp = SendMessageToWX.Req.WXSceneSession;
		}else if (type == "pyq"){
			temp = SendMessageToWX.Req.WXSceneTimeline;
			msg.title = description;
		}
		
		SendMessageToWX.Req req = new SendMessageToWX.Req();
		req.transaction = buildTransaction("webpage");
		req.message = msg;
		req.scene = temp;
		if(!api.sendReq(req)) {
			thumb = BitmapFactory.decodeResource(Game.mActivity.getResources(), R.drawable.shareicon);
			msg.setThumbImage(thumb);
			req.transaction = buildTransaction("webpage");
			req.message = msg;
			req.scene = temp;
			api.sendReq(req);
		}
	}
		
	/**
	 * json解析错误，提示分享失败
	 */
	protected static void dataNull(){
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
	 *  下面的都是bearluo 用于重构分享接口的 不要自己修改  如有一样功能 请自己重写
	 * 
	 */
	public static Bitmap compressBitmap(Bitmap bmp) throws IOException {
		int IMAGE_SIZE=32768;//微信分享图片大小限制 
		ByteArrayOutputStream output = new ByteArrayOutputStream();
		bmp.compress(Bitmap.CompressFormat.JPEG, 100, output);  
		int options = 100;
		while (output.toByteArray().length > IMAGE_SIZE && options != 10) {   
            output.reset(); //清空baos  
            bmp.compress(Bitmap.CompressFormat.PNG, options, output);//这里压缩options%，把压缩后的数据存放到baos中    
            options -= 10;  
        }
        bmp.recycle();  
        byte[] result = output.toByteArray();  
        output.close(); 
        return BitmapFactory.decodeByteArray(result, 0, result.length);
	}
	
	
	public static boolean shareToPYQ1(String content,String title,String description,Bitmap thumb) {
		boolean ret = false;
		if (isWXAppInstalled())return false;
		if (description == null || "".equals(description))description = "博雅中国象棋";
		if (title == null || "".equals(title))description = "博雅中国象棋";
		WXWebpageObject webpage = new WXWebpageObject();
		webpage.webpageUrl = content;
		WXMediaMessage msg = new WXMediaMessage(webpage);
		msg.title = title;
		msg.description = description;
		if( thumb == null) thumb = BitmapFactory.decodeResource(Game.mActivity.getResources(), R.drawable.shareicon);
		try {
			thumb = compressBitmap(thumb);
		} catch (IOException e) {
			thumb = BitmapFactory.decodeResource(Game.mActivity.getResources(), R.drawable.shareicon);
		}
		msg.setThumbImage(thumb);
		SendMessageToWX.Req req = new SendMessageToWX.Req();
		req.transaction = buildTransaction("webpage");
		req.message = msg;
		req.scene = SendMessageToWX.Req.WXSceneTimeline;
		ret = api.sendReq(req);
		if(!ret) {
			msg.setThumbImage(null);
			req.transaction = buildTransaction("webpage");
			req.message = msg;
			req.scene = SendMessageToWX.Req.WXSceneTimeline;
			ret = api.sendReq(req);
		}
		return ret;
	}
	/**
	 * 没有权限不能用
	 * @param url
	 */
	public static void openWechatWeb(String url) {
		if (isWXAppInstalled())return ;
		try{
			OpenWebview.Req req = new OpenWebview.Req();
			req.url = url;
			api.sendReq(req);
		}catch (Exception e) {
		}
	}
}
