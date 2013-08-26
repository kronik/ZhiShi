//
//  UIProgressAlertView.m
//  SpeechToText
//
//  Created by dima on 7/3/12.
//  Copyright (c) 2012 Dmitry Klimkin. All rights reserved.
//

#import "UIProgressAlertView.h"

@implementation UIProgressAlertView

- (id)initWithTitle:(NSString *)title delegate:(id /*<UIAlertViewDelegate>*/)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles 
{
    activityIndicator_ = [[YLActivityIndicatorView alloc] initWithFrame: CGRectMake(10.0f, 50.0f, 260.0f, 50.0f)];
    activityIndicator_.dotCount = 15;
    activityIndicator_.duration = 2.0f;
    
    [activityIndicator_ startAnimating];

	if ((self = [super initWithTitle:title message:nil delegate:delegate customView:activityIndicator_ cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil]))
    {
	}
	return self;
}

- (void)dealloc
{	
	[activityIndicator_ release];
    [super dealloc];
}
@end
