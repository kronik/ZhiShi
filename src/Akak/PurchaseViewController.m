//
//  PurchaseViewController.m
//  beanstalk
//
//  Created by dima on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PurchaseViewController.h"
#import "FCStoreManager.h"
#import "FlatPillButton.h"
#import "UITableView+Toches.h"
#import "UIColor+Colours.h"
#import "UIColor+MLPFlatColors.h"

// Default cell button size
#define BUTTON_SIZE 250

@interface PurchaseViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *menuItems;
@property (strong, nonatomic) NSMutableDictionary *purchaseResults;

@end

@implementation PurchaseViewController

@synthesize tableView = _tableView;
@synthesize menuItems = _menuItems;
@synthesize purchaseResults = _purchaseResults;

- (NSArray*)menuItems
{
    if (_menuItems == nil)
    {
        SKProduct *wordsUnlock = [[FCStoreManager sharedStoreManager] getProductFullWordsUnlock];
        SKProduct *phrasesUnlock = [[FCStoreManager sharedStoreManager] getProductFullPhrasesUnlock];
        SKProduct *noAdvUnlock = [[FCStoreManager sharedStoreManager] getProductNoAdvUnlock];
        SKProduct *cumulativeUnlock = [[FCStoreManager sharedStoreManager] getProductCumulativeUnlock];

        NSString *localizedWordsPrice = [self priceAsString:wordsUnlock.priceLocale Price:wordsUnlock.price];
        NSString *localizedPhrasesPrice = [self priceAsString:phrasesUnlock.priceLocale Price:phrasesUnlock.price];
        NSString *localizedNoAdvPrice = [self priceAsString:noAdvUnlock.priceLocale Price:noAdvUnlock.price];
        NSString *localizedCumulativePrice = [self priceAsString:cumulativeUnlock.priceLocale Price:cumulativeUnlock.price];

        if (localizedWordsPrice == nil) {
            localizedWordsPrice = @"$0.99";
        }
        
        if (localizedPhrasesPrice == nil) {
            localizedPhrasesPrice = @"$0.99";
        }
        
        if (localizedNoAdvPrice == nil) {
            localizedNoAdvPrice = @"$0.99";
        }
        
        if (localizedCumulativePrice == nil) {
            localizedCumulativePrice = @"$1.99";
        }

        _menuItems = @[[NSString stringWithFormat: @"%@ %@", NSLocalizedString(@"3400+ Words", nil), localizedWordsPrice],
                       [NSString stringWithFormat: @"%@ %@", NSLocalizedString(@"1000+ Phrases", nil), localizedPhrasesPrice],
                       [NSString stringWithFormat: @"%@ %@", NSLocalizedString(@"No more Ad", nil), localizedNoAdvPrice],
                       [NSString stringWithFormat: @"%@ %@", NSLocalizedString(@"All in one", nil), localizedCumulativePrice],
                       NSLocalizedString(@"Restore", nil)];
    }
    return  _menuItems;
}

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor black95PercentColor];
    
    float heightOffset = 44;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        heightOffset = 64;
    }

    self.tableView = [[MYTableView alloc] initWithFrame:CGRectMake(0, heightOffset,
                                                                   self.view.frame.size.width,
                                                                   self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor clearColor];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.tableView.contentOffset = CGPointMake(0, 0);
    }

    UIImageView *bgView = [[UIImageView alloc] initWithFrame:self.view.frame];
    bgView.backgroundColor = [UIColor black95PercentColor];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = bgView;
    self.tableView.bounces = NO;
    
    [self.view addSubview:self.tableView];
    
    [self addBackButton];
    
    [self setMainTitle: NSLocalizedString(@"Unlock all features", nil)];

    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.menuItems.count;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellID = @"PurchaseCellID";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    float xPoint = self.tableView.frame.size.width / 2 - BUTTON_SIZE / 2;

	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
        
        cell.accessoryType = UITableViewCellAccessoryNone;        
        cell.textLabel.highlightedTextColor = [UIColor blackColor];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:24.0f];
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.userInteractionEnabled = NO;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
	}
    
