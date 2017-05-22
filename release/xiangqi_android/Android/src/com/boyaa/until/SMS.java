package com.boyaa.until;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;

import org.json.JSONException;
import org.json.JSONObject;

import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.entity.common.Log;
import com.boyaa.entity.core.HandMachine;
import com.boyaa.made.LuaEvent;

import android.app.Activity;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.telephony.SmsManager;
import android.widget.Toast;

public class SMS {
	/* 自定义ACTION常数，作为广播的Intent Filter识别常数 */
	private static String SMS_SEND_ACTIOIN = "SMS_SEND_ACTIOIN";
	private static String SMS_DELIVERED_ACTION = "SMS_DELIVERED_ACTION";
	/* 建立两个ServiceReceiver对象，作为类成员变量 */
	private static ServiceReceiver mReceiver01;
	private static ServiceReceiver mReceiver02;	  
	
	public static void parseSendContent(final String phoneNo,final String MsgConactName,final String MsgDownLoadUrl){
		new Thread(new Runnable() {
			
			@Override
			public void run() {
				if (phoneNo.length()>0 ){
		            int start = 0;
		            int end = 0;
		            while(start!=-1){
		             	end = phoneNo.indexOf("-",start+1);
		             	if(end==-1){
		             		String elem = phoneNo.substring(start);
		             		int nameEnd = elem.indexOf(",");
		             		String name;
		            		final String no;
		             		if(nameEnd!=-1){
		             			name = elem.substring(0, nameEnd);
		             			no = elem.substring(nameEnd+1);
		             		}else{
		            			name = "";
		             			no = elem;
		             		}
		             		  
		             		String url = MsgDownLoadUrl+no;
	
		             		getShortUrlFromGoogle(url,new ShortUrlCallBack() {
								
								@Override
								public void onSuccess(String shorturl) {
				            		StringBuffer sb = new StringBuffer();
				            		sb.append(no);
				            		sb.append("=");
				            		sb.append("一起来下博雅中国象棋，安装后帮我领取奖励！ Android下载地址：");
				            		sb.append(shorturl);			
				            		LuaEvent.sendMessage(HandMachine.kSendSms, HandMachine.HANDLER_SEND_SMS, sb.toString());
								}
								
								@Override
								public void onFail(String result) {
									
								}
							});

		             	}else{
		             		if(start!=0)
		             			start+=1;
		             		
		             		String elem = phoneNo.substring(start, end);
		 
		             		int nameEnd = elem.indexOf(",");
		             		String name;
		            		final String no;
		             		if(nameEnd!=-1){
		             			name = elem.substring(0, nameEnd);
		             			no = elem.substring(nameEnd+1);
		             		}else{
		            			name = "";
		             			no = elem;
		             		}
		             
		             		
		             		
		             		String url = MsgDownLoadUrl+no;
		             		
		             		getShortUrlFromGoogle(url,new ShortUrlCallBack() {
								
								@Override
								public void onSuccess(String shorturl) {
				            		StringBuffer sb = new StringBuffer();
				            		sb.append(no);
				            		sb.append("=");
				            		
				            		sb.append("一起来下博雅中国象棋，安装后帮我领取奖励！ Android下载地址：");
				            		sb.append(shorturl);	
				            		
				            		LuaEvent.sendMessage(HandMachine.kSendSms, HandMachine.HANDLER_SEND_SMS, sb.toString());
								}
								
								@Override
								public void onFail(String result) {
									
								}
							});
		             	}
		             	
		             	start = end;
		             	
		             	try {
							Thread.sleep(100);
						} catch (InterruptedException e) {
							e.printStackTrace();
						}
		             	
		            }	
		 
		    	}				
			}
		}).start();
	}
	
	public interface ShortUrlCallBack {
		public void  onSuccess(String url);
		public void  onFail(String result);
	}
	
    private static String getShortUrlFromGoogle(String longUrl,ShortUrlCallBack shortUrlCallBack) {
    	String shortUrl = null;
    	try {
        	String POST_URL = "http://dwz.cn/create.php";
        	
        	URL postUrl = new URL(POST_URL);
            HttpURLConnection connection = (HttpURLConnection) postUrl.openConnection();
            connection.setDoOutput(true);
            connection.setDoInput(true);
            connection.setRequestMethod("POST");
            connection.setUseCaches(false);
            connection.setInstanceFollowRedirects(true);
            connection.setRequestProperty("Content-Type","application/x-www-form-urlencoded");
            connection.connect();
            

            DataOutputStream out = new DataOutputStream(connection.getOutputStream());
            String strPost= "url=" + URLEncoder.encode(longUrl, "utf-8")  ;
      
            out.write(strPost.getBytes());    
            out.flush();
            out.close(); // flush and close
            
            
            BufferedReader reader = new BufferedReader(new InputStreamReader(
                    connection.getInputStream()));
            String line;

            StringBuffer result=new StringBuffer();
            while ((line = reader.readLine()) != null) {
            	result.append(line);
            }
        	try {
    			JSONObject object = new JSONObject(result.toString());
    			int status = object.getInt("status");
    			if(status==0){
    				shortUrl = object.getString("tinyurl");
    			}else{
    				shortUrl = longUrl;
    			}
	    			
    			shortUrlCallBack.onSuccess(shortUrl);
    		} catch (JSONException e) {
    			e.printStackTrace();
    			shortUrlCallBack.onFail(e.getMessage());
    		}
            reader.close();
            connection.disconnect();
		} catch (Exception e) {
			e.printStackTrace();
		}
    	
        return shortUrl;
    }
    
