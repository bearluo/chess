package com.boyaa.made;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.text.SimpleDateFormat;
import java.util.Calendar;

import android.os.Debug;
import android.os.Debug.MemoryInfo;
import android.util.Log;

public class MemoryProfiling {

	private static final String LOG_FILE = "memory.csv";
	private static final String COMMA = ",";
	private static String SCENEBEFORE = "login";
	private static String SCENEAFTER = "";

	private static void LogFile(String name, String info) {

		try {
			File file = new File(name);
			FileOutputStream fos = new FileOutputStream(file, true);
			fos.write(info.getBytes());
			fos.write('\n');
			fos.close();
		} catch (IOException e) {
			Log.e("", e.toString());
		}
	}

	public static void init() {
		if (!FileUtil.readySDCard()) {
			return;
		}
		String strFile = FileUtil.getSubPath("log") + LOG_FILE;
		File file = new File(strFile);
		try {
			if (!file.exists()) {
				file.createNewFile();
			}
		} catch (IOException e) {
			Log.e("", e.toString());
		}
		LogFile(strFile, "time" + COMMA + "memory" + COMMA + "cpu");

	}

	private static SimpleDateFormat dformat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	private static final String TOP = "top -m 5 -d 1 -n 1 -s cpu";
	public static void log() {
		if (!FileUtil.readySDCard()) {
			return;
		}
		final Runtime rt = Runtime.getRuntime();
		String strFile = FileUtil.getSubPath("log") + LOG_FILE;
		String strTime = dformat.format(Calendar.getInstance().getTimeInMillis());

		MemoryInfo mi = new MemoryInfo();
		Debug.getMemoryInfo(mi);
		
		int iMemSize = mi.dalvikPrivateDirty + mi.nativePrivateDirty + mi.otherPrivateDirty;
		String strCpu = "1000%";

		Process proc = null;
		BufferedReader reader = null;

		try {
			proc = rt.exec(TOP);
			int code = proc.waitFor();
			if ( 0 == code )
			{
				reader = new BufferedReader(new InputStreamReader(proc.getInputStream()));
				String str = reader.readLine();
				while ( null != str )
				{
					if ( str.contains("boyaa"))
					{
						str = str.trim();
						str = str.replaceAll("  "," ");
						str = str.replaceAll("  "," ");
						String[] toks = str.split(" ");
						for ( int k = 1; k < toks.length; k ++ )
						{
							str = toks[k];
							if ( str.contains("%"))
							{
								strCpu = toks[k];
								break;
							}
						}
						break;
					}
					str = reader.readLine();
				}
			}
		}catch (IOException e) {
			Log.e("", e.toString());
		}catch (InterruptedException e) {
			Log.e("", e.toString());
		}finally{
			try {
				if ( null!=reader)
				{
					reader.close();
				}
			} catch (IOException e) {
			}
			try {
				proc.getErrorStream().close();
			} catch (IOException e) {
			}
			try {
				proc.getInputStream().close();
			} catch (IOException e) {
			}
			try {
				proc.getOutputStream().close();
			} catch (IOException e) {
			}
		}

		LogFile(strFile,strTime+COMMA+iMemSize+COMMA+strCpu);
		if(!SCENEBEFORE.equals(SCENEAFTER)){
			SCENEBEFORE = SCENEAFTER;
			LogFile(strFile,SCENEAFTER+COMMA+SCENEAFTER+COMMA+SCENEAFTER);
			
		}
	    
	};
	public static void setSceneStr(String scene){
		SCENEAFTER = scene;
	}
}
