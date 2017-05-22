package com.boyaa.entity.common.utils;


import android.graphics.Color;
import android.graphics.PorterDuff.Mode;
import android.graphics.drawable.Drawable;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;

import com.boyaa.entity.common.SdkVersion;

/**
 * 按钮按下时显示的底色
 * 
 * @author Administrator
 * 
 */
public class ButtonTouchStateListener implements OnTouchListener {
	@Override
	public boolean onTouch(View v, MotionEvent event) {
		Drawable drawable = v.getBackground();
		if (drawable == null)
			return false;
		
		if (SdkVersion.Above16())// 1.6以下版本mutate有bug
		{
			drawable.mutate();
		}
		switch (event.getAction()) {
		case MotionEvent.ACTION_DOWN:
			drawable.setColorFilter(Color.argb(100, 0, 0, 0), Mode.DST_IN);
			v.setBackgroundDrawable(drawable);
			break;
		case MotionEvent.ACTION_UP:
			drawable.clearColorFilter();
			v.setBackgroundDrawable(drawable);
			break;
		case MotionEvent.ACTION_CANCEL:
			drawable.clearColorFilter();
			v.setBackgroundDrawable(drawable);
			break;
		default:
			break;
		}
		return false;
	}
}