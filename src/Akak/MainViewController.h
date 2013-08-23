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
#import <UIKit/UIResponder.h>
#import "iPhone-Speech-To-Text/SpeechToTextModule.h"
#import "OtherAppsViewController.h"
#import "BasicViewController.h"
#import "AppDelegate.h"
#import "Reachability.h"

@interface MainViewController : BasicViewController <OnlineDictViewControllerDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, DictSearcherDelegate, UIAlertViewDelegate, AboutViewControllerDelegate, SpeechToTextModuleDelegate, OtherAppsViewControllerDelegate>

@property (assign,nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dictionaryRu;

- (IBAction)searchBarCustomCancelButtonClicked: (UIButton*)button;
- (IBAction)showRulesButtonClicked: (UIButton*)button;
- (IBAction)onRecognize:(UIButton*)sender;
- (IBAction)showAbout:(UIButton*)sender;

- (IBAction)buyFullVerButtonClicked: (UIButton*)button;

-(void)startToBuildIndex;

@end
