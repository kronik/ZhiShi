//
//  AppDelegate.m
//  Akak
//
//  Created by dima on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "MainViewController.h"
#import "iRate.h"
#import "Resources.h"
#import "GameViewController.h"
#import "RulesSearcherViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MyReachability.h"

#define CUSTOMVIEW_TAG 12345

NSString *const FBSessionStateChangedNotification = @"com.example.Login:FBSessionStateChangedNotification";

static BOOL L0AccelerationIsShaking(UIAcceleration* last, UIAcceleration* current, double threshold)
{
	double
    deltaX = fabs(last.x - current.x),
    deltaY = fabs(last.y - current.y),
    deltaZ = fabs(last.z - current.z);
    
	return
    (deltaX > threshold && deltaY > threshold) ||
    (deltaX > threshold && deltaZ > threshold) ||
    (deltaY > threshold && deltaZ > threshold);
}

@implementation AppDelegate

@synthesize lastAcceleration = _lastAcceleration;

@synthesize window = _window;
@synthesize session = _session;

//@synthesize managedObjectContextRu = __managedObjectContextRu;
//@synthesize managedObjectContextEn = __managedObjectContextEn;
//@synthesize managedObjectModelRu = __managedObjectModelRu;
//@synthesize managedObjectModelEn = __managedObjectModelEn;
//
//@synthesize persistentStoreCoordinatorRu = __persistentStoreCoordinatorRu;
//@synthesize persistentStoreCoordinatorEn = __persistentStoreCoordinatorEn;

@synthesize mainViewController = _mainViewController;

+ (AppDelegate *)appDelegate 
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

#if 1
+ (void)initialize
{
    //configure iRate
    [iRate sharedInstance].appStoreID = APPSTOREID;// App Id
    [iRate sharedInstance].applicationName = APPLICATION_NAME;
    [iRate sharedInstance].messageTitle = LIKE_THIS_APP;
    [iRate sharedInstance].message = PLEASE_RATE_APP;
    [iRate sharedInstance].rateButtonLabel = RATE_TXT;
    [iRate sharedInstance].cancelButtonLabel = NO_LATER_TXT;
    [iRate sharedInstance].remindButtonLabel = DO_LATER_TXT;
    [iRate sharedInstance].daysUntilPrompt = 1;
    [iRate sharedInstance].usesUntilPrompt = 3;
    [iRate sharedInstance].remindPeriod = 3;
}
#endif

- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    
	if (self.lastAcceleration)
    {
		if (!histeresisExcited && L0AccelerationIsShaking(self.lastAcceleration, acceleration, 0.7))
        {
			histeresisExcited = YES;
            
			/* SHAKE DETECTED. DO HERE WHAT YOU WANT. */
            [[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATION_SHAKE_DETECTED object: nil];
		}
        else if (histeresisExcited && !L0AccelerationIsShaking(self.lastAcceleration, acceleration, 0.2))
        {
			histeresisExcited = NO;
		}
	}
    
	self.lastAcceleration = acceleration;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // http://stackoverflow.com/questions/1725881/unknown-class-myclass-in-interface-builder-file-error-at-runtime
    [FBProfilePictureView class];

    // check for internet connection
    self.internetReachable = [MyReachability reachabilityForInternetConnection];
    
    [UIAccelerometer sharedAccelerometer].delegate = self;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"ipad-menubar-right"] forBarMetrics:UIBarMetricsDefault];
    //[[UINavigationBar appearance] setBackgroundColor: [UIColor clearColor]];
    [[UINavigationBar appearance] setTintColor: [UIColor blueColor]];

    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0], UITextAttributeTextColor, [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],UITextAttributeTextShadowColor, [NSValue valueWithUIOffset:UIOffsetMake(0, -1)], UITextAttributeTextShadowOffset, nil]];
    // Override point for customization after application launch.
    
#if LITE_VER == 0
    self.mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController_iPhone" bundle:nil];
#else
    self.mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController_iPhone_lite" bundle:nil];
#endif
    
    [self.mainViewController startToBuildIndex];

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.mainViewController];
    self.window.rootViewController = navController;
    
    // add the HUD
    hud = [[MBProgressHUD alloc] initWithView:navController.view];
    hud.dimBackground = NO;
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    hud.delegate = self;
    [navController.view addSubview:hud];
    
    
