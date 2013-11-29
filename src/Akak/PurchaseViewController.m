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
        SKProduct *appUnlock = [[FCStoreManager sharedStoreManager] getProductFullUnlock];

        NSString *localizedPrice = [self priceAsString:appUnlock.priceLocale Price:appUnlock.price];

        if (localizedPrice == nil) {
            localizedPrice = @"$0.99";
        }
        
        _menuItems = @[@"", @"Без рекламы", @"+ Локальный словарь", @"+ Расширенная игра", @"",
                       [NSString stringWithFormat: @"%@ %@", NSLocalizedString(@"Купить за", nil), localizedPrice],
                       NSLocalizedString(@"Восстановить покупки", nil)];
    }
    return  _menuItems;
}

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor black95PercentColor];
    
    float heightOffset = 0;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        heightOffset = 0;
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
    
    [self setMainTitle: NSLocalizedString(@"Полная версия Жи-Ши", nil)];

    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
    
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Flurry logEvent:@"ViewPurchaseOptions"];
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
            case 1:
            case 2:
            case 3:
            case 4:
            {
                cell.textLabel.textColor = [UIColor colorWithRed:0.18f green:0.39f blue:0.59f alpha:1.00f];
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f];
                cell.textLabel.textAlignment = NSTextAlignmentLeft;
                cell.textLabel.text = self.menuItems [indexPath.row];
                button = nil;
            }
                break;
            
            case 5:
                [button setTitleColor:[UIColor blueberryColor] forState:UIControlStateNormal];
                [button addTarget:self action:@selector(purchaseAppItem) forControlEvents: UIControlEventTouchUpInside];
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0f];
                break;
                
            case 6:
                [button setTitleColor:[UIColor blueberryColor] forState:UIControlStateNormal];
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
        [self showSuccessNotification:NSLocalizedString(@"Готово!", nil) onView:self.tableView];
        [self performSelector:@selector(goBack:) withObject:self afterDelay:1.5];
    } else {
        [self showError:NSLocalizedString(@"Произошла ошибка!", nil) onView:self.tableView];
    }
}

- (void)restoreItems {
    [Flurry logEvent:@"TapOnRestoreUnlock"];
    
    SKProduct *appUnlock = [[FCStoreManager sharedStoreManager] getProductFullUnlock];
    
    if (appUnlock == nil) {
        [self showError:NSLocalizedString(@"Произошла ошибка!", nil) onView:self.tableView];
        return;
    }
    
    [self showProgressHUD];
    
    _purchaseResults = [@{appUnlock.productIdentifier : [NSNumber numberWithInt: 0]} mutableCopy];

    __weak PurchaseViewController *weakRef = self;
    
    [[FCStoreManager sharedStoreManager] restorePreviousPurchasesForProduct:appUnlock
                                                               response:^(BOOL wasSuccess, SKPaymentTransaction *transaction) {
                                                                   @synchronized (weakRef) {
                                                                       weakRef.purchaseResults [appUnlock.productIdentifier] = [NSNumber numberWithInt: wasSuccess ? 1 : 2];
                                                                       [weakRef checkPurchaseResults];
                                                                   }
                                                               }];
}

- (void)purchaseAppItem {
    
    [Flurry logEvent:@"TapOnPurchaseAppUnlock"];

    SKProduct *appUnlock = [[FCStoreManager sharedStoreManager] getProductFullUnlock];

    [self purchaseItem:appUnlock];
}

- (void)purchaseItem: (SKProduct *)itemToPurchase {
        
    if (itemToPurchase == nil) {
        [self showError:NSLocalizedString(@"Произошла ошибка!", nil) onView:self.tableView];
        return;
    }
    
    [self showProgressHUD];

    [[FCStoreManager sharedStoreManager] purchaseNonconsumable:itemToPurchase
                                                      response:^(BOOL wasSuccess, SKPaymentTransaction *transaction) {

                                                          [self hideHUD: YES];

                                                          if (wasSuccess) {
                                                              [self showSuccessNotification:NSLocalizedString(@"Готово!", nil) onView:self.tableView];
                                                              [self performSelector:@selector(goBack:) withObject:self afterDelay:1.5];
                                                          } else {
                                                              [self showError:NSLocalizedString(@"Произошла ошибка!", nil) onView:self.tableView];
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
    if (indexPath.row < 5) {
        return 40.0;
    } else {
        return 60.0;
    }
}

@end
