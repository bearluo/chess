package com.boyaa.webview;

import java.util.ArrayList;

import org.json.JSONException;
import org.json.JSONObject;

import com.boyaa.entity.core.HandMachine;
import com.boyaa.activitysdk.ActivitySdkManager;
import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.proxy.share.ShareManager;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.Display;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnKeyListener;
import android.webkit.JavascriptInterface;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.net.http.SslError;
import android.webkit.SslErrorHandler;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

@TargetApi(Build.VERSION_CODES.HONEYCOMB)
public class WebViewManager{

private static WebViewManager shareInstance = null;
private static WebViewManager nativeInstance = null;
private static WebViewManager collectInstance = null;
private static WebViewManager activityInstance = null;

	
	public static WebViewManager getShareInstance() {
		if (shareInstance == null) {
			shareInstance = new WebViewManager();
			
		}
		return shareInstance;
	}
	
	public static void releaseShareInstance() {
		if (shareInstance != null) {
			shareInstance.delView();
		}
		shareInstance = null;
	}
	
	public static WebViewManager getNativeInstance() {
		if (nativeInstance == null) {
			nativeInstance = new WebViewManager();
		}
		return nativeInstance;
	}
	
	public static void releaseNativeInstance() {
		if (nativeInstance != null) {
			nativeInstance.delView();
		}
		nativeInstance = null;
	}
	
	public static WebViewManager getCollectInstance() {
		if (collectInstance == null) {
			collectInstance = new WebViewManager();
		}
		return collectInstance;
	}
	
	public static void releaseCollectInstance() {
		if (collectInstance != null) {
			collectInstance.delView();
		}
		collectInstance = null;
	}
	
	public static WebViewManager getActivityInstance() {
		if (activityInstance == null) {
			activityInstance = new WebViewManager();
		}
		return activityInstance;
	}
	
	public static void releaseActivityInstance() {
		if (activityInstance != null) {
			activityInstance.delView();
		}
		activityInstance = null;
	}
	
	
	private ArrayList<WebViewModel> mWebViewModelArray = new ArrayList<WebViewModel>();
//	private static WebViewModel[] mWebViewModelArray = new WebViewModel[5];
//	private static WebView mWebView;
	private RelativeLayout mInnerLayout;
	private RelativeLayout mOutterLayout;
	private TextView mTextView;
	public static int mScreenWidth;
	public static int mScreenHeight;
	private String url;
	private String old_url;//保存访问的Url,用于判断是否要重新Load url
	private String uid;
	private Handler mHandler = new Handler();
	private String loadResh = "0";//第一次load标记
	private int totalNum = 0;	  //html页面数据总条数（暂时没用）
	private int pageIndex = 1;	  //html页面数据页面标签
	private int anchor = 1;		  //html页面锚点（暂时没用）
	private String jsonData = "";	//html页面数据（暂时没用）
	private int scrollTop = 0;		//html页面滚动距离
	private int loadNum = 1;		//iframe页面是否进入标记
	private int x,y,width,height;
	private String method;
	
	private WebViewManager(){
		init(Game.mActivity);
	}
	
	public void  init(Activity activity){
		Display display = activity.getWindowManager().getDefaultDisplay();
		mScreenWidth = display.getWidth();
		mScreenHeight = display.getHeight();
	}
	
	public void delView() {
//		if (mWebView != null) {
//			mWebView.setVisibility(View.GONE);
			removeAddedLayouts();
//			mWebView.destroy();
//		}
//		mWebView = null;
	}
	
	public void hideView(){
		if (mOutterLayout!=null){
//			Log.i("WebViewManager","WebViewManager mOutterLayout VIEW.GONE");
			mOutterLayout.setVisibility(View.GONE);
			if (! mWebViewModelArray.isEmpty() ) {
				WebViewModel webViewModel = mWebViewModelArray.get(mWebViewModelArray.size()-1);
				webViewModel.mWebView.onPause();
			}
		}
	}
	
