package com.boyaa.entity.update;

import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.net.HttpURLConnection;
import java.net.InetSocketAddress;
import java.net.MalformedURLException;
import java.net.ProtocolException;
import java.net.SocketAddress;
import java.net.URL;
//import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import android.content.Context;
import android.text.TextUtils;

import com.boyaa.entity.update.RefactorDownloadLogDao;
import com.boyaa.entity.update.RefactorDownloadedTaskEntity;
import com.boyaa.made.APNUtil;

public class RefactorDownloader {
	private static final String TAG = RefactorDownloader.class.getSimpleName();
	
	private Context mContext;
	private RefactorDownloadLogDao mLogDao;	
	private int mDownloadedFileSize = 0;
	private int mSourceFileSize = 0;
	private RefactorDownloadThread[] mThreads;
	private File mSaveFile;
	private Map<Integer, RefactorDownloadedTaskEntity> mCacheDownloadRecords = new ConcurrentHashMap<Integer, RefactorDownloadedTaskEntity>();
	private int taskBlockSizePerThread;
	private String mDownloadUrlStr;
	private int mTimeoutMillis;
	private int mCallbackPeriodMillis;
	private Object mTag;
	
	private java.net.Proxy mProxy = null;
	
	private RefactorDownloadListener mDownloadListener;
	
	private boolean isDownloading = false;
	private boolean stopped = false;
	
	public RefactorDownloader(Context context, String downloadUrl,
			File saveFile, int threadNum,
			RefactorDownloadListener downloadListener) {
		this(context, downloadUrl, RefactorDownloaderConstants.DEFAULT_TIMEOUT,
				RefactorDownloaderConstants.DEFAULT_CALLBACK_PERIOD, saveFile,
				threadNum, downloadListener);
	}
	
	public RefactorDownloader(Context context, String downloadUrl,
			int timeoutMillis, int callbackPeriodMillis, File saveFile,
			int threadNum, RefactorDownloadListener downloadListener) {
		this.mContext = context;
		this.mDownloadUrlStr = downloadUrl;
		this.mLogDao = new RefactorDownloadLogDao(this.mContext);
		this.mSaveFile = saveFile;
		this.mThreads = new RefactorDownloadThread[threadNum];
		this.mCallbackPeriodMillis = callbackPeriodMillis;
		this.mDownloadListener = downloadListener;
		this.mTimeoutMillis = timeoutMillis;
	}
	
	public void startDownload() {
		isDownloading = true;
		HttpURLConnection conn = null;
		try {
			
			clearDownloadedRecordBeforeOneWeek();
			
			URL url = new URL(this.mDownloadUrlStr);
			boolean useProxy = APNUtil.hasProxy(mContext);
			if (useProxy) {
				this.mProxy = getProxy(mContext);
				conn = (HttpURLConnection) url.openConnection(mProxy);
			} else {
				conn = (HttpURLConnection) url.openConnection();
			}

			// timeout
			conn.setConnectTimeout(mTimeoutMillis);
			conn.setReadTimeout(mTimeoutMillis);
			conn.setRequestMethod("GET");
			conn.setRequestProperty(
					"Accept",
					"image/gif, image/jpeg, image/pjpeg, image/pjpeg, application/x-shockwave-flash, application/xaml+xml, application/vnd.ms-xpsdocument, application/x-ms-xbap, application/x-ms-application, application/vnd.ms-excel, application/vnd.ms-powerpoint, application/msword, */*");
			conn.setRequestProperty("Accept-Language", "zh-CN");
			conn.setRequestProperty("Referer", mDownloadUrlStr);
			conn.setRequestProperty("Charset", "UTF-8");
			conn.setRequestProperty(
					"User-Agent",
					"Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.2; Trident/4.0; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.30; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)");
			conn.setRequestProperty("Connection", "Keep-Alive");
			conn.setRequestProperty("Accept-Encoding", "identity"); 
			conn.connect();
			//printResponseHeader(conn);
			//System.err.println("code="+conn.getResponseCode());

			if (conn.getResponseCode() == HttpURLConnection.HTTP_OK) {
				int fileSize = conn.getContentLength();// 根据响应获取文件大小
				if (fileSize <= 0) {
					onDownloadFailed(RefactorDownloadListener.ERROR_UNKNOWN_FILE_SIZE);
					return;
				}
				
				this.setSourceFileSizeAndCallback(fileSize);
				List<RefactorDownloadedTaskEntity> recordList = mLogDao.getDownloadedRecord(mDownloadUrlStr);
				
				if (recordList.size() > 0) {
					for(RefactorDownloadedTaskEntity entity: recordList) {
						mCacheDownloadRecords.put(entity.getThreadId(), entity);
					}
				}

				checkDownloadedRecords();

				// 计算每条线程下载的数据长度
				this.taskBlockSizePerThread = (this.mSourceFileSize % this.mThreads.length) == 0 ? 
						this.mSourceFileSize / this.mThreads.length
						: this.mSourceFileSize / this.mThreads.length + 1;
				
				startThreadsDownload();
				
			} else {
				onDownloadFailed(RefactorDownloadListener.ERROR_SERVER_NO_RESPONSE);
			}
		} catch (MalformedURLException e) {
			onDownloadFailed(RefactorDownloadListener.ERROR_INCORRECT_URL);
		} catch (ProtocolException e) {
			onDownloadFailed(RefactorDownloadListener.ERROR_PROTOCOL_EXCEPTION);
		} catch (IOException e) {
			onDownloadFailed();
		} catch (Exception e) {
			onDownloadFailed();
		} finally {
			if (conn != null) {
				conn.disconnect();
				conn = null;
			}
			isDownloading = false;
		}
	}
	