//    PaperFoldNavigationController *paperFoldNavController = [[PaperFoldNavigationController alloc] initWithRootViewController:navController];
//
//    self.window.rootViewController = paperFoldNavController;
//
//    GameViewController *leftViewController = [[GameViewController alloc] init];
//    leftViewController.ruWords = self.mainViewController.dictionaryRu;
//    [leftViewController addBackButton];
//
//    UINavigationController *leftNavController = [[UINavigationController alloc] initWithRootViewController:leftViewController];
//    [leftNavController setNavigationBarHidden:NO];
//    [paperFoldNavController setLeftViewController:leftNavController width: ScreenWidth];
//    
//    RulesSearcherViewController *searchRulesController = [[RulesSearcherViewController alloc] init];
//    searchRulesController.sendNotifications = YES;
//
//    [searchRulesController addBackButton];
//    UINavigationController *rightNavController = [[UINavigationController alloc] initWithRootViewController:searchRulesController];
//    [rightNavController setNavigationBarHidden:NO];
//    [paperFoldNavController setRightViewController:rightNavController width:ScreenWidth rightViewFoldCount:3 rightViewPullFactor:0.9];
    
//    NSError *error = nil;
//    AVAudioSession *session = [AVAudioSession sharedInstance];
//    
//    [session setCategory: AVAudioSessionCategorySoloAmbient error: &error];
//    
//    if (error != nil)
//    {
//        NSLog(@"Failed to set category on AVAudioSession");
//    }
//    
//    BOOL active = [session setActive: YES error: nil];
//    
//    if (!active)
//    {
//        NSLog(@"Failed to set category on AVAudioSession");
//    }
    
//    if (![self openSessionWithAllowLoginUI:NO])
//    {
//        // No? Display the login page.
//        //[self openSessionWithAllowLoginUI: YES];
//    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

+ (NSString *)FBErrorCodeDescription:(FBErrorCode) code {
    switch(code){
        case FBErrorInvalid :{
            return @"FBErrorInvalid";
        }
        case FBErrorOperationCancelled:{
            return @"FBErrorOperationCancelled";
        }
        case FBErrorLoginFailedOrCancelled:{
            return @"FBErrorLoginFailedOrCancelled";
        }
        case FBErrorRequestConnectionApi:{
            return @"FBErrorRequestConnectionApi";
        }case FBErrorProtocolMismatch:{
            return @"FBErrorProtocolMismatch";
        }
        case FBErrorHTTPError:{
            return @"FBErrorHTTPError";
        }
        case FBErrorNonTextMimeTypeReturned:{
            return @"FBErrorNonTextMimeTypeReturned";
        }
        case FBErrorNativeDialog:{
            return @"FBErrorNativeDialog";
        }
        default:
            return @"[Unknown]";
    }
}

//- (void)sessionStateChanged:(FBSession *)session
//                      state:(FBSessionState) state
//                      error:(NSError *)error
//{
//    switch (state) {
//        case FBSessionStateOpen:
//        {
//            if (!error)
//            {
//                // We have a valid session
//                NSLog(@"User session found");
//            }
//            
//            FBCacheDescriptor *cacheDescriptor = [FBFriendPickerViewController cacheDescriptor];
//            [cacheDescriptor prefetchAndCacheForSession:session];
//        }
//            
//            break;
//        case FBSessionStateClosed:
//        case FBSessionStateClosedLoginFailed:
//            [FBSession.activeSession closeAndClearTokenInformation];
//            break;
//        default:
//            break;
//    }
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:FBSessionStateChangedNotification object:session];
//    
//    if (error) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Error: %@",
//                                                                     [AppDelegate FBErrorCodeDescription:error.code]]
//                                                            message:error.localizedDescription
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//        [alertView show];
//    }
//}

/*
 * Opens a Facebook session and optionally shows the login UX.
 */
//- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI
//{
//    return [FBSession openActiveSessionWithReadPermissions:nil
//                                              allowLoginUI:allowLoginUI
//                                         completionHandler:^(FBSession *session, FBSessionState state, NSError *error)
//                                         {
//                                             [self sessionStateChanged:session state:state error:error];
//                                         }];
//}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBSession.activeSession handleOpenURL:url];
}

