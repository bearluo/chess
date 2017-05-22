package com.boyaa.until;


import com.boyaa.entity.core.HandMachine;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.provider.Settings;
import android.telephony.PhoneStateListener;
import android.telephony.SignalStrength;
import android.telephony.TelephonyManager;

public class NetworkManager {
	private Context mContext;
	
	public NetworkManager(Context context) {
		this.mContext = context;
		wifiIconLevel = 3;
		bInit = true;
	}	
	
	//==========================监听网络信号变化================================
    private  SinalCallBackInterface sinalCallBack;
    private WifiReceiver rssiReceiver;
    private NetStateReceiver netStateReceiver;
    private ConnectivityManager connectivityManager;
    private MyPhoneStateListener myPhoneStateListener;
    private TelephonyManager Tel;
    private int wifiIconLevel = 0;
    private int gprsIconLevel = 0;
    private boolean bInit = true;
    private class NetStateReceiver extends BroadcastReceiver{
		@Override
		public void onReceive(Context ctx, Intent intent) {
	    	NetworkInfo gprsInfo = connectivityManager.getNetworkInfo(ConnectivityManager.TYPE_MOBILE);
	    	NetworkInfo wifiInfo = connectivityManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI);        	
			if (wifiInfo!=null&&wifiInfo.isConnected()){
				if(sinalCallBack!=null)
					sinalCallBack.onSinalChange(wifiIconLevel);
			}else if(gprsInfo!=null&&gprsInfo.isConnected()){
				if(sinalCallBack!=null)
					sinalCallBack.onSinalChange(gprsIconLevel);
			}else{
				if(sinalCallBack!=null)
					sinalCallBack.onSinalChange(5);
			}
		}
    };

    public void registerSinalListener(SinalCallBackInterface sinalCallBack){
    	unregisterSinalReceiver();
    	this.sinalCallBack = sinalCallBack;
    	connectivityManager = (ConnectivityManager)mContext.getSystemService(Context.CONNECTIVITY_SERVICE);

    	
        //NetState
    	netStateReceiver = new NetStateReceiver();
        IntentFilter filter=new IntentFilter();
        filter.addAction(ConnectivityManager.CONNECTIVITY_ACTION);
        mContext.registerReceiver(netStateReceiver, filter);
        netStateReceiver.onReceive(mContext, null);
        registerSinalReceiver(mContext);     
    }
    
    public void getNetStateSinalLevel(){
    	int netState = getNetState();
    	if(sinalCallBack!=null){
        	if(netState==1){
        		sinalCallBack.onSinalChange(wifiIconLevel);
        	}else if(netState==2){
        		sinalCallBack.onSinalChange(gprsIconLevel);
        	}
    	}
    }
    	
    private void  registerSinalReceiver(Context ctx){
    	NetworkInfo gprsInfo = connectivityManager.getNetworkInfo(ConnectivityManager.TYPE_MOBILE);
    	NetworkInfo wifiInfo = connectivityManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
    	
    	if((gprsInfo == null || !gprsInfo.isConnected()) && 
    	    (wifiInfo == null || !wifiInfo.isConnected())){
			if(sinalCallBack!=null)
				sinalCallBack.onSinalChange(5);
    	}
    	
  		rssiReceiver = new WifiReceiver();	
  		ctx.registerReceiver(rssiReceiver, new IntentFilter(WifiManager.RSSI_CHANGED_ACTION));
        
      	myPhoneStateListener = new MyPhoneStateListener();
        Tel = (TelephonyManager) ctx.getSystemService(Context.TELEPHONY_SERVICE);
        Tel.listen(myPhoneStateListener, PhoneStateListener.LISTEN_SIGNAL_STRENGTHS);
    }
    
    public void unregisterSinalReceiver(){
    	if(netStateReceiver !=null){
    		mContext.unregisterReceiver(netStateReceiver);
    		netStateReceiver = null;
    	}
    	
    	if(rssiReceiver !=null){
    		mContext.unregisterReceiver(rssiReceiver);
    		rssiReceiver = null;
    	}
    	
    	if(myPhoneStateListener != null){
            Tel.listen(myPhoneStateListener, PhoneStateListener.LISTEN_NONE);
            myPhoneStateListener = null;
    	}
    }
    
    /** 开始PhoneState听众 */
    private class MyPhoneStateListener extends PhoneStateListener {
        /** 从得到的信号强度,每个tiome供应商有更新 */
        @Override
        public void onSignalStrengthsChanged(SignalStrength signalStrength) {
            super.onSignalStrengthsChanged(signalStrength);
            
          	int asu=signalStrength.getGsmSignalStrength();
        	gprsIconLevel = getGsmSignalStrength(asu);
        	int netState = getNetState();
            if(netState == 2 && sinalCallBack!=null){
            	sinalCallBack.onSinalChange(gprsIconLevel);
            }
        }
        
        private int getGsmSignalStrength(int asu){
        	int iconLevel = 0;
        	if(asu <= 2) iconLevel = 0;
        	else if(asu>=12) iconLevel = 4;
        	else if(asu>=8) iconLevel = 3;
        	else if(asu>=5) iconLevel = 2;
        	else iconLevel = 1;
        	return iconLevel;
        }
    };
    
    public interface SinalCallBackInterface{
    	void onSinalChange(int level);
    }
    
    private class WifiReceiver extends BroadcastReceiver{

		@Override
		public void onReceive(Context context, Intent intent) {
         	obtainWifiSinalLevel();
		}
    }  
    
    // Wifi的连接信号强度：
    private String obtainWifiSinalLevel() {
        WifiManager wifiManager = (WifiManager) mContext.getSystemService(mContext.WIFI_SERVICE);
        WifiInfo info = wifiManager.getConnectionInfo();
        
  
        if (info.getBSSID() != null) {
            // 链接信号强度
        	wifiIconLevel= WifiManager.calculateSignalLevel(info.getRssi(), 5);
        	if (bInit){
        		bInit = false;
        		if (wifiIconLevel==0){
        			wifiIconLevel = 3;
        		}
        	}
        	int netState = getNetState();

        	if (netState == 1 && sinalCallBack!=null) {
        		sinalCallBack.onSinalChange(wifiIconLevel);
			}  
        }

        return info.toString();
    }
    
    private int getNetState(){
    	int nRe = 0;
    	NetworkInfo gprsInfo = connectivityManager.getNetworkInfo(ConnectivityManager.TYPE_MOBILE);
    	NetworkInfo wifiInfo = connectivityManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
    	if(wifiInfo!=null&&wifiInfo.isConnected())
    	{
    		nRe = 1;
    	}else if(gprsInfo!=null&&gprsInfo.isConnected()){
    		nRe = 2; 
    	}
    	
    	return nRe;
    }

	//跳转到设置无线网络设置界面
	public void StartWirelessSetting(){
		try {
	    	Intent intent = new Intent("/");
	    	ComponentName cm = new ComponentName("com.android.settings","com.android.settings.WirelessSettings");
	    	intent.setComponent(cm);
	    	intent.setAction("android.intent.action.VIEW");
	    	((Activity) mContext).startActivityForResult(intent , 0);  
		} catch (Exception e) {
			e.printStackTrace();
			try {
		        Intent intent=new Intent(Settings.ACTION_SETTINGS);
		        ComponentName cName = new ComponentName("com.android.phone","com.android.phone.Settings");
		        intent.setComponent(cName);
		        mContext.startActivity(intent);
			} catch (Exception e2) {
				e.printStackTrace();
				HandMachine.getHandMachine().luaCallEvent(HandMachine.kStartWirelessSetting , 1+"");
			}

		}
	}
	
}