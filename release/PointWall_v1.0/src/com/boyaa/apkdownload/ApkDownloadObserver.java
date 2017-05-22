package com.boyaa.apkdownload;

import android.os.Handler;
import android.os.Message;

public abstract class ApkDownloadObserver {
	//类型定义
	public static final int UPDATE = 1;
	public static final int NOTICE = 2;
    public static final int INITCHECK = 3;
	public static final int UNKNOW_ERROR = 100;
	public static final int EXIST_FULL_APK = 101;
	public static final int GET_APK_SIZE_FAIL = 102;
	public static final int CREATE_APK_FILE_FAIL = 103;
	public static final int NETWORK_UNAVAILABLE_ERROR = 104;
	public static final int NETWORK_RESUME = 106;
	private Handler  mHandler;
	public ApkDownloadObserver() {
		mHandler = new Handler() {
			public void handleMessage(Message msg) {
				if (msg.what == UPDATE) {
					update((String)msg.obj, msg.arg1, msg.arg2);
				} else if (msg.what == NOTICE) {
					notice((String)msg.obj, msg.arg1, msg.arg2);
				}  else {
					//initCheck((String)msg.obj, msg.arg1);
				}
			}
		};
	}
	
	void sendMessage(Message msg) {
		mHandler.sendMessage(msg);
	}

	/** 方法在主线程中被调用 */
	public abstract void update(String apkUrl, int completeSize, int apkFileSize);
	public abstract void notice(String apkUrl, int type, int arg2);
	//public abstract void initCheck(String apkUrl,int state);
}