//    if (indexPath.row <= self.menuItems.count - 1) {
//        UIImage *buttonImage = [[NIKFontAwesomeIconFactory generalFactory] createImageForIcon:NIKFontAwesomeIconHandRight];
//        cell.imageView.image = buttonImage;
//        cell.textLabel.text = self.menuItems [indexPath.row];
//        cell.textLabel.textAlignment = NSTextAlignmentLeft;
//        cell.userInteractionEnabled = YES;
//        cell.textLabel.numberOfLines = 2;
//    }
//    else
    {
        cell.imageView.image = nil;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.userInteractionEnabled = YES;
        cell.textLabel.text = @"";
        cell.userInteractionEnabled = YES;
        cell.textLabel.numberOfLines = 1;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:26.0f];
        
        FlatPillButton *button = [[FlatPillButton alloc] initWithFrame:CGRectMake(xPoint, 5, BUTTON_SIZE, 50)];
        button.enabled = YES;
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
                
        [button setTitle:self.menuItems [indexPath.row] forState:UIControlStateNormal];
        
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor tealColor] forState:UIControlStateNormal];
        
        switch (indexPath.row) {
            case 0:
                [button addTarget:self action:@selector(purchaseWordsItem) forControlEvents: UIControlEventTouchUpInside];
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0f];
                break;
                
            case 1:
                [button addTarget:self action:@selector(purchasePhrasesItem) forControlEvents: UIControlEventTouchUpInside];
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0f];
                break;
                
            case 2:
                [button setTitleColor:[UIColor blueberryColor] forState:UIControlStateNormal];
                [button addTarget:self action:@selector(purchaseNoAdvItem) forControlEvents: UIControlEventTouchUpInside];
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0f];
                break;
                
            case 3:
                [button setTitleColor:[UIColor flatYellowColor] forState:UIControlStateNormal];
                [button addTarget:self action:@selector(purchaseCumulativeItem) forControlEvents: UIControlEventTouchUpInside];
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:26.0f];
                break;
                
            case 4:
                [button setTitleColor:[UIColor turquoiseColor] forState:UIControlStateNormal];
                [button addTarget:self action:@selector(restoreItems) forControlEvents: UIControlEventTouchUpInside];
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:26.0f];
                break;
                
            default:
                break;
        }
        
        button.titleLabel.font = cell.textLabel.font;
        [cell addSubview: button];        
    }
    
	return cell;
}

- (void)checkPurchaseResults {    
    BOOL allRequestFailed = YES;
    
    for (NSString *key in self.purchaseResults.keyEnumerator) {
        if ([self.purchaseResults [key] integerValue] == 0) {
            return;
        }
        
        if ([self.purchaseResults [key] integerValue] == 1) {
            allRequestFailed = NO;
        }
    }
    
    [self hideHUD: YES];

    if (allRequestFailed == NO) {
        [self showSuccessNotification:NSLocalizedString(@"Success!", nil) onView:self.tableView];
        [self performSelector:@selector(goBack:) withObject:self afterDelay:1.5];
    } else {
        [self showError:NSLocalizedString(@"Operation failed!", nil) onView:self.tableView];
    }
}

