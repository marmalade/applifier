/*
 * Copyright 2011 Applifier
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ApplifierView.h"

#define BANNERHEIGHT 50
#define BANNERWIDTH 310
#define APPLIFIER_VIEW_TAG 10298305
#define TRANSPARENT_BG_COLOR [UIColor clearColor]
#define FULLSCREEN_BG_COLOR [UIColor grayColor]
#define degreesToRadian(x) (M_PI * (x) / 180.0)

@implementation ApplifierView

- (id) initWithSupportedOrientations:(NSMutableArray*)orientations {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.clipsToBounds = YES; //hides subview that go out from this bounds
        self.multipleTouchEnabled = NO;
        self.tag = APPLIFIER_VIEW_TAG;
        bannerScalingFactor = 1;
        supportedOrientations = orientations;
        

    }
    return self;
}

- (void) detectRotationAndRotate {
    UIDeviceOrientation o = [UIDevice currentDevice].orientation;
    NSLog(@"Current orientation %d", o);
    if ([self isSupportedOrientation:o] == NO) {
        o = [[supportedOrientations objectAtIndex:0] intValue];
    }
    [self rotateTo: o];
}

- (void) loadWebView {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(receivedRotateFromNotificationCenter:) name: UIDeviceOrientationDidChangeNotification object: nil];
    webView = [self getWebView];
    [self addSubview:webView];
    [self detectRotationAndRotate];
}

- (UIWebView*) getWebView {
    UIWebView *web = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, BANNERWIDTH, BANNERHEIGHT)];
    web.center = CGPointMake(BANNERWIDTH/2, BANNERHEIGHT/2);
    web.contentMode = UIViewContentModeCenter | UIViewContentModeScaleAspectFit;

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4) {
        //web.allowsInlineMediaPlayback = NO;
        web.allowsInlineMediaPlayback = YES; // since 1.5.3
        web.mediaPlaybackRequiresUserAction = NO; // since 1.5.3
    }
    
    web.userInteractionEnabled = YES;
    [web setBackgroundColor:TRANSPARENT_BG_COLOR];
    [web setOpaque:NO];
    return web;
}

- (void) setWebViewDelegate:(id)delegate {
    webView.delegate = delegate;
}

- (void) loadRequest:(NSURLRequest*)urlRequest {
    [webView loadRequest:urlRequest];
}

- (void)resetAutoresizeMasks:(NSString *)animationID finished:(BOOL)finished context:(void *)context {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void) sendFrameTransitionComplete:(NSString*)viewName {
    NSString *js = [NSString stringWithFormat:@"applifier.frameTransitionComplete('%@');", viewName];
    [webView stringByEvaluatingJavaScriptFromString:js];  
}

- (void)sendFrameTransitionComplete:(NSString *)animationID finished:(BOOL)finished context:(void *)context {
    if ([@"fullscreen" isEqualToString:context]) {
        [self resetAutoresizeMasks:animationID finished:finished context:context];
    }
    [self sendFrameTransitionComplete:(NSString*)context];
}


- (void) showFullView {
    bannerEnabled = NO;
    if (fullscreenEnabled == NO) {
        fullscreenEnabled = YES;
        
        self.autoresizingMask = UIViewAutoresizingNone;
        webView.autoresizingMask = UIViewAutoresizingNone;
        
        [self setBackgroundColor:FULLSCREEN_BG_COLOR];
        [webView setOpaque:YES];
        
        
        CGRect screenBounds = [[UIScreen mainScreen] bounds];

        self.frame = CGRectZero;   
        self.center = CGPointMake(screenBounds.size.width/2, screenBounds.size.height/2); //set animation center point for main view
        
        if (UIInterfaceOrientationIsLandscape(requestedOrientation)) 
            webView.frame = CGRectMake(0, 0, screenBounds.size.height, screenBounds.size.width);   
        else
            webView.frame = screenBounds;   

        webView.center = CGPointZero;

        [UIView beginAnimations:@"showFullView" context:@"fullscreen"];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(sendFrameTransitionComplete:finished:context:)];
        [UIView setAnimationDelay: UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.15];
        self.frame = screenBounds;
        
        if (UIInterfaceOrientationIsLandscape(requestedOrientation)) 
            webView.center = CGPointMake(screenBounds.size.height/2, screenBounds.size.width/2);
        else
            webView.center = CGPointMake(screenBounds.size.width/2, screenBounds.size.height/2);

        webView.alpha = 1;
        self.alpha = 1;
        
        [UIView commitAnimations];

    }
        
}


- (void) hide { 
    bannerEnabled = NO;
    fullscreenEnabled = NO;
   
    self.autoresizingMask = UIViewAutoresizingNone;
    webView.autoresizingMask = UIViewAutoresizingNone;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    [UIView beginAnimations:@"hideView" context:@"none"];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(sendFrameTransitionComplete:finished:context:)];
    [UIView setAnimationDelay: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.25];

    webView.alpha = 0;
    self.alpha = 0;
    webView.center = CGPointZero;
    
    self.frame = CGRectMake(screenBounds.size.width/2, screenBounds.size.height/2, 0,0);   

    [UIView commitAnimations];
}


- (CGRect) getRectForRotation:(UIDeviceOrientation)orientation usingRect:(CGRect)rect {
    CGFloat newWidth = 0;
    CGFloat newHeight = 0;
    CGFloat newX = 0;
	CGFloat newY = 0;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect originalFrame = rect;
    
    switch (orientation) {
        case UIDeviceOrientationPortrait: 
            newX = originalFrame.origin.x;
            newY = originalFrame.origin.y;
            newWidth = originalFrame.size.width;
            newHeight = originalFrame.size.height;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            newX = screenBounds.size.width - originalFrame.origin.x;
            newY = screenBounds.size.height - originalFrame.origin.y;
            newWidth = -originalFrame.size.width;
            newHeight = -originalFrame.size.height;
            break;
        case UIDeviceOrientationLandscapeLeft: //HomeButton on right
            newX = screenBounds.size.width - originalFrame.origin.y;
            newY = originalFrame.origin.x;
            newWidth = -originalFrame.size.height;
            newHeight = originalFrame.size.width;
            break;
        case UIDeviceOrientationLandscapeRight: //HomeButton on left
            newX = originalFrame.origin.y;
            newY = screenBounds.size.height - originalFrame.origin.x;
            newWidth = originalFrame.size.height;
            newHeight = -originalFrame.size.width;
            break;
        default: 
            break;
    }
    return CGRectMake(newX, newY, newWidth, newHeight);  
    
}

- (CGRect) getBannerRect {
    return CGRectMake(bannerPosition.x, bannerPosition.y, BANNERWIDTH * bannerScalingFactor, BANNERHEIGHT * bannerScalingFactor);
}

- (CGRect) getFullScreenRect {
    if (UIDeviceOrientationIsLandscape(requestedOrientation)) {
        return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
    }
    return [[UIScreen mainScreen] bounds];
}

    
- (void) animateBannerVisible {

    CGRect bannerRect = [self getBannerRect];
    CGRect rect = [self getRectForRotation:requestedOrientation usingRect:bannerRect];
    
    //this should be sent after transition, 
    //but without this we dont get to see banner during transition, making animation useless
    [self sendFrameTransitionComplete:@"banner"];
    
    
    CGFloat bannerWidth  = BANNERWIDTH * bannerScalingFactor;
    CGFloat bannerHeight = BANNERHEIGHT * bannerScalingFactor;
    
    self.autoresizingMask = UIViewAutoresizingNone;
    webView.autoresizingMask = UIViewAutoresizingNone;
    
    [webView setOpaque:NO];
    [self setBackgroundColor:TRANSPARENT_BG_COLOR];
    
    webView.frame = CGRectMake(0, 0, bannerWidth, bannerHeight);
    webView.center = CGPointZero;

    self.frame = [self getRectForRotation:requestedOrientation usingRect:CGRectMake(bannerRect.origin.x + (bannerWidth/2), bannerRect.origin.y + (bannerHeight/2), 0, 0)];
    
    self.alpha = 0;
    webView.alpha = 0;
    
    [UIView beginAnimations:@"bringBannerVisible" context:@"banner"];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(sendFrameTransitionComplete:finished:context:)];
    [UIView setAnimationDelay: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.8];
    webView.alpha = 1;
    self.alpha = 1;
    self.frame = rect; 
    webView.center = CGPointMake(bannerWidth/2, bannerHeight/2);    
    [UIView commitAnimations];
}


- (void) adjustViewsOrientation:(UIDeviceOrientation)orientation {
    if (fullscreenEnabled)
        self.frame = [self getRectForRotation:orientation usingRect:[self getFullScreenRect]];
    else if (bannerEnabled) 
        self.frame = [self getRectForRotation:orientation usingRect:[self getBannerRect]];        
}

- (void) setBannerPosition:(CGPoint)targetPosition {
    bannerPosition = targetPosition;
    self.frame = [self getRectForRotation:requestedOrientation usingRect:[self getBannerRect]];        
}

- (void) animateBannerTo:(CGPoint)position withScalingFactor:(double)scalingFactor {
    bannerEnabled = YES;
    fullscreenEnabled = NO;
    bannerScalingFactor = scalingFactor;
    bannerPosition = position;
    
    [self animateBannerVisible];
}

- (NSString*) evaluateJavascriptOnWebView:(NSString*)javascript {
    return [webView stringByEvaluatingJavaScriptFromString:javascript];  
}

- (void) sendOrientationChangeEvent {
    [webView stringByEvaluatingJavaScriptFromString:@"(function() { var e = document.createEvent('Events'); e.initEvent('orientationchange', true, false); document.dispatchEvent(e); })(); "];
}

- (CGRect) getFullScreenRectForOrientation:(UIDeviceOrientation)orientation {
    if (UIDeviceOrientationIsPortrait(orientation)) {
        return [[UIScreen mainScreen] bounds];
    }
    else {
        return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
    }
}

- (void) rotateTo:(UIDeviceOrientation)toOrientation {
    if (toOrientation == requestedOrientation) return;
    requestedOrientation = toOrientation;

    float time = 0.2;
    int angle = 0;
    if (toOrientation == UIDeviceOrientationLandscapeLeft) {
        angle = 90;
    }
    else if (toOrientation == UIDeviceOrientationLandscapeRight) {
        angle = -90;
    }
    else if (toOrientation == UIDeviceOrientationPortraitUpsideDown) {
        angle = -180;
        time = 0;
    }
    else if (toOrientation == UIDeviceOrientationPortrait) {
        angle = 0;
    }
    
    if (fullscreenEnabled == NO && bannerEnabled == NO) {
        self.transform = CGAffineTransformIdentity;
        self.transform = CGAffineTransformMakeRotation(degreesToRadian(angle));
        [self adjustViewsOrientation:toOrientation];
    }
    else {
        self.autoresizingMask = UIViewAutoresizingNone;
        webView.autoresizingMask = UIViewAutoresizingNone;
        
        BOOL fs = fullscreenEnabled; //separate boolean to be sure to execute commit animations aswell.
        if (fs) {
            webView.frame = [self getFullScreenRectForOrientation:toOrientation];
            [UIView beginAnimations:@"rotateView" context:nil];
            [UIView setAnimationDelay: UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:time];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(sendOrientationChangeEvent)];
        }
        
        self.transform = CGAffineTransformIdentity;
        self.transform = CGAffineTransformMakeRotation(degreesToRadian(angle));
        [self adjustViewsOrientation:toOrientation];

       
        if (fs)
            [UIView commitAnimations];
        
        //animate banner another way
        if (bannerEnabled)
            [self animateBannerVisible];

    }
    
    

}

-(BOOL) isSupportedOrientation:(UIDeviceOrientation)deviceOrientation {
    if (supportedOrientations == nil) return NO;
    else {
        for (NSNumber *orientationNumber in supportedOrientations) {
            UIDeviceOrientation orientation = [orientationNumber intValue];
            if (deviceOrientation == orientation) 
                return YES;
        }
    }
    return NO;
}

-(void) receivedRotateFromNotificationCenter: (NSNotification*) notification {
    UIDeviceOrientation o = [UIDevice currentDevice].orientation;
    if ([self isSupportedOrientation:o]) {
        [self rotateTo: o];
    }
    else {
        [self sendOrientationChangeEvent];
    }
}

- (void) closeWebView {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    //[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];

    self.frame = CGRectMake(0, 0, 0, 0);
    [self setBackgroundColor:TRANSPARENT_BG_COLOR];

    [webView stopLoading];
    [webView removeFromSuperview];
    [webView release];

    webView = nil;
}

/**
 * This will not get called, because this instance lives in singleton
 */
- (void) dealloc {
    if (webView != nil) { //if not closed already
        [self closeWebView];
    }
    [super dealloc];
}

@end
