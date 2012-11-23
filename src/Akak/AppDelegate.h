//
//  AppDelegate.h
//  Akak
//
//  Created by dima on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaperFoldNavigationController.h"

@class MainViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAccelerometerDelegate>
{
	BOOL histeresisExcited;
	UIAcceleration* lastAcceleration;
}

@property (strong, nonatomic) UIWindow *window;

- (NSURL *)applicationDocumentsDirectory;

@property (strong, nonatomic) MainViewController *mainViewController;

@property (strong, nonatomic) UIAcceleration* lastAcceleration;

+ (AppDelegate *)appDelegate;

@end
