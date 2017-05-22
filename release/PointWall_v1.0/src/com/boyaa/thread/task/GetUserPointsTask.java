package com.boyaa.thread.task;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Map;
import java.util.TreeMap;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.util.Log;
import android.widget.TextView;

import com.boyaa.http.HttpResult;
import com.boyaa.http.HttpUtil;
import com.boyaa.php.PHPRequest;
import com.boyaa.thread.ITask;
import com.boyaa.utils.EnviromentUtil;


public class GetUserPointsTask implements ITask {
	private Activity mActivity;
	private TextView tv;
	
	
	private HttpResult httpResult;
	
	private String pts;
	private String appid;
	private String uid;
	private String mUrl;
	private boolean isTimeOut = false;
	public GetUserPointsTask(Activity activity, String url, String id1, String id2, TextView textview){
		mActivity = activity;
		mUrl = url;
		appid = id1;
		uid = id2;
		tv = textview;
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

		String sig = PHPRequest.secretParms("reward/info", "", params);
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
//			result:
//			{"code":200,"message":"Success","ret":{"rewards":3420}}
				int code = object.getInt("code");
				if (200 == code){
					JSONObject ret = object.getJSONObject("ret");
					pts = ret.getString("rewards");
				}
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}			
		}else{
			Log.d("onResumePW","result is null: isTimeOut = true");
			isTimeOut   = true;
//			mActivity.runOnUiThread(new Runnable() {
//				@Override
//				public void run() {
//					// TODO Auto-generated method stub
//					((PointWallActivity) mActivity).isNotConnectNet();
//				}
//			});
		}
	}

	@Override
	public void postExecute() {
		if (!mActivity.isFinishing()) {
			mActivity.runOnUiThread(new Runnable() {
				public void run() {
					Log.d("onResumePW","result is null: TimeOut 15s, isTimeOut = true");
					if (!isTimeOut){
						if (null == pts){
							tv.setText("0");
						}else{
							tv.setText(pts);
						}
					}
				}
			});
		}	
	}
		
	
}