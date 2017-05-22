package com.boyaa.until;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.RandomAccessFile;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;

import junit.framework.Assert;
import android.annotation.TargetApi;
import android.content.ClipData;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.BitmapFactory;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.telephony.TelephonyManager;
import android.widget.Toast;

import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.entity.common.Log;
import com.boyaa.made.AppActivity;

public class Util {
	
	private static final String TAG = "Util";
	
	public static byte[] bmpToByteArray(final Bitmap bmp, final boolean needRecycle) {
		ByteArrayOutputStream output = new ByteArrayOutputStream();
		bmp.compress(CompressFormat.PNG, 100, output);
		if (needRecycle) {
			bmp.recycle();
		}
		
		byte[] result = output.toByteArray();
		try {
			output.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return result;
	}
	
	public static byte[] getHtmlByteArray(final String url) {
		 URL htmlUrl = null;     
		 InputStream inStream = null;     
		 try {         
			 htmlUrl = new URL(url);         
			 URLConnection connection = htmlUrl.openConnection();         
			 HttpURLConnection httpConnection = (HttpURLConnection)connection;         
			 int responseCode = httpConnection.getResponseCode();         
			 if(responseCode == HttpURLConnection.HTTP_OK){             
				 inStream = httpConnection.getInputStream();         
			  }     
			 } catch (MalformedURLException e) {               
				 e.printStackTrace();     
			 } catch (IOException e) {              
				e.printStackTrace();    
		  } 
		byte[] data = inputStreamToByte(inStream);

		return data;
	}
	
	public static byte[] inputStreamToByte(InputStream is) {
		try{
			ByteArrayOutputStream bytestream = new ByteArrayOutputStream();
			int ch;
			while ((ch = is.read()) != -1) {
				bytestream.write(ch);
			}
			byte imgdata[] = bytestream.toByteArray();
			bytestream.close();
			return imgdata;
		}catch(Exception e){
			e.printStackTrace();
		}
		
		return null;
	}
	
	public static byte[] readFromFile(String fileName, int offset, int len) {
		if (fileName == null) {
			return null;
		}

		File file = new File(fileName);
		if (!file.exists()) {
			Log.i(TAG, "readFromFile: file not found");
			return null;
		}

		if (len == -1) {
			len = (int) file.length();
		}

		Log.d(TAG, "readFromFile : offset = " + offset + " len = " + len + " offset + len = " + (offset + len));

		if(offset <0){
			Log.e(TAG, "readFromFile invalid offset:" + offset);
			return null;
		}
		if(len <=0 ){
			Log.e(TAG, "readFromFile invalid len:" + len);
			return null;
		}
		if(offset + len > (int) file.length()){
			Log.e(TAG, "readFromFile invalid file len:" + file.length());
			return null;
		}

		byte[] b = null;
		try {
			RandomAccessFile in = new RandomAccessFile(fileName, "r");
			b = new byte[len]; // 创建合适文件大小的数组
			in.seek(offset);
			in.readFully(b);
			in.close();

		} catch (Exception e) {
			Log.e(TAG, "readFromFile : errMsg = " + e.getMessage());
			e.printStackTrace();
		}
		return b;
	}
	
	private static final int MAX_DECODE_PICTURE_SIZE = 1920 * 1440;
	public static Bitmap extractThumbNail(final String path, final int height, final int width, final boolean crop) {
		Assert.assertTrue(path != null && !path.equals("") && height > 0 && width > 0);
	
		BitmapFactory.Options options = new BitmapFactory.Options();

		try {
			options.inJustDecodeBounds = true;
			Bitmap tmp = BitmapFactory.decodeFile(path, options);
			if (tmp != null) {
				tmp.recycle();
				tmp = null;
			}

			Log.d(TAG, "extractThumbNail: round=" + width + "x" + height + ", crop=" + crop);
			final double beY = options.outHeight * 1.0 / height;
			final double beX = options.outWidth * 1.0 / width;
			Log.d(TAG, "extractThumbNail: extract beX = " + beX + ", beY = " + beY);
			options.inSampleSize = (int) (crop ? (beY > beX ? beX : beY) : (beY < beX ? beX : beY));
			if (options.inSampleSize <= 1) {
				options.inSampleSize = 1;
			}

			// NOTE: out of memory error
			while (options.outHeight * options.outWidth / options.inSampleSize > MAX_DECODE_PICTURE_SIZE) {
				options.inSampleSize++;
			}

			int newHeight = height;
			int newWidth = width;
			if (crop) {
				if (beY > beX) {
					newHeight = (int) (newWidth * 1.0 * options.outHeight / options.outWidth);
				} else {
					newWidth = (int) (newHeight * 1.0 * options.outWidth / options.outHeight);
				}
			} else {
				if (beY < beX) {
					newHeight = (int) (newWidth * 1.0 * options.outHeight / options.outWidth);
				} else {
					newWidth = (int) (newHeight * 1.0 * options.outWidth / options.outHeight);
				}
			}

			options.inJustDecodeBounds = false;

			Log.i(TAG, "bitmap required size=" + newWidth + "x" + newHeight + ", orig=" + options.outWidth + "x" + options.outHeight + ", sample=" + options.inSampleSize);
			Bitmap bm = BitmapFactory.decodeFile(path, options);
			if (bm == null) {
				Log.e(TAG, "bitmap decode failed");
				return null;
			}

			Log.i(TAG, "bitmap decoded size=" + bm.getWidth() + "x" + bm.getHeight());
			final Bitmap scale = Bitmap.createScaledBitmap(bm, newWidth, newHeight, true);
			if (scale != null) {
				bm.recycle();
				bm = scale;
			}

			if (crop) {
				final Bitmap cropped = Bitmap.createBitmap(bm, (bm.getWidth() - width) >> 1, (bm.getHeight() - height) >> 1, width, height);
				if (cropped == null) {
					return bm;
				}

				bm.recycle();
				bm = cropped;
				Log.i(TAG, "bitmap croped size=" + bm.getWidth() + "x" + bm.getHeight());
			}
			return bm;

		} catch (final OutOfMemoryError e) {
			Log.e(TAG, "decode bitmap failed: " + e.getMessage());
			options = null;
		}

		return null;
	}
	
	public static boolean isNetworkConnected(Context context) {  
	    if (context != null) {  
	        ConnectivityManager mConnectivityManager = (ConnectivityManager) context  
	                .getSystemService(Context.CONNECTIVITY_SERVICE);  
	        NetworkInfo mNetworkInfo = mConnectivityManager.getActiveNetworkInfo();  
	        if (mNetworkInfo != null) {  
	            return mNetworkInfo.isAvailable();  
	        }  
	    }  
	    return false;  
	}
	
	/**
	 * 获得imei，如果无法获得会返回wifi mac。如果都没有，返回"" 
	 */
	public static String getMachineId() {
		String imei = null;
		TelephonyManager telephonyManager = (TelephonyManager)Game.mActivity
				.getApplication().getSystemService(Context.TELEPHONY_SERVICE);
		if (telephonyManager != null) {
			imei = telephonyManager.getDeviceId();
		}
		if (imei == null) {
			WifiManager mgr = (WifiManager) Game.mActivity.getApplication()
					.getSystemService(Context.WIFI_SERVICE);
			if (mgr != null) {
				WifiInfo wifiinfo = mgr.getConnectionInfo();
				if (wifiinfo != null) {
					imei = wifiinfo.getMacAddress();
				}
			}
		}
		if (imei == null) {
			imei = "";
		}
		return imei;
	}
	public static String getImeiNum() {
		String imei = null;
		TelephonyManager telephonyManager = (TelephonyManager)Game.mActivity
				.getApplication().getSystemService(Context.TELEPHONY_SERVICE);
		if (telephonyManager != null) {
			imei = telephonyManager.getDeviceId();
		}
		if (imei == null) {
			imei = "";
		}
		return imei;
	}
	public static String getMacAddr() {
		String Mac = null;
		WifiManager mgr = (WifiManager) Game.mActivity.getApplication()
				.getSystemService(Context.WIFI_SERVICE);
		if (mgr != null) {
			WifiInfo wifiinfo = mgr.getConnectionInfo();
			if (wifiinfo != null) {
				Mac = wifiinfo.getMacAddress();
			}
		}
		if (Mac == null) {
			Mac = "";
		}
		return Mac;
	}
	
	public static String getIpAddr(){
        WifiManager mgr = (WifiManager) Game.mActivity.getApplication()
        		.getSystemService(Context.WIFI_SERVICE);  
        if (!mgr.isWifiEnabled()) {
        	return "";
//        	mgr.setWifiEnabled(true);    
        }  
        WifiInfo wifiInfo = mgr.getConnectionInfo();       
        int ipAddress = wifiInfo.getIpAddress();   
        String ip = intToIp(ipAddress);   
        return ip;
    }     
    private static String intToIp(int i) {       
         
		return  (i & 0xFF) + "." +       
			    ((i >> 8 ) & 0xFF) + "." +       
			    ((i >> 16) & 0xFF) + "." +       
			    ((i >> 24) & 0xFF);  
	}
    /*
     * 剪切板功能
     */
    @TargetApi(Build.VERSION_CODES.HONEYCOMB) public static void copyStr(String str, Context context){
    	if (str != null){
			if(getSDKVersionNumber() < 11){
	            android.text.ClipboardManager clipboardManager = (android.text.ClipboardManager)Game.mActivity.getSystemService(Context.CLIPBOARD_SERVICE);  
	            clipboardManager.setText(str.trim());  	           
	        }else{
	            // 得到剪贴板管理器
	            android.content.ClipboardManager clipboardManager = (android.content.ClipboardManager)Game.mActivity.getSystemService(Context.CLIPBOARD_SERVICE);  
	            clipboardManager.setPrimaryClip(ClipData.newPlainText(null,str.replace("\"", "")));
	        }
			Toast.makeText(Game.mActivity, "已复制到粘贴板", Toast.LENGTH_LONG).show();
		}else{
			Toast.makeText(Game.mActivity, "复制失败", Toast.LENGTH_LONG).show();
		}
    	
    }
	/**
     * 获取手机操作系统版本
     */
    public static int getSDKVersionNumber() {  
        int sdkVersion;  
        try {  
            sdkVersion = Integer.valueOf(android.os.Build.VERSION.SDK);  
        } catch (NumberFormatException e) {  
            sdkVersion = 0;  
        }  
        return sdkVersion;  
    } 
    /**
     * 检测是否有手机卡
     */
	public static boolean checkoutSimCard(){
		SIMCardInfo cardInfo = new SIMCardInfo(
				AppActivity.mActivity);
		int state = SIMCardInfo.NO_SIMCARD;
		state = cardInfo.resdSIM();
		if(state == SIMCardInfo.NO_SIMCARD){
			Game.mActivity.runOnUiThread(new Runnable() {
				@Override
				public void run() {
					String str = "请确认是否已插入sim卡";
					Toast.makeText(Game.mActivity, str, Toast.LENGTH_LONG).show();
				}
			});
			return false;
		}
		return true;
	}
}
