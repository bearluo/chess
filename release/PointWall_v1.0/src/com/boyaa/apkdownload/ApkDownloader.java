package com.boyaa.apkdownload;

import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Random;
import java.util.Set;

import android.os.Message;
import android.text.TextUtils;
import android.util.Log;

import com.boyaa.apkdownload.ApkInfo.ApkItem;
import com.boyaa.cache.MemoryCache;
import com.boyaa.common.ApkFileManager;
import com.boyaa.common.Config;
import com.boyaa.common.FileUtil;
import com.boyaa.common.NetworkUtil;
import com.boyaa.db.APKInfoDao;

public class ApkDownloader {
    
    public static final String TAG = ApkDownloader.class.getSimpleName();
    
	private static ApkDownloader apkDownloader;
	private ApkDownloader() {
		init();
		
	}
	public static ApkDownloader getInstance() {
		if (apkDownloader == null) {
			apkDownloader = new ApkDownloader();
		}
		return apkDownloader;
	}
    
	private final int THREAD_COUNT = 1;//线程数
	private ArrayList<ApkDownloadThread> threadList;
	private CheckThread mCheckThread;
	private NerworkListenerThread mNerworkListenerThread;

	public APKInfoDao apkInfoDao;
	public APKInfoDao getApkInfoDao(){
		return apkInfoDao;
	}
	public boolean isHasDownLoadThread(){
		if (!threadList.isEmpty()){
			return true;
		}
		return false;
	}
	private void init() {
		//初始化下载线程
		threadList = new ArrayList<ApkDownloadThread>();
		for (int i=0; i<THREAD_COUNT; i++) {
			ApkDownloadThread thread = new ApkDownloadThread(this);
			thread.start();
			threadList.add(thread);
			
		}
		
		//启动检查线程
		mCheckThread = new CheckThread();
		mCheckThread.start();
		
		mNerworkListenerThread = new NerworkListenerThread();
		mNerworkListenerThread.start();
		
		//创建数据库访问对象
		apkInfoDao = new APKInfoDao();
		
		//初始化存放APK包目录
		File file = new File(Config.APK_PATH);
		if (!file.exists()) {
			file.mkdirs();
		}
		
	}
	
//	private final int MAX_SIZE = 1024*200;//200KB
	
	
	private ApkDownloadObserver mObserver;
	/** 设置观察者以观察下载进度 */
	public synchronized void setApkDownloadObserver(ApkDownloadObserver observer) {
		this.mObserver = observer;
	}
	
	
	synchronized void update(String apkUrl, int arg1) {
	    Log.d(TAG, "in update");
		ApkInfo info = apkMap.get(apkUrl);
		Log.d(TAG, "info = " + info);
		if (info != null) {
			info.completeSize += arg1;
			Log.d(TAG, "mObserver = " + mObserver);
			if (mObserver != null) {
				Log.d("Thread111", "mObserver is" + mObserver.toString());
				Message msg = Message.obtain();
				msg.what = ApkDownloadObserver.UPDATE;
				msg.arg1 = info.completeSize;
				msg.arg2 = info.apkFileSize;
				msg.obj = info.apkUrl;
				mObserver.sendMessage(msg);
			}else{
				Log.d("Thread111", "mObserver is null");
//				GameData data = null;
//				Cacheable cacheable = MemoryCache.get(GameData.TAG + info.type + apkUrl);
//				if (cacheable != null) {
//					data = (GameData)cacheable;
//				}
//				if (data != null && data.updateState == GameData.IN_DOWNLOAD) {
//					data.state = GameData.GET_POINTS;
//            		MemoryCache.put(GameData.TAG + info.type + data.url, data, true);
//            		
//            		updateGameDataState(0, data);
//				}
			}
			//Log.d("Thread111", ""+info.completeSize+"/"+info.apkFileSize);
			if (info.completeSize == info.apkFileSize)  {
				info.state = ApkInfo.COMPLETED;
				apkInfoDao.updataApkInfoState(info);
				apkInfoDao.deleteApkItems(info);
//				MemoryCache.put(GameData.TAG, info.cacheable);
//				apkMap.remove(apkUrl);
//				MemoryCache.put(ApkInfo.TAG + info.apkUrl, info, true);
				


			}  /*else if (info.completeSize > info.apkFileSize) {
				notice(apkUrl, ApkDownloadObserver.UNKNOW_ERROR);
				delete(apkMap.get(apkUrl));
			}*/

		}
	} 

