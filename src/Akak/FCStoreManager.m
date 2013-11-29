//
//  FCStoreManager.m
//  Auto-Renewable Subscriptions
//
//  Created by Vasu N on 08/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FCStoreManager.h"
#import "NSData+MKBase64.h"
#import "Flurry.h"

#define kProductFullUnlock @"fullappunlock"

#define verifyReceipt resetCurrentTheme
#define restorePurchasedForProduct restoreDefaultBundleTheme
#define removeTransaction resetDraw
#define kProductItemID @"741599423"

NSString *const kTransactionID	= @"Transaction ID";
NSString *const kTransactionReceipt = @"Transaction Receipt";

@interface FCStoreManager () {
    PurchaseResponse restorePurchaseResponse;
}

@property (nonatomic, strong) NSMutableDictionary *productById;
@property (nonatomic, strong) NSMutableDictionary *responseByProductId;

@end

@implementation FCStoreManager

@synthesize productById = _productById;
@synthesize responseByProductId = _responseByProductId;

- (id) init
{
	self = [super init];

	if (self != nil)
	{
        [self fetchProductList];
	}
	return self;
}

+ (FCStoreManager *)sharedStoreManager
{
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static FCStoreManager *_sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[FCStoreManager alloc] init];
    });
    
    // returns the same object each time
    return _sharedObject;
}

