package com.boyaa.baseactivity;

import java.io.File;
import java.util.HashMap;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.view.ViewGroup;
import android.view.ViewTreeObserver.OnGlobalLayoutListener;
import android.widget.Button;
import android.widget.ImageView;

import com.boyaa.common.PhoneScreen;
import com.boyaa.common.SDCardUtil;
import com.boyaa.php.Secret;
import com.boyaa.pointwall.R;
import com.boyaa.utils.EnviromentUtil;
//import com.flurry.android.FlurryAgent;

/** BaseActivity */
public abstract class BaseActivity extends Activity {
    
    public static final String TAG = BaseActivity.class.getSimpleName();
    
//	private static final String FLURRY_APP_KEY = "DJ95PDF3KPWKQK6W7JBC";
	public static final int SUC = 1;
	public static final int SD_ERROR = 2;
	public static final int FILE_ERROR = 3;
	
	private ProgressDialog mProgressDialog;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
//		if (PhoneScreen.isNotInit()) {
//			initPhoneScreen();
//		}
	}
	
//	private void initPhoneScreen() {
//		DisplayMetrics metric = new DisplayMetrics();
//		getWindowManager().getDefaultDisplay().getMetrics(metric);
//		PhoneScreen.width = metric.widthPixels;
//		PhoneScreen.height = metric.heightPixels;
//		PhoneScreen.density = metric.density;
//
//		PhoneScreen.widthScale = PhoneScreen.width / PhoneScreen.WIDTH_V;
//		PhoneScreen.heightScale = (PhoneScreen.height - PhoneScreen.statusBarHeight) / PhoneScreen.HEIGHT_V;
//		PhoneScreen.minScale = PhoneScreen.widthScale < PhoneScreen.heightScale ? PhoneScreen.widthScale : PhoneScreen.heightScale;
//	}
	
	@Override
	protected void onStart() {
		super.onStart();
//		FlurryAgent.onStartSession(this, FLURRY_APP_KEY);
//		FlurryAgent.setLogEnabled(true);
	}

	@Override
	protected void onStop() {
		super.onStop();
//		FlurryAgent.onEndSession(this);
		
	}

	private boolean isFirstShow = true;
	@Override
	protected void onResume() {
		super.onResume();
		if (!isFirstShow) {
			onUpdate();
		}
		isFirstShow = false;
	}
	
	protected void onUpdate() {}

	public void onBackClick(View v) {
		onBackPressed();
	}

	/** 请求在界面显示前获取View的高度宽度等值，子类重写onViewMeasure() */
	protected void afterViewMeasure1() {
		View contextView = getContentView();
		if (contextView != null) {
			contextView.getViewTreeObserver().addOnGlobalLayoutListener(new OnGlobalLayoutListener() {
				boolean isFirst = true;//系统会调两次，这里只需要调用一次
				public void onGlobalLayout() {
					if (isFirst) {
						isFirst = false;
						onViewMeasure();
					}
				}
			});
		}
	}
	
	protected void onViewMeasure() {};

	/** 获取ContextView */
	protected View getContentView() {
		return ((ViewGroup)findViewById(android.R.id.content)).getChildAt(0);
	}

