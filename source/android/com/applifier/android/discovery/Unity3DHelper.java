package com.applifier.android.discovery;

import java.lang.reflect.Method;


import android.app.Activity;
import android.util.Log;

public class Unity3DHelper implements ApplifierViewListener {

	private String gameObject;
	private Method sendMessageMethod;
	private static ApplifierView applifierView = null;
	
	public void init(String gameObject, final Activity activity, final String applifierID) {
		this.gameObject = gameObject;
		
		if (applifierView != null) {
			sendMessageToUnity3D("applifierLoaded", null);
			return; //dont init it again.
		}
		
		final Unity3DHelper listener = this;
		try {
			activity.runOnUiThread(new Runnable() {
				public void run() {
					applifierView = new ApplifierView(activity, applifierID);
					applifierView.setApplifierListener(listener);
					sendMessageToUnity3D("applifierLoaded", null);
				}
			});
		} 
		catch (Exception e) {
			Log.e("Applifier", "Exception while creating ApplifierView with " + activity, e);
		}
	}
	
	public ApplifierView getApplifierView() {
		return applifierView;
	}
	
	public Unity3DHelper() {
		Log.e("Applifier", "Unity3DHelper constructor");
		
		
		try {
			Class<?> unityClass = Class.forName("com.unity3d.player.UnityPlayer");
			Class<?> paramTypes[] = new Class[3];
			paramTypes[0] = String.class;
			paramTypes[1] = String.class;
			paramTypes[2] = String.class;
			sendMessageMethod = unityClass.getDeclaredMethod("UnitySendMessage", paramTypes);
		} catch (Exception e) {
			Log.e("Applifier", "Error getting class or method of com.unity3d.player.UnityPlayer, method UnitySendMessage(string,string,string). " + e.getLocalizedMessage());
		}
		
	}
	
	public void sendMessageToUnity3D(String methodName, String parameter) {
		//UnityPlayer.UnitySendMessage(gameObject, methodName, parameter);
		
		if (sendMessageMethod == null) {
			Log.e("Applifier", "Cannot send message to Unity3D. Method is null");
			return;
		}
		try {
			sendMessageMethod.invoke(null, gameObject, methodName, parameter);
		} catch (Exception e) {
			Log.e("Applifier", "Can't invoke UnitySendMessage method. Error = "  + e.getLocalizedMessage());
		}
		
	}
	
	public void onInterstialReady() {
		sendMessageToUnity3D("interstitialReady", null);
	}

	public void onFeaturedGamesReady() {
		sendMessageToUnity3D("featuredGamesReady", null);
	}

	public void onBannerReady() {
		sendMessageToUnity3D("bannerReady", null);
	}

	public void pauseGame() {
		sendMessageToUnity3D("pauseGame", null);
	}

	public void resumeGame() {
		sendMessageToUnity3D("resumeGame", null);
	}


}
