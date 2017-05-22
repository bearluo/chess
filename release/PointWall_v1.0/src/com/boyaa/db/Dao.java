package com.boyaa.db;

import android.database.ContentObserver;

abstract class Dao {

	public ContentObserver mObserver;
	
	public void registerChange(ContentObserver observer){
		
	}
}
