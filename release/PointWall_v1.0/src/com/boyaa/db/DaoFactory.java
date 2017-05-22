package com.boyaa.db;

import java.util.HashMap;

//import com.boyaa.BoyaaApplication;

public class DaoFactory {
	private static HashMap<String, Dao> mDaoMap = new HashMap<String, Dao>();
	
	public static ByGameDao getByGameDao() {
		ByGameDao gameDao = (ByGameDao)mDaoMap.get("ByGameDao");
		if (gameDao == null) {
			gameDao = new ByGameDao();
			mDaoMap.put("ByGameDao", gameDao);
		}
		return gameDao;
	}
	public static SgGameDao getSgGameDao() {
		SgGameDao gameDao = (SgGameDao)mDaoMap.get("SgGameDao");
		if (gameDao == null) {
			gameDao = new SgGameDao();
			mDaoMap.put("SgGameDao", gameDao);
		}
		return gameDao;
	}
//	public static APKInfoDao getAPKInfoDao() {
//		APKInfoDao aPKInfoDao = (APKInfoDao)mDaoMap.get("APKInfoDao");
//		if (aPKInfoDao == null) {
//			aPKInfoDao = new APKInfoDao();
//			mDaoMap.put("APKInfoDao", aPKInfoDao);
//		}
//		return aPKInfoDao;
//	}
	
//	public static UserFeedBackInfoDao getUserFeedBackInfoDao() {
//		UserFeedBackInfoDao userFeedBackInfoDao = (UserFeedBackInfoDao)mDaoMap.get("UserFeedBackInfoDao");
//		if (userFeedBackInfoDao == null) {
//			userFeedBackInfoDao = new UserFeedBackInfoDao();
//			mDaoMap.put("UserFeedBackInfoDao", userFeedBackInfoDao);
//		}
//		return userFeedBackInfoDao;
//	}
	
//	public static UserInfoDao getUserInfoDao() {
//		UserInfoDao userInfoDao = (UserInfoDao)mDaoMap.get("UserInfoDao");
//		if (userInfoDao == null) {
//			//userInfoDao = BoyaaApplication.getInstance().mUserInfoDao;
//			mDaoMap.put("UserInfoDao", userInfoDao);
//		}
//		return userInfoDao;
//	}
}
