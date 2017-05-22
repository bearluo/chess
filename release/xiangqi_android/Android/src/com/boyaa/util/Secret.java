package com.boyaa.util;

import java.security.MessageDigest;

public class Secret {

	public static String md5(String text) {
		String result = null;
		try {
			MessageDigest digest = java.security.MessageDigest.getInstance("MD5");
			digest.update(text.getBytes());
			result = toHexString(digest.digest());
		} catch (Exception e) {
			e.printStackTrace();
		}
		return result;
	}

	public static String sha1(String text) {
		String result = null;
		try {
			MessageDigest digest = MessageDigest.getInstance("SHA-1");
			digest.update(text.getBytes("UTF-8"));
			result = toHexString(digest.digest());
		} catch (Exception e) {
			e.printStackTrace();
		}
		return result;
	}

	private static String toHexString(byte[] b) {
		StringBuilder sb = new StringBuilder();
		for (int i = 0; i < b.length; i++) {
			int temp = 0xFF & b[i];
			String s = Integer.toHexString(temp);
			if (temp <= 0x0F) {
				s = "0" + s;
			}
			sb.append(s);
		}
		return sb.toString();
	}

}
