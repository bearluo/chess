package com.boyaa.entity.php;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;

import com.boyaa.entity.common.APNUtil;
import com.boyaa.made.AppActivity;

// 还需要加入超时、还需要加入exception的记录
public class PHPPost {

	/**
	 * 向服务器发送PHP请求
	 * 
	 * @param method
	 *            方法名
	 * @param param
	 *            参数
	 * @param timeout
	 *            连接及数据读取超时间（单位：毫秒）
	 * @return
	 */

	private static int countTry502 = 0;
	private static int countTryOther = 0;
	public static Bitmap loadPic(String uri) {
		countTry502 = 0;
		countTryOther = 0;
		return httpGetPic(uri, 1);
	}

	public static Bitmap httpGetPic(String uri, int try502) {
		if (uri == null || 0 == uri.length())
			return null;
		if (countTry502 > 3 || countTryOther > 3)
			return null;
		Bitmap bitmap = null;
		URL url = null;
		URLConnection connection = null;
		HttpURLConnection httpConnection = null;
		InputStream in = null;
		Context context = AppActivity.mActivity;
		boolean hasProxy = APNUtil.hasProxy(context);
		try {
			if (hasProxy) {
				String proxyIP = APNUtil.getApnProxy(context);
				String proxyPort = APNUtil.getApnPort(context);
				String host = null;
				String path = null;
				final int hostIndex = "http://".length();
				int pathIndex = uri.indexOf('/', hostIndex);
				if (pathIndex < 0) {
					host = uri.substring(hostIndex);
					path = "";
				} else {
					host = uri.substring(hostIndex, pathIndex);
					path = uri.substring(pathIndex);
				}
				String newUri = "http://" + proxyIP + ":" + proxyPort + path;
				url = new URL(newUri);
				connection = (HttpURLConnection) url.openConnection();
				connection.setRequestProperty("X-Online-Host", host);

			} else {
				url = new URL(uri);
				connection = url.openConnection();
			}
			httpConnection = (HttpURLConnection) connection;
			if (try502 != 2)
			{
				httpConnection.setDoOutput(true);
				httpConnection.setDoInput(true);
				httpConnection.setUseCaches(false);
				httpConnection.setAllowUserInteraction(false);
				httpConnection.setRequestMethod("GET");
			}
			httpConnection.connect();

			int responseCode = httpConnection.getResponseCode();
			if (responseCode == HttpURLConnection.HTTP_OK) {
				Log.e("PHPPost", "111 responseCode=" + responseCode + " url=" + uri);
				in = httpConnection.getInputStream();
				ByteArrayOutputStream outstream = new ByteArrayOutputStream();
				byte[] buffer = new byte[512];
				int len = -1;
				while ((len = in.read(buffer)) != -1) {
					outstream.write(buffer, 0, len);
				}
				byte[] data = outstream.toByteArray();
				outstream.close();
				in.close();
				bitmap = BitmapFactory.decodeByteArray(data, 0, data.length);
			} else {
				Log.e("PHPPost", "responseCode=" + responseCode + " url=" + uri);
				Log.e("PHPPost", "responseCode=" + responseCode + " header=" + httpConnection.getHeaderFields());
				if (502 == responseCode && 1 == try502) {
					countTry502 += 1;
					return httpGetPic(uri, 0);
				}else{
					countTryOther += 1;
					return httpGetPic(uri, 2);
				}
			}
		} catch (Exception e) {
			Log.e("PHPPost", e.toString());
			Log.e("PHPPost", uri);
			return bitmap;
		} finally {
			if (null != httpConnection) {
				httpConnection.disconnect();
				httpConnection = null;
			}
		}
		return bitmap;
	}


}
