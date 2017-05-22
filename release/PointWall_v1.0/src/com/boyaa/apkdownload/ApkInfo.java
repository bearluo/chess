package com.boyaa.apkdownload;

import java.util.List;

import com.boyaa.cache.Cacheable;

public class ApkInfo implements Cacheable {
	public static final String TAG = "com.boyaa.apkdownload.ApkInfo";

	//对象状态
	public static final int PAUSE = 3;
	public static final int DELETE = 4;
	public static final int RESUME = 6;
    public static final int WAITING = 8;
	//对象及数据库状态
	public static final int INIT = 1;
	public static final int DOWNLOADING = 2;
	public static final int COMPLETED = 5;
	public static final int ERROR = 7;

	public long _id;
	public String apkUrl;
	public int apkFileSize;
	public int completeSize;
	public String apkFilePath;
	public int state;
	public int type;
	
	public List<ApkItem> apkItemList;
	
	public ApkInfo(String apkUrl, int apkFileSize, int completeSize, String apkFilePath) {
		this.apkUrl = apkUrl;
		this.apkFileSize = apkFileSize;
		this.completeSize = completeSize;
		this.apkFilePath = apkFilePath;
	}
	
	public ApkInfo copy() {
		ApkInfo info = new ApkInfo(apkUrl, apkFileSize, completeSize, apkFilePath);
		info._id = _id;
		info.state = state;
		return info;
	}

	public static class ApkItem {
		public static final int UNCOMPLETED = 0;
		public static final int COMPLETED = 1;

		public long _id;//数据库自身_ID
		public long infoId;
		public int startPos;
		public int endPos;
		public int completeSize;
		public int state;//1完成；0未完成

		public ApkInfo info;
	}
	@Override
	public boolean equals(Object o) {
		// TODO Auto-generated method stub
		if(o==null)return false;
		if (o instanceof ApkInfo) {
			ApkInfo info = (ApkInfo)o;
			if(info.apkUrl!=null){
				return info.apkUrl.equals(this.apkUrl);
			} else {
				return false;
			}
			
		}
		return false;
	}
}
