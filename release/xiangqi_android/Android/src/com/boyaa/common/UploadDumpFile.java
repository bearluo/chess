package com.boyaa.common;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.SocketTimeoutException;
import java.net.URL;
import java.net.URLEncoder;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import org.apache.http.conn.ConnectTimeoutException;

import com.boyaa.common.CommonEvent.Log;
import com.boyaa.made.AppActivity;

import android.content.pm.PackageManager;
import android.webkit.URLUtil;


public class UploadDumpFile implements Runnable{

	public static final String TAG = "UploadDumpFile";
	public static final String CALLBACK = "event_uploadDumpFile_response";
	public static final String RESPONSE = "uploadDumpFile_response";
	public static final int RESPONSE_CODE_SUCCESS = 1001;
	public static final int RESPONSE_CODE_FAILED = 1002;
	public static final int RESPONSE_CODE_HTTP_TIMEOUT = 1003;
	public static final int RESPONSE_CODE_ARG_ERROR = 1004;
	public static final int RESPONSE_CODE_SOCKET_TIMEOUT = 1005;
	public static final int RESPONSE_CODE_BAD_GATEWAY = 1006;
	private static final String kFileSuffix=".zip";
	private static final String kId="id";
	private static final String kCode="code";
	private static final String kAppid="appId";
	private static final String kFilePath="filePath";
	private static final String kUrl="url";
	private static final String kTimeout="timeout";
	private RequestData data;
	private int responseCode = RESPONSE_CODE_FAILED;
	private int mRequestId;
	private String mKey;
	private int count502 = 0;
	
	public int getResult() {
		return responseCode;
	}
	
	public RequestData getData() {
		return data;
	}

	public void uploadDumpFile(){
		mRequestId = AppActivity.dict_get_int(CommonEvent.UPLOAD_DUMPFILE, kId, 0);
		Log.i(TAG, "mRequestId:.." + mRequestId);
		if (mRequestId <= 0) {
			Log.e(TAG, "Error  mReauestId :" + mRequestId);
			return;
		}
		mKey = "dumpfile_request_" + mRequestId;
		data = parseData();
		if (data != null) {
			new Thread(this).start();
		}else {
			callLua();
		}
	}
	
	@Override
	public void run() {
		String filePath = getEndFilePath(data.filePath);
		String zipFilePath = getZipFilePath(filePath);
		//String zipFileName = getZipFileName(filePath);
		String zipResult = zipFile(filePath, zipFilePath);
		if(null == zipResult){
			callLua();
			return;
		}
		upload(zipFilePath, data);
		deleteFile(zipFilePath);
		callLua();
	}
	
	private void upload(String zipPath, RequestData data) {
		HttpURLConnection connection = null;
		DataOutputStream outStream = null;
		int bytesAvailable;
		int bufferSize;
		byte[] buffer;
		int maxBufferSize = 1 * 1024 * 1024;
		int timeout = Integer.valueOf(data.timeout);
		try {
			FileInputStream fStream = new FileInputStream(zipPath);
			PackageManager pm = AppActivity.mActivity.getApplicationContext().getPackageManager(); 
			String pkgName = AppActivity.mActivity.getApplicationContext().getPackageName();
			String version  = pm.getPackageInfo(pkgName, 0).versionName;
			String appName = (String) pm.getApplicationLabel(pm.getApplicationInfo(pkgName, 0));
			appName = URLEncoder.encode(appName, "UTF-8");
			String urlStr = data.url + "?version=" + version +"&appid=" + data.appId +"&project_name=" + appName;
			Log.i(TAG, "请求url:" + urlStr );
			URL url = new URL(urlStr);
			connection = (HttpURLConnection) url.openConnection();
			connection.setConnectTimeout(timeout);
			connection.setReadTimeout(timeout);
			connection.setDoInput(true);
			connection.setDoOutput(true);
			connection.setUseCaches(false);
			connection.setRequestMethod("POST");
			connection.setRequestProperty("Connection", "Keep-Alive");
			outStream = new DataOutputStream(connection.getOutputStream());
			bytesAvailable = fStream.available();
			Log.i(TAG , "文件大小：" + bytesAvailable);
			bufferSize = Math.min(bytesAvailable, maxBufferSize);
			buffer = new byte[bufferSize];
			while (fStream.read(buffer, 0, bufferSize) > 0) {
				outStream.write(buffer, 0, bufferSize);
				bytesAvailable = fStream.available();
				bufferSize = Math.min(bytesAvailable, maxBufferSize);
			}
			fStream.close();
			long startTime = System.nanoTime(); 
			outStream.flush();
			outStream.close();
			Log.i(TAG, "向服务器写数据完成");
			int code = connection.getResponseCode();
			long consumingTime = System.nanoTime() - startTime;
			Log.i(TAG, "上传文件服务器返回 responseCode：" + code + ",耗时：" + consumingTime/1000000 + "ms");
			if (code == HttpURLConnection.HTTP_OK) {
				StringBuilder response = new StringBuilder();
				InputStream inStream = connection.getInputStream();
				BufferedReader bufferedReader = new BufferedReader(
						new InputStreamReader(inStream));
				String line = "";
				while ((line = bufferedReader.readLine()) != null) {
					response.append(line);
				}
				bufferedReader.close();
				inStream.close();
				connection.disconnect();
				Log.i(TAG, "response : " + response);
				if (response.toString().equals("1"))
					responseCode = RESPONSE_CODE_SUCCESS;
			}else if(code == HttpURLConnection.HTTP_BAD_GATEWAY) {
				Log.i(TAG, "520times:" + count502);
				if (count502 == 5){
					responseCode = RESPONSE_CODE_BAD_GATEWAY;
					return;
				}
				count502 += 1;
				upload(zipPath, data);
			}
		} catch (Exception e) {
			Log.e(TAG, e.toString());
			Class<? extends Exception> clazz = e.getClass();
			if (clazz.equals(SocketTimeoutException.class)) {
				responseCode = RESPONSE_CODE_SOCKET_TIMEOUT;
			}
			if (clazz.equals(ConnectTimeoutException.class)) {
				responseCode = RESPONSE_CODE_HTTP_TIMEOUT;
			}
		} 
	}
	
