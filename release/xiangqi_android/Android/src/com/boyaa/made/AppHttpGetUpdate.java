package com.boyaa.made;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.ProtocolException;
import java.util.HashMap;
import java.util.Timer;
import java.util.TimerTask;
import org.apache.http.HttpEntity;
import org.apache.http.HttpHost;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.conn.ConnectTimeoutException;
import org.apache.http.conn.params.ConnRoutePNames;
import org.apache.http.entity.BufferedHttpEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.os.Message;
import android.util.Log;

public class AppHttpGetUpdate implements Runnable {

	private static HashMap<Integer,Message> mMsgs = new HashMap<Integer,Message>();
	private static Object mSyncMsgs = new Object();
	public static void AddMsg ( int id, Message msg )
	{
		synchronized(mSyncMsgs)
		{
			mMsgs.put(id, msg);
		}
	}
	public static Message RemoveMsg ( int id )
	{
		Message msg = null;
		synchronized(mSyncMsgs)
		{
			if ( mMsgs.containsKey(id ))
			{
				msg = mMsgs.get(id);
				mMsgs.remove(id);
			}
		}
		return msg;
	}

	private final static String kHttpGetUpdateExecute = "http_get_update";
	private final static String KEventPrefix = "event_http_get_update_response";
	private final static String KEventPrefix_ = "event_http_get_update_response_";
	private final static String KEventTimePeriod = "event_http_get_update_timer_period";
	
	private final static String kId = "id";
	private final static String kUrl = "url";
	private final static String kSaveAs = "saveas";
	private final static String kTimeout = "timeout";
	private final static String kEvent = "event";
	private final static String kResult = "result";//flag of finish status
	private final static String kTimerPeriod = "timerPeriod";

	private final static int kResultSuccess = 1;
	private final static int kResultTimeout = 0;
	private final static int kResultError = -1;
	private final static int kBufferSize = 1024*4;
	
	private int id;
	private String url;
	private String savePath;
	private int timeOut;
	private String event;
	private int result; 
	private long hasRead;
	private long percentage;
	private long size;
	private int timerPeriod;
	private Timer timer;
	private static String GetDictName ( int id )
	{
		return String.format("%s%d",kHttpGetUpdateExecute,id);
	}
	public void Execute() {
		
		result = kResultError;	
		id = AppActivity.dict_get_int(kHttpGetUpdateExecute, kId, -1);
		if (-1 == id) {
			//FIXME
			return;
		}
		String strDictName = GetDictName ( id );

		url = AppActivity.dict_get_string(strDictName, kUrl);
		savePath = AppActivity.dict_get_string(strDictName, kSaveAs);
		timeOut = AppActivity.dict_get_int(strDictName, kTimeout,0);
		event = AppActivity.dict_get_string(strDictName, kEvent);
		timerPeriod = AppActivity.dict_get_int(strDictName, kTimerPeriod,0);
		
		if ( timeOut < 1000 ) timeOut = 1000;

		Message msg = new Message();
		Bundle bundle = new Bundle();
		bundle.putInt(kId, id);
		bundle.putString(kEvent, event);
		msg.what = AppActivity.HANDLER_HTTPGET_UPDATE_TIMEOUT;
		msg.setData(bundle);
		AppActivity.getHandler().sendMessageDelayed(msg,timeOut);
		
		AddMsg(id,msg);
		StartTimer(timerPeriod);
		new Thread(this).start();
	}
	
