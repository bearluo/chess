package com.boyaa.db;

import java.util.ArrayList;
import java.util.List;

import android.content.ContentValues;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;

import com.boyaa.log.Log;

import com.boyaa.pointwall.PointWallActivity;
import com.boyaa.apkdownload.ApkInfo;
import com.boyaa.apkdownload.ApkInfo.ApkItem;
import com.boyaa.db.DBHelper.APKInfo;
import com.boyaa.db.DBHelper.APKItem;

public class APKInfoDao extends Dao {
    
    public static final String TAG = APKInfoDao.class.getSimpleName();
    
	private DBHelper mDBHelper;
	public APKInfoDao() {
		PointWallActivity.getInstance();
		mDBHelper = PointWallActivity.getDBHelper();
	}

    /** 查看数据库中是否有数据 */
    public boolean hasApkInfo(String apkUrl) {
        SQLiteDatabase db = mDBHelper.getReadableDatabase();
        db.beginTransaction();
        Cursor cursor = null;
        int count = 0;
        try {
        	String sql = new StringBuilder().append("select count(*) from ")
        			.append(APKInfo.TABLE_NAME)
        			.append(" where ")
        			.append(APKInfo.URL)
        			.append(" = ?")
        			.toString();
        	cursor = db.rawQuery(sql, new String[] {apkUrl});
        	cursor.moveToFirst();

        	count = cursor.getInt(0);

			db.setTransactionSuccessful();
		} finally {
			db.endTransaction();
        	if (cursor != null) cursor.close();
		}
        return count > 0;
    }

    /** 查询ApkInfo */
    public ApkInfo getApkInfo(String apkUrl) {
        SQLiteDatabase db = mDBHelper.getReadableDatabase();
        db.beginTransaction();
        Cursor cursor = null;
        ApkInfo apkInfo = null;
        try {
        	String sql = new StringBuilder().append("SELECT * FROM ")
        			.append(APKInfo.TABLE_NAME)
        			.append(" where ")
        			.append(APKInfo.URL)
        			.append(" = ?")
        			.toString();
        	cursor = db.rawQuery(sql, new String[] {apkUrl});
        	if (cursor.moveToFirst()) {
        		long id = cursor.getLong(cursor.getColumnIndex(APKInfo._ID));
        		int apkFileSize = cursor.getInt(cursor.getColumnIndex(APKInfo.APK_FILE_SIZE));
        		int state = cursor.getInt(cursor.getColumnIndex(APKInfo.STATE));
        		String apkFilePath = cursor.getString(cursor.getColumnIndex(APKInfo.APK_FILE_PATH));
        		apkInfo = new ApkInfo(apkUrl, apkFileSize, 0, apkFilePath);
        		apkInfo._id = id;
        		apkInfo.state = state;
        	}
			db.setTransactionSuccessful();
		} finally {
			db.endTransaction();
        	if (cursor != null) cursor.close();
		}
        if (apkInfo != null) {
        	apkInfo.apkItemList = getApkItems(apkInfo);
        }
        return apkInfo;
    }