	public boolean isShowing() {
		if (mOutterLayout!=null && mOutterLayout.getVisibility() == View.VISIBLE){
			return true;
		}
		return false;
	}
	
	public WebViewModel getTopWebView() {
		if (mOutterLayout!=null){
			if (! mWebViewModelArray.isEmpty() ) {
				WebViewModel webViewModel = mWebViewModelArray.get(mWebViewModelArray.size()-1);
				return webViewModel;
			}
		}
		return null;
	}
	
	public void sendJsToWeb(String js) {
		WebViewModel webViewModel = getTopWebView();
		if( webViewModel != null ) {
			webViewModel.mWebView.loadUrl(js);
		}else {
			Log.e("WebViewManager", "not webview");
		}
	}
	
	public void shareCallBack(boolean isSuccess,String params) {
		if ( params == null ) params = "";
		String js = String.format("javascript:window.chessShareCallBack(%d,\"%s\")",isSuccess? 1:0,params);
		sendJsToWeb(js);
	}
	
	public void closeChild(){

	}
	
	public void hideNativeView(){

	}
	
	public void refreshView(){
//		if (mWebView != null){
//			mWebView.loadUrl("javascript:refresh("+totalNum+")");
//			return;
//		}
	}
	
	public void onPause() {
		if (mOutterLayout!=null && mOutterLayout.getVisibility() == View.VISIBLE){
			if (! mWebViewModelArray.isEmpty() ) {
				WebViewModel webViewModel = mWebViewModelArray.get(mWebViewModelArray.size()-1);
				webViewModel.mWebView.onPause();
			}
		}
		
	}
	
	public void onResume() {
		if (mOutterLayout!=null && mOutterLayout.getVisibility() == View.VISIBLE){
			if (! mWebViewModelArray.isEmpty() ) {
				WebViewModel webViewModel = mWebViewModelArray.get(mWebViewModelArray.size()-1);
				webViewModel.mWebView.onResume();
			}
		}
	}
	
	private void removeAddedLayouts() {
		try {
			FrameLayout framelayout = ((FrameLayout)Game.mActivity.getWindow().getDecorView().findViewById(android.R.id.content));
			framelayout.removeView(this.mOutterLayout);
			mOutterLayout = null;
			mInnerLayout = null;
		} catch (Exception e) {
		}
	}
	
