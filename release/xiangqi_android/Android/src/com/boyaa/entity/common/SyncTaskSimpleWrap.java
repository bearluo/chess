package com.boyaa.entity.common;



import android.app.Activity;
import android.os.AsyncTask;


/**
 * AsyncTask的简单包装(未处理progress和返回值).<br>
 * 贡献:
 */
public final class SyncTaskSimpleWrap extends AsyncTask<Void, Void, Void> {

	private Activity context;
	private OnThreadTask thread;
	private boolean enableAbort;
	public SyncTaskSimpleWrap( Activity context,OnThreadTask thread, boolean enableAbort)
	{
		this.context = context;
		this.thread = thread;
		this.enableAbort = enableAbort;
	}
	@Override
	protected void onPreExecute ()
	{
		if ( null != thread.tips && thread.tips.length() > 0 &&context!=null && !context.isFinishing())
		{
			thread.progressDialog = BoyaaProgressDialog.show(context, thread.tips);
			if ( false == this.enableAbort ) return;
			thread.progressDialog.setOnCancelListener(new BoyaaProgressDialog.onCancelListener() {
				@Override
				public void onCancel() {
					if ( null != SyncTaskSimpleWrap.this.thread.progressDialog )
					{
						SyncTaskSimpleWrap.this.thread.progressDialog.dismiss();
						SyncTaskSimpleWrap.this.thread.progressDialog = null;
					}
					SyncTaskSimpleWrap.this.thread.backPressed = true;
					SyncTaskSimpleWrap.this.thread.onUIBackPressed();
				}
			});
		}
	}

	@Override
	protected Void doInBackground(Void... params)
	{
		//Debug.threadInit();
		try
		{
			thread.onThreadRun();
		}
		catch(Exception e )
		{

		}
		return null;
	}

	@Override
	protected void onPostExecute( Void val) {
		if ( thread.backPressed )
		{
			// 在onCancel中已经关
			thread.progressDialog = null;
		}
		else
		{
			// 正常(未用backpressed)关闭ProgressDialog
			if ( null != thread.progressDialog && null!= context && !context.isFinishing())
			{
				thread.progressDialog.dismiss();
				thread.progressDialog = null;
			}
			thread.onAfterUIRun();
		}
	}
}
