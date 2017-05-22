package com.boyaa.widget;

//import java.util.Iterator;

import com.boyaa.common.PhoneScreen;

//import android.R.integer;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.view.View;

public class NewDotsView extends View{

	private int marginPs = 8;//默认8ps
	private int leftPadding = 0;
	private int dotWidth = 0;
	private int width;
	private int heigth;
	private int dotcount;
	private int selectIndex;
	private Bitmap selected;
	private Bitmap unselected;
	private Rect orRect;
	private Rect relateRect;
	public NewDotsView(Context context, AttributeSet attrs) {
		super(context, attrs);
		orRect = new Rect();
		relateRect = new Rect();
		// TODO Auto-generated constructor stub
	}
	public NewDotsView(Context context) {
		super(context);
		orRect = new Rect();
		relateRect = new Rect();
		// TODO Auto-generated constructor stub
	}
	@Override
	protected void onSizeChanged(int w, int h, int oldw, int oldh) {
		// TODO Auto-generated method stub
		width = w;
		heigth = h;
		ajestPosition();
		this.invalidate();
		super.onSizeChanged(w, h, oldw, oldh);
	}
	@Override
	protected void onDraw(Canvas canvas) {
		// TODO Auto-generated method stub
		Bitmap bitmap = unselected;
		for (int i = 0;i<dotcount;i++) {
			if(i==selectIndex){
				bitmap = selected;
			} else {
				bitmap = unselected;
			}
			//canvas.drawBitmap(bitmap, leftPadding+i*(dotWidth+marginPs), heigth/2, null);
			relateRect.left = leftPadding+i*(dotWidth+marginPs);
			relateRect.right = relateRect.left+dotWidth;
			canvas.drawBitmap(bitmap, orRect, relateRect, null);
		}
	}
	
	public void setDot(Bitmap selected, Bitmap unselected) {
		this.selected = selected;
		this.unselected = unselected;
		dotWidth = selected.getHeight();
		dotWidth = PhoneScreen.psw(dotWidth);
		orRect.left = 0;
		orRect.bottom = dotWidth;
		orRect.top = 0;
		orRect.right = dotWidth;
		ajestPosition();
	}
	public void setDotWidth(int width){
		dotWidth = PhoneScreen.psw(width);
		ajestPosition();
	}
	public void setMarginPs(int marginPs) {
		this.marginPs = PhoneScreen.psw(marginPs);
	}
	public void setDotcount(int dotcount) {
		this.dotcount = dotcount;
		ajestPosition();
		this.invalidate();
	}
	
	private void ajestPosition(){
		
		relateRect.top = heigth/2;
		relateRect.bottom = relateRect.top+dotWidth;
		relateRect.left = 0;
		relateRect.right = dotWidth;
		leftPadding = (width - (dotcount*dotWidth+(dotcount-1)*marginPs))/2;
	}

	public void setSelectIndex(int selectIndex) {
		this.selectIndex = selectIndex;
		this.invalidate();
	}
	
}