- (void)restoreItems {
    [Flurry logEvent:@"TapOnRestoreUnlock"];
    
    SKProduct *wordsUnlock = [[FCStoreManager sharedStoreManager] getProductFullWordsUnlock];
    SKProduct *phrasesUnlock = [[FCStoreManager sharedStoreManager] getProductFullPhrasesUnlock];
    SKProduct *noAdvUnlock = [[FCStoreManager sharedStoreManager] getProductNoAdvUnlock];
    SKProduct *cumulativeUnlock = [[FCStoreManager sharedStoreManager] getProductCumulativeUnlock];
    
    if ((wordsUnlock == nil) || (phrasesUnlock == nil) || (noAdvUnlock == nil) || (cumulativeUnlock == nil)) {
        [self showError:NSLocalizedString(@"Operation failed!", nil) onView:self.tableView];
        return;
    }
    
    [self showProgressHUD];
    
    _purchaseResults = [@{wordsUnlock.productIdentifier : [NSNumber numberWithInt: 0],
                         phrasesUnlock.productIdentifier : [NSNumber numberWithInt: 0],
                         noAdvUnlock.productIdentifier : [NSNumber numberWithInt: 0],
                         cumulativeUnlock.productIdentifier : [NSNumber numberWithInt: 0]} mutableCopy];

    __weak PurchaseViewController *weakRef = self;
    
    [[FCStoreManager sharedStoreManager] restorePreviousPurchasesForProduct:wordsUnlock
                                                               response:^(BOOL wasSuccess, SKPaymentTransaction *transaction) {
                                                                   @synchronized (weakRef) {
                                                                       weakRef.purchaseResults [wordsUnlock.productIdentifier] = [NSNumber numberWithInt: wasSuccess ? 1 : 2];
                                                                       [weakRef checkPurchaseResults];
                                                                   }
                                                               }];
    
    [[FCStoreManager sharedStoreManager] restorePreviousPurchasesForProduct:phrasesUnlock
                                                                   response:^(BOOL wasSuccess, SKPaymentTransaction *transaction) {
                                                                       @synchronized (weakRef) {
                                                                           weakRef.purchaseResults [phrasesUnlock.productIdentifier] = [NSNumber numberWithInt: wasSuccess ? 1 : 2];
                                                                           [weakRef checkPurchaseResults];
                                                                       }
                                                                   }];
    
    [[FCStoreManager sharedStoreManager] restorePreviousPurchasesForProduct:noAdvUnlock
                                                                   response:^(BOOL wasSuccess, SKPaymentTransaction *transaction) {
                                                                       @synchronized (weakRef) {
                                                                           weakRef.purchaseResults [noAdvUnlock.productIdentifier] = [NSNumber numberWithInt: wasSuccess ? 1 : 2];
                                                                           [weakRef checkPurchaseResults];
                                                                       }
                                                                   }];
    
    [[FCStoreManager sharedStoreManager] restorePreviousPurchasesForProduct:cumulativeUnlock
                                                                   response:^(BOOL wasSuccess, SKPaymentTransaction *transaction) {
                                                                       @synchronized (weakRef) {
                                                                           weakRef.purchaseResults [cumulativeUnlock.productIdentifier] = [NSNumber numberWithInt: wasSuccess ? 1 : 2];
                                                                           [weakRef checkPurchaseResults];
                                                                       }
                                                                   }];
}

- (void)purchaseWordsItem {
    
    [Flurry logEvent:@"TapOnPurchaseWordsUnlock"];

    SKProduct *wordsUnlock = [[FCStoreManager sharedStoreManager] getProductFullWordsUnlock];

    [self purchaseItem:wordsUnlock];
}

- (void)purchasePhrasesItem {
    
    [Flurry logEvent:@"TapOnPurchasePhrasesUnlock"];

    SKProduct *phrasesUnlock = [[FCStoreManager sharedStoreManager] getProductFullPhrasesUnlock];
    
    [self purchaseItem:phrasesUnlock];
}

- (void)purchaseNoAdvItem {
    
    [Flurry logEvent:@"TapOnPurchaseNoAdvUnlock"];

    SKProduct *noAdvUnlock = [[FCStoreManager sharedStoreManager] getProductNoAdvUnlock];
    
    [self purchaseItem:noAdvUnlock];
}

- (void)purchaseCumulativeItem {

    [Flurry logEvent:@"TapOnPurchaseCumulativeUnlock"];

    SKProduct *cumulativeUnlock = [[FCStoreManager sharedStoreManager] getProductCumulativeUnlock];
    
    [self purchaseItem:cumulativeUnlock];
}

- (void)purchaseItem: (SKProduct *)itemToPurchase {
        
    if (itemToPurchase == nil) {
        [self showError:NSLocalizedString(@"Operation failed!", nil) onView:self.tableView];
        return;
    }
    
    [self showProgressHUD];

    [[FCStoreManager sharedStoreManager] purchaseNonconsumable:itemToPurchase
                                                      response:^(BOOL wasSuccess, SKPaymentTransaction *transaction) {

                                                          [self hideHUD: YES];

                                                          if (wasSuccess) {
                                                              [self showSuccessNotification:NSLocalizedString(@"Success!", nil) onView:self.tableView];
                                                              [self performSelector:@selector(goBack:) withObject:self afterDelay:1.5];
                                                          } else {
                                                              [self showError:NSLocalizedString(@"Operation failed!", nil) onView:self.tableView];
                                                          }
                                                      }];
}

- (NSString *) priceAsString:(NSLocale *)localprice Price:(NSDecimalNumber *)price{
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setLocale:localprice];
    
    NSString *str = [formatter stringFromNumber:price];
    return str;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

@end