- (void) fetchProductList {
    
    if ((self.productById == nil) || ([[self.productById allKeys] count] == 0)) {

        self.responseByProductId = [[NSMutableDictionary alloc] init];
        
        NSSet *set = [NSSet setWithObjects: kProductFullUnlock, nil];
        
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
        request.delegate = self;
        [request start];
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
}

- (void)purchaseNonconsumable:(SKProduct*)product response:(PurchaseResponse)response
{
    [self purchase:product response:^(BOOL wasSuccess, SKPaymentTransaction *transaction)
    {        
        if (wasSuccess) {
            wasSuccess = [self verifyReceipt:transaction.transactionReceipt];
            
            if (wasSuccess) {
                [Flurry logEvent:@"SuccessValidPurchase"];
                NSLog(@"Successfully purchased full app unlock");
                
                if ([product.productIdentifier isEqualToString:kProductFullUnlock]) {
                    [self setIsFullProduct: YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName: kUnlockFullProductNotification object: self];
                }
                
                [self saveTransaction: transaction];
            } else {
                [Flurry logEvent:@"RejectedInvalidPurchase"];
                NSLog(@"Unsuccessfully purchased full app unlock");
            }
        }
        
        if (response) {
            response(wasSuccess, transaction);
        }
    }];
}

- (void) restorePreviousPurchasesForProduct:(SKProduct *)product response:(PurchaseResponse)response
{    
    [self restorePurchasedForProduct:product response:^(BOOL wasSuccess, SKPaymentTransaction *transaction)
    {
        if (wasSuccess) {
            wasSuccess = [self verifyReceipt:transaction.transactionReceipt];
            
            if (wasSuccess) {
                [Flurry logEvent:@"SuccessValidRestorePurchase"];
                NSLog(@"Successfully restored full app unlock");
                
                if ([product.productIdentifier isEqualToString:kProductFullUnlock]) {
                    [self setIsFullProduct: YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName: kUnlockFullProductNotification object: self];
                }
                                
                [self saveTransaction: transaction];
            } else {
                [Flurry logEvent:@"RejectedInvalidRestorePurchase"];
                NSLog(@"Unsuccessfully restored full app unlock");
            }
        }
        
        if (response) {
            response(wasSuccess, transaction);
        }
    }];
}
    
- (void)setIsFullProduct:(BOOL)isFullProduct {
    [[NSUserDefaults standardUserDefaults] setBool:isFullProduct forKey:kProductFullUnlock];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
    
- (BOOL)isFullProduct {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kProductFullUnlock];
}

- (void)restorePurchasedForProduct:(SKProduct *)product response:(PurchaseResponse)response
{
    if (product == nil) {
        response(NO, nil);
        return;
    }

    restorePurchaseResponse = response;
    [self.responseByProductId setObject:[response copy] forKey:product.productIdentifier];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)purchase:(SKProduct*)product response:(PurchaseResponse)response
{
    if (product == nil) {
        response(NO, nil);
        return;
    }
    
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [self.responseByProductId setObject:[response copy] forKey:product.productIdentifier];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (SKProduct*)getProductFullUnlock
{
    if (self.productById != nil)
    {
        return [self.productById objectForKey:kProductFullUnlock];
    }
    return nil;
}

- (void)checkForPendingTransactions
{
    // Hard code productId to "6monthpack01" because that is the only productId the server understands
//    NSString *fakeProductId = nil;
//    
//#ifdef TEST_SERVER
//
//#if (SAUDI_ARABIA_IN_APP_ENABLED == 1)
//    if([user.countryCode isEqualToString:@"SA"])
//    {
//        fakeProductId = @"TEST_1monthpack01";
//    }
//    else
//    {
//        fakeProductId = @"TEST_6monthpack01";
//    }
//#else
//    fakeProductId = @"TEST_6monthpack01";
//#endif
//    
//#else
//
//#if (SAUDI_ARABIA_IN_APP_ENABLED == 1)
//    if([user.countryCode isEqualToString:@"SA"])
//    {
//        fakeProductId = @"1monthpack01";
//    }
//    else
//    {
//        fakeProductId = @"6monthpack01";
//    }
//#else
//    fakeProductId = @"6monthpack01";
//#endif
//
//#endif
//    
//    NSString *receipt;
//    NSString *transactionId;
//    NSString *productId;
//    static bool isSubscribing = false;
//    if (!isSubscribing && [self getTransactionForUser:user transactionId:&transactionId receipt:&receipt productId:&productId])
//    {
//        isSubscribing = true;
//        [[BMMkManager sharedInstance] subscriptionToProduct:fakeProductId transactionReceipt:receipt onCompletion:^(BMFullProfile *profile, NSDictionary *settings)
//        {
//            [BMBubblyEngine.defaultBubblyEngine setLoggedInUser:profile settings:settings];
//            [self removeTransaction:transactionId forUser:user];
//            [self checkForPendingTransactions:user];
//            
//            [[NSNotificationCenter defaultCenter] postNotificationName: BMBubblyEngineSubscriptionPurchaseSuccessNotification object: self];
//
//            isSubscribing = false;
//        } onError:^(NSError *error)
//        {
//            isSubscribing = false;
//        }];
//    }
}

+ (NSString *)documentsDirectory
{
	static NSString *documentsDirectory= nil;
	if(! documentsDirectory) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		documentsDirectory = [paths objectAtIndex:0];
	}
	return documentsDirectory;
}

+ (NSString *)inAppPurcahseTransactionFolder
{
	return [NSString stringWithFormat:@"%@/%@", [[self class] documentsDirectory], @"Transaction"];
}

- (BOOL)saveTransaction:(SKPaymentTransaction *)transaction
{
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          [transaction.transactionReceipt base64EncodedString], kTransactionReceipt,
                          transaction.transactionIdentifier, kTransactionID,
                          transaction.payment.productIdentifier, @"product_id", nil];
    
    NSString *directory = [[[self class] inAppPurcahseTransactionFolder] stringByAppendingPathComponent:@"0"];
    BOOL isDir = YES;

    if ((NO == [[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:&isDir]) || (NO == isDir))
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *filePath = [directory stringByAppendingPathComponent:[NSString stringWithFormat:@"receipt_%@.plist", transaction.transactionIdentifier]];
    
    return [data writeToFile:filePath atomically:NO];
}

- (BOOL)getTransaction: (NSString**)transactionId receipt:(NSString**)receipt productId:(NSString**)productId
{
    NSString *directory = [[[self class] inAppPurcahseTransactionFolder] stringByAppendingPathComponent:@"0"];
	NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:nil];
    
    for (int i = 0; i < files.count; i++)
    {
        NSString *fileName = [files objectAtIndex:i];
        NSString *filePath = [directory stringByAppendingPathComponent:fileName];
        NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:filePath];
        
        if (data != nil)
        {
            *receipt = [data objectForKey:kTransactionReceipt];
            *productId = [data objectForKey:@"product_id"];
            *transactionId = [data objectForKey:kTransactionID];
            
            if (*receipt && *productId && *transactionId)
            {
                NSString *correctFileName = [NSString stringWithFormat:@"theme_settings_%@.plist", *transactionId];
            
                if ([fileName isEqualToString:correctFileName])
                {
                    return YES;
                }
            }
        }
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    return NO;
}

