//
//  MainViewController.m
//  Akak
//
//  Created by dima on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIkit/UITextChecker.h>
#import "MainViewController.h"
#import "DictSearcher.h"
#import "Resources.h"
#import "AdWhirlView.h"
#import "RulesSearcherViewController.h"
#import "GameViewController.h"

#if LITE_VER == 0

#import "Lexicontext.h"

#endif

#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

@interface MainViewController()

@property (strong, nonatomic) UIView *disableViewOverlay;
@property (strong, nonatomic) NSMutableArray *zeroEdits;
@property (strong, nonatomic) NSMutableArray *oneEdits;
@property (strong, nonatomic) NSMutableArray *twoEdits;
@property (strong, nonatomic) NSMutableArray *threeEdits;
@property (strong, nonatomic) DictSearcher *dictSearcherRu;
@property (strong, nonatomic) NSMutableArray *dictionaryEn;
@property (strong, nonatomic) DictSearcher *dictSearcherEn;
@property (strong, nonatomic) NSString *selectedWord;
@property (nonatomic) int selectedIdx;
@property (nonatomic) BOOL isDictionaryReady;
@property (nonatomic) BOOL didSearchStarted;
@property (strong,nonatomic) UIActivityIndicatorView *activity;
@property (strong, nonatomic) NSUserDefaults *standardUserDefaults;
@property (nonatomic) int appLaunchesCount;
@property (nonatomic) BOOL bannerIsVisible;
@property (nonatomic) BOOL noNeedToShowActionSheet;
@property (strong, nonatomic) NSString *previousWord;
@property (nonatomic) BOOL isSearchMode;
@property (nonatomic) BOOL isCorrectionStarted;
@property (nonatomic) BOOL isRecordingStarted;
@property (nonatomic, strong) NSTimer *timer;
@property (strong, nonatomic) SpeechToTextModule* STTConroller;
@property (strong, nonatomic) Reachability* hostReach;
@property (nonatomic) BOOL isVisible;

//@property (nonatomic, strong) AVAudioPlayer *clickPlayer;
//@property (nonatomic, strong) AVAudioPlayer *stopRecPlayer;

- (void)handleSearch:(UISearchBar *)searchBar;
- (void)findTextInFileFast: (NSString*)textToSearch forceFastSearch: (BOOL)forceFastSearch;
- (void)showOnlineDetails: (NSString*)word searchURL:(NSString*)searchURL title:(NSString*)title;
- (void)deviceOrientationDidChange:(NSNotification *)notification;
- (void)showActivityIndicatorInView: (UIView*)view style:(UIActivityIndicatorViewStyle)style;
- (void)hideActivityIndicator;
- (void)enableCancelButton;
- (void)disableCancelButton;
- (void)onRecordTimer: (NSTimer *)timer;

- (NSString*)getLocaleByWord: (NSString*)word;
- (BOOL) isWord: (NSString*)word inAlphabet: (NSString*)alphabet;

-(void) showActionSheet:(id)sender;

@end

@implementation MainViewController

@synthesize searchBar = _searchBar;
@synthesize tableView = _tableView;
@synthesize oneEdits = _oneEdits;
@synthesize twoEdits = _twoEdits;
@synthesize threeEdits = _threeEdits;
@synthesize zeroEdits = _zeroEdits;
@synthesize disableViewOverlay = _disableViewOverlay;
@synthesize activity = _activity;
@synthesize progressView = _progressView;
@synthesize isDictionaryReady = _isDictionaryReady;
@synthesize dictionaryRu = _dictionaryRu;
@synthesize dictSearcherRu = _dictSearcherRu;
@synthesize dictionaryEn = _dictionaryEn;
@synthesize dictSearcherEn = _dictSearcherEn;
@synthesize selectedWord = _selectedWord;
@synthesize selectedIdx = _selectedIdx;
@synthesize didSearchStarted = _didSearchStarted;
//@synthesize managedObjectContextRu = _managedObjectContextRu;
//@synthesize managedObjectContextEn = _managedObjectContextEn;
@synthesize standardUserDefaults = _standardUserDefaults;
@synthesize appLaunchesCount = _appLaunchesCount;
@synthesize bannerView = _bannerView;
@synthesize cancelButton = _cancelButton;
@synthesize showRulesButton = _showRulesButton;
@synthesize bannerIsVisible = _bannerIsVisible;
@synthesize myAdView = _myAdView;
@synthesize noNeedToShowActionSheet = _noNeedToShowActionSheet;
@synthesize previousWord = _previousWord;
@synthesize isSearchMode = _isSearchMode;
@synthesize isCorrectionStarted = _isCorrectionStarted;
@synthesize recognizeButton = _recognizeButton;
@synthesize isRecordingStarted = _isRecordingStarted;
@synthesize timer = _timer;
@synthesize STTConroller = _STTConroller;
@synthesize hostReach = _hostReach;
@synthesize isVisible = _isVisible;
//@synthesize clickPlayer = _clickPlayer;
//@synthesize stopRecPlayer = _stopRecPlayer;

#if LITE_VER == 1
@synthesize adView;
#endif

-(int)appLaunchesCount
{
    _appLaunchesCount = [self.standardUserDefaults integerForKey:APP_LAUNCHES_COUNT_KEY];
    return _appLaunchesCount;
}

-(void)setAppLaunchesCount: (int)newAppLaunchesCount
{
    _appLaunchesCount = newAppLaunchesCount;
    [self.standardUserDefaults setInteger:newAppLaunchesCount forKey:APP_LAUNCHES_COUNT_KEY];
    [self.standardUserDefaults synchronize];
}

