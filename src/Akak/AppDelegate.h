//
//  AppDelegate.h
//  Akak
//
//  Created by dima on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContextRu;
//@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContextEn;
//
//@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModelRu;
//@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinatorRu;
//
//@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModelEn;
//@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinatorEn;
//
//- (void)saveContext;

- (NSURL *)applicationDocumentsDirectory;

@property (strong, nonatomic) MainViewController *mainViewController;

+ (AppDelegate *)appDelegate;

@end
