package com.boyaa.thread.task;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Map;
import java.util.TreeMap;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.util.Log;

import com.boyaa.http.HttpResult;
import com.boyaa.http.HttpUtil;
import com.boyaa.php.PHPRequest;
import com.boyaa.thread.ITask;
import com.boyaa.utils.EnviromentUtil;


public class AddDownLoadCountTask implements ITask {
	private Activity mActivity;
	private HttpResult httpResult;
	private String appid;
	private String uid;
	private String mUrl;
	private String id;
	public AddDownLoadCountTask(Activity activity, String url, String id1, String id2, String id3){
		mActivity = activity;
		mUrl = url;
		appid = id1;
		uid = id2;
		id = id3;
	}

	@Override
	public void execute() {
	
		JSONObject object;
		Map<String, String> params = new TreeMap<String, String>();
		params.put("phone_model", EnviromentUtil.getPhoneModel());
		params.put("phone_sdkversion", EnviromentUtil.getSdkVersion());
		params.put("phone_mac", EnviromentUtil.getMacAddr(mActivity));
		params.put("phone_nettype", EnviromentUtil.getNetWorkName(mActivity));
		params.put("phone_ipaddr", EnviromentUtil.getIpAddr(mActivity));
		params.put("phone_imei", EnviromentUtil.getImeiNum(mActivity));
		SimpleDateFormat formatter = new SimpleDateFormat("yyyy年MM月dd日   HH:mm:ss");     
		Date curDate = new Date(System.currentTimeMillis());//获取当前时间     
		String str = formatter.format(curDate);    
		params.put("request_time", str);
		params.put("appid", appid);
		params.put("uid", uid);
		params.put("promote_id", id);
		String sig = PHPRequest.secretParms("app/click", "", params);
		params.put("sig", sig);
		httpResult = HttpUtil.post(mUrl, params);
		String result = null;
		if (null != httpResult.result){
			result = new String(httpResult.result);
		}
		if (null != result)
		{
			try {
					object = new JSONObject(result);
//					result:
//					{"code":200,"message":"Success","ret":7}
					int code = object.getInt("code");
					if (200 == code){
						//只是通知服务器下载了。返回之后什么也不做
						Log.d("Thread112", "统计成功了！");
					}
				} catch (JSONException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}			
		}	
		
		
	}

	@Override
	public void postExecute() {
	
	}		
	
}