	public void newWebView(final String data) {
		JSONObject jsonResult = null;
		old_url = url;
		try{
			jsonResult = new JSONObject(data);
			x = jsonResult.optInt("x",0);
			y = jsonResult.optInt("y",0);
			width = jsonResult.optInt("width",480);
			height = jsonResult.optInt("height",-1);
			url = jsonResult.getString("url");
			method = jsonResult.getString("method");
			uid = jsonResult.optString("uid", "0");
//			url = "file:///android_asset/shareList_test/index.html";
			Log.i("CON","CON 访问1"+url);
			if(!url.equals("null")){
				if(url.contains("?"))
					url += "&mid="+uid+"&method="+method+"&tempTime=" + Math.random();
				else
					url += "?mid="+uid+"&method="+method+"&tempTime=" + Math.random();
			}
			
			Log.i("CON","CON 访问2"+url);
		} catch (JSONException e) {
			return;
		}
		if (mOutterLayout != null){
			if (! mWebViewModelArray.isEmpty() ) {
				WebViewModel webViewModel = mWebViewModelArray.get(mWebViewModelArray.size()-1);
				webViewModel.mWebView.onResume();

				if ( webViewModel.height == -1 ) webViewModel.height = mScreenWidth;
				RelativeLayout.LayoutParams lp = new RelativeLayout.LayoutParams(webViewModel.width,webViewModel.height);
				Log.e("WebViewManager","mInnerLayout.LayoutParams:" +width + "+" + height);
				lp.setMargins(webViewModel.x, webViewModel.y, 0, 0);
				mInnerLayout.setLayoutParams(lp);
			}
//			
//			if(old_url.equals("null")){
//				if(!url.equals("null")){
					mWebViewModelArray.get(0).mWebView.loadUrl(url);
					mTextView.setVisibility(View.GONE);
//				}
//			}else {
//				mWebViewModelArray.get(0).mWebView.loadUrl("javascript:refresh()");
////				mWebViewModelArray.get(0).mWebView.setVisibility(View.INVISIBLE);
//				mTextView.setVisibility(View.GONE);
//			}
			mOutterLayout.setVisibility(View.VISIBLE);
			mOutterLayout.setVisibility(View.VISIBLE);
			
			return;
		}
		
		mTextView = new TextView(Game.mActivity);
		mTextView.setText("请先登录或检查网络设置");
		mTextView.setVisibility(View.GONE);
		
		mInnerLayout = new RelativeLayout(Game.mActivity);
		mInnerLayout.addView(mTextView);
		mOutterLayout = new RelativeLayout(Game.mActivity);
		mOutterLayout.addView(mInnerLayout);
		
		RelativeLayout.LayoutParams lp = new RelativeLayout.LayoutParams(
				RelativeLayout.LayoutParams.FILL_PARENT,
				RelativeLayout.LayoutParams.FILL_PARENT);
		Game.mActivity.addContentView(mOutterLayout, lp);
		
		if(url.equals("null"))
			mTextView.setVisibility(View.VISIBLE);
		overrideLoad(url,true,x,y,width,height);
		
		mWebViewModelArray.get(0).mWebView.setWebViewClient(new WebViewClient(){
			
			@Override
			public void onPageFinished(WebView view, String url) {
				// TODO Auto-generated method stub
				Log.i("WebViewManager","WebViewManager onPageFinished");
				if(loadResh.equals("0")){
//					Log.i("WebViewManager","WebViewManager onPageFinished loadResh = " + loadResh);
////					int sendHeight = px2dip(height);
//					int sendHeight = height;
//					try{
//						JSONObject jsonString = new JSONObject();
//						jsonString.put("hight", mScreenHeight);
//						jsonString.put("width", mScreenWidth);
//						jsonString.put("uid", uid);
//						jsonString.put("method", method);
//						mWebViewModelArray.get(0).mWebView.loadUrl("javascript:setWindowHight("+jsonString+")");
//						
//					}catch(JSONException e) {
//						return;
//					}
					loadResh = "1";
				}
				super.onPageFinished(view, url);
			}

			@Override
			public boolean shouldOverrideUrlLoading(WebView view, String url) {
				// TODO Auto-generated method stub
				overrideLoad(url,false,0,0,mScreenWidth,mScreenHeight);
				return true;
			}

			@Override
			public void onReceivedSslError(WebView view, SslErrorHandler handler, SslError error) {
				handler.proceed();  // 接受所有网站的证书
			}
		});

		mWebViewModelArray.get(0).mWebView.addJavascriptInterface(new DemoJavaScriptInterface(), "demo");
//		initContent();
	}
	
