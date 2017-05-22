package com.boyaa.entity.update;

import java.io.File;
import java.io.InputStream;
import java.io.RandomAccessFile;
import java.net.HttpURLConnection;
import java.net.URL;

//import android.util.Log;

public class RefactorDownloadThread extends Thread {
	private static final String TAG = RefactorDownloadThread.class.getSimpleName();
	
	private File mSaveFile;
	private URL mDownloadUrl;
	private int mTaskBlockSize;
	private int mTimeoutMillis;
	private int mThreadId = -1;	
	private int mDownloadedBlockSize;
	private java.net.Proxy mProxy;
	private byte[] mBuffer;
	private boolean isFinish = false;
	
	private RefactorDownloader mDownloader;
	
	private boolean stopped = false;
	
	public RefactorDownloadThread(RefactorDownloader downloader,
			URL downloadUrl, File saveFile, int taskBlockSize,
			int downloadedBlockSize, int bufferSize, int threadId,
			java.net.Proxy proxy) {
		
		this(downloader, downloadUrl, saveFile, taskBlockSize,
				downloadedBlockSize, bufferSize, threadId, proxy,
				RefactorDownloaderConstants.DEFAULT_TIMEOUT);
		
	}

	public RefactorDownloadThread(RefactorDownloader downloader,
			URL downloadUrl, File saveFile, int taskBlockSize,
			int downloadedBlockSize, int bufferSize, int threadId,
			java.net.Proxy proxy, int timeoutMillis) {
		
		this.mDownloadUrl = downloadUrl;
		this.mSaveFile = saveFile;
		this.mTaskBlockSize = taskBlockSize;
		this.mDownloader = downloader;
		this.mThreadId = threadId;
		this.mProxy = proxy;
		if (bufferSize < 0) {
			throw new IllegalArgumentException("bufferSize " + bufferSize + " is not legal!");
		}
		this.mBuffer = new byte[bufferSize];
		this.mDownloadedBlockSize = downloadedBlockSize;
		this.mTimeoutMillis = timeoutMillis;
	}
	
	public void stopDownload() {
		this.stopped = true;
	}
	
	@Override
	public void run() {
		if(mDownloadedBlockSize < mTaskBlockSize){//未下载完成
			InputStream inStream = null;
			RandomAccessFile fileBlock = null;
			HttpURLConnection conn = null;
			try {
				if (this.mProxy == null) {
					conn = (HttpURLConnection) mDownloadUrl.openConnection();
				} else {
					conn = (HttpURLConnection) mDownloadUrl.openConnection(mProxy);
				}
				conn.setConnectTimeout(mTimeoutMillis);
				conn.setReadTimeout(mTimeoutMillis);
				conn.setRequestMethod("GET");
				conn.setRequestProperty("Accept", "image/gif, image/jpeg, image/pjpeg, image/pjpeg, application/x-shockwave-flash, application/xaml+xml, application/vnd.ms-xpsdocument, application/x-ms-xbap, application/x-ms-application, application/vnd.ms-excel, application/vnd.ms-powerpoint, application/msword, */*");
				conn.setRequestProperty("Accept-Language", "zh-CN");
				conn.setRequestProperty("Referer", mDownloadUrl.toString()); 
				conn.setRequestProperty("Charset", "UTF-8");
				
				int startPos = mTaskBlockSize * (mThreadId - 1) + mDownloadedBlockSize;//开始位置
				int endPos = mTaskBlockSize * mThreadId -1;//结束位置
				conn.setRequestProperty("Range", "bytes=" + startPos + "-"+ endPos);//设置获取实体数据的范围
				conn.setRequestProperty("User-Agent", "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.2; Trident/4.0; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.30; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)");
				conn.setRequestProperty("Connection", "Keep-Alive");
				conn.setRequestProperty("Accept-Encoding", "identity");
				
				inStream = conn.getInputStream();
//				logResponseHead(conn);
				int offset = 0;
				fileBlock = new RandomAccessFile(this.mSaveFile, "rws");
				fileBlock.seek(startPos);
				
				while ((offset = inStream.read(mBuffer, 0, mBuffer.length)) != -1) {
					fileBlock.write(mBuffer, 0, offset);
					mDownloadedBlockSize += offset;
					mDownloader.updateCacheDownloadRecord(this.mThreadId,
							mDownloadedBlockSize);
					mDownloader.append(offset);

					if (stopped) {
						break;
					}
				}
				
				if (mDownloadedBlockSize == mTaskBlockSize) {
					isFinish = true;
				}

				fileBlock.close();
				inStream.close();
				
			} catch (Exception e) {
				this.mDownloadedBlockSize = -1;
			} finally {
				if (fileBlock != null) {
					try {
						fileBlock.close();
						fileBlock = null;
					} catch (Exception e) {
					}
				}
				if (inStream != null) {
					try {
						inStream.close();
						inStream = null;
					} catch (Exception e) {
					}
				}
				if (conn != null) {
					try {
						conn.disconnect();
						conn = null;
					} catch (Exception e) {
					}
				}
			}
		}
	}
	
	public boolean isDownloadTaskFinish() {
		return isFinish;
	}
	
	public long getDownloadedBlockSize() {
		return mDownloadedBlockSize;
	}
	
	// 打印回应的头信息
//	public void logResponseHead(HttpURLConnection con) {
//		for (int i = 1;; i++) {
//			String header = con.getHeaderFieldKey(i);
//			//String str="a";
//			if (header != null)
//				// responseHeaders.put(header,httpConnection.getHeaderField(header));
//				//str = con.getHeaderField(header);
//				System.err.println(con.getHeaderField(header));
//				//if(!str.equals("asdf"))
//				//	System.out.println(str);
//			else
//				break;
//		}
//	}
}