	synchronized void notice(String apkUrl, int state) {
//		ApkInfo info = apkMap.get(apkUrl);
//		if(info!=null){
//			info.state = state;
//			apkMap.put(apkUrl,info);
//		}
		if (mObserver != null) {
			Message msg = Message.obtain();
			msg.what = ApkDownloadObserver.NOTICE;
			msg.arg1 = state;
			msg.obj = apkUrl;
			mObserver.sendMessage(msg);
		}
		if (state == ApkDownloadObserver.NETWORK_UNAVAILABLE_ERROR) {
			if (mNerworkListenerThread.canWait) {
				mNerworkListenerThread.wakeup();
			}
		}
	}

	private ArrayList<ApkInfo> apkList = new ArrayList<ApkInfo>();//需要下载的APK信息
	private HashMap<String, ApkInfo> apkMap = new HashMap<String, ApkInfo>();//需要下载、本次已经下载的APK信息
    public boolean isHandingApk(String apkUrl){
    	return apkMap.containsKey(apkUrl);
    }
    
	/** 添加一个下载包 */
	public void addApk(String apkUrl, int type) {
		if (TextUtils.isEmpty(apkUrl)) return;
		
		if (!NetworkUtil.isNetworkAvailable()) {
			notice(apkUrl, ApkDownloadObserver.NETWORK_UNAVAILABLE_ERROR);
			return;
		}
		
		if (apkMap.containsKey(apkUrl)) {
			return;
		} else {
			ApkInfo mApkInfo = new ApkInfo(apkUrl, 0, 0, null);
			mApkInfo.state = ApkInfo.WAITING;
			mApkInfo.type = type;
			apkMap.put(apkUrl, mApkInfo);
			
		}

		mCheckThread.addTask(apkUrl);
	}
	public int get_apkMap_size(){
		return apkMap.size();
	}
	public void delete_apkMap_item(String mUrl){
		if (apkMap.containsKey(mUrl)){
			apkMap.remove(mUrl);
		}
		
		if (taskList.contains(mUrl)) {
			taskList.clear();
		}
	}
	private synchronized void downloadAPK() {
		this.notifyAll();
	}
	private ArrayList<String> taskList = new ArrayList<String>();
	//初始化线程
	private class CheckThread extends Thread {
		

		public synchronized void addTask(String apkUrl) {
			if (!taskList.contains(apkUrl)) {
				taskList.add(apkUrl);
				this.notify();
			}
		}

