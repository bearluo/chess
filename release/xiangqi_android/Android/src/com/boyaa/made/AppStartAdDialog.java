package com.boyaa.made;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.AlertDialog;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.os.Message;
import android.util.DisplayMetrics;
import android.view.KeyEvent;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.SimpleAdapter;

import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.chinesechess.platform91.R;
import com.boyaa.entity.core.HandMachine;
import com.boyaa.proxy.share.ShareManager;
import com.boyaa.util.FastBlur;

public class AppStartAdDialog extends AlertDialog {

	protected ImageView adImgView;
	private ImageView shareBg;
	protected Button closeButton;
	protected Button shareButton;
	protected Button closeShareButton;
	protected GridView shareView;
	protected String path;
	protected static double buttonWidth; // button宽度
	protected static double buttonHeight; // button高度
	protected static double scale; // 缩放比例
	protected Activity context;

	Bitmap bm = null;
	Bitmap bmBlur = null;
	
	public AppStartAdDialog(Activity context) {
		super(context, R.style.CustomDialog);
		// TODO Auto-generated constructor stub
		this.context = context;
	}

	@Override
	public void show() {
		super.show();
		// TODO Auto-generated method stub
		buttonWidth = (double) closeButton.getLayoutParams().width;
		buttonHeight = (double) closeButton.getLayoutParams().height;
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		setContentView(R.layout.start_ad_default);
		adImgView = (ImageView) findViewById(R.id.startAdImg);
		adImgView.setScaleType(ImageView.ScaleType.FIT_XY);
		closeButton = (Button) findViewById(R.id.closeBtn);
		closeButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				Game.getGameHandler().removeMessages(Game.HANDLER_CLOSE_START_AD_DIALOG);
				Message msg = new Message();
				msg.what = Game.HANDLER_CLOSE_START_AD_DIALOG;
				Game.getGameHandler().sendMessage(msg);
			}
		});
		
		shareBg = (ImageView) findViewById(R.id.shareBg);
		shareBg.setVisibility(View.INVISIBLE);

		shareButton = (Button) findViewById(R.id.shareBtn);
		shareButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				shareView.setVisibility(View.VISIBLE);
				closeShareButton.setVisibility(View.VISIBLE);
				shareBg.setVisibility(View.VISIBLE);
				if (bmBlur!=null){
					adImgView.setImageBitmap(bmBlur);
				}
			}
		});
		closeShareButton = (Button) findViewById(R.id.closeShareBtn);
		closeShareButton.setVisibility(View.INVISIBLE);
		closeShareButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				shareView.setVisibility(View.INVISIBLE);
				closeShareButton.setVisibility(View.INVISIBLE);
				shareBg.setVisibility(View.INVISIBLE);
				adImgView.setImageBitmap(bm);
			}
		});	
		
		shareView = (GridView) findViewById(R.id.gridViewShare);
		shareView.setVisibility(View.INVISIBLE);
		shareView.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> parent, View view, final int position,long id) {
				// TODO Auto-generated method stub
				handleBmp2();
				ShareManager.shareImage(position+1, path, bm);
			}
		});
		
	    int[] icon ={
	    		R.drawable.share_wechat, R.drawable.share_pyq,R.drawable.share_qq, 
	    		R.drawable.share_weibo, R.drawable.share_sms,R.drawable.share_local,
	    		};
	    String[] iconName = { 
	    		"微信", "朋友圈", "QQ", 
	    		"微博", "短信", "保存本地",
	            };
	    List<Map<String, Object>> data_list = new ArrayList<Map<String, Object>>();
	    
        for(int i=0;i<icon.length;i++){
            Map<String, Object> map = new HashMap<String, Object>();
            map.put("start_share_image", icon[i]);
            map.put("start_share_text", iconName[i]);
            data_list.add(map);
        }
        String [] from ={"start_share_image","start_share_text"};
        int [] to = {R.id.start_share_image,R.id.start_share_text};
        SimpleAdapter sim_adapter = new SimpleAdapter(context,data_list,R.layout.start_share_item,from,to);
        //配置适配器
        shareView.setAdapter(sim_adapter);
        
		handleBmp2();
		adImgView.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				// 跳转链接
				Message msg = new Message();
				msg.what = Game.HANDLER_START_AD_DIALOG_JUMP_URL;
				Game.getGameHandler().sendMessage(msg);
			}
		});
		if (bm != null){
			int scaleBm = 5;
			Bitmap bm2 = Bitmap.createScaledBitmap(bm, bm.getWidth()/scaleBm, bm.getHeight()/scaleBm, false);
			bmBlur = blur(bm2,2);
		}
	}

	@Override
	protected void onStart() {
		// TODO Auto-generated method stub
		super.onStart();
	}

	@Override
	protected void onStop() {
		// TODO Auto-generated method stub
		super.onStop();
	}

	public void setDownloadImg(String imgPath) {
		// adImgView.setImageBitmap(BitmapFactory.decodeFile(imgPath));
	}

	public void setWindowScale(double winscale) {
		scale = winscale;
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0) {
			return true;
		}

		return super.onKeyDown(keyCode, event);
	}

	@Override
	public void dismiss() {
		// TODO Auto-generated method stub
		super.dismiss();
		recycleBmp();
	}
	/*
	 * bmp图片压缩（暂时不用）,手动分配图片内存
	 */
