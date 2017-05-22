package com.boyaa.entity.guest;

import java.util.TreeMap;

import org.json.JSONException;
import org.json.JSONObject;

import android.os.Build;
import android.util.DisplayMetrics;
import android.util.Log;

import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.entity.common.IThirdPartySdk;
import com.boyaa.entity.common.utils.JsonUtil;
import com.boyaa.entity.core.HandMachine;
import com.boyaa.made.APNUtil;
import com.boyaa.made.AppActivity;
import com.boyaa.until.SIMCardInfo;
import com.boyaa.until.Util;
import com.boyaa.util.NetworkUtil;

public class Guset implements IThirdPartySdk{

	public void GuestLoginZh() {
	}
	
	@Override
	public int login(String key , String data) {
		String osinfo = "设备类型:" + Build.MODEL+"系统版本:" + Build.VERSION.RELEASE+"联网方式:"+APNUtil.getNetWorkName(Game.mActivity);
		String model = android.os.Build.MODEL;
		String name = "Guest_";
		String gender = "";
		if (model != null) {
			String names[] = model.split(" ");
			int length = names.length;
			if (length >= 3) {
				name = names[length - 2] + " " + names[length - 1];
			} else {
				name = model;
			}
		}
		
		if (null != data && data != ""){
			JSONObject jsonObj;
			try {
				jsonObj = new JSONObject(data);
				name = jsonObj.getString("nickName");
				gender = jsonObj.getString("gender");
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		String new_uuid = uuidProxy.getUUID();
		uuidProxy.saveUUID(new_uuid);
		String new_other_uuid = uuidProxy.getOtherUUID();
		if( new_other_uuid != null ) {
			uuidProxy.saveOtherUUID(new_other_uuid);
			new_uuid = new_other_uuid;
		}
		String versionName = Game.versionName;
		TreeMap<String, Object> map = new TreeMap<String, Object>();
		map.put("imei", Util.getMachineId());
		map.put("new_uuid",new_uuid);
		map.put("name", name);
		map.put("versions", versionName);
		map.put("osinfo", osinfo);
		map.put("sdkVersion", Build.VERSION.RELEASE);
		map.put("netType", APNUtil.getNetWorkName(Game.mActivity));
		map.put("netTypeLevel", NetworkUtil.getNetworkType(AppActivity.mActivity));
		Log.e("netType", APNUtil.getNetWorkName(Game.mActivity)+"");
		map.put("model", Build.MODEL == null ? "" : Build.MODEL);
		//积分墙
		map.put("mac", Util.getMacAddr());//物理地址
		map.put("ip", Util.getIpAddr());//ip地址
		map.put("imeiNum", Util.getImeiNum());
		//积分墙 end
        DisplayMetrics dm = new DisplayMetrics();
        
        AppActivity.mActivity.getWindowManager().getDefaultDisplay().getMetrics(dm);
        
		SIMCardInfo cardInfo = new SIMCardInfo(AppActivity.mActivity);
		int type = cardInfo.getProvidersType();
		String operator=null;
		
		if(type==SIMCardInfo.CHINA_MOBILE)
		{
			operator="CHINA_MOBILE";
		}else if(type==SIMCardInfo.CHINA_UNICOM)
		{
			operator="CHINA_UNICOM";
		}else if(type==SIMCardInfo.CHINA_TELECOM)
		{
			operator="CHINA_TELECOM";
		}else if(type==SIMCardInfo.CHINA_TIETONG)
		{
			operator="CHINA_TIETONG";
		}else
		{
			operator="";
		}
	
		String imei = Util.getMachineId();		
		map.put("operatorType", type);
		map.put("operator", operator);
		map.put("imei", imei);
		map.put("pixel", dm.widthPixels+"x"+dm.heightPixels);
		
		if(APNUtil.isActiveNetworkAvailable(Game.mActivity)){
			map.put("isNetworkAvailable", 1);
		}else{
			map.put("isNetworkAvailable", 0);
		}
		// endgateDb clear;
		
		JsonUtil json = new JsonUtil(map);
		String gueststr = json.toString();
		HandMachine.getHandMachine().luaCallEvent(key , gueststr);
		
		return 0;
	}
	

	@Override
	public int Share(String key, String data) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public int pay(String key, String data) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public int freunde(String key, String data) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public int logout(String key, String data) {
		// TODO Auto-generated method stub
		return 0;
	}

}
