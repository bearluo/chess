package com.boyaa.common;

import java.util.regex.Pattern;

public class CheckUtil {

	/** 检查邮箱格式 */
	public static boolean checkEmail(String email) {
		String check = "^([a-z0-9A-Z]+[-|\\.]?)+[a-z0-9A-Z]@([a-z0-9A-Z]+(-[a-z0-9A-Z]+)?\\.)+[a-zA-Z]{2,}$";
		Pattern regex = Pattern.compile(check);
		boolean result = regex.matcher(email).matches();
		return result;
	}

	/** 检查手机号格式 */
	public static boolean checkMobileNumber(String mobileNumber){
		Pattern regex = Pattern.compile("^((13[0-9])|(15[^4,\\D])|(18[0,5-9]))\\d{8}$");
		boolean result = regex.matcher(mobileNumber).matches();
		return result;
	}
}
