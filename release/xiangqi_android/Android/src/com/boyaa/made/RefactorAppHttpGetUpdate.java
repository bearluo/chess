package com.boyaa.made;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InterruptedIOException;
import java.net.HttpURLConnection;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.apache.http.HttpEntity;
import org.apache.http.HttpHost;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.conn.params.ConnRoutePNames;
import org.apache.http.entity.BufferedHttpEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.params.CoreConnectionPNames;

import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.entity.update.RefactorDownloadListener;
import com.boyaa.entity.update.RefactorDownloader;
import com.boyaa.util.MD5Util;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.os.Environment;
import android.os.Message;
import android.os.SystemClock;
import android.text.TextUtils;
import android.util.Log;

/**
 * 重构并加代理版的AppHttpGetUpdate，暂时与AppHttpGetUpdate共存，若没有bug的话就用于代替AppHttpGetUpdate，
 * 当前AppHttpGetUpdate存在一个超时无法保证进度返回立即停止的bug，并且存在返回超时之后依旧能返回成功的bug
 * @author junmeng
 */
public class RefactorAppHttpGetUpdate implements Runnable {
	private static HashMap<Integer,Message> mMsgs = new HashMap<Integer,Message>();
	private static Map<Integer, RefactorDownloader> updateDownloads = new ConcurrentHashMap<Integer, RefactorDownloader>();
	
	private static Object mSyncMsgs = new Object();
	
	public static void AddMsg(int id, Message msg) {
		synchronized (mSyncMsgs) {
			mMsgs.put(id, msg);
		}
	}
	
	public static Message RemoveMsg(int id) {
		Message msg = null;
		synchronized (mSyncMsgs) {
			if (mMsgs.containsKey(id)) {
				msg = mMsgs.get(id);
				mMsgs.remove(id);
			}
		}
		return msg;
	}
	
	public static void HandleTimeout(Message msg) {
		Bundle bundle = msg.getData();
		final int id = bundle.getInt(kId);
		final String event = bundle.getString(kEvent);
		if (null != RemoveMsg(id)) {
			AppActivity.mActivity.runOnLuaThread(new Runnable() {
				@Override
				public void run() {
					String strDictName = GetDictName(id);
					AppActivity.dict_set_int(kHttpGetUpdateExecute, kId, id);
					AppActivity.dict_set_int(strDictName, kResult,
							kResultTimeout);

					String strFunc;
					if (null == event) {
						strFunc = KEventPrefix;
					} else {
						strFunc = KEventPrefix_ + event;
					}
					AppActivity.call_lua(strFunc);
				}
			});
		}
	}
	
	private static String GetDictName(int id) {
		return String.format("%s%d", kHttpGetUpdateExecute, id);
	}
	
	public static void cancelAllUpdateDownload() {
		for(Map.Entry<Integer, RefactorDownloader> entry : updateDownloads.entrySet()) {
			cancelUpdateDownload(entry.getKey());
		}
	}
	
	public static void cancelUpdateDownload(int id) {
		RefactorDownloader downloader = updateDownloads.remove(id);
		if (downloader != null) {
			downloader.stopDownload();
		}
	}
	
	public static void cancelUpdateDownloadById() {
		int id = AppActivity.dict_get_int(kHttpGetUpdateExecute, kId, -1);
		cancelUpdateDownload(id);
	}

	private final static String kHttpGetUpdateExecute = "http_get_update";
	private final static String KEventPrefix = "event_http_get_update_response";
	private final static String KEventPrefix_ = "event_http_get_update_response_";
	private final static String KEventTimePeriod = "event_http_get_update_timer_period";
	private final static String KEventTimePeriod_ = "event_http_get_update_timer_period_";
	
	private final static String kId = "id";
	private final static String kUrl = "url";
	private final static String kSaveAs = "saveas";
	private final static String kTimeout = "timeout";
	private final static String kEvent = "event";
	private final static String kResult = "result";//flag of finish status
	private final static String kTimerPeriod = "timerPeriod";
	private final static String kMd5 = "md5";