	private static final long ONE_WEEK_MILLIS = 7 * 24 * 3600 * 1000;
	private void clearDownloadedRecordBeforeOneWeek() {
		this.mLogDao.clearDownloadedRecordBefore((System.currentTimeMillis() - ONE_WEEK_MILLIS)+"");
	}

	private void checkDownloadedRecords() {
		boolean isNeedClearRecordsAndReInitialize = false;
		do {
			if (this.mCacheDownloadRecords.size() != this.mThreads.length) {
				isNeedClearRecordsAndReInitialize = true;
				break;
			}
			String recordedSavePath = this.mCacheDownloadRecords.get(1).getSaveFilePath();
			if (TextUtils.isEmpty(recordedSavePath)) {
				isNeedClearRecordsAndReInitialize = true;
				break;
			}
			if (!recordedSavePath.equals(this.mSaveFile.getAbsolutePath())) {
				isNeedClearRecordsAndReInitialize = true;
				break;
			}
			File recordedFile = new File(recordedSavePath);
			if (!recordedFile.exists()){
				isNeedClearRecordsAndReInitialize = true;
				break;
			}
			if (!recordedFile.isFile()) {
				isNeedClearRecordsAndReInitialize = true;
				break;
			}
			if (recordedFile.length() != mSourceFileSize) {
				isNeedClearRecordsAndReInitialize = true;
				break;
			}
		}while(false);
		if (isNeedClearRecordsAndReInitialize) {
			mLogDao.clearDownloadedRecord(mDownloadUrlStr);
			reInitializeDownloadCacheRecords();
			this.mLogDao.createDownloadRecord(this.mCacheDownloadRecords, System.currentTimeMillis()+"");
		} else {
			countDownloadedSize(this.mCacheDownloadRecords);
		}
	}

	private void countDownloadedSize(Map<Integer, RefactorDownloadedTaskEntity> map) {
		for (Map.Entry<Integer, RefactorDownloadedTaskEntity> entry : map.entrySet()) {
			this.mDownloadedFileSize += entry.getValue().getDownloadedBlockSize();
		}
	}
	
	private void startThreadsDownload() throws Exception {
		RandomAccessFile randFile = null;
		try {
			randFile = new RandomAccessFile(this.mSaveFile, "rw");
			randFile.setLength(this.mSourceFileSize);
			randFile.close();
			URL url = new URL(this.mDownloadUrlStr);
			distributeTasksAndThread(url);
			
			boolean notFinish = true;// 下载未完成
			while (notFinish && (!stopped)) {// 循环判断所有线程是否完成下载
				notFinish = false;// 假定全部线程下载完成
				for (int i = 0; i < this.mThreads.length; i++) {
					if (this.mThreads[i] != null && !this.mThreads[i].isDownloadTaskFinish()) {// 如果发现线程未完成下载
						notFinish = true;// 设置标志为下载没有完成
						if (this.mThreads[i].getDownloadedBlockSize() == -1) {// 如果下载失败，抛出下载失败异常
							for (int j = 0; j < this.mThreads.length; j++) {
								if(mThreads[j] != null) {
									mThreads[j].stopDownload();
								}
							}
							throw new Exception("download exception");
						}
					}
				}
				
				// 更新一下数据库
				updateRecords();
				onDownloadingSize();
				
				if (notFinish) {
					Thread.sleep(mCallbackPeriodMillis);
				}
			}
			if(stopped) {
				for (int i = 0; i < this.mThreads.length; i++) {
					if(mThreads[i] != null) {
						mThreads[i].stopDownload();
					}
				}
			}
			if (!notFinish) {
				mLogDao.clearDownloadedRecord(this.mDownloadUrlStr);
				onDownloadSuccess();
			}else
				onDownloadPause();
		} catch (Exception e) {
			e.printStackTrace();
			throw new Exception("file download fail!!");
		} finally {
			if(randFile != null) {
				try {
					randFile.close();
					randFile = null;
				} catch (Exception e) {
				}
			}
		}
	}
	