		public void run() {
			while(true) {
				if (taskList.size() == 0) {
					synchronized(this) {
						try {
							this.wait();
						} catch (InterruptedException e) {
							e.printStackTrace();
						}
					}
				} else {
					/*线程唤醒，从任务列表里取出并计算拆分*/
					String apkUrl = taskList.remove(0);
					Log.d("Thread", "CheckThread handle:" + apkUrl);
					ApkInfo mApkInfo = apkInfoDao.getApkInfo(apkUrl);
					if (mApkInfo != null) {//之前有下载，并已经持久化到数据库中
						if (!FileUtil.existFile(mApkInfo.apkFilePath)) {
							//下载了，但是下载文件被删掉了
							apkInfoDao.deleteApkInfo(mApkInfo);
							mApkInfo.completeSize = 0;
							if (!arrageTask(apkUrl, mApkInfo)) {
								continue;
							}
						}
						if (mApkInfo.state == ApkInfo.COMPLETED) {
							Log.e("CDL", "走到这里了。。。1");
							apkInfoDao.deleteApkInfo(mApkInfo);
							FileUtil.deleteFile(mApkInfo.apkFilePath);
							mApkInfo.apkItemList.clear();
							mApkInfo.completeSize = 0;
//							if (!arrageTask(apkUrl, mApkInfo)) {
//								Log.e("CDL", "走到这里了。。。2");
//								continue;
//							}
							Log.e("CDL", "走到这里了。。。3");
						}
						if (mApkInfo.apkItemList.isEmpty()) {
							Log.e("CDL", "走到这里了。。。4");
							Log.e("CDH", "数据库中存在一个未完成的ApkInfo，但它却没有ApkItems");
							apkInfoDao.deleteApkInfo(mApkInfo);
							mApkInfo.completeSize = 0;
							if (!arrageTask(apkUrl, mApkInfo)) {
								Log.e("CDL", "走到这里了。。。5");
								continue;
							}
						} else {
							Log.e("CDL", "走到这里了。。。6");
							Log.d("Thread113", "CheckThread handle 进入断点下载1:" + apkUrl);
							/*取出计算已经完成了多少下载，并继续添加到列表中断点下载*/
							int completeSize = deleteCompleteApkItem(mApkInfo);
//							mApkInfo.completeSize = completeSize;
							mApkInfo.state = ApkInfo.WAITING;
							notice(apkUrl, ApkInfo.WAITING);
//							addApkList(mApkInfo);
							//apkSet.add(mApkInfo);
							//apkMap.put(apkUrl, mApkInfo);
							addApk(apkUrl,mApkInfo);
							if (completeSize > 0) {
								Log.e("CDL", "走到这里了。。。10");
							    update(apkUrl, completeSize);//没有正式下载时候最好不要调用哪个这个方法
							}
						}
					} else {
						Log.e("CDL", "走到这里了。。。7");
						if (!arrageTask(apkUrl, mApkInfo)) {
							Log.e("CDL", "走到这里了。。。8");
							continue;
						}
					}
//					update(ApkDownloadObserver.UPDATE, apkUrl, mApkInfo.completeSize);
					Log.d("Thread113", "CheckThread handle 进入断点下载2:" + apkUrl);
					Log.e("CDL", "走到这里了。。。9");
					downloadAPK();
				}
			}
		}

