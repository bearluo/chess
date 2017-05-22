package com.boyaa.thread.task;

import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.BitmapFactory.Options;
import android.util.Log;
import android.widget.ImageView;

import com.boyaa.common.ImageFileManager;
import com.boyaa.common.ImageUtil;
import com.boyaa.http.HttpResult;
import com.boyaa.http.HttpUtil;
import com.boyaa.thread.ITask;

public class ImageDownloadTask implements ITask {
	private Activity mActivity;
	private ImageView mImageView;
	private String mUrl;
	private Bitmap mBitmap;
	private int mMaxBytes;
	private static int[] sampleSize = {1, 2, 4, 8, 16, 32, 64};
	
	public ImageDownloadTask(Activity activity, ImageView imageView, String url) {
		mActivity = activity;
		mImageView = imageView;
		mImageView.setTag(url);
		mUrl = url;
		mMaxBytes = -1;
	}

	public ImageDownloadTask(Activity activity, ImageView imageView, String url, int maxBytes) {
		mActivity = activity;
		mImageView = imageView;
		mImageView.setTag(url);
		mUrl = url;
		mMaxBytes = maxBytes;
	}

	public void execute() {
		HttpResult httpResult = HttpUtil.get(mUrl);
		if (httpResult.result != null) {
			ImageFileManager.saveImage(httpResult.result, mUrl);

			//如果图片很大，需要缩小图片像素
			Options mOptions = null;
			if (mMaxBytes != -1 && mMaxBytes < httpResult.result.length) {
//				int scale = (int)Math.ceil(httpResult.result.length / 4.0 / mMaxBytes);
				int scale = 0;
				double length = httpResult.result.length;
				while (length > mMaxBytes) {
					length = length / 4;
					scale++;
				}
				
				Log.i("CDH", "Image bytes length:" + httpResult.result.length + "  scale:"+scale);
				mOptions = new Options();
				mOptions.inSampleSize = sampleSize[scale];
			}
			mBitmap = BitmapFactory.decodeByteArray(httpResult.result, 0, httpResult.result.length, mOptions);
			mBitmap = 	ImageUtil.toRoundCorner(mBitmap, 6);
		}
	}

	public void postExecute() {
		if (mBitmap != null) {
			String curUrl = (String)mImageView.getTag();
			if (!mActivity.isFinishing() && mUrl.equals(curUrl)) {
				mImageView.post(new Runnable() {

					public void run() {
						mImageView.setImageBitmap(mBitmap);
//						mImageView.setBackgroundResource(R.drawable.image_shadow);
					}
				});
			}
		}
	}
}
