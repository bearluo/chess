package com.boyaa.made;



import android.app.Dialog;
import android.content.Context;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.text.InputFilter;
import android.text.InputType;
import android.text.Selection;
import android.util.TypedValue;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.TextView.OnEditorActionListener;

import com.boyaa.chinesechess.platform91.R;


public class AppEditBoxDialog extends Dialog {
	// ===========================================================
	// Constants
	// ===========================================================

	/**
	 * The user is allowed to enter any text, including line breaks.
	 */
	public final static int kEditBoxInputModeAny = 0;

	/**
	 * The user is allowed to enter an e-mail address.
	 */
	public final static int kEditBoxInputModeEmailAddr = 1;

	/**
	 * The user is allowed to enter an integer value.
	 */
	public final static int kEditBoxInputModeNumeric = 2;

	/**
	 * The user is allowed to enter a phone number.
	 */
	public final static int kEditBoxInputModePhoneNumber = 3;

	/**
	 * The user is allowed to enter a URL.
	 */
	public final static int kEditBoxInputModeUrl = 4;

	/**
	 * The user is allowed to enter a real number value. This extends
	 * kEditBoxInputModeNumeric by allowing a decimal point.
	 */
	public final static int kEditBoxInputModeDecimal = 5;

	/**
	 * The user is allowed to enter any text, except for line breaks.
	 */
	public final static int kEditBoxInputModeSingleLine = 6;

	/**
	 * Indicates that the text entered is confidential data that should be
	 * obscured whenever possible. This implies EDIT_BOX_INPUT_FLAG_SENSITIVE.
	 */
	public final static int kEditBoxInputFlagPassword = 0;

	/**
	 * Indicates that the text entered is sensitive data that the implementation
	 * must never store into a dictionary or table for use in predictive,
	 * auto-completing, or other accelerated input schemes. A credit card number
	 * is an example of sensitive data.
	 */
	public final static int kEditBoxInputFlagSensitive = 1;

	/**
	 * This flag is a hint to the implementation that during text editing, the
	 * initial letter of each word should be capitalized.
	 */
	public final static int kEditBoxInputFlagInitialCapsWord = 2;

	/**
	 * This flag is a hint to the implementation that during text editing, the
	 * initial letter of each sentence should be capitalized.
	 */
	public final static int kEditBoxInputFlagInitialCapsSentence = 3;

	/**
	 * Capitalize all characters automatically.
	 */
	public final static int kEditBoxInputFlagInitialCapsAllCharacters = 4;

	public final static int kKeyboardReturnTypeDefault = 0;
	public final static int kKeyboardReturnTypeDone = 1;
	public final static int kKeyboardReturnTypeSend = 2;
	public final static int kKeyboardReturnTypeSearch = 3;
	public final static int kKeyboardReturnTypeGo = 4;

	// ===========================================================
	// Fields
	// ===========================================================

	private EditText mInputEditText;
	private TextView mTextViewTitle;
	private Button mOkButton;

	private final String mTitle;
	private final String mMessage;
	private final int mInputMode;
	private final int mInputFlag;
	private final int mReturnType;
	private final int mMaxLength;

	private int mInputFlagConstraints;
	private int mInputModeContraints;
	private boolean mIsMultiline;

	// ===========================================================
	// Constructors
	// ===========================================================

	public AppEditBoxDialog(final Context pContext, final String pTitle, final String pMessage, final int pInputMode, final int pInputFlag, final int pReturnType, final int pMaxLength) {
		super(pContext, android.R.style.Theme_Translucent_NoTitleBar_Fullscreen);
		// super(context, R.style.Theme_Translucent);

		this.mTitle = pTitle;
		this.mMessage = pMessage;
		this.mInputMode = pInputMode;
		this.mInputFlag = pInputFlag;
		this.mReturnType = pReturnType;
		this.mMaxLength = pMaxLength;
	}

