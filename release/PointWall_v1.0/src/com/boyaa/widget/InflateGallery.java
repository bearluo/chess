package com.boyaa.widget;

import android.content.Context;
import android.graphics.Matrix;
import android.util.AttributeSet;
//import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.animation.Transformation;
import android.widget.Gallery;

public class InflateGallery extends Gallery {
	private int mCenterPoint, chileWidth, leftPoint, rightPint;

	public InflateGallery(Context context) {
		super(context);
		setStaticTransformationsEnabled(true);
	}

	public InflateGallery(Context context, AttributeSet attrs) {
		super(context, attrs);
		setStaticTransformationsEnabled(true);
	}

	public InflateGallery(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		setStaticTransformationsEnabled(true);
	}

    @Override  
    public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX, float velocityY) {  
//		int keyCode;
//		if (isScrollingLeft(e1, e2)) {
//			keyCode = KeyEvent.KEYCODE_DPAD_LEFT;
//		} else {
//			keyCode = KeyEvent.KEYCODE_DPAD_RIGHT;
//		}
//		onKeyDown(keyCode, null);
//		return true;
		return false;
    }

//	private boolean isScrollingLeft(MotionEvent e1, MotionEvent e2) {
//		return e2.getX() > e1.getX();
//	}

	protected boolean getChildStaticTransformation(View child, Transformation t) {
        //重置转换状态
        t.clear();
        //设置转换类型
        t.setTransformationType(Transformation.TYPE_MATRIX);

        if (mCenterPoint == 0) {
        	mCenterPoint = getCenterPoint();
        	chileWidth = child.getWidth();
        	leftPoint = mCenterPoint - chileWidth;
        	rightPint = mCenterPoint + chileWidth;
        }
        
        final Matrix imageMatrix = t.getMatrix();
        int childCenterPoint = getCenterOfView(child);
       
        if (childCenterPoint > leftPoint && childCenterPoint < rightPint) {
        	int centeroffset = chileWidth - Math.abs(mCenterPoint - childCenterPoint);
        	float scale = centeroffset*1f / chileWidth / 2 + 1;
            imageMatrix.postScale(scale, scale, child.getWidth() / 2, child.getHeight() / 2);
        }
		return true;
	}
	
	private int getCenterOfView(View view) {
		return view.getLeft() + view.getWidth() / 2;
	}
	
	private int getCenterPoint() {
        return (getWidth() - getPaddingLeft() - getPaddingRight()) / 2 + getPaddingLeft();
    }

}
