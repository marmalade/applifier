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

#import "Applifier.h"
#import "ApplifierSBJSON.h"
#import "ApplifierSDURLCache.h"

#import <CommonCrypto/CommonDigest.h>

#include <sys/types.h>
#include <sys/sysctl.h>
#include <sys/socket.h> // Per msqr
#include <net/if.h>
#include <net/if_dl.h>

#define APPLIFIER_FACEBOOK_ID @"103673636361992"

#define APPLIFIER_MOBILE_URL @"http://cdn.applifier.com/mobile.html"
//#define APPLIFIER_MOBILE_URL @"http://cdn.applifier.com/mobile_mockup.html"
//#define APPLIFIER_MOBILE_URL @"http://aet.local/cdn/mobile_raw.html"
//#define APPLIFIER_MOBILE_URL @"http://aet.local/cdn/mobile.html"

#define APPLIFIER_SDK_VERSION 2
//#define APPLIFIER_DEBUG

static Applifier *_instance = nil;
static NSString *APPLIFIER_APP_ID = nil;
static NSMutableArray *supportedOrientations = nil;

@implementation Applifier

@synthesize facebook;
@synthesize gameDelegate;
@synthesize applifierView;
@synthesize targetPosition;
@synthesize window;
@synthesize bannerReady;
@synthesize interstitialReady;
@synthesize featuredGamesReady;
@synthesize gameRendererShouldPause;

/**
 * Checks application PList file that it contains facebook integration url scheme for applifier
 */
- (BOOL) isFacebookURLSchemeRegistered {
    BOOL facebookUrlSchemeRegistered = NO;
   
    NSString *schemeKey = [NSString stringWithFormat:@"fb%@%@", APPLIFIER_FACEBOOK_ID, APPLIFIER_APP_ID];
    
    NSArray *array = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    for (NSDictionary *typeDict in array) {
        NSArray *schemes = [typeDict objectForKey:@"CFBundleURLSchemes"];
        for (NSString *scheme in schemes) {
            if ([schemeKey isEqualToString:scheme]) {
                facebookUrlSchemeRegistered = YES;
            }
        }
    }
    return facebookUrlSchemeRegistered;
}

- (void) moveBanner:(CGPoint)to {
    targetPosition = to;
    [applifierView setBannerPosition: to];
}   

- (void) sendToDelegate:(SEL)selectorToCall {
    if (gameDelegate != nil && 
            [gameDelegate conformsToProtocol:@protocol(ApplifierGameDelegate)] && 
            [gameDelegate respondsToSelector:selectorToCall]) {
        [gameDelegate performSelector:selectorToCall];
    }
    else {
        //NSLog(@"Can't call Applifier game delegate. gameDelegate is not set or it does not conformToProtocol ApplifierGameDelegate");
    }
}

- (void) addView {
    if (applifierView.superview == nil) {
        //[gameView addSubview:[Applifier sharedInstance].applifierView];
        [window addSubview:[Applifier sharedInstance].applifierView];
    }
        
}

- (void) pauseGame {
    [self sendToDelegate:@selector(pauseGame)];
    gameRendererShouldPause = YES;
}

- (void) resumeGame {
    [self sendToDelegate:@selector(resumeGame)];    
    gameRendererShouldPause = NO;
}

/**
 * Called by html, when fullscreen requested.
 */
- (void) openFullView {
    [self addView];
    [self pauseGame];
    [applifierView showFullView];
}

- (void) hideApplifierView {
    [self resumeGame];
    [applifierView hide];
}

/**
 * Returns iOS device type, like iPhone3,1
 */