    /** 查询ApkInfo */
    public List<ApkItem> getApkItems(ApkInfo apkInfo) {
        SQLiteDatabase db = mDBHelper.getReadableDatabase();
        db.beginTransaction();
        Cursor cursor = null;
        List<ApkItem> itemList = new ArrayList<ApkItem>();
        String sql = new StringBuilder().append("SELECT * FROM ")
        		.append(APKItem.TABLE_NAME)
        		.append(" where ")
        		.append(APKItem.INFO_ID)
        		.append(" = ?")
        		.toString();
        try {
        	cursor = db.rawQuery(sql, new String[] {String.valueOf(apkInfo._id)});
        	while (cursor.moveToNext()) {
        		ApkItem apkItem = new ApkItem();
        		apkItem._id = cursor.getLong(cursor.getColumnIndex(APKItem._ID));
        		apkItem.startPos = cursor.getInt(cursor.getColumnIndex(APKItem.START_POS));
        		apkItem.endPos = cursor.getInt(cursor.getColumnIndex(APKItem.END_POS));
        		apkItem.completeSize = cursor.getInt(cursor.getColumnIndex(APKItem.COMPLETE_SIZE));
        		apkItem.state = cursor.getInt(cursor.getColumnIndex(APKItem.STATE));
        		apkItem.infoId = apkInfo._id;
        		apkItem.info = apkInfo;
        		itemList.add(apkItem);
        		Log.d("DB", "ApkItem _id:"+apkItem._id+" startPos:"+apkItem.startPos+" endPos:"+apkItem.endPos+" completeSize:"+apkItem.completeSize
        				+" state:"+apkItem.state+" infoId:"+apkItem.infoId);
        	}
			db.setTransactionSuccessful();
		} finally {
			db.endTransaction();
        	if (cursor != null) cursor.close();
		}
        return itemList;
    }

    /** 保存下载信息 */
    public long saveApkInfo(ApkInfo info) {
    	long infoId = -1;
        SQLiteDatabase db = mDBHelper.getWritableDatabase();
        db.beginTransaction();
        try {
    		ContentValues values = new ContentValues();
    		values.put(APKInfo.URL, info.apkUrl);
    		values.put(APKInfo.APK_FILE_SIZE, info.apkFileSize);
    		values.put(APKInfo.APK_FILE_PATH, info.apkFilePath);
    		values.put(APKInfo.STATE, info.state);
    		infoId = db.insert(APKInfo.TABLE_NAME, null, values);
    		info._id = infoId;
    		db.setTransactionSuccessful();
        } finally {
			db.endTransaction();
		}
        return infoId;
    }

    /** 保存下载项信息 */
    public void saveApkItem(List<ApkItem> items) {
        SQLiteDatabase db = mDBHelper.getWritableDatabase();
        db.beginTransaction();
        String sql = new StringBuilder().append("insert into ")
        		.append(APKItem.TABLE_NAME)
        		.append("(")
        		.append(APKItem.INFO_ID).append(",")
        		.append(APKItem.START_POS).append(",")
        		.append(APKItem.END_POS).append(",")
        		.append(APKItem.COMPLETE_SIZE).append(",")
        		.append(APKItem.STATE)
        		.append(") values (?,?,?,?,?)")
        		.toString();
        try {
        	for (ApkItem item : items) {
        		Object[] bindArgs = {item.infoId, item.startPos, item.endPos, item.completeSize, item.state};
        		db.execSQL(sql, bindArgs);
        	}
        	db.setTransactionSuccessful();
        } finally {
			db.endTransaction();
		}
    }
    /** 保存下载项信息 */
    public void saveApkItemRetunId(List<ApkItem> items) {
        SQLiteDatabase db = mDBHelper.getWritableDatabase();
        db.beginTransaction();
       /* String sql = new StringBuilder().append("insert into ")
        		.append(APKItem.TABLE_NAME)
        		.append("(")
        		.append(APKItem.INFO_ID).append(",")
        		.append(APKItem.START_POS).append(",")
        		.append(APKItem.END_POS).append(",")
        		.append(APKItem.COMPLETE_SIZE).append(",")
        		.append(APKItem.STATE)
        		.append(") values (?,?,?,?,?)")
        		.toString();*/
        try {
        	ContentValues values = new ContentValues();
        	/*for (ApkItem item : items) {
        		Object[] bindArgs = {item.infoId, item.startPos, item.endPos, item.completeSize, item.state};
        		db.execSQL(sql, bindArgs);
        	}*/
        	ApkItem item = null;
        	for (int i = 0; i < items.size(); i++) {
				values.clear();
				item = items.get(i);
				values.put(APKItem.INFO_ID, item.infoId);
				values.put(APKItem.START_POS, item.startPos);
				values.put(APKItem.END_POS, item.endPos);
				values.put(APKItem.COMPLETE_SIZE, item.completeSize);
				values.put(APKItem.STATE, item.state);
				item._id = db.insert(APKItem.TABLE_NAME,null , values);
				items.set(i, item);
			}
        	db.setTransactionSuccessful();
        } finally {
			db.endTransaction();
		}
    }
    /** 更新ApkInfo状态 */
    public void updataApkInfoState(ApkInfo info) {
        
        Log.d(TAG, "info.state = " + info.state);
        
	   	SQLiteDatabase db = mDBHelper.getWritableDatabase();
	   	db.beginTransaction();
	   	String sql = new StringBuilder().append("update ")
	   			 .append(APKInfo.TABLE_NAME)
	   			 .append(" set ")
	   			 .append(APKInfo.STATE).append(" = ?")
	   			 .append(" where ")
	   			 .append(APKInfo._ID).append(" = ?")
	   			 .toString();
	   	try {
	   		Object[] bindArgs = {info.state, info._id};
	   		db.execSQL(sql, bindArgs);
	   		db.setTransactionSuccessful();
	   	} finally {
	   		db.endTransaction();
		}
    }

