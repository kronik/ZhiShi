//
//  VoiceAddModule.h
//  AstridiPhone
//
//  Created by Sam Bosley on 10/7/11.
//  Copyright (c) 2011 Todoroo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "UIWaveAlertView.h"
#import "UIProgressAlertView.h"

#define kNumberBuffers 3
#define kNumVolumeSamples 10
#define kSilenceThresholdDB -30.0

#define kVolumeSamplingInterval 0.05
#define kSilenceTimeThreshold 0.9
#define kSilenceThresholdNumSamples kSilenceTimeThreshold / kVolumeSamplingInterval

// For scaling display
#define kMinVolumeSampleValue 0.01
#define kMaxVolumeSampleValue 1.0

@protocol SpeechToTextModuleDelegate <NSObject>

// Delegate will need to parse JSON and dismiss loading view if presented
// returns true on success, false on failure
- (void)didRecognizeResponse:(NSString *)recognizedText;
- (void)speechStartRecording;
- (void)speechStopRecording;

@end

@interface SpeechToTextModule : NSObject <UIAlertViewDelegate> 
{
    //UIAlertView *status;
        
    BOOL detectedSpeech;
    int samplesBelowSilence;
    
    NSTimer *meterTimer;
    BOOL processing;
    
    NSMutableArray *volumeDataPoints;
    UIWaveAlertView *waveAlert;
    UIProgressAlertView *progressAlert;
    
    NSThread *processingThread;
    NSString *customLocale;
}

@property (readonly) BOOL recording;
@property (assign) id<SpeechToTextModuleDelegate> delegate;

/* Caller can pass a non-nil nib name to specify the nib with which to create
 a SineWaveViewController (nib should conform to the spec in the SineWaveViewController
 interface). A nil argument will cause the module to display an alert view instead
 of the custom view controller. */
- (id)initWithCustomDisplay:(NSString *)nibName;
- (id)initWithLocale: (NSString*)recognitionLocale;

// Begins a voice recording
- (void)beginRecording;

// Stops a voice recording. The startProcessing parameter is intended for internal use,
// so don't pass NO unless you really mean it.
- (void)stopRecording:(BOOL)startProcessing;

@end
