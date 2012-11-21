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

@implementation AppDelegate

@synthesize window = _window;
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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"ipad-menubar-right"] forBarMetrics:UIBarMetricsDefault];
    
    // Override point for customization after application launch.
    
#if LITE_VER == 0
    self.mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController_iPhone" bundle:nil];
#else
    self.mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController_iPhone_lite" bundle:nil];
#endif
    
    [self.mainViewController startToBuildIndex];

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.mainViewController];
    PaperFoldNavigationController *paperFoldNavController = [[PaperFoldNavigationController alloc] initWithRootViewController:navController];

    self.window.rootViewController = paperFoldNavController;

    GameViewController *leftViewController = [[GameViewController alloc] init];

    UINavigationController *leftNavController = [[UINavigationController alloc] initWithRootViewController:leftViewController];
    [leftNavController setNavigationBarHidden:YES];
    [paperFoldNavController setLeftViewController:leftNavController width: 310];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
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

@end
