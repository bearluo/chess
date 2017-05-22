/*
 * Copyright (C) 2007 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.boyaa.entity.common;


import com.boyaa.chinesechess.platform91.R;

import android.app.Activity;
import android.app.AlertDialog;
import android.os.Bundle;
import android.text.TextPaint;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.view.animation.Animation;
import android.view.animation.LinearInterpolator;
import android.view.animation.RotateAnimation;
import android.widget.ImageView;
import android.widget.TextView;


public class BoyaaProgressDialog extends AlertDialog {

	
	public interface onCancelListener
	{
		public abstract void onCancel();
	}
	private onCancelListener listener = null;
	public void setOnCancelListener( onCancelListener listener)
	{
		this.listener = listener;
	}
	private ImageView mImageView;
	private TextView mTipsView;
	private CharSequence mTitle;

	public BoyaaProgressDialog(Activity context) {
		super(context);
	}

	public static BoyaaProgressDialog show(Activity context, CharSequence title) {
		BoyaaProgressDialog dialog = new BoyaaProgressDialog(context);
		dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
		dialog.setCancelable(false);
		dialog.setCanceledOnTouchOutside(false);
		dialog.mTitle = title;
		dialog.show();
		
		return dialog;
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		LayoutInflater inflater = LayoutInflater.from(getContext());
		View view = inflater.inflate(R.layout.dialog_progress, null);
		mImageView = (ImageView) view.findViewById(R.id.imgAnim);
		mTipsView = (TextView) view.findViewById(R.id.tips);
		mTipsView.setText(mTitle);
		TextPaint paint = mTipsView.getPaint();
		paint.setFakeBoldText(true);
		setContentView(view);

		RotateAnimation animation = new RotateAnimation(0, -359,
				Animation.RELATIVE_TO_SELF, 0.5f,
				Animation.RELATIVE_TO_SELF, 0.5f);
		animation.setDuration(800);
		animation.setRepeatCount(Animation.INFINITE);
		animation.setInterpolator( new LinearInterpolator ());
		mImageView.setAnimation(animation);
		animation.start();
		
	}

	@Override
	public void onStart() {
		super.onStart();

	}

	@Override
	protected void onStop() {
		super.onStop();
		mImageView.setAnimation(null);

	}
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event)  {
	    if (keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0) {

	    	if ( null != this.listener )
	    	{
	    		this.listener.onCancel();
	    	}
	        return true;
	    }

	    return super.onKeyDown(keyCode, event);
	}

}
