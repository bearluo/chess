package com.boyaa.chinesechess.platform91.wxapi;


import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.chinesechess.platform91.R;
import com.boyaa.entity.core.HandMachine;
import com.tencent.mm.opensdk.constants.ConstantsAPI;
import com.tencent.mm.opensdk.modelbase.BaseReq;
import com.tencent.mm.opensdk.modelbase.BaseResp;
import com.tencent.mm.opensdk.modelmsg.SendAuth;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

public class WXPayEntryActivity extends Activity implements IWXAPIEventHandler{
	
	private static final String TAG = "weixinPay";
	
    private IWXAPI api;// = SendToWXUtil.api;

	private int result;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    	api = WXAPIFactory.createWXAPI(this, Constants.APP_ID);
        api.handleIntent(getIntent(), this);
    }

	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
		setIntent(intent);
        api.handleIntent(intent, this);
	}

	@Override
	public void onReq(BaseReq req) {
	}

	@Override
	public void onResp(BaseResp resp) {
		Log.d(TAG, "onPayFinish, errCode = " + resp.errCode);

		if (resp.getType() == ConstantsAPI.COMMAND_PAY_BY_WX) {
			boolean success = false;
			switch (resp.errCode) {
			case BaseResp.ErrCode.ERR_OK:
					result = R.string.pay_success;
					success = true;
				break;
			case BaseResp.ErrCode.ERR_USER_CANCEL:
					result = R.string.pay_cancel;
				break;
			case BaseResp.ErrCode.ERR_AUTH_DENIED:
					result = R.string.pay_deny;
				break;
			default:
					result = R.string.pay_unknown;
				break;
			}
			Toast.makeText(this, result, Toast.LENGTH_LONG).show();
			finish();
			if(success) {
				Game.mActivity.runOnLuaThread(new Runnable() {
					
					@Override
					public void run() {
						// TODO Auto-generated method stub
						HandMachine.getHandMachine().luaCallEvent(HandMachine.kPaySuccess, "");
					}
				});
			}
			else {
				Game.mActivity.runOnLuaThread(new Runnable() {
					
					@Override
					public void run() {
						// TODO Auto-generated method stub
						HandMachine.getHandMachine().luaCallEvent(HandMachine.kPayFailed, "");
					}
				});
			}
		}
	}
}