- (void)playStartRecordSound
{
    SystemSoundID soundID;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"earcon_done_listening" ofType:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
    AudioServicesPlaySystemSound(soundID);
    AudioServicesDisposeSystemSoundID(soundID);
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)playStopRecordSound
{
    SystemSoundID soundID;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"earcon_listening" ofType:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
    AudioServicesPlaySystemSound(soundID);
    AudioServicesDisposeSystemSoundID(soundID);
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

//-(AVAudioPlayer*)clickPlayer
//{
//    if (_clickPlayer != nil)
//    {
//        [_clickPlayer stop];
//        _clickPlayer = nil;
//    }
//    
//    NSString *clickPath = [[NSBundle mainBundle] pathForResource:@"earcon_done_listening" ofType:@"wav"];
//    NSError *error;
//    
//    _clickPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:clickPath] error:&error];
//    _clickPlayer.numberOfLoops = 0;
//    _clickPlayer.volume = 1.0f;
//    [_clickPlayer prepareToPlay];
//    
//    return _clickPlayer;
//}

//-(AVAudioPlayer*)stopRecPlayer
//{
//    if (_stopRecPlayer != nil)
//    {
//        [_stopRecPlayer stop];
//        _stopRecPlayer = nil;
//    }
//    
//    NSString *clickPath = [[NSBundle mainBundle] pathForResource:@"earcon_listening" ofType:@"wav"];
//    NSError *error;
//    
//    _stopRecPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:clickPath] error:&error];
//    _stopRecPlayer.numberOfLoops = 0;
//    _stopRecPlayer.volume = 1.0f;
//    [_stopRecPlayer prepareToPlay];
//    
//    return _stopRecPlayer;
//}

-(NSUserDefaults*)standardUserDefaults
{
    if (_standardUserDefaults == nil)
    {
        _standardUserDefaults = [NSUserDefaults standardUserDefaults];
    }
    return _standardUserDefaults;
}

-(NSMutableArray*)dictionaryRu
{
    if (_dictionaryRu == nil)
    {
        _dictionaryRu = [[NSMutableArray alloc] init];
    }
    return _dictionaryRu;
}

-(NSMutableArray*)dictionaryEn
{
    if (_dictionaryEn == nil)
    {
        _dictionaryEn = [[NSMutableArray alloc] init];
    }
    return _dictionaryEn;
}

-(NSMutableArray*)zeroEdits
{
    if (_zeroEdits == nil)
    {
        _zeroEdits = [[NSMutableArray alloc] init];
        [_zeroEdits addObject: WORD_NOT_FOUND_TXT];
    }
    return _zeroEdits;
}

-(NSMutableArray*)oneEdits
{
    if (_oneEdits == nil)
    {
        _oneEdits = [[NSMutableArray alloc] init];
        [_oneEdits addObject: WORD_NOT_FOUND_TXT];
    }
    return _oneEdits;
}

-(NSMutableArray*)twoEdits
{
    if (_twoEdits == nil)
    {
        _twoEdits = [[NSMutableArray alloc] init];
        [_twoEdits addObject: WORD_NOT_FOUND_TXT];
    }
    return _twoEdits;
}

-(NSMutableArray*)threeEdits
{
    if (_threeEdits == nil)
    {
        _threeEdits = [[NSMutableArray alloc] init];
        [_threeEdits addObject: WORD_NOT_FOUND_TXT];
    }
    return _threeEdits;
}

- (void)onRecordTimer: (NSTimer *)timer
{
    if (self.isRecordingStarted == YES)
    {
        self.isRecordingStarted = NO;
        [self.timer invalidate];
        self.timer = nil;
    }
}

-(IBAction)onRecognize:(UIButton*)sender 
{
#if 0
    if (self.isRecordingStarted == YES)
    {
        [self.voiceSearch stopRecording];
        self.isRecordingStarted = NO;
        return;
    }
    
    NSString* recoType = SKSearchRecognizerType;
    NSString* langType = APP_LOCALE;
    SKEndOfSpeechDetection detectionType = SKShortEndOfSpeechDetection;
    
    if (self.voiceSearch != nil)
    {
        self.voiceSearch = nil;
    }
    
    self.voiceSearch = [[SKRecognizer alloc] initWithType:recoType
                                                detection:detectionType
                                                 language:langType 
                                                 delegate:self];
    self.isRecordingStarted = YES;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:7.0
                                                  target:self
                                                selector:@selector(onRecordTimer:)
                                                userInfo:nil
                                                 repeats:NO];
#endif
    
#if 0
    [[[AppDelegate appDelegate] iSpeech] ISpeechSilenceDetectAfter:2.5 forDuration:2.0];
    
    NSError *error = nil;
    
    if(![[[AppDelegate appDelegate] iSpeech] ISpeechListenThenRecognizeWithTimeout:4.0 error:&error])
    {
        if([error code] == kISpeechErrorCodeNoInternetConnection) 
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You are not connected to the Internet. Please double check your connection settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        } else if([error code] == kISpeechErrorCodeNoInputAvailable) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No audio input available. Please plug in a microphone to use speech recognition." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
#endif

#if 1
    if (([self.hostReach currentReachabilityStatus] == ReachableViaWiFi) ||
        ([self.hostReach currentReachabilityStatus] == ReachableViaWWAN))
    {
        [self playStartRecordSound];
        
        self.STTConroller = [[SpeechToTextModule alloc] initWithLocale:RECOGNIZE_LOCALE_RU];
        self.STTConroller.delegate = self;
    
        [self.STTConroller beginRecording];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Внимание" message:@"Нет активного итернет подключения." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
#endif
    
}

- (void)didRecognizeResponse:(NSString *)recognizedText
{
    NSLog(@"Recognized: %@", recognizedText);
    
    if (recognizedText != nil)
    {
        [self.searchBar setText:recognizedText];
        [self handleSearch:self.searchBar];
    }
}

- (void)speechStartRecording
{
}

- (void)speechStopRecording
{
    [self playStopRecordSound];
}

- (void)enableCancelButton
{
    self.cancelButton.hidden = NO;
    self.searchBar.showsCancelButton = YES;
    
#if RU_LANG == 1
    self.showRulesButton.hidden = YES;
#endif
}

- (BOOL) substringIsInDictionary:(NSString *)subString
{
    [self.zeroEdits removeAllObjects];
    
    NSRange range;
    int i = 0;
    
    NSString *locale = [self getLocaleByWord:subString];
    NSMutableArray *dict = nil;
    
    if ([locale isEqualToString:APP_LOCALE_EN])
    {
        dict = self.dictionaryEn;
    }
    else
    {
        dict = self.dictionaryRu;
    }
    
    for (NSString *tmpString in dict)
    {
        if (self.isCorrectionStarted == NO)
        {
            NSLog(@"Search canceled");
            return NO;
        }
        
        range = [tmpString rangeOfString:subString];
        
        if (range.location != NSNotFound)
        {
            [self.zeroEdits addObject:[NSString stringWithFormat:@"%@ %d", tmpString, i]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
             
        i++;
    }

    return self.zeroEdits.count > 0;
}

- (void)disableCancelButton
{
    self.cancelButton.hidden = YES;
#if RU_LANG == 1
    self.showRulesButton.hidden = NO;
#else
    self.searchBar.showsCancelButton = NO;
#endif
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self handleSearch:searchBar];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length <= 3 || self.isCorrectionStarted == YES)
    {
        return;
    }
        
    self.isCorrectionStarted = YES;
    
    self.dictSearcherRu.requestToStopSearch = YES;
    self.dictSearcherEn.requestToStopSearch = YES;
    
    dispatch_queue_t processQueue = dispatch_queue_create("corrector", NULL);
    dispatch_async(processQueue, ^{
        
        [self findTextInFileFast:searchText forceFastSearch:YES];
        
        self.isCorrectionStarted = NO;
    });
    
    dispatch_release(processQueue);
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if (self.didSearchStarted == YES)
    {
        [self.searchBar resignFirstResponder];
        return;
    }
    self.disableViewOverlay.alpha = 0;
    [self.view addSubview:self.disableViewOverlay];
	
    [UIView beginAnimations:@"FadeIn" context:nil];
    [UIView setAnimationDuration:0.5];
    self.disableViewOverlay.alpha = 0.1;
    [UIView commitAnimations];
    
    self.tableView.scrollEnabled = NO;
    
    self.isSearchMode = NO;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    self.isSearchMode = YES;
}

- (void)showActivityIndicatorInView: (UIView*)view style:(UIActivityIndicatorViewStyle)style
{
    if (self.activity != nil)
    {
        return;
    }
    
    CGRect cgRect = view.bounds;
    CGSize cgSize = cgRect.size;
    
    self.activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: style];
    
    [view addSubview:self.activity];
    
    self.activity.center = CGPointMake(cgSize.width/2, cgSize.height/3 + 5);
    [self.activity startAnimating];
}

