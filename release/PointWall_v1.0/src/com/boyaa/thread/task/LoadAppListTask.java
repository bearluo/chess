package com.boyaa.thread.task;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.util.Log;

import com.boyaa.data.GameData;
import com.boyaa.db.ByGameDao;
import com.boyaa.db.SgGameDao;
import com.boyaa.http.HttpResult;
import com.boyaa.http.HttpUtil;
import com.boyaa.php.PHPRequest;
import com.boyaa.pointwall.PointWallActivity;
import com.boyaa.pointwall.PointWallActivity.DownLoadOverCallBack;
import com.boyaa.pointwall.viewholder.ViewHolder;
import com.boyaa.thread.ITask;
import com.boyaa.utils.EnviromentUtil;

public class LoadAppListTask implements ITask {
	private Activity mActivity;
	private String mUrl;
	private Object gameDao;
	private int INDEX;
	private HttpResult httpResult;
	private List<GameData> gameDataList;
	private GameData gameData;
	private DownLoadOverCallBack loadOverCallBack;
	private String updateFlag;
	private String timestamp;
	private JSONArray arr;
	private SharedPreferences sPrefs;
	private boolean isTimeOut = false;
	public LoadAppListTask(Activity activity, String url, Object gd, HashMap<ViewHolder, String> bv, int index,DownLoadOverCallBack loadOver){
		mActivity = activity;
		mUrl = url;
		gameDao = gd;
		INDEX = index;
		loadOverCallBack = loadOver;
	}

	@Override
	public void execute() {
		gameDataList = new ArrayList<GameData>();
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
		params.put("appid", "100001");
		params.put("boyaa", "1");
		sPrefs = PreferenceManager.getDefaultSharedPreferences(mActivity);
		params.put("timestamp", sPrefs.getString("timestampByGame", "0"));
		Log.d("timestamp","timestampBy = " + sPrefs.getString("timestampByGame", "0"));
		if (1 == INDEX)
		{
			params.put("boyaa", "0");
			params.put("timestamp", sPrefs.getString("timestampSgGame", "0"));
			Log.d("timestamp","timestampSg = " + sPrefs.getString("timestampSgGame", "0"));
		}
		
		
		String sig = PHPRequest.secretParms("app/list", "", params);
		params.put("sig", sig);
		httpResult = HttpUtil.post(mUrl, params);
		String result = null;
		if (null != httpResult.result){
			result = new String(httpResult.result);
		}
		
		Log.d("timestamp","result = " + result);
		if (null != result){
			try {
				object = new JSONObject(result);
				object = object.getJSONObject("ret");
				updateFlag = object.getString("update_flag");
				if (updateFlag.equals("1")){
					
					timestamp = object.getString("timestamp");
					arr = object.getJSONArray("list");
					if (0 != arr.length())
					{
						
						for (int i = 0; i < arr.length(); i++)
						{
							gameData = new GameData();
							object = arr.getJSONObject(i);
							int appId = object.getInt("id");
							String appName = object.getString("name");
							String appIcon = object.getString("appimg");
							String appBigImage = object.getString("screenshots");
							String appPoint = object.getString("rewards");
							String appUrl = object.getString("installurl");
							String appVersion = object.getString("version");
							String appDetailDesc = object.getString("description");//详细信息
							String appDesc = object.getString("summary");//概要信息
							String pn = object.getString("package_name");
							String ps = object.getString("package_size");
							gameData.id = appId;
							gameData.name = appName;
							gameData.image = appIcon;
							gameData.bigimage = appBigImage;
							gameData.packagename = pn;
							gameData.shortdesc = appDesc;
							gameData.size = ps;
							gameData.url = appUrl;
							gameData.version = appVersion;
							gameData.versioncode = 1;
							gameData.type = INDEX;
							gameData.desc = appDetailDesc;
							gameData.state = 0;
							gameData.points = appPoint;
							gameDataList.add(gameData);
						}
						if (0 == INDEX)
						{	
							((ByGameDao)gameDao).reCreateByTable();
							((ByGameDao)gameDao).saveGamesData(gameDataList);
							//保存时间戳到本地
							sPrefs.edit().putString("timestampByGame", timestamp).commit();
							Log.d("timestamp","timestampBy in update = " + sPrefs.getString("timestampByGame", "0"));
						}else if(1 == INDEX)
						{
							((SgGameDao)gameDao).reCreateSgTable();
							((SgGameDao)gameDao).saveGamesData(gameDataList);
							//保存时间戳到本地
							sPrefs.edit().putString("timestampSgGame", timestamp).commit();
							Log.d("timestamp","timestampSg in update = " + sPrefs.getString("timestampSgGame", "0"));
						}
									
					}else{
						//应用全部下架处理
					}
				}else if (updateFlag.equals("0")){
					
				}
			} catch (JSONException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}else if (null == result){
			isTimeOut  = true;
			mActivity.runOnUiThread(new Runnable() {
				
				@Override
				public void run() {
					// TODO Auto-generated method stub
					((PointWallActivity) mActivity).isNotConnectNet();
				}
			});
			
		}
	}

	@Override
	public void postExecute() {
		if (!mActivity.isFinishing()) {
			mActivity.runOnUiThread(new Runnable() {
//			new Handler(Looper.getMainLooper()).post(new Runnable() {
//			listView.post(new Runnable() {
				public void run() {
					if(loadOverCallBack!=null)
					{
						if (!isTimeOut){
							if (!gameDataList.isEmpty()){
								loadOverCallBack.loadover(INDEX, true);
							}else{
								loadOverCallBack.loadover(INDEX, false);
							}
						}
					}
				}
			});
		}	
	}
}