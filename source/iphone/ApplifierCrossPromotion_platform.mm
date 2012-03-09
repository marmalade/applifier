/*
 * iphone-specific implementation of the ApplifierCrossPromotion extension.
 * Add any platform-specific functionality here.
 */
/*
 * NOTE: This file was originally written by the extension builder, but will not
 * be overwritten (unless --force is specified) and is intended to be modified.
 */
#include "ApplifierCrossPromotion_internal.h"
#include "IwDebug.h"
#import <Applifier/Applifier.h>
#import "s3eDevice.h"
#import "s3eEdk.h"

@interface ApplifierDelegateWrapper : NSObject<ApplifierGameDelegate> {
	
}
@end

@implementation ApplifierDelegateWrapper

- (void)applifierFeaturedGamesReady {
}
- (void)applifierInterstitialReady {	
}
- (void)pauseGame {
}
- (void)resumeGame {

}

@end



s3eResult ApplifierCrossPromotionInit_platform()
{
    // Add any platform-specific initialisation code here
    return S3E_RESULT_SUCCESS;
}

int32 openURLCallback(void* systemData, void* userData) {
	NSURL *url = (NSURL *)systemData;
	[[Applifier sharedInstance] handleOpenURL:url];
	return 0;
}

void ApplifierCrossPromotionTerminate_platform()
{
	[[Applifier sharedInstance] releaseResources];
}

s3eResult ApplifierCrossPromotionInitialize_platform(const char* applifierId, bool orientationHomeButtonDown, bool orientationHomeButtonRight, bool orientationHomeButtonLeft, bool orientationHomeButtonUp) {
	NSString *af_id = [NSString stringWithUTF8String:applifierId];
	UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0]; 	
	
	NSMutableArray *array = [[NSMutableArray alloc] init];
	if (orientationHomeButtonDown)
		[array addObject:[NSNumber numberWithInt:UIDeviceOrientationPortrait]];	
	if (orientationHomeButtonRight)
		[array addObject:[NSNumber numberWithInt:UIDeviceOrientationLandscapeLeft]];	
	if (orientationHomeButtonLeft)
		[array addObject:[NSNumber numberWithInt:UIDeviceOrientationLandscapeRight]];	
	if (orientationHomeButtonUp)
		[array addObject:[NSNumber numberWithInt:UIDeviceOrientationPortraitUpsideDown]];	

	if ([array count] == 0) {
		[array addObject:[NSNumber numberWithInt:UIDeviceOrientationPortrait]];	
		NSLog(@"Applifier config error: At least one orientation should be enabled. Enabling Portrait for now.");
	}
	
	[Applifier initWithApplifierID:af_id withWindow:window supportedOrientationsArray:array];
	ApplifierDelegateWrapper *wrapper = [[ApplifierDelegateWrapper alloc] init];
	[Applifier sharedInstance].gameDelegate = wrapper;
	[wrapper release];
	 
	[array release];
	
	s3eEdkCallbacksRegister(S3E_EDK_INTERNAL, 
									S3E_EDK_CALLBACK_MAX, 
									S3E_EDK_IPHONE_HANDLEOPENURL, 
									openURLCallback, 
									0,
									false
									);
	
	
    return S3E_RESULT_SUCCESS;
}



bool ApplifierCrossPromotionShowBanner_platform(int positionX, int positionY) {
	[[Applifier sharedInstance] showBannerAt:CGPointMake(positionX, positionY)];	
    return true;
}

bool ApplifierCrossPromotionMoveBanner_platform(int x, int y) {
	[[Applifier sharedInstance] moveBanner:CGPointMake(x, y)];	
    return true;
}

bool ApplifierCrossPromotionHideBanner_platform() {
	[[Applifier sharedInstance] hideView];	
    return true;
}

bool ApplifierCrossPromotionPrepareFeaturedGames_platform() {
	[[Applifier sharedInstance] prepareFeaturedGames];	
    return true;
}

bool ApplifierCrossPromotionPrepareInterstitial_platform() {
	[[Applifier sharedInstance] prepareInterstitial];	
    return true;
}

bool ApplifierCrossPromotionIsFeaturedGamesReady_platform() {
	return [Applifier sharedInstance].featuredGamesReady;
}

bool ApplifierCrossPromotionIsInterstitialReady_platform() {
	return [Applifier sharedInstance].interstitialReady;
}


bool ApplifierCrossPromotionShowFeaturedGames_platform() {
	if ([Applifier sharedInstance].featuredGamesReady) {
		[[Applifier sharedInstance] showFeaturedGames];	
		return true;
	}
	else {
		return false;
	}
}

bool ApplifierCrossPromotionShowInterstitial_platform() {
	if ([Applifier sharedInstance].interstitialReady) {
		[[Applifier sharedInstance] showInterstitial];
		return true;
	}
	else {
		return false;

	}
}

bool ApplifierCrossPromotionPauseRenderer_platform() {
	return [Applifier sharedInstance].gameRendererShouldPause;
}
