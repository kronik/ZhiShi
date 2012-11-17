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
	if ((self = [super initWithTitle:title message:@"\n\n\n" delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil]))
    {
		activityIndicator_ = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];   
        activityIndicator_.frame=CGRectMake(150, 150, 16, 16);
        [activityIndicator_ startAnimating];
        
		[self addSubview:activityIndicator_];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];        
		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	}
	return self;
}

- (void)layoutSubviews
{
	if ([[UIDevice currentDevice] isGeneratingDeviceOrientationNotifications]) 
    {
        activityIndicator_.frame = CGRectMake(12.0f, 51.0f, 260.0f, 56.0f);		
	}
}

- (void)orientationDidChange:(NSNotification *)notification
{
    [self setNeedsLayout];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	
	[activityIndicator_ release];
    [super dealloc];
}
@end
