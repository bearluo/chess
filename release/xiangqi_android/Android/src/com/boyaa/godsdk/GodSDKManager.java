package com.boyaa.godsdk;

import java.util.HashMap;
import java.util.Set;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Map;

import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.chinesechess.platform91.wxapi.Constants;
import com.boyaa.chinesechess.platform91.wxapi.SendToWXUtil;
import com.boyaa.entity.core.HandMachine;
import com.boyaa.godsdk.callback.AccountListener;
import com.boyaa.godsdk.callback.CallbackStatus;
import com.boyaa.godsdk.callback.IAPListener;
import com.boyaa.godsdk.callback.SDKListener;
import com.boyaa.godsdk.core.ActivityAgent;
import com.boyaa.godsdk.core.GodSDK;
import com.boyaa.godsdk.core.GodSDKAccount;
import com.boyaa.godsdk.core.GodSDKIAP;
import com.boyaa.godsdk.core.GodSDK.IGodSDKIterator;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.widget.Toast;

//状态码（回调状态）CallbackStatus：
//主要包含：主状态码，子状态码，状态描述信息，其余参数（留作扩充）
//	/**
//	 * 主状态码
//	 */
//	private int mainStatus = BaseCallbackStatus.UNKNOWN;
//	
//	/**
//	 * 子状态码
//	 */
//	private int subStatus = BaseCallbackStatus.UNKNOWN;
//	
//	/**
//	 * 状态描述信息
//	 */
//	private String msg = "";
//	
//	/**
//	 * 其余参数，用于做扩充
//	 */
//	private Bundle extras;
//主状态码mainStatus即用于描述事件结果，比如登录失败。
//子状态码subStatus用于描述导致主状态的具体原因，比如用户取消、超时等。

public class GodSDKManager {

	private static Context ctx;
	private static SDKListener mSDKListner;//SDK事件监听：
	private static AccountListener mAccountListener;//账户事件监听：
	private static IAPListener mIAPListener;//支付事件监听：
	private static String GodSDKTag = "GodSDK";
	private static Set<String> pmodes;
	private static boolean mShouldDestoryAndKillProcess;