	private String getEndFilePath(String filePath){
		String endFilePathArr[] = filePath.split(","); // 获取最后的dump日志路径
		String endFilePath = endFilePathArr[endFilePathArr.length-1];
		return endFilePath;
	}
	
	private String getZipFilePath(String filePath){
		return getFilePathPrefix(filePath) + kFileSuffix;
	}
	
	private String getFilePathPrefix(String filePath){
		String filePathPrefix = "";
		int lenPrefix = filePath.lastIndexOf(".");
		if (lenPrefix != -1) {
			filePathPrefix = filePath.substring(0, lenPrefix);
		} else {
			Log.i(TAG, "文件名异常 filePath:" + filePath);
		}
		return filePathPrefix;
	}
	
	@SuppressWarnings("unused")
	private String getZipFileName(String filePath){
		String filePath2 = getFilePathPrefix(filePath);
		int fileIndexOf = filePath2.lastIndexOf("/");
		String fileName = "";
		if (fileIndexOf != -1){
			fileName = filePath2.substring(fileIndexOf+1) + kFileSuffix;
		}else {
			Log.i(TAG, "文件名异常 filePath:" + filePath);
		}
		return fileName;
	}
	
	private String zipFile(String filePath ,String zipFilePath) {
		File file = new File(filePath);
		FileInputStream fis;
		try {
			fis = new FileInputStream(file);
			BufferedInputStream bis = new BufferedInputStream(fis);
			byte[] buf = new byte[1024];
			int len;
			FileOutputStream fos = new FileOutputStream(zipFilePath);
			BufferedOutputStream bos = new BufferedOutputStream(fos);
			ZipOutputStream zos = new ZipOutputStream(bos);// 压缩包
			ZipEntry ze = new ZipEntry(file.getName());// 这是压缩包名里的文件名
			zos.putNextEntry(ze);// 写入新的 ZIP 文件条目并将流定位到条目数据的开始处
			while ((len = bis.read(buf)) != -1) {
				zos.write(buf, 0, len);
				zos.flush();
			}
			bis.close();
			zos.close();
		} catch (FileNotFoundException e) {
			Log.i(TAG, e.toString());
			return null;
		} catch (IOException e) {
			Log.i(TAG, e.toString());
			return null;
		}
		return zipFilePath;
	}
	
	private RequestData parseData (){
		RequestData data = new RequestData();
		String url = AppActivity.dict_get_string(mKey, kUrl);
		String filePath = AppActivity.dict_get_string(mKey, kFilePath);
		String timeout = AppActivity.dict_get_string(mKey, kTimeout);
		String appid = AppActivity.dict_get_string(mKey, kAppid);
		if (!URLUtil.isHttpUrl(url) || filePath.length() == 0 || Integer.valueOf(timeout) <= 0 || appid.length() == 0){
			responseCode = RESPONSE_CODE_ARG_ERROR;
			return null;
		}
		data.setUrl(url);
		data.setFilePath(filePath);
		data.setTimeout(timeout);
		data.setAppId(appid);
		//data.setMimeType("application/octet-stream");
		return data;
	}
	
	private void callLua(){
		AppActivity.mActivity.runOnLuaThread(new Runnable()
		{
			@Override
			public void run() {
				Log.i(TAG, "call_lua:" + CALLBACK + "requestID:  " + mRequestId);
				AppActivity.dict_set_int(RESPONSE, kId, mRequestId);
				AppActivity.dict_set_int(mKey, kCode, responseCode);
				AppActivity.call_lua(CALLBACK);
			}
		});
	}
	
	
	private boolean deleteFile(String filePath)
	{
		File file=new File(filePath);
		if(file.exists())
		{
			return file.delete();
		}
		return false;
	}
	
	@SuppressWarnings("unused")
	private final class RequestData {
		private String url;
		private String filePath;
		private String timeout;
		private String appId;
		
		public String getUrl() {
			return url;
		}
		public void setUrl(String url) {
			this.url = url;
		}
		public String getFilePath() {
			return filePath;
		}
		public void setFilePath(String filePath) {
			this.filePath = filePath;
		}
		public String getTimeout() {
			return timeout;
		}
		public void setTimeout(String timeout) {
			this.timeout = timeout;
		}
		public String getAppId() {
			return appId;
		}
		public void setAppId(String appId) {
			this.appId = appId;
		}
	}
}
	
