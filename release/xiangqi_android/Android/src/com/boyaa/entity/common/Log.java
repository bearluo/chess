package com.boyaa.entity.common;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Calendar;

import com.boyaa.made.FileUtil;

import android.os.Environment;

/**
 * Wrapper of android.util.Log.<br>
 * 支持写到文件 sdcard/<br>
 */
public final class Log {
	private static byte[] sync = new byte[0];
	private static final String LOG_STRIP = " ";
	private static final String LOG_FILE = "errorlog";

	/*
	 * 日志级别常量
	 */
	public static final int LOG_RELEASE = 0;
	public static final int LOG_VERBOSE = 1;
	public static final int LOG_INFO = 1 << 1;
	public static final int LOG_WARNING = 1 << 2;
	public static final int LOG_DEBUG = 1 << 3;
	public static final int LOG_ERROR = 1 << 4;

	/**
	 * 日志级别
	 */
	public static int log_level = LOG_VERBOSE | LOG_INFO | LOG_WARNING | LOG_DEBUG | LOG_ERROR;
			
	
	/**
	 * 是否记录到文件
	 */
	public static boolean log_file = false;
	
	public static boolean LogV() {
		return (log_level & LOG_VERBOSE) > 0;
	}

	public static boolean LogI() {
		return (log_level & LOG_INFO) > 0;
	}

	public static boolean LogW() {
		return (log_level & LOG_WARNING) > 0;
	}

	public static boolean LogD() {
		return (log_level & LOG_DEBUG) > 0;
	}

	public static boolean LogE() {
		return (log_level & LOG_ERROR) > 0;
	}

	public static String getLogPath() {
//		String path = Environment.getExternalStorageDirectory()
//				.getAbsolutePath() + File.separator + LOG_PATH;
		
		String path = FileUtil.getSubPath("log");
		return path;
	}

	public static boolean testSDCard() {
		if (Environment.getExternalStorageState().equals(
				Environment.MEDIA_MOUNTED)) {
			return true;
		}

		return false;
	}

	public static String catInfo(String info) {

		StringBuilder sb = new StringBuilder();
		sb.append(String.format("[ThreadID=%04d]", Thread.currentThread()
				.getId()));

		sb.append(LOG_STRIP);
		sb.append(info);
		return sb.toString();
	}

	public static String catInfo(String info, Throwable e) {
		StringBuilder sb = new StringBuilder();
		sb.append(String.format("[ThreadID=%04d]", Thread.currentThread()
				.getId()));

		sb.append(LOG_STRIP);
		sb.append(info);
		sb.append(LOG_STRIP);
		sb.append(UnException.getStackTrace(e));
		return sb.toString();
	}

	// Object标准的
	public static void v(Object obj, String info) {
		if (false == LogV())
			return;
		info = catInfo(info);
		android.util.Log.v(obj.getClass().getName(), info);
		Log.LogFile(obj.getClass().getName() + LOG_STRIP + info);
	}

	public static void e(Object obj, String info) {
		if (false == LogE())
			return;
		info = catInfo(info, new Throwable());
		android.util.Log.e(obj.getClass().getName(), info);
		Log.LogFile(obj.getClass().getName() + LOG_STRIP + info);
	}

	public static void i(Object obj, String info) {
		if (false == LogI())
			return;
		info = catInfo(info);
		android.util.Log.i(obj.getClass().getName(), info);
		Log.LogFile(obj.getClass().getName() + LOG_STRIP + info);
	}

	public static void d(Object obj, String info) {
		if (false == LogD())
			return;
		info = catInfo(info);
		android.util.Log.d(obj.getClass().getName(), info);
		Log.LogFile(obj.getClass().getName() + LOG_STRIP + info);
	}

	public static void w(Object obj, String info) {
		if (false == LogW())
			return;
		info = catInfo(info);
		android.util.Log.w(obj.getClass().getName(), info);
		Log.LogFile(obj.getClass().getName() + LOG_STRIP + info);
	}

	// Object Exception的
	public static void e(Object obj, Exception e) {
		if (false == LogE())
			return;
		String info = UnException.getStackTrace(e);
		info = catInfo(info);
		android.util.Log.e(obj.getClass().getName(), info);
		Log.LogFile(obj.getClass().getName() + LOG_STRIP + info);
	}

	// name 标准的
	public static void v(String name, String info) {
		if (false == LogV())
			return;
		info = catInfo(info);
		android.util.Log.v(name, info);
		Log.LogFile(name + LOG_STRIP + info);
	}

	public static void e(String name, String info) {
		if (false == LogE())
			return;
		info = catInfo(info, new Throwable());
		android.util.Log.e(name, info);
		Log.LogFile(name + LOG_STRIP + info);
	}

