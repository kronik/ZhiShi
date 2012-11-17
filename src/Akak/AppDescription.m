//
//  AppDescription.m
//  MyApps
//
//  Created by dima on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDescription.h"

@implementation AppDescription

@synthesize name = _name;
@synthesize description = _description;
@synthesize iconName = _iconName;
@synthesize appId = _appId;

- (UIImage * )icon
{
    return [UIImage imageNamed:self.iconName];
}

@end
