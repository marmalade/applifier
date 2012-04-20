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
import com.applifier.android.discovery.IApplifierViewListener;
import com.applifier.android.discovery.ApplifierViewMode.ApplifierViewType;
import com.applifier.android.discovery.ApplifierViewMode.ApplifierCornerPosition;
import com.ideaworks3d.marmalade.LoaderActivity;

class ApplifierCrossPromotion implements IApplifierViewListener
{
    private ApplifierView applifier = null;    
    private String applifierID = null;
    private ApplifierCrossPromotion instance = null;

    public int init(String applifierID, boolean orientationHomeButtonDown, boolean orientationHomeButtonRight, boolean orientationHomeButtonLeft, boolean orientationHomeButtonUp) 
    {
    	this.applifierID = applifierID;
    	this.instance = this;
        LoaderActivity.m_Activity.runOnUiThread(initApplifierRunnable);
		return 0;
    }
    
    private final Runnable initApplifierRunnable = new Runnable() 
    {
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

        applifier.showBanner(lparams);
        return true;
    }

    public boolean moveBanner(int x, int y) 
    {
    	if (applifier == null) return false;
    	final FrameLayout.LayoutParams lparams = new FrameLayout.LayoutParams(RelativeLayout.LayoutParams.FILL_PARENT, RelativeLayout.LayoutParams.FILL_PARENT);
        lparams.leftMargin=x;
        lparams.topMargin=y;
        lparams.gravity = Gravity.NO_GRAVITY;

        LoaderActivity.m_Activity.runOnUiThread(new Runnable() {
        	@Override
        	public void run() {
        		applifier.setLayoutParams(lparams);
        	}
        });
    	return true;
    }

    public boolean pauseRenderer()
    {
    	if (applifier == null) return false;
    	return applifier.isShowingFullscreenView();
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

    public boolean prepareCustomInterstitial()
    {
    	if (applifier == null) return false;
    	applifier.prepareCustomInterstitial();
        return true;
    }

    public boolean prepareAnimated (int corner)
    {
    	if (applifier == null) return false;
    	applifier.prepareAnimated(getCornerPositionFromInt(corner));
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

    public boolean showCustomInterstitial()
    {
    	if (applifier == null) return false;
    	return applifier.showCustomInterstitial();
    }
   
    public boolean showAnimated (int corner)
    {
    	if (applifier == null) return false;
    	return applifier.showAnimated(getCornerPositionFromInt(corner));
    }

    public boolean isInterstitialReady() 
    {
        return applifier.isViewReady(ApplifierViewType.Interstitial);
    }

   public boolean isFeaturedGamesReady() 
   {
   	return applifier.isViewReady(ApplifierViewType.FeaturedGames);
   }

   public boolean isAnimatedReady() 
   {
   	return applifier.isViewReady(ApplifierViewType.Animated);
   }

   public boolean isCustomInterstitialReady() 
   {
    	return applifier.isViewReady(ApplifierViewType.CustomInterstitial);
   }
   	
   public boolean isFullscreenViewActive() 
   {
   	return applifier.isShowingFullscreenView();
   }

   public void onAnimatedReady() 
   {
   }

   public void onBannerReady() 
   {
   }
    
   public void onCustomInterstitialReady() 
   {
   }

   public void onInterstitialReady() 
   {
   }
   
   public void onFeaturedGamesReady() 
   {
   }

   private ApplifierCornerPosition getCornerPositionFromInt (int corner) {
	ApplifierCornerPosition enumCorner = ApplifierCornerPosition.BottomLeft;   	

	switch (corner) {
		case 0:
			enumCorner = ApplifierCornerPosition.TopLeft;
		break;
		case 1:
			enumCorner = ApplifierCornerPosition.TopRight;
		break;
		case 2:
			enumCorner = ApplifierCornerPosition.BottomRight;
		break;
		case 3:
			enumCorner = ApplifierCornerPosition.BottomLeft;
		break;
	}

	return enumCorner;
   }
}
