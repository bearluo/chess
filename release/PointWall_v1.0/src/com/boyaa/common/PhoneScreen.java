package com.boyaa.common;

//import com.boyaa.BoyaaApplication;
import android.view.ViewGroup;
import android.widget.ImageView;

public class PhoneScreen {
	public static int width;//灞忓箷瀹藉害锛堝儚鏁帮級
	public static int height;//灞忓箷楂樺害锛堝儚鏁帮級
	public static float density;//瀵嗗害鍊�

	public static int statusBarHeight;//鐘舵�鏍忛珮搴︼紙鍍忔暟锛�
	
	public static final float WIDTH_V = 480;//铏氭嫙灞忓箷瀹藉害
	public static final float HEIGHT_V = 800;//铏氭嫙灞忓箷楂樺害
	
	//鎵嬫満灞忓箷涓庤櫄鎷熷睆骞曠殑姣旂巼
	public static float widthScale;
	public static float heightScale;
	public static float minScale;//瀹藉害鍜岄珮搴︿腑鐨勫皬鑰�
	
	public static boolean isNotInit() {
		return width == 0;
	}

	/** 涓庡搴︽垨鑰呴珮搴︽渶灏忓昂瀵告棤鍏�*/
	public static int reviseSize(int size) {
		size *= minScale;
		return size;
	}
	
	/** 涓庡昂瀵告棤鍏冲搴�*/
	public static int reviseWidth(int w) {
		w *= widthScale;
		return w;
	}
	
	/** 涓庡昂瀵告棤鍏抽珮搴�*/
	public static int reviseHeight(int h) {
		h *= heightScale;
		return h;
	}

	public static int dip2px(int dip) {
		return Math.round(dip * density);
	}
	
	public static int px2dip(int px) {
		return Math.round(px / density);
	}

	/** 涓庡瘑搴﹀拰灏哄鏃犲叧瀹藉害 */
	public static int psw(int ps) {
		return reviseWidth(dip2px(ps));
	}

	/** 涓庡瘑搴﹀拰灏哄鏃犲叧楂樺害 */
	public static int psh(int ps) {
		return reviseHeight(dip2px(ps));
	}

	/** 鎸夋墜鏈哄垎杈ㄧ巼鏈�皬姣旂巼缂╂斁鍥剧墖锛屽浘鐗囧搴﹂珮搴︿笉鍙�*/
	public static void reviseImageViewSize(ImageView view) {
		if (view != null) {
			ViewGroup.LayoutParams lp = view.getLayoutParams();
			lp.width = reviseSize(lp.width);
			lp.height = reviseSize(lp.height);
			view.setLayoutParams(lp);
		}
	}
}