	//发短信
	public static void sendSMS(String content,Context ctx){
		if(content!=null){
			int end = content.indexOf("=");
			if(end!=-1){
				String phoneNumber = content.substring(0,end);
				
				if(phoneNumber!=null && phoneNumber.length()>0){
					int start = end+1;
					if(start<content.length()){
						String smsContent = content.substring(start);
	    	            SmsManager sms=SmsManager.getDefault();
	    	            /* 建立自定义Action常数的Intent(给PendingIntent参数之用) */
	    	            Intent itSend = new Intent(SMS_SEND_ACTIOIN);
	    	            Intent itDeliver = new Intent(SMS_DELIVERED_ACTION);
	                    PendingIntent mSendPI = PendingIntent.getBroadcast(ctx, 0, itSend, 0);    
	                    /* deliveryIntent参数为送达后接受的广播信息PendingIntent */
	                    PendingIntent mDeliverPI = PendingIntent.getBroadcast(ctx, 0, itDeliver, 0);

	    	        	if (smsContent.length() > 70) {
	    	        		ArrayList<String> msgs = sms.divideMessage(smsContent);
	    	        		for (String msg : msgs) {    
	    	                    sms.sendTextMessage(phoneNumber, null,msg, mSendPI, mDeliverPI);//发送信息到指定号码    
	    	                }
	    	        	} else {
		                    sms.sendTextMessage(phoneNumber, null,smsContent, mSendPI, mDeliverPI);//发送信息到指定号码    	        		}
	    	        	}
					}
					
				}
			}
			
		}
	}
	
	/* 自定义ServiceReceiver重写BroadcastReceiver监听短信状态信息 */
	protected static  class ServiceReceiver extends BroadcastReceiver{
		@Override
		public void onReceive(Context ctx, Intent intent) {
			if(intent.getAction() == SMS_SEND_ACTIOIN){
				switch(getResultCode()){
				case Activity.RESULT_OK:
					/* 发送短信成功 */			
					break;
				case SmsManager.RESULT_ERROR_GENERIC_FAILURE:

		            /* 发送短信失败 */
					Toast.makeText(Game.mActivity, "fail", Toast.LENGTH_SHORT).show();

					break;
	            case SmsManager.RESULT_ERROR_RADIO_OFF:
	                break;
	            case SmsManager.RESULT_ERROR_NULL_PDU:
	                break;
				}
				/* android.content.BroadcastReceiver.getResultCode()方法 */
		          //Retrieve the current result code, as set by the previous receiver.
			}else if(intent.getAction() == SMS_DELIVERED_ACTION){
				switch(getResultCode()){
	            case Activity.RESULT_OK:
	                /* 短信 */
					Toast.makeText(Game.mActivity, "到达", Toast.LENGTH_SHORT).show();
	            	break;
	            case SmsManager.RESULT_ERROR_GENERIC_FAILURE:
	                /* 短信未送达 */
					Toast.makeText(Game.mActivity, "短信未送达", Toast.LENGTH_SHORT).show();
	                break;
	            case SmsManager.RESULT_ERROR_RADIO_OFF:
	                break;
	            case SmsManager.RESULT_ERROR_NULL_PDU:
	            	break;
				}
			}
		}		
	}
	
	public static void registerReceiver(Context ctx){
	    /* 自定义IntentFilter为SENT_SMS_ACTIOIN Receiver */
	    IntentFilter mFilter01;
	    mFilter01 = new IntentFilter(SMS_SEND_ACTIOIN);
	    mReceiver01 = new ServiceReceiver();
	    ctx.registerReceiver(mReceiver01, mFilter01);
	    
	    /* 自定义IntentFilter为DELIVERED_SMS_ACTION Receiver */
	    mFilter01 = new IntentFilter(SMS_DELIVERED_ACTION);
	    mReceiver02 = new ServiceReceiver();
	    ctx.registerReceiver(mReceiver02, mFilter01);
	}
    
	public static void unregisterReceiver(Context ctx)
	{
	    /* 取消注册自定义Receiver */
		ctx.unregisterReceiver(mReceiver01);
		ctx.unregisterReceiver(mReceiver02);
	}
	
	
}