- (void)hideActivityIndicator
{
    if (self.activity == nil)
    {
        return;
    }
    
    [self.activity stopAnimating];
    [self.activity removeFromSuperview];
    self.activity = nil;
}

- (void)handleSearch:(UISearchBar *)searchBar
{   
    if (self.didSearchStarted == YES)
    {
        return;
    }
    
    NSString *userString = self.searchBar.text;

    self.didSearchStarted = YES;
    [self enableCancelButton];
    
    NSString *locale = [self getLocaleByWord: userString];
    DictSearcher *localDictSearcher = nil;
    
    if ([locale isEqualToString: APP_LOCALE_RU])
    {
        localDictSearcher = self.dictSearcherRu;
    }
    else
    {
        localDictSearcher = self.dictSearcherEn;
    }
    
    if (localDictSearcher.isIndexReady == NO)
    {
        [self showActivityIndicatorInView: self.view style:UIActivityIndicatorViewStyleWhiteLarge];
    }
        
    dispatch_queue_t processQueue = dispatch_queue_create("dict processor", NULL);
    dispatch_async(processQueue, ^{
        
        while(localDictSearcher.isIndexReady == NO)
        {
            sleep(1);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchBar resignFirstResponder]; // if you want the keyboard to go away
            [self.disableViewOverlay removeFromSuperview];
            [self hideActivityIndicator];
            
            for (UIView *subView in self.searchBar.subviews)
            {
                if ([subView isKindOfClass:[UITextField class]])
                {
                    UITextField *textField = (UITextField*)subView;                    
                    [self showActivityIndicatorInView: textField style:UIActivityIndicatorViewStyleGray];
                }
            }
        });

        if ([self.previousWord isEqualToString:userString] == NO)
        {
            self.previousWord = userString;
            [self findTextInFileFast:userString forceFastSearch:NO];
        }
        else
        {
            self.didSearchStarted = NO;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideActivityIndicator];
            [self disableCancelButton];
        });
    });
    
    dispatch_release(processQueue);

    self.tableView.scrollEnabled = YES;
}

