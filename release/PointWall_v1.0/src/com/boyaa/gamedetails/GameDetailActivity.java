package com.boyaa.gamedetails;

import java.util.ArrayList;

import android.app.AlertDialog;
import android.content.ContentValues;
import android.content.DialogInterface;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.Gallery;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.boyaa.apkdownload.ApkDownloadObserver;
import com.boyaa.apkdownload.ApkDownloader;
import com.boyaa.apkdownload.ApkInfo;
import com.boyaa.baseactivity.BaseActivity;
import com.boyaa.cache.Cacheable;
import com.boyaa.cache.MemoryCache;
import com.boyaa.common.BoyaaMath;
import com.boyaa.common.ClickLimit;
import com.boyaa.common.ImageFileManager;
import com.boyaa.common.NetworkUtil;
import com.boyaa.data.GameData;
import com.boyaa.db.APKInfoDao;
import com.boyaa.db.ByGameDao;
import com.boyaa.db.SgGameDao;
import com.boyaa.log.Log;
import com.boyaa.pointwall.PointWallActivity;
import com.boyaa.pointwall.PointWallAppManager;
import com.boyaa.pointwall.R;
import com.boyaa.thread.TaskManager;
import com.boyaa.thread.task.ImageDownloadTask;
import com.boyaa.widget.DotsView;
//import com.flurry.android.FlurryAgent;

public class GameDetailActivity extends BaseActivity {

    public static final String TAG = GameDetailActivity.class.getSimpleName();
    private GameDetailActivity THIS = this;
    private Gallery mGallery;
    private DotsView galleryDotsView;
    private ImageView appImage;
    private TextView briefDesc, downloadText;
    private TextView textShortDesc, textAppSize;
    private ProgressBar mProgressBar;
    private int gameType;
    private long gameId;
    private GameData mGameData;
    private ApkInfo info;
    private ApkDownloader mApkDownloader;
    private ApkDownloadObserver mObserver;
    private APKInfoDao mAPKInfoDao;
    private Object mGameDao;
    boolean fromDownloader;
    private TextView textAppName;
	private ImageButton downloadBtn;
	private PointWallAppManager mPwManager;
	private TextView pointAppItem;
	private String gamePoints;
	private TextView gameTotalPoints;
	private String totalPoints;
//	private ScrollView mScrollBlock ;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.game_detail);
        
        //gameType:0代表ByGame，1代表SgGame。
        gameType = this.getIntent().getIntExtra("game_type", -1);
        //gameId:GameData库中游戏Id(点击的那个游戏);
        gameId = this.getIntent().getLongExtra("game_id", -1);
        //FlurryAgent.logEvent("Activity-进入详情页，查看游戏：" + gameId);
        if (gameId == -1 || gameType == -1)
            this.finish();
        gamePoints = this.getIntent().getStringExtra("points");
        init();
        initViews();
        setEvents();
    }

    private void init() {
        /* 根据id加载游戏详细信息 */
    	if (gameType == 0)
    	{
    		mGameDao = new ByGameDao();
    		mGameData = ((ByGameDao) mGameDao).getGameData(gameId);
    	}else if (gameType == 1)
    	{
    		mGameDao = new SgGameDao();
    		mGameData = ((SgGameDao) mGameDao).getGameData(gameId);
    	}
        
        if (!TextUtils.isEmpty(mGameData.desc)) {
            mGameData.desc = String.format(mGameData.desc, mGameData.type, mGameData.version,
                    mGameData.size);
        }
        mAPKInfoDao = new APKInfoDao();
        mApkDownloader = ApkDownloader.getInstance();
        mPwManager = PointWallActivity.getInstance().getPWAppManager();
    }

    protected void onResume() {
        super.onResume();
        ApkDownloader.getInstance().setApkDownloadObserver(mObserver);
        updateHasInstallState();
        showPoints(gamePoints);
    }

    private void showPoints(String pts) {
		// TODO Auto-generated method stub
    	if (null == pts){
//    		gameTotalPoints.setText("0");
    	}else{
//    		gameTotalPoints.setText(pts);
    	}
    	
	}

	protected void onPause() {
        super.onPause();
        ApkDownloader.getInstance().setApkDownloadObserver(null);
    }