	public void newWebView2(final String data) {
		JSONObject jsonResult = null;
		old_url = url;
		try{
			jsonResult = new JSONObject(data);
			x = jsonResult.optInt("x",0);
			y = jsonResult.optInt("y",0);
			width = jsonResult.optInt("width",480);
			height = jsonResult.optInt("height",-1);
			url = jsonResult.getString("url");
			method = jsonResult.optString("method","");
			uid = jsonResult.optString("uid", "0");
//			url = "file:///android_asset/shareList_test/index.html";
			Log.i("CON2","CON2 访问"+url);
		} catch (JSONException e) {
			return;
		}
		if (mOutterLayout != null){
			while (! mWebViewModelArray.isEmpty() ) {
				WebViewModel removeWebViewModel = mWebViewModelArray.remove(mWebViewModelArray.size()-1);
				if(removeWebViewModel.mSwipeRefreshLayout == null){
					mInnerLayout.removeView(removeWebViewModel.mWebView);
					removeWebViewModel.mWebView.destroy();
				}else{
					mInnerLayout.removeView(removeWebViewModel.mSwipeRefreshLayout);
					removeWebViewModel.mSwipeRefreshLayout.removeView(removeWebViewModel.mWebView);
				}
				removeWebViewModel.mWebView.destroy();
				mInnerLayout.removeView(removeWebViewModel.mProgressBar);
			}

			overrideLoad2(url,false,x,y,width,height);

			mOutterLayout.setVisibility(View.VISIBLE);
			mOutterLayout.setVisibility(View.VISIBLE);
			
			return;
		}
		
		mTextView = new TextView(Game.mActivity);
		mTextView.setText("请先登录或检查网络设置");
		mTextView.setVisibility(View.GONE);
		
		mInnerLayout = new RelativeLayout(Game.mActivity);
		mInnerLayout.addView(mTextView);
		mOutterLayout = new RelativeLayout(Game.mActivity);
		mOutterLayout.addView(mInnerLayout);
		
		RelativeLayout.LayoutParams lp = new RelativeLayout.LayoutParams(
				RelativeLayout.LayoutParams.FILL_PARENT,
				RelativeLayout.LayoutParams.FILL_PARENT);
		Game.mActivity.addContentView(mOutterLayout, lp);
		
		if(url.equals("null"))
			mTextView.setVisibility(View.VISIBLE);
		overrideLoad2(url,false,x,y,width,height);
	}
	
	
	private void overrideLoad(String url,boolean needSwipeRefreshLayout,int x,int y,int width,int height){
		Log.i("WebViewManager","WebViewManager overrideLoad url "+url);
		if(url.contains(".apk")){
			Uri uri = Uri.parse(url);
            Intent viewIntent = new Intent(Intent.ACTION_VIEW,uri);
            Game.mActivity.startActivity(viewIntent);
			return;
		}
		WebViewModel mWebViewModel;
		mWebViewModel = WebViewModel.CreateWebViewModel(mInnerLayout, x, y, width, height, mScreenWidth, mScreenHeight,needSwipeRefreshLayout);
		
		if(mWebViewModelArray.size()>=1){
			mWebViewModelArray.get(mWebViewModelArray.size()-1).mWebView.onPause();
		}
		mWebViewModelArray.add(mWebViewModel);
		mWebViewModel.mWebView.loadUrl(url);
		if(mWebViewModel.mSwipeRefreshLayout != null)
			mWebViewModel.mSwipeRefreshLayout.setVisibility(View.VISIBLE);
		mWebViewModel.mWebView.setWebViewClient(new WebViewClient() {
			@Override
			public boolean shouldOverrideUrlLoading(WebView view, String url) {
				// TODO Auto-generated method stub
				overrideLoad(url,false,0,0,mScreenWidth,mScreenHeight);
				return true;
			}

			@Override
			public void onReceivedSslError(WebView view, SslErrorHandler handler, SslError error) {
				handler.proceed();  // 接受所有网站的证书
			}
		});
		
		mWebViewModel.mWebView.setOnKeyListener(new OnKeyListener() {    
	        @Override    
	        public boolean onKey(View v, int keyCode, KeyEvent event) {
	        	if(event.getAction() == KeyEvent.ACTION_DOWN){
		        	if (keyCode == KeyEvent.KEYCODE_BACK) {
		        		Log.i("WebViewManager","WebViewManager OnKeyListener KeyEvent.KEYCODE_BACK");
		    			if(mWebViewModelArray.size() > 1){
		    				webViewBack();
		    				Log.i("WebViewManager","WebViewManager OnKeyListener return true");
		    	            return true;
		    			}
		    			if (null != Game.mActivity.mGLView) { 
		    				Log.i("WebViewManager","WebViewManager OnKeyListener Game.mActivity.mGLView return true");
		    				Game.mActivity.mGLView.onKeyDown(keyCode, event);
		    				return true;
		    			}
		    		}
	        	}
	        	Log.i("WebViewManager","WebViewManager OnKeyListener return false");
	    		return false;    
	        }    
	    });
		mWebViewModel.mWebView.addJavascriptInterface(new DemoJavaScriptInterface(), "demo");
	}
	
