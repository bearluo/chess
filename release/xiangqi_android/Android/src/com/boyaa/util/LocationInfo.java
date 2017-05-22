package com.boyaa.util;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONException;
import org.json.JSONObject;

import android.Manifest;
import android.annotation.TargetApi;
import android.app.Activity;
import android.app.AppOpsManager;
import android.content.Context;
import android.content.pm.PackageManager;
import android.location.Address;
import android.location.Criteria;
import android.location.Geocoder;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.location.LocationProvider;
import android.os.Binder;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.util.Log;
import android.widget.Toast;

import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.entity.core.HandMachine;
import com.boyaa.made.AppActivity;

public class LocationInfo {
	
	static String DICT_NAME = "location_dict_name";
	static String DICT_KEY_LOCATION = "LocationInfo";
	static String LOCATION_URL = "http://ip.taobao.com/service/getIpInfo2.php";
	static String NAME = "ip";
	static String VALUE = "myip";
	static String sLongitude = null;
	static String sLatitude = null;
	public static LocationManager locationManager;
	private static Context mContext;
	public static final int OP_FINE_LOCATION = 1;  
	
	/*
	 * 获取经纬度
	 */
	public static void getLoLaByNetWork(final Context mc){
		mContext = mc;
        locationManager = (LocationManager)mContext.getSystemService(Context.LOCATION_SERVICE); 
        if (ContextCompat.checkSelfPermission(mContext,android.Manifest.permission.ACCESS_FINE_LOCATION)== PackageManager.PERMISSION_GRANTED) {
        	if (locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)){
        		locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, 0, 0, ll);
        	}else if(locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)){
        		locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 0, 0, ll);
        	}else{
    			Game.mActivity.runOnLuaThread(new Runnable() {
    				@Override
    				public void run() {
    					HandMachine.getHandMachine().luaCallEvent("GetLocationInfo", "{}");
    				}
    			});
        	}
		}else {
			Toast.makeText(mContext, "请获取权限", Toast.LENGTH_LONG).show();
		}
	}

	public static LocationListener ll = new LocationListener() {
		
		@Override
		public void onStatusChanged(String provider, int status, Bundle extras) {
		}
		@Override
		public void onProviderEnabled(String provider) {
		}
		@Override
		public void onProviderDisabled(String provider) {
		}
		@Override
		public void onLocationChanged(Location location) {
	        if (location != null){
	        	locationManager.removeUpdates(ll);
		        sLongitude = Double.toString(location.getLongitude());
		        sLatitude = Double.toString(location.getLatitude());
				final JSONObject json = new JSONObject();
				Game.mActivity.runOnLuaThread(new Runnable() {
					@Override
					public void run() {
						try {
							 json.put("longitude", sLongitude);
							 json.put("latitude", sLatitude);
							 Geocoder geocoder=new Geocoder(mContext);
							 List<Address> address = geocoder.getFromLocation(Double.parseDouble(sLatitude), Double.parseDouble(sLongitude), 1);
							 if(address.size()>0)
							 {
								 json.put("province", address.get(0).getAdminArea());
								 json.put("city", address.get(0).getLocality());
								 HandMachine.getHandMachine().luaCallEvent("GetLocationInfo", json.toString());
							 }else{
								 HandMachine.getHandMachine().luaCallEvent("GetLocationInfo", "{}");
							 }
						} catch (JSONException e) {
							e.printStackTrace();
						} catch (NumberFormatException e) {
							e.printStackTrace();
						} catch (IOException e) {
							e.printStackTrace();
						}
					}
				});
	        }
		}
	};
	
	/*
	 * 获取城市代码(走淘宝ip)
	 */
	public static void getCityByHttp(){
		NameValuePair pair = new BasicNameValuePair(NAME, VALUE);
        final List<NameValuePair> pairList = new ArrayList<NameValuePair>();
        pairList.add(pair);
		Game.mActivity.runOnLuaThread(new Runnable() {
			@Override
			public void run() {
		        try {
		        	HttpEntity requestHttpEntity = new UrlEncodedFormEntity(pairList);
			        // URL使用基本URL即可，其中不需要加参数
			        HttpPost httpPost = new HttpPost(LOCATION_URL);
			        // 将请求体内容加入请求中
			        httpPost.setEntity(requestHttpEntity);
			        // 需要客户端对象来发送请求
			        HttpClient httpClient = new DefaultHttpClient();
			        // 发送请求
					HttpResponse response = httpClient.execute(httpPost);
					if (response.getStatusLine().getStatusCode() == 200){
						HttpEntity httpEntity = response.getEntity();
						InputStream in = httpEntity.getContent();
						BufferedReader br = new BufferedReader(new InputStreamReader(in));
						String result = "";
						String line = "";
						while(null != (line = br.readLine())){
							result += line;
						};
						JSONObject json = new JSONObject(result);
						JSONObject data = json.getJSONObject("data");
						HandMachine.getHandMachine().luaCallEvent("GetCityInfo", data.toString());
					}
				} catch (ClientProtocolException e) {
					e.printStackTrace();
				} catch (IOException e) {
					e.printStackTrace();
				} catch (JSONException e) {
					e.printStackTrace();
				}
			}
		});
	}
	
}


