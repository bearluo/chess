package com.boyaa.entity.update;

import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;

/**
 * 下载记录数据访问对象
 * @author junmeng
 */
public class RefactorDownloadLogDao {
	private static final String TAG = RefactorDownloadLogDao.class.getSimpleName();
	
	private RefactorDownloadDBOpenHelper openHelper;

	public RefactorDownloadLogDao(Context context) {
		openHelper = new RefactorDownloadDBOpenHelper(context);
	}
	
	public List<RefactorDownloadedTaskEntity> getDownloadedRecord(String downloadUrlStr) {
		
		SQLiteDatabase db = openHelper.getReadableDatabase();
		Cursor cursor = db.rawQuery("select "
				+ RefactorDownloadDBOpenHelper.COL_THREAD_ID + ", "
				+ RefactorDownloadDBOpenHelper.COL_SAVE_FILE_PATH + ", "
				+ RefactorDownloadDBOpenHelper.COL_DOWNLOADED_SIZE + ", "
				+ RefactorDownloadDBOpenHelper.COL_LAST_MODIFY_TIME + " from "
				+ RefactorDownloadDBOpenHelper.DB_TABLE_NAME + " where "
				+ RefactorDownloadDBOpenHelper.COL_DOWNLOAD_URL_STR + "=?",
				new String[] { downloadUrlStr });
		
		List<RefactorDownloadedTaskEntity> recordList = new LinkedList<RefactorDownloadedTaskEntity>();
		while(cursor.moveToNext()){
			RefactorDownloadedTaskEntity entity = new RefactorDownloadedTaskEntity();
			entity.setDownloadUrlStr(downloadUrlStr);
			entity.setThreadId(cursor.getInt(cursor.getColumnIndex(RefactorDownloadDBOpenHelper.COL_THREAD_ID)));
			entity.setSaveFilePath(cursor.getString(cursor.getColumnIndex(RefactorDownloadDBOpenHelper.COL_SAVE_FILE_PATH)));
			entity.setDownloadedBlockSize(cursor.getInt(cursor.getColumnIndex(RefactorDownloadDBOpenHelper.COL_DOWNLOADED_SIZE)));
			entity.setLastModifiedTime(Long.valueOf(cursor.getString(cursor.getColumnIndex(RefactorDownloadDBOpenHelper.COL_LAST_MODIFY_TIME))));
			recordList.add(entity);
		}
		cursor.close();
		db.close();
		
		return recordList;
	}
	
	public void createDownloadRecord(Map<Integer, RefactorDownloadedTaskEntity> map, String modifyTimeStamp){
		SQLiteDatabase db = openHelper.getWritableDatabase();
		db.beginTransaction();
		
		try{
			for(Map.Entry<Integer, RefactorDownloadedTaskEntity> entry : map.entrySet()){
				RefactorDownloadedTaskEntity entity = entry.getValue();
				db.execSQL("insert into " + RefactorDownloadDBOpenHelper.DB_TABLE_NAME
						+ "(" + RefactorDownloadDBOpenHelper.COL_DOWNLOAD_URL_STR + ", "
						+ RefactorDownloadDBOpenHelper.COL_SAVE_FILE_PATH + ", "
						+ RefactorDownloadDBOpenHelper.COL_THREAD_ID + ", "
						+ RefactorDownloadDBOpenHelper.COL_DOWNLOADED_SIZE + ", "
						+ RefactorDownloadDBOpenHelper.COL_LAST_MODIFY_TIME
						+ ") values(?,?,?,?,?)",
						new Object[] {
								entity.getDownloadUrlStr(),
								entity.getSaveFilePath(),
								entity.getThreadId(),
								entity.getDownloadedBlockSize(),
								modifyTimeStamp});
			}
			
			db.setTransactionSuccessful();
		}finally{
			db.endTransaction();
		}
		
		db.close();
	}
	
	public void updateDownloadRecord(Map<Integer, RefactorDownloadedTaskEntity> map, String modifyTimeStamp){
		
		SQLiteDatabase db = openHelper.getWritableDatabase();
		db.beginTransaction();
		
		try{
			for(Map.Entry<Integer, RefactorDownloadedTaskEntity> entry : map.entrySet()){
				RefactorDownloadedTaskEntity entity = entry.getValue();
				db.execSQL("update " + RefactorDownloadDBOpenHelper.DB_TABLE_NAME
						+ " set " 
						+ RefactorDownloadDBOpenHelper.COL_DOWNLOADED_SIZE + "=?, "
						+ RefactorDownloadDBOpenHelper.COL_LAST_MODIFY_TIME + "=? "
						+ " where "
						+ RefactorDownloadDBOpenHelper.COL_DOWNLOAD_URL_STR + "=? and "
						+ RefactorDownloadDBOpenHelper.COL_THREAD_ID + "=?",
						new Object[] {
							entity.getDownloadedBlockSize(),
							modifyTimeStamp,
							entity.getDownloadUrlStr(),
							entity.getThreadId()});
			}
			
			db.setTransactionSuccessful();
		}finally{
			db.endTransaction();
		}
		
		db.close();
	}
	
	public void clearDownloadedRecord(String downloadUrlStr){
		SQLiteDatabase db = openHelper.getWritableDatabase();
		db.execSQL("delete from " + RefactorDownloadDBOpenHelper.DB_TABLE_NAME
				+ " where " + RefactorDownloadDBOpenHelper.COL_DOWNLOAD_URL_STR + "=?",
				new Object[] { downloadUrlStr });
		db.close();
	}
	
	public void clearDownloadedRecordBefore(String modifyTimeStamp) {
		SQLiteDatabase db = openHelper.getWritableDatabase();
		db.execSQL("delete from " + RefactorDownloadDBOpenHelper.DB_TABLE_NAME
				+ " where " + RefactorDownloadDBOpenHelper.COL_LAST_MODIFY_TIME + "<?",
				new Object[] {modifyTimeStamp});
		db.close();
	}
}