	private void overrideLoad2(String url,boolean needSwipeRefreshLayout,int x,int y,int width,int height){
		Log.i("WebViewManager","WebViewManager overrideLoad url "+url);
		if(url.contains(".apk")){
			Uri uri = Uri.parse(url);
            Intent viewIntent = new Intent(Intent.ACTION_VIEW,uri);
            Game.mActivity.startActivity(viewIntent);
			return;
		}
		WebViewModel mWebViewModel;
		mWebViewModel = WebViewModel.CreateWebViewModel(mInnerLayout, x, y, width, height, mScreenWidth, mScreenHeight,needSwipeRefreshLayout);
		
		if(mWebViewModelArray.size()>=1){
			mWebViewModelArray.get(mWebViewModelArray.size()-1).mWebView.onPause();
		}
		mWebViewModelArray.add(mWebViewModel);
		mWebViewModel.mWebView.loadUrl(url);
		if(mWebViewModel.mSwipeRefreshLayout != null)
			mWebViewModel.mSwipeRefreshLayout.setVisibility(View.VISIBLE);
		
		mWebViewModel.mWebView.setWebViewClient(new WebViewClient() {
			@Override
			public boolean shouldOverrideUrlLoading(WebView view, String url) {
				// TODO Auto-generated method stub
				overrideLoad2(url,false,0,0,mScreenWidth,mScreenHeight);
				return true;
			}

			@Override
			public void onReceivedSslError(WebView view, SslErrorHandler handler, SslError error) {
				handler.proceed();  // 接受所有网站的证书
			}
		});
		
		mWebViewModel.mWebView.setOnKeyListener(new OnKeyListener() {    
	        @Override    
	        public boolean onKey(View v, int keyCode, KeyEvent event) {
	        	Log.i("WebViewManager","WebViewManager onKey");
	        	if(event.getAction() == KeyEvent.ACTION_DOWN){
		        	if (keyCode == KeyEvent.KEYCODE_BACK) {
		        		Log.i("WebViewManager","WebViewManager OnKeyListener KeyEvent.KEYCODE_BACK");
		    			if(mWebViewModelArray.size() > 0){
		    				webViewBack();
		    				Log.i("WebViewManager","WebViewManager OnKeyListener return true");
		    	            return true;
		    			}
		    			if (null != Game.mActivity.mGLView) { 
		    				Log.i("WebViewManager","WebViewManager OnKeyListener Game.mActivity.mGLView return true");
		    				Game.mActivity.mGLView.onKeyDown(keyCode, event);
		    				return true;
		    			}
		    		}
	        	}
	        	Log.i("WebViewManager","WebViewManager OnKeyListener return false");
	    		return false;    
	        }    
	    });
		mWebViewModel.mWebView.addJavascriptInterface(new DemoJavaScriptInterface(), "demo");
	}
	
//	private void initContent() {
//		// TODO Auto-generated method stub
//		if(APNUtil.isNetworkAvailable(Game.mActivity)){
//			if(url != null){
//				mWebViewModelArray.get(0).mWebView.setVisibility(View.VISIBLE);
//				mWebViewModelArray.get(0).mWebView.loadUrl(url);
//			}else{
//				mWebViewModelArray.get(0).mWebView.setVisibility(View.GONE);
//			}
//		}else{
//			mWebViewModelArray.get(0).mWebView.setVisibility(View.GONE);
//			Toast.makeText(AppActivity.mActivity, R.string.noNetWork, Toast.LENGTH_SHORT).show();
//		}
//	}
	
