//
//  FCStoreManager.h
//  Auto-Renewable Subscriptions
//
//  Created by Vasu N on 08/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#define FCStoreManager ThemeLoader
#define fetchProductList fetchThemeList
#define purchaseNonconsumable loadThemeOnce
#define restorePreviousPurchasesForProduct reloadThemeFromDisk
#define checkForPendingTransactions suspendLoadingTheme
#define getProductFullUnlock getCurrentTheme
#define isFullProduct isDefaultTheme
#define PurchaseResponse ThemeLoadResponse
#define sharedStoreManager sharedThemeLoader
#define setIsFullProduct setIsDefaultTheme 

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define kUnlockFullProductNotification @"kDictionaryLoadNotification"

@interface FCStoreManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

typedef void (^PurchaseResponse)(BOOL wasSuccess, SKPaymentTransaction *transaction);

+ (FCStoreManager *)sharedStoreManager;

- (void)fetchProductList;
- (void)purchaseNonconsumable:(SKProduct*)product response:(PurchaseResponse)response;
- (void)restorePreviousPurchasesForProduct:(SKProduct *)product response:(PurchaseResponse)response;
- (void)checkForPendingTransactions;
- (SKProduct*)getProductFullUnlock;

@property (nonatomic) BOOL isFullProduct;
    
@end
