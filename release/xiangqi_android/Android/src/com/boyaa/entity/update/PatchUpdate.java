package com.boyaa.entity.update;

import java.io.File;

import android.app.ProgressDialog;
import android.os.AsyncTask;
import android.widget.Toast;

import com.boyaa.chinesechess.platform91.Game;
import com.skywds.android.bsdiffpatch.JniApi;

/**
 * Created by BrianLi on 2016/2/29.
 */
public class PatchUpdate {
	static {
	    System.loadLibrary("bsdiff");
	}

	private static AsyncTask<Void, Void, Void> task;
    public static int patch(String oldApkPath, String newApkPath, String patch){
        return JniApi.bspatch(oldApkPath, newApkPath, patch);
    }
    public static void exAsyncTask(final String old,final String newApk,final String patch) {
		if( task != null && task.getStatus() != AsyncTask.Status.FINISHED ) return ;
		Game.mActivity.runOnUiThread(new Runnable() {
			
			@Override
			public void run() {
				// TODO Auto-generated method stub
				task = new AsyncTask<Void, Void, Void>() {

					private ProgressDialog progressDialog;

					@Override
					protected void onPreExecute() {
						super.onPreExecute();
						progressDialog = ProgressDialog.show(Game.mActivity,
								"正在生成APK...", "请稍等...", true, false);
						progressDialog.show();
					}

					@Override
					protected Void doInBackground(Void... arg0) {
						File file = new File(newApk);
						if (file.exists())
							file.delete();// 如果newApk文件已经存在,先删除

						// 调用.so库中的方法,把增量包和老的apk包合并成新的apk
						patch(old, newApk, patch);
						return null;
					}

					@Override
					protected void onPostExecute(Void result) {
						progressDialog.dismiss();
						Toast.makeText(Game.mActivity, "打包完成，安装。。。。", Toast.LENGTH_SHORT).show();
						ApkInstall apkInstall = new ApkInstall();
						apkInstall.startInstall(newApk);
					}
				};
				task.execute();
			}
		});
	}
}
