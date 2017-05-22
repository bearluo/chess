package com.boyaa.ending.database;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;

import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.ending.model.EndingAccount;
import com.boyaa.ending.model.SubGate;

public class EndingAccountDBManager {
	
	private EndingAccountDBHelper helper;  
    private SQLiteDatabase db; 

    private static EndingAccountDBManager instance; 
    
    private EndingAccountDBManager(Context context) {  
        helper = new EndingAccountDBHelper(context);
        db = helper.getWritableDatabase();
    }
    
    public synchronized static EndingAccountDBManager getInstance(){
    	if(instance == null){
    		instance = new EndingAccountDBManager(Game.mActivity);
    	}
    	return instance;
    }
    
    public void insertOrUpdate(EndingAccount account){
    	Cursor cursor = db.rawQuery("SELECT * FROM EndingAccount where uid=? and tid=?",new String[] { String.valueOf(account.uid) ,String.valueOf(account.tid)});
	
		if(cursor.moveToNext()){//更新
			updateEndingAccount(account);	
		}else{
			 db.execSQL("INSERT INTO EndingAccount VALUES(null, ?, ?, ?, ?)", new Object[]{ account.uid, account.tid, account.isNeedPay, account.progress});
		}
    	cursor.close();
    }
    
    public void insertOrUpdate(List<EndingAccount> accounts) {  
        db.beginTransaction();  //开始事务  
        try {
            for (EndingAccount e : accounts) {
            	insertOrUpdate(e);
            }
            db.setTransactionSuccessful();  //设置事务成功完成  
        } finally {  
            db.endTransaction();    //结束事务  
        }
    }

    private void updateEndingAccount(EndingAccount account) {
        db.execSQL("update EndingAccount set isNeedPay=?,progress=? where uid=? and tid=?",  
        		new Object[] { account.isNeedPay, account.progress, account.uid, account.tid});  
    }
    
    public EndingAccount findAccountByUidAndTid(int uid,int tid){
    	ArrayList<EndingAccount> accountList = new ArrayList<EndingAccount>();
    	Cursor c = db.rawQuery("SELECT * FROM EndingAccount where uid=? and tid=?",new String[] { String.valueOf(uid),String.valueOf(tid)});  
    	while (c.moveToNext()) {
    	   EndingAccount ea = new EndingAccount();  
    	   ea.id = c.getInt(c.getColumnIndex("id"));
    	   ea.uid = c.getInt(c.getColumnIndex("uid"));
    	   ea.tid = c.getInt(c.getColumnIndex("tid"));  
    	   ea.isNeedPay = c.getInt(c.getColumnIndex("isNeedPay"));
    	   ea.progress = c.getInt(c.getColumnIndex("progress"));  
    	   accountList.add(ea);
    	}
    	c.close();  
    	if(accountList.size() > 0){
    		return accountList.get(0);
    	}else{
    		return null;
    	}
    }
    
    /**
     * 查找对应UID所有的数据
     * @param uid
     */
    public List<EndingAccount> findEndingAccountByUid(int uid){
    	ArrayList<EndingAccount> endingAccountList = new ArrayList<EndingAccount>();
    	Cursor c = db.rawQuery("SELECT * FROM EndingAccount where uid=?",new String[] { String.valueOf(uid) });  
    	while (c.moveToNext()) {
    	   EndingAccount ea = new EndingAccount();  
    	   ea.id = c.getInt(c.getColumnIndex("id"));
    	   ea.uid = c.getInt(c.getColumnIndex("uid"));
    	   ea.tid = c.getInt(c.getColumnIndex("tid"));  
    	   ea.isNeedPay = c.getInt(c.getColumnIndex("isNeedPay"));
    	   ea.progress = c.getInt(c.getColumnIndex("progress"));  
    	   endingAccountList.add(ea);  
    	}
    	c.close();
    	return endingAccountList;
    }
}
