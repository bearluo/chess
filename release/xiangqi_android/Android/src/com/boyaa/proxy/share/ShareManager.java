package com.boyaa.proxy.share;

import java.io.ByteArrayOutputStream;
import java.io.IOException;

import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.TargetApi;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Build;
import android.os.Bundle;
import android.widget.Toast;

import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.chinesechess.platform91.wxapi.SendToWXUtil;
import com.boyaa.entity.core.HandMachine;
import com.boyaa.made.FileUtil;
import com.boyaa.qqapi.SendToQQUtil;
import com.boyaa.share.NativeShare;
import com.boyaa.until.Util;
import com.boyaa.webview.WebViewManager;
import com.tencent.mm.opensdk.modelmsg.SendMessageToWX;
import com.tencent.mm.opensdk.modelmsg.WXImageObject;
import com.tencent.mm.opensdk.modelmsg.WXMediaMessage;
import com.tencent.mm.opensdk.openapi.IWXAPI;

public class ShareManager{
	public static final int TYPE_WEICHAT 		= 1;
	public static final int TYPE_PYQ 			= 2;
	public static final int TYPE_QQ 			= 3;
	public static final int TYPE_SMS 			= 4;
	public static final int TYPE_WEIBO 			= 5;
	public static final int TYPE_OTHER 			= 6;
	public static final int TYPE_IMG 	    	= 7;
	public static final int TYPE_LOCAL 	    	= 8;
	public  static IWXAPI api;
	private static String params = ""; // 活动分享透传字段
	public static void initWeChatApi(){
    	api = SendToWXUtil.getApi();
	}
	
	public static void share(int type, String line){
		//每次调用分享 清理 活动分享透传字段
		params = "";
		try {
			JSONObject msg = new JSONObject(line);
			boolean isPicture = (msg.optString("is_picture") == "" ? false : true);
			if (isPicture){// 分享截图
				String imageName = msg.optString("imageName");
				String path = FileUtil.getmStrImagesPath()+ imageName;
				Bitmap bm = BitmapFactory.decodeFile(path);
				shareImage(type, path, bm);
			}else{// 分享链接或其他
				distributeShare(line,type);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	private static void distributeShare(String data,int type) {

		switch(type){
		case TYPE_PYQ: 
			SendToWXUtil.shareToPYQ(data,"");
			break;
		case TYPE_WEICHAT: 
			SendToWXUtil.shareToWECHAT(data,"");
			break;
		case TYPE_QQ: 
			SendToQQUtil.shareToQQ(data,"");
			break;
		case TYPE_WEIBO: 
			NativeShare.shareTextToWeiBo(data);
			break;
		case TYPE_SMS: 
			if (Util.checkoutSimCard()){
				NativeShare.shareTextToSMS(data);
			}
			break;
		default:
			Game.mActivity.runOnUiThread(new Runnable() {
				@Override
				public void run() {
					// TODO Auto-generated method stub
					Toast.makeText(Game.mActivity, "分享失败", Toast.LENGTH_LONG).show();
				}
			});
			break;
		}
	}
	// 分享图片

	public static void shareImage(int type, String path, Bitmap bm) {
		if (bm == null){
			return;
		}
		switch(type){
		case TYPE_WEICHAT: //微信
			initWeChatApi();
			if (api == null){
				return;
			}
			SendMessageToWX.Req req = new SendMessageToWX.Req();
			WXImageObject image = new WXImageObject(bm);
			WXMediaMessage msg = new WXMediaMessage();
			msg.mediaObject = image;
			int h = bm.getHeight();
			int w = bm.getWidth();
			Bitmap bm_scale = Bitmap.createScaledBitmap(bm, w/2, h/2, true);
			bm.recycle();
			msg.thumbData = compressBitmapToData(bm_scale,32);
			req.message = msg;
			req.scene = SendMessageToWX.Req.WXSceneSession;
			api.sendReq(req);
			break;
		case TYPE_PYQ: //朋友圈
			initWeChatApi();
			if (api == null){
				return;
			}
			SendMessageToWX.Req req2 = new SendMessageToWX.Req();
			WXImageObject image2 = new WXImageObject(bm);
			WXMediaMessage msg2 = new WXMediaMessage();
			msg2.mediaObject = image2;
			int h2 = bm.getHeight();
			int w2 = bm.getWidth();
			Bitmap bm_scale2 = Bitmap.createScaledBitmap(bm, w2/2, h2/2, true);
			bm.recycle();
			msg2.thumbData = compressBitmapToData(bm_scale2,32);
			req2.message = msg2;
			req2.scene = SendMessageToWX.Req.WXSceneTimeline;
			api.sendReq(req2);
			break;
		case TYPE_QQ: //QQ
			SendToQQUtil.shareStartAdImg(path);
			break;
		case TYPE_WEIBO: //微博
			if (path == null){
				return;
			}
			NativeShare.shareImgToWeiBo(path);
			shareSuccess();
			break;
		case TYPE_SMS: //彩信
			if (path == null){
				return;
			}
			if (Util.checkoutSimCard()){
				NativeShare.shareImageToSMS(path);
				shareSuccess();
			}
			break;
		case TYPE_LOCAL://本地保存
			if (path == null || bm == null){
				return;
			}
			NativeShare.shareImageToLocal(path,bm);
			break;
		default:
			break;
		}
	}
	
	//压缩图片到指定大小
	public static byte [] compressBitmapToData(Bitmap bmp,float size) {  
        ByteArrayOutputStream output = new ByteArrayOutputStream();  
        byte [] result;
        try {  
            bmp.compress(Bitmap.CompressFormat.JPEG, 100, output);//质量压缩方法，这里100表示不压缩，把压缩后的数据存放到baos中  
            int options = 100;  
            while ( output.toByteArray().length / 1024 >= size) {  //循环判断如果压缩后图片是否大于size kb,大于继续压缩  
            	int s = output.toByteArray().length/1024;
            	output.reset();
                bmp.compress(Bitmap.CompressFormat.JPEG, options, output);//这里压缩options%，把压缩后的数据存放到baos中  
                if(options==1){  
                    break;  
                }  
                options -= 10;//每次都减少20  
                if(options<=0){  
                    options=1;  
                }  
            }  
            result = output.toByteArray();
            return result;
        } catch (Exception e) {  
            e.printStackTrace();  
            return null;  
        }finally {  
            try {  
                output.close();  
            } catch (IOException e) {  
                e.printStackTrace();  
            }  
        }  
    }
	/**
	 * 活动分享
	 * @param data
	 * @return
	 */
	@TargetApi(Build.VERSION_CODES.HONEYCOMB_MR1)
	public static void WXSend(Bundle data){
		params = data.getString("params", "");
		if( !SendToWXUtil.WXSend(data) ) {
			shareFail();
		}
	}
	public static void shareSuccess() {
		final JSONObject jsonObject = new JSONObject();
		WebViewManager.getActivityInstance().shareCallBack(true, params);
		Game.mActivity.runOnLuaThread(new Runnable() {
			@Override
			public void run() {
				// TODO Auto-generated method stub
				HandMachine.getHandMachine().luaCallEvent(
						HandMachine.kShareSuccessCallBack, jsonObject.toString());
			}
		});
	}

	public static void shareFail() {
		final JSONObject jsonObject = new JSONObject();
		WebViewManager.getActivityInstance().shareCallBack(false, params);
		Game.mActivity.runOnLuaThread(new Runnable() {
			@Override
			public void run() {
				// TODO Auto-generated method stub
				HandMachine.getHandMachine().luaCallEvent(
						HandMachine.kShareFailCallBack, jsonObject.toString());
			}
		});
	}
	
}
