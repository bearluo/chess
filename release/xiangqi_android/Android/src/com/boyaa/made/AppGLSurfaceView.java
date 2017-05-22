package com.boyaa.made;

import javax.microedition.khronos.egl.EGL10;
import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.egl.EGLDisplay;

import android.content.Context;
import android.graphics.PixelFormat;
import android.opengl.GLSurfaceView;
import android.util.AttributeSet;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MotionEvent;

public class AppGLSurfaceView extends GLSurfaceView {

	private AppRenderer mRenderer = null;

	public AppGLSurfaceView(Context context) {
		super(context);
		initView();
		
	}

	public AppGLSurfaceView(Context context, AttributeSet attrs) {
		super(context, attrs);
		initView();
	}

	protected void initView() {
		setFocusableInTouchMode(true);
		setEGLContextClientVersion(2);
		setEGLConfigChooser(new AppConfigChooser());
		getHolder().setKeepScreenOn(true);
		getHolder().setFormat(PixelFormat.RGBA_8888);
		mRenderer = new AppRenderer();
		setRenderer(mRenderer);
	}

	public boolean isGLThread() {
		String name = Thread.currentThread().getName();
		if ( null == name || 0 == name.length() || 0 != name.compareTo(AppRenderer.LUA_THREAD_NAME))
		{
			Log.e("bymade","do not call dict/sys function in other thread.");
			return false;
		}
		return true;
	}

	@Override
	public void onPause() {
		queueEvent(new Runnable() {
			@Override
			public void run() {
				mRenderer.handleOnPause();
			}
		});

		super.onPause();
	}

	@Override
	public void onResume() {
		super.onResume();

		queueEvent(new Runnable() {
			@Override
			public void run() {
				mRenderer.handleOnResume();
			}
		});
	}

	// /////////////////////////////////////////////////////////////////////////
	// for touch event
	// /////////////////////////////////////////////////////////////////////////

	@Override
	public boolean onTouchEvent(final MotionEvent event) {

		// these data are used in ACTION_MOVE and ACTION_CANCEL
		final int pointerNumber = event.getPointerCount();
		final int[] ids = new int[pointerNumber];
		final float[] xs = new float[pointerNumber];
		final float[] ys = new float[pointerNumber];
		final long[] ts = new long[pointerNumber];
			
		for (int i = 0; i < pointerNumber; i++) {
			ids[i] = event.getPointerId(i);
			xs[i] = event.getX(i);
			ys[i] = event.getY(i);
			ts[i] = event.getEventTime();
		}

		switch (event.getAction() & MotionEvent.ACTION_MASK) {
		case MotionEvent.ACTION_POINTER_DOWN:
			final int idPointerDown = event.getAction() >> MotionEvent.ACTION_POINTER_ID_SHIFT;
			final float xPointerDown = event.getX(idPointerDown);
			final float yPointerDown = event.getY(idPointerDown);
			final long  tPointerDown = event.getEventTime();
			if ( null != mRenderer )
			{
				mRenderer.queueTouchEvent(new Runnable() {
				@Override
				public void run() {
					mRenderer.handleActionDown(idPointerDown, xPointerDown, yPointerDown,tPointerDown);
				}
			});
			}
			break;

		case MotionEvent.ACTION_DOWN:
			// there are only one finger on the screen
			final int idDown = event.getPointerId(0);
			final float xDown = xs[0];
			final float yDown = ys[0];
			final long  tDown = ts[0];
			if ( null != mRenderer )
			{
				mRenderer.queueTouchEvent(new Runnable() {
					@Override
					public void run() {
						mRenderer.handleActionDown(idDown, xDown, yDown,tDown);
					}
				});
			}
			break;

		case MotionEvent.ACTION_MOVE:
			if ( null != mRenderer )
			{
				mRenderer.queueTouchEvent(new Runnable() {
					@Override
					public void run() {
						mRenderer.handleActionMove(ids, xs, ys,ts);
					}
				});
			}
			break;

		case MotionEvent.ACTION_POINTER_UP:
			final int idPointerUp = event.getAction() >> MotionEvent.ACTION_POINTER_ID_SHIFT;
			final float xPointerUp = event.getX(idPointerUp);
			final float yPointerUp = event.getY(idPointerUp);
			final long  tPointerUp = event.getEventTime();
			if ( null != mRenderer )
			{
				mRenderer.queueTouchEvent(new Runnable() {
					@Override
					public void run() {
						mRenderer.handleActionUp(idPointerUp, xPointerUp, yPointerUp,tPointerUp);
					}
				});
			}
			break;

		case MotionEvent.ACTION_UP:
			// there are only one finger on the screen
			final int idUp = event.getPointerId(0);
			final float xUp = xs[0];
			final float yUp = ys[0];
			final long tUp = ts[0];
			if ( null != mRenderer )
			{
				mRenderer.queueTouchEvent(new Runnable() {
					@Override
					public void run() {
						mRenderer.handleActionUp(idUp, xUp, yUp,tUp);
					}
				});
			}
			break;

		case MotionEvent.ACTION_CANCEL:
			if ( null != mRenderer )
			{
				mRenderer.queueTouchEvent(new Runnable() {
					@Override
					public void run() {
						mRenderer.handleActionCancel(ids, xs, ys,ts);
					}
				});
			}
			break;
		}
		return true;
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		final int kc = keyCode;
		if (keyCode == KeyEvent.KEYCODE_BACK) {
			if ( null != mRenderer )
			{
				mRenderer.queueTouchEvent(new Runnable() {
					@Override
					public void run() {
						mRenderer.handleKeyDown(kc);
					}
				});
			}
			return true;
		}
		return super.onKeyDown(keyCode, event);
	}

