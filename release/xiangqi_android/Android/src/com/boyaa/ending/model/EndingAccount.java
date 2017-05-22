package com.boyaa.ending.model;

public class EndingAccount extends Entity {
	
	public int uid;
	public int tid;
	public int isNeedPay = 0;
	public int progress = 0;	//进度
	
	@Override
	public String toString() {
		return "EndingAccount [uid=" + uid + ", tid=" + tid + ", isNeedPay="
				+ isNeedPay + ", progress=" + progress + "]";
	}
}
