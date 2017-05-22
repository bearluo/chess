package com.boyaa.made;

import android.content.Context;
import android.os.Bundle;
import android.os.Message;
import android.text.TextUtils;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.ProtocolException;
import java.util.HashMap;

import org.apache.http.HttpHost;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.params.HttpClientParams;
import org.apache.http.conn.ConnectTimeoutException;
import org.apache.http.conn.params.ConnRoutePNames;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.CoreConnectionPNames;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.params.HttpParams;
import org.apache.http.protocol.HTTP;
import org.apache.http.util.EntityUtils;

public class AppHttpPost implements Runnable {

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
	
	public final static int HTTP_REQUEST_NONE = 0;
	public final static int HTTP_REQUEST_CREATE = 1;
	public final static int HTTP_REQUEST_RUNING = 2;
	public final static int HTTP_REQUEST_FINISH = 3;

	public final static String kHttpRequestExecute = "http_request_execute";
	public final static String kHttpResponse = "http_response";
	public final static String KEventPrefix = "event_http_response";
	public final static String KEventPrefix_ = "event_http_response_";
	public final static String kId = "id";
	public final static String kStep = "step";
	public final static String kUrl = "url";
	public final static String kData = "data";
	public final static String kTimeout = "timeout";
	public final static String kEvent = "event";
	public final static String kAbort = "abort";
	public final static String kError = "error";
	public final static String kCode = "code";
	public final static String kRet = "ret";

	public int id;
	public String url;
	public String data;
	public int timeOut;
	public String event;

	// public int abort;
	public String ret;
	public int error;
	public int code;

	private static String GetDictName ( int id )
	{
		return String.format("http_request_%d", id);
	}

	public void Execute() {
		id = AppActivity.dict_get_int(kHttpRequestExecute, kId, 0);
		if (0 == id) {
			return;
		}
		String strDictName = GetDictName(id);
		event = AppActivity.dict_get_string(strDictName, kEvent);
		timeOut = AppActivity.dict_get_int(strDictName, kTimeout, 0);
		url = AppActivity.dict_get_string(strDictName, kUrl);
		data = AppActivity.dict_get_string(strDictName, kData);

		if ( timeOut < 1000 ) timeOut = 1000;

		Message msg = new Message();
		Bundle bundle = new Bundle();
		bundle.putInt(kId, id);
		bundle.putString(kEvent, event);
		msg.what = AppActivity.HANDLER_HTTPPOST_TIMEOUT;
		msg.setData(bundle);
		AppActivity.getHandler().sendMessageDelayed(msg,timeOut);

		AddMsg(id,msg);		
		new Thread(this).start();

	}

	@Override
	public void run() {

		ret = "";
		error = 0;
		code = 0;

		HttpPost postRequest = new HttpPost(url);
		HttpClient client = null;
		HttpResponse response = null;

		HttpParams httpParams = new BasicHttpParams();
		HttpConnectionParams.setConnectionTimeout(httpParams, timeOut);
		HttpConnectionParams.setSoTimeout(httpParams, timeOut);
		HttpConnectionParams.setSocketBufferSize(httpParams, 8 * 1024); // Socket数据缓存默认8K
		HttpConnectionParams.setTcpNoDelay(httpParams, false);
		HttpConnectionParams.setStaleCheckingEnabled(httpParams, false);
		HttpClientParams.setRedirecting(httpParams, false);
		client = new DefaultHttpClient(httpParams);

		setProxy(client);

		try {
			client.getParams().setParameter(CoreConnectionPNames.CONNECTION_TIMEOUT, timeOut);
			client.getParams().setParameter(CoreConnectionPNames.SO_TIMEOUT, timeOut);

			StringEntity entity = new StringEntity(data, HTTP.UTF_8);
			postRequest.setEntity(entity);
			postRequest.addHeader("content-type", "application/x-www-form-urlencoded");

			response = client.execute(postRequest);
			code = response.getStatusLine().getStatusCode();
			if (code == HttpURLConnection.HTTP_OK) {
				ret = EntityUtils.toString(response.getEntity());
			} else {
				// same as above ?
				ret = EntityUtils.toString(response.getEntity());
			}
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
		}
		
		Message msg = RemoveMsg(id);
		if ( null != msg )
		{
			final String strDictName = GetDictName(id);
			AppActivity.mActivity.runOnLuaThread(new Runnable()
			{
				@Override
				public void run() {
					AppActivity.dict_set_int(kHttpResponse, kId, id);
					AppActivity.dict_set_int(strDictName, kStep, HTTP_REQUEST_FINISH);
					AppActivity.dict_set_int(strDictName, kError, error);
					AppActivity.dict_set_int(strDictName, kCode, code);
					AppActivity.dict_set_string(strDictName, kRet, ret);
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
		final String strDictName = GetDictName(id);

		if ( null != RemoveMsg(id) )
		{
			AppActivity.mActivity.runOnLuaThread(new Runnable()
			{
				@Override
				public void run() {
					AppActivity.dict_set_int(kHttpResponse, kId, id);
					AppActivity.dict_set_int(strDictName, kStep, HTTP_REQUEST_FINISH);
					AppActivity.dict_set_int(strDictName, kError, 1);
					AppActivity.dict_set_int(strDictName, kCode, 0);
					AppActivity.dict_set_string(strDictName, kRet, "timeout");
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

//	设置代理
	private static void setProxy(HttpClient client) {
		Context context = AppActivity.mActivity.getApplication().getApplicationContext();
		boolean useProxy = APNUtil.hasProxy(context);
		if (useProxy) {
			String proxyIP = APNUtil.getApnProxy(context);
			int proxyPort = APNUtil.getApnPortInt(context);
			if(!TextUtils.isEmpty(proxyIP)){
				HttpHost proxy = new HttpHost(proxyIP, proxyPort);
				client.getParams().setParameter(ConnRoutePNames.DEFAULT_PROXY, proxy);
				return ;
			}
		}
		client.getParams().setParameter(ConnRoutePNames.DEFAULT_PROXY, null);
	}

}
