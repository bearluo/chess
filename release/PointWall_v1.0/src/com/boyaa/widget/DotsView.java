package com.boyaa.widget;

//import com.boyaa.common.PhoneScreen;

import android.content.Context;
import android.graphics.Bitmap;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

public class DotsView extends ViewGroup {
	private int marginPs = 15;//默认8ps
	
	private int dotCount;
	private int dotPs;
	private Bitmap selected;
	private Bitmap unselected;
	
	private int leftPadding = -1;
	
	private int curSelected;//当前选择哪个点
	
	public DotsView(Context context) {
		super(context);
	}

	public DotsView(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public DotsView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
	}

	@Override
	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
		for (int index = 0; index < getChildCount(); index++) {
			final View child = getChildAt(index);
			child.measure(MeasureSpec.UNSPECIFIED, MeasureSpec.UNSPECIFIED);
		}
		super.onMeasure(widthMeasureSpec, heightMeasureSpec);
	}

	@Override
	protected void onLayout(boolean changed, int l, int t, int r, int b) {
		setLeftPadding();
		
		int cx = l + leftPadding;
		int cy = t;

		final int count = getChildCount();
		for(int i=0; i<count; i++){
			final View child = this.getChildAt(i);
			int width = child.getMeasuredWidth();
			int height = child.getMeasuredHeight();
			if (i > 0) {
				cx += width + marginPs;
			}
			child.layout(cx, cy, cx + width, cy + height);
		}
	}

	private void setLeftPadding() {
		if (leftPadding == -1) {
			final View child = this.getChildAt(0);
			if (child != null) {
				int aw = child.getMeasuredWidth() * dotCount + marginPs * (dotCount - 1);//所有点占的宽度
				leftPadding = getWidth() / 2 - aw / 2;
			}
		}
	}
	
	public void setDotCount(int count) {
		dotCount = count;
	}
	
	public void setDot(Bitmap selected, Bitmap unselected) {
		this.selected = selected;
		this.unselected = unselected;
	}
	
	public void setDotSize(int size) {
		this.dotPs = size;//PhoneScreen.psw(size);
	}
	
	public void setDotMargin(int dotMargin) {
		marginPs = dotMargin;//PhoneScreen.psw(dotMargin);
	}
	
	private void createChilds(int count, int s) {
		this.removeAllViews();
//		marginPs = PhoneScreen.psw(marginPs);
		
		for(int i=0; i<count; i++){
			ImageView child = new ImageView(this.getContext());
			child.setMinimumWidth(dotPs);
			child.setMinimumHeight(dotPs);
			if (i == s) child.setImageBitmap(selected);
			else child.setImageBitmap(unselected);
			this.addView(child);
		}
	}
	
	public void show() {
		show(0);
	}

	public void show(int selected) {
		curSelected = selected;

		createChilds(dotCount, selected);
		refresh();
	}
	
	public void select(int select) {
		int count = this.getChildCount();
		if (count > select) {
			//切换上次选择的结点的图片
			ImageView child = (ImageView)this.getChildAt(curSelected);
			child.setImageBitmap(unselected);

			//设置这次选择的结点的图片
			child = (ImageView)this.getChildAt(select);
			child.setImageBitmap(selected);

			curSelected = select;

			refresh();
		}
	}

	private void refresh() {
		this.invalidate();
	}
}
