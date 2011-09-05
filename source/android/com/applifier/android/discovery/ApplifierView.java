package com.applifier.android.discovery;

import java.io.UnsupportedEncodingException;
import java.lang.reflect.Method;
import java.net.URLDecoder;
import java.util.ArrayList;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.graphics.Color;
import android.net.Uri;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.provider.Settings.Secure;
import android.telephony.TelephonyManager;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.AnimationSet;
import android.view.animation.ScaleAnimation;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebStorage;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;

public class ApplifierView extends WebView 
{	
	public static ApplifierView instance = null;	

	private static String FRAME_NONE = "none";
	private static String FRAME_FULLSCREEN = "fullscreen";
	private static String FRAME_BANNER = "banner";	
	private static String VIEW_NONE = "none";
	private static String VIEW_INTERSTITIAL = "interstitial";
	private static String VIEW_BANNER = "banner";
	private static String VIEW_FEATUREDGAMES = "featuredgames";	
	private static String APPLIFIER_URLPREFIX = "applifier://";
	private static String APPLIFIER_CHANGEFRAME = "changeFrame";
	private static String APPLIFIER_LOADCOMPLETE = "loadComplete";
	private static String APPLIFIER_SCALINGFACTOR = "scalingFactor";
	private static String YOUTUBE_URLPREFIX = "http://www.youtube";
	private static String GENERIC_URLPREFIX = "http://";
	private static String URL = "http://cdn.applifier.com/mobile.html";
	
	private enum ApplifierViewState { NoView, BannerVisible, FullscreenVisible };
	private enum ApplifierWebState { NotLoaded, Loaded, Inited };
	
	private ApplifierViewState applifierViewState;
	private ApplifierWebState applifierWebState;
	
	public static boolean _useJavascriptLogging = false;
	private int _minViewHeight = 50;
	private int _minViewWidth = 310;
	private int _possibleHeightNegations = -1;
	private int _possibleWidthNegations = -1;
	private String _applicationId = "";
	private String _lastRequestedView = VIEW_NONE;
	private String _logMessages = "Welcome to ApplifierLog v0.001b\n\n";
	private String _lastRequestedFrame = FRAME_NONE;
	private static String _logName = "Applifier";
	private String _appCachePath = null;
	private ApplifierViewListener _applifierViewListener = null;
	private ArrayList<String> _javascriptCommandLog = null;
	private double _javaScriptScalingFactor = 1;
	private Activity activity;
	private ViewGroup.LayoutParams bannerLayoutParams;
	private boolean cancelBannerPopup;
	private boolean interstitialReady;
	private boolean featuredGamesReady;

//	private int framesCount;
//	private int framesCountAvg;
//	private long framesTimer;

	private ArrayList<View> savedNeighbours;

	private boolean fullscreenActivityEnabled = false;
	
	public ApplifierView(Activity activity, String applifierId) 
	{
		super(activity);
		instance = this;
		
		Log.d(_logName, "ApplifierView constructor. Activity : " + activity);
		
		this.activity = activity;
		_applicationId = applifierId;
		startup();
		
		
		//fpsPaint.setColor(Color.BLACK);
		//fpsPaint.setTypeface(Typeface.DEFAULT_BOLD);
		//fpsPaint.setTextSize(50);
	}

	/*
	Paint fpsPaint = new Paint();
	@Override
	protected void onDraw(Canvas canvas) {
		super.onDraw(canvas);
        long now = System.currentTimeMillis();
        canvas.drawText("FPS: " + framesCountAvg, 20, getScrollY() + 50 , fpsPaint);
        framesCount++; 
        if(now-framesTimer>1000){ 
                framesTimer=now; 
                framesCountAvg=framesCount; 
                framesCount=0; 
        } 
	} 
	*/
	
	public static void setUrl (String url)
	{
		URL = url;
	}
	
	public void setApplifierListener (ApplifierViewListener listener)
	{
		_applifierViewListener = listener;
	}
	
	public void hide ()
	{
		setLastRequestedView(VIEW_NONE);
		requestViewChange(getLastRequestedView());
	}
		
	public void prepareInterstitial () 
	{
		requestViewPreparation(VIEW_INTERSTITIAL);
	}
	
