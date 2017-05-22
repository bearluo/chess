package com.boyaa.cache;

import java.util.HashMap;

/** 对象缓存 */
public class MemoryCache {
	private static HashMap<String, CacheItem> mCacheMap = new HashMap<String, CacheItem>();
	
	public static void put(String key, Cacheable cacheable) {
		put(key, cacheable, false);
	}

	public static void put(String key, Cacheable cacheable, boolean isForceCache) {
		if (!isForceCache && mCacheMap.containsKey(key)) return;

		CacheItem item = new CacheItem();
		item.mExpireTime = System.currentTimeMillis();
		item.mCacheable = cacheable;
		mCacheMap.put(key, item);
	}

	public static Cacheable get(String key) {
		Cacheable cacheable = null;
		if (mCacheMap.containsKey(key)) {
			CacheItem item = mCacheMap.get(key);
			cacheable = item.mCacheable;
		}
		return cacheable;
	}
}
