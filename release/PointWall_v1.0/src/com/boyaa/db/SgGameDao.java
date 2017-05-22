
package com.boyaa.db;

import java.util.ArrayList;
import java.util.List;

import android.content.ContentValues;
import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;

import com.boyaa.data.GameData;
import com.boyaa.data.InstallAppData;
import com.boyaa.db.DBHelper.InstallAppInfo;
import com.boyaa.db.DBHelper.SgGame;
import com.boyaa.db.DBHelper.UpdateTime;
import com.boyaa.log.Log;
import com.boyaa.pointwall.PointWallActivity;

public class SgGameDao extends Dao {
    private DBHelper mDBHelper;
    public SgGameDao() {
//       PointWallActivity.getInstance();
	mDBHelper = PointWallActivity.getDBHelper();
    }

    /** 查询GameData */
    public GameData getGameData(long id) {
        SQLiteDatabase db = mDBHelper.getReadableDatabase();
        db.beginTransaction();
        GameData gameData = null;
        try {
            gameData = getGameDataByGameId(db, id);
            db.setTransactionSuccessful();
        } finally {
            db.endTransaction();
        }
        return gameData;
    }

    public GameData getGameData(String url) {
        SQLiteDatabase db = mDBHelper.getReadableDatabase();
        db.beginTransaction();
        GameData gameData = null;
        try {
            gameData = getGameData(db, url);
            db.setTransactionSuccessful();
        } finally {
            db.endTransaction();
        }
        return gameData;
    }

    private GameData getGameDataByGameId(SQLiteDatabase db, long gameid) {
    	Cursor cursor = null;
        GameData gameData = null;
        String sql = new StringBuilder().append("SELECT * FROM ").append(SgGame.TABLE_NAME)
                .append(" where ").append(SgGame.GAME_ID).append(" = ?").toString();
        try {
            cursor = db.rawQuery(sql, new String[] {
                String.valueOf(gameid)
            });
            if (cursor.moveToFirst()) {
                gameData = parseGameData(cursor);
            }
        } finally {
            if (cursor != null)
                cursor.close();
        }
        return gameData;
    }

//    private GameData getGameDataById(SQLiteDatabase db, long id) {
//        Cursor cursor = null;
//        GameData gameData = null;
//        String sql = new StringBuilder().append("SELECT * FROM ").append(SgGame.TABLE_NAME)
//                .append(" where ").append(SgGame.GAME_ID).append(" = ?").toString();
//        try {
//            cursor = db.rawQuery(sql, new String[] {
//                String.valueOf(id)
//            });
//            if (cursor.moveToFirst()) {
//                gameData = parseGameData(cursor);
//            }
//        } finally {
//            if (cursor != null)
//                cursor.close();
//        }
//        return gameData;
//    }

    private GameData getGameData(SQLiteDatabase db, String url) {
        Cursor cursor = null;
        GameData gameData = null;
        String sql = new StringBuilder().append("SELECT * FROM ").append(SgGame.TABLE_NAME)
                .append(" where ").append(SgGame.URL).append(" = ?").toString();
        try {
            cursor = db.rawQuery(sql, new String[] {
                url
            });
            if (cursor.moveToFirst()) {
                gameData = parseGameData(cursor);
            }
        } finally {
            if (cursor != null)
                cursor.close();
        }
        return gameData;
    }

//    private List<GameData> getGameDataList(SQLiteDatabase db, List<Long> idList) {
//        StringBuilder builder = new StringBuilder().append("SELECT * FROM ")
//                .append(SgGame.TABLE_NAME).append(" where ").append(SgGame.GAME_ID).append(" in (");
//        for (int i = 0, count = idList.size(); i < count; i++) {
//            if (i > 0)
//                builder.append(",");
//            builder.append(idList.get(i));
//        }
//        builder.append(") and ").append(SgGame.STATE).append("!=").append(3);
//        String sql = builder.toString();
//        Cursor cursor = null;
//        List<GameData> list = new ArrayList<GameData>();
//        try {
//            cursor = db.rawQuery(sql, null);
//            while (cursor.moveToNext()) {
//                list.add(parseGameData(cursor));
//            }
//        } finally {
//            if (cursor != null)
//                cursor.close();
//        }
//        return list;
//    }

//    /** 查询多条BoyaaGameData数据 */
//    public List<GameData> getBoyaaGameDataList(int start, int length) {
//        SQLiteDatabase db = mDBHelper.getReadableDatabase();
//        db.beginTransaction();
//        List<GameData> gameDataList = null;
//        try {
//            gameDataList = getBoyaaGameDataList(db, start, length);
//            db.setTransactionSuccessful();
//        } finally {
//            db.endTransaction();
//        }
//        return gameDataList;
//    }

