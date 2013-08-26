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
    waveDisplay_ = [[WaveDisplay alloc] initWithFrame:CGRectMake(12.0f, 51.0f, 260.0f, 70.0f)];

	if ((self = [super initWithTitle:title message:nil delegate:delegate customView:waveDisplay_ cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil]))
    {
        waveDisplay_.dataPoints = self.dataPoints;
	}
	return self;
}

- (void)setDataPoints:(NSArray *)_dataPoints
{
    // Have to hold on to them here in case the wave display hasn't loaded when they're first set
    [dataPoints release];
    
    dataPoints = [_dataPoints retain];
    waveDisplay_.dataPoints = dataPoints;
    
    [self.waveDisplay setNeedsDisplay];
}

- (void)dealloc
{	
    [dataPoints release];
	[waveDisplay_ release];
    [super dealloc];
}

- (void)updateWaveDisplay 
{
    [self.waveDisplay setNeedsDisplay];
}

@end
