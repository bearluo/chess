package com.boyaa.pointwall;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.ContentValues;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.boyaa.apkdownload.ApkDownloadObserver;
import com.boyaa.apkdownload.ApkDownloader;
import com.boyaa.apkdownload.ApkInfo;
import com.boyaa.baseactivity.BaseActivity;
import com.boyaa.cache.Cacheable;
import com.boyaa.cache.MemoryCache;
import com.boyaa.common.BitmapPool;
import com.boyaa.common.BoyaaMath;
import com.boyaa.common.ClickLimit;
import com.boyaa.common.NetworkUtil;
import com.boyaa.data.GameData;
import com.boyaa.db.APKInfoDao;
import com.boyaa.gamedetails.GameDetailActivity;
import com.boyaa.pointwall.viewholder.ViewHolder;
import com.boyaa.thread.TaskManager;
import com.boyaa.thread.task.ImageDownloadTask;
import com.boyaa.widget.ProgressBar;
public class PointWallGamesListAdapter extends BaseAdapter {
	
	private int type;
	
	private Activity mActivity;
	
	private List<GameData> dataList;
	
	private Map<String, Integer> stateMap;
	
	private LayoutInflater inflater;

	private APKInfoDao mAPKInfoDao;
	
	private PointWallAppManager mPwManager;
	
	private HashMap<ViewHolder, String> bindViewMap; //= new HashMap<ViewHolder, String>();

	private ApkDownloader mApkDownloader;
	

	private boolean isBeginDownLoad = false;
	
	public PointWallGamesListAdapter(Activity activity, List<GameData> list, int type, HashMap<ViewHolder, String> bv) {
		this.type = type;
		mActivity = activity;
		bindViewMap = bv;
		dataList = list;
		putCache(dataList);
        stateMap = new HashMap<String, Integer>();
		init();
	}
	
	private void putCache(List<GameData> list) {
		if (list != null) {
			for (GameData data : list) {
				MemoryCache.put(GameData.TAG + type + data.url, data, true);
			}
		}
	}
	private void init() {
		inflater = LayoutInflater.from(mActivity);
		mAPKInfoDao = new APKInfoDao();
		mPwManager = PointWallActivity.getInstance().getPWAppManager();
		mApkDownloader = ApkDownloader.getInstance();
		
	}
	
	void update(String apkUrl, int completeSize, int apkFileSize) {
		Log.d("Thread111", "AllGamesListAdapter "+completeSize+"/"+apkFileSize + "字节");
		ViewHolder holder = getBindViewHolder(apkUrl);
		if (holder != null) {
			int percent = BoyaaMath.percent(completeSize, apkFileSize);
			Log.d("Thread111", holder.titleView.getText() +"="+percent);
			if (apkFileSize == 0) {
            	Log.d("Thread111", "不可能走到这里 AllGamesListAdapter update() apkFileSize == 0");
            } else if (completeSize == apkFileSize) {
            	Log.d("Thread111", "完成 "+completeSize+"/"+apkFileSize + "字节");
            	holder.downloadImageView.clear();
            	holder.downloadImageView.setBackgroundResource(R.drawable.all_games_download_getpoints);
            	holder.downloadTextView.setText(R.string.all_game_getpoints);
            	holder.failImageView.setVisibility(View.GONE);
            	holder.desc_app_item.setVisibility(View.VISIBLE);
            	holder.sizeLayout.setVisibility(View.VISIBLE);
            	holder.hasUpdateImageView.setVisibility(View.GONE);
            	stateMap.put(apkUrl, ApkInfo.COMPLETED);
            	mApkDownloader.delete_apkMap_item(apkUrl);
            	if (holder.type == 0)//byGame
            	{
            		GameData data = mPwManager.getByGameData(apkUrl);
            		data.state = GameData.GET_POINTS;
            		MemoryCache.put(GameData.TAG + type + data.url, data, true);
            		updateGameDataState(0, data);
            	}else if (holder.type == 1)//sgGame
            	{
            		GameData data = mPwManager.getSgGameData(apkUrl);
            		data.state = GameData.GET_POINTS;
            		MemoryCache.put(GameData.TAG + type + data.url, data, true);
            		updateGameDataState(1, data);

            	}
            	Log.d("Thread111", "入库 "+completeSize+"/"+apkFileSize + "字节");
            	
            } else {
            	//holder.downloadImageView.clear();
            	//
//            	if (getString(R.string.all_game_continu) != holder.downloadTextView.getText()){
//            		holder.downloadTextView.setText("");
//            	}
            	if (isBeginDownLoad){
            		holder.downloadTextView.setText("");
            	}else{
            		holder.downloadTextView.setText(R.string.all_game_continu);
            	}
//            	isBeginDownLoad  = true;
            	holder.downloadImageView.setProgress(percent);
            	holder.downloadImageView.update();
            }
		}else{
			Log.d("Thread111", "holder空了？？？");
		}
	}
	
