package com.boyaa.widget;

import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.util.AttributeSet;
import android.widget.LinearLayout;

public class TranslationLinearLayout extends LinearLayout {
	private TranslationLinearLayout THIS = this;
	private Thread animThread;
	private int durationMillis = 500;
	private final int times = 100;
	private Handler mHandler;

	public TranslationLinearLayout(Context context) {
		super(context);
		init();
	}

	public TranslationLinearLayout(Context context, AttributeSet attrs) {
		super(context, attrs);
		init();
	}
	
	private final int TRANSLATION = 1;
	private final int ANIM_START = 2;
	private final int ANIM_END = 3;
	private void init() {
		mHandler = new Handler() {
			public void handleMessage(Message msg) {
				if (msg.what == TRANSLATION) {
					THIS.scrollTo(msg.arg1, msg.arg2);
				} else if (msg.what == ANIM_START) {
					if (mAnimationListener != null) mAnimationListener.onAnimationStart((Boolean)msg.obj);
				} else if (msg.what == ANIM_END) {
					if (mAnimationListener != null) mAnimationListener.onAnimationEnd((Boolean)msg.obj);
				}
			}
		};
	}
	
	public void setDuration(int duration) {
		durationMillis = duration;
	}

	public void translationAnimation(final int x, final int y, final boolean isBack) {
//		Log.i("CDH", "translationAnimation x:" +x + " y:" + y + " isBack:"+isBack);
		if (x == 0 && y == 0) return;

		animThread = new Thread() {
			public void run() {
				int sleepTime = durationMillis / times;
				int t = 0;
				float fx = x*1f / times;
				float fy = y*1f / times;
				int offset = 0;
				if (isBack) {
					offset = -times;
				}
				Message msg = mHandler.obtainMessage();
				msg.what = ANIM_START;
				msg.obj = isBack;
				if (mAnimationListener != null) mHandler.sendMessage(msg);
				while(t < times) {
					t++;
					msg = mHandler.obtainMessage();
					msg.what = TRANSLATION;
					msg.arg1 = (int)(fx*(t + offset));
					msg.arg2 = (int)(fy*(t + offset));
//					Log.i("CDH", "scrollTo times:" +t+ " x:" + msg.arg1 + " y:" + msg.arg2);
					mHandler.sendMessage(msg);
					try {
						Thread.sleep(sleepTime);
					} catch(Exception e) {
						e.printStackTrace();
					}
				}
				msg = mHandler.obtainMessage();
				msg.what = ANIM_END;
				msg.obj = isBack;
				if (mAnimationListener != null) mHandler.sendMessage(msg);
			}
		};
		animThread.start();
	}
	
	private AnimationListener mAnimationListener;
	public void setAnimationListener(AnimationListener animationListener) {
		mAnimationListener = animationListener;
	}
	
	public static interface AnimationListener {
		void onAnimationStart(boolean isBack);
		void onAnimationEnd(boolean isBack);
	}
}
