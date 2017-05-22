package com.boyaa.gamedetails;

import java.util.List;

import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Gallery;
import android.widget.Gallery.LayoutParams;
import android.widget.ImageView;

import com.boyaa.common.ImageFileManager;
import com.boyaa.pointwall.R;
import com.boyaa.thread.TaskManager;
import com.boyaa.thread.task.ImageDownloadTask;

public class GalleryAdapter extends BaseAdapter {
	private Activity mActivity;
	private List<String> urlList;

//	private LayoutInflater inflater;

	GalleryAdapter(Activity activity, List<String> urls) {
		mActivity = activity;
		urlList = urls;

//		inflater = LayoutInflater.from(activity);
	}

	public int getCount() {
		return urlList == null ? 0 : urlList.size();
	}

	public String getItem(int position) {
		return urlList.get(position);
	}

	public long getItemId(int position) {
		return position;
	}

	public View getView(int position, View convertView, ViewGroup parent) {
		ImageView contentView = null;
		if (convertView == null) {
			contentView = new ImageView(mActivity);
			contentView.setLayoutParams(new Gallery.LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.FILL_PARENT));
            
			convertView = contentView;
		} else {
			contentView = (ImageView)convertView;
		}
		//设置默认图片
		contentView.setBackgroundResource(R.drawable.game_detail_big_default);

		String bigImageUrl = getItem(position);
		if (!TextUtils.isEmpty(bigImageUrl)) {
			Bitmap bitmap = ImageFileManager.getImage(bigImageUrl);
			if (bitmap != null) {
				contentView.setBackgroundDrawable(new BitmapDrawable(bitmap));
			} else {
				TaskManager.getInstance().addTask(new ImageDownloadTask(mActivity, contentView, bigImageUrl, 100000));
			}
		}
		
		return contentView;
	}

}
