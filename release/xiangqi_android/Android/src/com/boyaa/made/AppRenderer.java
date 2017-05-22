package com.boyaa.made;

import java.util.ArrayList;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

import com.boyaa.chinesechess.platform91.Game;

import android.opengl.GLSurfaceView;
import android.util.Log;

public class AppRenderer implements GLSurfaceView.Renderer {
	public final static String LUA_THREAD_NAME = "GLThread.Lua";	
	public final static long NANOSECONDSPERSECOND = 1000000000L;// 1000,000,000
	public final static long NANOSECONDSPERMINISECOND = 1000000;// 1000,000
	public static long animationInterval = (long) (1.0 / 60 * NANOSECONDSPERSECOND);
	private boolean mFirstChange = false;
	private boolean mGLInit = false;
	private int mWaitNum = 0;
	private ArrayList<Runnable> mTouchEventQueue = new ArrayList();
	private static Object mTouchEventObj = new Object();
	public void queueTouchEvent(Runnable r)
	{
        synchronized(mTouchEventObj) {
        	mTouchEventQueue.add(r);
        }		
	}
	
    private Runnable getTouchEvent() {
        synchronized(mTouchEventObj) {
            if (mTouchEventQueue.size() > 0) {
                return mTouchEventQueue.remove(0);
            }
        }
        return null;
    }
	
	public void onSurfaceCreated(GL10 gl, EGLConfig config) {
		Thread.currentThread().setName(LUA_THREAD_NAME);
		Log.e("lua","onSurfaceCreated");
//		Game.getAdDialogPram();
		
		String strRender = gl.glGetString(GL10.GL_RENDERER);
		if (strRender.contains("PixelFlinger")) {
			AppActivity.getHandler().sendEmptyMessage(AppActivity.HANDLER_OPENGL_NOT_SUPPORT);
		} else {
			mFirstChange = true;

		}
		int[] arrSize = new int[1];
		gl.glGetIntegerv(GL10.GL_MAX_TEXTURE_SIZE, arrSize, 0);
		AppBitmap.TEXTURE_MAX = arrSize[0];

		mWaitNum = 0;
	}

	public void onSurfaceChanged(GL10 gl, int w, int h) {
		Thread.currentThread().setName(LUA_THREAD_NAME);
		Log.e("onSurfaceChanged", "w:"+w+" h:"+h);
		if (mFirstChange && AppActivity.mActivity.mWidth == w) {
			Log.e("onSurfaceChanged change", "w:"+w+" h:"+h+" w:"+AppActivity.mActivity.mWidth);
			AppActivity.mActivity.OnSetEnv();
			mGLInit = true;
			nativeInit(w, h);
			mWaitNum = 0;
			mFirstChange = false;
			AppActivity.mActivity.OnBeforeLuaLoad();
		}
	}
	//�Ƿ��Զ���֡
	public static boolean bAutoFramerate = true;

	public void onDrawFrame(GL10 gl) {
		if (mWaitNum < 3) {
			mWaitNum++;
			return;
		}

		if (!bAutoFramerate) {
			Runnable r;
			while ((r = getTouchEvent()) != null) {
				r.run();
			}

			AppActivity.sys_set_int("force_redraw", 1);
			nativeUpdate();
			nativeRender();
		} else {
			int skip = 0;
			while (true) {
				Runnable r;
				while ((r = getTouchEvent()) != null) {
					r.run();
				}

				if (1 == nativeUpdate()) {
					nativeRender();
					break;
				} else {
					sleep(1);
					skip++;
					if (100 == skip) {
						AppActivity.sys_set_int("force_redraw", 1);
					}
				}
			}
		}
	}

	private void sleep(long ms) {
		try {
			Thread.sleep(ms);
		} catch (Exception e) {
		}

	}

	public void handleActionDown(int id, float x, float y,long t) {
		nativeTouchesBegin(id, x, y,t);
	}

	public void handleActionUp(int id, float x, float y,long t) {
		nativeTouchesEnd(id, x, y,t);
	}

	public void handleActionCancel(int[] id, float[] x, float[] y,long[] t) {
		nativeTouchesCancel(id, x, y,t);
	}

	public void handleActionMove(int[] id, float[] x, float[] y,long[] t) {
		nativeTouchesMove(id, x, y,t);
	}

	public void handleKeyDown(int keyCode) {
		nativeKeyDown(keyCode);
	}

	public void handleOnPause() {
		nativeOnPause();
	}

	public void handleOnResume() {
		nativeOnResume();
	}

	// c native function
	private static native void nativeTouchesBegin(int id, float x, float y,long t);

	private static native void nativeTouchesEnd(int id, float x, float y,long t);

	private static native void nativeTouchesMove(int[] id, float[] x, float[] y,long[] t);

	private static native void nativeTouchesCancel(int[] id, float[] x, float[] y,long[] t);

	private static native boolean nativeKeyDown(int keyCode);

	private static native int nativeUpdate();
	private static native void nativeRender();

	private static native void nativeInit(int w, int h);

	private static native void nativeOnPause();

	private static native void nativeOnResume();

}
