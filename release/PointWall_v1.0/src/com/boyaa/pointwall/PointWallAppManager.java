package com.boyaa.pointwall;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.ContentValues;
import android.widget.TextView;
import android.widget.Toast;

import com.boyaa.data.GameData;
import com.boyaa.db.ByGameDao;
import com.boyaa.db.SgGameDao;
import com.boyaa.http.HttpResult;
import com.boyaa.http.HttpUtil;
import com.boyaa.php.PHPRequest;
import com.boyaa.pointwall.PointWallActivity.DownLoadOverCallBack;
import com.boyaa.pointwall.viewholder.ViewHolder;
import com.boyaa.thread.TaskManager;
import com.boyaa.thread.task.AddDownLoadCountTask;
import com.boyaa.thread.task.GetUserPointsTask;
import com.boyaa.thread.task.LoadAppListTask;
import com.boyaa.utils.EnviromentUtil;

public class PointWallAppManager {
	private Activity mActivity;
	private ByGameDao bygameDao;
	private SgGameDao sggameDao;
	private HttpResult httpResult;
	PointWallAppManager(Activity activity) {
		this.mActivity = activity;
		bygameDao = new ByGameDao();
		sggameDao = new SgGameDao();
		
	}

	List<GameData> boyaaGameDataList;
	List<GameData> suggestGameDatasList;
	List<GameData> getBoyaaGameDataList(int start, int length) {
		return bygameDao.getBoyaaGameDataList(start, length);
	}
	List<GameData> getSuggestGameDataList(int start, int length) {
		return sggameDao.getSuggestGameDataList(start, length);
	}
	int getByGameCount() {
		return bygameDao.getGamesCount();
	}
	int getSgGameCount() {
		return sggameDao.getGamesCount();
	}
	public void updateByGameState(long id, ContentValues ct){
		bygameDao.updateGameData(id, ct);
	}
	public void updateSgGameState(long id, ContentValues ct){
		sggameDao.updateGameData(id, ct);
	}
	public GameData getByGameData(String url)
	{
		return bygameDao.getGameData(url);
	}
	public GameData getSgGameData(String url)
	{
		return sggameDao.getGameData(url);
	}
	public synchronized void getAppListByPhp(Activity activity, int index,HashMap<ViewHolder, String> bv,DownLoadOverCallBack loadOverCallBack){
		String url = PHPRequest.SERVER_RUL + "app/list/";
		if (0 == index){
			TaskManager.getInstance().addTask(new LoadAppListTask(activity, url, bygameDao, bv, index,loadOverCallBack));
		}else if(1 == index){
			TaskManager.getInstance().addTask(new LoadAppListTask(activity, url, sggameDao, bv, index,loadOverCallBack));
		}
	}
	public void getUserPoints(Activity activity, String appid, String uid, TextView textview){
		String url = PHPRequest.SERVER_RUL + "reward/info/";
		TaskManager.getInstance().addTask(new GetUserPointsTask(activity, url, appid, uid, textview));

	}
	
	public void addDownLoadCount(Activity activity, String appid, String uid, String id){
		String url = PHPRequest.SERVER_RUL + "app/click/";
		TaskManager.getInstance().addTask(new AddDownLoadCountTask(activity, url, appid, uid, id));
	}
	
	public String addUserPoints(String appid, String uid, String mtkey, String id, String points){
		JSONObject object;
		String pts = null;
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
		String sig = PHPRequest.secretParms("reward/get_reward", "", params);
		params.put("sig", sig);
		httpResult = HttpUtil.post(PHPRequest.SERVER_RUL + "reward/get_reward/", params);
		String result = null;
		
		if (null != httpResult.result){
			result = new String(httpResult.result);
		}
		if (null != result)
		{
			try {
					object = new JSONObject(result);
//					result:
//					{"code":200,"message":"Success","ret":{"rewards":3420}}
//					{"code":412,"message":"Beyond max day rewards","ret":""}
//					{"code":413,"message":"Rewards already got","ret":""}
					int code = object.getInt("code");
					if (200 == code){

//						JSONObject ob = object.getJSONObject("ret");
//						pts = ob.getString("rewards");
						Toast.makeText(mActivity, "领取金币成功！", Toast.LENGTH_LONG).show();
						Map<String, String> params2 = new TreeMap<String, String>();
						params2.put("api", "2");
						params2.put("mid", uid);
						params2.put("mtkey", mtkey);
						params2.put("reward", String.valueOf((Integer.parseInt(points) * 100)));
						params2.put("method", "getRewardByMoney");	
						
						String sig2 = PHPRequest.secretParmsToLua(params2, mtkey);
						params2.put("sig", sig2);
						
					
						JSONObject jsonStr_temp = new JSONObject(params2);
						if (!params.isEmpty()) {
							params.clear();
						}
						String result2 = "";
						params.put("api", jsonStr_temp.toString());
						httpResult = HttpUtil.post(PHPRequest.LUA_SERVERADDR +"?m=scorewall&p=api", params);
						if (null != httpResult.result){
							result2 = new String(httpResult.result);
						}
						
						
						
					}else if (401 == code || 402 == code){
						Toast.makeText(mActivity, "请求参数错误！", Toast.LENGTH_SHORT).show();
					}else if (404 == code){
						Toast.makeText(mActivity, "未知错误", Toast.LENGTH_SHORT).show();
					}else if (412 == code){
						Toast.makeText(mActivity, "领取失败! (您获得的金币已达上限)", Toast.LENGTH_LONG).show();
					}else if (413 == code){
						Toast.makeText(mActivity, "领取失败! (您已领取过此应用)", Toast.LENGTH_LONG).show();
					}else if (414 == code){
						Toast.makeText(mActivity, "应用已下架", Toast.LENGTH_SHORT).show();
					}else if (500 == code){
						Toast.makeText(mActivity, "系统错误", Toast.LENGTH_SHORT).show();
					}
					


				} catch (JSONException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
					return null;
				}			
		}
		return pts;
		
	}
	
}
