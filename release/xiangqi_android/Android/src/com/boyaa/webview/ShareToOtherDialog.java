package com.boyaa.webview;

import java.io.File;
import java.lang.reflect.Method;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.TreeMap;

import org.json.JSONException;
import org.json.JSONObject;

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
import android.view.WindowManager.LayoutParams;
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
import android.widget.Toast;
import android.widget.AdapterView.OnItemClickListener;

public class ShareToOtherDialog {

	private static ShareToOtherDialog instance = null;
	private static Button mButton;
	private static Button mButton_close;
	private static EditText mQiPuName;
	private static ShareAdapter shareDialogAdapter;
	private static Dialog dlg;
	private static ShareAdapter adapter;
	private static GridView grid;
	
	private static ShareToOtherDialog getInstance(){
		if (instance == null){
			instance = new ShareToOtherDialog();
		}
		return instance;
	}
	
	public static Dialog showDialog(final Context context,String json,OnCancelListener cancelListener) {
		final Bundle bundle = new Bundle();
		try {
			JSONObject jsonObject = new JSONObject(json);
			bundle.putString("manual_type",jsonObject.getString("manual_type"));
			bundle.putString("red_mid",jsonObject.getString("red_mid"));
			bundle.putString("black_mid",jsonObject.getString("black_mid"));
			bundle.putString("win_flag",jsonObject.getString("win_flag"));
			bundle.putString("end_type",jsonObject.getString("end_type"));
			bundle.putString("chess_opening",jsonObject.getString("chess_opening"));
			bundle.putString("move_list",jsonObject.getString("move_list"));
			bundle.putString("news_pid",jsonObject.getString("news_pid"));
			bundle.putString("manual_id",jsonObject.getString("manual_id"));
			
			Log.e("ShareDialog", bundle.toString());
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;
		}
		dlg = new Dialog(context, R.style.MMTheme_DataSheet);
		LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		LinearLayout ll = (LinearLayout) inflater.inflate(R.layout.share_dialog_layout, null);
		
		mButton = (Button) ll.findViewById(R.id.share_cancle);
		mButton.setOnClickListener(new View.OnClickListener() {  
	           @Override  
	           public void onClick(View v) {  
	        	   dlg.dismiss();
	           }  
	       }); 
		
//		mButton_close = (Button) ll.findViewById(R.id.share_close);
//		mButton_close.setOnClickListener(new View.OnClickListener() {  
//	           @Override  
//	           public void onClick(View v) {  
//	        	   dlg.dismiss();
//	           }  
//	       }); 
//		
//		mQiPuName = (EditText) ll.findViewById(R.id.share_editText); 
//		mQiPuName.addTextChangedListener(new MaxLengthWatcher(8, mQiPuName));
        
		grid = (GridView) ll.findViewById(R.id.share_content_grid);
		adapter = new ShareToOtherDialog.ShareAdapter(context);
		
		grid.setAdapter(adapter);

		grid.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
				//item点击--->回lua上报php--->php返回url--->返回Android--->onResponseItemClick继续响应点击事件。
				String editString = mQiPuName.getText().toString();
				if (position == 0){//博雅棋友
					ShareAdapter.ShareViewData data = (ShareAdapter.ShareViewData)adapter.getItem(position);
					bundle.putString("qipuName",editString);
					data.alertItemClick.onClick(bundle);
					dlg.dismiss();
					grid.requestFocus();
				}else if (position == 1){//朋友圈
					TreeMap<String, Object> map = new TreeMap<String, Object>();
					map.put("itemPosition",position);
					map.put("qipuName", editString);
					JsonUtil json = new JsonUtil(map);
					final String str = json.toString();
					Game.mActivity.runOnLuaThread(new Runnable() {
						@Override
						public void run() {
							HandMachine.getHandMachine().luaCallEvent("ShareToPYQ", str);
						}
					});
				}else if(position == 2){//微信
					TreeMap<String, Object> map = new TreeMap<String, Object>();
					map.put("itemPosition",position);
					map.put("qipuName", editString);
					JsonUtil json = new JsonUtil(map);
					final String str = json.toString();
					Game.mActivity.runOnLuaThread(new Runnable() {
						@Override
						public void run() {
							HandMachine.getHandMachine().luaCallEvent("ShareToWX", str);
						}
					});
				}else if (position == 3){
					
				}else{
					
				}
				
//				String editString = mQiPuName.getText().toString();
//				TreeMap<String, Object> map = new TreeMap<String, Object>();
//				map.put("itemPosition",position);
//				map.put("qipuName", editString);
//				JsonUtil json = new JsonUtil(map);
//				final String str = json.toString();
//				Game.mActivity.runOnLuaThread(new Runnable() {
//					@Override
//					public void run() {
//						HandMachine.getHandMachine().luaCallEvent("ShareInfo", str);
//					}
//				});
			}
		});

		// set a large value put it in bottom
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
//		dlg.show();
		return dlg;

	}
	public static void onResponseItemClick(int position, String qipuName, String url) {
		Bundle bundle = new Bundle();
		ShareAdapter.ShareViewData data = (ShareAdapter.ShareViewData)adapter.getItem(position);
		bundle.putString("qipuName",qipuName);
		bundle.putString("url",url);
		data.alertItemClick.onClick(bundle);
		dlg.dismiss();
		grid.requestFocus();
	}
	
	static class ShareAdapter extends BaseAdapter {
		private static final String TAG = "ShareAdapter";
		private List<ShareViewData> items;
		private Context context;

		public ShareAdapter(Context context) {
			this.context = context;
			this.items = new ArrayList<ShareAdapter.ShareViewData>();
//			items.add(new ShareViewData(R.drawable.share_boyaa,new SendToWXUtil.SendWebPageToBoyaa()));
//			items.add(new ShareViewData(R.drawable.share_friends,new SendToWXUtil.SendWebPageToPYQ()));
//			items.add(new ShareViewData(R.drawable.share_wechat,new SendToWXUtil.SendWebPageToWX()));
//			items.add(new ShareViewData(R.drawable.share_weibo,new SendToWXUtil.SendWebPageToWB()));
//			for(int i = 1;i<10;i++)
//			items.add(new ShareViewData(R.drawable.native_save_icon,new SendToWXUtil.SaveNative()));
		}

		@Override
		public int getCount() {
			return items.size();
		}

		@Override
		public Object getItem(int position) {
			return items.get(position);
		}
		
		@Override
		public long getItemId(int position) {
			// TODO Auto-generated method stub
			return 0;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			final ShareViewData data = (ShareViewData) getItem(position);
			ViewHolder holder;
			if (convertView == null || convertView.getTag() == null) {
				holder = new ViewHolder();
				convertView = View.inflate(context, R.layout.share_dialog_layout_item, null);
				holder.view = (LinearLayout) convertView.findViewById(R.id.share_layout_item);
				holder.img = (ImageView) convertView.findViewById(R.id.share_item_icon);
				convertView.setTag(holder);
			} else {
				holder = (ViewHolder) convertView.getTag();
			}

			holder.img.setImageResource(data.img);
			return convertView;
		}

		class ViewHolder {
			LinearLayout view;
			ImageView img;
		}
		final class ShareViewData {
			int img;
			onAlertItemClick alertItemClick; 
			public ShareViewData(int img,onAlertItemClick alertItemClick) {
				// TODO Auto-generated constructor stub
				this.img = img;
				this.alertItemClick = alertItemClick;
			}
		}
		
	}
	
	
}