		private void addApk(String apkUrl, ApkInfo mApkInfo) {
			// TODO Auto-generated method stub
//			if (!apkMap.containsKey(apkUrl)) {
				apkMap.put(apkUrl, mApkInfo);
				apkList.add(mApkInfo);
//			}
		}
//		private void addApkList(ApkInfo mApkInfo){
//			if (!apkList.contains(mApkInfo)) {				
//			}
//		}
		private boolean arrageTask(String apkUrl,ApkInfo mApkInfo){
			Log.e("CDL", "走到这里了。。。11");
			//之前没有下载
			String apkFilePath = ApkFileManager.createApkFilePath(apkUrl);
			mApkInfo = new ApkInfo(apkUrl, 0, 0, apkFilePath);
			int size = getApkFileSize(mApkInfo);
			if(size>0){
				Log.e("CDL", "走到这里了。。。12");
				mApkInfo.apkFileSize = size;
			}
			//检查目录中是否存在包
//			if (existFullFile(mApkInfo.apkFilePath, mApkInfo.apkFileSize)) {
//				notice(ApkDownloadObserver.NOTICE, apkFilePath, ApkDownloadObserver.EXIST_FULL_APK);
//				continue;
//			}
			if (size <= 1000) {
				Log.e("CDL", "走到这里了。。。13");
				delete(mApkInfo);
				Log.w("CHECK", "size = " + size);
				notice(apkUrl, ApkDownloadObserver.GET_APK_SIZE_FAIL);//通知重新下载
				return false;
			}
			boolean isSuccess = createApkFile(mApkInfo);
			if (!isSuccess) {
				Log.e("CDL", "走到这里了。。。14");
				delete(mApkInfo);
				notice(apkUrl, ApkDownloadObserver.CREATE_APK_FILE_FAIL); //通知重新下载
				return false;
			}
		    /*保存下载的apk信息到数据库中*/
			apkInfoDao.saveApkInfo(mApkInfo);
			MemoryCache.put(ApkInfo.TAG + mApkInfo.apkUrl, mApkInfo, true);
			
//			if(BoyaaApplication.isDebug)Log.d("Thread", "CheckThread FileSize:"+mApkInfo.apkFileSize);
			
			if (mApkInfo._id > 0 && size > 0) {
				Log.e("CDL", "走到这里了。。。15");
				mApkInfo.apkItemList = new ArrayList<ApkItem>();
				final int COUNT = 100;
				int itemtLen = mApkInfo.apkFileSize/COUNT;
				for (int i=0; i<COUNT; i++) {
					ApkItem apkItem = new ApkItem();
					apkItem.info = mApkInfo;
					apkItem.infoId = mApkInfo._id;
					apkItem.startPos =  i * itemtLen;
					apkItem.endPos = apkItem.startPos + itemtLen - 1;
					mApkInfo.apkItemList.add(apkItem);
				}
				int length = mApkInfo.apkFileSize % itemtLen;
				if (length > 0) {
					ApkItem apkItem = new ApkItem();
					apkItem.info = mApkInfo;
					apkItem.infoId = mApkInfo._id;
					apkItem.startPos = COUNT * itemtLen;
					apkItem.endPos = apkItem.startPos + length - 1;
					mApkInfo.apkItemList.add(apkItem);
				}
				/*保存拆分的数据项到数据库中*/
				apkInfoDao.saveApkItemRetunId(mApkInfo.apkItemList);
				Log.e("CDL", "走到这里了。。。16");
			}
			mApkInfo.state = ApkInfo.WAITING;
			notice(apkUrl, ApkInfo.WAITING);
			
//			addApkList(mApkInfo);
		    //apkSet.add(mApkInfo);
			//apkMap.put(apkUrl, mApkInfo);
			addApk(apkUrl, mApkInfo);
			Log.e("CDL", "走到这里了。。。17");
			return true;
		}
	}
	
	
	private int deleteCompleteApkItem(ApkInfo mApkInfo) {
		int size = mApkInfo.apkItemList.size();
		int completeSize = 0;
		for (int i=0; i<size; i++) {
			ApkItem apkItem = mApkInfo.apkItemList.get(i);
			completeSize += apkItem.completeSize;
			if (apkItem.state == ApkItem.COMPLETED) {
				//去除已完成项
				mApkInfo.apkItemList.remove(apkItem);
				i--;
				size--;
			}
		}
		return completeSize;
	}

	/** 修改下载包状态 *//*
	public synchronized void operation(String apkUrl, int state) {
		ApkInfo info = apkMap.get(apkUrl);
		if (info != null && info.state != ApkInfo.COMPLETED) {
			info.state = state;
			apkMap.put(apkUrl, info);
			if (info.state == ApkInfo.DELETE) {
				
				//apkSet.remove(info);
				apkInfoDao.deleteApkInfo(info);
				FileUtil.deleteFile(info.apkFilePath);
				apkMap.remove(info.apkUrl);
				apkList.remove(info);
//				mObserver.update(apkUrl, 0, info.apkFileSize);
			} else {
				if (state==ApkInfo.PAUSE) {
					apkMap.remove(info.apkUrl);
					apkList.remove(info);
				} else {
					this.notifyAll();
				}
				
			}
		}
	}*/
	
	public synchronized void delete(ApkInfo info){
		if (info == null) return;

		ApkInfo info2 = apkMap.remove(info.apkUrl);
		if (info2 != null) apkList.remove(info2);
		if (info._id > 0) apkInfoDao.deleteApkInfo(info);
		FileUtil.deleteFile(info.apkFilePath);
	}
	
	public synchronized void puase(String apkUrl){
		ApkInfo info = apkMap.get(apkUrl);
		if (info!=null) {
			apkMap.remove(info.apkUrl);
			apkList.remove(info);
			notice(apkUrl, ApkInfo.PAUSE);
		}
	}
	
	
	
