package com.boyaa.webview;

import java.io.File;
import java.lang.reflect.Method;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.TreeMap;

import org.apache.http.message.BasicNameValuePair;
import org.json.JSONException;
import org.json.JSONObject;

import com.boyaa.entity.common.BoyaaProgressDialog;
import com.boyaa.entity.common.utils.JsonUtil;
import com.boyaa.entity.core.HandMachine;
import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.chinesechess.platform91.R;
import com.boyaa.chinesechess.platform91.wxapi.SendToWXUtil;
import com.boyaa.made.APNUtil;
import com.boyaa.made.AppActivity;
import com.boyaa.chinesechess.platform91.wxapi.Alert.onAlertItemClick;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.content.DialogInterface.OnCancelListener;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.os.Message;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Display;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.webkit.WebView;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.GridView;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.AdapterView.OnItemClickListener;

public class ShareToBoyaaDialog {

	private static Button mButton;
	private static Button mButton_sure;
	private static EditText mQiPuContent;
	private static String str;
	private static Dialog dlg;
	private static ImageView mManualTypeView;
	private static TextView titleView;
	
	public static Dialog showDialog(final Context context,final Bundle bundle,OnCancelListener cancelListener) {
		dlg = new Dialog(context, R.style.MMTheme_DataSheet2);
		LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		LinearLayout ll = (LinearLayout) inflater.inflate(R.layout.share_boyaa_layout, null);
		
		mQiPuContent = (EditText) ll.findViewById(R.id.editText);
		mQiPuContent.addTextChangedListener(new MaxLengthWatcher(140, mQiPuContent));
		
		mButton = (Button) ll.findViewById(R.id.share_cancle);
		mButton.setOnClickListener(new View.OnClickListener() {
	           @Override  
	           public void onClick(View v) {  
	        	   dlg.dismiss();
	           }  
	       }); 
		
		int manual_type = bundle.getInt("manual_type");
		mManualTypeView = (ImageView)ll.findViewById(R.id.room_type); 
//		switch(manual_type){
//		case 2:mManualTypeView.setImageResource(R.drawable.end_icon);break;
//		case 4:mManualTypeView.setImageResource(R.drawable.dapu_icon);break;
//		default:
//			mManualTypeView.setImageResource(R.drawable.replay_icon);break;
//		}
		
		String title = bundle.getString("qipuName");
		titleView = (TextView)ll.findViewById(R.id.title);
		titleView.setText(title);
		
		mButton_sure = (Button) ll.findViewById(R.id.share_sure);
		mButton_sure.setOnClickListener(new View.OnClickListener() {  
	           @Override  
	           public void onClick(View v) {  
	        	   Log.i("ShareToBoyaaDialog","----------------");
	        	   String editString = mQiPuContent.getText().toString();
					if(editString == "" || editString == null){
						return;
					}else{
//						dlg.dismiss();
//						String url = bundle.getString("url");
//						ShareHttpPost shareHttp = new ShareHttpPost(bundle);
//						shareHttp.Execute();
						Game.progressDialog = BoyaaProgressDialog.show(Game.mActivity, "正在分享...");
						TreeMap<String, Object> map = new TreeMap<String, Object>();
						map.put("news_abstract", editString);
						map.put("news_text", bundle.getString("qipuName"));
						map.put("manual_type", bundle.getString("manual_type"));
						map.put("red_mid", bundle.getString("red_mid"));
						map.put("black_mid", bundle.getString("black_mid"));
						map.put("win_flag", bundle.getString("win_flag"));
						map.put("end_type", bundle.getString("end_type"));
						map.put("chess_opening", bundle.getString("chess_opening"));
						map.put("move_list", bundle.getString("move_list"));
						map.put("news_pid", bundle.getString("news_pid"));
						map.put("manual_id", bundle.getString("manual_id"));
						JsonUtil json = new JsonUtil(map);
						str = json.toString();
						Game.mActivity.runOnLuaThread(new Runnable() {
							@Override
							public void run() {
								HandMachine.getHandMachine().luaCallEvent("ShareToBoyaa", str);
							}
						});
					}
	           }  
	       }); 
		dlg.setContentView(ll);
		Window w = dlg.getWindow();
		WindowManager.LayoutParams lp = w.getAttributes();
		lp.x = 0;
		lp.gravity = Gravity.BOTTOM;
		lp.width = Game.mActivity.mWidth;
		dlg.onWindowAttributesChanged(lp);
		dlg.setCanceledOnTouchOutside(true);
		if (cancelListener != null) {
			dlg.setOnCancelListener(cancelListener);
		}
		return dlg;

	}
	
	public static void success(){
		Toast.makeText(Game.mActivity, "分享成功！", Toast.LENGTH_LONG).show();
		dlg.dismiss();
	}
	
	public static void fail(){
		Toast.makeText(Game.mActivity, "分享失败，请稍后再试！", Toast.LENGTH_LONG).show();
	}
}
