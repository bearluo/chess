package com.boyaa.entity.images;

import java.io.File;

import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.content.ContentUris;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.support.v4.content.FileProvider;
import android.util.Log;
import android.widget.Toast;

import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.entity.common.SDTools;
import com.boyaa.entity.core.HandMachine;
import com.boyaa.made.FileUtil;

public class SaveImage {
	
	private Game activity;
	private String strDicName;
	private boolean isFBimage;
	public SaveImage(){
		
	}
	public SaveImage(Game activity , String strDicName){
		this.activity = activity;
		this.strDicName = strDicName;
	}
	
	private String  imageName= "headIcon03";
	private String Api = "";
	private String Url = "";
	private static boolean savesucess = false;
	/** 用来标识请求gallery的activity */
	public static final int PHOTO_PICKED_WITH_DATA = 1001;
	private static final int MAXSIZE = 128;   //图片的长、宽最大长度
	
	
	/**
	 * 请求Gallery程序
	 * @param isFBimg,是否是反馈里面截图
	 */
	public void doPickPhotoFromGallery(String imageNamePar,boolean isFBimg) {
		Log.i("SaveImage","doPickPhotoFromGallery ");
		isFBimage = isFBimg;
		JSONObject jsonResult = null;
		try {
			jsonResult = new JSONObject(imageNamePar);
			imageName = jsonResult.getString("ImageName");
			Api = jsonResult.getString("Api");
			Url = jsonResult.getString("Url");
			Log.i("SaveImage","doPickPhotoFromGallery imageName = " + imageName);
			Log.i("SaveImage","doPickPhotoFromGallery Api = " + Api);
			Log.i("SaveImage","doPickPhotoFromGallery Url = " + Url);
			Log.i("SaveImage","doPickPhotoFromGallery Url = " + Url);
		} catch (JSONException e) {
			Log.i("SaveImage","doPickPhotoFromGallery JSONException e = " + e.getMessage());
			Log.i("SaveImage","doPickPhotoFromGallery JSONException e = " + e.getStackTrace());
			Toast.makeText(activity, "调用失败", Toast.LENGTH_SHORT).show();
			return;
		}
//		ACTION_PICK直接“选取图片”,ACTION_GET_CONTENT会有几种图片可供选择，为了避免onSaveBitmap返回的data为空,所以选择ACTION_PICK方式。
//		Intent intent = new Intent(Intent.ACTION_PICK,
//                android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
		//file:// 规避权限问题
		String fullPath = "file://" + FileUtil.getmStrImagesPath() + "temp.png";
		Log.i("SaveImage","doPickPhotoFromGallery fullPath = " + fullPath);
		Uri imageUri = Uri.parse(fullPath);
//		Intent intent = new Intent(Intent.ACTION_PICK,
//      android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
//		intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
//		intent.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
		Intent intent = new Intent(Intent.ACTION_GET_CONTENT,android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
		intent.setType("image/*");
//		intent.setAction(Intent.ACTION_PICK);
//		intent.putExtra("crop", "true");
//		intent.putExtra("aspectX", 1);
//		intent.putExtra("aspectY", 1);
//		intent.putExtra("outputX", 300);
//		intent.putExtra("outputY", 300);
//		intent.putExtra("return-data", false);
//		intent.putExtra(MediaStore.EXTRA_OUTPUT, imageUri);
//		intent.putExtra("outputFormat", Bitmap.CompressFormat.PNG.toString());
		intent.putExtra(MediaStore.EXTRA_SCREEN_ORIENTATION,
				ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
		activity.startActivityForResult(intent,
				PHOTO_PICKED_WITH_DATA);
		
	}
	
	public void doCropPhoto(Intent i,File file) {
		try {
			Uri uri;
			if(Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP){
				 uri = Uri.fromFile(file);
			}else{
				 uri = FileProvider.getUriForFile(activity,activity.getApplicationContext().getPackageName()+ ".provider",file);
			}
			doCropPhoto(i,uri);
		} catch (Exception e) {
			e.printStackTrace();
			Toast.makeText(this.activity, "图片路径解析失败", Toast.LENGTH_LONG).show();
		}
	}
	
	public void doCropPhoto(Intent i,Uri uri) {
		try {
			// 启动gallery去剪辑这个照片
			Log.i("doCropPhoto","uri = " + uri);
			//file:// 规避权限问题
			String fullPath = "file://" + FileUtil.getmStrImagesPath() + "temp.png";
			Uri imageUri = Uri.parse(fullPath);
			Intent intent = new Intent("com.android.camera.action.CROP");
			intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
			intent.setDataAndType(uri, "image/*");
			intent.putExtra("crop", "true");
			intent.putExtra("aspectX", 1);
			intent.putExtra("aspectY", 1);
			intent.putExtra("outputX", 300);
			intent.putExtra("outputY", 300);
			intent.putExtra(MediaStore.EXTRA_OUTPUT, imageUri);
			intent.putExtra("return-data", false);
			intent.putExtra("outputFormat", Bitmap.CompressFormat.PNG.toString());
			intent.putExtra(MediaStore.EXTRA_SCREEN_ORIENTATION,
					ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);

			this.activity.startActivityForResult(intent, PHOTO_PICKED_WITH_DATA);
		} catch (Exception e) {
			e.printStackTrace();
			Toast.makeText(this.activity, "裁剪图片失败", Toast.LENGTH_LONG).show();
		}
	}
	
	public void onSaveBitmap(Intent data){

		if (null == data) {
			return;
		}
		String fullPath = FileUtil.getmStrImagesPath() + "temp.png";
		String imgPath = FileUtil.getmStrImagesPath() + imageName + ".png";
		File temp = new File(fullPath);
		File imgTemp = new File(imgPath);
		boolean imgExist = imgTemp.exists();
		if(imgExist) {
			imgTemp.delete();
		}
		boolean exist = temp.exists();
		if(exist) {
			savesucess = temp.renameTo(imgTemp);
		}else {
			Uri uri = data.getData();
			if (uri != null) {
//				Log.i("onSaveBitmap","uri = " + uri);
//				String path = checkPath(activity, uri);
//				if (path != null){
//					File file = new File(path);
					doCropPhoto(data,uri);
					return ;
//				}
			}else {
				savesucess = false;
			}
		}
		
//		Bitmap photo = data.getParcelableExtra("data");
//		if (photo != null) {
//		
//			Log.d("DEBUG", "big width = " + photo.getWidth()
//					+ " height = " + photo.getHeight());
//		
//
//			savesucess = SDTools.saveBitmap(
//					activity, FileUtil.getmStrImagesPath(), imageName , photo);
//			photo.recycle();
//			photo = null;
//		} else {
//			Uri uri = data.getData();
//			if (uri != null) {
//				String path = checkPath(activity, uri);
//				if(path != null){
//					savesucess = false;
//				}else {
//					savesucess = false;
//				}
//				BitmapFactory.Options options = new BitmapFactory.Options();
//				options.inJustDecodeBounds = true;
//				BitmapFactory.decodeFile(path, options);
//				int maxlen = (options.outHeight > options.outWidth) ? options.outHeight
//						: options.outWidth;
//				options.inSampleSize = maxlen / MAXSIZE;
//				options.inJustDecodeBounds = false;
//				photo = BitmapFactory.decodeFile(path, options);
//				if (null != photo) {
//					Log.d("DEBUG", "big width = " + photo.getWidth()
//							+ " height = " + photo.getHeight());
//					savesucess = SDTools.saveBitmap(
//							activity, FileUtil.getmStrImagesPath(), imageName , photo);
//					photo.recycle();
//					photo = null;
//				}
//			}
//		}
		
		
		if (savesucess){
			if (!isFBimage){//反馈只是选中截图，不需要上传
				// 生成新的
				Log.i("uploadPhoto", "uploadPhoto url = " + Url);
				
				UploadImage.uploadPhoto(activity , imgPath , Api , Url , strDicName,false);				
			}else{
				final JSONObject ret = new JSONObject();
				try {
					ret.put("imageName", imageName);
					// 保存本地成功后，返回反馈界面，设置截图				
					activity.runOnLuaThread(new Runnable() {

						@Override
						public void run() {
							HandMachine.getHandMachine().luaCallEvent(strDicName , ret.toString());
						}
					});	
				} catch (JSONException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}

		}else{
			activity.runOnLuaThread(new Runnable() {
				@Override
				public void run() {
					HandMachine.getHandMachine().luaCallEvent(strDicName , null);
				}
			});
			
		} 


	}
	
	@SuppressLint("NewApi")
	public static String checkPath(final Context context, final Uri uri) {

		final boolean isKitKat = Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT;

		// DocumentProvider
		if (isKitKat && DocumentsContract.isDocumentUri(context, uri)) {
			// ExternalStorageProvider
			if (isExternalStorageDocument(uri)) {
				final String docId = DocumentsContract.getDocumentId(uri);
				final String[] split = docId.split(":");
				final String type = split[0];

				if ("primary".equalsIgnoreCase(type)) {
					return Environment.getExternalStorageDirectory() + "/"
							+ split[1];
				}

			}
			// DownloadsProvider
			else if (isDownloadsDocument(uri)) {
				final String id = DocumentsContract.getDocumentId(uri);
				final Uri contentUri = ContentUris.withAppendedId(
						Uri.parse("content://downloads/public_downloads"),
						Long.valueOf(id));

				return getDataColumn(context, contentUri, null, null);
			}
			// MediaProvider
			else if (isMediaDocument(uri)) {
				final String docId = DocumentsContract.getDocumentId(uri);
				final String[] split = docId.split(":");
				final String type = split[0];

				Uri contentUri = null;
				if ("image".equals(type)) {
					contentUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
				} else if ("video".equals(type)) {
					contentUri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI;
				} else if ("audio".equals(type)) {
					contentUri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI;
				}

				final String selection = "_id=?";
				final String[] selectionArgs = new String[] { split[1] };

				return getDataColumn(context, contentUri, selection,
						selectionArgs);
			}
		}
		// MediaStore (and general)
		else if ("content".equalsIgnoreCase(uri.getScheme())) {
			// Return the remote address
			if (isGooglePhotosUri(uri))
				return uri.getLastPathSegment();

			return getDataColumn(context, uri, null, null);
		}
		// File
		else if ("file".equalsIgnoreCase(uri.getScheme())) {
			return uri.getPath();
		}

		return null;
	}

	/**
	 * @param uri
	 *            The Uri to check.
	 * @return Whether the Uri authority is ExternalStorageProvider.
	 */
	public static boolean isExternalStorageDocument(Uri uri) {
		return "com.android.externalstorage.documents".equals(uri
				.getAuthority());
	}

	/**
	 * @param uri
	 *            The Uri to check.
	 * @return Whether the Uri authority is DownloadsProvider.
	 */
	public static boolean isDownloadsDocument(Uri uri) {
		return "com.android.providers.downloads.documents".equals(uri
				.getAuthority());
	}
	

	/**
	 * Get the value of the data column for this Uri. This is useful for
	 * MediaStore Uris, and other file-based ContentProviders.
	 *
	 * @param context
	 *            The context.
	 * @param uri
	 *            The Uri to query.
	 * @param selection
	 *            (Optional) Filter used in the query.
	 * @param selectionArgs
	 *            (Optional) Selection arguments used in the query.
	 * @return The value of the _data column, which is typically a file path.
	 */
	public static String getDataColumn(Context context, Uri uri,
									   String selection, String[] selectionArgs) {

		Cursor cursor = null;
		final String column = "_data";
		final String[] projection = { column };

		try {
			cursor = context.getContentResolver().query(uri, projection,
					selection, selectionArgs, null);
			if (cursor != null && cursor.moveToFirst()) {
				final int index = cursor.getColumnIndexOrThrow(column);
				return cursor.getString(index);
			}
		} finally {
			if (cursor != null)
				cursor.close();
		}
		return null;
	}

	/**
	 * @param uri
	 *            The Uri to check.
	 * @return Whether the Uri authority is MediaProvider.
	 */
	public static boolean isMediaDocument(Uri uri) {
		return "com.android.providers.media.documents".equals(uri
				.getAuthority());
	}

	/**
	 * @param uri
	 *            The Uri to check.
	 * @return Whether the Uri authority is Google Photos.
	 */
	public static boolean isGooglePhotosUri(Uri uri) {
		return "com.google.android.apps.photos.content".equals(uri
				.getAuthority());
	}
//	
//	private String getPath(Uri uri) {
//		if(uri == null){
//			Log.e(this+"", "null uri!");
//			return null;
//		}
//		String[] projection = { MediaStore.Images.Media.DATA };
//		Cursor cursor = activity.managedQuery(uri, projection, null, null, null);
//		if(cursor == null){
//			//当使用第三方资源管理选择照片的时候
//			String uriString = uri.toString();
//			Log.d("DEBUG", "uri = "+uriString);
//			uriString = uriString.replace("file://", "");
//			Log.d("DEBUG", "uri2 = "+uriString);
//			
//			return uriString;
//		}
//		int column_index = cursor
//				.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
//		cursor.moveToFirst();
//		return cursor.getString(column_index);
//
//	}
	
}