	private final static int kResultSuccess = 1;
	private final static int kResultTimeout = 0;
	private final static int kResultError = -1;
	private final static int kResultMD5Fail = -2;
	private final static int kResultPause = 2;
	private final static int kBufferSize = 1024*4;
	
	// 下载类型
	private static final int DOWNLOAD_TYPE_PNG = 1;
	private static final int DOWNLOAD_TYPE_PATCH = 2;
	
	/**
	 * 默认套接字超时
	 */
	private final static int DEFAULT_SOCKET_TIMEOUT = 10000; 		// 根据原代码Timer SocketTimeOut设为10秒
	private final static int DEFAULT_NOTIFICATION_PERIOD = 200;		// 默认进度返回周期
	
	private int id;
	private String url;
	private String savePath;
	private int timeOut;
	private String event;
	private int result; 
	private String resultReason;
	private long hasRead;
	private long percentage;
	private long size;
	private int timerPeriod;
	private String md5;
	
	/**
	 * 是否需要返回值给Lua，如果建立连接超时，则不需要再返回一次
	 */
	private boolean needReturnResult = true;
	
	public void Execute() {
		
		result = kResultError;	
		resultReason = "下载失败(INIT FAIL)";
		id = AppActivity.dict_get_int(kHttpGetUpdateExecute, kId, -1);
		if (-1 == id) {
			return;
		}
		String strDictName = GetDictName ( id );

		url = AppActivity.dict_get_string(strDictName, kUrl);
		savePath = AppActivity.dict_get_string(strDictName, kSaveAs);
		timeOut = AppActivity.dict_get_int(strDictName, kTimeout,0);
		event = AppActivity.dict_get_string(strDictName, kEvent);

		timerPeriod = AppActivity.dict_get_int(strDictName, kTimerPeriod,0);
		md5 = AppActivity.dict_get_string(strDictName, kMd5);
		
		timerPeriod = timerPeriod < DEFAULT_NOTIFICATION_PERIOD ? DEFAULT_NOTIFICATION_PERIOD : timerPeriod;
		
		if ( timeOut < 1000 ) timeOut = 1000;
		
		File saveFile = new File(savePath);
		if (!saveFile.exists()) {
			Log.i("checkFile",savePath);
		}
		if (TextUtils.isEmpty(url)||TextUtils.isEmpty(url.replace(" ", "").trim())) {
			result = kResultError;
			resultReason = "下载失败(URL EMPTY)";
			returnResultToLua();
			return;
		}

		if (DOWNLOAD_TYPE_PATCH == checkDownloadType(savePath)) {
			
			new Thread() {
				@Override
				public void run() {
					breakpointResumeDownloadPatch();
				}
			}.start();
			
		} else {
			Message msg = new Message();
			Bundle bundle = new Bundle();
			bundle.putInt(kId, id);
			bundle.putString(kEvent, event);
			msg.what = AppActivity.HANDLER_HTTPGET_UPDATE_TIMEOUT;
			msg.setData(bundle);
			AppActivity.getHandler().sendMessageDelayed(msg,timeOut);
			AddMsg(id,msg);
			new Thread(this).start();
		}
	}
	
	@Override
	public void run() {

		int downloadType = checkDownloadType(savePath);
		
		switch (downloadType) {

		case DOWNLOAD_TYPE_PNG:
			downloadPNG();
			break;

		case DOWNLOAD_TYPE_PATCH:
			downloadPatch();
			break;
		}
		
		returnResultToLua();
	}

	/**
	 * 根据保存路径字符串判断下载类型
	 * @param savePath
	 * @return
	 */
	private int checkDownloadType(String savePath) {
		String strPathLowCase = savePath.toLowerCase();
		int len = strPathLowCase.length() - 4;
		if ( len == strPathLowCase.lastIndexOf(".png")) {
			return DOWNLOAD_TYPE_PNG;
		} else {
			return DOWNLOAD_TYPE_PATCH;
		}
	}
	
