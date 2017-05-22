package com.boyaa.widget;

import com.boyaa.pointwall.R;

import android.app.ProgressDialog;
import android.content.Context;
import android.os.Bundle;

public class ProgressDlg extends ProgressDialog{
	
	public ProgressDlg(Context context) {
		super(context);
	}
	
	public ProgressDlg(Context context, int theme){
		super(context, theme);
		
	}
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.progressdlg);
	}

	@Override
	public void onWindowFocusChanged(boolean hasFocus) {
		// TODO Auto-generated method stub
		//super.onWindowFocusChanged(hasFocus);
		if (!hasFocus)
		{
			this.dismiss();
		}
	}
//	
//	public void show(Context context){
//		ProgressDlg dlg = new ProgressDlg(context, R.style.dialog);
//		dlg.show();
//	}
//	
}