kHttpRequestNone=0;
kHttpRequestCreate=1;
kHttpRequestRuning=2;
kHttpRequestFinish=3;

HttpRequestNS = {};
HttpRequestNS.http_request_id=0;
HttpRequestNS.kHttpRequestExecute="http_request_execute";
HttpRequestNS.kHttpResponse="http_response";
HttpRequestNS.kId="id";
HttpRequestNS.kStep="step";
HttpRequestNS.kUrl="url";
HttpRequestNS.kData="data";
HttpRequestNS.kTimeout="timeout";
HttpRequestNS.kEvent="event";
HttpRequestNS.kAbort="abort";
HttpRequestNS.kError="error";
HttpRequestNS.kCode="code";
HttpRequestNS.kRet="ret";

HttpRequestNS.allocId = function ()
	HttpRequestNS.http_request_id = HttpRequestNS.http_request_id + 1;
	return HttpRequestNS.http_request_id;
end
HttpRequestNS.getKey = function ( iRequestId )
	local key = string.format("http_request_%d",iRequestId);
	return key;
end

function http_request_create( iTypePost, iResponseType, strUrl )
	local iRequestId = HttpRequestNS.allocId();
	local key = HttpRequestNS.getKey(iRequestId);
	dict_set_int(key,HttpRequestNS.kStep,kHttpRequestCreate);
	dict_set_string(key,HttpRequestNS.kUrl,strUrl);
	return iRequestId;
end

function http_request_destroy(iRequestId)
	local key = HttpRequestNS.getKey(iRequestId);

	local step = dict_get_int(key,HttpRequestNS.kStep,kHttpRequestNone);
	if step == kHttpRequestNone then
		FwLog(string.format("http_request_destroy failed %d, not create",iRequestId));
		return;
	end
	if step == kHttpRequestRuning then
		FwLog(string.format("http_request_destroy failed %d, can't destroy while execute ",iRequestId));
		return;
	end
	
	dict_delete(key);

end

function http_set_timeout ( iRequestId, timeout1, timeout2 )
	local key = HttpRequestNS.getKey(iRequestId);

	local step = dict_get_int(key,HttpRequestNS.kStep,kHttpRequestNone);
	if step == kHttpRequestNone then
		FwLog(string.format("http_set_timeout failed %d, not create",iRequestId));
		return;
	end
	if step == kHttpRequestRuning then
		FwLog(string.format("http_set_timeout failed %d, can't set timeout while execute ",iRequestId));
		return;
	end

	dict_set_int(key,HttpRequestNS.kTimeout,timeout1);

end

function http_request_set_data (iRequestId, strValue )
	local key = HttpRequestNS.getKey(iRequestId);

	local step = dict_get_int(key,HttpRequestNS.kStep,kHttpRequestNone);
	if step == kHttpRequestNone then
		FwLog(string.format("http_request_set_data failed %d, not create",iRequestId));
		return;
	end
	if step == kHttpRequestRuning then
		FwLog(string.format("http_request_set_data failed %d, can't set data while execute ",iRequestId));
		return;
	end

	dict_set_string(key,HttpRequestNS.kData,strValue);

end

function http_request_set_agent(iRequestId,strValue)
	FwLog("not support on android platform");
end

function http_request_add_header(iRequestId,strValue)
	FwLog("not support on android platform");
end

function http_request_execute(iRequestId,strEventName )
	local key = HttpRequestNS.getKey(iRequestId);
	local step = dict_get_int(key,HttpRequestNS.kStep,kHttpRequestNone);
	if step ~= kHttpRequestCreate then
		FwLog(string.format("http_request_execute failed %d",iRequestId));
		return;
	end
	
	dict_set_int(HttpRequestNS.kHttpRequestExecute,HttpRequestNS.kId,iRequestId);
	dict_set_int(key,HttpRequestNS.kStep,kHttpRequestRuning);
	dict_set_string(key,HttpRequestNS.kEvent,strEventName);
	call_native("HttpPost");

end

function http_request_abort(iRequestId)
	local key = HttpRequestNS.getKey(iRequestId);
	local step = dict_get_int(key,HttpRequestNS.kStep,kHttpRequestNone);
	if step ~= kHttpRequestRuning then
		FwLog(string.format("http_request_abort failed %d",iRequestId));
		return;
	end
	dict_set_int(key,HttpRequestNS.kAbort,1);
end
function http_request_get_response(iRequestId)
	local key = HttpRequestNS.getKey(iRequestId);
	local step = dict_get_int(key,HttpRequestNS.kStep,kHttpRequestNone);
	if step ~= kHttpRequestFinish then
		FwLog(string.format("http_request_get_response failed %d",iRequestId));
		return "";
	end

	local str = dict_get_string(key,HttpRequestNS.kRet);
	if nil == str then
		return "";
	end
	return str;
end

function http_request_get_abort(iRequestId)
	local key = HttpRequestNS.getKey(iRequestId);
	local step = dict_get_int(key,HttpRequestNS.kStep,kHttpRequestNone);
	if step ~= kHttpRequestFinish then
		FwLog(string.format("http_request_get_abort failed %d",iRequestId));
		return 0;
	end
	
	return dict_get_int(key,HttpRequestNS.kAbort,0);
	
end

function http_request_get_error(iRequestId)
	local key = HttpRequestNS.getKey(iRequestId);
	local step = dict_get_int(key,HttpRequestNS.kStep,kHttpRequestNone);
	if step ~= kHttpRequestFinish then
		FwLog(string.format("http_request_get_error failed %d",iRequestId));
		return 0;
	end
	
	return dict_get_int(key,HttpRequestNS.kError,0);

end

function http_request_get_response_code(iRequestId)
	local key = HttpRequestNS.getKey(iRequestId);
	local step = dict_get_int(key,HttpRequestNS.kStep,kHttpRequestNone);
	if step ~= kHttpRequestFinish then
		FwLog(string.format("http_request_get_response_code failed %d",iRequestId));
		return 0;
	end
	
	return dict_get_int(key,HttpRequestNS.kCode,0);
end


function http_request_get_current_id ( id )
	return dict_get_int(HttpRequestNS.kHttpResponse,HttpRequestNS.kId,0);
end