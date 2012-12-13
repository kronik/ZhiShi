//
//  AppDelegate.h
//  Akak
//
//  Created by dima on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "MBProgressHUD.h"

@class MainViewController;
@class MyReachability;

#define APPDELEGATE (AppDelegate *)[UIApplication sharedApplication].delegate

extern NSString *const FBSessionStateChangedNotification;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAccelerometerDelegate, MBProgressHUDDelegate>
{
	BOOL histeresisExcited;
	UIAcceleration* lastAcceleration;
    MBProgressHUD *hud;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) MyReachability* internetReachable;
@property (nonatomic, assign) BOOL hayInternet;

- (NSURL *)applicationDocumentsDirectory;
//- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;

@property (strong, nonatomic) MainViewController *mainViewController;
@property (strong, nonatomic) FBSession *session;

@property (strong, nonatomic) UIAcceleration* lastAcceleration;

+ (AppDelegate *)appDelegate;

- (void) mostratHUDCargando;
- (void) mostratHUD:(BOOL)animated conTexto:(NSString *)aTexto;
- (void) mostratHUD:(BOOL)animated conTexto:(NSString *)aTexto conView:(UIView *)aView dimBackground:(BOOL)dimBackg;
- (void) mostratHUDConTexto:(NSString *)aTexto WhileExecuting:(SEL)method onTarget:(id)target withObject:(id)object animated:(BOOL)animated;

- (void) ocultarHUD;
- (void) ocultarHUD:(BOOL)animated;
- (void) ocultarHUD:(BOOL)animated despuesDe:(NSTimeInterval)delay;
- (void) ocultarHUDConCustomView:(BOOL)animated despuesDe:(NSTimeInterval)delay;

- (void)showLoaderInView: (UIView*)view;
- (void)hideLoader;
- (void) showInfoHudInView: (UIView*)view;

@end
