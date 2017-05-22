package com.boyaa.kefu;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.net.Uri;
import android.util.Log;

import com.boyaa.customer.service.main.BoyaaCustomerServiceCallBack;
import com.boyaa.customer.service.main.BoyaaCustomerServiceManager;
import com.boyaa.customer.service.main.Constant;

public class KefuFeedbackSys {
	private static KefuFeedbackSys instance = null;
	
	public static KefuFeedbackSys getInstance(){
		if (instance == null){
			instance = new KefuFeedbackSys();
		}
		return instance;
	}
	
	public void init(Context mContext,String data){
		BoyaaCustomerServiceManager.getInstance().setBoyaaCustomerServiceCallBack(new BoyaaCustomerServiceCallBack() {
			@Override
			public void onGetUnreadMsgNum(int num) {
				Log.d("KefuFeedbackSys", "onGetUnreadMsgNum num=" + num);
			}
			
			@Override
			public void onError(int code, String msg) {
				Log.d("KefuFeedbackSys", "onError code=" + code+";msg=" + msg);
			}

			@Override
			public void onGetDynamicInfo(String arg0) {
				// TODO Auto-generated method stub
				
			}
		});
		
		try {
			JSONObject jsonObject = new JSONObject(data);
			String gid = jsonObject.getString("game_id");
			String site_id = jsonObject.getString("site_id");
			String uid = jsonObject.getString("uid");
			BoyaaCustomerServiceManager.getInstance().getDynamicInfo(mContext,gid, site_id, uid);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		/*model：连接地址环境，目前共分四种环境：测试、预发布、HA高可用测试和正式线，分别对应传入CONNECT_MODEL_DEBUG、CONNECT_MODEL_PRE_RELEASE、CONNECT_MODEL_TEMP和CONNECT_MODEL_OFFICIAL，默认为正式线地址。
		  isSsl：是否ssl安全模式，默认true
		  isAbroad：是否接入国外环境，目前有部分环境分国内外两个地址，可供业务设置，默认为false（即国内环境）。
		*/
		BoyaaCustomerServiceManager.getInstance().setEnvParams(Constant.CONNECT_MODEL_OFFICIAL, true,false);
		/**
		 * 获取离线消息条目
		 */
//		BoyaaCustomerServiceManager.getInstance().getOfflineMsgNum("1", "117", Constant.STATION_ID);

	}
	
	// 进入客服反馈系统
	public void entryFeedbackSys(Context mContext,String data){
		try {
		JSONObject jsonObject = new JSONObject(data);
		String gid = jsonObject.getString("game_id");
		String site_id = jsonObject.getString("site_id");
		String uid = jsonObject.getString("uid");
		String user_name = jsonObject.getString("user_name");
		String user_icon_url = jsonObject.getString("user_icon_url");
		String role = jsonObject.getString("is_kefu_vip");
		String role_level = jsonObject.getString("kefu_vip_level");
		String account_type = jsonObject.getString("account_type");
		String client = jsonObject.getString("client");
		JSONObject json = new JSONObject();
		json.put(Constant.COLUMN_GID_CONFIG, gid);
		json.put(Constant.COLUMN_SID_CONFIG, site_id);
		json.put(Constant.COLUMN_STATIONID_CONFIG, uid);
		json.put(Constant.COLUMN_ROLE_CONFIG, role);
		json.put(Constant.VIP_LEVEL,role_level);
		json.put(Constant.COLUMN_QOS_CONFIG, 1);
		json.put(Constant.COLUMN_CLEANSESSION_CONFIG, true);
		json.put(Constant.COLUMN_KEEPALIVE_CONFIG, 60);
		json.put(Constant.COLUMN_TIMEOUT_CONFIG, 1000);
		json.put(Constant.COLUMN_RETAIN_CONFIG, false);
		json.put(Constant.COLUMN_SSL_CONFIG, false);
		json.put(Constant.NICKNAME, user_name);
		json.put(Constant.COLUMN_SSLKEY_CONFIG, "");
		json.put(Constant.COLUMN_UNAME_CONFIG, "");
		json.put(Constant.COLUMN_UPWD_CONFIG, "");
		json.put(Constant.ACCOUNT_TYPE, account_type);
		json.put(Constant.COLUMN_UAVATAR_CONFIG, Uri.parse(user_icon_url));
		json.put(Constant.CLIENT, client);
//		json.put(Constant.GAME_NAME,"寰峰窞鎵戝厠");
		json.put(Constant.USER_ID, uid);
//		json.put(Constant.DEVICE_TYPE, "瀹夊崜4.0");
//		json.put(Constant.CONNECTIVITY, "wifi");
//		json.put(Constant.GAME_VERSION, "211");
//		json.put(Constant.DEVICE_DETAIL, "MI2S");
//		json.put(Constant.IP, "112223334");
//		json.put(Constant.MAC, "B0:83:FE:94:58:F3");
//		json.put(Constant.BROWSER, "UC");
		json.put(Constant.SCREEN, "720*1280");
//		json.put(Constant.OS_VERSION, "6.0.1");
//		json.put(Constant.JAILBREAK, "false");
//		json.put(Constant.OPERATOR, "1");
		/**
		 * 进去在线客服系统
		 */
		BoyaaCustomerServiceManager.getInstance().enterChat(mContext, json.toString());
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}
}