//	//省份代号
//	public static String getProvinceId(){
//		String saveLocation = AppActivity.dict_get_string(DICT_NAME,DICT_KEY_LOCATION);
//		if (saveLocation.equals("")){
//			return null;
//		}else{
//			try {
//				JSONObject json = new JSONObject(saveLocation);
//				JSONObject data = json.getJSONObject("data");
//				return data.getString("region_id");
//			} catch (JSONException e) {
//				// TODO Auto-generated catch block
//				e.printStackTrace();
//			}
//			return null;
//		}
//	}
//	//省份
//	public static String getProvinceName(){
//		String saveLocation = AppActivity.dict_get_string(DICT_NAME,DICT_KEY_LOCATION);
//		if (saveLocation.equals("")){
//			return null;
//		}else{
//			try {
//				JSONObject json = new JSONObject(saveLocation);
//				JSONObject data = json.getJSONObject("data");
//				return data.getString("region");
//			} catch (JSONException e) {
//				// TODO Auto-generated catch block
//				e.printStackTrace();
//			}
//			return null;
//		}
//	}
//	
//	//城市代号
//	public static String getCityId(){
//		String saveLocation = AppActivity.dict_get_string(DICT_NAME,DICT_KEY_LOCATION);
//		if (saveLocation.equals("")){
//			return null;
//		}else{
//			try {
//				JSONObject json = new JSONObject(saveLocation);
//				JSONObject data = json.getJSONObject("data");
//				return data.getString("city_id");
//			} catch (JSONException e) {
//				// TODO Auto-generated catch block
//				e.printStackTrace();
//			}
//			return null;
//		}
//	}
//	//城市
//	public static String getCityName(){
//		String saveLocation = AppActivity.dict_get_string(DICT_NAME,DICT_KEY_LOCATION);
//		if (saveLocation.equals("")){
//			return null;
//		}else{
//			try {
//				JSONObject json = new JSONObject(saveLocation);
//				JSONObject data = json.getJSONObject("data");
//				return data.getString("city");
//			} catch (JSONException e) {
//				// TODO Auto-generated catch block
//				e.printStackTrace();
//			}
//			return null;
//		}
//	}
//	
//	//外网ip
//	public static String getIPAddress(){
//		String saveLocation = AppActivity.dict_get_string(DICT_NAME,DICT_KEY_LOCATION);
//		if (saveLocation.equals("")){
//			return null;
//		}else{
//			try {
//				JSONObject json = new JSONObject(saveLocation);
//				JSONObject data = json.getJSONObject("data");
//				return data.getString("ip");
//			} catch (JSONException e) {
//				// TODO Auto-generated catch block
//				e.printStackTrace();
//			}
//			return null;
//		}
//	}