	private File getTempDownloadFile() {
		String fileName = new File(savePath).getName();
		String strSDPath = Environment.getExternalStorageDirectory().getAbsolutePath();
		String packageName = Game.mActivity.getPackageName();
		String tempDirPath = strSDPath + File.separator + "." + packageName + File.separator + "dltmp";
		Log.i("tempDirPath",tempDirPath);
		File tempDir = new File(tempDirPath);
		if (!tempDir.exists()) {
			tempDir.mkdirs();
		}
		File tempFile = new File(tempDir, fileName + ".dltmp");
		if (!tempFile.exists()) {
			try {
				tempFile.createNewFile();
			} catch (IOException e) {
			}
		}
		return tempFile;
	}
	
	private void renameAndSaveFile(File tmpFile) {
		File dstFile = new File(savePath);
		File dir = dstFile.getParentFile();
		if (!dir.exists()) {
			dir.mkdirs();
		}
		tmpFile.renameTo(dstFile);
	}
	
	private void breakpointResumeDownloadPatch() {
		
		// 下载完成才会保存为savePath，缓存文件名称为savePath.dltmp
		if (new File(savePath).exists()) {
			noticePercentage(100);
			result = kResultSuccess;
			returnResultToLua();
			return;
		}
		
		RefactorDownloadListener downloadListener = new RefactorDownloadListener() {
			
			@Override
			public void onGetTargetDownloadFileSize(int targetFileSize) {
			}
			
			@Override
			public void onDownloadingSize(int downloadedSize, int sourceFileSize) {
				percentage = (long)downloadedSize * 100/ (long)sourceFileSize;
				noticePercentage();
			}
			
			@Override
			public void onDownloadSuccess(File file, String fileAbsolutePath) {
				renameAndSaveFile(file);
				updateDownloads.remove(id);
				result = kResultSuccess;
				try {
					Runtime runtime = Runtime.getRuntime();
					runtime.exec("chmod 777 " + savePath);
				} catch (IOException e) {
					e.printStackTrace();
				}
				if(!MD5Util.verify(savePath,md5)){
					resultReason="安装包校验失败(MD5 FAIL)";
					result = kResultMD5Fail;
				}
				returnResultToLua();
			}
			
			@Override
			public void onDownloadPause(){
				updateDownloads.remove(id);
				resultReason="暂停下载(PAUSE)";
				result = kResultPause;
				returnResultToLua();
			}
			
			@Override
			public void onDownloadFailed(int errorCode) {
				switch(errorCode){
					case RefactorDownloadListener.ERROR_INCORRECT_URL:resultReason="下载失败(ERROR_INCORRECT_URL)";break;
					case RefactorDownloadListener.ERROR_PROTOCOL_EXCEPTION:resultReason="下载失败(ERROR_PROTOCOL_EXCEPTION)";break;
					case RefactorDownloadListener.ERROR_SERVER_NO_RESPONSE:resultReason="下载失败(ERROR_SERVER_NO_RESPONSE)";break;
					case RefactorDownloadListener.ERROR_UNKNOWN_ERROR:resultReason="下载失败(ERROR_UNKNOWN_ERROR)";break;
					case RefactorDownloadListener.ERROR_UNKNOWN_FILE_SIZE:resultReason="下载失败(ERROR_UNKNOWN_FILE_SIZE)";break;
				}
				updateDownloads.remove(id);
				result = kResultError;
				returnResultToLua();
			}
		};
		
		// 缓存路径
		File tempFile = getTempDownloadFile();
		
		RefactorDownloader downloader = new RefactorDownloader(
				AppActivity.mActivity.getApplicationContext(), url, timeOut,
				timerPeriod, tempFile , 1, downloadListener);
		
		updateDownloads.put(id, downloader);
		
		downloader.startDownload();
	}
	
