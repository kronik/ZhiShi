//
//  MainViewController.h
//  Akak
//
//  Created by dima on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreData/CoreData.h>
#import "OnlineDictViewController.h"
#import "AboutViewController.h"
#import "DictSearcher.h"
#import <iAd/iAd.h>
#import <UIKit/UIResponder.h>
#import "iPhone-Speech-To-Text/SpeechToTextModule.h"
#import "OtherAppsViewController.h"

#import "AppDelegate.h"
#import "Reachability.h"

#ifdef LITE_VERSION

#import "AdWhirlDelegateProtocol.h"
@class AdWhirlView;

@interface MainViewController : UIViewController <OnlineDictViewControllerDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, DictSearcherDelegate, ADBannerViewDelegate, UIAlertViewDelegate, AdWhirlDelegate, AboutViewControllerDelegate, SpeechToTextModuleDelegate, OtherAppsViewControllerDelegate>
{
    AdWhirlView *adView;
}

#else

@interface MainViewController : UIViewController <OnlineDictViewControllerDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, DictSearcherDelegate, ADBannerViewDelegate, UIAlertViewDelegate, AboutViewControllerDelegate, SpeechToTextModuleDelegate, OtherAppsViewControllerDelegate>

#endif

@property (assign,nonatomic) IBOutlet UISearchBar *searchBar;
@property (assign,nonatomic) IBOutlet UITableView *tableView;
@property (assign,nonatomic) IBOutlet UIProgressView *progressView;
@property (assign,nonatomic) IBOutlet ADBannerView *bannerView;
@property (assign,nonatomic) IBOutlet UIButton *cancelButton;
@property (assign,nonatomic) IBOutlet UIButton *showRulesButton;
@property (assign,nonatomic) IBOutlet UIButton *recognizeButton;

#ifdef LITE_VERSION
@property (strong, nonatomic) AdWhirlView *adView;
#endif
//@property (strong, nonatomic) NSManagedObjectContext *managedObjectContextRu;
//@property (strong, nonatomic) NSManagedObjectContext *managedObjectContextEn;

- (IBAction)searchBarCustomCancelButtonClicked: (UIButton*)button;
- (IBAction)showRulesButtonClicked: (UIButton*)button;
- (IBAction)onRecognize:(UIButton*)sender;
- (IBAction)showAbout:(UIButton*)sender;

@property (assign,nonatomic) IBOutlet UIView *myAdView;
- (IBAction)buyFullVerButtonClicked: (UIButton*)button;

-(void)startToBuildIndex;

#ifdef LITE_VERSION
- (void)adjustAdSize;
#endif
@end