    /** 查询多条SuggestGameData数据 */
    public List<GameData> getSuggestGameDataList(int start, int length) {
        SQLiteDatabase db = mDBHelper.getReadableDatabase();
        db.beginTransaction();
        List<GameData> gameDataList = null;
        try {
            gameDataList = getSuggestGameDataList(db, start, length);
            db.setTransactionSuccessful();
        } finally {
            db.endTransaction();
        }
        return gameDataList;
    }

//    private List<GameData> getSuggestGameDataList(SQLiteDatabase db, int start, int length) {
//        Cursor cursor = null;
//        List<GameData> gameDataList = new ArrayList<GameData>();
//        try {
//
//            cursor = db.query(SgGame.TABLE_NAME, null, SgGame.MINE_GAME + ">0", null, null, null, null,
//                    start + "," + length);
//            while (cursor.moveToNext()) {
//                gameDataList.add(parseGameData(cursor));
//            }
//        } finally {
//            if (cursor != null)
//                cursor.close();
//        }
//        return gameDataList;
//    }

    private List<GameData> getSuggestGameDataList(SQLiteDatabase db, int start, int length) {
        Cursor cursor = null;
        List<GameData> gameDataList = new ArrayList<GameData>();
        try {

            cursor = db.query(SgGame.TABLE_NAME, null, null, null, null, null, null, start + ","
                    + length);
            while (cursor.moveToNext()) {
                gameDataList.add(parseGameData(cursor));
            }
        } finally {
            if (cursor != null)
                cursor.close();
        }
        return gameDataList;
    }

    private GameData parseGameData(Cursor cursor) {
        GameData gameData = new GameData();
        gameData.id = cursor.getLong(cursor.getColumnIndex(SgGame.GAME_ID));
        //gameData._id = cursor.getLong(cursor.getColumnIndex(SgGame._ID));
        gameData.name = cursor.getString(cursor.getColumnIndex(SgGame.NAME));
        gameData.image = cursor.getString(cursor.getColumnIndex(SgGame.IMAGE));
        gameData.bigimage = cursor.getString(cursor.getColumnIndex(SgGame.BIGIMAGE));
        gameData.packagename = cursor.getString(cursor.getColumnIndex(SgGame.PACKAGENAME));
        gameData.shortdesc = cursor.getString(cursor.getColumnIndex(SgGame.SHORTDESC));
        gameData.size = cursor.getString(cursor.getColumnIndex(SgGame.SIZE));
        gameData.url = cursor.getString(cursor.getColumnIndex(SgGame.URL));
        gameData.version = cursor.getString(cursor.getColumnIndex(SgGame.VERSION));
        gameData.versioncode = cursor.getInt(cursor.getColumnIndex(SgGame.VERSIONCODE));
        gameData.type = cursor.getInt(cursor.getColumnIndex(SgGame.TYPE));
        gameData.desc = cursor.getString(cursor.getColumnIndex(SgGame.DESC));
        gameData.state = cursor.getInt(cursor.getColumnIndex(SgGame.STATE));
        gameData.points = cursor.getString(cursor.getColumnIndex(SgGame.POINTS));
//        gameData.updateState = cursor.getInt(cursor.getColumnIndex(SgGame.UPDATE_STATE));
//        gameData.mineGame = cursor.getLong(cursor.getColumnIndex(SgGame.MINE_GAME));
        return gameData;
    }

//    /** 保存GameData */
//    private void saveGameData(GameData gameData) {
//        SQLiteDatabase db = mDBHelper.getWritableDatabase();
//        db.beginTransaction();
//        ContentValues values = new ContentValues();
//        values.put(SgGame.NAME, gameData.name);
//        values.put(SgGame._ID, gameData.id);
//        values.put(SgGame.IMAGE, gameData.image);
//        values.put(SgGame.BIGIMAGE, gameData.bigimage);
//        values.put(SgGame.PACKAGENAME, gameData.packagename);
//        values.put(SgGame.SHORTDESC, gameData.shortdesc);
//        values.put(SgGame.SIZE, gameData.size);
//        values.put(SgGame.URL, gameData.url);
//        values.put(SgGame.VERSION, gameData.version);
//        values.put(SgGame.VERSIONCODE, gameData.versioncode);
//        values.put(SgGame.TYPE, gameData.type);
//        values.put(SgGame.DESC, gameData.desc);
//        values.put(SgGame.STATE, gameData.state);
//        try {
//            db.insert(SgGame.TABLE_NAME, null, values);
//            db.setTransactionSuccessful();
//        } finally {
//            db.endTransaction();
//        }
//    }