	@Override
	public void run() {

		Message msg = null;
		int error = 0;
		String ret = "";
		try {
		    DefaultHttpClient client = new DefaultHttpClient();

		    HttpGet httpGet = new HttpGet(url);
		    HttpResponse response = client.execute(httpGet);
		    msg = RemoveMsg(id);
		    
			int code = response.getStatusLine().getStatusCode();
			if (code == HttpURLConnection.HTTP_OK) {				
		        if ( null != msg )
		        {
					HttpEntity entity = response.getEntity();
					String strPathLowCase = savePath.toLowerCase();
					int len = strPathLowCase.length() - 4;
					if ( len == strPathLowCase.lastIndexOf(".png"))
		        	{
		        		BufferedHttpEntity bufEntity = new BufferedHttpEntity(entity);
		        		Bitmap bmp = BitmapFactory.decodeStream(bufEntity.getContent());
		        		FileOutputStream fos = new FileOutputStream(savePath);
		        		bmp.compress(Bitmap.CompressFormat.PNG,100, fos);
		        		fos.flush();
		        		fos.close();
		        	}
		        	else
		        	{
		        		InputStream inputStream = entity.getContent();  
		        		FileOutputStream outputStream = new FileOutputStream(savePath);  
		        		size = entity.getContentLength();
		        		byte []buffer = new byte[kBufferSize];
		        		
		        		class Finish{boolean isFinial=false;};
		        		final Finish finish = new Finish();
		        		
		        		do{  
		        			final Timer downtimer = new Timer();
		        			downtimer.schedule(new TimerTask() {
		        				@Override
		        				public void run() {
		        					noticeTimeout();
		        					finish.isFinial = true;
		        					if (null != downtimer) {
				        				downtimer.cancel();
				        			}
		        				}
		        			}, 10000);
		        			
		        			len = inputStream.read(buffer);
		        			
		        			if (null != downtimer) {
		        				downtimer.cancel();
		        			}
		        			
		        			if(finish.isFinial)
		        				break;
		        			
		        			if (len < 0) {
		        				noticeTimeout();
		                        break;  
		                    } 
		        			outputStream.write(buffer,0,len);  
		        			hasRead += len;  
		        			percentage = (hasRead*100)/size;  
		        			
		        			if(hasRead == size)
		        			{
		        				break;
		        			}
		        			
		        		}while(true);
		        		outputStream.flush();
		        		outputStream.close(); 
		        		inputStream.close();
		        	}
		        }

			} else {
				ret = String.format("status code %d", code);
				error = 1;
			}
		}catch (ClientProtocolException e){
			error = 1;
			ret = e.toString();		
		} catch (MalformedURLException e) {
			error = 1;
			ret = e.toString();
		} catch (ProtocolException e) {
			error = 1;
			ret = e.toString();

		} catch (ConnectTimeoutException e) {
			error = 1;
			ret = e.toString();
		} catch (IOException e) {
			error = 1;
			ret = e.toString();
		} catch (Exception e) {
			error = 1;
			ret = e.toString();
		} finally {
			CancelTimer();
		}
		if ( 1 == error )
		{
			Log.d("AppHttpGetUpdate", ret);
		}
		else
		{
			result = kResultSuccess;
		}

		if ( null != msg )
		{
			AppActivity.mActivity.runOnLuaThread(new Runnable()
			{
				@Override
				public void run() {
					String strDictName = GetDictName ( id );	
					AppActivity.dict_set_int(kHttpGetUpdateExecute, kId, id);
					AppActivity.dict_set_int(strDictName, kResult, result);
					String strFunc;
					if (null == event) {
						strFunc = KEventPrefix;
					} else {
						strFunc = KEventPrefix_ + event;
					}
					AppActivity.call_lua(strFunc);
				}
			});
		}
	}
	public static void HandleTimeout ( Message msg )
	{
		Bundle bundle = msg.getData();
		final int id = bundle.getInt(kId);
		final String event = bundle.getString(kEvent);
		if ( null != RemoveMsg(id) )
		{
			AppActivity.mActivity.runOnLuaThread(new Runnable()
			{
				@Override
				public void run() {
					String strDictName = GetDictName ( id );
					AppActivity.dict_set_int(kHttpGetUpdateExecute, kId, id);
					AppActivity.dict_set_int(strDictName, kResult, kResultTimeout);

					String strFunc;
					if (null == event) {
						strFunc = KEventPrefix;
					} else {
						strFunc = KEventPrefix_ + event;
					}
					AppActivity.call_lua(strFunc);
				}
			});
		}
	}
	
	private void StartTimer(int period){ 
		if(period <= 0){
			return;
		}
		timer=new Timer();
		timer.schedule(new TimerTask() {           
		            @Override
		            public void run() {
		            	if(percentage == 100){
		            		CancelTimer();
		            	}else{		            		
		            		noticePercentage();
		            	}
		            }
		        }, 0,period); 
	}
	
	private void CancelTimer(){
		if(null != timer){
			noticePercentage();
			timer.cancel();
		}
	}
	
	private void noticePercentage(){
		AppActivity.mActivity.runOnLuaThread(new Runnable()
		{
			@Override
			public void run() {
				String strDictName = GetDictName ( id );
				AppActivity.dict_set_int(kHttpGetUpdateExecute, kId, id);
				AppActivity.dict_set_double(strDictName, kResult, percentage);
				AppActivity.call_lua(KEventTimePeriod);
			}
		});
	}
	
	private void noticeTimeout(){
		AppActivity.mActivity.runOnLuaThread(new Runnable()
		{
			@Override
			public void run() {
				String strDictName = GetDictName ( id );
				AppActivity.dict_set_int(kHttpGetUpdateExecute, kId, id);
				AppActivity.dict_set_int(strDictName, kResult, kResultTimeout);
				
				String strFunc;
				if (null == event) {
					strFunc = KEventPrefix;
				} else {
					strFunc = KEventPrefix_ + event;
				}
				AppActivity.call_lua(strFunc);
			}
		});
	}
}
