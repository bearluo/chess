package com.boyaa.widget;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.RectF;
import android.graphics.Region;
import android.util.AttributeSet;
import android.util.Log;
import android.widget.ImageView;

import com.boyaa.common.PhoneScreen;

public class ProgressBar extends ImageView {
	private int total = 100;
	private int progress = -1;
	private int margin = PhoneScreen.dip2px(3);

	private Paint mPaint;
	private int coverColor = 0xff00E100;
	private int textColor = 0xff000000;
	public ProgressBar(Context context) {
		super(context);
		init();
	}

	public ProgressBar(Context context, AttributeSet attrs) {
		super(context, attrs);
		init();
	}

	public ProgressBar(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		init();
	}

	private void init() {
        mPaint = new Paint();
        mPaint.setAntiAlias(true);
        mPaint.setStrokeWidth(6);
        mPaint.setTextSize(22);
        mPaint.setTextAlign(Paint.Align.CENTER);
        mPaint.setColor(coverColor);
	}

	@Override
	protected void onDraw(Canvas canvas) {
		super.onDraw(canvas);
		if (progress >= 0) {
			drawProgress(canvas);
		}
	}
	
	@Override
	public void draw(Canvas canvas) {
		super.draw(canvas);
	}
	

	private void drawProgress(Canvas canvas) {
		int coverWidth = getWidth() - margin*2;
		int coverHeight = getHeight() - margin*2;
//		int cx = coverWidth / 2;
//		int cy = coverHeight / 2;
		int percent = (int)(progress*1f/total*100);
		int clipWidth = (int)((100 - percent)*0.01*coverWidth);
//		Log.d("CDH", "ProgressImageView clipHeight:"+clipHeight + " margin:" + margin + " percent:"+ percent +" cWidth:"+coverWidth + " Width:"+getWidth());
		Log.d("Thread111", "drawProgress前" +"="+percent);
		canvas.save();
		canvas.translate(margin + coverWidth, margin + coverHeight);
		canvas.rotate(180);
		Log.d("Thread111", "drawProgress中" +"="+percent);
        canvas.clipRect(0, 0, clipWidth, coverHeight, Region.Op.DIFFERENCE);
        mPaint.setColor(coverColor);
        if (percent == 100) mPaint.setColor(0xff3DFA92);
		canvas.drawRoundRect(new RectF(margin, margin, margin + coverWidth, margin + coverHeight), 8, 6, mPaint);
		canvas.restore();
		Log.d("Thread111", "drawProgress后" +"="+percent);
	}

	@Override
	public void dispatchDraw(Canvas canvas) {
		if (progress >= 0) {
			//mPaint.setTextSize(20);
			mPaint.setColor(textColor);
			
			int percent = progress*100/total;
			canvas.drawText(percent + "%", getWidth()/2, (int)(getHeight()/1.6), mPaint);
		}
	}
	
	public void setTotal(int total) {
		this.total = total;
	}

	public void setProgress(int progress) {
		this.progress = progress;
	}

	public void setCoverColor(int color) {
		coverColor = color;
	}
	
	public void setTextColor(int color) {
		textColor = color;
	}
	
	public void update() {
		this.invalidate();
	}
	
	public void clear() {
		progress = -1;
		this.invalidate();
	}

//*************以下代码是测试使用*****************
	public void show() {
		new Thread() {
			public void run() {
				int times = 100;
				while (times-- > 0) {
					progress++;
					try {
						Thread.sleep(400);
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
					ProgressBar.this.postInvalidate();
				}
			}
		}.start();
	}
}
