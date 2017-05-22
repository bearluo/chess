package com.boyaa.ending;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.entity.core.HandMachine;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.util.Log;
import android.widget.Toast;

// 当大量更新sqlite 的时候会导致数据库操作报错  因为数据不是很负责所以 指进行json 解析
// lua 层数据解析过慢

public class EndingUtilNew {
	public static String TAG = EndingUtilNew.class.getSimpleName();
	public static ArrayList<Gate> gates = new ArrayList<Gate>();
	public static ArrayList<Chessrecord> chessrecords = new ArrayList<Chessrecord>();
	private static SharedPreferences sharedPreferences;
	private static Editor editor;
	public static void Init (final String jsonStr) {
		sharedPreferences = Game.mActivity.getSharedPreferences("endgate", Context.MODE_PRIVATE);
		editor = sharedPreferences.edit();
		editor.clear();
		editor.commit();
		new Thread(new Runnable() {
			
			@Override
			public void run() {
				// TODO Auto-generated method stub
				ArrayList<Gate> gates = new ArrayList<Gate>();
				ArrayList<Chessrecord> chessrecords = new ArrayList<Chessrecord>();
				try {
					JSONArray data = new JSONArray(jsonStr);
					for (int i = 0;i<data.length();i++) {
						Gate gate = new Gate();
						JSONObject temp = data.getJSONObject(i);
						JSONObject gateJson = temp.getJSONObject("gate");
						JSONArray gateArray = temp.getJSONArray("chessrecord");
						gate.tid = gateJson.getInt("tid");
						editor.putString("gate"+gate.tid, gateJson.toString());
						Chessrecord chessrecord = new Chessrecord();
						chessrecord.addChessrecord(gateArray,gate.tid,editor);
						gate.chessrecord_size = chessrecord.getSize();
						gates.add(i, gate);
						chessrecords.add(chessrecord);
					}
					EndingUtilNew.gates = gates;
					EndingUtilNew.chessrecords = chessrecords;
					Game.mActivity.runOnLuaThread(new Runnable() {//只返回版本号
						@Override
						public void run() {
							HandMachine.getHandMachine().luaCallEvent(HandMachine.kEndingUtilNewInit,getGatesData());
						}
					});
				} catch (JSONException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
					Log.e(TAG,"数据解析错误");
					Game.mActivity.runOnLuaThread(new Runnable() {//只返回版本号
						@Override
						public void run() {
							HandMachine.getHandMachine().luaCallEvent(HandMachine.kEndingUtilNewInit,null);
						}
					});
				}
				editor.commit();
			}
		}).start();
	}
	
	public static String getGatesData() {
		JSONArray jsonArray = new JSONArray();
		for(int i=0;i<gates.size();i++) {
			try {
				String str = sharedPreferences.getString("gate" + gates.get(i).tid ,"");
				JSONObject jsonObject = new JSONObject(str);
				jsonObject.put("chessrecord_size", gates.get(i).chessrecord_size);
				jsonArray.put(jsonObject);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
		}
		Log.e(TAG,jsonArray.toString());
		return jsonArray.toString();
	}
	
	public static String getSubGateJsonStrByTidAndSort(int tid,int sort) {
		return sharedPreferences.getString("gate " + tid + " subGate " + sort,"");
	}
	
}
class Gate {
	int tid;
	int chessrecord_size;
}

class Chessrecord {
	public int tid = 0;
	public int cnt = 0;
	public void addChessrecord(JSONArray jsonArray,int tid,Editor editor) {
		this.tid = tid;
		this.cnt = jsonArray.length();
		for(int i=0;i<jsonArray.length();i++) {
			try {
				JSONObject temp = jsonArray.getJSONObject(i);
				editor.putString("gate " + this.tid + " subGate " + temp.getInt("sort"), temp.toString());
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	public int getSize() {
		return cnt;
	}
}