	public static void i(String name, String info) {
		if (false == LogI())
			return;
		info = catInfo(info);
		android.util.Log.i(name, info);
		Log.LogFile(name + LOG_STRIP + info);
	}

	public static void d(String name, String info) {
		if (false == LogD())
			return;
		info = catInfo(info);
		android.util.Log.d(name, info);
		Log.LogFile(name + LOG_STRIP + info);
	}

	public static void w(String name, String info) {
		if (false == LogW())
			return;
		info = catInfo(info);
		android.util.Log.w(name, info);
		Log.LogFile(name + LOG_STRIP + info);
	}

	// name Exception的
	public static void v(String name, Exception e) {
		if (false == LogV())
			return;
		String info = UnException.getStackTrace(e);
		info = catInfo(info);
		android.util.Log.v(name, info);
		Log.LogFile(name + LOG_STRIP + info);
	}

	public static void e(String name, Exception e) {
		if (false == LogE())
			return;
		String info = UnException.getStackTrace(e);
		info = catInfo(info);
		android.util.Log.e(name, info);
		Log.LogFile(name + LOG_STRIP + info);
	}

	public static void i(String name, Exception e) {
		if (false == LogI())
			return;
		String info = UnException.getStackTrace(e);
		info = catInfo(info);
		android.util.Log.i(name, info);
		Log.LogFile(name + LOG_STRIP + info);
	}

	public static void d(String name, Exception e) {
		if (false == LogD())
			return;
		String info = UnException.getStackTrace(e);
		info = catInfo(info);
		android.util.Log.d(name, info);
		Log.LogFile(name + LOG_STRIP + info);
	}

	public static void w(String name, Exception e) {
		if (false == LogW())
			return;
		String info = UnException.getStackTrace(e);
		info = catInfo(info);
		android.util.Log.w(name, info);
		Log.LogFile(name + LOG_STRIP + info);
	}

	// 可变参数的
	// support ... parameters

	public static String catInfo(Object... objects) {
		StringBuilder sb = new StringBuilder();
		sb.append(String.format("[ThreadID=%04d]", Thread.currentThread()
				.getId()));
		sb.append(LOG_STRIP);
		for (Object obj : objects) {
			sb.append(String.valueOf(obj)).append(LOG_STRIP);
		}

		return sb.toString();
	}

	public static void v(Object obj, Object... objects) {
		if (false == LogV())
			return;
		String info = catInfo(objects);
		android.util.Log.v(obj.getClass().getName(), info);
		Log.LogFile(obj.getClass().getName() + LOG_STRIP + info);
	}

	public static void e(Object obj, Object... objects) {
		if (false == LogE())
			return;
		String info = catInfo(objects);
		android.util.Log.e(obj.getClass().getName(), info);
		Log.LogFile(obj.getClass().getName() + LOG_STRIP + info);
	}

	public static void i(Object obj, Object... objects) {
		if (false == LogI())
			return;
		String info = catInfo(objects);
		android.util.Log.i(obj.getClass().getName(), info);
		Log.LogFile(obj.getClass().getName() + LOG_STRIP + info);
	}

	public static void d(Object obj, Object... objects) {
		if (false == LogD())
			return;
		String info = catInfo(objects);
		android.util.Log.d(obj.getClass().getName(), info);
		Log.LogFile(obj.getClass().getName() + LOG_STRIP + info);
	}

	public static void w(Object obj, Object... objects) {
		if (false == LogW())
			return;
		String info = catInfo(objects);
		android.util.Log.w(obj.getClass().getName(), info);
		Log.LogFile(obj.getClass().getName() + LOG_STRIP + info);
	}

	/**
	 * write info to file
	 * @param info
	 */
	private static void LogFile(String info) {
		if (!log_file || false == testSDCard())
			return;
		synchronized (sync) {
			try {
				File file = createFile();
				FileOutputStream fos = new FileOutputStream(file, true);
				info = dateFormat.format(Calendar.getInstance()
						.getTimeInMillis()) + LOG_STRIP + info;
				fos.write(info.getBytes());
				fos.write('\n');
				fos.close();
			} catch (FileNotFoundException e) {
			} catch (IOException e) {
			}
			;
		}
	}

	private static File createFile() throws IOException {
		String path = getLogPath() + LOG_FILE;
		File file = new File(path);
		if (file.exists())
			return file;

		file = new File(getLogPath());
		file.mkdirs();
		file = new File(path);
		file.createNewFile();
		return file;
	}

	private static SimpleDateFormat dateFormat = new SimpleDateFormat(
			"yyyy-MM-dd HH:mm:ss SSS");
}