	/**
	 * 下载PNG图片，对应DOWNLOAD_TYPE_PNG
	 */
	private void downloadPNG() {
		result = kResultError;
		try {

			DefaultHttpClient client = new DefaultHttpClient();
			client.getParams().setParameter(CoreConnectionPNames.CONNECTION_TIMEOUT, timeOut);
			client.getParams().setParameter(CoreConnectionPNames.SO_TIMEOUT, DEFAULT_SOCKET_TIMEOUT);

			setProxy(client);

			HttpGet httpGet = new HttpGet(url);

			HttpResponse response = client.execute(httpGet);
			
			Message msg = RemoveMsg(id);
			if (msg == null) {
				needReturnResult = false;
				return;
			}

			int code = response.getStatusLine().getStatusCode();
			if (code == HttpURLConnection.HTTP_OK) {
				InputStream is = null;
				FileOutputStream fos = null;
				try {
					HttpEntity entity = response.getEntity();
					BufferedHttpEntity bufEntity = new BufferedHttpEntity(
							entity);
					is = bufEntity.getContent();
					Bitmap bmp = BitmapFactory.decodeStream(is);
					fos = new FileOutputStream(savePath);
					bmp.compress(Bitmap.CompressFormat.PNG, 100, fos);
					fos.flush();
					// 成功
					result = kResultSuccess;
				} catch (FileNotFoundException e) {
				} catch (InterruptedIOException e) {
					// Socket超时
					result = kResultTimeout;
					resultReason = "下载响应超时(TIME OUT)";
				} catch (IOException e) {
				} finally {

					if (is != null) {
						try {
							is.close();
							is = null;
						} catch (IOException e) {
						}
					}

					if (fos != null) {
						try {
							fos.close();
							fos = null;
						} catch (IOException e) {
						}
					}
				}
			}
		} catch (ClientProtocolException e) {
		} catch (IOException e) {
		} catch (Exception e) {
			result = kResultError;
			resultReason = "下载失败(HTTP ERROR)";
		}
	}
	
	/**
	 * 下载更新包相关，对应DOWNLOAD_TYPE_PATCH
	 */
	private void downloadPatch() {
		result = kResultError;
		
		try {
			DefaultHttpClient client = new DefaultHttpClient();
			client.getParams().setParameter(CoreConnectionPNames.CONNECTION_TIMEOUT, timeOut);
			client.getParams().setParameter(CoreConnectionPNames.SO_TIMEOUT, DEFAULT_SOCKET_TIMEOUT);
			
			setProxy(client);

			HttpGet httpGet = new HttpGet(url);
			HttpResponse response = client.execute(httpGet);
			
			Message msg = RemoveMsg(id);
			if (msg == null) {
				needReturnResult = false;
				return;
			}
			
			int code = response.getStatusLine().getStatusCode();
			if (code == HttpURLConnection.HTTP_OK) {
				HttpEntity entity = response.getEntity();

				InputStream is = null;
				FileOutputStream fos = null;

				try {
					is = entity.getContent();
					fos = new FileOutputStream(savePath);

					size = entity.getContentLength();
					
					byte[] buffer = new byte[kBufferSize];
					int len;
					
					long lastTime = SystemClock.uptimeMillis();

					while (true) {
						len = is.read(buffer);
						
						if (len > 0) {
							fos.write(buffer, 0, len);
							hasRead += len;
							percentage = (hasRead * 100) / size;
						}

						long curTime = SystemClock.uptimeMillis();
						if (curTime - lastTime > timerPeriod) {
							noticePercentage();
							lastTime = curTime;
						}
						
						if (len < 0) {
							if (hasRead == size) {
								// 下载完毕
								fos.flush();
								noticePercentage();
								result = kResultSuccess;
							} else {
								// 由于某些诡异的原因无法读IO
								result = kResultError;
								resultReason = "下载失败(something else error)";
							}
							break;
						}

					}

				} catch (IllegalStateException e) {
				} catch (FileNotFoundException e) {
				} catch (InterruptedIOException e) {
					// Socket超时
					result = kResultTimeout;
					resultReason = "下载超时(TIME OUT)";
				} catch (IOException e) {
				} finally {
					if (fos != null) {
						try {
							fos.close();
							fos = null;
						} catch (IOException e) {
						}
					}
					if (is != null) {
						try {
							is.close();
							fos = null;
						} catch (IOException e) {
						}
					}
				}
			}
		} catch (ClientProtocolException e) {
		} catch (IOException e) {
		} catch (Exception e) {
			result = kResultError;
			resultReason = "下载失败(HTTP ERROR)";
		}
	}
	
//	/**
//	 * 用于添加代理（如果有的话）
//	 */
//	private HttpHost getProxy() {
//		try {
//			Activity activity = Game.mActivity;
//			boolean hasProxy = APNUtil.hasProxy(activity);
//			if (hasProxy) {
//				String proxyIP = APNUtil.getApnProxy(activity);
//				String proxyPort = APNUtil.getApnPort(activity);
//				
//				Integer port = Integer.getInteger(proxyPort);
//				
//				if (!TextUtils.isEmpty(proxyIP) && port != null) {
//					HttpHost proxy = new HttpHost(proxyIP, port);
//					return proxy;
//				}
//				
//			}
//		} catch (Exception e) {
//		}
//		return null;
//	}
//	
//	/**
//	 * 添加代理
//	 * @param client
//	 */
//	private void addProxy(DefaultHttpClient client) {
//		HttpHost proxy = getProxy();
//		if (proxy != null) {
//			client.getParams().setParameter(ConnRoutePNames.DEFAULT_PROXY, proxy);
//		}
//	}
	/**
	 * 添加代理
	 * @param client
	 */
	private void setProxy(HttpClient client) {
		try {
			// 有可能会出现需要代理，但proxyIP为空的情况，所以try-catch一下
			Context context = AppActivity.mActivity.getApplication().getApplicationContext();
			boolean useProxy = APNUtil.hasProxy(context);
			if (useProxy) {
				String proxyIP = APNUtil.getApnProxy(context);
				int proxyPort = APNUtil.getApnPortInt(context);
				HttpHost proxy = new HttpHost(proxyIP, proxyPort);
				client.getParams().setParameter(ConnRoutePNames.DEFAULT_PROXY,
						proxy);
			} else {
				client.getParams()
						.setParameter(ConnRoutePNames.DEFAULT_PROXY, null);
			}
		} catch (Exception e) {
			client.getParams().setParameter(ConnRoutePNames.DEFAULT_PROXY, null);
		}
	}
	
