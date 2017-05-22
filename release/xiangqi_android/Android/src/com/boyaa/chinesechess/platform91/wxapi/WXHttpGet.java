package com.boyaa.chinesechess.platform91.wxapi;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONException;
import org.json.JSONObject;

import android.util.Log;
import android.widget.Toast;

import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.entity.core.HandMachine;

public class WXHttpGet extends HttpGet implements Runnable{
	
	public WXHttpGet(String uri) {
		// TODO Auto-generated constructor stub
		super(uri);
	}
	
	public void Execute() {
		new Thread(this).start();
	}
	
	@Override
	public void run() {
		// TODO Auto-generated method stub
		HttpClient httpClient = new DefaultHttpClient();
		try {
			HttpResponse httpResponse = httpClient.execute(this);
			int code = httpResponse.getStatusLine().getStatusCode();
			switch(code) {
				case HttpURLConnection.HTTP_OK :
				{
					HttpEntity httpEntity = httpResponse.getEntity();
					InputStream inputStream = httpEntity.getContent();
					BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(inputStream));
					String str = "";
					StringBuffer buffer = new StringBuffer();
					while((str=bufferedReader.readLine())!=null) {
						buffer.append(str);
					}
					inputStream.close();
					String json = buffer.toString();
//					sendToLua(json);
					getUserInfo(json);
				}
				break;
				default :
				{
					sendToLua(null);
				}
				break;
			}
		} catch (ClientProtocolException e) {
			// TODO Auto-generated catch block
			sendToLua(null);
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			sendToLua(null);
			e.printStackTrace();
		}
	}
	
	public void getUserInfo(final String json) {
		try {
			JSONObject jsonObject = new JSONObject(json);
			String ACCESS_TOKEN = jsonObject.getString("access_token");
			String OPENID = jsonObject.getString("openid");
			final String url = Constants.userInfoUrl.replace("ACCESS_TOKEN", ACCESS_TOKEN).replace("OPENID", OPENID);
			new Thread(new Runnable() {
				
				@Override
				public void run() {
					// TODO Auto-generated method stub
					HttpClient httpClient = new DefaultHttpClient();
					try {
						HttpResponse httpResponse = httpClient.execute(new HttpGet(url));
						int code = httpResponse.getStatusLine().getStatusCode();
						switch(code) {
							case HttpURLConnection.HTTP_OK :
							{
								HttpEntity httpEntity = httpResponse.getEntity();
								InputStream inputStream = httpEntity.getContent();
								BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(inputStream));
								String str = "";
								StringBuffer buffer = new StringBuffer();
								while((str=bufferedReader.readLine())!=null) {
									buffer.append(str);
								}
								inputStream.close();
								String json = buffer.toString();
								sendToLua(json);
							}
							break;
							default :
							{
								sendToLua(null);
							}
							break;
						}
					} catch (ClientProtocolException e) {
						// TODO Auto-generated catch block
						sendToLua(null);
						e.printStackTrace();
					} catch (IOException e) {
						// TODO Auto-generated catch block
						sendToLua(null);
						e.printStackTrace();
					}
				}
			}).start();
		} catch (JSONException e) {
			// TODO: handle exception
			Game.mActivity.runOnUiThread(new Runnable() {
				
				@Override
				public void run() {
					// TODO Auto-generated method stub
					Toast.makeText(Game.mActivity, "微信授权信息获取失败", Toast.LENGTH_SHORT).show();
				}
			});
		}
		
	}
	
	public void sendToLua(final String json) {
		if(json != null)
			Log.e("WXHttpGet", json);
		else
			Log.e("WXHttpGet", "json is null");
		Game.mActivity.runOnLuaThread(new Runnable() {
			
			@Override
			public void run() {
				// TODO Auto-generated method stub
				HandMachine.getHandMachine().luaCallEvent("loginWeChat" , json);
			}
		});
	}
}