- (BOOL)disablesAutomaticKeyboardDismissal
{
    return NO;
}

// called after network status changes
- (void) checkNetworkStatus
{
    NetworkStatus internetStatus = [self.internetReachable currentReachabilityStatus];
    
    switch (internetStatus)
    {
        case NotReachable:
        {
            NSLog(@"The internet is down.");
            self.hayInternet = NO;
            
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"The internet is working via WIFI.");
            self.hayInternet = YES;
            
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"The internet is working via WWAN.");
            // muestro un mensaje el label de salida y habilito el boton de actualizar
            self.hayInternet = YES;
            
            break;
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.internetReachable stopNotifier];
    
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    [FBSession.activeSession handleDidBecomeActive];
    
    
    // Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
    // method "reachabilityChanged" will be called.
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(checkNetworkStatus) name:kReachabilityChangedNotification object: nil];
    
    // inicio la variable de internet
    self.hayInternet = NO;
	[self.internetReachable startNotifier];
	[self checkNetworkStatus];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [UIAccelerometer sharedAccelerometer].delegate = nil;
    [FBSession.activeSession close];

    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

//- (void)saveContext
//{
//    NSError *error = nil;
//    NSManagedObjectContext *managedObjectContext = self.managedObjectContextRu;
//    
//    if (managedObjectContext != nil)
//    {
//        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
//        {
//            /*
//             Replace this implementation with code to handle the error appropriately.
//             
//             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
//             */
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        } 
//    }
//    
//    managedObjectContext = self.managedObjectContextEn;
//    
//    if (managedObjectContext != nil)
//    {
//        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
//        {
//            /*
//             Replace this implementation with code to handle the error appropriately.
//             
//             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//             */
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        }
//    }
//}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
//- (NSManagedObjectContext *)managedObjectContextRu
//{
//    if (__managedObjectContextRu != nil)
//    {
//        return __managedObjectContextRu;
//    }
//    
//    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinatorRu];
//    if (coordinator != nil)
//    {
//        __managedObjectContextRu = [[NSManagedObjectContext alloc] init];
//        [__managedObjectContextRu setPersistentStoreCoordinator:coordinator];
//    }
//    return __managedObjectContextRu;
//}
//
//- (NSManagedObjectContext *)managedObjectContextEn
//{
//    if (__managedObjectContextEn != nil)
//    {
//        return __managedObjectContextEn;
//    }
//    
//    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinatorEn];
//    if (coordinator != nil)
//    {
//        __managedObjectContextEn = [[NSManagedObjectContext alloc] init];
//        [__managedObjectContextEn setPersistentStoreCoordinator:coordinator];
//    }
//    return __managedObjectContextEn;
//}
//
///**
// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
// */
//- (NSManagedObjectModel *)managedObjectModelRu
//{
//    if (__managedObjectModelRu != nil)
//    {
//        return __managedObjectModelRu;
//    }
//    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
//    __managedObjectModelRu = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
//    return __managedObjectModelRu;
//}
//
//- (NSManagedObjectModel *)managedObjectModelEn
//{
//    if (__managedObjectModelEn != nil)
//    {
//        return __managedObjectModelEn;
//    }
//    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
//    __managedObjectModelEn = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
//    return __managedObjectModelEn;
//}
//
///**
// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
// */
//- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorRu
//{
//    if (__persistentStoreCoordinatorRu != nil)
//    {
//        return __persistentStoreCoordinatorRu;
//    }
//
//    NSError *error = nil;
//
//#if DO_BACKUP == 1
//    
//    NSLog(@"Creating new model... ");
//    /*
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Model.sqlite"];
//    NSString *destinationPath = [documentsDirectory stringByAppendingPathComponent:@"Model.sqlite"];
//    
//    if ([fileManager fileExistsAtPath:destinationPath] == NO)
//    {
//        [fileManager copyItemAtPath:sourcePath toPath:destinationPath error:&error];
//        NSLog(@"DB File copied");
//    }
//    else
//    {
//        NSLog(@"DB File already exists");
//    }
//    
//    if (error != nil)
//    {
//         NSLog(@"Error while copy database description-%@ \n", [error localizedDescription]);
//    }
//     */
//    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ModelRU.sqlite"];    
//    NSDictionary *options = nil;
//    
//#else
//
//    NSURL *storeURLRu = [[NSBundle mainBundle] URLForResource:@"ModelRU" withExtension:@"sqlite"];
//    
//    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:1]forKey:NSReadOnlyPersistentStoreOption];
//#endif
//    
//    __persistentStoreCoordinatorRu = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModelRu]];
//    
//    if (![__persistentStoreCoordinatorRu addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURLRu options:options error:&error])
//    {
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
//
//    return __persistentStoreCoordinatorRu;
//}
//
//- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorEn
//{
//    if (__persistentStoreCoordinatorEn != nil)
//    {
//        return __persistentStoreCoordinatorEn;
//    }
//    
//    NSError *error = nil;
//    
//#if DO_BACKUP == 1
//    
//    NSLog(@"Creating new model... ");
//    /*
//     NSFileManager *fileManager = [NSFileManager defaultManager];
//     NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//     NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Model.sqlite"];
//     NSString *destinationPath = [documentsDirectory stringByAppendingPathComponent:@"Model.sqlite"];
//     
//     if ([fileManager fileExistsAtPath:destinationPath] == NO)
//     {
//     [fileManager copyItemAtPath:sourcePath toPath:destinationPath error:&error];
//     NSLog(@"DB File copied");
//     }
//     else
//     {
//     NSLog(@"DB File already exists");
//     }
//     
//     if (error != nil)
//     {
//     NSLog(@"Error while copy database description-%@ \n", [error localizedDescription]);
//     }
//     */
//#if RU_LANG == 1
//    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ModelRU.sqlite"];
//#else
//    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ModelEN.sqlite"];
//#endif
//    
//    
//    NSDictionary *options = nil;
//    
//#else
//    
//    NSURL *storeURLEn = [[NSBundle mainBundle] URLForResource:@"ModelEN" withExtension:@"sqlite"];
//    
//    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:1]forKey:NSReadOnlyPersistentStoreOption];
//#endif
//    
//    __persistentStoreCoordinatorEn = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModelEn]];
//    
//    if (![__persistentStoreCoordinatorEn addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURLEn options:options error:&error])
//    {
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
//    
//    return __persistentStoreCoordinatorEn;
//}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - HUD

