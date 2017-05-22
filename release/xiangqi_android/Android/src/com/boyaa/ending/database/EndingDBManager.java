package com.boyaa.ending.database;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;

import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.ending.model.Entity;
import com.boyaa.ending.model.Gate;
import com.boyaa.ending.model.SubGate;

/**
 * 用于操作残局数据库
 */
public class EndingDBManager {
    

//	private EndingDBHelper helper;  
    private SQLiteDatabase db; 
    public static final String END_DB = "/endgate.db";

    private static EndingDBManager instance; 


    private EndingDBManager(Context context) {
//
//        helper = new EndingDBHelper(context);
//        db = helper.getWritableDatabase();
//        
        //使用已存在的数据库
        db = SQLiteDatabase.openOrCreateDatabase(Game.mActivity.getFilesDir() + END_DB, null);
    }
    
    public synchronized static EndingDBManager getInstance(){
    	if(instance == null){
    		instance = new EndingDBManager(Game.mActivity);
    	}
    	return instance;
    }
    
    /**
     * 插入or更新数据
     * @param entity 
     */
    public void insertOrUpdate(Entity entity){
    	
    	if(entity instanceof Gate){
    		Gate g = (Gate)entity;
    		Cursor cursor = db.rawQuery("SELECT * FROM Gate where tid=?",new String[] { String.valueOf(g.tid)});
    		if(cursor.moveToNext()){//更新
    			 db.execSQL("update Gate set str=?,subCount=? where tid=?",  new Object[] { g.str,g.subCount,g.tid});	
    		}else{
    			 db.execSQL("INSERT INTO Gate VALUES(null, ?, ?, ?, ?, ?)", new Object[]{ g.tid, g.isNeedPay, g.progress, g.subCount, g.str});
    		}
    		cursor.close();
    	}else if(entity instanceof SubGate){
    		SubGate sg = (SubGate)entity;
    		Cursor cursor = db.rawQuery("SELECT * FROM SubGate where tid=? and sort=?",new String[] { String.valueOf(sg.tid),String.valueOf(sg.sort) });
    				
    		if(cursor.moveToNext()){//更新
    			db.execSQL("update SubGate set str=? where tid=? and sort=?",  new Object[] { sg.str,sg.tid,sg.sort});
    		}else{//插入
    			db.execSQL("INSERT INTO SubGate VALUES(null, ?, ?, ?)", new Object[]{sg.tid,sg.sort,sg.str});
    		}
    		
    		cursor.close();
    	}
    }
    
    
    /** 
     * 插入or更新数据
     * @param entitys 
     */  
    public void insertOrUpdate(List<Entity> entitys) {  
		
        db.beginTransaction();  //开始事务  
        try {
            for (Entity e : entitys) {
            	insertOrUpdate(e);
            }
            db.setTransactionSuccessful();  //设置事务成功完成  
        } finally {  
            db.endTransaction();    //结束事务  
        }  
    }

    /**
     * 更新大关卡数据
     * @param gate 
     */
    public void updateGate(Gate gate) {
        db.execSQL("update Gate set isNeedPay=?,progress=? where tid=?",  
        		new Object[] { gate.isNeedPay, gate.progress, gate.tid});  
    }
    
    /**
     * 删除大关数据 
     * @param tids
     */
    public void deleteGate(Integer... tids) {  
        if (tids.length > 0) {  
            StringBuffer sb = new StringBuffer();  
            for (Integer tid : tids) {  
                sb.append('?').append(',');  
            }
            sb.deleteCharAt(sb.length() - 1);
            db.execSQL("delete from Gate where tid in(" + sb.toString()  
                            + ")", tids);  
        }
    }
 
    /**
     * 读取所有大关卡数据
     */
    public List<Gate> findAllGate(){
    	ArrayList<Gate> gateList = new ArrayList<Gate>();
    	Cursor c = db.rawQuery("SELECT * FROM Gate", null);  
    	while (c.moveToNext()) {	  
    	   Gate gate = new Gate();  
    	   gate.id = c.getInt(c.getColumnIndex("id"));  
    	   gate.tid = c.getInt(c.getColumnIndex("tid"));
    	   gate.isNeedPay = c.getInt(c.getColumnIndex("isNeedPay"));
    	   gate.progress = c.getInt(c.getColumnIndex("progress"));
    	   gate.subCount = c.getInt(c.getColumnIndex("subCount"));
    	   gate.str = c.getString(c.getColumnIndex("str"));  
    	   gateList.add(gate);  
    	}
    	c.close();  
    	return gateList;
    }
    
    /**
     * 查找小关卡
     * @param tid
     * @param sort
     */
    public SubGate findSubGateByTidAndSort(int tid,int sort){
    	ArrayList<SubGate> subGateList = new ArrayList<SubGate>();
    	Cursor c = db.rawQuery("SELECT * FROM SubGate where tid=? and sort=?",new String[] { String.valueOf(tid),String.valueOf(sort) });  
    	while (c.moveToNext()) {
    	   SubGate subGate = new SubGate();  
    	   subGate.id = c.getInt(c.getColumnIndex("id"));  
    	   subGate.tid = c.getInt(c.getColumnIndex("tid"));  
    	   subGate.sort = c.getInt(c.getColumnIndex("sort"));
    	   subGate.str = c.getString(c.getColumnIndex("str"));  
    	   subGateList.add(subGate);
    	}
    	c.close();  
    	if(subGateList.size() > 0){
    		return subGateList.get(0);
    	}else{
    		return null;
    	}
    }
    
    /**
     * 查找某一大关卡的所有小关卡
     * @param tid
     */
    public List<SubGate> findSubGateByTid(int tid){
    	ArrayList<SubGate> subGateList = new ArrayList<SubGate>();
    	Cursor c = db.rawQuery("SELECT * FROM SubGate where tid=?",new String[] { String.valueOf(tid) });  
    	while (c.moveToNext()) {
    	   SubGate subGate = new SubGate();  
    	   subGate.id = c.getInt(c.getColumnIndex("id"));  
    	   subGate.tid = c.getInt(c.getColumnIndex("tid"));  
    	   subGate.sort = c.getInt(c.getColumnIndex("sort"));
    	   subGate.str = c.getString(c.getColumnIndex("str"));  
    	   subGateList.add(subGate);  
    	}
    	c.close();
    	return subGateList;
    }
    
    /** 
     * close database 
     */  
    public void closeDB() {  
        db.close();  
    }  
}  