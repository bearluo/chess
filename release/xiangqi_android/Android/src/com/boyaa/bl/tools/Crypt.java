package com.boyaa.bl.tools;
import java.io.UnsupportedEncodingException;
import java.security.NoSuchAlgorithmException;
import java.util.TreeMap;

import org.json.JSONException;
import org.json.JSONObject;

import android.util.Base64;


public class Crypt {
	/**
     * Crypt
     * @access static
     * @param string $str 
     * @param string $key
     * @return string
	 * @throws NoSuchAlgorithmException 
	 * @throws UnsupportedEncodingException 
     */
	public static String encrypt(String str,String key) throws NoSuchAlgorithmException, UnsupportedEncodingException{
        String r = MD5.getMD5(key);
        int c=0;
        byte[] bStr = str.getBytes();
        byte[] bR = r.getBytes();
        int len = bStr.length;
        byte[] v = new byte[2*len];
		int l = bR.length;
        for (int i=0;i< len; i++){
        	if (c == l) c=0;
        	v[2*i]= (byte)bR[c];
        	v[2*i+1]=(byte)(bStr[i]^bR[c]);
        	c++;
        }
        String s = Base64.encodeToString(ed(v,bR), Base64.NO_WRAP);
//        String ss = decrypt(s,key);
        return s;


    }

    /**
     * decrypt
     * @access static
     * @param string $str
     * @param string $key
     * @return string
     * @throws NoSuchAlgorithmException 
     * @throws UnsupportedEncodingException 
     */
	public static String decrypt(String str,String key) throws NoSuchAlgorithmException, UnsupportedEncodingException {
		String r = MD5.getMD5(key);
		byte[] bR = r.getBytes();
		byte[] bStr = ed(Base64.decode(str, Base64.NO_WRAP),bR);
		int len = bStr.length;
		byte[] v = new byte[len];
		int j = 0;
        for (int i=0;i<len;i++){
		    byte md5 = bStr[i];
		    i++;
		    v[j]=(byte)(bStr[i] ^ md5);
		    j++;
        }   
        byte [] vv = new byte[len / 2];
        for (int k = 0; k < len / 2; k++){
        	vv[k] = v[k];
        }
        String rStr = new String(vv); 
        return rStr;	
    }


	public static byte[] ed(byte [] str,byte [] key) throws NoSuchAlgorithmException, UnsupportedEncodingException {
      int c=0;
      int len = str.length;
      int l = key.length;
      byte[] v = new byte[len];
      for (int i=0;i< len; i++){
		  if (c == l) c=0;
		  v[i]=(byte)(str[i] ^ key[c]);
		  c++;
      }
      return v;
   }
}
