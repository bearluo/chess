package com.boyaa.entity.common.utils;

import android.os.Bundle;
import android.os.Message;
import android.widget.Toast;

import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.entity.core.HandMachine;
import com.boyaa.made.AppActivity;
public class UtilTool {

	public static void showToast(String text, int duration) {

		Toast.makeText(AppActivity.mActivity, text, duration).show();
	}

	public static void showToast(String text) {
		showToast(text , 1000);
	}

	public static void showToast(int resId) {
		String s = AppActivity.mActivity.getString(resId);
		showToast(s);
	}

    /*
     * 上报分享类型
     */
    public static void sendCountToMain(String line){
    	Message msg = new Message();
		Bundle bundle = new Bundle();// 存放数据
		bundle.putString("data", line);
		msg.what = HandMachine.ON_EVENT_STAT;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
    }
    
    /*
     * 统计分享
     */
//    public static void sendCountToPHP(String line){
//		AppActivity.mActivity.runOnLuaThread(new Runnable() {
//			@Override
//			public void run() {
//				HandMachine.getHandMachine().luaCallEvent(HandMachine.kCountToPHP , null);
//			}
//		});
//    }
    
}