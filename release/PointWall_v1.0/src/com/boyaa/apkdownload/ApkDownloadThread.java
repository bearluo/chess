package com.boyaa.apkdownload;

import java.io.BufferedInputStream;
import java.io.InputStream;
import java.io.RandomAccessFile;
import java.net.HttpURLConnection;
import java.net.URL;

import android.text.TextUtils;

import com.boyaa.apkdownload.ApkInfo.ApkItem;
import com.boyaa.common.Config;
import com.boyaa.common.NetworkUtil;
import com.boyaa.log.Log;

public class ApkDownloadThread extends Thread {
	private ApkDownloader mApkDownloader;
	private static boolean isRunning = true;
	public ApkDownloadThread(ApkDownloader apkDownloader) {
		mApkDownloader = apkDownloader;
	}
    public void setIsRunning(boolean is){
    	isRunning = is;
    }
	@Override
	public void run() {
		while(isRunning) {
			ApkItem item = mApkDownloader.getTask();
			if (item == null) {
				_wait();
			} else {
				downloadApk(item);
			}
		}
	}
	
	private void _wait() {
		synchronized(mApkDownloader) {
			try {
				Log.d("Thread", "Thread " + getId() + " 我太累了，休息会");
				mApkDownloader.wait();
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
	}
	
	
	private void downloadApk(ApkItem item) {
		HttpURLConnection connection = null;
		RandomAccessFile randomAccessFile = null;
		InputStream is = null;
		try {
			System.setProperty("http.keepAlive", "false");
			URL url = new URL(item.info.apkUrl);
			connection = (HttpURLConnection)url.openConnection();
			connection.setConnectTimeout(Config.HTTP_CONNECT_TIME_OUT);
			connection.setRequestMethod("GET");
			// 设置范围，格式为Range：bytes x-y;
			connection.setRequestProperty("Range", "bytes=" + (item.startPos + item.completeSize) + "-" + item.endPos);
			//Log.d("Thread111", "Thread bytes=" + (item.startPos + item.completeSize) + "-" + item.endPos);

			// 将要下载的文件写到保存在保存路径下的文件中
			is = new BufferedInputStream(connection.getInputStream());

			randomAccessFile = new RandomAccessFile(item.info.apkFilePath, "rwd");
			randomAccessFile.seek(item.startPos + item.completeSize);
			byte[] buffer = new byte[1024*50];//10KB
			int length = -1;
			int needLength = item.endPos - (item.startPos + item.completeSize) + 1;
			int totalLength = 0;
			mApkDownloader.notice(item.info.apkUrl, ApkInfo.DOWNLOADING);
			while ((length = is.read(buffer)) != -1) {
				randomAccessFile.write(buffer, 0, length);
				
				item.completeSize += length;
				
				totalLength += length;
				
				if (item.completeSize == item.endPos - item.startPos + 1) {
					item.state = ApkItem.COMPLETED;//完成
					mApkDownloader.update(item.info.apkUrl, totalLength);//通知Ui更新视图
				}
				// 更新数据库中的下载信息
				mApkDownloader.apkInfoDao.updataApkItem(item);
				if (item.info.state == ApkInfo.PAUSE) {
//					return;
					break;
				} else if (item.info.state == ApkInfo.DELETE){
					mApkDownloader.notice(item.info.apkUrl, ApkInfo.DELETE);
//                    return ;
					break;
				}
				
			}
			if (totalLength > needLength) Log.e("Thread", "Item 实际下载长度:" + totalLength + " 应下载长度：" + needLength);
		} catch (Exception e) {
			e.printStackTrace();
			/* 当正在关闭网络时请求失败，但NetworkUtil.isNetworkAvailable()仍返回true */
			boolean networkUnreachable = false;
			String msgString =e.getMessage();
			if (!TextUtils.isEmpty(msgString)) {				
				if (msgString.contains("Connection timed out") || msgString.contains("Network is unreachable")) {
					networkUnreachable = true;
					Log.e("Thread", "Thread networkUnavailable" + getId());
				}
				if (msgString.contains("write failed")) {
					Log.e("Thread", "安装包文件删除，randomAccessFile写人错误");
					return ;
					
				}
			}
			if (!NetworkUtil.isNetworkAvailable() || networkUnreachable) {
				Log.e("Thread", "Thread " + getId() + " 无网络异常"+e.getMessage());
				
				mApkDownloader.setApkInfoState(item.info.apkUrl, ApkInfo.ERROR);
				mApkDownloader.notice(item.info.apkUrl, ApkDownloadObserver.NETWORK_UNAVAILABLE_ERROR);
			} else {
				Log.e("Thread", "Thread " + getId() + " 未知异常"+e.getMessage());
				mApkDownloader.setApkInfoState(item.info.apkUrl, ApkInfo.ERROR);
				mApkDownloader.notice(item.info.apkUrl, ApkDownloadObserver.UNKNOW_ERROR);
			}
			_wait();
		} finally {
			try {
				if (is != null) is.close();
				if (randomAccessFile != null){
					randomAccessFile.close();
					
				} 
				if (connection != null) connection.disconnect();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
}