- (NSString*) getDeviceType {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

/**
 * Called when html wants to switch back to banner view
 */
- (void) showBanner {
    [self addView];
    [self resumeGame];
    [applifierView animateBannerTo:targetPosition withScalingFactor:scalingFactor];
}

- (CGSize) getBannerSize {
    if (scalingFactor == 0) 
        return CGSizeZero;
    else 
        return CGSizeMake(BANNERWIDTH * scalingFactor, BANNERHEIGHT * scalingFactor);
}

/**
 * Called when facebook app comes back to this app
 */
- (BOOL)handleOpenURL:(NSURL *)url {
    return [facebook handleOpenURL:url];
}

- (void) initApplfierView {
    state = AFWebViewStateInitInProgress;
    
    NSString *deviceId2 = [self uniqueDeviceIdentifier];
    NSString *deviceId = [[UIDevice currentDevice] uniqueIdentifier];
    NSString *deviceType = [self getDeviceType];
    NSString *locale = [[NSLocale currentLocale] localeIdentifier];
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    
    NSString* jsInit = [NSString stringWithFormat:@"applifier.init({'apiVersion' : %d, 'deviceId' : '%@', 'deviceId2' : '%@', 'appId' : '%@', 'deviceType' : '%@', 'locale' : '%@', 'platform' : 'ios', firmwareVersion : '%@'});", APPLIFIER_SDK_VERSION, deviceId, deviceId2, APPLIFIER_APP_ID, deviceType, locale, currSysVer];
    
    #ifdef APPLIFIER_DEBUG
    NSLog(@"Init %@", jsInit);
    #endif
    
    [applifierView evaluateJavascriptOnWebView:jsInit];

    state = AFWebViewStateInited;
    
    if (pendingCommands != nil) {
        for (NSString *jsCommand in pendingCommands) {
            #ifdef APPLIFIER_DEBUG
            NSLog(@"Sending command from queue: %@", jsCommand);
            #endif
            [applifierView evaluateJavascriptOnWebView:jsCommand];            
        }
        [pendingCommands release];
        pendingCommands = nil;
    }
}


/**
 * Called when webview has finished loading 
 */
- (void) webViewDidFinishLoad:(UIWebView *)webView {
    #ifdef APPLIFIER_DEBUG
    NSLog(@"Webview finished loading.");
    #endif
    if (state == AFWebViewStateLoadingInProgress) { 
        state = AFWebViewStateLoaded;
        [self initApplfierView];
    }
}




- (void) initWebView {
    [applifierView loadWebView];
    #ifdef APPLIFIER_DEBUG
    NSLog(@"Init WebView. Start loading page.");
    #endif
    NSURL* url = [NSURL URLWithString:APPLIFIER_MOBILE_URL];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [applifierView setWebViewDelegate:self];
    [applifierView loadRequest:request];
}


/**
 * Requests view to show in UIWebView
 */
- (void) sendCommand:(NSString*)command withParameter:(NSString*)param {
    NSString *js;
    
    if (param == nil) {
        js = [NSString stringWithFormat:@"applifier.%@();", command];    
    }
    else {
        js = [NSString stringWithFormat:@"applifier.%@('%@');", command, param];
    }
    

    if (state == AFWebViewStateInited) {
        #ifdef APPLIFIER_DEBUG
        NSLog(@"Sending command to web: %@", js);
        #endif
        [applifierView evaluateJavascriptOnWebView:js];
    }
    else {
        if (state == AFWebViewStateNotLoaded) {
            state = AFWebViewStateLoadingInProgress;
            [self initWebView];
        }
        
        if (pendingCommands == nil) {
            pendingCommands = [[NSMutableArray alloc] init];
        }
        
        BOOL found = NO;
        for (NSString *cmd in pendingCommands) {
            if ([cmd isEqualToString:js]) {
                found = YES;
            }
        }
        
        if (found == NO) {
            #ifdef APPLIFIER_DEBUG
            NSLog(@"Queue command: %@", js);
            #endif
            [pendingCommands addObject:js];
        }
        
    }
}

/**
 * Generates Alert to show on configuration errors only.
 */
+ (void) showAlert:(NSString*)title msg:(NSString*)text {
    [[[[UIAlertView alloc] initWithTitle:title 
                                 message:text
                                delegate:nil 
                       cancelButtonTitle:@"Ok" 
                       otherButtonTitles:nil] 
      autorelease] 
     show];
    
}

/**
 * Called when the user successfully logged in.
 */
- (void)fbDidLogin {
    [self sendCommand:@"facebookLoginSuccess" withParameter:facebook.accessToken];
}
     
    /**
     * Called when the user dismissed the dialog without logging in.
     */
- (void)fbDidNotLogin:(BOOL)cancelled {
    [self sendCommand:@"facebookLoginCancelled" withParameter:nil];
}
     
/**
* Called when facebook user logged out.
*/
- (void)fbDidLogout {
    [self sendCommand:@"facebookLogout" withParameter:nil];
}


- (NSString*) decodeFromPercentEscapeString:(NSString*)string {
    return (NSString *)
    CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                            (CFStringRef) string,
                                                            CFSTR(""),
                                                            kCFStringEncodingUTF8);
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    #ifdef APPLIFIER_DEBUG
    NSLog(@"Failed to load applifier %@", [error localizedDescription]);
    #endif
    [self releaseResources];
    state = AFWebViewStateNotLoaded;
}

