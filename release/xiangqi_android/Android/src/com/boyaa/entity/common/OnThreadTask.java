package com.boyaa.entity.common;

public abstract class OnThreadTask
{
	public String tips;
	public volatile boolean backPressed = false;
	public BoyaaProgressDialog progressDialog;
	public abstract void onThreadRun();
	public abstract void onAfterUIRun();
	public abstract void onUIBackPressed();
};
