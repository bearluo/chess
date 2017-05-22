package com.boyaa.snslogin;

public interface ISNSInterface {
	public void auth(AuthCallBack authCallBack);
	public void Login(AuthCallBack authCallBack);
	
	public void clearAuthReceiver();
	
	
	public interface AuthCallBack {
		public void  onSuccess(UserInfo userInfo);
		public void  onFail(String result);
	}
}
