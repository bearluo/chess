package com.boyaa.entity.common;

import android.os.Build;
public class SdkVersion
{
	private static int sdkVersion = 0;
	

	private static int getSdkVersion()
	{
		if ( 0 == sdkVersion )
		{
			sdkVersion = Integer.parseInt(Build.VERSION.SDK);
		}
		return sdkVersion;
	}
	
	public static boolean Above16()
	{
		return getSdkVersion() > Build.VERSION_CODES.DONUT;
	}
	
}
