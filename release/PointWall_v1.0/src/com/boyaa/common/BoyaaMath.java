package com.boyaa.common;

public class BoyaaMath {

	public static String double2String(double d, int decimal) {
		String ds = String.valueOf(d);
		int dotPos = ds.indexOf(".");
		int decimalLength = ds.substring(dotPos + 1).length();
		int minLength = Math.min(decimalLength, decimal);
		String result = ds.substring(0, dotPos + 1 + minLength);
		return result;
	}

	private static String[] unitType = {"B", "KB", "MB", "GB"};
	public static String reduceUnit(long l) {
		int times = 0;
		while(l > 1024) {
			l /= 1024;
			times++;
		}
		return l + unitType[times];
	}
	
	public static String reduceUnit(double d, int decimal) {
		int times = 0;
		while(d > 1024) {
			d /= 1024;
			times++;
		}
		return double2String(d, decimal) + unitType[times];
	}
	
	public static int percent(double dividend, double divisor) {
		if(divisor==0) return 0;
		return (int)(dividend/divisor*100);
	}

}