    /** 保存全部GameData */
    public void saveGamesData(List<GameData> gamesDataList) {
        SQLiteDatabase db = mDBHelper.getWritableDatabase();
        db.beginTransaction();
        String insertSql = new StringBuilder().append("insert into ").append(SgGame.TABLE_NAME)
                .append("(").append(SgGame.GAME_ID).append(",").append(SgGame.NAME).append(",")
                //.append("(").append(SgGame.NAME).append(",")
                .append(SgGame.IMAGE).append(",").append(SgGame.BIGIMAGE).append(",")
                .append(SgGame.PACKAGENAME).append(",").append(SgGame.SHORTDESC).append(",")
                .append(SgGame.SIZE).append(",").append(SgGame.URL).append(",").append(SgGame.VERSION)
                .append(",").append(SgGame.VERSIONCODE).append(",").append(SgGame.TYPE).append(",")
                .append(SgGame.DESC).append(",").append(SgGame.STATE).append(",").append(SgGame.POINTS)
                .append(") values (?,?,?,?,?,?,?,?,?,?,?,?,?,?)").toString();
        try {

            for (GameData gameData : gamesDataList) {
                if (checkExist(db, String.valueOf(gameData.id))) {
                    // 更新数据
                    updateGameData(db, gameData);
                } else {

                    if (gameData.state == 3)
                        continue;

                    // 插入数据
                    Object[] bindArgs = {
                            gameData.id, gameData.name, gameData.image, gameData.bigimage,
                    		//gameData.name, gameData.image, gameData.bigimage,
                            gameData.packagename, gameData.shortdesc, gameData.size,
                            gameData.url, gameData.version, gameData.versioncode, gameData.type,
                            gameData.desc, gameData.state, gameData.points
                    };
                    try {
                    	db.execSQL(insertSql, bindArgs);
                    	}
                    catch(SQLException E){

                    }
                 
                    
                }
            }
            db.setTransactionSuccessful();
        } finally {
            db.endTransaction();
        }
    }

    public void updateGameData(GameData gameData) {
        SQLiteDatabase db = mDBHelper.getWritableDatabase();
        db.beginTransaction();
        try {
            updateGameData(db, gameData);
            db.setTransactionSuccessful();
        } finally {
            db.endTransaction();
        }
    }

    private void updateGameData(SQLiteDatabase db, GameData gameData) {
        ContentValues values = new ContentValues();
        values.put(SgGame.NAME, gameData.name);
        values.put(SgGame.IMAGE, gameData.image);
        values.put(SgGame.BIGIMAGE, gameData.bigimage);
        values.put(SgGame.PACKAGENAME, gameData.packagename);
        values.put(SgGame.SHORTDESC, gameData.shortdesc);
        values.put(SgGame.SIZE, gameData.size);
        values.put(SgGame.URL, gameData.url);
        values.put(SgGame.VERSION, gameData.version);
        values.put(SgGame.VERSIONCODE, gameData.versioncode);
        values.put(SgGame.TYPE, gameData.type);
        values.put(SgGame.DESC, gameData.desc);
        values.put(SgGame.STATE, gameData.state);
        // values.put(SgGame.MINE_GAME, gameData.mineGame);
        db.update(SgGame.TABLE_NAME, values, SgGame.GAME_ID + "=?", new String[] {
            String.valueOf(gameData.id)
        });
    }

