/*
 * Copyright 2011 Applifier
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 *
 * Applifier iOS SDK Version 1.5.7
 *
 */

#import "ApplifierFacebook.h"
#import "ApplifierView.h"

@protocol ApplifierGameDelegate <NSObject>
- (void)applifierInterstitialReady;
- (void)applifierFeaturedGamesReady;
@optional
- (void)applifierBannerReady;
- (void)pauseGame;
- (void)resumeGame;
@end

typedef enum {
    AFWebViewStateNotLoaded,
    AFWebViewStateLoadingInProgress,
    AFWebViewStateLoaded,
    AFWebViewStateInitInProgress,
    AFWebViewStateInited
}  AFWebViewState;

#pragma mark

@interface Applifier : NSObject <ApplifierFBSessionDelegate,UIWebViewDelegate> {
    @private
    ApplifierFacebook *facebook;
    ApplifierView *applifierView;
    CGPoint targetPosition;
    id<ApplifierGameDelegate> gameDelegate;
    AFWebViewState state;
    NSMutableArray *pendingCommands;
    double scalingFactor;
    BOOL cancelBannerPopup;
    UIWindow *window;
    BOOL bannerReady;
    BOOL interstitialReady;
    BOOL featuredGamesReady;
    BOOL gameRendererShouldPause;
}

+ (Applifier*)initWithApplifierID:(NSString*)applifierID withWindow:(UIWindow*)window supportedOrientations:(UIDeviceOrientation)orientationsToSupport, ...NS_REQUIRES_NIL_TERMINATION;
+ (Applifier*)initWithApplifierID:(NSString*)applifierID withWindow:(UIWindow*)window delegate:(id<ApplifierGameDelegate>)applifierDelegate usingBanners:(BOOL)banners usingInterstitials:(BOOL)interstitials usingFeaturedGames:(BOOL)featuredGames supportedOrientations:(UIDeviceOrientation)orientationsToSupport, ...NS_REQUIRES_NIL_TERMINATION;
+ (Applifier*)initWithApplifierID:(NSString*)applifierID withWindow:(UIWindow*)window supportedOrientationsArray:(NSMutableArray*)orientationsArray;

+ (Applifier*)sharedInstance;

- (void) releaseResources;
- (void) hideView;
- (void) prepareBanner;
- (void) prepareInterstitial;
- (void) prepareFeaturedGames;
- (void) showInterstitial;
- (void) showFeaturedGames;
- (void) showBannerAt:(CGPoint)position;
- (BOOL) handleOpenURL:(NSURL *)url;
- (CGSize) getBannerSize;
- (NSString*) uniqueDeviceIdentifier;
- (void) moveBanner:(CGPoint)to;

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) ApplifierFacebook *facebook;
@property (nonatomic, retain) id<ApplifierGameDelegate> gameDelegate;
@property (nonatomic, retain) ApplifierView* applifierView;
@property (assign) CGPoint targetPosition; //target position for banner
@property (assign) BOOL bannerReady;
@property (assign) BOOL interstitialReady;
@property (assign) BOOL featuredGamesReady;
@property (assign) BOOL gameRendererShouldPause;

@end