	public void prepareFeaturedGames ()
	{
		requestViewPreparation(VIEW_FEATUREDGAMES);
	}

	public void prepareBanner()
	{
		cancelBannerPopup = true;
		requestViewPreparation(VIEW_BANNER);
	}
	
	public void showBanner(ViewGroup.LayoutParams params)
	{
		cancelBannerPopup = false;
		bannerLayoutParams = params;
		requestViewPreparation(VIEW_BANNER);
	}
	
	public boolean showInterstitial ()
	{
		if (!interstitialReady || applifierWebState == ApplifierWebState.NotLoaded) return false;
		setLastRequestedView(VIEW_INTERSTITIAL);
		requestViewChange(getLastRequestedView());
		return true;
	}
	
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK && applifierViewState == ApplifierViewState.FullscreenVisible) {
			hide();
			return true;
		}
		return super.onKeyDown(keyCode, event);
	}
	
	public boolean showFeaturedGames ()
	{
		if (!featuredGamesReady || applifierWebState == ApplifierWebState.NotLoaded) return false;
		setLastRequestedView(VIEW_FEATUREDGAMES);
		requestViewChange(getLastRequestedView());
		return true;
	}
	
	public boolean isShowingFullscreenView() {
		return applifierViewState == ApplifierViewState.FullscreenVisible;
	}
	
	/* VIEW METHODS */
	
	public void loadUrl (String url)
	{
		Log.d(_logName, "Loading url: " + url);		
		super.loadUrl(url);
	}
	
	public String getLogMessages ()
	{
		return _logMessages;
	}


	protected void reportFrameTransitionDone (String frameType)
	{
		loadUrl("javascript:applifier.frameTransitionComplete('" + frameType + "');");
	}
	
	protected String getLastRequestedView ()
	{
		return _lastRequestedView;
	}
	
	protected void setLastRequestedView (String view)
	{
		_lastRequestedView = view;
	}
	
	protected String getLastRequestedFrame ()
	{
		return _lastRequestedFrame;
	}
		
	protected void setLastRequestedFrame (String frame)
	{
		_lastRequestedFrame = frame;
	}
	
	
	
	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec)
	{
		super.onMeasure(widthMeasureSpec, heightMeasureSpec);		
		Resources rs = getRootView().getContext().getResources();		
		
		if (rs != null)
		{
			View rootView = getRootView().findViewById(Window.ID_ANDROID_CONTENT);
			
			if (rootView != null)
			{
				if (applifierViewState == ApplifierViewState.BannerVisible) {
					//Log.d(_logName, "Setting dimensions to banner size");
					setBannerMeasures();
				}
				if (applifierViewState == ApplifierViewState.FullscreenVisible)
				{
					//Log.d(_logName, "Setting dimensions to fullscreen size");

					int rootViewWidth = 0;
					int rootViewHeight = 0;
					
					if (rs.getDisplayMetrics().heightPixels > rs.getDisplayMetrics().widthPixels && rootView.getHeight() > 0 && rootView.getWidth() > 0)
					{
						rootViewHeight = Math.max(rootView.getHeight(), rootView.getWidth());
						rootViewWidth = Math.min(rootView.getHeight(), rootView.getWidth());
					}
					else if (rs.getDisplayMetrics().heightPixels < rs.getDisplayMetrics().widthPixels && rootView.getHeight() > 0 && rootView.getWidth() > 0) 
					{
						rootViewHeight = Math.min(rootView.getHeight(), rootView.getWidth());
						rootViewWidth = Math.max(rootView.getHeight(), rootView.getWidth());
					}

					if (rootView.getHeight() > 0 && _possibleHeightNegations == -1) 
						_possibleHeightNegations = rs.getDisplayMetrics().heightPixels - rootViewHeight;
					
					if (rootView.getWidth() > 0 && _possibleWidthNegations == -1)
						_possibleWidthNegations = rs.getDisplayMetrics().widthPixels - rootViewWidth;
					
					
					setMeasuredDimension(rs.getDisplayMetrics().widthPixels - _possibleWidthNegations, rs.getDisplayMetrics().heightPixels - _possibleHeightNegations);
					//Log.d(_logName, "Setting dimensions to  " + (rs.getDisplayMetrics().widthPixels - _possibleWidthNegations) + " x " +  (rs.getDisplayMetrics().heightPixels - _possibleHeightNegations));
				}
				if (applifierViewState == ApplifierViewState.NoView) {
					//Log.d(_logName, "Setting dimensions to zero.  ");
					setMeasuredDimension(0,0);
				}
			}
		}
	}
	
	private void pushToJavascriptCommandLog (String cmd)
	{
		if (_javascriptCommandLog == null)
			_javascriptCommandLog = new ArrayList<String>();
		
		_javascriptCommandLog.add(cmd);
	}
	
	private void processJavascriptCommandLog ()
	{
		if (_javascriptCommandLog != null) {
			for (String cmd : _javascriptCommandLog) 
				loadUrl("javascript:" + cmd);
		
			_javascriptCommandLog.clear();
		}
	}
	
	private void requestViewPreparation (String view)
	{
		String cmd = "applifier.prepareView('" + view + "');";
		
		if (applifierWebState == ApplifierWebState.Inited)
			loadUrl("javascript:" + cmd);
		else
			pushToJavascriptCommandLog(cmd);
	}
		
		
	private void requestViewChange (String view)
	{
		if (applifierWebState == ApplifierWebState.Inited) {
			loadUrl("javascript:applifier.requestView('" + view + "');");
		}
	}
		
	private void startup () 
	{
		getSettings().setJavaScriptEnabled(true);
		
		if (URL != null && URL.endsWith("mobile_raw.html"))
		{
			getSettings().setCacheMode(WebSettings.LOAD_NO_CACHE);
			Log.d(_logName, "startup() -> LOAD_NO_CACHE");
		}
		else
		{
			getSettings().setCacheMode(WebSettings.LOAD_NORMAL);
			//Log.d(_logName, "startup() -> LOAD_NORMAL");
		}
		
		_appCachePath = getContext().getCacheDir().toString();
		//Log.d(_logName, "Cache path : " + _appCachePath);
		
		getSettings().setSupportZoom(false);
		getSettings().setBuiltInZoomControls(false);
		getSettings().setLightTouchEnabled(false);
		getSettings().setRenderPriority(WebSettings.RenderPriority.HIGH);
		getSettings().setSupportMultipleWindows(false);
		
		setHorizontalScrollBarEnabled(false);
		setVerticalScrollBarEnabled(false);		

		setClickable(true);
		setFocusable(true);
		setFocusableInTouchMode(true);
		setInitialScale(0);
		
		setBackgroundColor(Color.TRANSPARENT);
		setBackgroundDrawable(null);
		setBackgroundResource(0);		

		applifierViewState = ApplifierViewState.NoView;
		applifierWebState = ApplifierWebState.NotLoaded;
		setWebViewClient(new ApplifierViewClient());
		setWebChromeClient(new ApplifierViewChromeClient());
		
	
		if (_appCachePath != null)
		{
			getSettings().setAppCacheEnabled(true);			
			getSettings().setDomStorageEnabled(true);
			getSettings().setAppCacheMaxSize(1024*1024*10);
			getSettings().setAppCachePath(_appCachePath);
			getSettings().setAllowFileAccess(true);
			//Log.d(_logName, "Cache path: " + _appCachePath);
		}
		
		if (URL != null)
			loadUrl(URL);
	}
	
	
	private void finishFullscreenActivity() {
		Log.d(_logName, "Finishind fullscreen activity");
		View view = (View)getRootView();

		if (view != null) {
			Activity act = (Activity)getRootView().getContext();

			if (act != null && act instanceof ApplifierFullscreenActivity) {
		    	ViewGroup vg = (ViewGroup)ApplifierView.instance.getParent();
		    	if (vg != null)
		    		vg.removeAllViews();
		    	else
		    		Log.d(_logName, "Cannot remove ApplifierView from parent!");
				
				act.finish();
				act.overridePendingTransition(0, 0);
			}
		}
	}

	private void showViewList() {
		ViewGroup vg = (ViewGroup)activity.getWindow().getDecorView();
		Log.e(_logName, "-- view hierarchy debugging -- ");
		logContentView(vg, ">");
		Log.e(_logName, "------------------------------ ");
	}
	
	private void logContentView(View parent, String indent) {
	    Log.i(_logName, indent + parent.getClass().getName());
	    if (parent instanceof ViewGroup) {
	        ViewGroup group = (ViewGroup)parent;
	        for (int i = 0; i < group.getChildCount(); i++)
	            logContentView(group.getChildAt(i), indent + ">");
	    }
	}

	
	private void startFullScreen ()
	{
		if (applifierViewState != ApplifierViewState.FullscreenVisible) {
			applifierViewState = ApplifierViewState.FullscreenVisible;

			if (fullscreenActivityEnabled) {
				
				if (this.getParent() != null) 
					((ViewGroup)this.getParent()).removeView(this);
				
				Intent newIntent = new Intent(getRootView().getContext(), com.applifier.android.discovery.ApplifierFullscreenActivity.class);
				newIntent.addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION | Intent.FLAG_ACTIVITY_NEW_TASK);
				activity.startActivity(newIntent);
			}
			else {

				removeNeighbourViewsFromParent((ViewGroup)this.getParent());
				prepareApplifierView(true);

				Unity3DHelper u3dListener = getUnity3DListener();
				if (u3dListener != null) {
					u3dListener.pauseGame();
				}
				
				this.requestFocus();
				this.setFocusableInTouchMode(true);
				
	    		requestLayout();
				reportFrameTransitionDone(getLastRequestedFrame());
			}
			
		}
	}
	
	private void restoreNeighbourViewsToParent(ViewGroup parent) {
		if (savedNeighbours == null) {
			Log.e(_logName, "Trying to restore view without saved views to restore!");
			return;
		}
		for (View neighbour : savedNeighbours) {
			parent.addView(neighbour);
		}
		savedNeighbours = null;
		
		parent.bringChildToFront(this);

	}
	
	private void removeNeighbourViewsFromParent(ViewGroup parent) {
		if (parent == null) return; //parent can be null in some cases
		
		savedNeighbours = new ArrayList<View>();
		for (int i = 0; i < parent.getChildCount(); i++) {
			View neighbour = parent.getChildAt(i);
			if (neighbour != this) {
				//Log.d(_logName, "Removing neighbour view : " + neighbour);
				savedNeighbours.add(neighbour);
				parent.removeViewAt(i); 
			}
		}
		
	}

	private void startAppearAnimation () 
	{
		setBannerMeasures();
		
		if (getMeasuredWidth() > 0 && getMeasuredHeight() > 0) {
			Animation scaleAnim = new ScaleAnimation(0, 1, 0, 1, getMeasuredWidth() / 2, getMeasuredHeight() / 2);
			scaleAnim.setDuration(1000);
			scaleAnim.setFillEnabled(true);
			scaleAnim.setFillAfter(true);
			
			Animation alphaAnim = new AlphaAnimation(0, 1);
			alphaAnim.setDuration(1000);
			alphaAnim.setFillEnabled(true);
			alphaAnim.setFillAfter(true);
			
			AnimationSet animSet = new AnimationSet(false);
			animSet.addAnimation(scaleAnim);
			animSet.addAnimation(alphaAnim);
			
			startAnimation(animSet);
		}
		else {
			Log.d(_logName, "Animations not showing because dimensions are 0");
		}
	}	
	
	private void setBannerMeasures() {
		Resources rs = getRootView().getContext().getResources();		
		setMeasuredDimension((int)Math.round(_minViewWidth * rs.getDisplayMetrics().density * _javaScriptScalingFactor), (int)Math.round(_minViewHeight * rs.getDisplayMetrics().density * _javaScriptScalingFactor));
	}

	private JSONObject getJsonFromApplifierUrl (String url)
	{
		int index = url.length() - 1;
		String tmp = null;

		if (url != null)
		{
			index = url.indexOf("?");
			tmp = url.substring(index + 1);
		}
		
		String jsonString = null;
		JSONObject json = null;
		
		try
		{
			jsonString = URLDecoder.decode(tmp, "UTF-8");
		}
		catch (UnsupportedEncodingException e)
		{
			Log.e(_logName, "The programmer fails to write correctly.");
		}
		
		if (jsonString != null)
		{
			try
			{
				json = new JSONObject(jsonString);
			}
			catch (JSONException e)
			{
				Log.e(_logName, "JSON-ERROR: " + e.getMessage());
			}
		}
		
		return json;
	}
	
	private void loadApplifierUrl (String url)
	{
		Log.d(_logName, "Applifier command received : " + url);
		if (url != null && url.startsWith(APPLIFIER_URLPREFIX))
		{
			if (url.startsWith(APPLIFIER_URLPREFIX + APPLIFIER_CHANGEFRAME))
			{
				JSONObject json = getJsonFromApplifierUrl(url);
				String frameType = null;
				
				if (json != null)
				{
					try
					{
						frameType = json.getString("type");
					}
					catch (JSONException e)
					{
						Log.e(_logName, e.getMessage());
					}
				}
				
				if (FRAME_FULLSCREEN.equals(frameType))
				{
					setLastRequestedFrame(FRAME_FULLSCREEN);


					if (applifierViewState != ApplifierViewState.FullscreenVisible)
					{
						startFullScreen();
					}
					else { //already visible
						reportFrameTransitionDone(getLastRequestedFrame());					
					}
				}
				else if (FRAME_BANNER.equals(frameType)) {
					
					if (applifierViewState == ApplifierViewState.FullscreenVisible) {
						if (fullscreenActivityEnabled) {
							finishFullscreenActivity();
						}
						else {
 							restoreNeighbourViewsToParent((ViewGroup) this.getParent());
						}
					}
					prepareApplifierView(false);
					showViewList();
					
					setLastRequestedFrame(FRAME_BANNER);

					resumeUnity3D();
					
					setLayoutParams(bannerLayoutParams);
					applifierViewState = ApplifierViewState.BannerVisible;
					requestLayout();
					reportFrameTransitionDone(getLastRequestedFrame());

				}
				else if (FRAME_NONE.equals(frameType))
				{
					if (applifierViewState == ApplifierViewState.FullscreenVisible) {
						if (fullscreenActivityEnabled) {
							finishFullscreenActivity();
						}
						else {
 							restoreNeighbourViewsToParent((ViewGroup) this.getParent());
						}
					}
					
					setLastRequestedFrame(FRAME_NONE);

					resumeUnity3D();
					if (applifierViewState == ApplifierViewState.NoView)
						reportFrameTransitionDone(getLastRequestedFrame());
					else if (applifierViewState == ApplifierViewState.BannerVisible) {
						applifierViewState = ApplifierViewState.NoView;
						requestLayout();
						reportFrameTransitionDone(getLastRequestedFrame());
					}
					else if (applifierViewState == ApplifierViewState.FullscreenVisible) {
						applifierViewState = ApplifierViewState.NoView;
						requestLayout();
						reportFrameTransitionDone(getLastRequestedFrame());					
					}
					
					removeApplifierViewFromActivity();
				}
			}
			else if (url.startsWith(APPLIFIER_URLPREFIX + APPLIFIER_LOADCOMPLETE))
			{
				JSONObject json = getJsonFromApplifierUrl(url);

				String viewType = null;
				if (json != null)
				{
					try
					{
						viewType = json.getString("view");
					}
					catch (JSONException e)
					{
						Log.e(_logName, e.getMessage());
					}
				}
				
				if (VIEW_BANNER.equals(viewType))
				{
					Unity3DHelper u3dListener = getUnity3DListener();
					if (u3dListener != null) {
						u3dListener.onBannerReady();
					}
					
					if (cancelBannerPopup == false) {
						setLastRequestedView(VIEW_BANNER);
						requestViewChange(getLastRequestedView());
					
						applifierViewState = ApplifierViewState.BannerVisible;
						requestLayout();//calls onMeasure
					
						startAppearAnimation();
					}
				}
				else if (VIEW_INTERSTITIAL.equals(viewType))
				{
					interstitialReady = true;
					if (_applifierViewListener != null)
						_applifierViewListener.onInterstialReady();
				}
				else if (VIEW_FEATUREDGAMES.equals(viewType))
				{					
					featuredGamesReady = true;
					if (_applifierViewListener != null)
						_applifierViewListener.onFeaturedGamesReady();
				}
			}
			else if (url.startsWith(APPLIFIER_URLPREFIX + APPLIFIER_SCALINGFACTOR)) {
				JSONObject json = getJsonFromApplifierUrl(url);
				String tmpFactor = null;
				
				if (json != null) {
					try	{
						tmpFactor = json.getString("ratio");
					} 
					catch (JSONException e) {
						Log.e(_logName, e.getMessage());
					}
					
					if (tmpFactor != null) 	{
						_javaScriptScalingFactor = Double.parseDouble(tmpFactor);
						onMeasure(1, 1);
					}
				}
			}
			
			loadUrl("javascript:applifier.callNativeComplete();");
		}		
	}
	
	private void resumeUnity3D() {
		Unity3DHelper u3dListener = getUnity3DListener();
		if (u3dListener != null) {
			u3dListener.resumeGame();
		}
	}

	private Unity3DHelper getUnity3DListener() {
		Unity3DHelper u3dListener  = null;
		if (_applifierViewListener != null && _applifierViewListener instanceof Unity3DHelper) {
			u3dListener = (Unity3DHelper)_applifierViewListener;
		}
		return u3dListener;
	}

	private void prepareApplifierView(boolean fullscreen) {
		ViewGroup vg = (ViewGroup)this.getParent();
		boolean addedToView = vg != null;
		if (fullscreen) {
			FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.FILL_PARENT, ViewGroup.LayoutParams.FILL_PARENT);
			params.topMargin = 0;
			params.leftMargin = 0;
			if (addedToView)
				this.setLayoutParams(params);
			else
				activity.addContentView(this, params);
		}
		else {
			if (addedToView) {
				Log.d(_logName, "setting banner params to existing view");
				this.setLayoutParams(bannerLayoutParams);
			}
			else {
				Log.d(_logName, "Adding banner as content view to activity " + activity);
				activity.addContentView(this, bannerLayoutParams);
			}
		}
	}
	
	private void removeApplifierViewFromActivity() {
		ViewGroup vg = (ViewGroup)this.getParent();
		if (vg != null) {
			vg.removeView(this);
			applifierViewState = ApplifierViewState.NoView;
		}
	}
	
	public void changeActivity(Activity a) {
		if (activity == a) return;
		Log.d(_logName, "Change Activity to : " + a + " hiding and removing view");
		hide();
		removeApplifierViewFromActivity();
		activity = a;
	}

	private void loadYoutubeUrl (String url)
	{
		String logPrefix = "loadYoutubeUrl() -> Loading YouTube video: ";
		
		if (url.startsWith(YOUTUBE_URLPREFIX))
		{			
			Log.d(_logName, logPrefix + url);
			Intent youtubeIntent = new Intent (Intent.ACTION_VIEW, Uri.parse(url));
			getRootView().getContext().startActivity(youtubeIntent);
		}
	}
	
	private void loadGenericUrl (String url)
	{
		if (url != null && url.startsWith(GENERIC_URLPREFIX))
		{
			Log.w(_logName, "WARNING: Opening url (" + url + ") with generic action");
			Intent genericIntent = new Intent (Intent.ACTION_VIEW, Uri.parse(url));
			getRootView().getContext().startActivity(genericIntent);
		}
	}
	
	private void addLogMessage (String message, int lineNumber, String sourceID)
	{
		if (_useJavascriptLogging)
			_logMessages += message + "\nLine number: " + lineNumber + "\nSource id: " + sourceID + "\n\n";
	}

	
	/* SUBCLASSES */
	
	private class ApplifierViewChromeClient extends WebChromeClient
	{
		public void onConsoleMessage(String message, int lineNumber, String sourceID) 
		{
			addLogMessage(message, lineNumber, sourceID);
		}
		
		public void onReachedMaxAppCacheSize(long spaceNeeded, long totalUsedQuota, WebStorage.QuotaUpdater quotaUpdater)
		{
			quotaUpdater.updateQuota(spaceNeeded * 2);
		}
		
	}
	
	private class ApplifierViewClient extends WebViewClient
	{
		@Override
		public void onPageFinished (WebView webview, String url)
		{
			//String logPrefix = "ApplifierViewClient.onPageFinished() -> ";
			
		
			super.onPageFinished(webview, url);

			Log.d(_logName, "Finished url: "  + url);
			
			if (applifierWebState != ApplifierWebState.Inited && webview != null)
			{
				 
				String deviceForm = getResources().getConfiguration().screenLayout > Configuration.SCREENLAYOUT_SIZE_NORMAL ? "tablet" : "phone";
				
				String settings = "";
				settings += "{";
				settings +=	"\"apiVersion\":1, ";
				settings +=	"\"deviceId\":\"" + getDeviceId(getRootView().getContext()) + "\", ";
				settings +=	"\"appId\":\"" + _applicationId + "\", ";
				settings +=	"\"deviceType\":\"" + Build.MODEL + "\", ";
				settings += "\"manufacturer\":\"" + Build.MANUFACTURER + "\", ";
				settings += "\"deviceSdkVersion\":\"" + Build.VERSION.SDK_INT +  "\", ";				
				settings += "\"deviceForm\":\"" + deviceForm + "\", ";	
				settings += "\"platform\":\"android\"}";				
				
				//Log.d(_logName, logPrefix + "Applying settings: " + settings);
				webview.loadUrl("javascript:applifier.init(" + settings + ");");

				applifierWebState = ApplifierWebState.Inited;
				
				if (getLastRequestedView() != VIEW_NONE && getLastRequestedView() != VIEW_BANNER)
					requestViewChange(getLastRequestedView());
				
				processJavascriptCommandLog();
			}
		}
		
		@Override
		public boolean shouldOverrideUrlLoading (WebView view, String url)
		{
			boolean shouldOverride = false;
			
			if (view != null && url != null)
			{
				if (url.startsWith(APPLIFIER_URLPREFIX))
				{
					shouldOverride = true;
					loadApplifierUrl(url);
				}
				else if (url.startsWith(YOUTUBE_URLPREFIX))
				{
					shouldOverride = true;
					loadYoutubeUrl(url);
				}
				else if (url.startsWith(GENERIC_URLPREFIX))
				{
					shouldOverride = true;
					loadGenericUrl(url);
				}
			}
			
			return shouldOverride;
		}
		
		@Override
		public void onReceivedError(WebView view, int errorCode, String description, String failingUrl)
		{		
			Log.e(_logName, "ApplifierViewClient.onReceivedError() -> " + errorCode + " (" + failingUrl + ") " + description);
			super.onReceivedError(view, errorCode, description, failingUrl);
		}

		@Override
		public void onLoadResource(WebView view, String url)
		{
			super.onLoadResource(view, url);
		}	
	}	
	
	
	/**
	 * <p>
	 * Get the ID of the device where the library is running.
	 * </p>
	 * @return ID of the device or null if could not be fetched. 
	 */
	public static String getDeviceId (Context context) {
		String prefix = "";
		String deviceId = null;
		//get android id
		
		if  (deviceId == null || deviceId.length() < 3) {
			//get telephony id
			prefix = "aTUDID";
			try {
				TelephonyManager tmanager = (TelephonyManager)context.getSystemService(Context.TELEPHONY_SERVICE);
				deviceId = tmanager.getDeviceId();
			}
			catch (Exception e) {
				//maybe no permissions
			}
		}
		
		if  (deviceId == null || deviceId.length() < 3) {
			//get device serial no using private api
			prefix = "aSNO";
			try {
		        Class<?> c = Class.forName("android.os.SystemProperties");
		        Method get = c.getMethod("get", String.class);
		        deviceId = (String) get.invoke(c, "ro.serialno");
		    } 
			catch (Exception e) {
		    }
		}

		if  (deviceId == null || deviceId.length() < 3) {
			deviceId = Secure.getString(context.getContentResolver(), Secure.ANDROID_ID);
			prefix = "aID";
		}
		
		if  (deviceId == null || deviceId.length() < 3) {
			//get mac address
			prefix = "aWMAC";
			try {
				WifiManager wm = (WifiManager)context.getSystemService(Context.WIFI_SERVICE);
				deviceId = wm.getConnectionInfo().getMacAddress();
			} catch (Exception e) {
				//maybe no permissons or wifi off
			}
		}

		
		if  (deviceId == null || deviceId.length() < 3) {
			prefix = "aUnknown";
			deviceId = Build.MANUFACTURER + "-" + Build.MODEL + "-"+Build.FINGERPRINT; 
		}

		//Log.d(_logName, "DeviceID : " + prefix + "_" + deviceId);
		
		return prefix + "_" + deviceId;
	}



}