	public void webViewBack(){
		WebViewModel removeWebViewModel = mWebViewModelArray.remove(mWebViewModelArray.size()-1);
		if(removeWebViewModel.mSwipeRefreshLayout == null){
			mInnerLayout.removeView(removeWebViewModel.mWebView);
			removeWebViewModel.mWebView.destroy();
		}else{
			mInnerLayout.removeView(removeWebViewModel.mSwipeRefreshLayout);
			removeWebViewModel.mSwipeRefreshLayout.removeView(removeWebViewModel.mWebView);
		}
		removeWebViewModel.mWebView.destroy();
		mInnerLayout.removeView(removeWebViewModel.mProgressBar);
		if ( mWebViewModelArray.size() > 0 ) {
			WebViewModel webViewModel = mWebViewModelArray.get(mWebViewModelArray.size()-1);
			webViewModel.mWebView.onResume();
			
			if ( webViewModel.height == -1 ) webViewModel.height = mScreenWidth;
			RelativeLayout.LayoutParams lp = new RelativeLayout.LayoutParams(webViewModel.width,webViewModel.height);
			Log.e("WebViewManager","mInnerLayout.LayoutParams:" +width + "+" + height);
			lp.setMargins(webViewModel.x, webViewModel.y, 0, 0);
			mInnerLayout.setLayoutParams(lp);
		}
//		if (webViewModel.height == -1) {
//			mInnerLayout.setPadding(webViewModel.x, webViewModel.y, (mScreenWidth - webViewModel.width) - webViewModel.x, 0);
//		} else {
//			mInnerLayout.setPadding(webViewModel.x, webViewModel.y, mScreenWidth - webViewModel.width - webViewModel.x, mScreenHeight - webViewModel.height - webViewModel.y);
//		}
	}

