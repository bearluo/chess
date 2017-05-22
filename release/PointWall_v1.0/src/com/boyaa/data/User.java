package com.boyaa.data;

import com.boyaa.utils.EnviromentUtil;

public class User {
	private User() {
		
		uid = EnviromentUtil.getDeviceId();
	}
	private static User me = new User();
	public static User getInstance() {
		return me;
	}
	public static void clear(){
		me.expire_in = "0";
		me.tocken = "";
		me.uid = EnviromentUtil.getDeviceId();
		me.isLogined = false;
		me.type = 0;
		me.hallUserId = 0;
		me.account = "";
		me.headImage = "";
	}
	public boolean isLogined = false;
	public String uid = EnviromentUtil.getDeviceId();
	public String nickename = "";
	public String headImage;
	public String tocken = "";
	public String expire_in = "0";
	public String lang;
	public String account;
	public String password;
	public int type;
	public int hallUserId;
	
}
