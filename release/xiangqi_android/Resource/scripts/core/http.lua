-- http.lua
-- Author: Vicent Gong
-- Date: 2012-09-30
-- Last modification : 2013-05-29
-- Description: provide basic wrapper for http functions

require("core/object");
require("core/system");
require("core/constants");
require("core/global");

Http = class();
Http.s_objs = CreateTable("v");
Http.s_platform = System.getPlatform();

if Http.s_platform == kPlatformAndroid or Http.s_platform == kPlatformWin32 then
	require("core/httpRequest");
end

Http.ctor = function(self, requestType, responseType, url)
	self.m_requestID = http_request_create(requestType,responseType,url);
	Http.s_objs[self.m_requestID] = self;
	self.m_eventCallback = {};
end

Http.dtor = function(self)
	http_request_destroy(self.m_requestID);
	self.m_requestID = nil;
end

Http.setTimeout = function(self, connectTimeout, timeout)
	http_set_timeout(self.m_requestID,connectTimeout,timeout)
end

Http.setAgent = function(self, str)
	http_request_set_agent(self.m_requestID,str);
end

Http.addHeader = function(self, str)
	http_request_add_header(self.m_requestID,str);
end

Http.setData = function(self, str)
	http_request_set_data(self.m_requestID,str);
end

Http.execute = function(self)
	local eventName = "httpEvent";
	http_request_execute(self.m_requestID,eventName);
end

Http.abortRequest = function(self)
	http_request_abort(self.m_requestID);
end

Http.isAbort = function(self)
	return (http_request_get_abort(self.m_requestID) == kTrue);
end

Http.getResponseCode = function(self)
	return http_request_get_response_code(self.m_requestID);
end

Http.getResponse = function(self)
	return http_request_get_response(self.m_requestID);
end

Http.getError = function(self)
	return http_request_get_error(self.m_requestID);
end

Http.setEvent = function(self, obj, func)
	self.m_eventCallback.obj = obj;
	self.m_eventCallback.func = func;
end

function event_http_response_httpEvent(requestID)
	if Http.s_platform == kPlatformAndroid or Http.s_platform == kPlatformWin32 then
	requestID = http_request_get_current_id();
	end

	local http = Http.s_objs[requestID];
	if http and  http.m_eventCallback.func then
		http.m_eventCallback.func(http.m_eventCallback.obj,http);
	end
end
