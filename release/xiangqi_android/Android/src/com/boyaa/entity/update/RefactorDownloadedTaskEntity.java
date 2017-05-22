package com.boyaa.entity.update;

public class RefactorDownloadedTaskEntity {

	private int threadId;
	private String downloadUrlStr;
	private String saveFilePath;
	private int downloadedBlockSize;
	private long lastModifiedTime;
	
	public int getThreadId() {
		return threadId;
	}
	public void setThreadId(int threadId) {
		this.threadId = threadId;
	}
	public String getDownloadUrlStr() {
		return downloadUrlStr;
	}
	public void setDownloadUrlStr(String downloadUrlStr) {
		this.downloadUrlStr = downloadUrlStr;
	}
	public String getSaveFilePath() {
		return saveFilePath;
	}
	public void setSaveFilePath(String saveFilePath) {
		this.saveFilePath = saveFilePath;
	}
	public int getDownloadedBlockSize() {
		return downloadedBlockSize;
	}
	public void setDownloadedBlockSize(int downloadedBlockSize) {
		this.downloadedBlockSize = downloadedBlockSize;
	}
	public long getLastModifiedTime() {
		return lastModifiedTime;
	}
	public void setLastModifiedTime(long lastModifiedTime) {
		this.lastModifiedTime = lastModifiedTime;
	}
	
}