	public synchronized void puaseAll(){
		for (ApkInfo info:/*apkSet*/apkList) {
			info.state = ApkInfo.PAUSE;
			this.notifyAll();
		}
	}
	public synchronized void setApkInfoState(String apkUrl, int state) {
		ApkInfo info = apkMap.get(apkUrl);
		if (info != null && info.state != ApkInfo.COMPLETED) {
			info.state = state;
			apkInfoDao.updataApkInfoState(info);
			MemoryCache.put(ApkInfo.TAG + info.apkUrl, info, true);
		}
	}
	public void setApkInfoState(ApkInfo info){
		apkMap.put(info.apkUrl, info);
	}
	
	/** 断网恢复后调用 */
	private synchronized void networkResume() {
		//重新取出
		if (apkList != null) {
			for (ApkInfo info : apkList) {
				info.apkItemList = apkInfoDao.getApkItems(info);
				Log.d("CDH", "before complete size:" + info.completeSize);
				info.completeSize = deleteCompleteApkItem(info);
				Log.d("CDH", "after complete size:" + info.completeSize);
			}
		}
		notifyAll();
	}
	
	public synchronized int getApkInfoState(String apkUrl) {
		int result = 0;
		if (apkMap.containsKey(apkUrl)) {
			ApkInfo info = apkMap.get(apkUrl);
			result = info.state;
		}
		return result;
	}

	public synchronized int getApkInfoCompleteSize(String apkUrl) {
		int result = 0;
		if (apkMap.containsKey(apkUrl)) {
			ApkInfo info = apkMap.get(apkUrl);
			result = info.completeSize;
		}
		return result;
	}

	public ApkInfo getApkInfo(String apkUrl) {
		ApkInfo info = null;
		if (apkMap.containsKey(apkUrl)) {
			info = apkMap.get(apkUrl);
		}
		return info;
	}
	
	private Random mRandom = new Random();
	synchronized ApkItem getTask() {
		ApkItem apkItem = null;
		int size = apkList.size();
		if (size > 0) {
			int index = mRandom.nextInt(size);
			ApkInfo info = apkList.get(index);
			if (info != null) {
				if (info.apkItemList != null && info.apkItemList.size() > 0) {
					apkItem = info.apkItemList.remove(0);//
					if (info.apkItemList.size() == 0) {
						apkList.remove(index);
					}
				} else {
					apkList.remove(index);
					//错误
					Log.e("CDH", "错误 Items为空，却没有完成 " +info.completeSize+"/"+info.apkFileSize + " " +info.apkUrl);
				}
			}
		}
		return apkItem;
	}

//	private synchronized ApkItem getTaskOld() {
//		ApkItem apkItem = null;
//		int size = apkList.size();
//		int index = 0;
//		while (size > 0) {
//			ApkInfo info = apkList.get(index++);
//            
//			if (info.state == ApkInfo.PAUSE) {
////				if(BoyaaApplication.isDebug)Log.d("CDH", "PAUSE " +info.completeSize+"/"+info.apkFileSize + " " +info.apkUrl);
//				info = null;
//			} else if (info.state == ApkInfo.RESUME) {
//				//重新取ApkItems数据
//				info.apkItemList = apkInfoDao.getApkItems(info);
//				info.completeSize = deleteCompleteApkItem(info);
//				update(info.apkUrl, 0);
//			} else if (info.state == ApkInfo.ERROR) {
////				if(BoyaaApplication.isDebug)Log.d("CDH", "ERROR " +info.completeSize+"/"+info.apkFileSize + " " +info.apkUrl);
//				info = null;
//			} else if (info.state == ApkInfo.DELETE) {
//				apkMap.remove(info.apkUrl);
//				apkList.remove(info);
//				apkInfoDao.deleteApkInfo(info);
//				FileUtil.deleteFile(info.apkFilePath);
////				if(BoyaaApplication.isDebug)Log.d("CDH", "DELETE " +info.completeSize+"/"+info.apkFileSize + " " +info.apkUrl);
//				info = null;
//				index--;
//			} else if (info.completeSize == info.apkFileSize && info.completeSize>1000) {
//				info.state = ApkInfo.COMPLETED;
//				apkInfoDao.updataApkInfoState(info);
//				apkInfoDao.deleteApkItems(info);
////				apkMap.remove(info.apkUrl);
//				apkList.remove(info);
//				info = null;
//				index--;
//			}
//			if (info != null) {
//				if (info.apkItemList != null && info.apkItemList.size() > 0) {
//					apkItem = info.apkItemList.remove(0);
//					break;
//				} else {
//					//错误
////					if(BoyaaApplication.isDebug)Log.e("CDH", "错误 Items为空，却没有完成 " +info.completeSize+"/"+info.apkFileSize + " " +info.apkUrl);
//				}
//			}
//			size--;
//		}
//		return apkItem;
//	}
	