    /** 查看数据库中是否有数据 */
    public int getApkInfoState(String apkUrl) {
        SQLiteDatabase db = mDBHelper.getReadableDatabase();
//        db.beginTransaction();
        Cursor cursor = null;
        int state = 0;
        String sql = new StringBuilder().append("select ")
        		.append(APKInfo.STATE)
        		.append(" from ")
        		.append(APKInfo.TABLE_NAME)
        		.append(" where ")
        		.append(APKInfo.URL)
        		.append(" = ?")
        		.toString();
        try {
        	cursor = db.rawQuery(sql, new String[] {apkUrl});
        	if (cursor.moveToFirst()) {
        		state = cursor.getInt(0);
        	}
//			db.setTransactionSuccessful();
		} finally {
//			db.endTransaction();
        	if (cursor != null) cursor.close();
		}
        return state;
    }

     /** 更新数据库中的下载信息 */
     public void updataApkItem(ApkItem item) {
    	 SQLiteDatabase db = mDBHelper.getWritableDatabase();
    	 db.beginTransaction();
    	 String sql = new StringBuilder().append("update ")
    			 .append(APKItem.TABLE_NAME)
    			 .append(" set ")
    			 .append(APKItem.COMPLETE_SIZE).append(" = ?,")
    			 .append(APKItem.STATE).append(" = ?")
    			 .append(" where ")
    			 .append(APKItem._ID).append(" = ?")
    			 .toString();
    	 try {
    		 Object[] bindArgs = {item.completeSize, item.state, item._id};
    		 db.execSQL(sql, bindArgs);
    		 db.setTransactionSuccessful();
    	 } finally {
 			db.endTransaction();
 		 }
     }

     public void deleteApkInfo(ApkInfo info) {
    	 if(info==null) return;
    	 
    	 SQLiteDatabase db = mDBHelper.getWritableDatabase();
         db.beginTransaction();
         try {
         	db.delete(APKInfo.TABLE_NAME, APKInfo._ID + " = ?", new String[] {String.valueOf(info._id)});
         	db.delete(APKItem.TABLE_NAME, APKItem.INFO_ID + " = ?", new String[] {String.valueOf(info._id)});
         	db.setTransactionSuccessful();
         } finally {
 			db.endTransaction();
 		 }
     }
     
     public void deleteApkItems(ApkInfo info) {
    	 SQLiteDatabase db = mDBHelper.getWritableDatabase();
         db.beginTransaction();
         try {
         	db.delete(APKItem.TABLE_NAME, APKItem.INFO_ID + " = ?", new String[] {String.valueOf(info._id)});
         	db.setTransactionSuccessful();
         } finally {
 			db.endTransaction();
 		 }
     }
}
