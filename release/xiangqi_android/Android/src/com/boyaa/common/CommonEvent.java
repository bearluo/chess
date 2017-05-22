package com.boyaa.common;

import com.boyaa.made.AppActivity;

public class CommonEvent {

	public static final String EVENT = "CommonEvent";
	public static final String UPLOAD_DUMPFILE = "uploadDumpFile";
	
	private static void invoke (String method) {
		if (method.equals(UPLOAD_DUMPFILE)){
			new UploadDumpFile().uploadDumpFile();
		}else {
			Log.i(EVENT, "Error, No such a method!!");
		}
	}
	
	public static void event () {
		String method = AppActivity.dict_get_string(EVENT, EVENT);
		invoke(method);
	}
	
	public static class Log {
		
		private static final boolean PRINT_LOG = true;
		
		public static void i(String tag, String msg){
			if (PRINT_LOG) 
				android.util.Log.i(tag, msg);
		}
		
		public static void e(String tag, String msg){
			if (PRINT_LOG) 
				android.util.Log.e(tag, msg);
		}
	}
}
