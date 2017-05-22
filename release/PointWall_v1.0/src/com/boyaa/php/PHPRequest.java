package com.boyaa.php;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.boyaa.common.JsonUtil;
import com.boyaa.log.Log;

public class PHPRequest {
	//private static final String TEST_IP = "http://192.168.100.134:8090/api/";//测试环境地址
//	private static final String TEST_IP = "http://192.168.202.12:8090/api/";//测试环境地址
	private static final String MAIN_IP = "http://jifen.ifere.com/api/";			//正式环境
//	public static final String LUA_TEST_IP = "http://chesstest.boyaa.com:90/chess_android/application/";		//回调lua端php 测试地址
//	public static final String LUA_MAIN_IP = "http://snspcs03.ifere.com/chess_android/application/";			//回调lua端php 正式地址
    public static String LUA_SERVERADDR = "";
	private static final String CON_SERECT = "lk%j50s^1d#$h-g;";
	public  static final String defaultUid = "123456";
	
	
	public static String SERVER_RUL = MAIN_IP;
//	public static String SERVER_RUL = TEST_IP;
//	static {
	
//	}

	public static String createApi(String m,String u,Map<String, String> p){
		String api;
		try {
			Map<String, String> params = new HashMap<String, String>();
			//long time = System.currentTimeMillis()/1000;
			//JSONObject jsonObject = JsonUtil.map2Json(p);
			//params.put("t", time);
			params.put("m", m);
			//params.put("u", u);//目前没有登录功能，用户ID随意写一个
			//params.put("p", jsonObject);
			//生成签名
			StringBuilder sb = new StringBuilder();
			sb.append(params.get("m"));
			sb.append("/?");
			//sb.append(params.get("u"));
			//sb.append(params.get("t"));
			Set<String> keySet = p.keySet();
			List<String> listKey = new ArrayList<String>();
			for (Iterator<String> iterator = keySet.iterator();iterator.hasNext();) {
				String key = iterator.next();
				listKey.add(key);
			}
			Collections.sort(listKey);
			for (int i = 0; i < listKey.size(); i++) {
				Object s = p.get(listKey.get(i));
				String value = "";
				if(s!=null){
					value = s.toString();
				}
				sb.append(listKey.get(i) + "=" +value);
			}
			String str = sb.toString();
			Log.d("CDH", "签名参数："+sb.toString());
			String sign =Secret.sha1(Secret.md5(Secret.md5(str) + CON_SERECT));
			params.put("sig", sign);
			api = JsonUtil.map2Json(params).toString();
			Log.d("CDH", "api="+api);
			return api;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}
	public static String secretParms(String m, String u, Map<String, String> p){
		Map<String, String> params = new HashMap<String, String>();
		params.put("m", m);
		StringBuilder sb = new StringBuilder();
		sb.append(params.get("m"));
		sb.append("/");
		Set<String> keySet = p.keySet();
		List<String> listKey = new ArrayList<String>();
		for (Iterator<String> iterator = keySet.iterator();iterator.hasNext();) {
			String key = iterator.next();
			listKey.add(key);
		}
		Collections.sort(listKey);
		for (int i = 0; i < listKey.size(); i++) {
			String s = p.get(listKey.get(i));
			String value = "";
			if(s!=null){
				value = s;
			}
			if (i == (listKey.size() - 1))
			{
				sb.append(listKey.get(i) + "=" +value);
			}else
			{
				sb.append(listKey.get(i) + "=" +value + "&");
			}
			
		}
		String str = sb.toString();
		String sign = "";
		Log.d("CDH", "签名参数："+sb.toString());
		try {
			sign =Secret.sha1(Secret.md5(URLEncoder.encode(str,"UTF-8") + CON_SERECT));
		} catch (UnsupportedEncodingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;
		}
		
		return sign;
	}
	//生成lua下php请求的加密格式。
	public static String secretParmsToLua(Map<String, String> p, String mtkey){

		Set<String> keySet = p.keySet();
		List<String> listKey = new ArrayList<String>();
		for (Iterator<String> iterator = keySet.iterator();iterator.hasNext();) {
			String key = iterator.next();
			listKey.add(key);
		}
		
		String signature = Joins(p, mtkey, listKey);
		

//		String str = sb.toString();
		String sign = "";
//		Log.d("CDH", "签名参数："+sb.toString());

		sign =Secret.md5(signature);
		return sign;
	}
	private static String Joins(Map<String, String> p, String mtkey, List<String> listKey) {
		String finalStr = "M";
		Collections.sort(listKey);
		for (int i = 0; i < listKey.size(); i++) {
			String s = p.get(listKey.get(i));
			String str = "M";
			if(s!= null){
				if (isNumeric(s)) {
					str = String.format("%sT%s%s", str, mtkey, s);
				}else{
					str = String.format("%sT%s%s", str, mtkey, s.replaceAll("[^a-zA-Z0-9]", ""));
				}

			}else{
				finalStr += str;
			}
			
			finalStr +=  listKey.get(i) + "=" + str;
		
		}
		
		
		return finalStr;
	}
	
	public static boolean isNumeric(String str){ 
		   Pattern pattern = Pattern.compile("-?[0-9]+.?[0-9]+"); //-?[0-9]+.?[0-9]+  所有数字
		   Matcher isNum = pattern.matcher(str);
		   if( !isNum.matches() ){
		       return false; 
		   } 
		   return true; 
		}
	
	
	
}