@Override
protected void onDestroy() {
	// TODO Auto-generated method stub
	super.onDestroy();
}


    private void initViews() {
    	
        textAppName = (TextView)findViewById(R.id.game_detail_app_name);
        textAppName.setText(mGameData.name);
        
        textShortDesc = (TextView)findViewById(R.id.game_detail_title_app_desc);
        textShortDesc.setText(mGameData.shortdesc);
        
        textAppSize = (TextView)findViewById(R.id.game_detail_title_app_size);
        
        mProgressBar = (ProgressBar)findViewById(R.id.game_detail_progress_bar);
        mProgressBar.setVisibility(View.VISIBLE);
        
        downloadBtn = (ImageButton)findViewById(R.id.game_detail_title_app_dl_button);
        downloadText = (TextView)findViewById(R.id.game_detail_title_app_dl_bar_text);
        
//      gameTotalPoints = (TextView)findViewById(R.id.game_detail_title_dl_points);
        
        
        pointAppItem = (TextView)findViewById(R.id.game_detail_title_app_dl_points);
        pointAppItem.setText(String.valueOf(Integer.parseInt(mGameData.points)*100));
        
        //游戏介绍
        TextView briefText = (TextView)findViewById(R.id.game_detail_bottom_brief);
        briefText.getPaint().setFakeBoldText(true);
        
//        mScrollBlock = (ScrollView)this.findViewById(R.id.game_detail_bottom_scrolview);
        
        //Gallery下面的小圆点。
        Bitmap selected = BitmapFactory.decodeResource(this.getResources(), R.drawable.dot_green);
        Bitmap unselected = BitmapFactory.decodeResource(this.getResources(), R.drawable.dot_gray);
        /* 初始化大图海报数据 */
        mGallery = (Gallery)this.findViewById(R.id.game_detail_bottom_gallery);
        mGallery.setVisibility(View.VISIBLE);
        ArrayList<String> imageUrlList = new ArrayList<String>();
        if (!TextUtils.isEmpty(mGameData.bigimage)) {
            for (String bigImageUrl : mGameData.bigimage.split(";")) {
                if (!TextUtils.isEmpty(bigImageUrl))
                    imageUrlList.add(bigImageUrl);
            }
        }
        mGallery.setAdapter(new GalleryAdapter(THIS, imageUrlList));
        galleryDotsView = (DotsView)this.findViewById(R.id.detail_gallery_dots);
        galleryDotsView.setDotCount(imageUrlList.size());//imageUrlList.size();
        galleryDotsView.setDotSize(5);
        galleryDotsView.setDot(selected, unselected);
        galleryDotsView.show();
        /* 初始化顶部数据信息 */
        appImage = (ImageView)this.findViewById(R.id.game_detail_title_app_image);
        if (!TextUtils.isEmpty(mGameData.image)) {
            /* 先出本地加载图片 */
            Bitmap bitmap = ImageFileManager.getImage(mGameData.image);
            if (bitmap != null) {
                appImage.setImageBitmap(bitmap);
//                appImage.setBackgroundResource(R.drawable.image_shadow);
            } else {
                /* 本地不存在，则重网络加载 */
                TaskManager.getInstance().addTask(
                        new ImageDownloadTask(THIS, appImage, mGameData.image));
            }
        }

//        mDownloadFailImageView = (ImageView)findViewById(R.id.down_fail);
        

//
//        // int completeSize =
        //mApkDownloader.getApkInfoCompleteSize(mGameData.url);
        info = mApkDownloader.getApkInfo(mGameData.url);
        fromDownloader = true;
        if (info == null) {
            fromDownloader = false;
            info = mAPKInfoDao.getApkInfo(mGameData.url);
        }
        if (info == null) {
            int size = 0;
            if (mGameData.size != null) {
                try {
                    size = Integer.parseInt(mGameData.size);
                } catch (NumberFormatException e) {
                }
            }
            info = new ApkInfo(mGameData.url, size, 0, null);
        }
//        isInstall = false;
        initViewState();
        int percent = BoyaaMath.percent(info.completeSize, info.apkFileSize);
        switch (mGameData.state) {
        case GameData.UNINIT_UPDATE:
            downloadText.setText(R.string.all_game_download);
            break;
        case GameData.IN_DOWNLOAD:
            if (fromDownloader) {
                downloadText.setText(R.string.all_game_downloading);
                mProgressBar.setVisibility(View.VISIBLE);
//                text3.setVisibility(View.VISIBLE);
                textAppSize.setText(BoyaaMath.reduceUnit(info.completeSize, 2) + "/"
                        + BoyaaMath.reduceUnit(info.apkFileSize, 2));
//                text3.setText(percent + "%");
                mProgressBar.setProgress(percent);
            } else {
                downloadText.setText(getString(R.string.all_game_continu));
            }

            break;
        case GameData.CONTINUE_DOWNLOAD:
        	downloadText.setText(getString(R.string.all_game_continu));
        	break;
        case GameData.GET_POINTS:
        	downloadBtn.setBackgroundResource(R.drawable.all_games_download_getpoints);
            downloadText.setText(R.string.all_game_getpoints);
            break;
        case GameData.NEED_INSTALL:
        	downloadText.setText(getString(R.string.all_game_install));
        	break;
        	
        case GameData.HAS_INSTALL:
        	downloadBtn.setBackgroundResource(R.drawable.all_games_hasdownload_img);
        	downloadText.setText(R.string.all_game_hasinstall);
            break;
        default:
        	break;
    }

        /* 初始化游戏详情信息 */
        briefDesc = (TextView)findViewById(R.id.game_detail_bottom_desc);
        if (!TextUtils.isEmpty(mGameData.desc)) {
            briefDesc.setText(mGameData.desc);
        }
    }


    private void updateHasInstallState(){
		if (PointWallActivity.getInstance().isInstalledGame(mGameData.packagename))
		{
        	downloadBtn.setBackgroundResource(R.drawable.all_games_hasdownload_img);
        	downloadText.setText(R.string.all_game_hasinstall);
			mGameData.state = GameData.HAS_INSTALL;
			MemoryCache.put(GameData.TAG + mGameData.type + mGameData.url, mGameData, true);
			updateGameDataState(mGameData.type, mGameData);
		} 
    }
    protected void onUpdate() {
 
    }

    private void initViewState() {
        downloadText.setText(getString(R.string.all_game_download));
        textShortDesc.setText(mGameData.shortdesc);
        String total = getString(R.string.package_size) + "：" + mGameData.size
                + getString(R.string.unit_mb);
        textAppSize.setText(total);
        mProgressBar.setProgress(0);
        mProgressBar.setVisibility(View.GONE);
    }

    /**
     * 图片适配多分辨率
     */
