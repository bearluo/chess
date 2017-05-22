package com.boyaa.entity.php;

import org.json.JSONObject;

import android.util.Log;

import com.boyaa.entity.common.ICallBackListener;

public class PHPResult {
	public static final String json_error = "json error:";
	public static final String network_error = "network error:";
	public static final String server_error = "server response:";
	
	public static final int ERROR_NUMBER_NOERROR = 0;
	public static final int ERROR_NUMBER_MalformedURLException = -1;
	public static final int ERROR_NUMBER_ProtocolException = -2;
	public static final int ERROR_NUMBER_ConnectTimeoutException = -3;
	public static final int ERROR_NUMBER_IOException = -4;
	public static final int ERROR_NUMBER_Exception = -5;
	public static final int ERROR_NUMBER_PHPSERVER = -6;
	public static final int ERROR_NUMBER_ = 51;
	
	
	public void setError ( String str )
	{
		switch(code )
		{
		case SUCCESS:
			error = ""; 
			break;
		case NETWORK_ERROR:
			error = network_error + str;
			break;
		case JSON_ERROR:
			error = json_error + str;
			break;
		case SERVER_ERROR:
			error = server_error + str;
			break;
		case USER_ABORT:
			error = str;
			break;
		case USER_CODE1:
			error = USER_CODE1 + str;
			break;
		default:
			break;
		}
	}
	public void JsonError( String str )
	{
		code = PHPResult.JSON_ERROR;
		setError(str);
	}
	public static final int SUCCESS = 0;
	public static final int NETWORK_ERROR = -1;
	public static final int JSON_ERROR = -2;
	public static final int SERVER_ERROR = -3;
	public static final int USER_ABORT = -5;
	public static final int USER_CODE1 = 1;
	public int code = SUCCESS;
	public int errorNumber = ERROR_NUMBER_NOERROR;
	public JSONObject obj = null;
	public String error = "";
	public String json = "";
	
	public void reset()
	{
		code = SUCCESS;
		errorNumber = ERROR_NUMBER_NOERROR;
		obj = null;
		error = "";
		json = "";
	}
	public void afterExplain( ICallBackListener callback )
	{
		switch(code )
		{
		case SUCCESS:
			callback.onSucceed();
			break;
		case NETWORK_ERROR:
			callback.onNetWorkError(error);
	
			break;
		case JSON_ERROR:
			callback.onJsonError(error);
	
			break;
		case SERVER_ERROR:
			callback.onFailed();
		
			break;
		case USER_ABORT:
			callback.onAbort(error);
			
			break;

		case USER_CODE1:
			callback.onUserDefineError(code, error);
			
			break;
		default:

			break;
		}

	}
}

