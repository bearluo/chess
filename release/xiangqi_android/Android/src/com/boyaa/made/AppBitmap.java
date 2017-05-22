package com.boyaa.made;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

import java.util.HashMap;

import android.content.Context;
import android.graphics.Bitmap;

import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.Typeface;
import android.graphics.Paint.Align;
import android.graphics.Paint.FontMetricsInt;
import android.text.StaticLayout;
import android.text.TextPaint;
import android.text.Layout.Alignment;

public class AppBitmap {
	public static int TEXTURE_MAX = 0;
	/*
	 * The values are the same as TextJin.h
	 */
	private final static int ALIGNCENTER = 0x33;
	private final static int ALIGNLEFT = 0x31;
	private final static int ALIGNRIGHT = 0x32;

	private final static int ALIGNTOP = 0x13;
	private final static int ALIGNTOPRIGHT = 0x12;
	private final static int ALIGNBOTTOMRIGHT = 0x22;

	private final static int ALIGNBOTTOM = 0x23;
	private final static int ALIGNBOTTOMLEFT = 0x21;
	private final static int ALIGNTOPLEFT = 0x11;

	private static Context mContext;
	private static Paint mPaint = new Paint();
	private static TextPaint mTextPaint = new TextPaint();
	private static HashMap<String, Typeface> mFonts = new HashMap<String, Typeface>();

	public static void setContext(Context mContext) {
		AppBitmap.mContext = mContext;
	}

	private static Typeface getFont(String fontName) {
		if (!mFonts.containsKey(fontName)) {
			try {
				Typeface typeFace = Typeface.createFromAsset(mContext.getAssets(), "fonts/" + fontName);
				mFonts.put(fontName, typeFace);
			} catch (Exception e) {
				return null;
			}
		}
		return mFonts.get(fontName);
	}

	private static Paint resetPaint(String fontName, int fontSize) {
		mPaint.reset();
//		int red 	= AppActivity.dict_get_int("ResText","r",255);
//		int green 	= AppActivity.dict_get_int("ResText","g",255);
//		int blue 	= AppActivity.dict_get_int("ResText","b",255);
//		mPaint.setColor(Color.rgb(red, green, blue));
		mPaint.setColor(Color.WHITE);
		mPaint.setTextAlign(Align.LEFT);
		mPaint.setTextSize(fontSize);
		mPaint.setAntiAlias(true);
		if (null != fontName && fontName.length() > 0 && fontName.endsWith(".ttf")) {
			Typeface typeFace = getFont(fontName);
			if (null != typeFace) {
				mPaint.setTypeface(typeFace);
			} else {
				mPaint.setTypeface(null);
			}
		}
		else
		{
			// cuipeng add 2014-09-10
			mPaint.setTypeface(null);
		}
		return mPaint;
	}

	private static void drawText(Canvas canvas, String content, int width, int height, Paint paint, int alignment) {

		Rect rc = new Rect();
		paint.getTextBounds(content, 0, content.length(), rc);
		int transY = -rc.top;
		int mw = (int)paint.measureText(content);
		//use mw instead of rc.width();

		float x = 0;
		float y = 0;
		switch (alignment) {
		case ALIGNTOP:
			x = (width - mw) / 2;
			y = 0;
			break;
		case ALIGNTOPLEFT:
			x = 0;
			y = 0;
			break;
		case ALIGNTOPRIGHT:
			x = width - mw;
			y = 0;
			break;
		case ALIGNBOTTOM:
			x = (width - mw) / 2;
			y = height - rc.height();
			break;

		case ALIGNBOTTOMLEFT:
			x = 0;
			y = height - rc.height();
			break;

		case ALIGNBOTTOMRIGHT:
			x = width - mw;
			y = height - rc.height();
			break;

		case ALIGNCENTER:
			x = (width - mw) / 2;
			y = (height - rc.height()) / 2;
			break;
		case ALIGNLEFT:
			x = 0;
			y = (height - rc.height()) / 2;
			break;
		case ALIGNRIGHT:
			x = width - mw;
			y = (height - rc.height()) / 2;
			break;
		default:

		}
		canvas.save();
		canvas.translate(0, transY);
		canvas.drawText(content, x, y, paint);
		canvas.restore();
	}