//    private void reviseView() {
//        reviseImageViewSize(appImage);
//        reviseViewHeight(titleBlock);
//        reviseViewHeight(topBlock);
//        // reviseViewHeight(bottomBlock);
//        reviseViewHeight(briefExtendBlock);
//       reviseViewHeight(galleryBlock);
//        reviseViewHeight(briefTitle);
//        reviseViewHeight(briefDesc);
//  }
//
//    private AlertDialog mAlertDialog;
//
//    private int briefExtendHeight = 0;
//    
    public void onBackClick(View v) {
    	PointWallActivity.getInstance().showPoints(totalPoints);
    	onBackPressed();
	}
//    
    public void onBackPressed() {
    	super.onBackPressed();
		overridePendingTransition(R.anim.push_right_in, R.anim.push_right_out);
    }
//
    private void setEvents() {
        OnClickListener listener = new OnClickListener() {
            

			public void onClick(View v) {
                if (ClickLimit.mutipleClick()) {
                    return;
                }
//                mDownloadFailImageView.setVisibility(View.GONE);
                textShortDesc.setVisibility(View.VISIBLE);
                textAppSize.setVisibility(View.VISIBLE);
                String [] ids = PointWallActivity.getInstance().getIds();//获取appid和uid
                switch (mGameData.state) {
	                case GameData.UNINIT_UPDATE:
	                	if (mApkDownloader.get_apkMap_size() < 1){
		    				if(NetworkUtil.isNetworkAvailable()){
		    					mPwManager.addDownLoadCount(THIS, ids[0], ids[1], String.valueOf(mGameData.id));
		    					downloadText.setText(getString(R.string.all_game_downloading));
		    					mProgressBar.setVisibility(View.VISIBLE);
		    					mApkDownloader.addApk(mGameData.url, mGameData.type);
		    					mGameData.state = GameData.IN_DOWNLOAD;//下载中
		    					MemoryCache.put(GameData.TAG + mGameData.type + mGameData.url, mGameData, true);
		    					updateGameDataState(mGameData.type, mGameData);
		    				}  else {
		    					PointWallActivity.getInstance().showToast(getString(R.string.network_unavailable));
		    				}
	                	}else{
	                		PointWallActivity.getInstance().showToast(getString(R.string.downloadTaskIsFull));
	                	}
	                    break;
	                case GameData.IN_DOWNLOAD:
						mApkDownloader.puase(mGameData.url);
						mGameData.state = GameData.CONTINUE_DOWNLOAD;
						MemoryCache.put(GameData.TAG + mGameData.type + mGameData.url, mGameData, true);
						updateGameDataState(mGameData.type, mGameData);
						mProgressBar.setBackgroundResource(R.drawable.all_games_download_img);
						downloadText.setText(R.string.all_game_continu);
	                	
	                    break;
	                case GameData.CONTINUE_DOWNLOAD:
	                	if (mApkDownloader.get_apkMap_size() < 1){
		    				if(NetworkUtil.isNetworkAvailable()){
		    					downloadText.setText(getString(R.string.all_game_downloading));
		    					mProgressBar.setVisibility(View.VISIBLE);
		    					mApkDownloader.addApk(mGameData.url, mGameData.type);
		    					mGameData.state = GameData.IN_DOWNLOAD;//下载中
		    					MemoryCache.put(GameData.TAG + mGameData.type + mGameData.url, mGameData, true);
		    					updateGameDataState(mGameData.type, mGameData);
		    				}  else {
		    					PointWallActivity.getInstance().showToast(getString(R.string.network_unavailable));
		    				}
	                	}else{
	                		PointWallActivity.getInstance().showToast(getString(R.string.downloadTaskIsFull));
	                	}
	                    break;
	                case GameData.GET_POINTS:
	                	
	        			
	        			if(NetworkUtil.isNetworkAvailable()){
	    	    			totalPoints = mPwManager.addUserPoints(ids[0], ids[1], ids[2], String.valueOf(mGameData.id), mGameData.points);
	    	    			if (null != totalPoints){
	    	    				showPoints(totalPoints);
	    	    			}
    	        			mGameData.state = GameData.NEED_INSTALL;
    	        			MemoryCache.put(GameData.TAG + mGameData.type + mGameData.url, mGameData, true);
    	        			updateGameDataState(mGameData.type, mGameData);
    	                	downloadBtn.setBackgroundResource(R.drawable.all_games_download_img);
    	                    downloadText.setText(R.string.all_game_install);
	    	    		}else{
	    	    			PointWallActivity.getInstance().showToast(getString(R.string.network_unavailable));
	    	    		}
	        			break;
				case GameData.NEED_INSTALL:
	                	int result = ((BaseActivity) THIS).installApplication(info.apkFilePath,mGameData.id);//安装
	        			switch (result) {
		        			case BaseActivity.FILE_ERROR:
		        				 //mAPKInfoDao.deleteApkInfo(info);
		        				 mApkDownloader.delete(info);
		        				 new AlertDialog.Builder(THIS)
		        				 .setMessage(getString(R.string.install_fail_file))
		        				 .setNegativeButton(getString(R.string.btn_no), null)
		        				 .setPositiveButton(getString(R.string.btn_yes), new DialogInterface.OnClickListener() {
									public void onClick(DialogInterface dialog, int which) {
										// TODO Auto-generated method stub
										if(NetworkUtil.isNetworkAvailable()){
											mGameData.state = GameData.IN_DOWNLOAD;
											MemoryCache.put(GameData.TAG + mGameData.type + mGameData.url, mGameData, true);
											updateGameDataState(mGameData.type, mGameData);
											//										mProgressBar.show();
											mApkDownloader.addApk(mGameData.url, mGameData.type);
										}  else {
											PointWallActivity.getInstance().showToast(getString(R.string.network_unavailable));
										}
									
									}
									
								}).show();
		        				 break;
		        			case BaseActivity.SD_ERROR:
		        				Toast.makeText(THIS, getString(R.string.install_fail_sdcard),Toast.LENGTH_SHORT).show();
		        				break;
		        			case BaseActivity.SUC:
		        				break;
		        			default:
		        				break;
		        			}
	        			break;
	                case GameData.HAS_INSTALL:
//	                	downloadBtn.setBackgroundResource(R.drawable.all_games_hasdownload_img);
//	                	downloadText.setText(R.string.all_game_hasinstall);
//	                	MemoryCache.put(GameData.TAG + mGameData.type + mGameData.url, mGameData, true);
//	                	updateGameDataState(mGameData.type, mGameData);
	                    break;
	                default:
	                	break;
                
                }
            }
                	
//        moveBlock.setAnimationListener(new TranslationLinearLayout.AnimationListener() {
//            public void onAnimationStart(boolean isBack) {
//            	if (isBack) {
//            		mScrollBlock.setLayoutParams(new LinearLayout.LayoutParams(LayoutParams.FILL_PARENT, mScrollBlock.getHeight() + extendBlock.getHeight()));
//            	}
//            }
//
//            public void onAnimationEnd(boolean isBack) {
//            	if (!isBack) {
//            		mScrollBlock.setLayoutParams(new LinearLayout.LayoutParams(LayoutParams.FILL_PARENT, mScrollBlock.getHeight() - extendBlock.getHeight()));
//            	}
//            }
//
//        });
        };
        downloadBtn.setOnClickListener(listener);

        mGallery.setOnItemSelectedListener(new OnItemSelectedListener() {

            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                Log.i("CDH", "onItemSelected height:" + view.getHeight());
                galleryDotsView.select(position);
            }

            public void onNothingSelected(AdapterView<?> parent) {
            }

        });


        mObserver = new ApkDownloadObserver() {

           

			@Override
            public void update(String apkUrl, int completeSize, int apkFileSize) {
//                 Toast.makeText(THIS, completeSize + "/" + apkFileSize+ "字节",
//                 Toast.LENGTH_SHORT).show();
                Log.d("CDH", "GameDetail " + completeSize + "/" + apkFileSize + "字节");
                Log.d("Thread111", "GameDetailUpdate "+completeSize+"/"+apkFileSize + "字节");
               
                if (mGameData.url.equals(apkUrl)) {

                    /* info just holds a copy. so update it here */
                	ApkInfo tempInfo = mApkDownloader.getApkInfo(mGameData.url);
                    if (tempInfo == null) {
                        return;
                    }
                    info = tempInfo;
                    Log.d(TAG, "info = " + info + ", info.state = " + info.state);
                    int percent = BoyaaMath.percent(completeSize, apkFileSize);
                    Log.d("Thread111", textAppName.getText() +"="+percent);
//                    PointWallActivity.getInstance().showToast(new Integer(percent).toString());
                    if (apkFileSize == 0) {
                    	Log.d(TAG, "不可能走到这里 GameDetailActivity update() apkFileSize == 0");
                    } else if (completeSize == apkFileSize) {
                    	if (info != null) {
                            /* 下载完成，上报下载，安装数 */
                    		downloadBtn.setBackgroundResource(R.drawable.all_games_download_getpoints);
                    		downloadText.setText(R.string.all_game_getpoints);
                        	textAppSize.setText(BoyaaMath.reduceUnit(completeSize, 2) + "/"
                                    + BoyaaMath.reduceUnit(apkFileSize, 2));
                            mProgressBar.setProgress(percent);
                            info.state = ApkInfo.COMPLETED;
                            mGameData.state = GameData.GET_POINTS;
							MemoryCache.put(GameData.TAG + mGameData.type + mGameData.url, mGameData, true);
							updateGameDataState(mGameData.type, mGameData);
							mApkDownloader.delete_apkMap_item(apkUrl);
//                            noticfyServer(mGameData.id, optype);
                        }
                    } else {
                    	textAppSize.setText(BoyaaMath.reduceUnit(completeSize, 2) + "/"
                                + BoyaaMath.reduceUnit(apkFileSize, 2));
                        mProgressBar.setProgress(percent);
                    }
                }else{//处理进入详情页面时，只有一个应用在UI更新进度，其他下载线程完成后没有更新的bug
                	if (completeSize == apkFileSize){
                		ApkInfo tempInfo2 = mApkDownloader.getApkInfo(apkUrl);
                		if (tempInfo2 == null){
                			return;
                		}
                		GameData data = null;
                		Cacheable cacheable = MemoryCache.get(GameData.TAG + tempInfo2.type + apkUrl);
                		if (cacheable != null) {
                			data = (GameData)cacheable;
                		}
                		data.state = GameData.GET_POINTS;
                		MemoryCache.put(GameData.TAG + tempInfo2.type + apkUrl, data, true);
						updateGameDataState(tempInfo2.type, data);
						mApkDownloader.delete_apkMap_item(apkUrl);
                	}
                }
            }

            @Override
            public void notice(String apkUrl, int type, int arg2) {
                Log.d("CDH", "GameDetail " + type);
                if (mGameData.url.equals(apkUrl)) {
                    switch (type) {
                        case ApkInfo.WAITING:
                            break;
                        case ApkDownloadObserver.NETWORK_RESUME:
                            /* 网络终端后又恢复，恢复下载状态 */
                        	PointWallActivity.getInstance().showToast(getString(R.string.network_available));
                            mProgressBar.setVisibility(View.VISIBLE);
                            textShortDesc.setVisibility(View.VISIBLE);
						break;
                        case ApkInfo.DOWNLOADING:
//                            mDownloadFailImageView.setVisibility(View.GONE);
                            textShortDesc.setVisibility(View.VISIBLE);
                            break;
                        case ApkDownloadObserver.EXIST_FULL_APK:
                            Log.d("CDH", "GameDetail EXIST_FULL_APK 不可能执行");
                            break;
                        case ApkDownloadObserver.GET_APK_SIZE_FAIL:
                            Log.d("CDH", "GameDetail GET_APK_SIZE_FAIL");
                            break;
                        case ApkDownloadObserver.NETWORK_UNAVAILABLE_ERROR:
                            Log.d("CDH", "GameDetail NETWORK_UNAVAILABLE_ERROR");
                            PointWallActivity.getInstance().showToast(getString(R.string.network_unavailable));
                            break;
                        case ApkDownloadObserver.CREATE_APK_FILE_FAIL:
                            break;
                        case ApkDownloadObserver.UNKNOW_ERROR:
                        	ApkDownloader.getInstance().delete(mAPKInfoDao.getApkInfo(apkUrl));
                            break;
                        case ApkInfo.DELETE:
                        	ApkDownloader.getInstance().delete(mAPKInfoDao.getApkInfo(apkUrl));
                            initViewState();
                            break;
                        default:
                        	Log.e("CDH", "GameDetailActivity notice not handle for type " + type);
                            break;
                    }
                }
           }
        };
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
//
//    /**
//     * 上报用户下载的游戏
//     */
//    private void noticfyServer(long id, final String optype) {
//        HashMap<String, Object> param = new HashMap<String, Object>();
//        param.put("platform", "ANDROID");
//        param.put("devid", Secret.md5(EnviromentUtil.getDeviceId(this)));
//        param.put("optype", optype);
//        param.put("appid", id);
//        param.put("lang", this.getString(R.string.language));
//        String api = PHPRequest.createApi(PHPRequest.LOGIN_METHOD, PHPRequest.defaultUid, param);
//        TaskManager.getInstance().addTask(
//        new RequestPhpServerTask(PHPRequest.SERVER_RUL, api, null));
//
//    }

}