    public void updateGameData(long id, ContentValues values) {
        SQLiteDatabase db = mDBHelper.getWritableDatabase();
        db.beginTransaction();
        try {
            db.update(SgGame.TABLE_NAME, values, SgGame.GAME_ID + "=?", new String[] {
                String.valueOf(id)
            });
            db.setTransactionSuccessful();
        } finally {
            db.endTransaction();
        }

    }
//
//    public void setUpdateState(long gameId, int updateState) {
//        SQLiteDatabase db = mDBHelper.getWritableDatabase();
//        db.beginTransaction();
//        try {
//            ContentValues values = new ContentValues();
//            values.put(SgGame.UPDATE_STATE, updateState);
//            db.update(SgGame.TABLE_NAME, values, SgGame._ID + "=?", new String[] {
//                String.valueOf(gameId)
//            });
//            db.setTransactionSuccessful();
//        } finally {
//            db.endTransaction();
//        }
//    }

//    public int getUpdateState(long gameId) {
//        SQLiteDatabase db = mDBHelper.getReadableDatabase();
//        Cursor cursor = null;
//        int updateState = 0;
//        String sql = new StringBuilder().append("select ").append(SgGame.UPDATE_STATE)
//                .append(" from ").append(SgGame.TABLE_NAME).append(" where ").append(SgGame._ID)
//                .append(" = ?").toString();
//        try {
//            cursor = db.rawQuery(sql, new String[] {
//                String.valueOf(gameId)
//            });
//            if (cursor.moveToFirst()) {
//                updateState = cursor.getInt(0);
//            }
//        } finally {
//            if (cursor != null)
//                cursor.close();
//        }
//        return updateState;
//    }
    public void reCreateSgTable(){
    	SQLiteDatabase db = mDBHelper.getWritableDatabase();
        db.beginTransaction();
        try {
				db.execSQL("DROP TABLE IF EXISTS " + SgGame.TABLE_NAME);
				db.execSQL(SgGame.getCreateTableSQL());
				db.setTransactionSuccessful();
        } finally {
            db.endTransaction();
        }
    }
    public void deleteGameByState(final int state) {
        SQLiteDatabase db = mDBHelper.getWritableDatabase();
        db.beginTransaction();
        try {
            db.delete(SgGame.TABLE_NAME, SgGame.STATE + "=?", new String[] {
                String.valueOf(state)
            });
            db.setTransactionSuccessful();
        } finally {
            db.endTransaction();
        }
    }

    private boolean checkExist(SQLiteDatabase db, String id) {
        boolean result = false;
        String checkSql = new StringBuilder().append("SELECT _id FROM ").append(SgGame.TABLE_NAME)
                .append(" where ").append(SgGame.GAME_ID).append(" = ?").toString();
        Cursor cursor = db.rawQuery(checkSql, new String[] {
            String.valueOf(id)
        });
        if (cursor.moveToFirst()) {
            result = true;
        }
        cursor.close();
        Log.d("CDH", "checkExist SgGame id:" + id + " result:" + result);
        return result;
    }

    /** 获取全部游戏数量 */
    public int getGamesCount() {
        SQLiteDatabase db = mDBHelper.getReadableDatabase();
        return getGamesCount(db);
    }

    private int getGamesCount(SQLiteDatabase db) {
        String checkSql = new StringBuilder().append("SELECT count(*) FROM ")
                .append(SgGame.TABLE_NAME).toString();
        Cursor cursor = null;
        int result = 0;
        try {
            cursor = db.rawQuery(checkSql, null);
            if (cursor.moveToFirst()) {
                result = cursor.getInt(0);
            }
        } finally {
            if (cursor != null)
                cursor.close();
        }
        return result;
    }


//    private boolean isGameInstalled(String packagename) {
//        boolean retValue = false;
//        SQLiteDatabase db = mDBHelper.getReadableDatabase();
//       // PackageManager pm = BoyaaApplication.getInstance().getPackageManager();
////        try {
////            //pm.getApplicationInfo(packagename, PackageManager.GET_META_DATA);
////            retValue = true;
////        } catch (NameNotFoundException e) {
////            e.printStackTrace();
////            //db.delete(RecentPlay.TABLE_NAME, RecentPlay.PACKAGENAME + "=?", new String[] {packagename});
////            retValue = false;
////        }
//        return retValue;
//    }