//	public void handleBmp() {
//		path = FileUtil.getmStrImagesPath() + "download_ad_start.png";
//		BitmapFactory.Options bfOptions = new BitmapFactory.Options();
//		bfOptions.inDither = false; /* 不进行图片抖动处理 */
//		bfOptions.inPurgeable = true;
//		bfOptions.inTempStorage = new byte[24 * 1024];
//		File file = new File(path);
//		FileInputStream fs = null;
//		try {
//			fs = new FileInputStream(file);
//		} catch (FileNotFoundException e) {
//			e.printStackTrace();
//		}
//		if (fs != null) {
//			try {
//				bm = BitmapFactory.decodeFileDescriptor(fs.getFD(), null,
//						bfOptions);
//			} catch (IOException e) {
//				e.printStackTrace();
//			} finally {
//				if (fs != null) {
//					try {
//						fs.close();
//					} catch (IOException e) {
//						e.printStackTrace();
//					}
//				}
//			}
//		}
//		if (null != bm) {
//			adImgView.setImageBitmap(bm);
//		}
//	}
	/*
	 * bmp图片压缩
	 */
	public void handleBmp2() {
		try {
			DisplayMetrics dm = new DisplayMetrics();
			// 获取屏幕信息
			context.getWindowManager().getDefaultDisplay().getMetrics(dm);
			int screenWidth = dm.widthPixels;
			int screenHeigh = dm.heightPixels;
	
			path = FileUtil.getmStrImagesPath() + "download_ad_start.png";
			BitmapFactory.Options bfOptions = new BitmapFactory.Options();
			bfOptions.inJustDecodeBounds = true; // 设置了此属性一定要记得将值设置为false
			bm = BitmapFactory.decodeFile(path, bfOptions);
			bfOptions.inSampleSize = caculateInSampleSize(bfOptions, screenWidth, screenHeigh);
			bfOptions.inPreferredConfig = Bitmap.Config.ARGB_4444;
			/* 下面两个字段需要组合使用 */
			bfOptions.inPurgeable = true;
			bfOptions.inInputShareable = true;
			bfOptions.inJustDecodeBounds = false;
			bm = BitmapFactory.decodeFile(path, bfOptions);
			if (null != bm) {
				adImgView.setImageBitmap(bm);
			}
		} catch (OutOfMemoryError e) {

		}
	}
	/*
	 * 计算bmp图片压缩倍数
	 */
	public static int caculateInSampleSize(BitmapFactory.Options options,
			int reqWidth, int reqHeight) {

		int width = options.outWidth;
		int height = options.outHeight;
		int inSampleSize = 1;
		if (width > reqWidth || height > reqHeight) {
			int widthRadio = Math.round(width * 1.0f / reqWidth);
			int heightRadio = Math.round(height * 1.0f / reqHeight);
			inSampleSize = Math.max(widthRadio, heightRadio);
		}
		return inSampleSize;
	}
	/*
	 * 回收bmp
	 */
	public void recycleBmp() {
		if (bm != null && !bm.isRecycled()) {
			adImgView.setImageDrawable(null);
			bm.recycle();
			bm = null;
		}
		if (bmBlur != null && !bmBlur.isRecycled()) {
			adImgView.setImageDrawable(null);
			bmBlur.recycle();
			bmBlur = null;
		}
		System.gc();
	}
	
    private Bitmap blur(Bitmap bkg, int radius) {  
    	return FastBlur.doBlur(bkg, radius, true);
    }  
}
