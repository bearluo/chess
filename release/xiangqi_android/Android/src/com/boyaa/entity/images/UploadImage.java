package com.boyaa.entity.images;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.sql.Date;
import java.text.SimpleDateFormat;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Matrix;
import android.net.Uri;
import android.util.Log;

import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.entity.common.OnThreadTask;
import com.boyaa.entity.common.ThreadTask;
import com.boyaa.entity.core.HandMachine;
import com.boyaa.entity.php.PHPResult;



public class UploadImage {

	public  static final String METHOD_VISITOR_UPLOADICON = "IconAndroid.upload";
	private static final String TAG = "UserManager";
	public  static final int SEX_MAIL = 0;
	public  static final int SEX_FEMAIL = 1;
	public  static final int SEX_SECRET = 2;
	static  final int CAMERA_WITH_DATA = 0; // 拍照
	static  final int PHOTO_PICKED_WITH_DATA = 1; // gallery
	private static final int IMG_SIZE = 300;

	/**
	 * 上传游客头像,完成之后，phpinfo中的icon,big,middle信息会更新，请做相应处理
	 * 
	 * @param filePath
	 * @return
	 */
	@SuppressWarnings("rawtypes")
	public static boolean uploadVisitorIcon(String filePath,  String surl , String api , PHPResult result, boolean isUploadFBimg) {
		HttpURLConnection connection = null;
		DataOutputStream outStream = null;

		String lineEnd = "\r\n";
		String twoHyphens = "--";
		String boundary = "*****";

		int bytesRead, bytesAvailable, bufferSize;

		byte[] buffer;

		int maxBufferSize = 1 * 1024 * 1024;

		try {
			FileInputStream fileInputStream = null;
			try {
				File file = new File(filePath);
				Log.i(TAG, "将要上传的图片：" + file.getAbsolutePath());
				fileInputStream = new FileInputStream(file);
				Log.i(TAG, "获得图片输入流成功，文件大小：" + fileInputStream.available());
			} catch (FileNotFoundException e) {
				Log.e("DEBUG", "[FileNotFoundException]");
				result.code = PHPResult.JSON_ERROR;
				return false;
			}
			//String surl = "http://tcmahjong.boyaagame.com/__mahjong_x/facebook/androidinfo/uploadIcon.php";// Config.getCurrentURL();
			Log.i(TAG, "请求url:" + surl);
			URL url = new URL(surl);
			connection = (HttpURLConnection) url.openConnection();
			connection.setConnectTimeout(10000);
			connection.setDoInput(true);
			connection.setDoOutput(true);
			connection.setUseCaches(false);

			connection.setRequestMethod("POST");
			connection.setRequestProperty("Connection", "Keep-Alive");
			connection.setRequestProperty("Content-Type",
					"multipart/form-data;boundary=" + boundary);

			outStream = new DataOutputStream(connection.getOutputStream());
//			String api = new PHPPost().getApi(new TreeMap(),
//					METHOD_VISITOR_UPLOADICON);
			
			Log.i(TAG, "参数：" + api);
			outStream.writeBytes(addParam("api", api, twoHyphens, boundary,
					lineEnd));
			outStream.writeBytes(twoHyphens + boundary + lineEnd);
			// 是否上传反馈图片			
			if(isUploadFBimg){
				outStream.writeBytes("Content-Disposition: form-data; name=\"pfile\";filename=\"feedback_image.png"
						+ "\""
						+ lineEnd
						+ "Content-Type: "
						+ "application/octet-stream"
						+ lineEnd
						+ "Content-Transfer-Encoding: binary" + lineEnd);				
			}else{
				outStream.writeBytes("Content-Disposition: form-data; name=\"icon\";filename=\"icon.jpg"
						+ "\""
						+ lineEnd
						+ "Content-Type: "
						+ "application/octet-stream"
						+ lineEnd
						+ "Content-Transfer-Encoding: binary" + lineEnd);
			}

			outStream.writeBytes(lineEnd);

			bytesAvailable = fileInputStream.available();
			Log.i("" , "文件大小：" + bytesAvailable);
			bufferSize = Math.min(bytesAvailable, maxBufferSize);
			buffer = new byte[bufferSize];

			bytesRead = fileInputStream.read(buffer, 0, bufferSize);

			while (bytesRead > 0) {
				outStream.write(buffer, 0, bufferSize);
				bytesAvailable = fileInputStream.available();
				bufferSize = Math.min(bytesAvailable, maxBufferSize);
				bytesRead = fileInputStream.read(buffer, 0, bufferSize);
			}

			outStream.writeBytes(lineEnd);
			outStream.writeBytes(twoHyphens + boundary + twoHyphens + lineEnd);

			fileInputStream.close();
			outStream.flush();
			outStream.close();
			Log.i(TAG, "往服务器写数据完成");
		} catch (MalformedURLException e) {
			result.code = PHPResult.JSON_ERROR;
			Log.e("DEBUG", "[MalformedURLException while sending a picture]");
			return false;
		} catch (IOException e) {
			result.code = PHPResult.JSON_ERROR;
			Log.e("DEBUG", "[IOException while sending a picture]");
			return false;
		}

		int responseCode;
		try {
			responseCode = connection.getResponseCode();
			StringBuilder response = new StringBuilder();
			Log.i(TAG, "上传头像，服务器返回：" + responseCode);
			if (responseCode == HttpURLConnection.HTTP_OK) {
				InputStream urlStream = connection.getInputStream();
				BufferedReader bufferedReader = new BufferedReader(
						new InputStreamReader(urlStream));
				String sCurrentLine = "";
				while ((sCurrentLine = bufferedReader.readLine()) != null) {
					response.append(sCurrentLine);
				}
				bufferedReader.close();
				Log.i(TAG, "读数据完成");
				connection.disconnect();
				Log.i(TAG, "结果：" + response.toString());
				result.code = PHPResult.SUCCESS;
				result.json = response.toString();
				return true;
			}
		} catch (IOException e) {
			result.code = PHPResult.JSON_ERROR;
		}

		return false;
	}

