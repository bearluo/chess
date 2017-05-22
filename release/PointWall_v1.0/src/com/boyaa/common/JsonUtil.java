package com.boyaa.common;

import java.util.List;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class JsonUtil {
	public static JSONObject map2Json(Map<String, String> map) {
		JSONObject json = new JSONObject();
		if (map != null) {
			try {
				for (String key : map.keySet()) {
					json.put(key, map.get(key));
				}
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
		return json;
	}
	
	public static JSONArray list2JsonArray(List<Object> list) {
		JSONArray ja = new JSONArray();
		if (list != null && list.size() > 0) {
			for (Object obj : list) {
				ja.put(obj);
			}
		}
		return ja;
	}
}
