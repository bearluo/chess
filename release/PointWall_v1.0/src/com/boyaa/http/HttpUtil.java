package com.boyaa.http;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.HttpVersion;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.utils.URLEncodedUtils;
import org.apache.http.entity.mime.HttpMultipartMode;
import org.apache.http.entity.mime.MultipartEntity;
import org.apache.http.entity.mime.content.FileBody;
import org.apache.http.entity.mime.content.StringBody;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.CoreProtocolPNames;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.params.HttpParams;
import org.apache.http.protocol.HTTP;

import android.util.Log;

import com.boyaa.common.NetworkUtil;

public class HttpUtil {
	private static final int CONNECTION_TIMEOUT = 15000;//连接数据超时
	private static final int SO_TIMEOUT = 30000;//等待获取数据超时
	
	public static HttpResult post(String url, Map<String, String> paramMap) {
		return post(url, paramMap, false);
	}

	public static HttpResult post(String url, Map<String, String> paramMap, boolean needGZip) {
		Log.e("CHECK", "HttpResult.post url = " + url);
		HttpResult httpResult = new HttpResult();
		if (!NetworkUtil.isNetworkAvailable()) {
			httpResult.status = HttpResult.NETWORK_UNAVAILABLE;
			return httpResult;
		}

		ArrayList<BasicNameValuePair> params = new ArrayList<BasicNameValuePair>();
		String param = "";
		if (paramMap != null) {
			for (String key : paramMap.keySet()) {
				params.add(new BasicNameValuePair(key, paramMap.get(key)));		
				param = param + key + "=" + paramMap.get(key) + "&";
			}
		}
		param = param.substring(0, param.length() - 1);
		HttpClient httpClient = createHttpClient();
		Log.e("CHECK", "HttpResult.post param = " + param);
		InputStream is = null;
		try {
			HttpPost postMethod = new HttpPost(url);
			postMethod.setEntity(new UrlEncodedFormEntity(params,HTTP.UTF_8));
			HttpResponse response = httpClient.execute(postMethod);
			if (response != null) {				
				if (response.getStatusLine().getStatusCode() == HttpStatus.SC_OK) {
					if (needGZip) {
//						debugGZipFile(response.getEntity().getContent());
						is = new java.util.zip.GZIPInputStream(response.getEntity().getContent());
					} else {
//						debugGZipFile(response.getEntity().getContent());
						is = response.getEntity().getContent();
					}
					if (is != null) {
//						int length = (int)response.getEntity().getContentLength();
						httpResult.result = getByteArray(is);
					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (is != null) {
				try {
					is.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
		return httpResult;
	}

	
	public static HttpResult post(String url, List<BasicNameValuePair> params, boolean needGZip) {
		Log.e("CHECK", "HttpResult.post url = " + url);
		HttpResult httpResult = new HttpResult();
		if (!NetworkUtil.isNetworkAvailable()) {
			httpResult.status = HttpResult.NETWORK_UNAVAILABLE;
			return httpResult;
		}

		HttpClient httpClient = createHttpClient();
		InputStream is = null;
		try {
			HttpPost postMethod = new HttpPost(url);
			postMethod.setEntity(new UrlEncodedFormEntity(params,HTTP.UTF_8));
			HttpResponse response = httpClient.execute(postMethod);
			if (response != null) {				
				if (response.getStatusLine().getStatusCode() == HttpStatus.SC_OK) {
					if (needGZip) {
//						debugGZipFile(response.getEntity().getContent());
						is = new java.util.zip.GZIPInputStream(response.getEntity().getContent());
					} else {
//						debugGZipFile(response.getEntity().getContent());
						is = response.getEntity().getContent();
					}
					if (is != null) {
//						int length = (int)response.getEntity().getContentLength();
						httpResult.result = getByteArray(is);
					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (is != null) {
				try {
					is.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
		return httpResult;
	}
	
	
	
	
	public static HttpResult get(String url,Map<String, String> paramMap) {
		Log.e("CHECK", "HttpResult.get url = " + url);	
		HttpResult httpResult = new HttpResult();
		if (!NetworkUtil.isNetworkAvailable()) {
			httpResult.status = HttpResult.NETWORK_UNAVAILABLE;
			return httpResult;
		}
		
		ArrayList<BasicNameValuePair> params = new ArrayList<BasicNameValuePair>();
		if (paramMap != null) {
			for (String key : paramMap.keySet()) {
				params.add(new BasicNameValuePair(key, paramMap.get(key)));		
			}
		}
		url = url + URLEncodedUtils.format(params, HTTP.UTF_8);
		Log.e("CHECK", "HttpResult.get param = " + url);	
		HttpClient httpClient = createHttpClient();
		InputStream is = null;
		try {
			HttpGet getMethod = new HttpGet(url);
			HttpResponse response = httpClient.execute(getMethod);
			if (response != null) {				
				if (response.getStatusLine().getStatusCode() == HttpStatus.SC_OK) {
					is = response.getEntity().getContent();
					if (is != null) {
//						int length = (int)response.getEntity().getContentLength();
						httpResult.result = getByteArray(is);
					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (is != null) {
				try {
					is.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
		return httpResult;
	}
	
	public static HttpResult get(String url) {
		HttpResult httpResult = new HttpResult();
		if (!NetworkUtil.isNetworkAvailable()) {
			httpResult.status = HttpResult.NETWORK_UNAVAILABLE;
			return httpResult;
		}

		HttpClient httpClient = createHttpClient();
		InputStream is = null;
		try {
			HttpGet getMethod = new HttpGet(url);
			HttpResponse response = httpClient.execute(getMethod);
			if (response != null) {				
				if (response.getStatusLine().getStatusCode() == HttpStatus.SC_OK) {
					
					
					
					
					is = response.getEntity().getContent();
					if (is != null) {
//						int length = (int)response.getEntity().getContentLength();
						httpResult.result = getByteArray(is);
					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (is != null) {
				try {
					is.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
		return httpResult;
	}
	
	private static HttpClient createHttpClient() {
		HttpParams httpParameters = new BasicHttpParams();
		HttpConnectionParams.setConnectionTimeout(httpParameters, CONNECTION_TIMEOUT);
		HttpConnectionParams.setSoTimeout(httpParameters, SO_TIMEOUT);
		HttpClient httpClient = new DefaultHttpClient(httpParameters);
		return httpClient;
	}

	private static byte[] getByteArray(InputStream is) throws IOException {
		ByteArrayOutputStream byteOutputStream = new ByteArrayOutputStream();
		byte[] data = new byte[10240];
		for (int count=is.read(data); count!=-1; count=is.read(data)) {
			byteOutputStream.write(data, 0, count);
		}
        byte[] byteArray = byteOutputStream.toByteArray();
        byteOutputStream.close();
        return byteArray;
	}

//	/** 将输入流中的数据读出，并以字符串返回 */
//	private String parseContent(InputStream is) throws IOException {
//		StringBuilder sb = new StringBuilder();
//		BufferedReader reader = new BufferedReader(new InputStreamReader(is));
//		for (String s = reader.readLine(); s != null; s = reader.readLine()) {
//			sb.append(s);
//		}
//		return sb.toString();
//	}
	
	public static HttpResult uploadFile(String pathToOurFile,String urlServer,String filefield,Map<String, String> param) {
		      HttpResult httpResult = new HttpResult();
		      if (!NetworkUtil.isNetworkAvailable()) {
			     httpResult.status = HttpResult.NETWORK_UNAVAILABLE;
			     return httpResult;
		      }
		      HttpClient httpclient = new DefaultHttpClient();
		      InputStream is = null;
		      //设置通信协议版本
		
		     httpclient.getParams().setParameter(CoreProtocolPNames.PROTOCOL_VERSION, HttpVersion.HTTP_1_1);
		     HttpPost httppost = new HttpPost(urlServer);

		     MultipartEntity mpEntity = new MultipartEntity(HttpMultipartMode.BROWSER_COMPATIBLE); //文件传输
		     File file = new File(pathToOurFile);
		     if (!file.exists()) {
		    	 Log.e("CDH", "头像文件不存在，"+pathToOurFile);
		     }
		     mpEntity.addPart(filefield, new FileBody(file));   
		     Set<String> keys = param.keySet();
			try {
				for (String key:keys) {
					mpEntity.addPart(key, new StringBody(param.get(key)));
				}
				httppost.setEntity(mpEntity);
				HttpResponse response;
				response = httpclient.execute(httppost);
				if (response != null) {				
					if (response.getStatusLine().getStatusCode() == HttpStatus.SC_OK) {
						is = response.getEntity().getContent();
						if (is != null) {
							httpResult.result = getByteArray(is);
						}
					}
				}
			} catch (ClientProtocolException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			} catch (IOException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			} finally {
				 httpclient.getConnectionManager().shutdown();
			    
			}
			return httpResult;
		      
		     
		    }

//	private static void debugGZipFile(InputStream in) {
//		FileUtil.createDirectoryIfNotExist(Environment.getExternalStorageDirectory()+"/.boyaa/hall/");
//		try {
//			FileOutputStream fos = new FileOutputStream(Environment.getExternalStorageDirectory()+"/.boyaa/hall/test_file.xml");
//			Log.e("CDH", "available:"+in.available());
//			byte[] buffer = new byte[1024];
//			while(in.read(buffer) != -1) {				
//				fos.write(buffer);
//			}
//			fos.flush();
//			fos.close();
//		} catch (IOException e) {
//			e.printStackTrace();
//		}
//	}
}
