package com.boyaa.db;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

public class DBHelper extends SQLiteOpenHelper {
	private static final int VERSION = 2;//数据库版本

	private static final String NAME = "boyaa_pwall.db";
	public DBHelper(Context context) {
		super(context, NAME, null, VERSION);
	}

	@Override
	public void onCreate(SQLiteDatabase db) {
		db.beginTransaction();
		try {
			db.execSQL(APKInfo.getCreateTableSQL());
			db.execSQL(APKItem.getCreateTableSQL());
			db.execSQL(ByGame.getCreateTableSQL());
			db.execSQL(SgGame.getCreateTableSQL());

		
//			db.execSQL(UpdateTime.getCreateTableSQL());
//			db.execSQL(UserInfo.getCreateTableSQL());//version2.0
//			db.execSQL(UserFeedBack.getCreateTableSQL());//version2.0
//			db.execSQL(InstallAppInfo.getCreateTableSQL());//version2.0
			db.setTransactionSuccessful();
		} finally {
			db.endTransaction();
		}
	}

	@Override
	public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
		db.beginTransaction();
		try {
			db.execSQL("DROP TABLE IF EXISTS " + ByGame.TABLE_NAME);
//			db.execSQL("DROP TABLE IF EXISTS " + HallGame.TABLE_NAME);
			db.execSQL(ByGame.getCreateTableSQL());
			db.execSQL(SgGame.getCreateTableSQL());
//			db.execSQL(HallGame.getCreateTableSQL());

			if (oldVersion == 1) {
				db.execSQL(UserInfo.getCreateTableSQL());
//				db.execSQL(UserFeedBack.getCreateTableSQL());
				db.execSQL(InstallAppInfo.getCreateTableSQL());
			}
			db.setTransactionSuccessful();
		} finally {
			db.endTransaction();
		}
	}
	
//	/** 恢复数据，可减少字段 */
//	private void upgrade(SQLiteDatabase db, final int oldVersion, final int newVersion) {
//		//1、改成临时表
//		rename2TempTableName(db, Game.TABLE_NAME);
//		
//		//2、创建新表
//		db.execSQL(Game.getCreateTableSQL());
//		
//		//3、导入数据
//		db.execSQL("INSERT INTO " + Game.TABLE_NAME + "(_id,name,image,big_image,url,packagename,onlinecount,size,version,version_code,type,desc,state,order_by,update_state) "
//				 						 + "SELECT (game_id,name,image,big_image,url,packagename,onlinecount,size,version,version_code,type,desc,state,order_by,update_state) FROM " + TEMP_SUFFIX + Game.TABLE_NAME);
//		//4、删除临时表
//		deleteTempTable(db, Game.TABLE_NAME);
//	}

	//升级参数定义
//	private final String TEMP_SUFFIX = "temp_";
//	
//	private void rename2TempTableName(SQLiteDatabase db, String originTableName) {
//		db.execSQL("ALTER TABLE " + originTableName + " RENAME TO " + TEMP_SUFFIX + originTableName);
//	}
	
