package com.boyaa.entity.update;

import java.io.File;
import java.io.IOException;
import java.util.zip.ZipException;

import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.made.AppActivity;
import com.boyaa.util.MD5Util;
import com.boyaa.util.ZipUtils;

import android.content.Intent;
import android.net.Uri;
import android.os.Environment;

public class ApkInstall {
	
	private final static String KEventResponse = "event_install_apk";
	private final static String kstrDictName = "patchUpdate";
	private final static String kResult = "result";//flag of finish status
	private final static int kResultSuccess = 1;
	private final static int kResultError = -1;
	private int result;
	
	public void startInstall(String apkFullPath){
		result = kResultSuccess;
		try {
			Runtime runtime = Runtime.getRuntime();
			runtime.exec("chmod 777 " + apkFullPath);
		} catch (IOException e) {
			e.printStackTrace();
		}
		File apkFile = new File(apkFullPath);
		if(apkFile.exists()){
			Intent intent = new Intent(Intent.ACTION_VIEW);
			intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			intent.setDataAndType(Uri.parse("file://" + apkFullPath),"application/vnd.android.package-archive");
			AppActivity.mActivity.startActivity(intent);
		}else{
			result = kResultError;
		}
		
		AppActivity.mActivity.runOnLuaThread(new Runnable()
		{
			@Override
			public void run() {
				AppActivity.dict_set_int(kstrDictName, kResult, result);
				AppActivity.call_lua(KEventResponse);
			}
		});
	}
	
	public void startZipInstall(String luaFullPath,String outFullPath) {
		result = kResultSuccess;
		try {
			Runtime runtime = Runtime.getRuntime();
			runtime.exec("chmod 777 " + luaFullPath);
		} catch (IOException e) {
			e.printStackTrace();
		}
		File luaFile = new File(luaFullPath);
		if(luaFile.exists()){
			try {
				ZipUtils.unzip(luaFullPath, outFullPath);
			} catch (ZipException e) {
				e.printStackTrace();
				result = kResultError;
			} catch (IOException e) {
				e.printStackTrace();
				result = kResultError;
			}
		}else{
			result = kResultError;
		}
		AppActivity.mActivity.runOnLuaThread(new Runnable()
		{
			@Override
			public void run() {
				AppActivity.dict_set_int(kstrDictName, kResult, result);
				AppActivity.call_lua(KEventResponse);
			}
		});
	}
	
	// 这个不能用
	public void silenceZipInstall() {
		String rootPath=Environment.getExternalStorageDirectory().getPath()+"/."+Game.mActivity.getPackageName() + File.separator + "update";
		String outFullPath = Game.mActivity.getFilesDir() + File.separator + "update";
		try {
			File file = new File(rootPath);
			if(file.isDirectory()) {
				File[] files = file.listFiles();
				for( File delF : files ) {
					String fileName=delF.getName();
					String prefix=fileName.substring(fileName.lastIndexOf(".")+1);
					if ( prefix.equals("zip") ) {
						if(delF.exists()&&delF.isFile()){
							try {
								ZipUtils.unzip(delF.getPath(), outFullPath);
							} catch (ZipException e) {
								e.printStackTrace();
							} catch (IOException e) {
								e.printStackTrace();
							}
						}
					}
				}
			}
		} catch (Exception e) {
			// TODO: handle exception
		}
	}
	
}