    // ******************** 最近常玩 end ***************************

    // ******************** 更新时间 start ***************************
    public long getUpdateTime(String updateTable) {
        SQLiteDatabase db = mDBHelper.getReadableDatabase();
        return getUpdateTime(db, updateTable);
    }

    private long getUpdateTime(SQLiteDatabase db, String updateTable) {
        Cursor cursor = null;
        long result = 0;
        String sql = new StringBuilder().append("SELECT ").append(UpdateTime.UPDATE_TIME)
                .append(" FROM ").append(UpdateTime.TABLE_NAME).append(" WHERE ")
                .append(UpdateTime.UPDATE_TABLE).append(" = ?").toString();
        try {
            cursor = db.rawQuery(sql, new String[] {
                updateTable
            });
            if (cursor.moveToFirst()) {
                result = cursor.getLong(0);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (cursor != null)
                cursor.close();
        }
        return result;
    }

    public void saveUpdateTime(String updateTable, long updateTime) {
        if (updateTime <= 0)
            return;

        SQLiteDatabase db = mDBHelper.getWritableDatabase();
        long result = getUpdateTime(db, updateTable);
        db.beginTransaction();
        try {
            ContentValues values = new ContentValues();
            values.put(UpdateTime.UPDATE_TABLE, updateTable);
            values.put(UpdateTime.UPDATE_TIME, updateTime);
            if (result == 0) {
                // 插入
                db.insert(UpdateTime.TABLE_NAME, null, values);
            } else {
                // 更新
                db.update(UpdateTime.TABLE_NAME, values, UpdateTime.UPDATE_TABLE + "=?",
                        new String[] {
                            updateTable
                        });
            }

            db.setTransactionSuccessful();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            db.endTransaction();
        }
    }

    // ******************** 更新时间 end ***************************


    // ******************** 安装游戏上报 start ***************************
    public InstallAppData getInstallAppInfo(long gameId) {
        SQLiteDatabase db = mDBHelper.getReadableDatabase();
        String sql = new StringBuilder().append("SELECT * FROM ").append(InstallAppInfo.TABLE_NAME)
                .append(" WHERE ").append(InstallAppInfo.GAME_ID).append(" = ?").toString();
        Cursor cursor = null;
        InstallAppData data = null;
        try {
            cursor = db.rawQuery(sql, new String[] {
                String.valueOf(gameId)
            });
            if (cursor.moveToFirst()) {
                data = new InstallAppData();
                data.id = cursor.getLong(cursor.getColumnIndex(InstallAppInfo._ID));
                data.gameId = cursor.getLong(cursor.getColumnIndex(InstallAppInfo.GAME_ID));
                data.state = cursor.getInt(cursor.getColumnIndex(InstallAppInfo.STATE));
            }
        } finally {
            if (cursor != null)
                cursor.close();
        }
        return data;
    }

    public void saveInstallAppInfo(InstallAppData data) {
        SQLiteDatabase db = mDBHelper.getWritableDatabase();
        db.beginTransaction();
        ContentValues values = new ContentValues();
        values.put(InstallAppInfo.GAME_ID, data.gameId);
        values.put(InstallAppInfo.STATE, data.state);
        try {
            db.insert(InstallAppInfo.TABLE_NAME, null, values);
            db.setTransactionSuccessful();
        } finally {
            db.endTransaction();
        }
    }

    public void deleteInstallAppInfo(final long id) {
        SQLiteDatabase db = mDBHelper.getWritableDatabase();
        db.beginTransaction();
        try {
            db.delete(InstallAppInfo.TABLE_NAME, InstallAppInfo._ID + "=?", new String[] {
                String.valueOf(id)
            });
            db.setTransactionSuccessful();
        } finally {
            db.endTransaction();
        }
    }
    // ******************** 安装游戏上报 end ***************************
}