//	protected void setTitle(String title) {
////		TextView titleView = (TextView)this.findViewById(R.id.head_title);
//		if (titleView != null) {
//			titleView.setText(title);
//			titleView.getPaint().setFakeBoldText(true);
//		}
//	}
	public void setSelector(final View view, final int normalDrawableId, final int pressDrawableId) {
		if (view != null) {
			view.setOnTouchListener(new OnTouchListener() {

				public boolean onTouch(View v, MotionEvent event) {
					switch (event.getAction()) {
						case MotionEvent.ACTION_DOWN:
						case MotionEvent.ACTION_MOVE:
							view.setBackgroundResource(pressDrawableId);
							break;
						case MotionEvent.ACTION_UP:
							view.setBackgroundResource(normalDrawableId);
							break;
					}
					return false;
				}
				
			});
		}
	}

	protected void setSelectorColor(final View view, final int normalColor, final int pressColor) {
		if (view != null) {
			view.setOnTouchListener(new OnTouchListener() {

				public boolean onTouch(View v, MotionEvent event) {
					switch (event.getAction()) {
						case MotionEvent.ACTION_DOWN:
						case MotionEvent.ACTION_MOVE:
							view.setBackgroundColor(pressColor);
							break;
						case MotionEvent.ACTION_UP:
							view.setBackgroundColor(normalColor);
							break;
					}
					return false;
				}
				
			});
		}
	}
	
	protected void reviseButtonSize(Button view) {
		if (view != null) {
			
			view.setWidth(PhoneScreen.reviseSize(view.getWidth()));
			view.setHeight(PhoneScreen.reviseSize(view.getHeight()));
		}
	}

	public void reviseImageViewSize(ImageView view, int pxSize) {
		if (view != null) {
			view.setMinimumWidth(pxSize);
			view.setMinimumHeight(pxSize);
		}
	}
	
	/** 按手机分辨率比率缩放图片 */
	public void reviseView1(View view) {
		if (view != null) {
			ViewGroup.LayoutParams lp = view.getLayoutParams();
			lp.width = PhoneScreen.reviseWidth(lp.width);
			lp.height = PhoneScreen.reviseHeight(lp.height);
			view.setLayoutParams(lp);
		}
	}

	/** 按手机分辨率最小比率缩放图片，图片宽度高度不变 */
	protected void reviseImageViewSize1(ImageView view) {
		if (view != null) {
			ViewGroup.LayoutParams lp = view.getLayoutParams();
			lp.width = PhoneScreen.reviseSize(lp.width);
			lp.height = PhoneScreen.reviseSize(lp.height);
			view.setLayoutParams(lp);
		}
	}
	
	public void reviseViewHeight1(View view) {
		if (view != null) {
			ViewGroup.LayoutParams lp = view.getLayoutParams();
			lp.height = PhoneScreen.reviseHeight(lp.height);
			view.setLayoutParams(lp);
		}
	}

	public void reviseViewWidth1(View view) {
		if (view != null) {
			ViewGroup.LayoutParams lp = view.getLayoutParams();
			lp.width = PhoneScreen.reviseHeight(lp.width);
			view.setLayoutParams(lp);
		}
	}

	/** 判断手机上是否安装该游戏 */
//	public boolean isInstalledGame(String packageName) {
//		return BoyaaApplication.getInstance().isInstalledGame(packageName);
//	}
	public boolean isInstalledGame(String packageName) {
		try {
			Log.d("isStall", "安装了吗？3" + packageName);
			ApplicationInfo info = getPackageManager().getApplicationInfo(packageName, PackageManager.GET_PERMISSIONS);
			if (info != null) {
				return true;
			}
		} catch (NameNotFoundException e) {}
		return false;
	}
	@Override
    protected void onPause() {
        super.onPause();
        Log.d(TAG, "Cancel the dialog");
        if (mProgressDialog != null) {
            mProgressDialog.cancel();
        }
    }

    /** 安装游戏 
	 * @param _id */
	public int installApplication(String path, long _id){
		if(!SDCardUtil.isSDCardAvailable()){//Sd卡未挂
			return SD_ERROR;
		} else if (TextUtils.isEmpty(path)) {
			return FILE_ERROR;
		} else {
			if (new File(path).exists()) {
				Intent intent = new Intent(Intent.ACTION_VIEW);
				intent.setDataAndType(Uri.fromFile(new File(path)), "application/vnd.android.package-archive");
				startActivity(intent);
				callServer(_id);
				return SUC;
			} else {
				//弹出对话框，提示，改变状态。点击重新下载
				return FILE_ERROR;
			}
			
		}
		
	}
	/**
	 * 上报用户安装的游戏
	 */
	private void callServer(long id){
//		if(BoyaaApplication.isDebug)Log.e("guangli.liu", "开始上报用户安装的游戏。。。。");
		final String optype = "INSTALL";
		HashMap<String,Object> param = new HashMap<String, Object>();
		param.put("platform", "ANDROID");
		param.put("devid", Secret.md5(EnviromentUtil.getDeviceId(this)));
		param.put("optype", optype);
		param.put("appid", id);
		param.put("lang", this.getString(R.string.language));
//		String api = PHPRequest.createApi(PHPRequest.LOGIN_METHOD, PHPRequest.defaultUid, param);
//		TaskManager.getInstance().addTask(new RequestPhpServerTask(PHPRequest.SERVER_RUL, api,null));
	}

}
