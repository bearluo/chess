package com.boyaa.receiver;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.os.Bundle;
import android.util.Log;

import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.entity.core.HandMachine;
import com.igexin.sdk.PushConsts;
import com.igexin.sdk.PushManager;
import com.igexin.sdk.Tag;

public class PushMsgDlgReceiver extends BroadcastReceiver{

    /**
     * 应用未启动, 个推 service已经被唤醒,保存在该时间段内离线消息(此时 GetuiSdkDemoActivity.tLogView == null)
     */
    public static StringBuilder payloadData = new StringBuilder();

    @Override
    public void onReceive(Context context, Intent intent) {
        Bundle bundle = intent.getExtras();
        Log.d("GetuiSdk", "onReceive() action=" + bundle.getInt("action"));

        switch (bundle.getInt(PushConsts.CMD_ACTION)) {
            case PushConsts.GET_MSG_DATA:
                // 获取透传数据
                // String appid = bundle.getString("appid");
                byte[] payload = bundle.getByteArray("payload");

                String taskid = bundle.getString("taskid");
                String messageid = bundle.getString("messageid");

                // smartPush第三方回执调用接口，actionid范围为90000-90999，可根据业务场景执行
                boolean result = PushManager.getInstance().sendFeedbackMessage(context, taskid, messageid, 90001);
                System.out.println("第三方回执接口调用" + (result ? "成功" : "失败"));

                if (payload != null) {
                    String data = new String(payload);

                    Log.d("GetuiSdk", "receiver payload : " + data);

                    payloadData.append(data);
                    payloadData.append("\n");
                }
                break;

            case PushConsts.GET_CLIENTID:
                // 获取ClientID(CID)
                // 第三方应用需要将CID上传到第三方服务器，并且将当前用户帐号和CID进行关联，以便日后通过用户帐号查找CID进行消息推送
				String cid = bundle.getString("clientid");
				Log.d("GetuiSdk", "Got ClientID:" + cid + ",size:"+cid.length());
				final JSONObject jsonStr = new JSONObject();
				try {
					jsonStr.put("clientid", cid);
				} catch (JSONException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				
				if (Game.mActivity != null){
					Game.mActivity.runOnLuaThread(new Runnable() {
						public void run() {
							HandMachine.getHandMachine().luaCallEvent(HandMachine.kPushGeTuiMsg , jsonStr.toString());
						}
					});
				}
				//主线包，有不同的渠道，以渠道号作为唯一标签；个推后台可根据渠道号作为标签推送消息
				ApplicationInfo appInfo = null;
				try {
					appInfo = context.getPackageManager().getApplicationInfo(
							context.getPackageName(),PackageManager.GET_META_DATA);
				} catch (NameNotFoundException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				String chess_channelid = String.valueOf(appInfo.metaData.getInt("CHANNELID")) ;
				if (chess_channelid.equals("0") ||chess_channelid.equals("") || chess_channelid == null){
					//配置联运包个推sdk信息，务必将AndroidManifest.xml中CHANNELID值置""
					//<meta-data
					//android:name="CHANNELID"
					//android:value="" />
					//主线包填写对应渠道号
				}else{
					Tag[] tagParam = new Tag[1];
	                Tag t = new Tag();
	                t.setName(chess_channelid);
	                tagParam[0] = t;
					PushManager.getInstance().setTag(context,tagParam);
				}

				break;
            case PushConsts.THIRDPART_FEEDBACK:
                /*
                 * String appid = bundle.getString("appid"); String taskid =
                 * bundle.getString("taskid"); String actionid = bundle.getString("actionid");
                 * String result = bundle.getString("result"); long timestamp =
                 * bundle.getLong("timestamp");
                 * 
                 * Log.d("GetuiSdkDemo", "appid = " + appid); Log.d("GetuiSdkDemo", "taskid = " +
                 * taskid); Log.d("GetuiSdkDemo", "actionid = " + actionid); Log.d("GetuiSdkDemo",
                 * "result = " + result); Log.d("GetuiSdkDemo", "timestamp = " + timestamp);
                 */
                break;

            default:
                break;
        }
    }	
}