- (IBAction)searchBarCustomCancelButtonClicked: (UIButton*)button
{
    NSLog(@"Cancel button clicked");
    [self disableCancelButton];
    
    self.dictSearcherRu.requestToStopSearch = YES;
    self.dictSearcherEn.requestToStopSearch = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    self.dictSearcherRu.requestToStopSearch = YES;
    self.dictSearcherEn.requestToStopSearch = YES;

    [self.disableViewOverlay removeFromSuperview];
    
    [searchBar resignFirstResponder]; // if you want the keyboard to go away
    
    self.tableView.scrollEnabled = YES;
    //self.searchBar.showsCancelButton = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(void)findTextInFileFast: (NSString*)textToSearch forceFastSearch: (BOOL)forceFastSearch
{
    NSDate *startTime = [NSDate date];
    int distance = 3;
    
    [self.zeroEdits removeAllObjects];
    [self.oneEdits removeAllObjects];
    [self.twoEdits removeAllObjects];
    [self.threeEdits removeAllObjects];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
        
    NSArray *edits = [[NSArray alloc] initWithObjects:self.zeroEdits, self.oneEdits, self.twoEdits, self.threeEdits, nil];
    
    if (textToSearch.length == 1)
    {
        distance = 0;
    }
    else if (textToSearch.length <= 3)
    {
        distance = 1;
    }
    else if (textToSearch.length <= 5)
    {
        distance = 2;
    }
    else
    {
        distance = 3;
    }
    
    if (forceFastSearch == YES)
    {
        distance = 1;
    }
    
    NSString *locale = [self getLocaleByWord:textToSearch];

    if ([locale isEqualToString:APP_LOCALE_EN])
    {
        [self.dictSearcherEn findStringInDictionary:textToSearch resultSet:edits distance:distance];
    }
    else
    {
        [self.dictSearcherRu findStringInDictionary:textToSearch resultSet:edits distance:distance];
    }

    for (NSMutableArray *array in edits)
    {
        if ([array count] == 0)
        {
            if (array == self.zeroEdits)
            {
                [array addObject: SEARCH_ONLINE_TXT];
            }
            else
            {
                [array addObject: WORD_NOT_FOUND_TXT];
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //[self.progressView setProgress:1.0 animated:YES];
        [self.tableView reloadData];
        self.didSearchStarted = NO;
    });
    
    NSDate *endTime = [NSDate date];
    NSLog(@"Search time: %f", [endTime timeIntervalSinceDate:startTime]);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil)
    {
        return nil;
    }
    
    // Create label with section title
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, 0, 1024.0, 22);
    label.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-menubar"]];
    label.textColor = [UIColor whiteColor]; //UIColorFromRGB(0xF6D993);
    label.font = [UIFont boldSystemFontOfSize:18];
    label.text = sectionTitle;
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset = CGSizeMake(0, 1);
    
    // Create header view and add label as a subview
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024.0, 22)];
    [view addSubview:label];
    
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

-(int)getEditsCount: (NSArray*)editsArray
{
    if (editsArray.count == 0)
    {
        return 0;
    }
    
    if ([[editsArray objectAtIndex:0] isEqualToString: WORD_NOT_FOUND_TXT] ||
        [[editsArray objectAtIndex:0] isEqualToString: SEARCH_ONLINE_TXT])
    {
        return 0;
    }
    else
    {
        return editsArray.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0: return [[NSString alloc] initWithFormat: self.isSearchMode ? SIMILAR_WORDS_TXT : FULL_MATCH_TXT, [self getEditsCount: self.zeroEdits]];
            break;
        case 1: return [[NSString alloc] initWithFormat: ONE_CHANGE_MATCH_TXT, [self getEditsCount: self.oneEdits]];
            break;
        case 2: return [[NSString alloc] initWithFormat: TWO_CHANGES_MATCH_TXT, [self getEditsCount: self.twoEdits]];
            break;
        case 3: return [[NSString alloc] initWithFormat: THREE_CHANGES_MATCH_TXT, [self getEditsCount: self.threeEdits]];
            break;
            
        default:
            break;
    }
    
    return @"";
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0: return [self.zeroEdits count];
            break;
        case 1: return [self.oneEdits count];
            break;
        case 2: return [self.twoEdits count];
            break;
        case 3: return [self.threeEdits count];
            break;
            
        default:
            break;
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    UIColor *color = ((indexPath.row % 2) == 0) ? [UIColor colorWithRed:255.0/255 green:255.0/255 blue:145.0/255 alpha:1] : [UIColor clearColor];
    cell.backgroundColor = color;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    */
}

/*
- (void)longPress:(UILongPressGestureRecognizer *)gesture
{
	// only when gesture was recognized, not when ended
	if (gesture.state == UIGestureRecognizerStateBegan)
	{
		// get affected cell
		UITableViewCell *cell = (UITableViewCell *)[gesture view];
        
		// get indexPath of cell
		NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
		// do something with this action
		NSLog(@"Long-pressed cell at row %@", indexPath);
	}
}
*/

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell.textLabel.text isEqualToString:SEARCH_ONLINE_TXT] == YES ||
        [cell.textLabel.text isEqualToString:WORD_NOT_FOUND_TXT] == YES ||
        [cell.textLabel.text isEqualToString:@""] == YES)
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return (action == @selector(copy:));
}

- (void)paste:(id)sender
{
    if (self.searchBar.text.length > 0)
    {
        [self searchBarSearchButtonClicked: self.searchBar];
    }
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (action == @selector(copy:))
    {
        UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString: cell.textLabel.text ];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCellID = @"cellID";
    NSString *title = nil;
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.highlightedTextColor = [UIColor blackColor];
        cell.textLabel.textColor = [UIColor darkGrayColor];
	}
    
    switch (indexPath.section)
    {
        case 0: title = [self.zeroEdits objectAtIndex:indexPath.row];
            break;
        case 1: title = [self.oneEdits objectAtIndex:indexPath.row];
            break;
        case 2: title = [self.twoEdits objectAtIndex:indexPath.row];
            break;
        case 3: title = [self.threeEdits objectAtIndex:indexPath.row];
            break;
            
        default:
            NSLog(@"ERROR: Strange section index: %d!!!!!", indexPath.section);
            title = @"";
            break;
    }
    
    if ([title isEqualToString:SEARCH_ONLINE_TXT] == NO && [title isEqualToString:WORD_NOT_FOUND_TXT] == NO)
    {        
        NSArray *tokens = [title componentsSeparatedByString:@" "];
        cell.textLabel.text = [tokens objectAtIndex:0];
        
        if (tokens.count > 1)
        {
            cell.tag = [[tokens objectAtIndex:1] intValue];
        }
    }
    else
    {
        cell.textLabel.text = title;
    }
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
    switch (indexPath.section)
    {
        case 0:
        case 1:
        case 2:
        case 3:
            self.selectedWord = cell.textLabel.text;
            break;
            
        default:
            self.selectedWord = WORD_NOT_FOUND_TXT;
            break;
    }
    
    if ([self.selectedWord isEqualToString:SEARCH_ONLINE_TXT] == YES)
    {
        self.selectedWord = self.searchBar.text;
        self.selectedIdx = -1;
        [self showActionSheet:self];
    }
    else if ([self.selectedWord isEqualToString:WORD_NOT_FOUND_TXT] == NO)
    {
        self.selectedIdx = cell.tag;
        
        NSLog(@"Selected idx: %d", self.selectedIdx);
        
        BOOL isWordInDict = [UITextChecker hasLearnedWord: cell.textLabel.text];

        if (isWordInDict == NO)
        {
            [UITextChecker learnWord: cell.textLabel.text];
        }
        
        [self showActionSheet:self];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIView *touchedView = [[touches anyObject] view];
    
    if (touchedView == self.disableViewOverlay && self.isDictionaryReady == YES)
    {
        [self searchBarCancelButtonClicked: self.searchBar];
    }
}

