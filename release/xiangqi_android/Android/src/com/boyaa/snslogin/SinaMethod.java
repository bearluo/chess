package com.boyaa.snslogin;

import java.io.IOException;
import java.security.KeyStore;
import java.util.ArrayList;
import java.util.List;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.HttpVersion;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpUriRequest;
import org.apache.http.conn.ClientConnectionManager;
import org.apache.http.conn.scheme.PlainSocketFactory;
import org.apache.http.conn.scheme.Scheme;
import org.apache.http.conn.scheme.SchemeRegistry;
import org.apache.http.conn.ssl.SSLSocketFactory;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.impl.conn.tsccm.ThreadSafeClientConnManager;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.HttpParams;
import org.apache.http.params.HttpProtocolParams;
import org.apache.http.protocol.HTTP;
import org.apache.http.util.EntityUtils;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;

import com.boyaa.chinesechess.platform91.R;
import com.boyaa.chinesechess.platform91.SinaAuthActivity;

public class SinaMethod implements ISNSInterface{
	public static  String kAppKey          =    "3751187183";
	public static  String  kAppSecret        =  "2cf290f812ab2ce55e7df1235e4f9251";
	public static  String  kAppRedirectURI   =  "https://api.weibo.com/oauth2/default.html";
	private AuthCallBack authCallBack;
	private AuthBroadcast mAuthBroadcast;
	private AuthCallBack loginCallBack;
	private Context mCtx;
	public static String WEIBO_AUTH_ACTION = "weibo_auth_action";
	
	public SinaMethod(Context ctx){
		mCtx = ctx;
	}
	
	@Override
	public void auth(AuthCallBack authCallBack) {
		this.authCallBack = authCallBack;
    	registerReceiver();
		Intent intent = new Intent();
		intent.setClass(mCtx, SinaAuthActivity.class);
		mCtx.startActivity(intent);
	}

	@Override
	public void Login(final AuthCallBack loginCallBack) {
		this.loginCallBack = loginCallBack;
		auth(new AuthCallBack() {
			
			@Override
			public void onSuccess(UserInfo userInfo) {
				getUserInfo(userInfo);
				clearAuthReceiver();
			}
			
			@Override
			public void onFail(String result) {
				loginCallBack.onFail(result);
				clearAuthReceiver();
			}
		});
	}

	@Override
	public void clearAuthReceiver() {
		if (mAuthBroadcast!=null) {
			mCtx.unregisterReceiver(mAuthBroadcast);
		}
	}

	
	private void registerReceiver() {
		// 注册广播
		mAuthBroadcast = new AuthBroadcast();
		IntentFilter filter = new IntentFilter();
		filter.addAction(SinaMethod.WEIBO_AUTH_ACTION);
		mCtx.registerReceiver(mAuthBroadcast, filter);
	}
	
	
	private class AuthBroadcast extends BroadcastReceiver {

		@Override
		public void onReceive(Context context, Intent intent) {
			String code = intent.getStringExtra("code");
			if ( null != code && !code.equals("") ) {
				getAccessToken(code);
			}else {
				authCallBack.onFail(mCtx
				.getString(R.string.verified_failed));
			}
		}
	}
	
	public boolean satisfyConditions(String access_token,String expires_in,String uid) {
		return 	access_token != null && 
				expires_in != null && 
			    uid != null && 
				!access_token.equals("") && 
				!access_token.equals("") && 
				!expires_in.equals("");
	}
	
	private void getAccessToken(final String code) {
		new Thread(new Runnable() {
			
			@Override
			public void run() {	
			
				String result=null;
				HttpPost httpRequst = new HttpPost("https://api.weibo.com/oauth2/access_token");    
				List <NameValuePair> params = new ArrayList<NameValuePair>();  
		        params.add(new BasicNameValuePair("client_id", kAppKey)); 
		        params.add(new BasicNameValuePair("client_secret", kAppSecret)); 
		        params.add(new BasicNameValuePair("grant_type", "authorization_code")); 
		        params.add(new BasicNameValuePair("redirect_uri", kAppRedirectURI)); 
		        params.add(new BasicNameValuePair("code", code)); 
				HttpResponse httpResponse=null;
				try {
					httpRequst.setEntity(new UrlEncodedFormEntity(params,HTTP.UTF_8)); 
					httpResponse = (HttpResponse) getNewHttpClient().execute(httpRequst);
					if(httpResponse.getStatusLine().getStatusCode() == 200) {
						HttpEntity httpEntity = httpResponse.getEntity();  
		                result = EntityUtils.toString(httpEntity);//取出应答字符串
		                JSONObject jsonObject = new JSONObject(result);
		    			String token = jsonObject.getString("access_token");
		    			String expires_in = jsonObject.getString("expires_in");
		    			String uid = jsonObject.getString("uid");
		    			if (satisfyConditions(token,expires_in,uid)) {	
		    				UserInfo userInfo=new UserInfo(); 
		    				userInfo.setAccessToken(token);
		    				userInfo.setOpenid(uid);
		    				userInfo.setOpenid(uid);
		    				userInfo.setExpiresIn(expires_in);
		    				authCallBack.onSuccess(userInfo);
		    			}else {
		    				authCallBack.onFail(mCtx
		    						.getString(R.string.verified_failed));
		    			}
					}else {
						if(loginCallBack!=null){
							loginCallBack.onFail(mCtx.getString(R.string.verified_failed));
						}
					}
				} catch (ClientProtocolException e1) {
					e1.printStackTrace();
					if(loginCallBack!=null){
						loginCallBack.onFail(mCtx.getString(R.string.verified_failed));
					}
				} catch (IOException e1) {
					e1.printStackTrace();
					if(loginCallBack!=null){
						loginCallBack.onFail(mCtx.getString(R.string.verified_failed));
					}
				} catch (JSONException e) {
					e.printStackTrace();
					if(loginCallBack!=null){
						loginCallBack.onFail(mCtx.getString(R.string.verified_failed));
					}
				}
			}
		}).start();
	}
	
