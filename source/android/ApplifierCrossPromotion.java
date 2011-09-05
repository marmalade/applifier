/*
java implementation of the ApplifierCrossPromotion extension.

Add android-specific functionality here.

These functions are called via JNI from native code.
*/
/*
 * NOTE: This file was originally written by the extension builder, but will not
 * be overwritten (unless --force is specified) and is intended to be modified.
 */
import android.view.Gravity;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;

import com.applifier.android.discovery.ApplifierView;
import com.applifier.android.discovery.ApplifierViewListener;
import com.ideaworks3d.marmalade.LoaderActivity;

class ApplifierCrossPromotion implements ApplifierViewListener
{
    private ApplifierView applifier = null;
    
    private boolean interstitialReady = false;
    private boolean featuredGamesReady = false;
    private boolean fullscreenViewActive = false;
    
    private String applifierID;
    private ApplifierCrossPromotion instance = null;

   public int init(String applifierID, boolean orientationHomeButtonDown, boolean orientationHomeButtonRight, boolean orientationHomeButtonLeft, boolean orientationHomeButtonUp) {
    	this.applifierID = applifierID;
    	this.instance = this;
        LoaderActivity.m_Activity.runOnUiThread(initApplifierRunnable);
		return 0;
    }
    
	private final Runnable initApplifierRunnable = new Runnable() {
        public void run() {
	        applifier = new ApplifierView(LoaderActivity.m_Activity, applifierID);
	        applifier.setApplifierListener(instance);
	    }
    };
    
    public boolean showBanner(int positionX, int positionY)
    {
    	if (applifier == null) return false;
    	FrameLayout.LayoutParams lparams = new FrameLayout.LayoutParams(RelativeLayout.LayoutParams.FILL_PARENT, RelativeLayout.LayoutParams.FILL_PARENT);
        lparams.leftMargin=positionX;
        lparams.topMargin=positionY;
        lparams.gravity = Gravity.NO_GRAVITY;

        //lparams.gravity = Gravity.CENTER_HORIZONTAL;
     
        applifier.showBanner(lparams);
        return true;
    }
    
    public boolean hideBanner() 
    {
    	if (applifier == null) return false;
    	applifier.hide();
    	return true;	
    }
    
    public boolean prepareFeaturedGames()
    {
    	if (applifier == null) return false;
    	applifier.prepareFeaturedGames();
        return true;
    }
    public boolean prepareInterstitial()
    {
    	if (applifier == null) return false;
    	applifier.prepareInterstitial();
        return true;
    }
    public boolean showFeaturedGames()
    {
    	if (applifier == null) return false;
    	return applifier.showFeaturedGames();
    }
    public boolean showInterstitial()
    {
    	if (applifier == null) return false;
    	return applifier.showInterstitial();
    }
    public boolean pauseRenderer()
    {
    	if (applifier == null) return false;
    	return applifier.isShowingFullscreenView();
    }
   
   	public boolean isInterstitialReady() {
   		return interstitialReady;
   	}

   	public boolean isFeaturedGamesReady() {
   		return featuredGamesReady;
   	}
   	
   	public boolean isFullscreenViewActive() {
   		return fullscreenViewActive;
   	}
    
	public void onInterstialReady() {
		interstitialReady = true;		
	}

	public void onFeaturedGamesReady() {
		featuredGamesReady = true;
	}

	public void onEnterApplifierFullScreenView() {
		fullscreenViewActive = true;		
	}

	public void onExitApplifierFullScreenView() {
		fullscreenViewActive = false;
	}
}
