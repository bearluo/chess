package com.boyaa.thread;


public class TaskThread extends Thread {
	private TaskManager mTaskManager;
	public TaskThread(TaskManager taskManager) {
		mTaskManager = taskManager;
	}
	
	public void run() {
		while(true) {
			ITask task = mTaskManager.getTask();
			if (task == null) {
				synchronized(mTaskManager) {
					try {
						mTaskManager.wait();
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
				}
			} else {
				try {
					task.execute();
					task.postExecute();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}
	}

	@Override
	public void destroy() {
		// TODO Auto-generated method stub
		super.destroy();
	}
	
}