	private static final String addParam(String key, String value,
			String twoHyphens, String boundary, String lineEnd) {
		return twoHyphens + boundary + lineEnd
				+ "Content-Disposition: form-data; name=\"" + key + "\""
				+ lineEnd + lineEnd + value + lineEnd;
	}



	// 用当前时间给取得的图片命名
	public static String getPhotoFileName() {
		Date date = new Date(System.currentTimeMillis());
		SimpleDateFormat dateFormat = new SimpleDateFormat(
				"'IMG'_yyyyMMdd_HHmmss");
		return dateFormat.format(date) + ".jpg";
	}



	/**
	 * Constructs an intent for image cropping. 调用图片剪辑程序 剪裁后的图片跳转到新的界面
	 */
	public static Intent getCropImageIntent(Uri photoUri) {
		Intent intent = new Intent("com.android.camera.action.CROP");
		intent.setDataAndType(photoUri, "image/*");
		intent.putExtra("crop", "true");
		intent.putExtra("aspectX", 1);
		intent.putExtra("aspectY", 1);
		intent.putExtra("outputX", 300);
		intent.putExtra("outputY", 300);
		intent.putExtra("return-data", true);
		return intent;
	}

	/**
	 * 
	 */
	public static void uploadPhoto(final Game activity , final String filepath , final String api ,final String url , final String strDicName,final boolean isUpLoadFBimg){
		uploadPhoto(activity, filepath, api, url, strDicName, isUpLoadFBimg,"上传图片");
	}
	public static void uploadPhoto(final Game activity , final String filepath , final String api ,final String url , final String strDicName,final boolean isUpLoadFBimg,final String tips) {

		//final Bitmap cBitmap = comPressBitmap(bitmap);
		

		Log.i("uploadPhoto", "uploadPhoto url = " + url);
		System.out.print("uploadPhoto url = " + url);

		ThreadTask.start(activity,tips, true, new OnThreadTask() {
			PHPResult result = new PHPResult();
			@Override
			public void onThreadRun() {
				Log.i("uploadPhoto", "开始上传onThreadRun url = " + url);
				Log.i("uploadPhoto", "开始上传" + filepath);
				System.out.print("uploadPhoto url = " + url);
				UploadImage.uploadVisitorIcon(filepath , url , api ,result,isUpLoadFBimg);
			}

			@Override
			public void onAfterUIRun() {
				Log.i("result.code", "result.code:" + result.code);
				activity.runOnLuaThread(new Runnable() {
					@Override
					public void run() {
						if (result.code == PHPResult.SUCCESS){
							HandMachine.getHandMachine().luaCallEvent(strDicName , result.json);
						}else{
							HandMachine.getHandMachine().luaCallEvent(strDicName, null);
						} 
					}
				});
				
			}

			@Override
			public void onUIBackPressed() {
				activity.runOnLuaThread(new Runnable() {
					@Override
					public void run() {
						HandMachine.getHandMachine().luaCallEvent(strDicName , null);
					}
				});
			}
		});

	}

	private static Bitmap comPressBitmap(Bitmap bitmap) {
		int height = bitmap.getHeight();
		float scale = ((float) IMG_SIZE) / height;
		Matrix matrix = new Matrix();
		matrix.postScale(scale, scale);
		return Bitmap.createBitmap(bitmap, 0, 0, height, height, matrix, true);
	}
	
}
