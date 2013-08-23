//
//  OnlineDictViewController.h
//  Akak
//
//  Created by dima on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "BasicViewController.h"

@class OnlineDictViewController;

@protocol OnlineDictViewControllerDelegate
- (void)onlineDictViewControllerDidFinish:(OnlineDictViewController *)controller;
@end

@interface OnlineDictViewController : BasicViewController <UIWebViewDelegate, UIAlertViewDelegate>

@property (assign, nonatomic) IBOutlet id <OnlineDictViewControllerDelegate> delegate;
@property (assign, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) UIActivityIndicatorView *av;
@property (strong, nonatomic) NSString *word;
@property (strong, nonatomic) NSString *localHtml;
@property (strong, nonatomic) NSString *searchURL;
@property (strong, nonatomic) NSString *header;

- (IBAction)buyFullVerButtonClicked: (UIButton*)button;
- (IBAction)done:(id)sender;

@end
