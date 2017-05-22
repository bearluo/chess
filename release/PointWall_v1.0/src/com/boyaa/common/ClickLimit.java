package com.boyaa.common;

import android.os.Handler;


public class ClickLimit {
	private static long lastClickTime;
	private static boolean runningClock;
	public static boolean mutipleClick() {
		long curTime = System.currentTimeMillis();
		if (curTime - lastClickTime < 500) {
			return true;
		}
		lastClickTime = curTime;
		return false;
	}
	
	public static void startClock(final int count,final int interval,final Handler handler){
		runningClock = true;
		new Thread(){
			int n = count ;
			@Override
			public void run() {
				while (runningClock && n>=0) {
					handler.sendEmptyMessage(n);
					try {
						sleep(interval);
					} catch (InterruptedException e) {
						e.printStackTrace();
					} finally {
						n--;
					}
				}
			}
		}.start();
	}

	 public static void stopClock(){
		 runningClock = false;
	 }
  }