/**
 * Called when webview starts loading new url. 
 * This is used also to receive calls from html side.
 */
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    #ifdef APPLIFIER_DEBUG
    NSLog(@"Going to url: %@", [[request URL] absoluteString]);
    #endif

    if ([[[request URL] scheme] isEqualToString:@"applifier"]) {
        NSString *command = [[request URL] host];
        NSString *query = [[request URL] query];
        NSString *unescapedString = [query stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        ApplifierSBJSON *jsonParser = [ApplifierSBJSON new];
        NSDictionary *json = [jsonParser objectWithString:unescapedString error:NULL];
        [jsonParser release];

        if ([command isEqualToString:@"changeFrame"]) {
            NSString *type = [json objectForKey:@"type"];
           
            if ([type isEqualToString:@"banner"])
                [self showBanner];
            else if ([type isEqualToString:@"fullscreen"])
                [self openFullView];
            else if ([type isEqualToString:@"none"])
                [self hideApplifierView];
        }
        else if ([command isEqualToString:@"loadComplete"]) {
            NSString *view = [json objectForKey:@"view"];
            
            if ([view isEqualToString:@"interstitial"]) {
                interstitialReady = YES;
                [self sendToDelegate:@selector(applifierInterstitialReady)];                
            }
            else if ([view isEqualToString:@"featuredgames"]) { 
                featuredGamesReady = YES;
                [self sendToDelegate:@selector(applifierFeaturedGamesReady)];
            }
            else if ([view isEqualToString:@"banner"]) { 
                bannerReady = YES;
                [self sendToDelegate:@selector(applifierBannerReady)];
                
                if(cancelBannerPopup == NO) {
                    cancelBannerPopup = YES; //prevent two prepare banner calls to flicker the banner
                    [applifierView setBannerPosition:targetPosition];
                    [self sendCommand:@"requestView" withParameter:@"banner"];
                }
                else {
                    #ifdef APPLIFIER_DEBUG
                    NSLog(@"Cancel banner popup flag is on. Not showing.");
                    #endif
                }
            }
        }
        else if ([command isEqualToString:@"requestFBToken"]) {
            NSArray *permissions = [json objectForKey:@"permissions"];
            [facebook authorize:permissions delegate:self];
        }
        else if ([command isEqualToString:@"scalingFactor"]) {
            scalingFactor = [[json objectForKey:@"ratio"] doubleValue];
        }
        else if ([command isEqualToString:@"log"]) {
            NSLog(@"Javascript: %@", [json objectForKey:@"message"]);
        }
        [applifierView evaluateJavascriptOnWebView:@"applifier.callNativeComplete();"];

        return NO;
    }
    else { //http etc
        if (navigationType == UIWebViewNavigationTypeLinkClicked) {

            
            NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[request URL]] delegate:self startImmediately:YES];
            [conn release];    
         
            //[self hideView];
            //[[UIApplication sharedApplication] openURL:[request URL]];
            
            return NO;
        }

    }
    return YES;
}