	public static void initGodSDK(Context context){
		ctx = context;
		setListener();
		initSDK();
	}
	
//	支付
	public static void pay(String data) {
		JSONObject object;
		int pmode;
		String params;
		Map<String, Object>map;
		try {
			object = new JSONObject(data);
			pmode = object.getInt("pmode");
			map = new HashMap<String, Object>();
			switch(pmode){
//				case 218:
//					//移动MM弱网支付
//					String orderid_mm = object.getString("pid");
//					String paycode_mm = object.getString("paycode");
//					String appid_mm = PayContent.appid_mm;
//					String appkey_mm = PayContent.appkey_mm;
//					
//					map = new HashMap<String, Object>();
//					map.put("porder", orderid_mm);			//订单号
//					map.put("paycode", paycode_mm);			//计费码
//					map.put("appid", appid_mm);				//应用编号
//					map.put("appkey", appkey_mm);		    //商品名称限定长度50
//					map.put("pmode", Integer.toString(pmode));				//支付渠道ID
//					break;
				case 109:
					//联通wo商店
					String orderid_wo = object.getString("pid");
					String customCode_wo = object.getString("customCode");
					
					map.put("porder", orderid_wo);			//订单号
					map.put("customCode", customCode_wo);	//第三方支付计费代码
					map.put("pmode", Integer.toString(pmode));				//支付渠道ID
					break;
				case 34:
					//电信爱游戏
					String orderid_dianxin = object.getString("pid");
					String desc_dianxin = object.getString("desc");
					String price_dianxin = object.getString("price");
					
					map.put("orderid", orderid_dianxin);		//订单号
					map.put("price", price_dianxin);			//价格
					map.put("desc", desc_dianxin);				//描述
					map.put("pmode", Integer.toString(pmode));				    //支付渠道ID
					break;
				case 265:
					//支付宝极简标准版支付
					String orderid_alipay = object.getString("pid");
					String desc_alipay = object.getString("desc");
					String price_alipay = object.getString("price");
//					String notify_url_alipay = object.getString("notify_url");
					String notify_url_alipay = "http://paycn.boyaa.com/pay_order_alipay.php";
					map.put("porder", orderid_alipay);		//订单号
					map.put("pamount", price_alipay);			//价格 
					map.put("pname", desc_alipay);				//名称
					map.put("udesc", desc_alipay);				//描述
					map.put("pmode", Integer.toString(pmode));				    //支付渠道ID
					map.put("PARTNER", PayContent.PARTNER_ID);				//合作者身份ID，以2088开头由16位纯数字
					map.put("SELLER", PayContent.SELLER);				    //支付宝收款帐号，手机号码或邮箱格式
					map.put("RSA_PRIVATE", PayContent.PRIVATE_RSA_KEY);		//商户方的私钥
					map.put("RSA_ALIPAY_PUBLIC", PayContent.RSA_ALIPAY_PUBLIC);		//支付宝的公钥
					map.put("notify_url", notify_url_alipay);			    //回调地址，接受第三方服务器支付回调，由支付中心提供
					break;
				case 431:
					// 微信支付3.0（43	微信支付3.0（431））
					String appId = Constants.APP_ID;
					String partnerId = Constants.PARTNER_ID;
					String prepayId = object.getString("prepayid");
					String nonceStr = object.getString("noncestr");
					String packageValue  = object.getString("package");
					String sign = object.getString("sign");
					String timeStamp = object.getString("timeStamp");
					map.put("appId", appId);
					map.put("partnerId", partnerId);
					map.put("pmode", pmode);
					map.put("prepayId", prepayId);	
					map.put("nonceStr", nonceStr);
					map.put("timeStamp", timeStamp);
					map.put("packageValue", packageValue);
					map.put("sign", sign);
					map.put("extData", "boyaa chess");
					if(!SendToWXUtil.weixinPay(map)) {
						Game.mActivity.runOnLuaThread(new Runnable() {
							@Override
							public void run() {
								// TODO Auto-generated method stub
								HandMachine.getHandMachine().luaCallEvent(HandMachine.kPayFailed, "");
							}
						});
					}
					return;
				case 198:
					//银联支付（31	银联2.0（198））
					String tn = object.getString("tn");
					map.put("tn", tn);
					map.put("pmode", pmode);					
					break;
			}
			
			JSONObject jsonObj = new JSONObject(map);
			params = jsonObj.toString();
			GodSDKIAP.getInstance().requestPay((Activity)ctx, params, Integer.toString(pmode));
		} catch (JSONException e) {
//			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
//	登陆
	public static void login() {
		GodSDKAccount.getInstance().requestLogin((Activity)ctx);
	}
	
//	登出
	public static void logout() {
		if(GodSDKAccount.getInstance().isSupportLogout())
			GodSDKAccount.getInstance().requestLogout((Activity)ctx);
	}
	
//	切换账号
	public static void switchAccount(){
		if(GodSDKAccount.getInstance().isSupportSwitchAccount())
			GodSDKAccount.getInstance().requestSwitchAccount((Activity)ctx);
	}
	
//	退出游戏
	public static void quit() {
		if(GodSDK.getInstance().isQuitRequired())
			GodSDK.getInstance().quit((Activity)ctx);
	}
	
	private static void initSDK() {
//		SDK事件监听：
		GodSDK.getInstance().setSDKListener(mSDKListner);
//		账户事件监听：
		GodSDKAccount.getInstance().setAccountListener(mAccountListener);
//		支付事件监听：
		GodSDKIAP.getInstance().setIAPListener(mIAPListener);
		
//		true 为打开调试日志输出，false为关闭
		GodSDK.getInstance().setDebugMode(true);
		GodSDKAccount.getInstance().setDebugMode(true);
		GodSDKIAP.getInstance().setDebugMode(true);
		
		
		/*IGodSDKIterator<Integer> 用于设置GodSDK和第三方SDK可用的Activty.startActivityForResult 的请求码的范围，
		 * 需要保证跟游戏现有逻辑或已经接入的SDK的请求码不冲突，并且大于0。返回值b若为true则代表成功初始化GodSDK并且
		 * GodSDK也成功调用完毕所有第三方SDK的初始逻辑（如果第三方SDK初始结果是异步返回的，并不代表第三方SDK成功初始
		 * 化）。若为false，则代表GodSDK在初始化时或者初始化第三方SDK时出现错误。则需要排查生成包的操作或者参数传递的
		 * 操作是否有问题。
		 */

		boolean b = GodSDK.getInstance().initSDK((Activity)ctx, new IGodSDKIterator<Integer>() {
			private int i = 20000;
			private final int end = 20100;
			
			@Override
			public Integer next() {
				i = i + 1;
				return i;
			}
			
			@Override
			public boolean hasNext() {
				if (i < end) {
					return true;
				} else {
					return false;
				}
			}
		});
		if(!b) {
			Log.d(GodSDKTag, GodSDKTag + " SDK初始化失败");
		}
	}
	
	private static void setListener() {
		mSDKListner = new SDKListener(){

			@Override
			public void onInitSuccess(CallbackStatus status) {
				// TODO Auto-generated method stub
				/**
				 * 初始化成功
				 * @param status
				 */
				Log.d(GodSDKTag, GodSDKTag + " SDK初始化成功");
				pmodes = GodSDKIAP.getInstance().getSupportingPmodes();
			}

			@Override
			public void onInitFailed(CallbackStatus status) {
				// TODO Auto-generated method stub
				/**
				 * 初始化失败
				 * @param status
				 */
				Log.d(GodSDKTag, GodSDKTag + " SDK初始化失败 " + status.getMainStatus() + " " + status.getSubStatus() + " " + status.getMsg());
			}

			@Override
			public void onQuitSuccess(CallbackStatus status) {
				// TODO Auto-generated method stub
				/**
				 * 退出成功
				 * @param status
				 */
				Log.d(GodSDKTag, GodSDKTag + " SDK退出成功");
				mShouldDestoryAndKillProcess = true;
				((Activity)ctx).finish();
			}

			@Override
			public void onQuitCancel(CallbackStatus status) {
				// TODO Auto-generated method stub
				/**
				 * 退出失败
				 * @param status
				 */
				Log.d(GodSDKTag, GodSDKTag + " SDK退出失败" + status.getMainStatus() + " " + status.getSubStatus() + " " + status.getMsg());
			}
			
		};
		
		mAccountListener = new AccountListener(){

			@Override
			public void onLoginSuccess(CallbackStatus status, String loginTag) {
				// TODO Auto-generated method stub
				/**
				 * 登录成功
				 * @param status
				 * @param loginTag
				 */
				Log.d(GodSDKTag, GodSDKTag + " 登陆成功");
			}

			@Override
			public void onLoginFailed(CallbackStatus status, String loginTag) {
				// TODO Auto-generated method stub
				/**
				 * 登录失败
				 * @param status
				 * @param loginTag
				 */
				Log.d(GodSDKTag, GodSDKTag + " 登陆失败" + status.getMainStatus() + " " + status.getSubStatus() + " " + status.getMsg());
			}

			@Override
			public void onLogoutSuccess(CallbackStatus status, String loginTag) {
				// TODO Auto-generated method stub
				/**
				 * 由客户端发起的登出成功
				 * @param status
				 * @param loginTag
				 */
				Log.d(GodSDKTag, GodSDKTag + " 登出成功");
			}

			@Override
			public void onLogoutFailed(CallbackStatus status, String loginTag) {
				// TODO Auto-generated method stub
				/**
				 * 由客户端发起的登出失败
				 * @param status
				 * @param loginTag
				 */
				Log.d(GodSDKTag, GodSDKTag + " 登出失败" + status.getMainStatus() + " " + status.getSubStatus() + " " + status.getMsg());
			}

			@Override
			public void onSwitchAccountSuccess(CallbackStatus status,
					String loginTag) {
				// TODO Auto-generated method stub
				/**
				 * 由客户端发起的切换账号成功
				 * @param status
				 * @param loginTag
				 */
				Log.d(GodSDKTag, GodSDKTag + " 切换账号成功");
			}

			@Override
			public void onSwitchAccountFailed(CallbackStatus status,
					String loginTag) {
				// TODO Auto-generated method stub
				/**
				 * 由客户端发起的切换账号失败
				 * @param status
				 * @param loginTag
				 */
				Log.d(GodSDKTag, GodSDKTag + " 切换账号失败" + status.getMainStatus() + " " + status.getSubStatus() + " " + status.getMsg());
			}

			@Override
			public void onSDKLogout(CallbackStatus status, String loginTag) {
				// TODO Auto-generated method stub
				/**
				 * 由第三方SDK发起的登出请求，此处需要游戏自行调用登出，清除登录状态，并执行后续逻辑。
				 * @param status
				 * @param loginTag
				 */
				Log.d(GodSDKTag, GodSDKTag + " 第三方SDK登出请求");
			}

			@Override
			public void onSDKLogoutSuccess(CallbackStatus status,
					String loginTag) {
				// TODO Auto-generated method stub
				/**
				 * 由第三方SDK发起的登出成功
				 * @param status
				 * @param loginTag
				 */
				Log.d(GodSDKTag, GodSDKTag + " 第三方SDK登出成功");
			}

			@Override
			public void onSDKLogoutFailed(CallbackStatus status, String loginTag) {
				// TODO Auto-generated method stub
				/**
				 * 由第三方SDK发起的登出失败
				 * @param status
				 * @param loginTag
				 */
				Log.d(GodSDKTag, GodSDKTag + " 第三方SDK登出失败" + status.getMainStatus() + " " + status.getSubStatus() + " " + status.getMsg());
			}

			@Override
			public void onSDKSwitchAccount(CallbackStatus status,
					String loginTag) {
				// TODO Auto-generated method stub
				/**
				 * 由第三方SDK发起的切换账号请求，此处需要游戏自行调用切换账号，变更游戏内的登录状态，并执行相应逻辑。
				 * @param status
				 * @param loginTag
				 */
				Log.d(GodSDKTag, GodSDKTag + " 第三方SDK切换账号请求");
			}

			@Override
			public void onSDKSwitchAccountSuccess(CallbackStatus status,
					String loginTag) {
				// TODO Auto-generated method stub
				/**
				 * 由第三方SDK发起的切换账号成功
				 * @param status
				 * @param loginTag
				 */
				Log.d(GodSDKTag, GodSDKTag + " 第三方SDK切换成功");
			}

			@Override
			public void onSDKSwitchAccountFailed(CallbackStatus status,
					String loginTag) {
				// TODO Auto-generated method stub
				/**
				 * 由第三方SDK发起的切换账号失败
				 * @param status
				 * @param loginTag
				 */
				Log.d(GodSDKTag, GodSDKTag + " 第三方SDK切换失败" + status.getMainStatus() + " " + status.getSubStatus() + " " + status.getMsg());
			}
			
		};
		
		mIAPListener = new IAPListener(){

			@Override
			public void onPaySuccess(CallbackStatus status, String pmode) {
				// TODO Auto-generated method stub
				/**
				 * 支付成功回调
				 * @param status
				 * @param pmode
				 */
				Log.d(GodSDKTag, GodSDKTag + " 支付成功");
				String str = "操作成功！由于地域问题，发货存在延时，请耐心等待！小提示：若发货不成功，不会产生任何游戏资费（不含信息费）。";
				Toast.makeText(ctx, str, 10000).show();
				Game.mActivity.runOnLuaThread(new Runnable() {
					
					@Override
					public void run() {
						// TODO Auto-generated method stub
						HandMachine.getHandMachine().luaCallEvent(HandMachine.kPaySuccess, "");
					}
				});
			}

			@Override
			public void onPayFailed(CallbackStatus status, String pmode) {
				// TODO Auto-generated method stub
				/**
				 * 支付失败回调
				 * @param status
				 * @param pmode
				 */
				Log.d(GodSDKTag, GodSDKTag + " 支付失败" + status.getMainStatus() + " " + status.getSubStatus() + " " + status.getMsg());
				String str = "操作失败，请稍后再试！";
				Toast.makeText(ctx, str, Toast.LENGTH_LONG).show();
				Game.mActivity.runOnLuaThread(new Runnable() {
					
					@Override
					public void run() {
						// TODO Auto-generated method stub
						HandMachine.getHandMachine().luaCallEvent(HandMachine.kPayFailed, "");
					}
				});
			}
			
		};
	}
	
	public static boolean shouldDestoryAndKillProcess() {
		return mShouldDestoryAndKillProcess;
	}
	
	public static void onNewIntent(Intent intent) {
		ActivityAgent.onNewIntent((Activity)ctx,intent);
	}
	
	public static void onCreate() {
		ActivityAgent.onCreate((Activity)ctx);
	}
	
	public static void onStart() {
		ActivityAgent.onStart((Activity)ctx);
	}
	
	public static void onResume() {
		ActivityAgent.onResume((Activity)ctx);
//		悬浮窗
		if(GodSDKAccount.getInstance().isFloatViewRequired()) {
			GodSDKAccount.getInstance().showFloatView((Activity)ctx);
		}
	}
	
	public static void onRestart() {
		ActivityAgent.onRestart((Activity)ctx);
	}

	public static void onPause() {
		ActivityAgent.onPause((Activity)ctx);
//		悬浮窗
		if(GodSDKAccount.getInstance().isFloatViewRequired()) {
			GodSDKAccount.getInstance().hideFloatView((Activity)ctx);
		}
	}
	
	public static void onStop() {
		ActivityAgent.onStop((Activity)ctx);
	}
	
	public static void onActivityResult(int requestCode, int resultCode, Intent data) {
		ActivityAgent.onActivityResult((Activity)ctx,requestCode,resultCode,data);
	}
	
	public static void onDestroy() {
		ActivityAgent.onDestroy((Activity)ctx);
	}
}
