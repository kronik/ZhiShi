//
//  UIWaveAlertView.m
//  SpeechToText
//
//  Created by dima on 7/3/12.
//  Copyright (c) 2012 Dmitry Klimkin. All rights reserved.
//

#import "UIWaveAlertView.h"

@implementation UIWaveAlertView

@synthesize dataPoints;
@synthesize waveDisplay = waveDisplay_;

- (id)initWithTitle:(NSString *)title delegate:(id /*<UIAlertViewDelegate>*/)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles 
{
	if ((self = [super initWithTitle:title message:@"\n\n\n" delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil]))
    {
		waveDisplay_ = [[WaveDisplay alloc] initWithFrame:CGRectMake(12.0f, 51.0f, 260.0f, 56.0f)];
		[self addSubview:waveDisplay_];
        
        waveDisplay_.dataPoints = self.dataPoints;

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];        
		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	}
	return self;
}

- (void)setDataPoints:(NSArray *)_dataPoints 
{
    // Have to hold on to them here in case the wave display hasn't loaded when they're first set
    [dataPoints release];
    dataPoints = [_dataPoints retain];
    waveDisplay_.dataPoints = dataPoints;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	
    [dataPoints release];
	[waveDisplay_ release];
    [super dealloc];
}

- (void)layoutSubviews
{
	if ([[UIDevice currentDevice] isGeneratingDeviceOrientationNotifications]) 
    {
        self.waveDisplay.frame = CGRectMake(12.0f, 51.0f, 260.0f, 56.0f);		

        /*
		if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
        {
			//self.center = CGPointMake(160.0f, (460.0f - 216.0f)/2 + 12.0f);
		} 
        else 
        {
			//self.center = CGPointMake(240.0f, (300.0f - 162.0f)/2 + 12.0f);
			self.waveDisplay.frame = CGRectMake(12.0f, 35.0f, 260.0f, 56.0f);		
		}
         */
	}
}

- (void)orientationDidChange:(NSNotification *)notification
{
	[self setNeedsLayout];
}

- (void)updateWaveDisplay 
{
    [self.waveDisplay setNeedsDisplay];
}

@end
