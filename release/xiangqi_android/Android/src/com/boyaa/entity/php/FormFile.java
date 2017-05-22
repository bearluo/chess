package com.boyaa.entity.php;

import java.io.InputStream;

/**
 * 定义了使用文件的特点
 * 上传文件信息
 * @author Shineflag
 *
 */
public class FormFile {
	
	/**文件的数据*/
	private byte[] data;
	
	private InputStream inputStream;
	
	/**文件名称*/
	private String fileName;
	
	/**请求参数名称*/
	private String formNames;
	
	/**数据类型*/
	private String contentType = "application/octet-stream";

	public FormFile(byte[] data, String fileName, String formNames,
			String contentType) {
		this.data = data;
		this.fileName = fileName;
		this.formNames = formNames;
		this.contentType = contentType;
	}

	public FormFile(InputStream openInputStream, String fileName,
			String formNames, String contentType) {
		this.inputStream = openInputStream;
		this.fileName = fileName;
		this.formNames = formNames;
		this.contentType = contentType;
	}

	public byte[] getData() {
		return data;
	}

	public void setData(byte[] data) {
		this.data = data;
	}

	public String getFileName() {
		return fileName;
	}

	public void setFileName(String fileName) {
		this.fileName = fileName;
	}

	public String getFormNames() {
		return formNames;
	}

	public void setFormNames(String formNames) {
		this.formNames = formNames;
	}

	public String getContentType() {
		return contentType;
	}

	public void setContentType(String contentType) {
		this.contentType = contentType;
	}

	public InputStream getInputStream() {
		return inputStream;
	}

	public void setInputStream(InputStream inputStream) {
		this.inputStream = inputStream;
	}
	
	
	
	
	

}