- (NSURLRequest*)connection:(NSURLConnection*)connection willSendRequest:(NSURLRequest*)request redirectResponse:(NSURLResponse*)response {
    BOOL itms = [[[request URL] absoluteString] hasPrefix:@"itms://"] || [[[request URL] absoluteString] hasPrefix:@"itms-apps://"];
    if (itms) {
        NSString *itmsUrl = [[request URL] absoluteString];
        NSString *itmsApps = [itmsUrl stringByReplacingOccurrencesOfString:@"itms://" withString:@"itms-apps://"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:itmsApps]];
        [self hideView];
        return nil;
    }
    return request;
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSString *message = [NSString stringWithFormat:@"Cannot connect to AppStore, please try again later. (Error: %@)", [error localizedDescription]];
    [Applifier showAlert:@"Network error" msg:message];
}

//NOTE: normally you would just use showBanner. It will appear when its loaded
//This is mainly for Unity3D integration.
- (void) prepareBanner {
    //dont show it immediately if prepared
    cancelBannerPopup = YES; 
    [self sendCommand:@"prepareView" withParameter:@"banner"];
}
- (void) prepareInterstitial {
    [self sendCommand:@"prepareView" withParameter:@"interstitial"];
}
- (void) prepareFeaturedGames {
    [self sendCommand:@"prepareView" withParameter:@"featuredgames"];    
}

/**
 * Public method
 * Call this when you want to show interstitial on ApplifierView
 */
- (void)showInterstitial {
    if (interstitialReady) {
        cancelBannerPopup = YES;
        [self sendCommand:@"requestView" withParameter:@"interstitial"];
    }

}

- (void)hideView {
    cancelBannerPopup = YES;
    [self sendCommand:@"requestView" withParameter:@"none"];
}

/**
 * Public method
 * Call this when you want to show banner on ApplifierView
 */
- (void) showBannerAt:(CGPoint)position {
    NSLog(@"Requested banner to %f %f", position.x, position.y);
    cancelBannerPopup = NO;
    targetPosition = position;
    if (bannerReady)
        [self sendCommand:@"requestView" withParameter:@"banner"];
    else
        [self sendCommand:@"prepareView" withParameter:@"banner"];
}


/**
 * Show featured games. (More games button calls this)
 */
- (void) showFeaturedGames {
    if (featuredGamesReady) {
        cancelBannerPopup = YES;
        [self sendCommand:@"requestView" withParameter:@"featuredgames"];
    }
}


/**
 * Closes webview and frees resources.
 */
- (void) releaseResources {
    [applifierView closeWebView];

    bannerReady = NO;
    interstitialReady = NO;
    featuredGamesReady = NO;
    
    [pendingCommands release];
    pendingCommands = nil;

    [applifierView removeFromSuperview];
    
    state = AFWebViewStateNotLoaded;
}




/**
 * Applifier internal initializer. 
 * For initializing, use [Applifier sharedInstance]
 */
- (id) internalInit {
	self = [super init];
    if (self != nil) {
        gameDelegate = nil;
        applifierView = nil;
        pendingCommands = nil;
        cancelBannerPopup = YES;
        scalingFactor = 0;
        
        if ([self isFacebookURLSchemeRegistered] == NO) {
            [Applifier showAlert:@"Applifier config error" msg:@"You should add applifier facebook url scheme to url types in plist file. "];
            facebook = nil;
        }
        else {
            NSString *fbAppId = [NSString stringWithFormat:@"%@%@", APPLIFIER_FACEBOOK_ID, APPLIFIER_APP_ID];
            facebook = [[ApplifierFacebook alloc] initWithAppId:fbAppId];
            facebook.sessionDelegate = self;
        }

        //for internal testing only
        if ([APPLIFIER_MOBILE_URL hasSuffix:@"mobile_raw.html"] == NO) {
            NSLog(@"Cache in use");
            ApplifierSDURLCache *urlCache = [[ApplifierSDURLCache alloc] initWithMemoryCapacity:1024*1024   // 1MB mem cache
                                                                                   diskCapacity:1024*1024*10 // 10MB disk cache
                                                                                       diskPath:[ApplifierSDURLCache defaultCachePath]];
            [NSURLCache setSharedURLCache:urlCache];
            [urlCache release];
            
        }

        state = AFWebViewStateLoadingInProgress;
        applifierView = [[ApplifierView alloc] initWithSupportedOrientations:supportedOrientations];
        [applifierView retain];
        [self initWebView];

	}
	return self;
}