- (void)removeTransaction:(NSString *)transactionId
{
    NSString *directory = [[[self class] inAppPurcahseTransactionFolder] stringByAppendingPathComponent:@"0"];
    NSString *filePath = [directory stringByAppendingPathComponent:[NSString stringWithFormat:@"theme_settings_%@.plist", transactionId]];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	for (SKPaymentTransaction *transaction in transactions)
	{
		switch (transaction.transactionState)
		{
            case SKPaymentTransactionStatePurchasing:
                break;
                
			case SKPaymentTransactionStatePurchased:
            {
                PurchaseResponse response = [self.responseByProductId objectForKey:transaction.payment.productIdentifier];
                if (response) {
                    [self.responseByProductId removeObjectForKey:transaction.payment.productIdentifier];
                    response(YES, transaction);
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            }
                break;
				
            case SKPaymentTransactionStateFailed:
            {
                PurchaseResponse response = [self.responseByProductId objectForKey:transaction.payment.productIdentifier];
                if (response) {
                    [self.responseByProductId removeObjectForKey:transaction.payment.productIdentifier];
                    response(NO, transaction);
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            }
                break;
				
            case SKPaymentTransactionStateRestored:
            {
                PurchaseResponse response = [self.responseByProductId objectForKey:transaction.payment.productIdentifier];
                if (response) {
                    [self.responseByProductId removeObjectForKey:transaction.payment.productIdentifier];
                    response(YES, transaction);
                }
                
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            }
                break;
		}
	}
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"Error restored filters");
    
    if (restorePurchaseResponse) {
        restorePurchaseResponse(NO, nil);
    }
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    self.productById = [[NSMutableDictionary alloc] init];
    
    for (SKProduct *product in response.products)
    {
        [self.productById setObject:product forKey:product.productIdentifier];
    }
    
	NSLog(@"Invalid Products = %@", response.invalidProductIdentifiers);
}

- (BOOL)verifyReceipt:(NSData*)receiptData {

#ifdef DEBUG
    NSURL *url = [NSURL URLWithString: @"https://sandbox.itunes.apple.com/verifyReceipt"];
#else
    NSURL *url = [NSURL URLWithString: @"https://buy.itunes.apple.com/verifyReceipt"];
#endif
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *st =  [receiptData base64EncodedString];
    NSString *json = [NSString stringWithFormat:@"{\"receipt-data\":\"%@\"}", st];
    
    [theRequest setHTTPBody:[json dataUsingEncoding:NSUTF8StringEncoding]];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];    
    [theRequest setValue:[NSString stringWithFormat:@"%d", json.length] forHTTPHeaderField:@"Content-Length"];
    
    NSHTTPURLResponse* urlResponse = nil;
    NSError *error = nil;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:theRequest
                                                 returningResponse:&urlResponse
                                                             error:&error];
    if(error != nil || responseData == nil) return NO;
    
    error = nil;
    
    id returnValue = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
    
    if(error){
        NSLog(@"JSON Parsing Error: %@", error);
        return NO;
    }
    
    NSDictionary *dic = returnValue;
    NSInteger status = [[dic objectForKey:@"status"] intValue];
    NSDictionary *receiptDic = [dic objectForKey:@"receipt"];
    BOOL retVal = NO;
   
    if (status == 0 && receiptDic != nil) {
        NSString *itemId = [receiptDic objectForKey:@"item_id"];
        NSString *productId = [receiptDic objectForKey:@"product_id"];
        
        if (productId && ([productId isEqualToString:kProductFullUnlock])) {
            if (itemId && ([itemId isEqualToString:kProductItemID])) {
                retVal = YES;
            }
        }
    }
    return retVal;
}

@end
