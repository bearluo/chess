package com.boyaa.entity.common;

import android.app.Activity;
import android.content.Context;
import android.os.HandlerThread;

/**
 * 不要直接使用SyncTaskSimpleWrap,使用ThreadTask.start<br>
 * 这种做法更利于结构化的程序设计(而不是面向对象的).<br>
 * 贡献:
 */
public final class ThreadTask
{
	// OnThreadTask must be start once
	public static void start ( Activity context,String tips,boolean enableAbort,OnThreadTask ott )
	{
		ott.tips = tips;
		ott.progressDialog = null;
		new SyncTaskSimpleWrap(context,ott,enableAbort).execute();
	}
}