	public static void shareView() {
		Intent intent=new Intent(Intent.ACTION_SEND);
		intent.setType("text/plain");
		intent.putExtra(Intent.EXTRA_SUBJECT, "博雅中国象棋");
		intent.putExtra(Intent.EXTRA_TEXT, "json"); 
		intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK); 
		Game.mActivity.startActivity(Intent.createChooser(intent,"博雅中国象棋"));
	}
	
	public static void forwardView() {
//		mWebViewModelArray.get(0).mWebView.loadUrl("javascript:forward()");
	}
	
	public static int px2dip(float pxValue) {  
        final float scale = Game.mActivity.getResources().getDisplayMetrics().density;  
        return (int) (pxValue / scale + 0.5f);  
    }  
	
	final class DemoJavaScriptInterface {
        /**
         * This is not called on the UI thread. Post a runnable to invoke
         * loadUrl on the UI thread.
         */
        
        //保存总个数
        @JavascriptInterface
        public void onTotal(int num) {
        	totalNum = num;
        }
        
      //保存数据
        @JavascriptInterface
        public void onSave(String data) {
        	try{
    			JSONObject jsonResult = new JSONObject(data);
    			totalNum = jsonResult.optInt("totalNum",0);
    			pageIndex = jsonResult.optInt("pageIndex",1);
    			anchor = jsonResult.optInt("anchor",1);
    			scrollTop = jsonResult.optInt("scrollTop",0);
    			jsonData = jsonResult.optString("arrayJson","");
    		} catch (JSONException e) {
    			return;
    		}
        }
        
        //返回上一页
        @JavascriptInterface
        public void onBack() {
        	mHandler.post(new Runnable() {
                public void run() {
                	webViewBack();
                }
            });
        	
        }

        @JavascriptInterface
        public void onChangeView(){
			mHandler.post(new Runnable() {
                public void run() {
                	if (height == -1) {
        				mInnerLayout.setPadding(0, 0, (mScreenWidth - width + x), 0);
        			} else {
        				mInnerLayout.setPadding(0, 0, mScreenWidth - width - x, mScreenHeight - height - y);
        			}
                }
            });
        }

        @JavascriptInterface
        public String getAPIUrl() {
        	return ActivitySdkManager.getAPIUrl();
        }

        @JavascriptInterface
        public String getMid() {
    		return ActivitySdkManager.getMid();
    	}

        @JavascriptInterface
    	public void setMid(String mid) {
    		ActivitySdkManager.setMid(mid);
    	}

        @JavascriptInterface
    	public String getAppid() {
    		return ActivitySdkManager.getAppid();
    	}

        @JavascriptInterface
    	public void setAppid(String appid) {
    		ActivitySdkManager.setAppid(appid);
    	}

        @JavascriptInterface
    	public String getApi() {
    		return ActivitySdkManager.getApi();
    	}

        @JavascriptInterface
    	public void setApi(String api) {
    		ActivitySdkManager.setApi(api);
    	}

        @JavascriptInterface
    	public String getVersion() {
    		return ActivitySdkManager.getVersion();
    	}

        @JavascriptInterface
    	public void setVersion(String version) {
    		ActivitySdkManager.setVersion(version);
    	}

        @JavascriptInterface
    	public String getSitemid() {
    		return ActivitySdkManager.getSitemid();
    	}

        @JavascriptInterface
    	public void setSitemid(String sitemid) {
    		ActivitySdkManager.setSitemid(sitemid);
    	}

        @JavascriptInterface
    	public String getUsertype() {
    		return ActivitySdkManager.getUsertype();
    	}

        @JavascriptInterface
    	public void setUsertype(String usertype) {
    		ActivitySdkManager.setUsertype(usertype);
    	}

        @JavascriptInterface
    	public String getDeviceno() {
    		return ActivitySdkManager.getDeviceno();
    	}

        @JavascriptInterface
    	public void setDeviceno(String deviceno) {
    		ActivitySdkManager.setDeviceno(deviceno);
    	}

        @JavascriptInterface
    	public int getActivityDebug() {
    		return ActivitySdkManager.getActivityDebug();
    	}

        @JavascriptInterface
    	public void setActivityDebug(int activityDebug) {
    		ActivitySdkManager.setActivityDebug(activityDebug);
    	}

    	@JavascriptInterface
        public int getCollect_manual() {
    		return ActivitySdkManager.getCollect_manual();
    	}

    	@JavascriptInterface
    	public void setCollect_manual(int collect_manual) {
    		ActivitySdkManager.setCollect_manual(collect_manual);
    	}

    	@JavascriptInterface
    	public int getSave_manual() {
    		return ActivitySdkManager.getSave_manual();
    	}

    	@JavascriptInterface
    	public void setSave_manual(int save_manual) {
    		ActivitySdkManager.setSave_manual(save_manual);
    	}
    	
    	@JavascriptInterface
    	public int getComment_manual() {
    		return ActivitySdkManager.getComment_manual();
    	}
    	
    	@JavascriptInterface
    	public void setComment_manual(int comment_manual) {
    		ActivitySdkManager.setComment_manual(comment_manual);
    	}
        
    	@JavascriptInterface
    	public String getAccess_token() {
    		return ActivitySdkManager.getAccess_token();
    	}
    	
    	@JavascriptInterface
    	public void setAccess_token(String access_token) {
    		ActivitySdkManager.setAccess_token(access_token);
    	}
    	
        @JavascriptInterface
    	public void changeStates(final String json) {
    		Game.mActivity.runOnLuaThread(new Runnable() {

    			@Override
    			public void run() {
    				// TODO Auto-generated method stub
    				HandMachine.getHandMachine().luaCallEvent(
    						HandMachine.kChangeStates, json);
    			}
    		});
    	}
        
        @JavascriptInterface
        public void WXsend(final String json) {
        	try {
            	Bundle data = new Bundle();
				JSONObject jsonObject = new JSONObject(json);
				data.putString("description",jsonObject.optString("description",""));
				data.putString("title",jsonObject.optString("title",""));
				data.putInt("isTimeline",jsonObject.optInt("isTimeline",1));
				data.putInt("type",jsonObject.optInt("type",0));
				data.putString("imageUrl",jsonObject.optString("imageUrl",""));
				data.putString("text",jsonObject.optString("text",""));
				data.putString("webpageUrl",jsonObject.optString("webpageUrl",""));
				data.putString("params",jsonObject.optString("params",""));
				ShareManager.WXSend(data);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
        }
    }

}
