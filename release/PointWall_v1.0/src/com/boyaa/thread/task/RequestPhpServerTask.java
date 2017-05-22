package com.boyaa.thread.task;

import java.util.HashMap;
import java.util.List;

import org.apache.http.message.BasicNameValuePair;

import android.util.Log;

import com.boyaa.http.HttpResult;
import com.boyaa.http.HttpUtil;
import com.boyaa.thread.ITask;

public class RequestPhpServerTask implements ITask{

	private String url;
	private String api;
	private OnCompleteHttpCallListener listener;
	private boolean needGzip;
	
	private List<BasicNameValuePair> params;
	private HashMap<String, String> hparam;
	private HttpResult result;
	public RequestPhpServerTask(String url, String api,OnCompleteHttpCallListener l) {
		super();
		this.url = url;
		this.api = api;
		this.listener = l;
	}
	public RequestPhpServerTask(String url, String api,OnCompleteHttpCallListener l,boolean needGzip) {
		this(url,api,l);
		this.needGzip = needGzip;
	}
	public RequestPhpServerTask(String sERVER_RUL,
			List<BasicNameValuePair> params, OnCompleteHttpCallListener l) {
			super();
			this.url = sERVER_RUL;
			this.listener = l;
			this.params = params;
	}
	public RequestPhpServerTask(String sERVER_RUL,
			HashMap<String, String> hparam, OnCompleteHttpCallListener l) {
			super();
			this.url = sERVER_RUL;
			this.listener = l;
			this.hparam = hparam;
	}
	public void execute() {
		
		// TODO Auto-generated method stub
		HashMap<String,String> apiHashMap = new HashMap<String, String>();
		apiHashMap.put("api", api);
		
		if(params != null){
			result = HttpUtil.post(url, params,false);
		}else if(hparam != null){
			result = HttpUtil.post(url, hparam,false);
		}else{
			result = HttpUtil.post(url, apiHashMap,needGzip);
		}

		
	}

	public void postExecute() {
		// TODO Auto-generated method stub
		
		Log.e("CHECK", "RequestPhpServerTask.postExecute = " + new String(result.result));
		if (listener!=null) {
			Log.e("CHECK", "RequestPhpServerTask.postExecute onComplete ");
			listener.onComplete(result);
		}
	}

	public static interface OnCompleteHttpCallListener{
		public void onComplete(HttpResult httpResult);
	}
}