	/**
	 * 回传下载进度
	 */
	private void noticePercentage(){
		AppActivity.mActivity.runOnLuaThread(new Runnable() {
			@Override
			public void run() {
				String strDictName = GetDictName(id);
				AppActivity.dict_set_int(kHttpGetUpdateExecute, kId, id);
				AppActivity.dict_set_double(strDictName, kResult, percentage);
				String strFunc;
				if (null == event) {
					strFunc = KEventTimePeriod;
				} else {
					strFunc = KEventTimePeriod_ + event;
				}
				AppActivity.call_lua(strFunc);
			}
		});
	}
	
	/**
	 * 回传下载进度
	 * @param percent 0~100
	 */
	private void noticePercentage(final double percent) {
		AppActivity.mActivity.runOnLuaThread(new Runnable() {
			@Override
			public void run() {
				String strDictName = GetDictName(id);
				AppActivity.dict_set_int(kHttpGetUpdateExecute, kId, id);
				AppActivity.dict_set_double(strDictName, kResult, percent);
				String strFunc;
				if (null == event) {
					strFunc = KEventTimePeriod;
				} else {
					strFunc = KEventTimePeriod_ + event;
				}
				AppActivity.call_lua(strFunc);
			}
		});
	}
	
	private void returnResultToLua() {
		if (!needReturnResult) {
			return;
		}
		
		AppActivity.mActivity.runOnLuaThread(new Runnable() {
			@Override
			public void run() {
				String strDictName = GetDictName(id);
				AppActivity.dict_set_int(kHttpGetUpdateExecute, kId, id);
				AppActivity.dict_set_int(strDictName, kResult, result);
				AppActivity.dict_set_string(strDictName, "resultReason", resultReason);
				String strFunc;
				if (null == event) {
					strFunc = KEventPrefix;
				} else {
					strFunc = KEventPrefix_ + event;
				}
				AppActivity.call_lua(strFunc);
			}
		});
	}
}
