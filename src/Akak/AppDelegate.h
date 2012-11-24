//
//  AppDelegate.h
//  Akak
//
//  Created by dima on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@class MainViewController;

extern NSString *const FBSessionStateChangedNotification;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAccelerometerDelegate>
{
	BOOL histeresisExcited;
	UIAcceleration* lastAcceleration;
}

@property (strong, nonatomic) UIWindow *window;

- (NSURL *)applicationDocumentsDirectory;
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;

@property (strong, nonatomic) MainViewController *mainViewController;
@property (strong, nonatomic) FBSession *session;

@property (strong, nonatomic) UIAcceleration* lastAcceleration;

+ (AppDelegate *)appDelegate;

@end
