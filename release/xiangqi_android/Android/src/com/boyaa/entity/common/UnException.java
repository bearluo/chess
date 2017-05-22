package com.boyaa.entity.common;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.io.Writer;
import java.lang.Thread.UncaughtExceptionHandler;

/**
 * Uncaught Exception Handler.<br>
 * 每个线程(主线程/显式创建的或隐式创建的线程)尽量在开始时调用 UnException.threadInit().<br>
 * @author Shineflag
 * date 2012-01-30
 */
public final class UnException {
	
	/**
	 * see http://stuffthathappens.com/blog/2007/10/07/programmers-notebook-uncaught-exception-handlers/
	 * @author Shineflag
	 */
	public class DefaultExceptionHandler implements UncaughtExceptionHandler{

		// private UncaughtExceptionHandler defaultUEH;
		public DefaultExceptionHandler() {
			// this.defaultUEH = Thread.getDefaultUncaughtExceptionHandler();
		}
		
		@Override
		public void uncaughtException(Thread thread, Throwable ex) {
			  showException(thread, ex);
		}
		
	    private void showException(Thread t, Throwable e) {
	        String msg = String.format("Unexpected problem on thread %s: %s",
	                t.getName(), e.getMessage());

	        logException(t, e);

	        // note: in a real app, you should locate the currently focused frame
	        // or dialog and use it as the parent. 
	        System.out.println(msg);
	    }
	    
	    private void logException(Thread t, Throwable e) {
			String info = getStackTrace(e);
			boolean log = Log.log_file;
			Log.log_file = true;
			Log.e(t, info);
			Log.log_file = log;
	        // todo: start a thread that sends an email, or write to a log file, or
	        // send a JMS message...whatever
	    }
		
	}
	
	public DefaultExceptionHandler handler = new DefaultExceptionHandler();
	
	public void set(){
		Thread.setDefaultUncaughtExceptionHandler(handler);
	}
	
	public static String getStackTrace(Throwable e){
		Writer result = new StringWriter();
		PrintWriter printWriter = new PrintWriter(result);
		e.printStackTrace(printWriter);
		String stackTrace = result.toString();
		printWriter.close();
		return stackTrace;
	}
	
	public static String MName(){
		StackTraceElement stackTraceElements[] = (new Throwable()).getStackTrace();
		return stackTraceElements[1].toString();
	}
	
	public static UnException self = null;
	
	public static void threadInit(){
		if(null == self){
			self = new UnException();
		}
		self.set();
	}

}
