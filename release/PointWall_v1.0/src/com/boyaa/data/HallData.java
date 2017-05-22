package com.boyaa.data;

public class HallData {
	public static final int HOT_GAME = 0;
	public static final int NEW_GAME = 1;

	public long id;
	public int gameId;//游戏ID
	public int type;//游戏类别(0为热门游戏，1为新游推荐)

	public HallData copy() {
		HallData copy = new HallData();
		copy.id = id;
		copy.gameId = gameId;
		copy.type = type;
		return copy;
	}
}
