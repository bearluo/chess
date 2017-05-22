package com.boyaa.pointwall;


import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.boyaa.apkdownload.ApkDownloadObserver;
import com.boyaa.apkdownload.ApkDownloader;
import com.boyaa.baseactivity.BaseActivity;
import com.boyaa.common.ClickLimit;
import com.boyaa.db.DBHelper;
import com.boyaa.php.PHPRequest;
import com.boyaa.php.Secret;
import com.boyaa.pointwall.viewholder.ViewHolder;
import com.boyaa.widget.ProgressDlg;
public class PointWallActivity extends BaseActivity {
	private static final int TOAST_OFFSET_Y = 300;
	private final static int BY_INDEX = 0;
	private final static int SG_INDEX = 1;
	private static PointWallActivity THIS;
	
	private PointWallAppManager mAllGamesManager;

//	private Button backButton;
    private ImageView mBoyaaGamesTitle,mSuggestGamesTitle;
	private ListView mBylistView = null;
	private ListView mSglistView = null;;
	private ViewPager mvPager;
	private MyPageViewerAdapter myPageViewerAdapter;
	private final int ITEMS_COUNT = 20;
    private int currentItem = BY_INDEX;
    
    
	private  PointWallGamesListAdapter mByListAdapter;
	private  PointWallGamesListAdapter mSgListAdapter;
    private  ProgressDlg loaddialog;
    
    private static DBHelper mDBHelper;
    
    private static ApkDownloadObserver mObserver;
    
    private static String appid, uid, mtkey;
    
    private String points;
    
    private TextView pointsText;
    
    private HashMap<ViewHolder, String> bindViewMap = new HashMap<ViewHolder, String>();
    
    private int mByGameCount, mSgGameCount;
   
    
	private View byView = null;
    private View sgView = null;
    
    private static boolean isAddCoins = false;
    
	@Override
	protected void onCreate(Bundle savedInstanceState){
		super.onCreate(savedInstanceState);

		setContentView(R.layout.all_games);
		Log.i("CDH", "PW's onCreate()");
		THIS = this;
		initViews();
		ininDBHelper();
		mAllGamesManager = new PointWallAppManager(this);
		appid = THIS.getIntent().getStringExtra("appid");
		uid = THIS.getIntent().getStringExtra("uid");
		mtkey = THIS.getIntent().getStringExtra("mtkey");
		PHPRequest.LUA_SERVERADDR = THIS.getIntent().getStringExtra("developUrl"); 
		loaddialog = new ProgressDlg(THIS, R.style.dialog);
		initApps();
	}
	public static PointWallActivity getInstance(){
		return THIS;
	}
	
	public void ininDBHelper(){
		if (null == mDBHelper){
			mDBHelper = new DBHelper(THIS);
		}
	}
	
    public synchronized static DBHelper getDBHelper(){
        return mDBHelper;
    }
    
    public PointWallAppManager getPWAppManager(){
        return mAllGamesManager;
    }
    public String[] getIds(){
    	String [] ids = new String[]{appid, uid, mtkey};
    	
    	return ids;
    }
    
    public String getPointFromPw(){
    	
//    	points = (String)(pointsText.getText());
    	return points;
    }
	private DownLoadOverCallBack loadOverCallBack = new DownLoadOverCallBack() {
		@Override
		public void loadover(int index, boolean isUpdate) {
			// TODO Auto-generated method stub
			if (isUpdate){
				if (BY_INDEX == index){
					if (loaddialog.isShowing()){
						loaddialog.dismiss();
					}
					setByMoreItems();//Note: When first introduced, this method could only be called 
									 //before setting the adapter with setAdapter(ListAdapter).
					initByGameAdapter();
				}else if (SG_INDEX == index){
					setSgMoreItems();
					initSgGameAdapter();
				}
			}else{//不需要更新，从数据库加载
				if (BY_INDEX == index){
					if (loaddialog.isShowing()){
						loaddialog.dismiss();
					}
					setByMoreItems();
					initByGameAdapter();
					
				}else if (SG_INDEX == index){
					setSgMoreItems();
					initSgGameAdapter();
				}
			}
		}
	};
	

	

	private void initApps() {
		loaddialog.show();
		isUpdateByGame();
		isUpdateSgGame();
	}
	public void isNotConnectNet(){
		if (loaddialog.isShowing()){
			loaddialog.dismiss();
		}
		showToast(getString(R.string.network_unavailable));
		
	}

