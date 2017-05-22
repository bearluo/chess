package com.boyaa.entity.common;



/*
 * 该类定义了所有返回监听事件所需要的接口，界面之间的转换以后直接以该类为标准
 */
public interface ICallBackListener {
	/*
	 * onSucceed接口用于实现当事物正常返回时的处理
	 */
	public void onSucceed();
	
	/*
	 * onFailed接口用于实现当事物失败返回时的处理
	 */
	public void onFailed();
	
	/*
	 * onJsonError接口用于实现当事物发生Json格式错误时的处理
	 */
	public void onJsonError(String message);
	
	/*
	 * onNetWorkError接口用于实现当事物发生接收不到服务器信息时的错误处理
	 */
	public void onNetWorkError(String message);
	
	public void onUserDefineError(int code, String message );
	
	public void onAbort(String message );
}
