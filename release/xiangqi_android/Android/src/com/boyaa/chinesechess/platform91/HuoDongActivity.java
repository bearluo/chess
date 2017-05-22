package com.boyaa.chinesechess.platform91;

import java.lang.reflect.Method;

import android.app.Activity;
import android.net.http.SslError;
import android.os.Bundle;
import android.os.Message;
import android.util.DisplayMetrics;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.webkit.JavascriptInterface;
import android.webkit.SslErrorHandler;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.ProgressBar;

import com.boyaa.chinesechess.platform91.R;
import com.boyaa.entity.common.Log;
import com.boyaa.entity.common.utils.ButtonTouchStateListener;
import com.boyaa.entity.common.utils.UtilTool;
import com.boyaa.entity.core.HandMachine;
import com.boyaa.made.APNUtil;
import com.boyaa.made.AppActivity;
import com.umeng.analytics.MobclickAgent;

public class HuoDongActivity extends Activity {

	private WebView m_webView = null;	
	private ImageButton m_backButton = null;
	private ProgressBar m_progressBar;
	private ImageButton m_pre_btn;
	private ImageButton m_next_btn;
	private ImageView m_noContent_view;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		setContentView(R.layout.activity_center);
		
		m_webView = (WebView) findViewById(R.id.webview);
		m_webView.setBackgroundColor(0);
		
		m_backButton = (ImageButton) findViewById(R.id.backBtn);
		m_backButton.setOnClickListener(clickListener);
		m_backButton.setOnTouchListener(new ButtonTouchStateListener());
		m_pre_btn = (ImageButton) findViewById(R.id.preBtn);
		m_pre_btn.setOnClickListener(clickListener);
		m_pre_btn.setOnTouchListener(new ButtonTouchStateListener());
		m_next_btn = (ImageButton) findViewById(R.id.nextBtn);
		m_next_btn.setOnClickListener(clickListener);
		m_next_btn.setOnTouchListener(new ButtonTouchStateListener());
		
		m_progressBar = (ProgressBar) findViewById(R.id.progressBar);
		m_noContent_view = (ImageView) findViewById(R.id.noContentView);
		
		m_webView.getSettings().setJavaScriptEnabled(true); 
		m_webView.getSettings().setUseWideViewPort(true);
		m_webView.getSettings().setLoadWithOverviewMode(true);
		m_webView.getSettings().setSupportZoom(true);  
		m_webView.getSettings().setBuiltInZoomControls(true);  
		
		//映射Java对象到一个名为”js2java“的Javascript对象上
		 //JavaScript中可以通过"window.js2java"来调用Java对象的方法
		m_webView.addJavascriptInterface(new JSInvokeClass(), "js2java");
		
			
		setZoom(m_webView.getSettings());
		
		m_webView.setWebChromeClient(new WebChromeClient(){

			@Override
			public void onProgressChanged(WebView view, int newProgress) {
				// TODO Auto-generated method stub
				m_progressBar.setProgress(newProgress);
				if(newProgress == 100){
					m_progressBar.setVisibility(View.INVISIBLE);
				}else{
					m_progressBar.setVisibility(View.VISIBLE);
				}
			}
		});
		m_webView.setWebViewClient(new WebViewClient(){
			
			@Override
			public boolean shouldOverrideUrlLoading(WebView view, String url) {
				// TODO Auto-generated method stub
				view.loadUrl(url);
				return true;
			}
			
			@Override
			public void onReceivedSslError(WebView view, SslErrorHandler handler, SslError error) {
				handler.proceed();  // 接受所有网站的证书
			}
		});
		
		initContent();
	}
	
	/**网页Javascript调用接口**/
	 class JSInvokeClass {
		 @JavascriptInterface
	     public void download(final String url) {   			 
			Bundle bundle = new Bundle();// 存放数据			
			bundle.putString("data", url);
			 
			Message msg = new Message();
			msg.what = HandMachine.TOWEBPAGE;
			msg.setData(bundle);
			Game.getGameHandler().sendMessage(msg);
	
	     }
	 }	 
	 
	private void setZoom(WebSettings webSettings) {  
		int screenDensity = getResources().getDisplayMetrics().densityDpi;  
		String zd = "FAR";  
		switch (screenDensity) {  
		case DisplayMetrics.DENSITY_LOW:  
		    zd = "CLOSE";  
		    break;  
		 
		case DisplayMetrics.DENSITY_MEDIUM:  
		    zd = "MEDIUM";  
		    break;  
		}  
		Class<?> zoomDensityClass = null;  
		Enum<?> zoomDensity = null;  
		 
		try {  
		    if (zoomDensityClass == null) {  
		    zoomDensityClass = Class.forName("android.webkit.WebSettings$ZoomDensity");  
		    }
		    if (zoomDensity == null) {
		    	zoomDensity = (Enum<?>) Enum.valueOf((Class) zoomDensityClass,zd);  
		    }
		 
		    Method method = WebSettings.class.getDeclaredMethod("setDefaultZoom", new Class<?>[] { zoomDensityClass });  
		    if(method!=null){  
		    	method.invoke(webSettings, zoomDensity);  
		    }
		      
		    method = WebSettings.class.getDeclaredMethod("setTextZoom", new Class<?>[] { int.class });  
		    if(method!=null){  
		    	method.invoke(webSettings, 60 * getWindowManager().getDefaultDisplay().getWidth() / 480);  
		    }
		} catch (Exception e) {
		    return;  
		}  
	}
	
	private void initContent() {
		// TODO Auto-generated method stub
		if(APNUtil.isNetworkAvailable(this)){
			String url = getIntent().getStringExtra("url");
			if(url != null){
				m_noContent_view.setVisibility(View.GONE);
				m_progressBar.setVisibility(View.VISIBLE);
				m_webView.setVisibility(View.VISIBLE);
				m_webView.loadUrl(url);
			}else{
				m_noContent_view.setVisibility(View.VISIBLE);
				m_webView.setVisibility(View.GONE);
				m_progressBar.setVisibility(View.GONE);
			}
		}else{
			m_noContent_view.setVisibility(View.GONE);
			m_webView.setVisibility(View.GONE);
			m_progressBar.setVisibility(View.GONE);
			UtilTool.showToast(R.string.noNetWork);
		}
	}

	private OnClickListener clickListener = new OnClickListener() {
		
		@Override
		public void onClick(View view) {
			// TODO Auto-generated method stub
			switch(view.getId()){
			case R.id.backBtn :
				finish();
				break;
			case R.id.preBtn:
				if(m_webView.canGoBack()){
					m_webView.goBack();
				}
				break;
			case R.id.nextBtn:
				if(m_webView.canGoForward()){
					m_webView.goForward();
				}
				break;
			}
		}
	};

	@Override
	public boolean onKeyUp(int keyCode, KeyEvent event) {
		// TODO Auto-generated method stub
		if(keyCode == KeyEvent.KEYCODE_BACK){
			finish();
			return true;
		}
		return super.onKeyUp(keyCode, event);
	}

	@Override
	public void finish() {
		// TODO Auto-generated method stub
		AppActivity.mActivity.runOnLuaThread(new Runnable() {
			@Override
			public void run() {
				HandMachine.getHandMachine().luaCallEvent(HandMachine.kUpdateUserInfo , null);
			}
		});
		super.finish();
	}

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
	    MobclickAgent.onResume(this);
	}

	@Override
	protected void onPause() {
		// TODO Auto-generated method stub
		super.onPause();
	    MobclickAgent.onPause(this);
	}
	
	
	
}