	void notice(String apkUrl, int type, int arg2) {
		ViewHolder holder = getBindViewHolder(apkUrl);
//		stateMap.put(apkUrl, Integer.valueOf(type));
		Log.e("Thread", "AllGamesListAdapter notice type:"+type);
		if (holder != null) {
			switch (type) {
			case ApkInfo.PAUSE:
				isBeginDownLoad = false;
				
				break;
			
			case ApkInfo.WAITING:
				
				break;
			case ApkDownloadObserver.NETWORK_RESUME:
				PointWallActivity.getInstance().showToast(getString(R.string.network_available));

				break;
			case ApkInfo.DOWNLOADING:
				isBeginDownLoad = true;
				break;
			case ApkDownloadObserver.EXIST_FULL_APK:

				break;
			case ApkDownloadObserver.GET_APK_SIZE_FAIL:
				Log.d("CDH", "GET_APK_SIZE_FAIL");
				break;
			case ApkDownloadObserver.CREATE_APK_FILE_FAIL:
				Log.d("CDH", "CREATE_APK_FILE_FAIL");
				break;
			case ApkDownloadObserver.NETWORK_UNAVAILABLE_ERROR:
				Log.d("CDH", "NETWORK_UNAVAILABLE_ERROR");
				PointWallActivity.getInstance().showToast(getString(R.string.network_unavailable));
				
				break;
			case ApkDownloadObserver.UNKNOW_ERROR:
				Log.d("CDH", "UNKNOW_ERROR");
				//ApkDownloader.getInstance().operation(apkUrl, ApkInfo.DELETE);
				ApkDownloader.getInstance().delete(mAPKInfoDao.getApkInfo(apkUrl));
				break;
			default:
				break;
			}
		}
	}
	private ViewHolder getBindViewHolder(String apkUrl) {
		ViewHolder holder = null;
		if (bindViewMap.containsValue(apkUrl)) {
			for (Map.Entry<ViewHolder, String> entry : bindViewMap.entrySet()) {
				if (entry.getValue().equals(apkUrl)) {
					holder = entry.getKey();
				}
			}
		}
		return holder;
	}
	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return dataList == null ? 0 : dataList.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public long getItemId(int position) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		ViewHolder holder  = null;
		
