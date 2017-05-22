package com.boyaa.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HashMap;
import java.util.Map;

import org.json.JSONException;
import org.json.JSONObject;

import android.util.Log;

import com.boyaa.made.AppActivity;

/**
 * MD5验证工具
 * 
 */
public class MD5Util {
	private final static String KEventResponse = "event_verify_md5";
	private final static String kstrDictName = "verifyMD5";
	private final static String kfilePath = "filePath";
	private final static String kfilePathCallback = "filePathCallback";
	private final static String kmd5 = "MD5";
	private final static String kResult = "result";//flag of finish status
	private final static int kResultSame = 1;//验证相同
	private final static int kResultDifference = -1;//验证不同或失败
	
	private static char hexDigits[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
	private static MessageDigest messagedigest = null;
	private static int result;
	static {
		try {
			messagedigest = MessageDigest.getInstance("MD5");
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
		}
	}
	
	/**
	 * 验证lua传的文件和md5
	 */
	public static void startVerify(){
		final String filePath = AppActivity.dict_get_string(kstrDictName, kfilePath);
		String MD5 = AppActivity.dict_get_string(kstrDictName, kmd5);
	
		if(verify(filePath, MD5)){
			result = kResultSame;
		}else{
			result = kResultDifference;
		}
		AppActivity.mActivity.runOnLuaThread(new Runnable()
		{
			@Override
			public void run() {
				AppActivity.dict_set_int(kstrDictName, kResult, result);
				AppActivity.dict_set_string(kstrDictName, kfilePathCallback, filePath);
				AppActivity.call_lua(KEventResponse);
			}
		});;
	}
	
	/**
	 * 验证文件和md5
	 * @param filepath
	 * @param md5
	 */
	public static boolean verify(String filepath, String md5) {
		try {
			File file = new File(filepath);
			if(!file.exists()){
				Log.i("verify","verify 校验失败(文件不存在)");
				return false;
			}
			String md5Now = getFileMD5String(file);
			if (md5Now.equals(md5)) {
				Log.i("verify","verify 校验成功");
				return true;
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		Log.i("verify","verify 校验失败");
		return false;
	}
	
	private static String getFileMD5String(File file) throws IOException {
		InputStream fis;
		fis = new FileInputStream(file);
		byte[] buffer = new byte[1024];
		int numRead = 0;
		while ((numRead = fis.read(buffer)) > 0) {
			messagedigest.update(buffer, 0, numRead);
		}
		fis.close();
		return bufferToHex(messagedigest.digest());
	}
	
	private static String bufferToHex(byte bytes[]) {
		return bufferToHex(bytes, 0, bytes.length);
	}
	
	private static String bufferToHex(byte bytes[], int m, int n) {
		StringBuffer stringbuffer = new StringBuffer(2 * n);
		int k = m + n;
		for (int l = m; l < k; l++) {
			appendHexPair(bytes[l], stringbuffer);
		}
		return stringbuffer.toString();
	}
	
	private static void appendHexPair(byte bt, StringBuffer stringbuffer) {
		char c0 = hexDigits[(bt & 0xf0) >> 4];// 取字节中高 4 位的数字转换
		// 为逻辑右移，将符号位一起右移,此处未发现两种符号有何不同
		char c1 = hexDigits[bt & 0xf];// 取字节中低 4 位的数字转换
		stringbuffer.append(c0);
		stringbuffer.append(c1);
	}
}