	/*synchronized ApkItem getTask1() {
		for (ApkInfo info:apkSet) {
			switch (info.state) {
			case ApkInfo.PAUSE:
			case ApkInfo.ERROR:	
				return null;
			case ApkInfo.DELETE:
				apkMap.remove(info.apkUrl);
				apkSet.remove(info);
				apkInfoDao.deleteApkInfo(info);
				FileUtil.deleteFile(info.apkFilePath);
				if(BoyaaApplication.isDebug)Log.d("CDH", "DELETE " +info.completeSize+"/"+info.apkFileSize + " " +info.apkUrl);
				return null;
			default:
				break;
			}
			if (info.completeSize == info.apkFileSize && info.completeSize>1000) {
				info.state = ApkInfo.COMPLETED;
				apkInfoDao.updataApkInfoState(info);
				apkInfoDao.deleteApkItems(info);
				apkSet.remove(info);
				return null;
			}
			 if(info.apkItemList != null && info.apkItemList.size() > 0){
				return  info.apkItemList.remove(0);
			 }
		}
		return null;
		
	}*/
	/** 获取要下载的包大小 */
	private int getApkFileSize(ApkInfo apkInfo) {
		HttpURLConnection connection = null;
		int size = -1;
		try {
			URL url = new URL(apkInfo.apkUrl);
			
			Log.w("CHECK","getApkFileSize url = " + apkInfo.apkUrl);
			Log.w("CHECK","getApkFileSize decode url = " + URLDecoder.decode(apkInfo.apkUrl));
			connection = (HttpURLConnection)url.openConnection();
			connection.setConnectTimeout(Config.HTTP_CONNECT_TIME_OUT);
			connection.setRequestMethod("GET");
			size =  connection.getContentLength();
			
			Log.w("CHECK","getApkFileSize size = " +size);
			
			//WIFI网络不无连接时connection.getContentLength()返回216
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (connection != null) connection.disconnect();
		}
		return size;
	}
	
	private boolean createApkFile(ApkInfo apkInfo) {
		boolean result = true;
		RandomAccessFile accessFile = null;
		try {
			if (apkInfo.apkFileSize > 0) {
				File file = new File(apkInfo.apkFilePath);
				if (!file.exists()) {
					file.createNewFile();
				}
				accessFile = new RandomAccessFile(file, "rwd");
				accessFile.setLength(apkInfo.apkFileSize);
			}
		} catch (Exception e) {
			e.printStackTrace();
			result = false;
		} finally {
			if (accessFile != null) {
				try {
					accessFile.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
		return result;
	}
	
	/** 网络监听线程 */
	private class NerworkListenerThread extends Thread {
		boolean canWait = true;

		public synchronized void wakeup() {
			Log.i("Thread", "NerworkListenerThread 说：汗！又断网了，我又得干活了。");
			canWait = false;
			this.notify();
		}

		public void run() {
			while (true) {
				try {
					if (canWait) {
						synchronized(this) {
							this.wait();
						}
					}

					sleep(1000);

					if (NetworkUtil.isNetworkAvailable()) {
						Log.i("Thread", "NerworkListenerThread 说：终于有网络了，我可以休息了。");
						apkDownloader.networkResume();
						if(apkMap!=null){
							Set<String> set = apkMap.keySet();
							for (String url:set) {
								ApkInfo info = apkMap.get(url);
								info.state = ApkInfo.DOWNLOADING;
								apkDownloader.notice(info.apkUrl, ApkDownloadObserver.NETWORK_RESUME);
							}
						}
						
						canWait = true;
					}
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
			}
		}
	}
}