	private void distributeTasksAndThread(URL url) {
		for (int i = 0; i < this.mThreads.length; i++) {// 开启线程进行下载
			int downloadedSize = this.mCacheDownloadRecords.get(i + 1).getDownloadedBlockSize();
			if (downloadedSize < this.taskBlockSizePerThread
					&& this.mDownloadedFileSize < this.mSourceFileSize) {// 判断线程是否已经完成下载,否则继续下载
				this.mThreads[i] = new RefactorDownloadThread(
						this,
						url,
						mSaveFile,
						taskBlockSizePerThread,
						downloadedSize,
						RefactorDownloaderConstants.DEFAULT_BUFFER_SIZE_PERTHREAD,
						i + 1, mProxy, mTimeoutMillis);
				this.mThreads[i].start();
			} else {
				this.mThreads[i] = null;
			}
		}
	}

	private void reInitializeDownloadCacheRecords() {
		this.mCacheDownloadRecords.clear();
		for (int i = 0; i < this.mThreads.length; i++) {
			int threadId = i + 1;
			RefactorDownloadedTaskEntity entity = new RefactorDownloadedTaskEntity();
			entity.setDownloadedBlockSize(0);
			entity.setDownloadUrlStr(mDownloadUrlStr);
			entity.setSaveFilePath(mSaveFile.getAbsolutePath());
			entity.setThreadId(threadId);
			this.mCacheDownloadRecords.put(threadId, entity);// 初始化每条线程已经下载的数据长度为0
		}
	}
	
	private void setSourceFileSizeAndCallback(int fileSize) {
		this.mSourceFileSize = fileSize;
		if (this.mDownloadListener != null) {
			mDownloadListener.onGetTargetDownloadFileSize(this.mSourceFileSize);
		}
	}
	
	private void onDownloadFailed(int errorCode) {
		if (this.mDownloadListener != null) {
			mDownloadListener.onDownloadFailed(errorCode);
		}
	}
	
	private void onDownloadFailed() {
		this.onDownloadFailed(RefactorDownloadListener.ERROR_UNKNOWN_ERROR);
	}
	
	private void onDownloadingSize(int downloadedSize) {
		if (this.mDownloadListener != null) {
			mDownloadListener.onDownloadingSize(downloadedSize, this.mSourceFileSize);
		}
	}
	
	private void onDownloadingSize() {
		this.onDownloadingSize(this.mDownloadedFileSize);
	}
	
	private void onDownloadSuccess(File file, String fileAbsolutePath) {
		if (this.mDownloadListener != null) {
			mDownloadListener.onDownloadSuccess(file, fileAbsolutePath);
		}
	}
	
	private void onDownloadSuccess() {
		this.onDownloadSuccess(this.mSaveFile, this.mSaveFile.getAbsolutePath());
	}
	
	private void onDownloadPause() {
		if (this.mDownloadListener != null) {
			mDownloadListener.onDownloadPause();
		}
	}
	
	public boolean isDownloading() {
		return this.isDownloading;
	}
	
	public void stopDownload() {
		stopped = true;
	}
	
	public String getDownloadUrl() {
		return mDownloadUrlStr;
	}

	public int getThreadSize() {
		return mThreads.length;
	}
	
	public int getFileSize() {
		return mSourceFileSize;
	}
	
	public int getDownloadSize() {
		return mDownloadedFileSize;
	}
	
	public void setTag(Object tag) {
		this.mTag = tag;
	}
	
	public Object getTag() {
		return this.mTag;
	}
	
	protected synchronized void append(int size) {
		mDownloadedFileSize += size;
	}
	
	protected void updateCacheDownloadRecord(int threadId, int downloadedSize) {
		RefactorDownloadedTaskEntity entity = this.mCacheDownloadRecords.get(threadId);
		entity.setDownloadedBlockSize(downloadedSize);
		this.mCacheDownloadRecords.put(threadId, entity);
	}
	
	private void updateRecords() {
		this.mLogDao.updateDownloadRecord(this.mCacheDownloadRecords, System.currentTimeMillis()+"");
	}
	
	private java.net.Proxy getProxy(Context context) {
		String host = APNUtil.getApnProxy(context);
		int port = APNUtil.getApnPortInt(context);
		SocketAddress socketAddress = new InetSocketAddress(host, port);
		java.net.Proxy proxy = new java.net.Proxy(java.net.Proxy.Type.HTTP, socketAddress);
		return proxy;
	}
	
//	private static Map<String, String> getHttpResponseHeader(HttpURLConnection http) {
//		Map<String, String> header = new HashMap<String, String>();
//		for (int i = 0;; i++) {
//			String mine = http.getHeaderField(i);
//			if (mine == null) {
//				break;
//			}
//			header.put(http.getHeaderFieldKey(i), mine);
//		}
//		return header;
//	}
//	
//	private static void printResponseHeader(HttpURLConnection http){
//		Map<String, String> header = getHttpResponseHeader(http);
//		for(Map.Entry<String, String> entry : header.entrySet()){
//			String key = entry.getKey()!=null ? entry.getKey()+ ":" : "";
//		}
//	}
}