-(void) showActionSheet:(id)sender
{
    UIActionSheet *popupQuery = nil;
    NSString *locale = [self getLocaleByWord: self.selectedWord];
    NSString *wiktionaryUrl = nil;
    NSString *wikipediaUrl = nil;
    NSString *yandexUrl = nil;
    NSString *googleUrl = nil;
    NSString *wiktionary = nil;
    NSString *wikipedia = nil;
    NSString *yandex = nil;
    NSString *google = nil;
    
    if ([locale isEqualToString:APP_LOCALE_RU])
    {
        wiktionaryUrl = WIKTIONARY_URL_RU;
        wikipediaUrl = WIKIPEDIA_URL_RU;
        yandexUrl = YANDEX_URL_RU;
        googleUrl = GOOGLE_URL_RU;
        
        wiktionary = WIKTIONARY_RU;
        wikipedia = WIKIPEDIA_RU;
        yandex = YANDEX_RU;
        google = GOOGLE_RU;
    }
    else
    {
        wiktionaryUrl = WIKTIONARY_URL_EN;
        wikipediaUrl = WIKIPEDIA_URL_EN;
        yandexUrl = YANDEX_URL_EN;
        googleUrl = GOOGLE_URL_EN;
        
        wiktionary = WIKTIONARY_EN;
        wikipedia = WIKIPEDIA_EN;
        yandex = YANDEX_EN;
        google = GOOGLE_EN;
    }
    
	popupQuery = [[UIActionSheet alloc] initWithTitle:[[NSString alloc] initWithFormat: CHECK_WORD_ONLINE_TXT, self.selectedWord] delegate:self cancelButtonTitle:CANCEL_TXT destructiveButtonTitle:nil otherButtonTitles:wiktionary, wikipedia, yandex, google, LOCAL_DICTIONARY, nil];
    self.noNeedToShowActionSheet = NO;
    [self.searchBar resignFirstResponder];
    
	popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[popupQuery showInView:self.view];
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *locale = [self getLocaleByWord: self.selectedWord];
    NSString *wiktionaryUrl = nil;
    NSString *wikipediaUrl = nil;
    NSString *yandexUrl = nil;
    NSString *googleUrl = nil;
    NSString *wiktionary = nil;
    NSString *wikipedia = nil;
    NSString *yandex = nil;
    NSString *google = nil;
    
    if ([locale isEqualToString:APP_LOCALE_RU])
    {
        wiktionaryUrl = WIKTIONARY_URL_RU;
        wikipediaUrl = WIKIPEDIA_URL_RU;
        yandexUrl = YANDEX_URL_RU;
        googleUrl = GOOGLE_URL_RU;
        
        wiktionary = WIKTIONARY_RU;
        wikipedia = WIKIPEDIA_RU;
        yandex = YANDEX_RU;
        google = GOOGLE_RU;
    }
    else
    {
        wiktionaryUrl = WIKTIONARY_URL_EN;
        wikipediaUrl = WIKIPEDIA_URL_EN;
        yandexUrl = YANDEX_URL_EN;
        googleUrl = GOOGLE_URL_EN;
        
        wiktionary = WIKTIONARY_EN;
        wikipedia = WIKIPEDIA_EN;
        yandex = YANDEX_EN;
        google = GOOGLE_EN;
    }

    switch (buttonIndex)
    {
        case 0:
            [self showOnlineDetails: self.selectedWord searchURL:wiktionaryUrl title:wiktionary];
            break;
        case 1:
            [self showOnlineDetails: self.selectedWord searchURL:wikipediaUrl title:wikipedia];
            break;
        case 2:
            [self showOnlineDetails: self.selectedWord searchURL:yandexUrl title:yandex];
            break;
        case 3:
            [self showOnlineDetails: self.selectedWord searchURL:googleUrl title:google];
            break;            
        case 4:
        {
#if LITE_VER == 1
            UIAlertView *alert = nil;

            alert = [[UIAlertView alloc] initWithTitle:ATTENTION_TXT message:FEATURE_NOT_AVAILABLE delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            alert.tag = 1001;
            [alert show];
            return;
#else
            [self showOnlineDetails: nil searchURL:googleUrl title:LOCAL_DICTIONARY];
#endif
        }
            break;
        default:
            [self.tableView reloadData];
            [self.searchBar becomeFirstResponder];
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1001)
    {
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
#if RU_LANG == 1
        NSString *url = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?type=Purple+Software&id=493483440";
#else
        NSString *url = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?type=Purple+Software&id=496458462";
#endif
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        
        if (self.noNeedToShowActionSheet == NO)
        {
            [self showActionSheet:self];
        }
    }
}

- (IBAction)buyFullVerButtonClicked: (UIButton*)button
{
#if RU_LANG == 1
    NSString *url = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?type=Purple+Software&id=493483440";
#else
    NSString *url = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?type=Purple+Software&id=496458462";
#endif
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (IBAction)showAbout:(UIButton*)sender
{
    OtherAppsViewController *controller = [[OtherAppsViewController alloc] initWithNibName:@"OtherAppsView" bundle:nil];
    controller.delegate = self;
    
    controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    [self presentModalViewController:controller animated:YES];
    
    [self.navigationController pushViewController:controller animated: YES];
}

- (void)aboutViewControllerDidFinish:(AboutViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)otherAppsViewControllerDidFinish:(OtherAppsViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)showRulesButtonClicked: (UIButton*)button
{
    self.noNeedToShowActionSheet = YES;
    
#if LITE_VER != 0
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ATTENTION_TXT message:FEATURE_NOT_AVAILABLE delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    alert.tag = 1001;
    [alert show];
    return;    
#endif
    
    RulesSearcherViewController *searchRulesController = [[RulesSearcherViewController alloc] init];
    searchRulesController.sendNotifications = NO;
    [searchRulesController addBackButton];
    [self.navigationController pushViewController:searchRulesController animated:YES];//:searchRulesController animated:YES];

    self.navigationController.navigationBarHidden = NO;
    self.noNeedToShowActionSheet = YES;
}

- (void)onlineDictViewControllerDidFinish:(OnlineDictViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
        
    if (self.noNeedToShowActionSheet == NO)
    {
        [self showActionSheet:self];
    }
    
    self.showRulesButton.titleLabel.textColor = [UIColor whiteColor]; //UIColorFromRGB(0x361707);//[UIColor brownColor];
    self.cancelButton.titleLabel.textColor = [UIColor whiteColor]; //UIColorFromRGB(0x361707);//[UIColor brownColor];
}

- (BOOL) isWord: (NSString*)word inAlphabet: (NSString*)alphabet
{
    NSString *chars = [alphabet stringByReplacingOccurrencesOfString:@" ,-." withString:@""];
    
    for (int i=0; i<chars.length; i++)
    {
        NSString *ch = [chars substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [word rangeOfString : ch];
        
        if ( range.location != NSNotFound )
        {
            return YES;
        }
    }

    return NO;
}

- (NSString*)getLocaleByWord: (NSString*)word
{
    if ([self isWord:word inAlphabet:ALPHABET_EN])
    {
        return APP_LOCALE_EN;
    }
    else
    {
        return APP_LOCALE_RU;
    }
}

- (void) showOnlineDetails:(NSString *)word searchURL:(NSString*)searchURL title:(NSString*)title
{
    OnlineDictViewController *controller = nil;
#if LITE_VER == 0
    controller = [[OnlineDictViewController alloc] initWithNibName:@"OnlineDictView" bundle:nil];
#else
    controller = [[OnlineDictViewController alloc] initWithNibName:@"OnlineDictView_lite" bundle:nil];
#endif
    controller.delegate = self;
    controller.word = word;

    NSString *html = nil;
    
    //TODO: Make grey background
    
    NSString *locale = [self getLocaleByWord: self.selectedWord];

    if ([locale isEqualToString:APP_LOCALE_RU])
    {
        html = [[self.dictSearcherRu getWordDescriptionByIdx: self.selectedIdx] stringByReplacingOccurrencesOfString:@"\n" withString:@"</font></p><p><font size=46>"];
    
        controller.localHtml = [[NSString alloc] initWithFormat:@"<html><body bgcolor=#E4E4E4><p><font size=70><b>%@</b></font></p><p><font size=46>%@</font></p></body></html>", self.selectedWord, html];
    }
    else
    {
#if LITE_VER == 0
        Lexicontext *dictionary = [Lexicontext sharedDictionary];
        html = [dictionary definitionAsHTMLFor:self.selectedWord
                                     withTextColor:@"000000"
                                     backgroundColor:@"#E4E4E4"
                                     definitionBodyFontFamily:@"Helvetica"
                                     definitionBodyFontSize:46];
        controller.localHtml = html;
#endif
    }
    
    controller.header = title;
    controller.searchURL = searchURL;
    //controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self.navigationController pushViewController:controller animated: YES];

    self.navigationController.navigationBarHidden = NO;

    //[self presentModalViewController:controller animated:YES];
}

#pragma mark - View lifecycle
/*
 
 NSData *databuffer;
 NSFileHandle *file;
 
 file = [NSFileHandle fileHandleForReadingAtPath: 
 @"/tmp/myfile.txt"];
 if (file == nil)
 NSLog(@"Failed to open file");
 
 [file seekToFileOffset: 10];
 databuffer = [file readDataOfLength: 5];
 [file closeFile];
 
 */

- (void)viewDidLoad
{
    self.navigationController.navigationBarHidden = YES;
    
    [super viewDidLoad];
    UInt32 sessionCategory = kAudioSessionCategory_AmbientSound;
    AudioSessionSetProperty (kAudioSessionProperty_AudioCategory,
                             sizeof (sessionCategory),
                             &sessionCategory);
    
#if 0
    [SpeechKit setupWithID:@"NMDPPRODUCTION_Home_iSpellIt_20120506222652"
                      host:@"nu.nmdp.nuancemobility.net"
                      port:443
                    useSSL:NO
                  delegate:self];
    
    SKEarcon* earconStart	= [SKEarcon earconWithName:@"earcon_done_listening.wav"];
	SKEarcon* earconStop	= [SKEarcon earconWithName:@"earcon_listening.wav"];
	SKEarcon* earconCancel	= [SKEarcon earconWithName:@"earcon_done_listening.wav"];
	
	[SpeechKit setEarcon:earconStart forType:SKStartRecordingEarconType];
	[SpeechKit setEarcon:earconStop forType:SKStopRecordingEarconType];
	[SpeechKit setEarcon:earconCancel forType:SKCancelRecordingEarconType];
#endif
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paste:) name:UIMenuControllerWillHideMenuNotification object:nil];
    
    self.tableView.scrollEnabled = YES;
    self.bannerIsVisible = NO;
    
    //self.tableView.backgroundColor = [UIColor colorWithRed:251/255.0f green:248/255.0f blue:148/255.0f alpha:1.0];
    self.tableView.separatorColor = [UIColor clearColor];//[UIColor colorWithRed:180/255.0f green:188/255.0f blue:164/255.0f alpha:1.0];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-BG"]];
    
    //self.searchBar.tintColor = [UIColor colorWithRed:77/255.0f green:55/255.0f blue:47/255.0f alpha:1.0f];
    //self.cancelButton.backgroundColor = [UIColor colorWithRed:77/255.0f green:55/255.0f blue:47/255.0f alpha:1.0f];
    //self.cancelButton.tintColor = [UIColor colorWithRed:77/255.0f green:55/255.0f blue:47/255.0f alpha:1.0f];
    //self.showRulesButton.backgroundColor = [UIColor colorWithRed:77/255.0f green:55/255.0f blue:47/255.0f alpha:1.0f];
    //self.showRulesButton.tintColor = [UIColor colorWithRed:77/255.0f green:55/255.0f blue:47/255.0f alpha:1.0f];

    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"ipad-button-red"] forState:UIControlStateNormal];
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"ipad-button-red-pressed"] forState:UIControlStateHighlighted];

    [self.showRulesButton setBackgroundImage:[UIImage imageNamed:@"ipad-button-blue"] forState:UIControlStateNormal];
    [self.showRulesButton setBackgroundImage:[UIImage imageNamed:@"ipad-button-blue-pressed"] forState:UIControlStateHighlighted];

    self.showRulesButton.titleLabel.textColor = [UIColor whiteColor];// UIColorFromRGB(0x361707);//[UIColor brownColor];
    self.cancelButton.titleLabel.textColor = [UIColor whiteColor]; //UIColorFromRGB(0x361707);//[UIColor brownColor];
    
    [self.searchBar setBackgroundImage:[UIImage imageNamed:@"ipad-menubar"]];

