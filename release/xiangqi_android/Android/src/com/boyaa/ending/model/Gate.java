package com.boyaa.ending.model;

/**
 * 残局大关
 */
public class Gate extends Entity{

	public int tid;
	public int isNeedPay = 0;				//0:需要付费 
	public int progress = 0;				//进度
	public int subCount = 0;
	public String str = "";					//json字符串

}