//	private void deleteTempTable(SQLiteDatabase db, String originTableName) {
//		db.execSQL("DROP TABLE IF EXISTS " + TEMP_SUFFIX + originTableName);
//	}
	
	
	public void reCreateTable(SQLiteDatabase db, String TableName) {
		db.execSQL("DROP TABLE IF EXISTS " + TableName);
		if (TableName == ByGame.TABLE_NAME){
			db.execSQL(ByGame.getCreateTableSQL());
		}else if (TableName == SgGame.TABLE_NAME){
			db.execSQL(SgGame.getCreateTableSQL());
		}
	}
	/** 下载的APK包信息 */
	public static class APKInfo {
		//表名
    	public static final String TABLE_NAME = "apk_info";
    	
    	//字段名
    	public static final String _ID = "_id";
    	public static final String URL = "url";
    	public static final String APK_FILE_SIZE = "apk_file_size";
    	public static final String APK_FILE_PATH = "apk_file_path";
    	public static final String STATE = "state";

    	//建表语句
    	public static String getCreateTableSQL() {
    		return new StringBuilder()
    		.append("create table ").append(TABLE_NAME)
    		.append("(")
    		.append(_ID).append(" integer PRIMARY KEY AUTOINCREMENT,")
    		.append(URL).append(" char,")
    		.append(APK_FILE_SIZE).append(" integer,")
    		.append(APK_FILE_PATH).append(" char,")
    		.append(STATE).append(" integer")
    		.append(")")
    		.toString();
    	}
	}


	/** 用户信息  version 2.0*/
	public static class UserInfo {
		//表名
    	public static final String TABLE_NAME = "user_info";
    	
    	//字段名
    	public static final String _ID = "_id";
    	public static final String TYPE = "type";
    	public static final String O_TOKEN = "o_token";
    	public static final String O_ID = "o_id";
    	public static final String O_EXTRA = "o_extra";
    	public static final String HEAD_IMAGE = "head_image";
        public static final String NICKNAME = "nickname";
    	public static final String SEX = "sex";
    	public static final String PASSWORD = "password";
    	public static final String ACCOUNT = "account";
    	public static final String AGE = "age";
		public static final String EMAIL = "email";
		public static final String STATE = "state";
		public static final String HALL_USERID = "hall_userid";
    	//建表语句
    	public static String getCreateTableSQL() {
    		return new StringBuilder()
    		.append("create table ").append(TABLE_NAME)
    		.append("(")
    		.append(_ID).append(" integer PRIMARY KEY,")
    		.append(TYPE).append(" integer,")
    		.append(O_ID).append(" char,")
    		.append(O_EXTRA).append(" char,")
    		.append(O_TOKEN).append(" char,")
    		.append(NICKNAME).append(" char,")
    		.append(HEAD_IMAGE).append(" char,")
    		.append(SEX).append(" integer,")
    		.append(PASSWORD).append(" char,")
    		.append(ACCOUNT).append(" char,")
    		.append(EMAIL).append(" char,")
    		.append(STATE).append(" integer DEFAULT 0,")
    		.append(HALL_USERID).append(" integer DEFAULT 0,")
    		.append(AGE).append(" integer")
    		.append(")")
    		.toString();
    	}
    	
	}

	/** 下载的APK包信息 */
	public static class APKItem {
		//表名
    	public static final String TABLE_NAME = "apk_item";
    	
    	//字段名
    	public static final String _ID = "_id";
    	public static final String INFO_ID = "info_id";
    	public static final String START_POS = "start_pos";
    	public static final String END_POS = "end_pos";
    	public static final String COMPLETE_SIZE = "compelete_size";
    	public static final String STATE = "state";

    	//建表语句
    	public static String getCreateTableSQL() {
    		return new StringBuilder()
    		.append("create table ").append(TABLE_NAME)
    		.append("(")
    		.append(_ID).append(" integer PRIMARY KEY AUTOINCREMENT,")
    		.append(INFO_ID).append(" integer,")
    		.append(START_POS).append(" integer,")
    		.append(END_POS).append(" integer,")
    		.append(COMPLETE_SIZE).append(" integer,")
    		.append(STATE).append(" integer")
    		.append(")")
    		.toString();
    	}
	}
	
	public static class ByGame {
		//表名
    	public static final String TABLE_NAME = "bygame";
    	
    	//字段名
    	public static final String _ID = "_id";
    	public static final String GAME_ID = "game_id";
    	public static final String NAME = "name";
    	public static final String IMAGE = "image";
    	public static final String BIGIMAGE = "bigimage";
    	public static final String URL = "url";
    	public static final String PACKAGENAME = "packagename";
    	public static final String SHORTDESC = "shortdesc";
    	public static final String SIZE = "size";
    	public static final String VERSION = "version";
    	public static final String VERSIONCODE = "versioncode";
    	public static final String TYPE = "type";
    	public static final String DESC = "desc";
    	public static final String STATE = "state";
    	public static final String POINTS = "points";
//    	private static final String ORDER = "orderby";//预留，为以后全部游戏列表做排序使用
    	
    	//Version 2
    	public static final String UPDATE_STATE = "updatestate";//0：无需更新；1：需要更新；2：已更新且未安装
    	public static final String MINE_GAME = "minegame";//我的游戏


    	//建表语句
    	public static String getCreateTableSQL() {
    		return new StringBuilder()
    		.append("create table ").append(TABLE_NAME)
    		.append("(")
    		.append(_ID).append(" integer PRIMARY KEY, ")
    		.append(GAME_ID).append(" integer,")
    		.append(NAME).append(" char, ")
    		.append(URL).append(" char, ")
    		.append(IMAGE).append(" char, ")
    		.append(BIGIMAGE).append(" char, ")
    		.append(PACKAGENAME).append(" char, ")
    		.append(SHORTDESC).append(" char, ")
    		.append(SIZE).append(" char, ")
    		.append(VERSION).append(" char, ")
    		.append(VERSIONCODE).append(" integer, ")
    		.append(TYPE).append(" char, ")
    		.append(DESC).append(" char, ")
    		.append(STATE).append(" char, ")
    		.append(POINTS).append(" char ")
    		//.append(UPDATE_STATE).append(" integer,")
    		//.append(MINE_GAME).append(" char,")
    		//.append(ORDER).append(" char")
    		.append(")")
    		.toString();
    	}
	}
	
	public static class SgGame {
		//表名
    	public static final String TABLE_NAME = "sggame";
    	
    	//字段名
    	public static final String _ID = "_id";
    	public static final String GAME_ID = "game_id";
    	public static final String NAME = "name";
    	public static final String IMAGE = "image";
    	public static final String BIGIMAGE = "bigimage";
    	public static final String URL = "url";
    	public static final String PACKAGENAME = "packagename";
    	public static final String SHORTDESC = "shortdesc";
    	public static final String SIZE = "size";
    	public static final String VERSION = "version";
    	public static final String VERSIONCODE = "versioncode";
    	public static final String TYPE = "type";
    	public static final String DESC = "desc";
    	public static final String STATE = "state";
    	public static final String POINTS = "points";
//    	private static final String ORDER = "orderby";//预留，为以后全部游戏列表做排序使用
    	
    	//Version 2
    	public static final String UPDATE_STATE = "updatestate";//0：无需更新；1：需要更新；2：已更新且未安装
    	public static final String MINE_GAME = "minegame";//我的游戏

    	//建表语句
    	public static String getCreateTableSQL() {
    		return new StringBuilder()
    		.append("create table ").append(TABLE_NAME)
    		.append("(")
    		.append(_ID).append(" integer PRIMARY KEY, ")
    		.append(GAME_ID).append(" integer,")
    		.append(NAME).append(" char, ")
    		.append(URL).append(" char, ")
    		.append(IMAGE).append(" char, ")
    		.append(BIGIMAGE).append(" char, ")
    		.append(PACKAGENAME).append(" char, ")
    		.append(SHORTDESC).append(" char, ")
    		.append(SIZE).append(" char, ")
    		.append(VERSION).append(" char, ")
    		.append(VERSIONCODE).append(" integer, ")
    		.append(TYPE).append(" char, ")
    		.append(DESC).append(" char, ")
    		.append(STATE).append(" char, ")
    		.append(POINTS).append(" char ")
    		//.append(UPDATE_STATE).append(" integer,")
    		//.append(MINE_GAME).append(" char,")
    		//.append(ORDER).append(" char")
    		.append(")")
    		.toString();
    	}
	}
	


	public static class UpdateTime {
		//表名
    	public static final String TABLE_NAME = "update_time";
    	
    	//字段名
    	public static final String _ID = "_id";
    	public static final String UPDATE_TABLE = "updatetable";
    	public static final String UPDATE_TIME = "updatetime";

    	//建表语句
    	public static String getCreateTableSQL() {
    		return new StringBuilder()
    		.append("create table ").append(TABLE_NAME)
    		.append("(")
    		.append(_ID).append(" integer PRIMARY KEY AUTOINCREMENT,")
    		.append(UPDATE_TABLE).append(" char,")
    		.append(UPDATE_TIME).append(" long")
    		.append(")")
    		.toString();
    	}
	}
	
	public static class InstallAppInfo {
		//表名
    	public static final String TABLE_NAME = "install_app_info";
    	//字段名
    	public static final String _ID = "_id";
    	public static final String GAME_ID = "game_id";
    	public static final String STATE = "state";

    	//建表语句
    	public static String getCreateTableSQL() {
    		return new StringBuilder()
	    		.append("create table ").append(TABLE_NAME)
	    		.append("(")
	    		.append(_ID).append(" integer PRIMARY KEY AUTOINCREMENT,")
	    		.append(GAME_ID).append(" long,")
	    		.append(STATE).append(" integer")
	    		.append(")")
	    		.toString();
    	}
	}
}