//    [self.searchBar setBackgroundColor:[UIColor clearColor]];
//    for (UIView *subview in self.searchBar.subviews) {
//        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
//            [subview removeFromSuperview];
//            break;
//        }
//    }
    
    self.cancelButton.layer.cornerRadius = 5.0;
    self.showRulesButton.layer.cornerRadius = 5.0;
    //self.recognizeButton.hidden = YES;
    self.previousWord = @"";
    
    //[self.searchBar insertSubview:self.showRulesButton atIndex:3];
    
#if RU_LANG == 0
    [self.showRulesButton setHidden:YES];
    self.searchBar.showsCancelButton = NO;
#endif
    
#if LITE_VER == 0
    self.disableViewOverlay = [[UIView alloc]
                               initWithFrame:CGRectMake(0.0f,44.0f,1024.0f,1024)];//416.0f
#else
    self.disableViewOverlay = [[UIView alloc]
                               initWithFrame:CGRectMake(0.0f,94.0f,1024.0f,1024)];//416.0f
#endif
    self.disableViewOverlay.backgroundColor=[UIColor lightGrayColor];
    self.disableViewOverlay.alpha = 0;
    self.cancelButton.titleLabel.text = STOP_TXT;
        
    /*[[self.searchBar.subviews objectAtIndex:0] removeFromSuperview];
        
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f,0.0f,1024.0,416.0f)];
    backgroundView.image = [UIImage imageNamed:@"search_bar2.jpeg"];
    [self.searchBar insertSubview:backgroundView atIndex:1];
     */
    [self.searchBar setPlaceholder:SEARCH_HINT];
    [self disableCancelButton];
    
    [self.progressView setBackgroundColor: [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"search_bar2.jpeg"]]];
    //[self.progressView setProgressTintColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"search_bar2.jpeg"]]];

    
