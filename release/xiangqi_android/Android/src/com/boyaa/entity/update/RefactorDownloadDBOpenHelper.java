package com.boyaa.entity.update;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

public class RefactorDownloadDBOpenHelper extends SQLiteOpenHelper {
	
	private static final String TAG = RefactorDownloadDBOpenHelper.class.getSimpleName();
	
	/**
	 * 版本号
	 */
	private static final int VERSION = 1;
	
	/**
	 * 数据库名称
	 */
	public static final String DB_NAME = "engineddz_download.db";
	
	/**
	 * 表名称
	 */
	public static final String DB_TABLE_NAME = "filedownlog";
	
	/**
	 * 自增长主键
	 */
	public static final String COL_ID = "_id";
	
	/**
	 * 下载路径，用于区分下载任务
	 */
	public static final String COL_DOWNLOAD_URL_STR = "downloadurlstr";
	
	/**
	 * 文件保存目录
	 */
	public static final String COL_SAVE_FILE_PATH = "savepath";
	
	/**
	 * 线程id，用于区分是那条线程
	 */
	public static final String COL_THREAD_ID = "threadid";
	
	/**
	 * 该条线程已下载数据长度
	 */
	public static final String COL_DOWNLOADED_SIZE = "downloadedsize";
	
	/**
	 * 用于记录上次修改时间
	 */
	public static final String COL_LAST_MODIFY_TIME = "modifytime";
	
	
	/**
	 * 构造器
	 * @param context
	 */
	public RefactorDownloadDBOpenHelper(Context context) {
		super(context, DB_NAME, null, VERSION);
	}
	
	@Override
	public void onCreate(SQLiteDatabase db) {
		db.execSQL("CREATE TABLE IF NOT EXISTS " + DB_TABLE_NAME + " (" + COL_ID
				+ " integer primary key autoincrement, "
				+ COL_DOWNLOAD_URL_STR + " varchar(100), "
				+ COL_SAVE_FILE_PATH + " varchar(100), "
				+ COL_THREAD_ID + " INTEGER, "
				+ COL_DOWNLOADED_SIZE + " INTEGER, "
				+ COL_LAST_MODIFY_TIME + " TEXT)");
	}

	@Override
	public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
		db.execSQL("DROP TABLE IF EXISTS " + DB_TABLE_NAME);
		onCreate(db);
	}
}