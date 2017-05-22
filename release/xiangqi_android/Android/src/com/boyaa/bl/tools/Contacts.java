package com.boyaa.bl.tools;

import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.Set;

import android.content.ContentResolver;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.provider.ContactsContract.CommonDataKinds.Phone;
import android.text.TextUtils;
import android.util.Log;

public class Contacts {
	private static final String TAG = Contacts.class.getSimpleName(); 
	private static final String[] PHONES_PROJECTION = new String[] {  
	      Phone.DISPLAY_NAME,Phone.NUMBER };
	private static final int PHONES_DISPLAY_INDEX = 0;
	private static final int PHONES_NUMBER_INDEX = 1;
	/**得到手机通讯录联系人信息**/  
	public static HashMap<String, String> getPhoneContacts(Context mContext) {
		ContentResolver resolver = mContext.getContentResolver();
		HashMap<String,String> contactMap = new HashMap<String,String>();
		// 获取手机联系人  
		Cursor phoneCursor = resolver.query(Phone.CONTENT_URI,PHONES_PROJECTION, null, null, null);
		if (phoneCursor != null) {  
		    while (phoneCursor.moveToNext()) {  
			    //得到联系人姓名
			    String phoneName = phoneCursor.getString(PHONES_DISPLAY_INDEX);     	
			    //得到手机号码  
			    String phoneNumber = phoneCursor.getString(PHONES_NUMBER_INDEX);  
			    
			    //当手机号码为空的或者为空字段 跳过当前循环  
			    if (TextUtils.isEmpty(phoneNumber))  
			        continue;
			    contactMap.put(phoneName, phoneNumber);
			}
		    phoneCursor.close();  
		}
		Log.e(TAG,"getPhoneContacts:"+contactMap.toString());
		return contactMap;
	}
	/**得到手机SIM卡联系人人信息**/  
	public static Set<String> getSIMContacts(Context mContext) {  
		ContentResolver resolver = mContext.getContentResolver();  
		// 获取Sims卡联系人  
		LinkedHashSet<String> linkedHashSet = new LinkedHashSet<String>();
		Uri uri = Uri.parse("content://icc/adn");  
		Cursor phoneCursor = resolver.query(uri, PHONES_PROJECTION, null, null,  
		    null);  
		 
		if (phoneCursor != null) {  
		    while (phoneCursor.moveToNext()) {  
			 
			    // 得到手机号码  
			    String phoneNumber = phoneCursor.getString(PHONES_NUMBER_INDEX);  
			    // 当手机号码为空的或者为空字段 跳过当前循环  
			    if (TextUtils.isEmpty(phoneNumber))  
			        continue;
			    linkedHashSet.add(phoneNumber);
		    }  
		    phoneCursor.close();  
		}  
		Log.e(TAG,"getSIMContacts:"+linkedHashSet.toString());
		return linkedHashSet;
	} 
}