#pragma mark -
#pragma mark Singleton Methods

+ (Applifier*)initWithApplifierID:(NSString*)applifierID withWindow:(UIWindow*)window supportedOrientations:(UIDeviceOrientation)orientationsToSupport, ... {
    
    APPLIFIER_APP_ID = [applifierID copy];
    
    supportedOrientations = [[NSMutableArray alloc] init];
    va_list args;
    va_start(args, orientationsToSupport);
    while (orientationsToSupport) {
        [supportedOrientations addObject:[NSNumber numberWithInt:orientationsToSupport]];
        orientationsToSupport = va_arg(args, UIDeviceOrientation);
    }
    va_end(args); 
    
    //internal init happens here
    [Applifier sharedInstance].window = window;
    
    return [Applifier sharedInstance];
}

+ (Applifier*)initWithApplifierID:(NSString*)applifierID withWindow:(UIWindow*)window delegate:(id<ApplifierGameDelegate>)applifierDelegate usingBanners:(BOOL)banners usingInterstitials:(BOOL)interstitials usingFeaturedGames:(BOOL)featuredGames supportedOrientations:(UIDeviceOrientation)orientationsToSupport, ... {
    APPLIFIER_APP_ID = [applifierID copy];
    supportedOrientations = [[NSMutableArray alloc] init];
    va_list args;
    va_start(args, orientationsToSupport);
    while (orientationsToSupport) {
        [supportedOrientations addObject:[NSNumber numberWithInt:orientationsToSupport]];
        orientationsToSupport = va_arg(args, UIDeviceOrientation);
    }
    va_end(args); 
    
    //internal init happens here
    [Applifier sharedInstance].window = window;
    [Applifier sharedInstance].gameDelegate = applifierDelegate;

    if (banners)
        [[Applifier sharedInstance] prepareBanner];
    if (interstitials)
        [[Applifier sharedInstance] prepareInterstitial];
    if (featuredGames) 
        [[Applifier sharedInstance] prepareFeaturedGames];
    return [Applifier sharedInstance];
}

+ (Applifier*)initWithApplifierID:(NSString*)applifierID withWindow:(UIWindow*)window supportedOrientationsArray:(NSMutableArray*)supportedOrientationsArray {
    APPLIFIER_APP_ID = [applifierID copy];
    
	supportedOrientations = supportedOrientationsArray;
	[supportedOrientations retain];
	//internal init happens here
    [Applifier sharedInstance].window = window;
    return [Applifier sharedInstance];
}

+ (Applifier*)sharedInstance {
	@synchronized(self) {
        if (_instance == nil) {
            if (APPLIFIER_APP_ID == nil) {
                [Applifier showAlert:@"Applifier init error" msg:@"You need to initialize Applifier with initWithApplifierID method before using sharedInstance method."];
            }
            
            _instance = [[self alloc] internalInit];
        }
    }
    return _instance;
}

+ (id)allocWithZone:(NSZone *)zone {	
    @synchronized(self) {
        if (_instance == nil) {
            _instance = [super allocWithZone:zone];			
            return _instance;  
        }
    }
    return nil; 
}

// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
- (NSString *) getMac {
    
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", 
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}
- (NSString *) MD5:(NSString*)original {
    
    if(original == nil || [original length] == 0)
        return nil;
    
    const char *value = [original UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return [outputString autorelease];
}

- (NSString*) uniqueDeviceIdentifier{
    NSString *mac = [self getMac];
    NSString *udid = [self MD5:mac];
    return udid;
}


- (id)copyWithZone:(NSZone *)zone {
    return self;	
}
- (id)retain {	
    return self;	
}
- (unsigned)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}
- (oneway void)release {
    //do nothing
}
- (id)autorelease {
    return self;	
}


@end
