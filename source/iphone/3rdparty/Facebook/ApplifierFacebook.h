/*
 * Copyright 2010 Facebook
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
 */

#import "ApplifierFBLoginDialog.h"
#import "ApplifierFBRequest.h"

@protocol ApplifierFBSessionDelegate;

/**
 * Main Facebook interface for interacting with the Facebook developer API.
 * Provides methods to log in and log out a user, make requests using the REST
 * and Graph APIs, and start user interface interactions (such as
 * pop-ups promoting for credentials, permissions, stream posts, etc.)
 */
@interface ApplifierFacebook : NSObject<ApplifierFBLoginDialogDelegate>{
  NSString* _accessToken;
  NSDate* _expirationDate;
  id<ApplifierFBSessionDelegate> _sessionDelegate;
  ApplifierFBRequest* _request;
  ApplifierFBDialog* _loginDialog;
  ApplifierFBDialog* _fbDialog;
  NSString* _appId;
  NSString* _localAppId;
  NSArray* _permissions;
}

@property(nonatomic, copy) NSString* accessToken;
@property(nonatomic, copy) NSDate* expirationDate;
@property(nonatomic, assign) id<ApplifierFBSessionDelegate> sessionDelegate;
@property(nonatomic, copy) NSString* localAppId;

- (id)initWithAppId:(NSString *)app_id;

- (void)authorize:(NSArray *)permissions
         delegate:(id<ApplifierFBSessionDelegate>)delegate;

- (void)authorize:(NSArray *)permissions
         delegate:(id<ApplifierFBSessionDelegate>)delegate
       localAppId:(NSString *)localAppId;

- (BOOL)handleOpenURL:(NSURL *)url;

- (void)logout:(id<ApplifierFBSessionDelegate>)delegate;

- (ApplifierFBRequest*)requestWithParams:(NSMutableDictionary *)params
                    andDelegate:(id <ApplifierFBRequestDelegate>)delegate;

- (ApplifierFBRequest*)requestWithMethodName:(NSString *)methodName
                          andParams:(NSMutableDictionary *)params
                      andHttpMethod:(NSString *)httpMethod
                        andDelegate:(id <ApplifierFBRequestDelegate>)delegate;

- (ApplifierFBRequest*)requestWithGraphPath:(NSString *)graphPath
                       andDelegate:(id <ApplifierFBRequestDelegate>)delegate;

- (ApplifierFBRequest*)requestWithGraphPath:(NSString *)graphPath
                         andParams:(NSMutableDictionary *)params
                       andDelegate:(id <ApplifierFBRequestDelegate>)delegate;

- (ApplifierFBRequest*)requestWithGraphPath:(NSString *)graphPath
                         andParams:(NSMutableDictionary *)params
                     andHttpMethod:(NSString *)httpMethod
                       andDelegate:(id <ApplifierFBRequestDelegate>)delegate;

- (void)dialog:(NSString *)action
   andDelegate:(id<ApplifierFBDialogDelegate>)delegate;

- (void)dialog:(NSString *)action
     andParams:(NSMutableDictionary *)params
   andDelegate:(id <ApplifierFBDialogDelegate>)delegate;

- (BOOL)isSessionValid;

@end

////////////////////////////////////////////////////////////////////////////////

/**
 * Your application should implement this delegate to receive session callbacks.
 */
@protocol ApplifierFBSessionDelegate <NSObject>

@optional

/**
 * Called when the user successfully logged in.
 */
- (void)fbDidLogin;

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled;

/**
 * Called when the user logged out.
 */
- (void)fbDidLogout;

@end
