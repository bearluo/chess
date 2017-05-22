package com.boyaa.made;

import android.app.Activity;
import android.app.AlertDialog;
import android.os.Bundle;
import android.os.Message;
import android.view.KeyEvent;
import android.widget.ImageView;

import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.chinesechess.platform91.R;





public class AppStartDialog extends AlertDialog {

	private ImageView startImgView;

	
	public AppStartDialog(Activity context) {
		super(context, R.style.Transparent);
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.start_screen);
		
		startImgView = (ImageView) findViewById(R.id.startImg);
	}
	
	public void setStartImg(int id){
		startImgView.setBackgroundResource(id);
	}

	@Override
	public void onStart() {
		super.onStart();

	}

	@Override
	protected void onStop() {
		super.onStop();

	}
	
	
	
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event)  {
	    if (keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0) {
	        return true;
	    }

	    return super.onKeyDown(keyCode, event);
	}

}
