package com.boyaa.data;

import com.boyaa.cache.Cacheable;

public class GameData implements Cacheable {
	public static final String TAG = "com.boyaa.data.GameData";

	public static final int UNINIT_UPDATE = 0;
	public static final int NEED_UPDATE = 1;
	public static final int UPDATED_UNINSTALL = 2;
	public static final int NEED_INSTALL = 3;
	public static final int GET_POINTS = 4;
	public static final int HAS_INSTALL = 5;	
	public static final int IN_DOWNLOAD = 6;	
	public static final int CONTINUE_DOWNLOAD = 7;

//	public long _id;
	public long id;
	public String name;
	public String image;
	public String bigimage;
	public String url;
	public String shortdesc;//
	public String size;
	public String version;
	public int versioncode;
	public String packagename;
	public int type;
	public String desc;
	public int state;
	public int updateState;
//	public long mineGame;
	public String points;
	public GameData copy() {
		GameData data = new GameData();
//		data._id = _id;
		data.id = id;
		data.name = name;
		data.image = image;
		data.bigimage = bigimage;
		data.url = url;
		data.shortdesc = shortdesc;
		data.size = size;
		data.version = version;
		data.versioncode = versioncode;
		data.packagename = packagename;
		data.type = type;
		data.desc = desc;
		data.points = points;
		data.state = state;
		data.updateState = updateState;
//		data.mineGame = mineGame;
		return data;
	}
}