		if (null == convertView){
			convertView = inflater.inflate(R.layout.all_games_list_item, null);
			holder = new ViewHolder();
			//app图标
			holder.imageView = (ImageView)convertView.findViewById(R.id.all_games_item_image);
			//app名称
			holder.titleView = (TextView)convertView.findViewById(R.id.all_games_list_item_title);
			//app描述布局
			holder.descLayout = (LinearLayout)convertView.findViewById(R.id.desc_app_layout);
			//app描述
			holder.desc_app_item = (TextView)convertView.findViewById(R.id.all_games_list_item_desc);
			//app大小布局
			holder.sizeLayout = (LinearLayout)convertView.findViewById(R.id.size_layout);
			//app大小
			holder.size_app_item = (TextView)convertView.findViewById(R.id.all_games_list_item_size);
			//app加载失败图标
			holder.failImageView = (ImageView)convertView.findViewById(R.id.all_games_list_item_fail);
			//下载按钮
			holder.downloadImageView = (ProgressBar)convertView.findViewById(R.id.all_games_list_item_download_image);
			Log.d("Thread111", holder.downloadImageView +"=====");
			holder.downloadTextView = (TextView)convertView.findViewById(R.id.all_games_list_item_dl_text);
			//应用对应的积分
			holder.point_app_item = (TextView)convertView.findViewById(R.id.all_games_list_item_download_points);
			//app是否有更新图标
			holder.hasUpdateImageView = (ImageView)convertView.findViewById(R.id.all_games_list_item_has_update_icon);
			//item左、右半边视图
			holder.left = convertView.findViewById(R.id.all_games_item_left);
			holder.right = convertView.findViewById(R.id.all_games_item_right);
			//app信息布局
			holder.infoView = (LinearLayout)convertView.findViewById(R.id.info_layout);
			
			holder.type = type;
			convertView.setTag(holder);
			
			
		} else{
			
			holder = (ViewHolder)convertView.getTag();
		}
		boolean evenLine = (position % 2) == 1;
		if (evenLine) {
			convertView.setBackgroundResource(R.drawable.all_game_cover);
		} else {
			if (type == 1 && position == getCount() - 1) {//推荐游戏
				convertView.setBackgroundResource(R.drawable.my_game_under_line);
			} else {				
				convertView.setBackgroundDrawable(null);
			}
		}
		GameData data = dataList.get(position);
		Cacheable cacheable = MemoryCache.get(GameData.TAG + type + data.url);
		if (cacheable != null) {
			data = (GameData)cacheable;
		}
		bindViewMap.put(holder, data.url);
		holder.imageView.setImageResource(R.drawable.small_default);
		if (!TextUtils.isEmpty(data.image)) {
			Bitmap bitmap = BitmapPool.getBitmap(data.image);
			if (bitmap != null) {
				Log.e("guangli.liu","width:"+bitmap.getWidth());
				holder.imageView.setImageBitmap(bitmap);
//				holder.imageView.setBackgroundResource(R.drawable.image_shadow);
			} else {
				TaskManager.getInstance().addTask(new ImageDownloadTask(mActivity, holder.imageView, data.image));
			}
			
		}
		holder.titleView.setText(data.name);
		holder.desc_app_item.setVisibility(View.VISIBLE);
		holder.desc_app_item.setText(data.shortdesc);
		holder.size_app_item.setText(getString(R.string.package_size) + getString(R.string.semicolon) + data.size + getString(R.string.unit_mb));
		holder.point_app_item.setText(String.valueOf(Integer.parseInt(data.points)*100));
		holder.left.setTag(position);
		holder.left.setOnClickListener(leftClickListener);
		holder.infoView.setTag(position);
		holder.right.setTag(holder.infoView);
		holder.right.setOnClickListener(rightClickListener);
		holder.downloadImageView.setTag(holder.infoView);
		holder.downloadImageView.setOnClickListener(rightClickListener);
		holder.failImageView.setVisibility(View.GONE);
		holder.hasUpdateImageView.setVisibility(View.GONE);
		holder.sizeLayout.setVisibility(View.VISIBLE);
		
//		ApkInfo info = ApkDownloader.getInstance().getApkInfo(data.url);//apkMap缓存里获得ApkInfo
//		if (info==null) {
//			info =  mAPKInfoDao.getApkInfo(data.url);//数据库中获得ApkInfo
//		}
		Log.d("isStall", "安装了吗？1");
		if (PointWallActivity.getInstance().isInstalledGame(data.packagename))
		{
			Log.d("isStall", "安装了吗？2");
			data.state = GameData.HAS_INSTALL;
			MemoryCache.put(GameData.TAG + type + data.url, data, true);
			updateGameDataState(holder.type, data);
//			Toast.makeText(mActivity, "已经安装！",Toast.LENGTH_SHORT).show();
//			notifyDataSetChanged();
			
		} 
		//判断在上次退出时，是否有正在下载中的任务，如果有则从断点处继续下载，没有则正常刷新UI
		if (data.state == GameData.IN_DOWNLOAD && !mApkDownloader.isHandingApk(data.url))
		{
			data.state = GameData.CONTINUE_DOWNLOAD;
			MemoryCache.put(GameData.TAG + type + data.url, data, true);
			updateGameDataState(holder.type, data);
		}
		//else {
//			if ((info != null) && (info.completeSize == info.apkFileSize) && (data.state == GameData.NEED_INSTALL)) {//之前有下载且已完成下载，并已经持久化到数据库中
//				String apkFilePath = ApkFileManager.createApkFilePath(data.url);
//				if (!FileUtil.existFile(apkFilePath)) {
//					//下载了，但是下载文件被删掉了
////					mApkDownloader.delete(info);//删除ApkInfo数据库中的数据，因为apk已经没有了，ApkInfo没有存在的意义。
//					data.state = GameData.UNINIT_UPDATE;
//					MemoryCache.put(GameData.TAG + type + data.url, data, true);
//					updateGameDataState(holder.type, data);
//				}else{
//					data.state = GameData.NEED_INSTALL;
//					MemoryCache.put(GameData.TAG + type + data.url, data, true);
//					updateGameDataState(holder.type, data);
//				}
//			}		
//		}
		//state:当下次重新启动游戏的时候，根据GameData数据库中data的状态来更新ListView的item状态。
		switch (data.state){
			case GameData.UNINIT_UPDATE://data初始状态0;
				holder.downloadTextView.setText(R.string.all_game_download);
				holder.downloadImageView.clear();
				holder.downloadImageView.setBackgroundResource(R.drawable.all_games_download_img);
				break;
			case GameData.NEED_INSTALL://data需要安装状态3;
				holder.downloadTextView.setText(R.string.all_game_install);
				holder.downloadImageView.clear();
				holder.downloadImageView.setBackgroundResource(R.drawable.all_games_download_img);
				break;
			case GameData.HAS_INSTALL://data已经安装状态5;
				holder.downloadTextView.setText(R.string.all_game_hasinstall);
				holder.downloadImageView.clear();
				holder.downloadImageView.setBackgroundResource(R.drawable.all_games_hasdownload_img);
				break;
			case GameData.IN_DOWNLOAD://data下载中状态6;
				holder.downloadTextView.setText("");
				holder.downloadImageView.setBackgroundResource(R.drawable.all_games_download_img);
				break;	
			case GameData.GET_POINTS://data领取状态4;
				holder.downloadTextView.setText(R.string.all_game_getpoints);
				holder.downloadImageView.clear();
				holder.downloadImageView.setBackgroundResource(R.drawable.all_games_download_getpoints);
				break;				
			case GameData.CONTINUE_DOWNLOAD://data领取状态4;
				holder.downloadTextView.setText(R.string.all_game_continu);
				holder.downloadImageView.clear();
				holder.downloadImageView.setBackgroundResource(R.drawable.all_games_download_img);
				break;
			default:
				break;
			
		}
		
