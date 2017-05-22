package com.boyaa.webview;

import java.lang.reflect.Method;

import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.chinesechess.platform91.R;

import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.support.v4.widget.SwipeRefreshLayout;
import android.util.Log;
import android.view.View;
import android.webkit.DownloadListener;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebSettings.LayoutAlgorithm;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.RelativeLayout.LayoutParams;

public class WebViewModel{
	public WebView mWebView;
	public SwipeRefreshLayout mSwipeRefreshLayout;
	public ProgressBar mProgressBar;
	public int x,y,width,height;
	
	public WebViewModel(WebView mWebView, SwipeRefreshLayout mSwipeRefreshLayout,ProgressBar mProgressBar,int x,int y,int width,int height){
		this.mWebView = mWebView;
		this.mSwipeRefreshLayout = mSwipeRefreshLayout;
		this.mProgressBar = mProgressBar;
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}
	
	public static WebViewModel CreateWebViewModel(RelativeLayout layout,int x,int y,int width,int height,int screenWidth, int screenHeight){
		return CreateWebViewModel( layout, x, y, width, height, screenWidth, screenHeight,false);
	}
	
	public static WebViewModel CreateWebViewModel(final RelativeLayout layout,final int x,final int y,final int width,final int height,final int screenWidth,final int screenHeight,final boolean needSwipeRefreshLayout){
		final WebView mWebView = new WebView(Game.mActivity);
		
		mWebView.setVerticalScrollBarEnabled(false);
		mWebView.setBackgroundResource(R.drawable.icon); // 设置背景色  
		mWebView.getBackground().setAlpha(0); // 设置填充透明度 范围：0-255  
		//调用2.3以上方法setOverScrollMode(View.OVER_SCROLL_NEVER)，设置滚动至顶部无渐变图案
		try {
			Method method = mWebView.getClass().getMethod("setOverScrollMode",int.class);
			method.invoke(mWebView, 2);
		}catch(NoSuchMethodException e){
		}catch (Exception e) {
		}
		
		RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(
				RelativeLayout.LayoutParams.MATCH_PARENT,
				screenHeight/80);
		
		final ProgressBar mProgressBar = new ProgressBar(Game.mActivity, null,android.R.attr.progressBarStyleHorizontal);
		mProgressBar.setLayoutParams(params);
		
		mProgressBar.setVisibility(View.VISIBLE);
		WebSettings settingSecond = mWebView.getSettings();
		settingSecond.setJavaScriptEnabled(true);
		settingSecond.setSupportZoom(false);
//		settingSecond.setCacheMode(WebSettings.LOAD_NO_CACHE);
		settingSecond.setUseWideViewPort(true);
		settingSecond.setLoadWithOverviewMode(true);
		settingSecond.setBuiltInZoomControls(true);
		settingSecond.setLayoutAlgorithm(LayoutAlgorithm.NORMAL);
		
		RelativeLayout.LayoutParams webViewLayoutParams = new RelativeLayout.LayoutParams(
		RelativeLayout.LayoutParams.MATCH_PARENT,
		RelativeLayout.LayoutParams.MATCH_PARENT);
		mWebView.setLayoutParams(webViewLayoutParams);
		if (needSwipeRefreshLayout) 
			mWebView.setVisibility(View.INVISIBLE);
		else
			mWebView.setVisibility(View.VISIBLE);
		layout.addView(mWebView);
		layout.addView(mProgressBar); 
		
		
		mWebView.setWebChromeClient(new WebChromeClient(){

			@Override
			public void onProgressChanged(WebView view, int newProgress) {
				// TODO Auto-generated method stub
				mProgressBar.setProgress(newProgress);
				if(newProgress == 100){
					Log.i("WebViewManager","WebViewManager mProgressBar VIEW.INVISIBLE");
					mProgressBar.setVisibility(View.INVISIBLE);
					mWebView.setVisibility(View.VISIBLE);
					mWebView.requestFocus();
				}else{
					Log.i("WebViewManager","WebViewManager mProgressBar VIEW.VISIBLE");
					mProgressBar.setVisibility(View.VISIBLE);
				}
				if(newProgress == 0 || newProgress == 100) {  // 软键盘 兼容
					int mheight = height;
					if ( height == -1 ) mheight = screenHeight;
					RelativeLayout.LayoutParams lp = new RelativeLayout.LayoutParams(width,mheight);
					Log.e("WebViewManager","mInnerLayout.LayoutParams:" +width + "+" + mheight);
					lp.setMargins(x, y, 0, 0);
					layout.setLayoutParams(lp);
				}
			}
		});
		
		int mheight = height;
		if ( height == -1 ) mheight = screenHeight;
		RelativeLayout.LayoutParams lp = new RelativeLayout.LayoutParams(width,mheight);
		Log.e("WebViewManager","mInnerLayout.LayoutParams:" +width + "+" + mheight);
		lp.setMargins(x, y, 0, 0);
		layout.setLayoutParams(lp);
		// 与以前的接口兼容
//		if (height == -1) {
//			layout.setPadding(x, y, (screenWidth - width) - x, 0);
//		} else {
//			layout.setPadding(x, y, screenWidth - width - x, screenHeight - height - y);
//		}
		
		WebViewModel mWebViewModel = new WebViewModel(mWebView,null,mProgressBar,x,y,width,height);
		return mWebViewModel;
	}
}