	protected void setByMoreItems() {
		mByGameCount = mAllGamesManager.getByGameCount();
		Log.v("gagaga",String.valueOf(mByGameCount));
		if (mByGameCount > ITEMS_COUNT) {
			LayoutInflater inflater = LayoutInflater.from(THIS);
			View byview = inflater.inflate(R.layout.all_games_list_foot, null);
			mBylistView.addFooterView(byview);
			final Button byfootButton = (Button)byview.findViewById(R.id.all_games_foot_button);
			byfootButton.setOnClickListener(new OnClickListener() {

				public void onClick(View v) {
					if (ClickLimit.mutipleClick()) return;

					int curSize = mAllGamesManager.boyaaGameDataList.size();
					if (curSize < mByGameCount) {
						mAllGamesManager.boyaaGameDataList.addAll(mAllGamesManager.getBoyaaGameDataList(curSize, ITEMS_COUNT));
						mByListAdapter.notifyDataSetChanged();
					}
					if (curSize + ITEMS_COUNT > mByGameCount) {
						byfootButton.setVisibility(View.GONE);
					}
				}
				
			});
		}

	}
	protected void setSgMoreItems() {
		mSgGameCount = mAllGamesManager.getSgGameCount();
		Log.v("gagaga",String.valueOf(mSgGameCount));
		if (mSgGameCount > ITEMS_COUNT) {
			LayoutInflater inflater = LayoutInflater.from(THIS);
			View view = inflater.inflate(R.layout.all_games_list_foot, null);
			mSglistView.addFooterView(view);
			final Button footButton = (Button)view.findViewById(R.id.all_games_foot_button);
			footButton.setOnClickListener(new OnClickListener() {

				public void onClick(View v) {
					if (ClickLimit.mutipleClick()) return;
					int curSize = mAllGamesManager.suggestGameDatasList.size();
					if (curSize < mSgGameCount) {
						mAllGamesManager.suggestGameDatasList.addAll(mAllGamesManager.getSuggestGameDataList(curSize, ITEMS_COUNT));
						mSgListAdapter.notifyDataSetChanged();
					}
					if (curSize + ITEMS_COUNT > mSgGameCount) {
						footButton.setVisibility(View.GONE);
					}
				}
				
			});
		}
	}
	private void isUpdateByGame() {
		mAllGamesManager.getAppListByPhp(THIS, BY_INDEX, bindViewMap, loadOverCallBack);
	}
	
	private void isUpdateSgGame() {
		mAllGamesManager.getAppListByPhp(THIS, SG_INDEX, bindViewMap, loadOverCallBack);
	}
	private void initViews() {
        mvPager = (ViewPager) this.findViewById(R.id.games_pager);
        byView = getLayoutInflater().inflate(R.layout.games_list, null);
        sgView = getLayoutInflater().inflate(R.layout.games_list, null);
		mBylistView = (ListView)byView.findViewById(R.id.games_list);
		mSglistView = (ListView)sgView.findViewById(R.id.games_list);
		mBoyaaGamesTitle = (ImageView) findViewById(R.id.boyaa_games_title);
		mSuggestGamesTitle = (ImageView) findViewById(R.id.suggest_games_title);
//		pointsText = (TextView)this.findViewById(R.id.game_detail_title_dl_points);
		
		OnClickListener mClickListener = new OnClickListener() {
			
			public void onClick(View v) {
				// TODO Auto-generated method stub
				if(v==mBoyaaGamesTitle){
					currentItem = BY_INDEX;
				} else {
					currentItem = SG_INDEX;
				}
				mvPager.setCurrentItem(currentItem);
			}
		};
		mBoyaaGamesTitle.setOnClickListener(mClickListener);
		mSuggestGamesTitle.setOnClickListener(mClickListener);
		setTitleState();
		Log.d("timestamp","PointWallActivity.initViews() after setTitleState() ");
		ImageButton backBtn = (ImageButton) findViewById(R.id.game_detail_title_left_btn);
		backBtn.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				onBackPressed();
			}
		});
		List<View> views = new ArrayList<View>();
		views.add(byView);
		views.add(sgView);
		myPageViewerAdapter = new MyPageViewerAdapter(views);
		mvPager.setAdapter(myPageViewerAdapter);
		mvPager.setCurrentItem(currentItem);
		mvPager.setOnPageChangeListener(new OnPageChangeListener() {
			
			public void onPageSelected(int arg0) {
				// TODO Auto-generated method stub
				currentItem = arg0;
				setTitleState();
			}
			
			public void onPageScrolled(int arg0, float arg1, int arg2) {
				// TODO Auto-generated method stub
				
			}
			
			public void onPageScrollStateChanged(int arg0) {
				// TODO Auto-generated method stub
				
			}
		});
		mObserver = new ApkDownloadObserver() {

			@Override
			public void update(String apkUrl, int completeSize, int apkFileSize) {
				if (currentItem==SG_INDEX) {
					if (null != mSgListAdapter){
						mSgListAdapter.update(apkUrl, completeSize, apkFileSize);
					}
				} else {
					if (null != mByListAdapter){
						mByListAdapter.update(apkUrl, completeSize, apkFileSize);
					}
				}
			}

			@Override
			public void notice(String apkUrl, int type, int arg2) {
				if (currentItem==SG_INDEX) {
					if (null != mSgListAdapter){
						mSgListAdapter.notice(apkUrl, type, arg2);
					}
				} else {
					if (null != mByListAdapter){
						mByListAdapter.notice(apkUrl, type, arg2);
					}
				}
			}
			
		};
}
	@Override
	public void onBackPressed() {
		setResult(RESULT_OK, THIS.getIntent().putExtra("isAddCoins", true));
		finish();
	}
	private void setTitleState(){
		if (currentItem==BY_INDEX) {
			mBoyaaGamesTitle.setBackgroundResource(R.drawable.boyaa_games_label_focus);
			mSuggestGamesTitle.setBackgroundResource(R.drawable.suggest_games_label);
		} else {
			mBoyaaGamesTitle.setBackgroundResource(R.drawable.boyaa_games_label);
			mSuggestGamesTitle.setBackgroundResource(R.drawable.suggest_games_label_focus);
		}
	}
