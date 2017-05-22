package com.boyaa.ending.database;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

public class EndingAccountDBHelper extends SQLiteOpenHelper {
	
	private static final String DATABASE_NAME = "endingaccount.db";  
    private static final int DATABASE_VERSION = 1;  
    
    public EndingAccountDBHelper(Context context) {
        super(context, DATABASE_NAME, null, DATABASE_VERSION);  
    }
    
    //数据库第一次被创建时onCreate会被调用  
    @Override
    public void onCreate(SQLiteDatabase db) {
        db.execSQL("CREATE TABLE IF NOT EXISTS EndingAccount" +
                "(id INTEGER PRIMARY KEY AUTOINCREMENT, uid INTEGER, tid INTEGER, isNeedPay INTEGER, progress INTEGER)");
    }
  
    @Override  
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {  
        
    }
}