#if LITE_VER == 1
    self.adView = [AdWhirlView requestAdWhirlViewWithDelegate:self];
    self.adView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:self.adView];
    
    [self adjustAdSize];
#endif 
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeypad:) name:NOTIFICATION_REQUEST_TO_HIDE_KEYPAD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shakeDetected:) name:NOTIFICATION_SHAKE_DETECTED object:nil];

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)shakeDetected:(NSNotification *)inNotification
{
    if (self.isVisible == YES)
    {
        GameViewController *gameController = [[GameViewController alloc] init];
        gameController.ruWords = self.dictionaryRu;
        [gameController addBackButton];
        
        [self.navigationController pushViewController:gameController animated:YES];
        self.navigationController.navigationBarHidden = NO;
    }
}

- (void)hideKeypad:(NSNotification *)inNotification
{
    [self.searchBar resignFirstResponder];

//    UIViewController *dummyController = [[UIViewController alloc] init];
//    UIView *dummy = [[UIView alloc] initWithFrame:CGRectMake(-1, -1,1,1)];
//    [dummyController setView:dummy];
//    [self presentModalViewController:dummyController animated:NO];
//    [dummyController dismissModalViewControllerAnimated:NO];
    [self searchBarCancelButtonClicked: self.searchBar];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
     
    [super viewDidUnload];

    self.hostReach = nil;
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationController.navigationBarHidden = YES;

    self.tableView.allowsSelection = YES;

    [self.searchBar becomeFirstResponder];
    
    [self searchBarTextDidBeginEditing: self.searchBar];
    
    self.showRulesButton.titleLabel.textColor = [UIColor whiteColor]; //UIColorFromRGB(0x361707);//[UIColor brownColor];
    self.cancelButton.titleLabel.textColor = [UIColor whiteColor]; //UIColorFromRGB(0x361707);//[UIColor brownColor];
    
    self.isVisible = YES;
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    //Obtaining the current device orientation
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown)
    {
        return;
    }
 
    if (self.activity == nil)
    {
        return;
    }
    
    CGRect cgRect =[[UIScreen mainScreen] bounds];
    CGSize cgSize = cgRect.size;
    
    if (UIDeviceOrientationIsPortrait(orientation))
    {
        self.activity.center = CGPointMake(cgSize.width/2, cgSize.height/3);
    }
    else
    {
        self.activity.center = CGPointMake(cgSize.height/2, cgSize.width/3);
    }
}

