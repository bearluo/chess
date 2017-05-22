package com.boyaa.thread.task;

import java.util.Map;

import com.boyaa.http.HttpResult;
import com.boyaa.http.HttpUtil;
import com.boyaa.thread.ITask;

public class FileUploadTask implements ITask{

	private String url;
	private String fileField;
	private Map<String, String> param;
	private String path;
	private HttpResult result;
	private OnCompleteHttpCallListener listener;
	public FileUploadTask(String url, Map<String, String> param,String localPath,String fileField,OnCompleteHttpCallListener l) {
		super();
		this.url = url;
		this.param = param;
		this.listener = l;
		this.fileField = fileField;
		this.path = localPath;
	}
	public void execute() {
		result  = HttpUtil.uploadFile(path, url, fileField, param);
	}

	public void postExecute() {
		if (listener != null) {
			listener.onComplete(result);
		}
	}

	public static interface OnCompleteHttpCallListener{
		public void onComplete(HttpResult result);
	}
}
