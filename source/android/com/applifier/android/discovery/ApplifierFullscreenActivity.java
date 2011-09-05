package com.applifier.android.discovery;

import android.app.Activity;
import android.util.Log;
import android.view.KeyEvent;
import android.view.ViewGroup;
import android.widget.FrameLayout;

public class ApplifierFullscreenActivity extends Activity {
	
	@Override
	public void onWindowFocusChanged (boolean hasFocus) 
	{
		super.onWindowFocusChanged(hasFocus);
		if (hasFocus) {
			Log.d("Applifier", "FullscreenView got focus! Reporting it via javascript.");
			ApplifierView.instance.reportFrameTransitionDone("fullscreen");
		}
	}
	
    /**
     * Handles the startup and creating of this activity. The <strong>AdView</strong>
     * that was touched is transported from the view where it was touched into this
     * Activity.
     */
	@Override
	protected void onResume() {
		FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.FILL_PARENT, ViewGroup.LayoutParams.FILL_PARENT);
		params.topMargin = 0;
		params.leftMargin = 0;

	   	ApplifierView.instance.setLayoutParams(params);
    	setContentView(ApplifierView.instance);
		super.onResume();
	}

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event)  {
        if (Integer.parseInt(android.os.Build.VERSION.SDK) < 5 && keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0) 
    		ApplifierView.instance.loadUrl("javascript:applifier.hardwareKeyPressed('back');");
        else if (keyCode == KeyEvent.KEYCODE_MENU && event.getRepeatCount() == 0)
        	ApplifierView.instance.loadUrl("javascript:applifier.hardwareKeyPressed('menu');");

        return super.onKeyDown(keyCode, event);
    }
    
    
}