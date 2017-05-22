package com.boyaa.entity.common;

public interface IThirdPartySdk {
	
	//登陆
	public int login(String key , String data );
	//分享
	public int Share(String key , String data );
	//支付
	public int pay(String key , String data );
	//好友
	public int freunde(String key  , String data );
	//退出
	public int logout(String key  , String data );
}
