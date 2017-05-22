package com.boyaa.ending.database;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

public class EndingDBHelper extends SQLiteOpenHelper {  
	
	private static final String DATABASE_NAME = "endgate.db";  
    private static final int DATABASE_VERSION = 1;  
    
    public EndingDBHelper(Context context) {  
        super(context, DATABASE_NAME, null, DATABASE_VERSION);  
    }
    
    //数据库第一次被创建时onCreate会被调用  
    @Override  
    public void onCreate(SQLiteDatabase db) {  
        db.execSQL("CREATE TABLE IF NOT EXISTS Gate" +
                "(id INTEGER PRIMARY KEY AUTOINCREMENT, tid INTEGER, isNeedPay INTEGER, progress INTEGER, subCount INTEGER, str TEXT)");
        
        db.execSQL("CREATE TABLE IF NOT EXISTS SubGate" +  
                "(id INTEGER PRIMARY KEY AUTOINCREMENT, tid INTEGER, sort INTEGER, str TEXT)");
    }
  
    @Override  
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {  
        
    }
}  