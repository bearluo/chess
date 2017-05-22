package com.boyaa.chinesechess.platform91.wxapi;


import java.net.URI;

import org.apache.http.client.utils.URIUtils;

import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.chinesechess.platform91.R;
import com.boyaa.entity.core.HandMachine;
import com.boyaa.proxy.share.ShareManager;
import com.tencent.mm.opensdk.constants.ConstantsAPI;
import com.tencent.mm.opensdk.modelbase.BaseReq;
import com.tencent.mm.opensdk.modelbase.BaseResp;
import com.tencent.mm.opensdk.modelmsg.SendAuth;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;


import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

public class WXEntryActivity extends Activity implements IWXAPIEventHandler{
	public static Activity app;
    private IWXAPI api;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
    	api = WXAPIFactory.createWXAPI(this, Constants.APP_ID, false);
    	api.handleIntent(getIntent(), this);
    	app = this;
        super.onCreate(savedInstanceState);
    }

	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
		
		setIntent(intent);
        api.handleIntent(intent, this);
	}

	@Override
	public void onReq(BaseReq req) {
		switch (req.getType()) {
		case ConstantsAPI.COMMAND_GETMESSAGE_FROM_WX:
			break;
		case ConstantsAPI.COMMAND_SHOWMESSAGE_FROM_WX:
			break;
		default:
			break;
		}
	}

	@Override
	public void onResp(BaseResp resp) {
		Log.e("weixinonResp",resp.errCode+"+"+resp.getType());
		int result = R.string.errcode_unknown;
		//errorCode = -6 :签名不对
		switch (resp.errCode) {
		case BaseResp.ErrCode.ERR_OK:
			if (ConstantsAPI.COMMAND_SENDMESSAGE_TO_WX == resp.getType()) {
				result = R.string.share_success;
				ShareManager.shareSuccess();
			}else if(ConstantsAPI.COMMAND_SENDAUTH == resp.getType()) {
				result = R.string.login_success;
				String code = ((SendAuth.Resp) resp).code; //即为所需的code
				String uri = Constants.url.replace("CODE", code);
				Log.e("COMMAND_SENDAUTH",uri);
				WXHttpGet httpGet  = new WXHttpGet(uri);
				httpGet.Execute();			
			}
			break;
		case BaseResp.ErrCode.ERR_USER_CANCEL:
			if (ConstantsAPI.COMMAND_SENDMESSAGE_TO_WX == resp.getType()) {
				result = R.string.share_cancel;
				ShareManager.shareFail();
			}else if(ConstantsAPI.COMMAND_SENDAUTH == resp.getType()) {
				result = R.string.login_cancel;
			}
			break;
		case BaseResp.ErrCode.ERR_AUTH_DENIED:
			if (ConstantsAPI.COMMAND_SENDMESSAGE_TO_WX == resp.getType()) {
				result = R.string.share_deny;
				ShareManager.shareFail();
			}else if(ConstantsAPI.COMMAND_SENDAUTH == resp.getType()) {
				result = R.string.login_deny;
				
			}
			break;
		default:
			if (ConstantsAPI.COMMAND_SENDMESSAGE_TO_WX == resp.getType()) {
				result = R.string.share_unknown;
				ShareManager.shareFail();
			}else if(ConstantsAPI.COMMAND_SENDAUTH == resp.getType()) {
				result = R.string.login_unknown;
			}
			
			break;
		}
		
		Toast.makeText(this, result, Toast.LENGTH_LONG).show();
		finish();
	}
}