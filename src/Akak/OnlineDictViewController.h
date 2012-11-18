//
//  OnlineDictViewController.h
//  Akak
//
//  Created by dima on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <iAd/iAd.h>

#ifdef LITE_VERSION
#import "AdWhirlDelegateProtocol.h"
@class AdWhirlView;
#endif

@class OnlineDictViewController;

@protocol OnlineDictViewControllerDelegate
- (void)onlineDictViewControllerDidFinish:(OnlineDictViewController *)controller;
@end

@interface OnlineDictViewController : UIViewController<UIWebViewDelegate, UIAlertViewDelegate, ADBannerViewDelegate
#ifdef LITE_VERSION
,AdWhirlDelegate>
{
    AdWhirlView *adView;
}
#else
>
#endif

@property (assign, nonatomic) IBOutlet id <OnlineDictViewControllerDelegate> delegate;
@property (assign, nonatomic) IBOutlet UIWebView *webView;
@property (assign, nonatomic) IBOutlet ADBannerView *bannerView;

@property (strong, nonatomic) UIActivityIndicatorView *av;
@property (strong, nonatomic) NSString *word;
@property (strong, nonatomic) NSString *localHtml;
@property (strong, nonatomic) NSString *searchURL;
@property (strong, nonatomic) NSString *header;
@property (nonatomic) BOOL bannerIsVisible;

#ifdef LITE_VERSION
@property (strong, nonatomic) AdWhirlView *adView;
#endif

@property (assign,nonatomic) IBOutlet UIView *myAdView;
- (IBAction)buyFullVerButtonClicked: (UIButton*)button;

- (IBAction)done:(id)sender;

#ifdef LITE_VERSION
- (void)adjustAdSize;
#endif

@end