-(void)startToBuildIndex
{
    dispatch_queue_t loaderQueue = dispatch_queue_create("dict loader", NULL);
    dispatch_async(loaderQueue, ^{
        NSDate *startTime = [NSDate date];
        
        if (_dictSearcherRu == nil)
        {
            _dictSearcherRu = [[DictSearcher alloc] initWithLocale:APP_LOCALE_RU];
            _dictSearcherRu.delegate = self;
        }
        
        if (_dictSearcherEn == nil)
        {
            _dictSearcherEn = [[DictSearcher alloc] initWithLocale:APP_LOCALE_EN];
            _dictSearcherEn.delegate = self;
        }
        
        if (_dictionaryRu == nil && _dictionaryEn == nil)
        {
            NSString *filePathRu = [[NSBundle mainBundle] pathForResource:@"dict_ru" ofType:@"bin"];
            NSString *filePathEn = [[NSBundle mainBundle] pathForResource:@"dict_en" ofType:@"bin"];
            
            /*
            NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *dictFile = [NSString stringWithFormat:@"%@/%@", documentsDirectory, @"dict_en.bin"];
            */
            
            /*
            _dictionary = (NSMutableArray*)[[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] 
                               componentsSeparatedByString:@"\n"];
            
            NSLog(@"Dict words count: %d", _dictionary.count);
            NSLog(@"New dict.bin: %@", dictFile);
            
            [_dictionary writeToFile:dictFile atomically:YES];
            */
            _dictionaryRu = [NSMutableArray arrayWithContentsOfFile:filePathRu];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATION_DICTIONARY_READY object: self.dictionaryRu];
            });
            
            _dictionaryEn = [NSMutableArray arrayWithContentsOfFile:filePathEn];

            //}
        }

        NSDate *endTime = [NSDate date];
        
        [self.dictSearcherRu makeHashTableLight:(NSMutableArray*)_dictionaryRu];
        [self.dictSearcherEn makeHashTableLight:(NSMutableArray*)_dictionaryEn];
        
        endTime = [NSDate date];
        NSLog(@"Total load time: %f", [endTime timeIntervalSinceDate:startTime]);
        
        self.isDictionaryReady = YES;
        
        dispatch_queue_t backupQueue = dispatch_queue_create("dict backup", NULL);
        dispatch_async(backupQueue, ^{
            [self.dictSearcherRu saveBackupData];
            [self.dictSearcherEn saveBackupData];
        });
        dispatch_release(backupQueue);
    });
    
    dispatch_release(loaderQueue);
}

- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    //    BOOL connectionRequired= [curReach connectionRequired];
    
    if (netStatus == ReachableViaWiFi)
    {
    }
}

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self updateInterfaceWithReachability: curReach];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];

    self.hostReach = [Reachability reachabilityWithHostName: @"www.google.ru"];
	[self.hostReach startNotifier];
	[self updateInterfaceWithReachability: self.hostReach];
    
    if (self.appLaunchesCount == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ATTENTION_TXT message:APP_LICENCE_TEXT delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    
    self.appLaunchesCount += 1;
    
    [super viewDidAppear:animated];
}

- (void)dictSearcherUpdateProgress:(DictSearcher *)searcher progress:(float)progress
{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (progress > 0.0)
//        {
//            //[self.progressView setProgress:progress animated:YES];
//        }
//        else
//        {
//            //[self.progressView setProgress:progress animated:NO];
//        }
//    });
}

- (void)dictSearcherUpdateTable:(DictSearcher *)searcher index:(int)index
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (index <= 1)
        {
            [self.tableView reloadData];
        }
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    self.isVisible = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
    self.hostReach = nil;
    
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
#if LITE_VER == 1
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
    {
        self.bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
    }
    else
    {
        self.bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    }
    
    [self adjustAdSize];
#endif 
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#if LITE_VER == 1

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return NO;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!self.bannerIsVisible)
    {
        [self.myAdView setHidden:YES];
        [self.bannerView setHidden:NO];
        self.bannerIsVisible = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"Failed to load iAd");
    
    if (self.bannerIsVisible)
    {
        //Show own banner
        [self.myAdView setHidden:NO];
        [self.bannerView setHidden:YES];
        self.bannerIsVisible = NO;
    }
}

#pragma mark AdWhirl

- (NSString *)adWhirlApplicationKey
{
    return @"5656e05a98154aafbeba074ee21361fb";
}
//
- (BOOL)adWhirlTestMode
{
    return NO;
}
//
- (void)adWhirlDidDismissFullScreenModal
{
}
//
- (UIViewController *)viewControllerForPresentingModalView
{
    return self;
}
//
- (void)adWhirlDidReceiveAd:(AdWhirlView *)adWhirlView
{
    [self adjustAdSize];
}
//
- (void)adjustAdSize
{    
    [UIView beginAnimations:@"AdResize" context:nil];
    [UIView setAnimationDuration:0.7];
    CGSize adSize = [adView actualAdSize];
    CGRect newFrame = adView.frame;
    newFrame.size.height = adSize.height;
    newFrame.size.width = adSize.width;
    newFrame.origin.x = (self.view.bounds.size.width - adSize.width)/2;
    newFrame.origin.y = self.view.bounds.size.height - adSize.height;
    adView.frame = newFrame;
    [UIView commitAnimations];
}
#endif

@end