- (void) mostratHUDCargando
{
    hud.labelText = NSLocalizedString(@"Loading...", @"");
    [hud show:YES];
}

- (void) mostratHUD:(BOOL)animated conTexto:(NSString *)aTexto
{
    hud.labelText = aTexto;
    [hud show:YES];
}

- (void) mostratHUD:(BOOL)animated conTexto:(NSString *)aTexto conView:(UIView *)aView dimBackground:(BOOL)dimBackg
{
    MBProgressHUD *hudCustom = [[MBProgressHUD alloc] initWithView:self.window.rootViewController.view];

    hudCustom.dimBackground = dimBackg;
    hudCustom.customView = aView;
    hudCustom.labelText = aTexto;
    hudCustom.mode = MBProgressHUDModeCustomView;
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    hudCustom.delegate = self;
    hudCustom.tag = CUSTOMVIEW_TAG;
    [self.window.rootViewController.view addSubview:hudCustom];
    [hudCustom show:animated];
}

- (void) mostratHUDConTexto:(NSString *)aTexto WhileExecuting:(SEL)method onTarget:(id)target withObject:(id)object animated:(BOOL)animated
{
    hud.labelText = aTexto;
    [hud showWhileExecuting:method onTarget:target withObject:object animated:animated];
}

- (void) ocultarHUD
{
    [hud hide:YES];
}

- (void) ocultarHUD:(BOOL)animated
{
    [hud hide:animated];
}

- (void) ocultarHUD:(BOOL)animated despuesDe:(NSTimeInterval)delay
{
    [hud hide:animated afterDelay:delay];
}

- (void) ocultarHUDConCustomView:(BOOL)animated despuesDe:(NSTimeInterval)delay
{
    MBProgressHUD *hudCustom = (MBProgressHUD *)[self.window.rootViewController.view viewWithTag:CUSTOMVIEW_TAG];
    [hudCustom hide:animated afterDelay:delay];
    
    [hudCustom performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:delay];
}

@end