	@Override
	protected void onCreate(final Bundle pSavedInstanceState) {
		super.onCreate(pSavedInstanceState);

		this.getWindow().setBackgroundDrawable(new ColorDrawable(0x80000000));

		final LinearLayout layout = new LinearLayout(this.getContext());
		layout.setOrientation(LinearLayout.VERTICAL);
		layout.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				inputCancel();
			}
		});
		final LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.FILL_PARENT, ViewGroup.LayoutParams.FILL_PARENT);

		this.mTextViewTitle = new TextView(this.getContext());
		final LinearLayout.LayoutParams textviewParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
		textviewParams.leftMargin = textviewParams.rightMargin = this.convertDipsToPixels(10);
		this.mTextViewTitle.setTextSize(TypedValue.COMPLEX_UNIT_DIP, 20);
		layout.addView(this.mTextViewTitle, textviewParams);

		final LinearLayout layout_input=new LinearLayout(this.getContext());
		layout_input.setOrientation(LinearLayout.HORIZONTAL);
		final LinearLayout.LayoutParams layout_inputParams = new LinearLayout.LayoutParams(
				ViewGroup.LayoutParams.FILL_PARENT,
				ViewGroup.LayoutParams.WRAP_CONTENT);
		
		this.mInputEditText = new EditText(this.getContext());
		final LinearLayout.LayoutParams editTextParams = new LinearLayout.LayoutParams(
				ViewGroup.LayoutParams.FILL_PARENT,
				ViewGroup.LayoutParams.WRAP_CONTENT,1.0f);
		editTextParams.leftMargin = this
				.convertDipsToPixels(10);
		layout_input.addView(this.mInputEditText, editTextParams);

		this.mOkButton =new Button(this.getContext());
		int buttonText = R.string.btn_done;
		final LinearLayout.LayoutParams buttonParams = new LinearLayout.LayoutParams(
				ViewGroup.LayoutParams.WRAP_CONTENT,
				ViewGroup.LayoutParams.WRAP_CONTENT);
		buttonParams.rightMargin = this
				.convertDipsToPixels(10);
		layout_input.addView(this.mOkButton, buttonParams);
		
		layout.addView(layout_input,layout_inputParams);

		this.setContentView(layout, layoutParams);

		this.getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);

		this.mTextViewTitle.setText(this.mTitle);
		this.mInputEditText.setText(this.mMessage);
		
		int oldImeOptions = this.mInputEditText.getImeOptions();
		this.mInputEditText.setImeOptions(oldImeOptions | EditorInfo.IME_FLAG_NO_EXTRACT_UI);
		oldImeOptions = this.mInputEditText.getImeOptions();

		switch (this.mInputMode) {
		case kEditBoxInputModeAny:
			this.mInputModeContraints = InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_FLAG_MULTI_LINE;
			break;
		case kEditBoxInputModeEmailAddr:
			this.mInputModeContraints = InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS;
			break;
		case kEditBoxInputModeNumeric:
			this.mInputModeContraints = InputType.TYPE_CLASS_NUMBER | InputType.TYPE_NUMBER_FLAG_SIGNED;
			break;
		case kEditBoxInputModePhoneNumber:
			this.mInputModeContraints = InputType.TYPE_CLASS_PHONE;
			break;
		case kEditBoxInputModeUrl:
			this.mInputModeContraints = InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_URI;
			break;
		case kEditBoxInputModeDecimal:
			this.mInputModeContraints = InputType.TYPE_CLASS_NUMBER | InputType.TYPE_NUMBER_FLAG_DECIMAL | InputType.TYPE_NUMBER_FLAG_SIGNED;
			break;
		case kEditBoxInputModeSingleLine:
			this.mInputModeContraints = InputType.TYPE_CLASS_TEXT;
			break;
		default:

			break;
		}

		if (this.mIsMultiline) {
			this.mInputModeContraints |= InputType.TYPE_TEXT_FLAG_MULTI_LINE;
		}

		this.mInputEditText.setInputType(this.mInputModeContraints | this.mInputFlagConstraints);

		switch (this.mInputFlag) {
		case kEditBoxInputFlagPassword:
			this.mInputFlagConstraints = InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD;
			break;
		case kEditBoxInputFlagSensitive:
			this.mInputFlagConstraints = InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS;
			break;
		case kEditBoxInputFlagInitialCapsWord:
			this.mInputFlagConstraints = InputType.TYPE_TEXT_FLAG_CAP_WORDS;
			break;
		case kEditBoxInputFlagInitialCapsSentence:
			this.mInputFlagConstraints = InputType.TYPE_TEXT_FLAG_CAP_SENTENCES;
			break;
		case kEditBoxInputFlagInitialCapsAllCharacters:
			this.mInputFlagConstraints = InputType.TYPE_TEXT_FLAG_CAP_CHARACTERS;
			break;
		default:
			break;
		}

		this.mInputEditText.setInputType(this.mInputFlagConstraints | this.mInputModeContraints);

		switch (this.mReturnType) {
		case kKeyboardReturnTypeDefault:
			this.mInputEditText.setImeOptions(oldImeOptions | EditorInfo.IME_ACTION_NONE);
			buttonText = R.string.btn_done;
			break;
		case kKeyboardReturnTypeDone:
			this.mInputEditText.setImeOptions(oldImeOptions | EditorInfo.IME_ACTION_DONE);
			buttonText = R.string.btn_done;
			break;
		case kKeyboardReturnTypeSend:
			this.mInputEditText.setImeOptions(oldImeOptions | EditorInfo.IME_ACTION_SEND);
			buttonText = R.string.btn_send;
			break;
		case kKeyboardReturnTypeSearch:
			this.mInputEditText.setImeOptions(oldImeOptions | EditorInfo.IME_ACTION_SEARCH);
			buttonText = R.string.btn_search;
			break;
		case kKeyboardReturnTypeGo:
			this.mInputEditText.setImeOptions(oldImeOptions | EditorInfo.IME_ACTION_GO);
			buttonText = R.string.btn_go;
			break;
		default:
			this.mInputEditText.setImeOptions(oldImeOptions | EditorInfo.IME_ACTION_NONE);
			this.mOkButton.setVisibility(View.GONE);
			break;
		}
		this.mOkButton.setText(this.getContext().getResources().getString(buttonText));
		if (this.mMaxLength > 0) {
			this.mInputEditText.setFilters(new InputFilter[] { new InputFilter.LengthFilter(this.mMaxLength) });
		}

		final Handler initHandler = new Handler();
		initHandler.postDelayed(new Runnable() {
			@Override
			public void run() {
				AppEditBoxDialog.this.mInputEditText.requestFocus();
				AppEditBoxDialog.this.mInputEditText.setSelection(AppEditBoxDialog.this.mInputEditText.length());
				AppEditBoxDialog.this.openKeyboard();
				Selection.selectAll(AppEditBoxDialog.this.mInputEditText.getText());
			}
		}, 200);

		this.mInputEditText.setOnEditorActionListener(new OnEditorActionListener() {
			@Override
			public boolean onEditorAction(final TextView v, final int actionId, final KeyEvent event) {
				/*
				 * If user didn't set keyboard type, this callback will be
				 * invoked twice with 'KeyEvent.ACTION_DOWN' and
				 * 'KeyEvent.ACTION_UP'.
				 */
						if (actionId != EditorInfo.IME_NULL
								|| (actionId == EditorInfo.IME_NULL
										&& event != null && event.getAction() == KeyEvent.ACTION_DOWN)) {
							inputDone();
							return true;
						}
						return false;
						}
					});
		this.mInputEditText.setOnKeyListener(new View.OnKeyListener() {
			
			@Override
			public boolean onKey(View v, int keyCode, KeyEvent event) {
				if(keyCode==KeyEvent.KEYCODE_BACK){
					inputCancel();
					return true;
				}
				return false;
			}
		});
		this.mOkButton.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				inputDone();
			}
		});
	}

	private void inputDone(){
		AppEditBoxDialog.this.closeKeyboard();
		AppEditBoxDialog.this.dismiss();
		AppActivity.mActivity.runOnLuaThread(new Runnable(){

			@Override
			public void run() {
				byte[] textArray = AppEditBoxDialog.this.mInputEditText.getText().toString().getBytes(); 
				AppActivity.nativeCloseIme(textArray,1);
			}
		});
	}
	
	private void inputCancel(){
		AppEditBoxDialog.this.closeKeyboard();
		AppEditBoxDialog.this.dismiss();
		AppActivity.mActivity.runOnLuaThread(new Runnable(){

			@Override
			public void run() {
				byte[] textArray = AppEditBoxDialog.this.mInputEditText.getText().toString().getBytes(); 
				AppActivity.nativeCloseIme(textArray,0);
			}
		});
	}

	private int convertDipsToPixels(final float pDIPs) {
		final float scale = this.getContext().getResources().getDisplayMetrics().density;
		return Math.round(pDIPs * scale);
	}

	private void openKeyboard() {
		final InputMethodManager imm = (InputMethodManager) this.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
		imm.showSoftInput(this.mInputEditText, 0);
	}

	private void closeKeyboard() {
		final InputMethodManager imm = (InputMethodManager) this.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
		imm.hideSoftInputFromWindow(this.mInputEditText.getWindowToken(), 0);
	}

	public void close()
	{
		this.closeKeyboard();
		this.dismiss();
	}
	// ===========================================================
	// Inner and Anonymous Classes
	// ===========================================================
}