	public static class AppConfigChooser implements GLSurfaceView.EGLConfigChooser {

	    @Override
	    public EGLConfig chooseConfig(EGL10 egl, EGLDisplay display) {
	        
	    	EGLConfig config = null;
	        int[] configNum = new int[1];
	    	
	        int[] configAttributes1 = {
	                EGL10.EGL_RED_SIZE, 8,
	                EGL10.EGL_GREEN_SIZE, 8,
	                EGL10.EGL_BLUE_SIZE, 8,
	                EGL10.EGL_ALPHA_SIZE,8,
	                EGL10.EGL_DEPTH_SIZE, 16,
	                EGL10.EGL_STENCIL_SIZE,0,
	                EGL10.EGL_RENDERABLE_TYPE,4,
	                EGL10.EGL_NONE
	        };
	        egl.eglChooseConfig(display, configAttributes1, null, 0, configNum);
	        int num = configNum[0];
	        if ( num > 0 )
	        {
	            EGLConfig[] configs1 = new EGLConfig[num];
	            egl.eglChooseConfig(display, configAttributes1, configs1, num, configNum);
	            config = configs1[0];
	        }
	        else
	        {
		        int[] configAttributes2 = {
		                EGL10.EGL_RED_SIZE, 8,
		                EGL10.EGL_GREEN_SIZE, 8,
		                EGL10.EGL_BLUE_SIZE, 8,
		                EGL10.EGL_ALPHA_SIZE,8,
		                EGL10.EGL_RENDERABLE_TYPE,4,
		                EGL10.EGL_NONE
		        };
		        egl.eglChooseConfig(display, configAttributes2, null, 0, configNum);
		        num = configNum[0];
		        if ( num > 0 )
		        {
		            EGLConfig[] configs2 = new EGLConfig[num];
		            egl.eglChooseConfig(display, configAttributes2, configs2, num, configNum);
		            config = configs2[0];
		        }
		        else
		        {
			        int[] configAttributes3 = {
			                EGL10.EGL_RED_SIZE, 8,
			                EGL10.EGL_GREEN_SIZE, 8,
			                EGL10.EGL_BLUE_SIZE, 8,
			                EGL10.EGL_RENDERABLE_TYPE,4,
			                EGL10.EGL_NONE
			        };
			        egl.eglChooseConfig(display, configAttributes3, null, 0, configNum);
			        num = configNum[0];
			        if ( num > 0 )
			        {
			            EGLConfig[] configs3 = new EGLConfig[num];
			            egl.eglChooseConfig(display, configAttributes3, configs3, num, configNum);
			            config = configs3[0];
			        }
			        else
			        {
				        int[] configAttributes4 = {
				                EGL10.EGL_RED_SIZE, 5,
				                EGL10.EGL_GREEN_SIZE, 6,
				                EGL10.EGL_BLUE_SIZE, 5,
				                EGL10.EGL_RENDERABLE_TYPE,4,
				                EGL10.EGL_NONE
				        };
				        egl.eglChooseConfig(display, configAttributes4, null, 0, configNum);
				        num = configNum[0];
				        if ( num > 0 )
				        {
				            EGLConfig[] configs4 = new EGLConfig[num];
				            egl.eglChooseConfig(display, configAttributes4, configs4, num, configNum);
				            config = configs4[0];
				        }
				        else
				        {
				        	throw new IllegalArgumentException("No opengl configs match");	
				        }
			        }
		        }
	        }
	        return config;
	    }
	}
}
