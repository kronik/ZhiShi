//
//  BasicViewController.h
//  iBeanstalk
//
//  Created by Dmitry Klimkin on 7/4/13.
//  Copyright (c) 2013 Dmitry Klimkin. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef LITE_VERSION

#import "GADBannerViewDelegate.h"
#import "GADBannerView.h"
#import "GADRequest.h"

@class GADBannerView, GADRequest;

@interface BasicViewController : UIViewController <GADBannerViewDelegate>

@property (strong, nonatomic) GADBannerView *adBanner;
@property (strong, nonatomic) GADRequest *request;

- (GADRequest *)createRequest;
- (void)unlockNoAdvProduct: (NSNotification *)notification;

#else 

@interface BasicViewController : UIViewController

#endif 

- (void)showSuccessNotification:(NSString *)message;
- (void)showSuccessNotification:(NSString *)message onView:(UIView *)inView;

- (void)showError:(NSString *)errorMessage;
- (void)showError:(NSString *)errorMessage onView:(UIView *)inView;

- (void)addBackButton;
- (void)goBack:(UIView *)button;

- (void) showProgressHUD;
- (void) showHUD:(BOOL)animated withText:(NSString *)text;
- (void) showHUD:(BOOL)animated withText:(NSString *)aTexto onView:(UIView *)aView dimBackground:(BOOL)dimBackg;
- (void) showHUDWithText:(NSString *)aTexto whileExecuting:(SEL)method onTarget:(id)target withObject:(id)object animated:(BOOL)animated;

- (void) hideHUD;
- (void) hideHUD:(BOOL)animated;
- (void) hideHUD:(BOOL)animated afterDelay:(NSTimeInterval)delay;
- (void) hideHUDCustomView:(BOOL)animated afterDelay:(NSTimeInterval)delay;
- (void)setMainTitle:(NSString*)title;

@end

