//
//  AppDescription.h
//  MyApps
//
//  Created by dima on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppDescription : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *iconName;
@property (nonatomic) int appId;

-(UIImage*)icon;

@end