	public static void createTextBitmap(byte[] contentArray, byte[] fontNameArray, int fontSize, int alignment, int width, int height, int iMultiLine) {

		String content = "";
		String fontName = "";
		if (null == contentArray || 0 == contentArray.length) {
			content = "0";
		}
		else
		{
			content = new String(contentArray);
		}
		if ( null == fontNameArray || 0 == fontNameArray.length ){
			fontName = "";
		}
		else
		{
			fontName = new String(fontNameArray);
		}
		if (0 > width)
			width = 0;
		if (0 > height)
			height = 0;

		Paint paint = resetPaint(fontName, fontSize);

		// single line
		if (0 == iMultiLine) {
			content = content.replaceAll("(\r\n|\n\r|\r|\n)", "");
			int singleLineMaxWidth = (int) Math.ceil(paint.measureText(content, 0, content.length()));
			FontMetricsInt fm = paint.getFontMetricsInt();
			int singleLineHeight = (int) Math.ceil(fm.bottom - fm.top);

			if (width < singleLineMaxWidth) {
				width = singleLineMaxWidth;
			}
			if (height < singleLineHeight) {
				height = singleLineHeight;
			}
			if (width > TEXTURE_MAX) {
				width = TEXTURE_MAX;
			}
			if (height > TEXTURE_MAX) {
				height = TEXTURE_MAX;
			}
			Bitmap bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
			Canvas canvas = new Canvas(bitmap);
			drawText(canvas, content, width, height, paint, alignment);
			// call c
			initNativeObject(bitmap);
			bitmap.recycle();
		} else {
			Alignment align = Alignment.ALIGN_NORMAL;
			switch (alignment) {
			case ALIGNLEFT:
			case ALIGNTOPLEFT:
			case ALIGNBOTTOMLEFT:
				align = Alignment.ALIGN_NORMAL;
				break;
			case ALIGNRIGHT:
			case ALIGNTOPRIGHT:
			case ALIGNBOTTOMRIGHT:
				align = Alignment.ALIGN_OPPOSITE;
				break;
			case ALIGNCENTER:
			case ALIGNTOP:
			case ALIGNBOTTOM:
				align = Alignment.ALIGN_CENTER;
				break;
			default:

			}
			mTextPaint.set(paint);
			if (width < 1)
				width = 8;
			if (width > TEXTURE_MAX) {
				width = TEXTURE_MAX;
			}
			StaticLayout layout = new StaticLayout(content, mTextPaint, width, align, 1.0f, 0.0f, false);
			int h;
			int transY = 0;
			if (layout.getHeight() < height) {
				h = height;
				switch (alignment) {
				case ALIGNTOP:
				case ALIGNTOPLEFT:
				case ALIGNTOPRIGHT:
					transY = 0;
					break;
				case ALIGNBOTTOM:
				case ALIGNBOTTOMLEFT:
				case ALIGNBOTTOMRIGHT:
					transY = height - layout.getHeight();
					break;

				case ALIGNCENTER:
				case ALIGNLEFT:
				case ALIGNRIGHT:
					transY = (height - layout.getHeight()) / 2;
					break;
				default:

				}
			} else {
				transY = 0;
				h = layout.getHeight();
			}
			// Draw text to bitmap
			Bitmap bitmap = Bitmap.createBitmap(width, h, Bitmap.Config.ARGB_8888);
			Canvas canvas = new Canvas(bitmap);
			canvas.translate(0, transY);
			layout.draw(canvas);

			// call c
			initNativeObject(bitmap);
			bitmap.recycle();
		}
	}

	private static void initNativeObject(Bitmap bitmap) {
		byte[] pixels = getPixels(bitmap);
		if (pixels == null) {
			return;
		}

		nativeInitBitmapDC(bitmap.getWidth(), bitmap.getHeight(), pixels);
	}

	private static byte[] getPixels(Bitmap bitmap) {
		if (bitmap != null) {
			byte[] pixels = new byte[bitmap.getWidth() * bitmap.getHeight() * 4];
			ByteBuffer buf = ByteBuffer.wrap(pixels);
			buf.order(ByteOrder.nativeOrder());
			bitmap.copyPixelsToBuffer(buf);
			return pixels;
		}

		return null;
	}

	// c native function
	private static native void nativeInitBitmapDC(int width, int height, byte[] pixels);

}
