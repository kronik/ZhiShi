//
//  AboutViewController.h
//  witrapp.ru
//
//  Created by kronik on 5/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AboutViewController;

@protocol AboutViewControllerDelegate
- (void)aboutViewControllerDidFinish:(AboutViewController *)controller;
@end

@interface AboutViewController : UIViewController

@property (assign, nonatomic) IBOutlet id <AboutViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
