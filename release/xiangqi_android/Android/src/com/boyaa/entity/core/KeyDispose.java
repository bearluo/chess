package com.boyaa.entity.core;

import com.boyaa.made.AppActivity;

public class KeyDispose {
	
	public KeyDispose(){
		
	}
	
	
	public void back(String key , String result){
		HandMachine.getHandMachine().luaCallEvent(key , result);
	}
	
	public void home(String key , String result){
		HandMachine.getHandMachine().luaCallEvent(key , result);
	}
	public void exit(String key , String result){
		AppActivity.terminateProcess();
	}
	
}