//	private void setEvents() {
//		setSelector(backButton, R.drawable.back_bg, R.drawable.back_bg_clicked);
//	}


	private void initByGameAdapter() {
		mAllGamesManager.boyaaGameDataList = mAllGamesManager.getBoyaaGameDataList(0, ITEMS_COUNT);
		mByListAdapter = new PointWallGamesListAdapter(THIS, mAllGamesManager.boyaaGameDataList, BY_INDEX, bindViewMap);
		mBylistView.setAdapter(mByListAdapter);
		
	}
	private void initSgGameAdapter() {
		mAllGamesManager.suggestGameDatasList = mAllGamesManager.getSuggestGameDataList(0, ITEMS_COUNT);
		mSgListAdapter = new PointWallGamesListAdapter(THIS, mAllGamesManager.suggestGameDatasList, SG_INDEX, bindViewMap);
		mSglistView.setAdapter(mSgListAdapter);
	}
	protected void onResume() {
		super.onResume();
		Log.d("CDH","PW'S onResume");
//		getPoints(pointsText);
		ApkDownloader.getInstance().setApkDownloadObserver(mObserver);
		if (mSgListAdapter != null && mByListAdapter != null){
			if (currentItem==SG_INDEX) {
				Log.d("isStall", "安装了吗？ in onResume Sg");
				mSgListAdapter.notifyDataSetChanged();
			} else {
				Log.d("isStall", "安装了吗？ in onResume By");
				mByListAdapter.notifyDataSetChanged();
			}
		}
	}
	@Override
	protected void onRestoreInstanceState(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onRestoreInstanceState(savedInstanceState);
	}
	protected void onPause() {
		Log.d("Thread111","onPause");
		super.onPause();
//		ApkDownloader.getInstance().setApkDownloadObserver(null);
		
		//showToast("观察者暂停了" + mObserver.toString());
	}
	
	@Override
	protected void onStop() {
		// TODO Auto-generated method stub
		Log.d("CDH","PW'S onStop");
		//判断是否退出积分墙，用来解决PointWallGamesListAdapter---update退出时setText为“继续”bug。
		
		super.onStop();
	}
	protected void onDestroy() {
		Log.d("CDH","PW'S onDestroy");
		super.onDestroy();
	};

	@Override
	protected void onUpdate() {
		// TODO Auto-generated method stub
		//super.onUpdate();
		if (null != mByListAdapter){
			mByListAdapter.notifyDataSetChanged();
		}
		
	}

	public interface DownLoadOverCallBack
	{
		public void loadover(int index, boolean isUpdate);
	}
	
	private Toast mToast;
	
	
	public void showToast(String text) {
        if(mToast == null) {
            mToast = Toast.makeText(THIS, text, Toast.LENGTH_LONG);
            mToast.setGravity(Gravity.CENTER, 0, TOAST_OFFSET_Y);
        } else {
            mToast.setText(text);
        }
        mToast.show();
    }
	public void showPoints(String pts){
		points = pts;
		
		if (null == pts){
//			pointsText.setText("0");
		}else{
			isAddCoins  = true;
//			pointsText.setText(points);
		}
	}
	public void getPoints(TextView textview){
		if (appid != null && uid != null){
			mAllGamesManager.getUserPoints(THIS, appid, uid, textview);
			
		}
	}
	

}
