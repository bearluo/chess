package com.boyaa.until;

import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.made.AppActivity;

import android.content.Context;
import android.content.res.Configuration;
import android.telephony.TelephonyManager;
import android.widget.Toast;

public class SIMCardInfo {
	private TelephonyManager telephonyManager;
	public static final int NO_SIMCARD= 0;//no card	
	public static final int HAVE_SIMCARD= -1;// card	
	public static final int CHINA_MOBILE = 1; //移动
	public static final int CHINA_UNICOM = 2;//联通 
	public static final int CHINA_TELECOM = 3;//电信
	public static final int CHINA_TIETONG= 4;//中国铁通


	 /** 
	   * 国际移动用户识别码 
	 */  
	private String IMSI;
	private ImsiUtil imsiUtil;
	
	/** 
	 * TelephonyManager提供设备上获取通讯服务信息的入口。 应用程序可以使用这个类方法确定的电信服务商和国家 以及某些类型的用户访问信息。 
	 * 应用程序也可以注册一个监听器到电话收状态的变化。不需要直接实例化这个类 
	 * 使用Context.getSystemService(Context.TELEPHONY_SERVICE)来获取这个类的实例。 
	 */ 
	public SIMCardInfo(Context ctx){
		telephonyManager = (TelephonyManager) ctx.getSystemService(Context.TELEPHONY_SERVICE);
		imsiUtil = new ImsiUtil(ctx);
	}
	

	public String getNativePhoneNumber(){
		String telNumber = null;
		if(telephonyManager!=null){
			telNumber = telephonyManager.getLine1Number();
		}
		return telNumber;
	}
	
	public int  getProvidersType(){     
		int ProvidersType = NO_SIMCARD;

		// 返回唯一的用户ID;就是这张卡的编号神马的  
		IMSI = telephonyManager.getSubscriberId(); 
		//中国移动系统使用00、02、07，中国联通GSM系统使用01、06，中国电信CDMA系统使用03、05，中国铁通系统使用20，
		// IMSI号前面3位460是国家，紧接着后面2位00 02是中国移动，01是中国联通，03是中国电信。      
		if( IMSI == null ) {
			ProvidersType = getProvidersType2();
			if( ProvidersType != NO_SIMCARD ) return ProvidersType;
			IMSInfo imsInfo = imsiUtil.getIMSInfo();
			if ( imsInfo != null ) {
				IMSI = imsInfo.imsi_1 == null ? imsInfo.imsi_1 : imsInfo.imsi_2;
			}
		}
		
		if (IMSI!=null){
			if (IMSI.startsWith("46000") || IMSI.startsWith("46002") || IMSI.startsWith("46007")) { 
				ProvidersType = CHINA_MOBILE;
			} else if (IMSI.startsWith("46001") || IMSI.startsWith("46006")) {
				ProvidersType = CHINA_UNICOM;
			} else if (IMSI.startsWith("46003") || IMSI.startsWith("46005") || IMSI.startsWith("46011") || IMSI.startsWith("46020")) {
				ProvidersType = CHINA_TELECOM;
			}
		}else{
			ProvidersType = NO_SIMCARD;
		}
		return ProvidersType;  
	}
	
	public int getProvidersType2(){     
		int ProvidersType = NO_SIMCARD;

		// 返回唯一的用户ID;就是这张卡的编号神马的  
		String operator = telephonyManager.getSimOperator(); 
		//中国移动系统使用00、02、07，中国联通GSM系统使用01、06，中国电信CDMA系统使用03、05，中国铁通系统使用20，
		// IMSI号前面3位460是国家，紧接着后面2位00 02是中国移动，01是中国联通，03是中国电信。      
		if (operator != null) {
			if (operator.equals("46000") || operator.equals("46002")
					|| operator.equals("46007")) { // 中国移动
				ProvidersType = CHINA_MOBILE;
			} else if (operator.equals("46001")|| operator.equals("46006")) { // 中国联通
				ProvidersType = CHINA_UNICOM;
			} else if (operator.equals("46003")|| operator.equals("46005")|| operator.equals("46011")|| operator.equals("46020")) { // 中国电信
				ProvidersType = CHINA_TELECOM;
			}
		}else{
			ProvidersType = NO_SIMCARD;
		}
		return ProvidersType;  
	}
	
	public int resdSIM(){
	     //取得相关服务  
		int cardState = NO_SIMCARD;
	     StringBuffer sb = new StringBuffer();
	     switch(telephonyManager.getSimState()){
	     case TelephonyManager.SIM_STATE_ABSENT: //无卡
	    	 cardState = NO_SIMCARD;
	           sb.append("无卡");
	      break;
	     case TelephonyManager.SIM_STATE_UNKNOWN: //未知状态
	    	 cardState = NO_SIMCARD;
	           sb.append("未知状态");
	      break;
	     case TelephonyManager.SIM_STATE_NETWORK_LOCKED: //需要networkpin解锁
	    	 cardState = NO_SIMCARD;
	           sb.append("需要networkpin解锁");
	      break;
	     case TelephonyManager.SIM_STATE_PIN_REQUIRED: // 需要pin解锁
	    	 cardState = NO_SIMCARD;
	           sb.append("需要pin解锁");
	      break;
	     case TelephonyManager.SIM_STATE_PUK_REQUIRED: //需要puk解锁
	    	 cardState = NO_SIMCARD;
	           sb.append("需要puk解锁");
	      break;
	     case TelephonyManager.SIM_STATE_READY: //良好
	    	 cardState = HAVE_SIMCARD;
	           sb.append("良好");
	      break;
	     }
		return cardState;
	}

}
