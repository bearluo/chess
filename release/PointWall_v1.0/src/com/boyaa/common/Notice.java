package com.boyaa.common;



import android.app.Activity;
import android.app.ProgressDialog;

public class Notice {
	private Activity mActivity;
	public Notice(Activity activity) {
		mActivity = activity;
	}

//	private AlertDialog mAlertDialog;

	private ProgressDialog mProgressDialog;
	public void showWaitDialog(String text) {
		showWaitDialog(text, true);
	}

	public void showWaitDialog(String text, boolean cancelable) {
		if (mProgressDialog == null) {
			mProgressDialog = new ProgressDialog(mActivity);
			mProgressDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
			mProgressDialog.setMessage(text);
			mProgressDialog.setCancelable(cancelable);
			mProgressDialog.setCanceledOnTouchOutside(false);
		} else {
			mProgressDialog.setMessage(text);
			mProgressDialog.setCancelable(cancelable);
		}
		mProgressDialog.show();
	}

	public void hideWaitDialog() {
		if (mProgressDialog != null) mProgressDialog.hide();
	}
}