		return convertView;
	}

	
	
	
	/** 点击左边进入详情界面 */
	private OnClickListener leftClickListener = new OnClickListener() {
		public void onClick(View view) {
			if (ClickLimit.mutipleClick()) return;

			int index = (Integer)view.getTag();
			GameData data = dataList.get(index);
			/*ApkInfo info = mAPKInfoDao.getApkInfo(data.url);
			if (!data.needUpdate && hasGame(data, info)) {
				return;
			}*/
			String pts = PointWallActivity.getInstance().getPointFromPw();
			Intent intent = new Intent(mActivity, GameDetailActivity.class);
			intent.putExtra("game_type", data.type);
			intent.putExtra("game_id", data.id);
			intent.putExtra("points", pts);
			
			mActivity.startActivity(intent);
			mActivity.overridePendingTransition(R.anim.push_left_in,R.anim.push_left_out);
		}
	};

//	
	/** 点击右边处理下载逻辑 */
	private OnClickListener rightClickListener = new OnClickListener() {
		

		private TextView downloadText;
		private ProgressBar mProgressBar;
		
		
		public void onClick(final View view) {
			if (ClickLimit.mutipleClick()) return;
			final LinearLayout infoView = (LinearLayout) view.getTag();
			int index = (Integer)infoView.getTag();
			//下载、更新处理
			GameData tempData = dataList.get(index);
			Cacheable cacheable = MemoryCache.get(GameData.TAG + type + tempData.url);
			if (cacheable != null) {
				tempData = (GameData)cacheable;
			}
			final GameData data = tempData;
			ApkInfo info = mApkDownloader.getApkInfo(data.url);
			if (info==null) {
				//info =  mAPKInfoDao.getApkInfo(data.url);
				info = mApkDownloader.getApkInfoDao().getApkInfo(data.url);
			}
            ((LinearLayout)infoView.getChildAt(1)).setVisibility(View.VISIBLE);
            ((LinearLayout)infoView.getChildAt(2)).setVisibility(View.VISIBLE);
            ((LinearLayout)infoView.getChildAt(0)).getChildAt(1).setVisibility(View.GONE);
            final FrameLayout superParent = (FrameLayout) infoView.getParent();
            ((ImageView)superParent.getChildAt(1)).setVisibility(View.GONE);
			FrameLayout parent = null;
			 if (view instanceof ImageView) {
				 parent = (FrameLayout)view.getParent();
				} else {
					parent = (FrameLayout)((view.findViewById(R.id.all_games_list_item_download_image)).getParent());
				}
			 int childCount = parent.getChildCount();
			 if (childCount >= 2) {
				downloadText = (TextView)parent.getChildAt(1);
				mProgressBar = (ProgressBar)parent.getChildAt(0);
			 }
			 String [] ids = PointWallActivity.getInstance().getIds();//获取appid和uid
			 
			 if (data.state == GameData.UNINIT_UPDATE){
				 Log.d("fastClick", "GameData.UNINIT_UPDATE1");
				if (mApkDownloader.get_apkMap_size() < 1){
					 if(NetworkUtil.isNetworkAvailable()){
						mPwManager.addDownLoadCount(mActivity, ids[0], ids[1], String.valueOf(data.id));
						downloadText.setText(R.string.all_game_downloading);
	//					mProgressBar.show();
						mApkDownloader.addApk(data.url, type);
						data.state = GameData.IN_DOWNLOAD;//下载中
						MemoryCache.put(GameData.TAG + type + data.url, data, true);
						updateGameDataState(type, data);
						Log.d("fastClick", "GameData.UNINIT_UPDATE2");
					 }else{
						PointWallActivity.getInstance().showToast(getString(R.string.network_unavailable));
					}
				}else{
					PointWallActivity.getInstance().showToast(getString(R.string.downloadTaskIsFull));
				}
				return;
			 } else if (data.state == GameData.IN_DOWNLOAD){
				Log.d("fastClick", "GameData.IN_DOWNLOAD1");
				if (isBeginDownLoad){
					mApkDownloader.puase(data.url);
					data.state = GameData.CONTINUE_DOWNLOAD;//下载中
					MemoryCache.put(GameData.TAG + type + data.url, data, true);
					updateGameDataState(type, data);
					mProgressBar.clear();
					mProgressBar.setBackgroundResource(R.drawable.all_games_download_img);
					downloadText.setText(R.string.all_game_continu);
					Log.d("fastClick", "GameData.IN_DOWNLOAD2");	
				}

				return;
			 }else if (data.state == GameData.CONTINUE_DOWNLOAD){
				 Log.d("fastClick", "GameData.CONTINUE_DOWNLOAD1");
					if (mApkDownloader.get_apkMap_size() < 1){
						 if(NetworkUtil.isNetworkAvailable()){
							downloadText.setText("");
		//					mProgressBar.show();
							mApkDownloader.addApk(data.url, type);
							data.state = GameData.IN_DOWNLOAD;//下载中
							MemoryCache.put(GameData.TAG + type + data.url, data, true);
							updateGameDataState(type, data);
						 }else{
							PointWallActivity.getInstance().showToast(getString(R.string.network_unavailable));
						}
					}else{
						PointWallActivity.getInstance().showToast(getString(R.string.downloadTaskIsFull));
					}
					return;
			 } else if (data.state == GameData.GET_POINTS){
    			
    			if(NetworkUtil.isNetworkAvailable()){
	    			String totalPoints = mPwManager.addUserPoints(ids[0], ids[1], ids[2], String.valueOf(data.id), data.points);
	    			if (null != totalPoints){
	    				PointWallActivity.getInstance().showPoints(totalPoints);
	    			}
        			data.state = GameData.NEED_INSTALL;
        			MemoryCache.put(GameData.TAG + type + data.url, data, true);
        			updateGameDataState(type, data);
        			downloadText.setText(R.string.all_game_install);
        			mProgressBar.setBackgroundResource(R.drawable.all_games_download_img);
	    		}else{
	    			PointWallActivity.getInstance().showToast(getString(R.string.network_unavailable));
	    		}
    			return;
        	} else if (data.state == GameData.NEED_INSTALL){
        			int result = ((BaseActivity) mActivity).installApplication(info.apkFilePath,data.id);//安装
        			switch (result) {
        			case BaseActivity.FILE_ERROR:
        				 //mAPKInfoDao.deleteApkInfo(info);
        				 mApkDownloader.delete(info);
        				 new AlertDialog.Builder(mActivity)
        				 .setMessage(getString(R.string.install_fail_file))
        				 .setNegativeButton(getString(R.string.btn_no), null)
        				 .setPositiveButton(getString(R.string.btn_yes), new DialogInterface.OnClickListener() {
							public void onClick(DialogInterface dialog, int which) {
								// TODO Auto-generated method stub
								if(NetworkUtil.isNetworkAvailable()){
//										FlurryAgent.logEvent("button-下载游戏 ID："+data.id+" Name:"+data.name);
									data.state = GameData.IN_DOWNLOAD;
									MemoryCache.put(GameData.TAG + type + data.url, data, true);
									updateGameDataState(type, data);
									notifyDataSetChanged();
//										mProgressBar.show();
									mApkDownloader.addApk(data.url, type);
								}  else {
									PointWallActivity.getInstance().showToast(getString(R.string.network_unavailable));
								}
							
							}
							
						}).show();
        				break;
        			case BaseActivity.SD_ERROR:
        				Toast.makeText(mActivity, getString(R.string.install_fail_sdcard),Toast.LENGTH_SHORT).show();
        				break;
        			case BaseActivity.SUC:
        				break;
        			default:
        				break;
        			}
        			return;
        		}else if (data.state == GameData.HAS_INSTALL){
        			return;
        		}
     
		}
	};
	
	private String getString(int rid) {
		return mActivity.getString(rid);
	}
	
	
	//UI状态（下载、领取、安装、已安装）更新后，用来更新数据库里的状态，以便下次登录更新UI状态。
	public void updateGameDataState(int index, GameData data){
    	ContentValues values = new ContentValues();
    	values.put("state", data.state);
		if (index == 0)//byGame
    	{
    		mPwManager.updateByGameState(data.id, values);
    		
    	}else if (index == 1)//sgGame
    	{
    		mPwManager.updateSgGameState(data.id, values);
    	}	
		
	}
}
