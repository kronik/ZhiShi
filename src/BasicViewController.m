//
//  BasicViewController.m
//  iBeanstalk
//
//  Created by Dmitry Klimkin on 7/4/13.
//  Copyright (c) 2013 Dmitry Klimkin. All rights reserved.
//

#import "BasicViewController.h"
#import "WBNoticeView.h"
#import "MBProgressHUD.h"
#import "NIKFontAwesomeIconFactory+iOS.h"

#define CUSTOMVIEW_TAG      1111

@interface BasicViewController () <MBProgressHUDDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation BasicViewController

#ifdef LITE_VERSION

@synthesize adBanner = adBanner_;
@synthesize request = _request;

#endif

@synthesize hud = _hud;

- (void)setMainTitle:(NSString*)title
{
    UILabel *label = [[UILabel alloc] init];
    
	label.text = title;
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont boldSystemFontOfSize:20.0f];
	label.textAlignment = NSTextAlignmentCenter;
	label.textColor =[UIColor whiteColor];
    
    CGSize size = [label sizeThatFits:CGSizeMake(1, 44)];
    label.frame = CGRectMake(0, 0, size.width, 44);
    label.adjustsFontSizeToFitWidth = YES;
	self.navigationItem.titleView = label;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    CGRect rect = CGRectMake(0, 0, 1, 1);
    // Create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    
    [[UIColor colorWithRed:0.18f green:0.39f blue:0.59f alpha:1.00f] setFill];
    
    UIRectFill(rect);   // Fill it with your color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [[UINavigationBar appearance] setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [self setNeedsStatusBarAppearanceUpdate];
        
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.18f green:0.39f blue:0.59f alpha:1.00f];
        
        self.navigationController.navigationBar.translucent = YES;
        
        [self.navigationController interactivePopGestureRecognizer];
        
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }

    UIView *hubParentView = self.navigationController.view ? self.view : self.view;
    
    // add the HUD
    self.hud = [[MBProgressHUD alloc] initWithView: hubParentView];
    self.hud.dimBackground = NO;
    
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    self.hud.delegate = self;
    
    [hubParentView addSubview:self.hud];
    
#ifdef LITE_VERSION
    self.adBanner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        
    self.adBanner.adUnitID = @"a14f29fa9fa7cb1";
    self.adBanner.delegate = self;
    [self.adBanner setRootViewController:self];
    //[self.view addSubview:self.adBanner];
    [self.adBanner loadRequest:[self createRequest]];
    
    //self.adBanner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
#endif
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
#if LITE_VER == 1
    
    self.adBanner.delegate = nil;
    self.adBanner = nil;
    
#endif
}

#ifdef LITE_VERSION

- (void)updateAdBannerPosition {
    
}

- (void)retryGetAd {
    [self.adBanner loadRequest: self.request];
}

- (void)unlockNoAdvProduct: (NSNotification *)notification {
    [self.adBanner removeFromSuperview];
}

- (GADRequest *)createRequest {
    self.request = [GADRequest request];
    
    self.request.testing = NO;
    
    // Make the request for a test ad. Put in an identifier for the simulator as
    // well as any devices you want to receive test ads.
    self.request.testDevices = @[];
    return self.request;
}

// We've received an ad successfully.
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    NSLog(@"Received ad successfully");
    
    float heightOffset = -20;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        heightOffset = 20;
    }
    
    [self updateAdBannerPosition];

    //self.adBanner.center = CGPointMake(ScreenWidth / 2, ScreenHeight - self.adBanner.frame.size.height - heightOffset);
    //[self.view bringSubviewToFront: self.adBanner];
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"Failed to receive ad with error: %@", [error localizedFailureReason]);
    
    //[self performSelector:@selector(retryGetAd) withObject:nil afterDelay:5];
}

#endif

- (void)showSuccessNotification:(NSString *)message
{
    [self showSuccessNotification:message onView:self.view];
}

- (void)showSuccessNotification:(NSString *)message onView:(UIView *)inView
{
    if ((self.isViewLoaded == NO) || (self.view.window == nil))
    {
        return;
    }
    
    if (inView == nil)
    {
        inView = self.view;
    }
    
    [[WBNoticeView defaultManager] showSuccessNoticeInView: inView title:@"" message: message];
}

- (void)showError:(NSString *)errorMessage
{
    [self showError:errorMessage onView:self.view];
}

- (void)showError:(NSString *)errorMessage onView:(UIView *)inView
{
    if ((self.isViewLoaded == NO) || (self.view.window == nil))
    {
        return;
    }
    
    if (inView == nil)
    {
        inView = self.view;
    }
    
    [[WBNoticeView defaultManager] showErrorNoticeInView: inView title:NSLocalizedString(@"Внимание!", nil) message: errorMessage];
}

- (void)addBackButton {
    UIImage* buttonImage = [[NIKFontAwesomeIconFactory barButtonItemIconFactory] createImageForIcon:NIKFontAwesomeIconCircleArrowLeft];
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)goBack:(UIView *)button {
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark - HUD

- (void) showProgressHUD
{
    self.hud.labelText = NSLocalizedString(@"Processing...", nil);
    self.hud.mode = MBProgressHUDModeIndeterminate;

    [self.hud show:YES];
}

- (void) showHUD:(BOOL)animated withText:(NSString *)text
{
    self.hud.labelText = text;
    [self.hud show:YES];
}

- (void) showHUD:(BOOL)animated withText:(NSString *)text onView:(UIView *)aView dimBackground:(BOOL)dimBackg
{
    MBProgressHUD *hudCustom = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    hudCustom.dimBackground = dimBackg;
    hudCustom.customView = aView;
    hudCustom.labelText = text;
    hudCustom.mode = MBProgressHUDModeCustomView;
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    hudCustom.delegate = self;
    hudCustom.tag = CUSTOMVIEW_TAG;
    [self.navigationController.view addSubview:hudCustom];
    [hudCustom show:animated];
}

- (void) showHUDWithText:(NSString *)aTexto whileExecuting:(SEL)method onTarget:(id)target withObject:(id)object animated:(BOOL)animated
{
    self.hud.labelText = aTexto;
    [self.hud showWhileExecuting:method onTarget:target withObject:object animated:animated];
}

- (void) hideHUD
{
    [self.hud hide:YES];
}

- (void) hideHUD:(BOOL)animated
{
    [self.hud hide:animated];
}

- (void) hideHUD:(BOOL)animated afterDelay:(NSTimeInterval)delay
{
    [self.hud hide:animated afterDelay:delay];
}

- (void) hideHUDCustomView:(BOOL)animated afterDelay:(NSTimeInterval)delay
{
    MBProgressHUD *hudCustom = (MBProgressHUD *)[self.navigationController.view viewWithTag:CUSTOMVIEW_TAG];
    [hudCustom hide:animated afterDelay:delay];
    
    [hudCustom performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:delay];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        return UIStatusBarStyleLightContent;
    } else {
        return UIStatusBarStyleDefault;
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
