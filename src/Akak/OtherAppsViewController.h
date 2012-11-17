//
//  OtherAppsViewController.h
//  MyApps
//
//  Created by dima on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OtherAppsViewController;

@protocol OtherAppsViewControllerDelegate
- (void)otherAppsViewControllerDidFinish:(OtherAppsViewController *)controller;
@end

@interface OtherAppsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (assign, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) IBOutlet UINavigationItem *navBar;
@property (assign, nonatomic) IBOutlet id <OtherAppsViewControllerDelegate> delegate;
- (IBAction)done:(id)sender;

@end
