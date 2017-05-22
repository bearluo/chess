package com.boyaa.thread;

import java.util.Stack;

public class TaskManager {
	private final int THREAD_COUNT = 5;
	private TaskManager() {
		mStack = new Stack<ITask>();
		mStack.setSize(15);

		for (int i=0; i<THREAD_COUNT; i++) {
			new TaskThread(this).start();
		}
	}
	private static TaskManager self = new TaskManager();
	public static TaskManager getInstance() {
		return self;
	}

	private Stack<ITask> mStack;
	public synchronized void addTask(ITask task) {
//		if (mStack.size() >= 15) {
//			mStack.remove(mStack.firstElement());
//		}
		mStack.add(task);
		wakeThreadsUp();
	}
	
	private synchronized void wakeThreadsUp() {
		this.notifyAll();
	}

	synchronized ITask getTask() {
		ITask task = null;
		if (mStack.size() > 0) {
			task = mStack.pop();
		}
		return task;
	}
}
