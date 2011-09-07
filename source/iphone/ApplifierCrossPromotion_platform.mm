/*
 * iphone-specific implementation of the ApplifierCrossPromotion extension.
 * Add any platform-specific functionality here.
 */
/*
 * NOTE: This file was originally written by the extension builder, but will not
 * be overwritten (unless --force is specified) and is intended to be modified.
 */
#include "ApplifierCrossPromotion_internal.h"
#import "Applifier.h"
#import "s3eDevice.h"

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

void ApplifierCrossPromotionTerminate_platform()
{
	[[Applifier sharedInstance] releaseResources];
}

s3eResult init_platform(const char* applifierId, bool orientationHomeButtonDown, bool orientationHomeButtonRight, bool orientationHomeButtonLeft, bool orientationHomeButtonUp) {
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

    return S3E_RESULT_SUCCESS;
}


bool showBanner_platform(int positionX, int positionY) {
	[[Applifier sharedInstance] showBannerAt:CGPointMake(positionX, positionY)];	
    return true;
}

bool moveBanner_platform(int x, int y) {
	[[Applifier sharedInstance] moveBanner:CGPointMake(x, y)];	
    return true;
}

bool hideBanner_platform() {
	[[Applifier sharedInstance] hideView];	
    return true;
}

bool prepareFeaturedGames_platform() {
	[[Applifier sharedInstance] prepareFeaturedGames];	
    return true;
}

bool prepareInterstitial_platform() {
	[[Applifier sharedInstance] prepareInterstitial];	
    return true;
}

bool isFeaturedGamesReady_platform() {
	return [Applifier sharedInstance].featuredGamesReady;
}

bool isInterstitialReady_platform() {
	return [Applifier sharedInstance].interstitialReady;
}


bool showFeaturedGames_platform() {
	if ([Applifier sharedInstance].featuredGamesReady) {
		[[Applifier sharedInstance] showFeaturedGames];	
		return true;
	}
	else {
		return false;
	}
}

bool showInterstitial_platform() {
	if ([Applifier sharedInstance].interstitialReady) {
		[[Applifier sharedInstance] showInterstitial];
		return true;
	}
	else {
		return false;

	}
}

bool pauseRenderer_platform() {
	return [Applifier sharedInstance].gameRendererShouldPause;
}
