package com.boyaa.until;


import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import android.content.ContentResolver;
import android.content.Context;
import android.database.Cursor;
import android.provider.ContactsContract.CommonDataKinds.Phone;
import android.provider.ContactsContract.CommonDataKinds.Photo;
import android.telephony.TelephonyManager;
import android.text.TextUtils;

public class Contacts {

    private static ContentResolver resolver;
    private static final String[] PHONES_PROJECTION = new String[] {
        Phone.DISPLAY_NAME, Phone.NUMBER, Photo.PHOTO_ID,Phone.CONTACT_ID };
    private static final int PHONES_DISPLAY_NAME_INDEX = 0;
 
    private static final int PHONES_NUMBER_INDEX = 1;
   
    private static final int PHONES_PHOTO_ID_INDEX = 2;
    
    private static final int PHONES_CONTACT_ID_INDEX = 3;
      
	public static String getPhoneContacts(Context ctx) {
		if (resolver==null){
	   		resolver = ctx.getContentResolver();
	   	}
		StringBuffer  result = new StringBuffer();
		List<Contact> contactsList = new ArrayList<Contact>();
	   	
	   	Contact contact;
        Cursor phoneCursor = resolver.query(Phone.CONTENT_URI,PHONES_PROJECTION, null, null, null);
        if (phoneCursor != null) {
        	StringBuffer personInfo;
        	
        	int n = 0;
        	while (phoneCursor.moveToNext()) {
    		   String phoneNumber = phoneCursor.getString(PHONES_NUMBER_INDEX);
    		   
               if (TextUtils.isEmpty(phoneNumber))
                   continue;
               
               contact = new Contact();
               personInfo = new StringBuffer();
        	   
               if (phoneNumber!=null){
            	   phoneNumber.trim();
            	   phoneNumber =   phoneNumber.replaceAll("-", "");
             	   phoneNumber =   phoneNumber.replaceAll(" ", "");
             	   
 				  if(phoneNumber.startsWith("+86")){
					  phoneNumber = phoneNumber.substring(3);
				  }else if(phoneNumber.startsWith("86")){
					  phoneNumber = phoneNumber.substring(2);
				  }  
               }
          
               personInfo.append(phoneNumber);
               contact.setPhoneNumber(phoneNumber);
               
               String contactName = phoneCursor.getString(PHONES_DISPLAY_NAME_INDEX);
               if (contactName!=null){
            	   contactName.trim();
               }
               
         	   if(contactName==null || "".equals(contactName))
         		  contactName = phoneNumber;
         	   
               contact.setContactName(contactName);
               personInfo.append("=");
               personInfo.append(contactName);
               
               long contactid = phoneCursor.getLong(PHONES_CONTACT_ID_INDEX);
               contact.setContactid(contactid);
               
               long photoid = phoneCursor.getLong(PHONES_PHOTO_ID_INDEX);
               contact.setPhotoid(photoid);
               
               boolean bHave = false;
               for(Iterator it = contactsList.iterator(); it.hasNext(); ) {
                   Contact c = (Contact)it.next();
                   if (c.getContactid()==contactid) {
                	   bHave=true;
                	   break;
				   }
               }
               
               if (!bHave){
            	   String str = personInfo.toString();
            	   if(str!=null && !"".equals(str.trim()) && !",".equals(str)){
            		   str.replaceAll(",", "");
                	   if(contactsList.size()>0)
                		   result.append(","+str);
                	   else
                		   result.append(str);

                	   contactsList.add(contact);
                	   personInfo = null;
                	   contact = null;
                	   n++;
            	   }
			   }
           }
           
        	phoneCursor.close();
        	String contactstr = result.toString();
            return contactstr;
     
        }
        return "";
    }

	protected static class Contact{
		private String phoneNumber;
		private String contactName;
		private long contactid;
		private long photoid;
		
		public String getPhoneNumber() {
			return phoneNumber;
		}
		public void setPhoneNumber(String phoneNumber) {
			this.phoneNumber = phoneNumber;
		}
		public String getContactName() {
			return contactName;
		}
		public void setContactName(String contactName) {
			this.contactName = contactName;
		}
		public long getContactid() {
			return contactid;
		}
		public void setContactid(long contactid) {
			this.contactid = contactid;
		}
		public long getPhotoid() {
			return photoid;
		}
		public void setPhotoid(long photoid) {
			this.photoid = photoid;
		}
	}	
}