	private void getUserInfo(final UserInfo userInfo){
		
		new Thread(new Runnable() {
			
			@Override
			public void run() {	
				StringBuilder sb = new StringBuilder();			
				sb.append("https://api.weibo.com/2/users/show.json?source=");
				sb.append(kAppKey);
				sb.append("&access_token=");
				sb.append(userInfo.getAccessToken());
				sb.append("&uid=");
				sb.append(userInfo.getOpenid());
			
				String result=null;
				HttpUriRequest request = new HttpGet(sb.toString());    
				
				HttpResponse httpResponse=null;
				try {
					httpResponse = (HttpResponse) getNewHttpClient().execute(request);
				} catch (ClientProtocolException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				} catch (IOException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
				
				try {
					 result=EntityUtils.toString(httpResponse.getEntity());		
                     
					 if(httpResponse.getStatusLine().getStatusCode() == 200 && result!=null && result!=""){//
				
						 JSONObject object = new JSONObject(result);
						 
						 if(object!=null){
							 String id = null;
							 try{
								 id = object.getString("id");
							 }catch(Exception e){
								 e.printStackTrace();
							 }

							 if(id!=null && !"".equals(id)){
								 String screen_name = object.getString("screen_name");
								 String gender = object.getString("gender");
								 String avatar_large = object.getString("avatar_large");
								 if("m".equals(gender)){
									 gender = "1";
								 }else if("f".equals(gender)){
									 gender = "2";
								 }else{
									 gender = "0";
								 }
								 
								 userInfo.setNickname(screen_name);
								 userInfo.setGender(gender);
								 userInfo.setAvatarLarge(avatar_large);
								 if(loginCallBack!=null){
									 loginCallBack.onSuccess(userInfo);
								 }
							 }else{
								 if(loginCallBack!=null){
									 loginCallBack.onFail(mCtx.getString(R.string.verified_failed));
								 } 
							 }
						 }else{
							 if(loginCallBack!=null){
								 loginCallBack.onFail(mCtx.getString(R.string.verified_failed));
							 }
						 }
					 }else{
						 if(loginCallBack!=null){
							 loginCallBack.onFail(mCtx.getString(R.string.verified_failed));
						 }
					 }
				} catch (Exception e) {
					e.printStackTrace();
				}

			}
		}).start();
	}
	
	
	public void getUserInfo(final UserInfo userInfo ,final  AuthCallBack  mAuthCallBack){
		new Thread(new Runnable() {
			
			@Override
			public void run() {	
				StringBuilder sb = new StringBuilder();					
				sb.append("https://api.weibo.com/2/users/show.json?source=");
				sb.append(kAppKey);
				sb.append("&access_token=");
				sb.append(userInfo.getAccessToken());
				sb.append("&uid=");
				sb.append(userInfo.getOpenid());
							
				HttpUriRequest request = new HttpGet(sb.toString());    
		
				HttpResponse httpResponse=null;
				try {
					httpResponse = (HttpResponse) getNewHttpClient().execute(request);
				} catch (ClientProtocolException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				} catch (IOException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
				
				String result=null;
				try {						
					 result=EntityUtils.toString(httpResponse.getEntity());
				     
					 if(httpResponse.getStatusLine().getStatusCode() == 200 && result!=null && result!=""){
						 JSONObject object = new JSONObject(result);
						 if(object!=null){
							 String error = null;
							 String error_code =null;
							 try{
								 error = object.getString("error");
								 error_code = object.getString("error_code");
							 }catch(Exception e){
								 e.printStackTrace();
							 }

							 if(error_code!=null && ("21301".equals(error_code)
										|| "21314".equals(error_code)
										|| "21315".equals(error_code)
										|| "21316".equals(error_code)
										|| "21317".equals(error_code)
										|| "21325".equals(error_code)
										|| "21327".equals(error_code) || "21501"
										.equals(error_code))){
								 
								 if(mAuthCallBack!=null){
									 mAuthCallBack.onFail(error);
								 }
//								 LuaEvent.sendMessage(HandMachine.kLoginWithWeibo , HandMachine.HANDLER_LOGIN_WITH_WEIBO);
							 }else{
							
								 String id = null;
								 try{
									 id = object.getString("id");
								 }catch(Exception e){
									 e.printStackTrace();
								 }
								 
								 if(id!=null && !"".equals(id)){
									 String screen_name = object.getString("screen_name");
									 String gender = object.getString("gender");
		 
									 if("m".equals(gender)){
										 gender = "1";
									 }else if("f".equals(gender)){
										 gender = "2";
									 }else{
										 gender = "0";
									 }
									 
									 userInfo.setNickname(screen_name);
									 userInfo.setGender(gender);
									 if(mAuthCallBack!=null){
										 mAuthCallBack.onSuccess(userInfo);
									 }
								 }else{
									 if(mAuthCallBack!=null){
										 mAuthCallBack.onFail(mCtx.getString(R.string.verified_failed));
									 } 	
//									 LuaEvent.sendMessage(HandMachine.kLoginWithWeibo , HandMachine.HANDLER_LOGIN_WITH_WEIBO);
								 }
							 }
						 }else{
							 if(mAuthCallBack!=null){
								 mAuthCallBack.onFail(mCtx.getString(R.string.verified_failed));
							 } 
//							 LuaEvent.sendMessage(HandMachine.kLoginWithWeibo , HandMachine.HANDLER_LOGIN_WITH_WEIBO);
						 }
					 }else{
//						 LuaEvent.sendMessage(HandMachine.kLoginWithWeibo , HandMachine.HANDLER_LOGIN_WITH_WEIBO);
						 
						 JSONObject object = new JSONObject(result);
						 if(object!=null){
							 String error = null;
							 String error_code =null;
							 try{
								 error = object.getString("error");
								 error_code = object.getString("error_code");
							 }catch(Exception e){
								 e.printStackTrace();
							 }
							 
							 if(error_code!=null && ("21301".equals(error_code)
										|| "21314".equals(error_code)
										|| "21315".equals(error_code)
										|| "21316".equals(error_code)
										|| "21317".equals(error_code)
										|| "21325".equals(error_code)
										|| "21327".equals(error_code) || "21501"
										.equals(error_code))){
								 if(mAuthCallBack!=null){
									 mAuthCallBack.onFail(error);
								 } 
								 
//								 LuaEvent.sendMessage(HandMachine.kLoginWithWeibo , HandMachine.HANDLER_LOGIN_WITH_WEIBO);
							 }else{
								 if(mAuthCallBack!=null){
									 mAuthCallBack.onFail(mCtx.getString(R.string.verified_failed));
								 } 
//								 LuaEvent.sendMessage(HandMachine.kLoginWithWeibo , HandMachine.HANDLER_LOGIN_WITH_WEIBO);
							 }
						 }else{
							 if(mAuthCallBack!=null){
								 mAuthCallBack.onFail(mCtx.getString(R.string.verified_failed));
							 }
//							 LuaEvent.sendMessage(HandMachine.kLoginWithWeibo , HandMachine.HANDLER_LOGIN_WITH_WEIBO);
						 }
					 }
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}).start();
	}
	
	public static HttpClient getNewHttpClient() {
		try {
		       KeyStore trustStore = KeyStore.getInstance(KeyStore.getDefaultType());
		       trustStore.load(null, null);
		       SSLSocketFactory sf = new SSLSocketFactoryEx(trustStore); 
		       sf.setHostnameVerifier(SSLSocketFactory.STRICT_HOSTNAME_VERIFIER);

		       HttpParams params = new BasicHttpParams();
		       HttpProtocolParams.setVersion(params, HttpVersion.HTTP_1_1);
		       HttpProtocolParams.setContentCharset(params, HTTP.UTF_8);
		 
		       SchemeRegistry registry = new SchemeRegistry();	 
		       registry.register(new Scheme("http", PlainSocketFactory.getSocketFactory(), 80));
		       registry.register(new Scheme("https", sf, 443));
		       ClientConnectionManager ccm = new ThreadSafeClientConnManager(params, registry);
		       return new DefaultHttpClient(ccm, params);
		   } catch (Exception e) {
		       return new DefaultHttpClient();
		   }
	}
	
}
