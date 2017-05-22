package com.boyaa.made;

import java.util.Hashtable;

import android.content.Context;
import android.graphics.Typeface;

public class AppTypefaces {
	private static final Hashtable<String, Typeface> cache = new Hashtable<String, Typeface>();

	public static Typeface get(Context context, String name) {
		synchronized (cache) {
			if (!cache.containsKey(name)) {
				Typeface t = Typeface.createFromAsset(context.getAssets(), name);
				cache.put(name, t);
			}
			return cache.get(name);
		}
	}
}
