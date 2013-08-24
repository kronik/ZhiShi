//
//  GameViewController.m
//  witrapp.ru
//
//  Created by Dmitry Klimkin on 19/11/12.
//
//

#import "GameViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"
#import "FlatPillButton.h"
#import "BCDShareSheet.h"
#import <Social/Social.h>
#import "AppDelegate.h"
#import "LASharekit.h"
#import "Resources.h"
#import "ImageUtility.h"
#import "UIColor+MLPFlatColors.h"

#define kIndexTwitter  0
#define kIndexVK       1
#define kIndexEmail    2
#define kIndexFaceBook 3

#define TESTS_IN_SESSION 10

@interface NSPair : NSObject

-(id)initWithKey: (NSString*) key andData: (NSString*)data;

@property (nonatomic, strong, readonly) NSString *key;
@property (nonatomic, strong, readonly) NSString *data;

@end

@implementation NSPair

@synthesize key = _key;
@synthesize data = _data;

-(id)initWithKey: (NSString*) key andData: (NSString*)data
{
    self = [super init];
    
    if (self != nil)
    {
        _key = key;
        _data = data;
    }
    return self;
}

@end

typedef enum gameTableMode
{
    kModeInit,
    kModeStart,
    kModeGameRu,
    kModeGameEn,
    kModeScore,
    kModeShare
} gameTableMode;

@interface GameViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) gameTableMode tableMode;
@property (nonatomic, strong) NSDictionary *rules;
@property (nonatomic, strong) NSMutableArray *rulesIndexer;
@property (nonatomic, strong) NSArray *task;
@property (nonatomic) int score;
@property (nonatomic) int errors;
@property (nonatomic) int totalPassed;
@property (nonatomic) int allPassed;
@property (nonatomic) int correctWordIndex;
@property (nonatomic) int inSequence;
@property (nonatomic) int maxInSequence;
@property (nonatomic) BOOL isTimedMode;
@property (nonatomic) BOOL isTimed;
@property (nonatomic) int seconds;
@property (nonatomic) int wrongIndex1;
@property (nonatomic) int wrongIndex2;
@property (nonatomic) int wrongIndex3;
@property (strong, nonatomic) NSArray *yesSounds;
@property (strong, nonatomic) NSArray *noSounds;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) NSTimer *secondsCounter;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) LASharekit *laSharekit;
@property (nonatomic, strong) UIImage *emptyCircleImage;
@property (nonatomic, strong) UIImage *correctCircleImage;
@property (nonatomic, strong) UIImage *incorrectCircleImage;

@end

@implementation GameViewController

@synthesize tableView = _tableView;
@synthesize tableMode = _tableMode;
@synthesize ruWords = _ruWords;
@synthesize rules = _rules;
@synthesize task = _task;
@synthesize score = _score;
@synthesize errors = _errors;
@synthesize totalPassed = _totalPassed;
@synthesize correctWordIndex = _correctWordIndex;
@synthesize inSequence = _inSequence;
@synthesize maxInSequence = _maxInSequence;
@synthesize yesSounds = _yesSounds;
@synthesize noSounds = _noSounds;
@synthesize hud = _hud;
@synthesize isTimed = _isTimed;
@synthesize allPassed = _allPassed;
@synthesize isTimedMode = _isTimedMode;
@synthesize seconds = _seconds;
@synthesize secondsCounter = _secondsCounter;
@synthesize timeLabel = _timeLabel;
@synthesize wrongIndex1 = _wrongIndex1;
@synthesize wrongIndex2 = _wrongIndex2;
@synthesize wrongIndex3 = _wrongIndex3;
@synthesize rulesIndexer = _rulesIndexer;
@synthesize laSharekit = _laSharekit;
@synthesize emptyCircleImage = _emptyCircleImage;
@synthesize correctCircleImage = _correctCircleImage;
@synthesize incorrectCircleImage = _incorrectCircleImage;

- (id) init
{
    self = [super init];
    
    if (self != nil)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dictionaryReady:) name:NOTIFICATION_DICTIONARY_READY object:nil];
        
        _emptyCircleImage = [ImageUtility circleImageOfSize:30
                                             withInnerColor:[UIColor colorWithRed:0.93f green:0.94f blue:0.95f alpha:1.00f]
                                              andOuterColor:[UIColor colorWithRed:0.14f green:0.33f blue:0.51f alpha:1.00f]];
        
        _correctCircleImage = [ImageUtility circleImageOfSize:30
                                               withInnerColor:[UIColor flatGreenColor]
                                                andOuterColor:[UIColor colorWithRed:0.14f green:0.33f blue:0.51f alpha:1.00f]];
        
        _incorrectCircleImage = [ImageUtility circleImageOfSize:30
                                                 withInnerColor:[UIColor flatRedColor]
                                                  andOuterColor:[UIColor colorWithRed:0.14f green:0.33f blue:0.51f alpha:1.00f]];
    }
    return self;
}

- (void) setTableMode:(gameTableMode)tableMode
{
    _tableMode = tableMode;
    
//    if ((tableMode == kModeInit) || (self.task.count == 0))
//    {
//        return;
//    }
//    
//    NSMutableArray *indexPathsToRemove = [[NSMutableArray alloc] init];
//    
//    for (NSInteger i = 0; i < self.task.count; i++)
//	{
//        [indexPathsToRemove addObject:[NSIndexPath indexPathForRow:i inSection:0]];
//    }
//	
//	[self.tableView beginUpdates];
//    [self.tableView insertRowsAtIndexPaths:indexPathsToRemove withRowAnimation:UITableViewRowAnimationTop];
//    [self.tableView endUpdates];
}

//- (void)playSound: (NSString*)soundFile
//{
//    NSArray *tokens = [soundFile componentsSeparatedByString:@"."];
//    
//    SystemSoundID soundID;
//    NSString *path = [[NSBundle mainBundle] pathForResource: tokens[0] ofType:tokens[1]];
//    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
//    AudioServicesPlaySystemSound(soundID);
//    AudioServicesDisposeSystemSoundID(soundID);    
//}
//
//- (void)playBgSound: (NSString*)soundFile
//{    
//    NSError *error = nil;
//    NSString *path = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], soundFile];
//    NSURL *url = [NSURL fileURLWithPath:path];
//    
//    if( [[NSFileManager defaultManager] fileExistsAtPath: path] == NO)
//    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:[NSString stringWithFormat: @"Нет файла: %@", soundFile] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
//        
//        return;
//    }
//        
//    AVAudioPlayer *soundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
//    soundPlayer.numberOfLoops = 0;
//    soundPlayer.volume = 1.0;
//    
//    if (error != nil)
//    {
//        NSLog(@"%@", [error description]);
//    }
//    
//    [soundPlayer prepareToPlay];
//    [soundPlayer play];
//}
//
//-(void)playYesSound
//{
//    int idx = arc4random() % self.yesSounds.count;
//    [self playBgSound:[self.yesSounds objectAtIndex:idx]];
//}
//
//-(void)playNoSound
//{
//    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
//
//    int idx = arc4random() % self.noSounds.count;
//    [self playBgSound:[self.noSounds objectAtIndex:idx]];
//}
//
//-(NSArray*)yesSounds
//{
//    if (_yesSounds == nil)
//    {
//        _yesSounds = [[NSArray alloc] initWithObjects:@"да.mp3", @"здорово.mp3", @"молодец.mp3", @"отлично.mp3", @"умничка.mp3", nil];
//    }
//    
//    return _yesSounds;
//}
//
//-(NSArray*)noSounds
//{
//    if (_noSounds == nil)
//    {
//        _noSounds = [[NSArray alloc] initWithObjects:@"еще разок1.mp3", @"еще разок2.mp3", @"нееет.mp3", @"нет.mp3", @"попробуй еще раз1.mp3", @"попробуй еще раз2.mp3", @"хммм.mp3", nil];
//    }
//    
//    return _noSounds;
//}

- (void)startNewGame: (UIView*) button
{
    //TODO: May be remove?
    
    [self.secondsCounter invalidate];

    if (button != nil)
    {
        [button removeFromSuperview];
    }
    
    self.score = 0;
    self.errors = 0;
    self.totalPassed = 0;
    self.correctWordIndex = 0;
    self.inSequence = 0;
    self.seconds = 0;
    
    self.tableMode = kModeGameRu;
    [self generateNextTask];
}

- (void)nextTaskButton: (FlatPillButton*) button
{
    if ([button.titleLabel.text isEqualToString: self.task[self.correctWordIndex]])
    {
        self.timeLabel.hidden = YES;
        self.isTimed = NO;
    }
    else
    {
        self.timeLabel.hidden = NO;
        self.isTimed = YES;
    }
    
    //[self playYesSound];
    
    // Start the game
    self.tableMode = kModeGameRu;
    
    [self generateNextTask];
}

- (void)resetGame
{
    self.timeLabel.hidden = YES;

    [self setMainTitle:@"Проверятор"];

    self.score = 0;
    self.errors = 0;
    self.totalPassed = 0;
    self.correctWordIndex = 0;
    self.inSequence = 0;
    self.seconds = 0;

    self.task = @[@"", @"", @"", @"", @"", @"", @"", @""];
    [self.tableView reloadData];
    
    if (self.ruWords != nil && self.ruWords.count > 0)
    {
        self.tableMode = kModeStart;
        
        self.task = @[@"", @"Хочу поиграть:", @"", @"Без времени", @"На время"];
        self.correctWordIndex = 3;
        
        self.wrongIndex1 = arc4random() % self.rulesIndexer.count;
        self.wrongIndex2 = arc4random() % self.rulesIndexer.count;
        self.wrongIndex3 = arc4random() % self.rulesIndexer.count;
    }
    else
    {
        self.tableMode = kModeInit;
        
        self.task = @[@""];
        self.correctWordIndex = 100;
        
        self.hud = [[MBProgressHUD alloc] initWithView:self.tableView];
        self.hud.removeFromSuperViewOnHide = YES;
        self.hud.labelText = @"Подождите";
        self.hud.detailsLabelText = @"Идет загрузка словаря...";
        self.hud.alpha = 0.7;
        
        [self.tableView addSubview: self.hud];

        [self.hud show: YES];
    }
    
    [self.tableView reloadData];
}

- (void)showScore
{
    [Flurry logEvent: @"Game finished"];

    self.timeLabel.hidden = YES;
    [self.secondsCounter invalidate];
    
    [self setMainTitle: @"Проверятор"];
    
    self.tableMode = kModeScore;
    
    if (self.isTimed)
    {
        self.task = @[@"Итого:", @"Время:", @"Ошибок:", @"Правильно:", @"Правильно подряд:", @"", @"Начать заново", @"Поделиться"];

    }
    else
    {
        self.task = @[@"Итого:", @"Слов:", @"", @"", @"", @"", @"Начать заново", @"Поделиться"];
    }
    self.correctWordIndex = 6;

    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

    [self.tableView reloadData];
    
//    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showShareResults:)];
//    self.navigationItem.rightBarButtonItem = shareButton;
}

- (void)showShareOptions {
    [Flurry logEvent: @"Show share options"];
    
    self.timeLabel.hidden = YES;
    [self.secondsCounter invalidate];
    
    [self setMainTitle: @"Проверятор"];
    
    self.tableMode = kModeShare;
    
    self.task = @[@"Поделиться:", @"Email", @"Facebook", @"Twitter", @"Vkontakte", @"", @"Начать заново", @""];
    self.correctWordIndex = 6;
    
    [self.tableView reloadData];
}

- (NSString*)getNextWord
{
    NSString *word = nil;
    NSArray *wordsPool = self.ruWords;    
    
    while (word == nil)
    {
        word = wordsPool [arc4random() % wordsPool.count];
        
        if (word.length < 7)
        {
            word = nil;
        }
    }
    
    return [[word lowercaseString] stringByReplacingOccurrencesOfString:@"" withString:@"е"];
}

- (BOOL)disablesAutomaticKeyboardDismissal
{
    return NO;
}

- (NSString *) getIncorrectWordBasedOn: (NSString*) correctWord
{
    NSString *word = nil;
    int startIndex = self.wrongIndex1;
            
    while (true)
    {
        self.wrongIndex1 ++;
        self.wrongIndex1 %= self.rulesIndexer.count;
        
        if (self.wrongIndex1 == startIndex)
        {
            break;
        }
        
        NSPair *pair = self.rulesIndexer [self.wrongIndex1];
        
        word = [correctWord stringByReplacingOccurrencesOfString: pair.key withString: pair.data];
        
        if ([word isEqualToString: correctWord] == NO)
        {
            return word;
        }
        else
        {
            word = nil;
        }
    }
    
    return word;
}

- (void)generateNextTask
{
    [self.secondsCounter invalidate];
    
    if (self.isTimed && (self.totalPassed == TESTS_IN_SESSION))
    {
        [self showScore];
        return;
    }
    
    // TODO: Generate next word index
    
    NSString *baseWord = nil;
    NSString *firstIncorrect = nil;
    NSString *secondIncorrect = nil;
    NSString *thirdIncorrect = nil;
    
//    self.wrongIndex2 %= self.rules.count;
//    self.wrongIndex3 %= self.rules.count;
    
    while (baseWord == nil || firstIncorrect == nil || secondIncorrect == nil || thirdIncorrect == nil || ([secondIncorrect isEqualToString:firstIncorrect]) ||  ([thirdIncorrect isEqualToString:firstIncorrect]) || ([secondIncorrect isEqualToString:thirdIncorrect]))
    {
        self.wrongIndex1 = arc4random() % self.rulesIndexer.count;

        baseWord = [self getNextWord];
        firstIncorrect = [self getIncorrectWordBasedOn: baseWord];
        secondIncorrect = [self getIncorrectWordBasedOn: baseWord];
        thirdIncorrect = [self getIncorrectWordBasedOn: baseWord];
        
//        self.wrongIndex1 ++;
//        self.wrongIndex2 ++;
//        self.wrongIndex3 ++;
        
//        self.wrongIndex1 %= self.rules.count;
//        self.wrongIndex2 %= self.rules.count;
//        self.wrongIndex3 %= self.rules.count;
    }

#ifdef LITE_VERSION
    int permut = arc4random() % 3;
    
    switch (permut)
    {
        case 0:
            self.task = @[@"", @"Выбери правильный вариант:", @"", baseWord, firstIncorrect, secondIncorrect, @""];
            self.correctWordIndex = 3;
            break;
        case 1:
            self.task = @[@"", @"Выбери правильный вариант:", @"", firstIncorrect, baseWord, secondIncorrect, @""];
            self.correctWordIndex = 4;
            break;
        case 2:
            self.task = @[@"", @"Выбери правильный вариант:", @"", firstIncorrect, secondIncorrect, baseWord, @""];
            self.correctWordIndex = 5;
            break;
            
        default:
            break;
    }
#else
    int permut = arc4random() % 4;
    
    switch (permut)
    {
        case 0:
            self.task = @[@"", @"Выбери правильный вариант:", @"", baseWord, firstIncorrect, secondIncorrect, thirdIncorrect];
            self.correctWordIndex = 3;
            break;
        case 1:
            self.task = @[@"", @"Выбери правильный вариант:", @"", firstIncorrect, baseWord, secondIncorrect, thirdIncorrect];
            self.correctWordIndex = 4;
            break;
        case 2:
            self.task = @[@"", @"Выбери правильный вариант:", @"", firstIncorrect, secondIncorrect, baseWord, thirdIncorrect];
            self.correctWordIndex = 5;
            break;
        case 3:
            self.task = @[@"", @"Выбери правильный вариант:", @"", firstIncorrect, secondIncorrect, thirdIncorrect, baseWord];
            self.correctWordIndex = 6;
            break;
            
        default:
            break;
    }
#endif
    
    if (self.isTimed)
    {
        [self setMainTitle: [NSString stringWithFormat:@"%d из %d", self.totalPassed + 1, TESTS_IN_SESSION]];
    }
    else
    {
        if (self.totalPassed < 11)
        {
            [self setMainTitle: [NSString stringWithFormat:@"Правильно пока: %d", self.totalPassed]];
        }
        else
        {
            [self setMainTitle: [NSString stringWithFormat:@"Правильно уже: %d", self.totalPassed]];
        }
    }
    [self.tableView reloadData];
    
    self.secondsCounter = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onSecondsTimer) userInfo:nil repeats:YES];
}

- (void) setSeconds:(int)seconds
{
    _seconds = seconds;
    
    int minutes = seconds / 60;
    int leftSeconds = seconds % 60;
    
    self.timeLabel.text = [NSString stringWithFormat:@"%02d : %02d", minutes, leftSeconds];
}

- (void)onSecondsTimer
{
    self.seconds++;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATION_REQUEST_TO_HIDE_KEYPAD object: nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.laSharekit = [[LASharekit alloc] init:self];
    
    // COMPLETION BLOCKS
    [self.laSharekit setCompletionDone:^{
        UIImageView *Checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark"]];
        [APPDELEGATE mostratHUD:YES conTexto:NSLocalizedString(@"Готово!", @"") conView:Checkmark dimBackground:YES];
        [APPDELEGATE ocultarHUDConCustomView:YES despuesDe:2.0];
    }];
    [self.laSharekit setCompletionCanceled:^{
        UIImageView *errorMark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"notice_error_icon"]];
        [APPDELEGATE mostratHUD:YES conTexto:NSLocalizedString(@"Отменено!", @"") conView:errorMark dimBackground:YES];
        [APPDELEGATE ocultarHUDConCustomView:YES despuesDe:2.0];
    }];
    [self.laSharekit setCompletionFailed:^{
        UIImageView *errorMark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"notice_error_icon"]];
        [APPDELEGATE mostratHUD:YES conTexto:NSLocalizedString(@"Ошибка!", @"") conView:errorMark dimBackground:YES];
        [APPDELEGATE ocultarHUDConCustomView:YES despuesDe:2.0];
    }];
    [self.laSharekit setCompletionSaved:^{
        UIImageView *Checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark"]];
        [APPDELEGATE mostratHUD:YES conTexto:NSLocalizedString(@"Сохранено!", @"") conView:Checkmark dimBackground:YES];
        [APPDELEGATE ocultarHUDConCustomView:YES despuesDe:2.0];
    }];
    
    float heightOffset = 0;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        heightOffset = 44;
    }
    
    self.tableView = [[MYTableView alloc] initWithFrame: CGRectMake(0, heightOffset, self.view.frame.size.width, self.view.frame.size.height) style: UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.allowsSelection = YES;
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView setUserInteractionEnabled:YES];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.tableView.contentOffset = CGPointMake(0, 0);
    }
    
    [self.view addSubview:self.tableView];
        
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-BG@2x.png"]];
    
    self.rules = [NSDictionary dictionaryWithObjectsAndKeys:@"раст", @"рост", @"жы", @"жи", @"шы", @"ши", @"н", @"нн", @"ок", @"окк",  @"ак", @"акк",  @"акк", @"ак",  @"окк", @"ок",  @"лаг", @"лог",  @"лог", @"лаг",  @"рост", @"раст", @"ращ", @"рощ",  @"рощ", @"ращ", @"рос", @"рас", @"рас", @"рос",  @"лож", @"лаж", @"кас", @"кос",  @"кос", @"кас", @"гар", @"гор",  @"гор", @"гар", @"зар", @"зор", @"зор", @"зар", @"клан", @"клон", @"клон", @"клан", @"твар", @"твор", @"твор", @"твар", @"мак", @"мок", @"мок", @"мак", @"равн", @"ровн", @"ровн", @"равн", @"цы", @"ци", @"ци", @"цы", @"ше", @"шо", @"шо", @"ше", @"же", @"жо", @"жо", @"же", @"пре", @"при", @"при", @"пре", @"ива", @"ыва", @"ыва", @"ива", @"ова", @"ева", @"ева", @"ова", @"не", @"ни", @"ни", @"не", @"бир", @"бер", @"бер", @"бир", @"дер", @"дир", @"дир", @"дер", @"мир", @"мер", @"мер", @"мир", @"тир", @"тер", @"тер", @"тир", @"пир", @"пер", @"пер", @"пир", @"жиг", @"жег", @"жег", @"жиг", @"стил", @"стел", @"стел", @"стил", @"блист", @"блест",  @"блест", @"блист", @"чит", @"чет", @"чет", @"чит", @"чот", @"чет", @"чет", @"чот", @"че", @"чо", @"чо", @"че", @"рос", @"роз", @"роз", @"рос", @"шу", @"шю", @"жу", @"жю", @"ания", @"анья", @"ония", @"онья", @"с", @"сс", @"нив", @"нев", @"нев", @"нив", @"кал", @"кол", @"кол", @"кал", @"терр", @"тер", @"кож", @"каж", @"каж", @"кож", @"изк", @"иск", @"зах", @"зох", @"зох", @"зах", @"сар", @"сор", @"мат", @"мот", @"мот", @"мат", @"чиск", @"ческ", @"ческ", @"чиск", @"ео", @"еа", @"еа", @"ео", @"сч", @"щ", @"щ", @"сч", @"бид", @"бед", @"бед", @"бид", @"ота", @"ото", @"ото", @"ота", @"пад", @"под", @"под", @"пад", @"лач", @"лоч", @"лоч", @"лач", @"чев", @"чив", @"чив", @"чев", @"сач", @"соч", @"соч", @"сач", @"пас", @"пос", @"пос", @"пас", @"дот", @"дат", @"дот", @"дат", @"пег", @"пиг", @"пиг", @"пег", @"мен", @"мин", @"мин", @"мен", @"ков", @"кав", @"кав", @"ков", @"наст", @"ност", @"ност", @"наст", @"л", @"лл", @"к", @"кк", @"ара", @"аро", @"аро", @"ара", @"паж", @"пож", @"пож", @"паж", @"ито", @"ыто", @"игр", @"ыгр", @"ё", @"йо", @"йо", @"ё", @"д", @"дд", @"ск", @"ськ", @"пери", @"пере",  @"пере", @"пери", nil];
    
    self.rulesIndexer = [[NSMutableArray alloc] init];

    for (NSString *key in self.rules.keyEnumerator)
    {
        [self.rulesIndexer addObject: [[NSPair alloc] initWithKey: key andData: self.rules [key]]];
    }
    
    [self resetGame];
}

- (void)dictionaryReady:(NSNotification *)inNotification
{
    NSArray *notificationData = (NSArray *)inNotification.object;
    
    if (notificationData != nil)
    {
        self.ruWords = notificationData;
    
        [self.hud hide:YES];

        [self.hud removeFromSuperview];
        [self resetGame];
    }
}

- (void)addBackButton
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    // Create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    
    [[UIColor colorWithRed:0.18f green:0.39f blue:0.59f alpha:1.00f] setFill];
    
    UIRectFill(rect);   // Fill it with your color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [[UINavigationBar appearance] setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
    UIImage* buttonImage = [UIImage imageNamed:@"back"];
    
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)goBack: (UIView *) button
{
    if (button != nil)
    {
        [button removeFromSuperview];
    }
    
    [self.navigationController popViewControllerAnimated: YES];
    [[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATION_HIDE_LEFT_VIEW object: nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.task.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float BUTTON_SIZE = 250;
    float xPoint = self.tableView.frame.size.width/2 - BUTTON_SIZE/2;
    
    NSString *CellIdentifier = @"CellForGameTable";
    
    if ((self.tableMode == kModeScore) && ((indexPath.row == 1) || (indexPath.row == 2) || (indexPath.row == 3) || (indexPath.row == 4)))
    {
        CellIdentifier = @"CellForScoreTable";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        if ([CellIdentifier isEqualToString:@"CellForGameTable"])
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        else
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
        cell.textLabel.textColor = [UIColor colorWithRed:0.14f green:0.33f blue:0.51f alpha:1.00f];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.14f green:0.33f blue:0.51f alpha:1.00f];
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:28.0f];
        cell.textLabel.numberOfLines = 1;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    for (UIView *subButton in cell.contentView.subviews)
    {
        if ([subButton isKindOfClass:[FlatPillButton class]])
        {
            [subButton removeFromSuperview];
        }
    }
    
    switch (self.tableMode)
    {
        case kModeInit:
            cell.imageView.image = nil;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.userInteractionEnabled = NO;
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0f];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.numberOfLines = 1;

            cell.textLabel.text = self.task [indexPath.row];

            break;
        
        case kModeStart:
            
            cell.textLabel.numberOfLines = 1;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:28.0f];
            cell.textLabel.text = @"";

            if (indexPath.row == 3 || indexPath.row == 4)
            {
                // EASY and HARD
                cell.imageView.image = nil;
                cell.userInteractionEnabled = YES;
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:26.0f];

                FlatPillButton *button = [[FlatPillButton alloc] initWithFrame:CGRectMake(xPoint, 5, BUTTON_SIZE, 50)];
                button.enabled = YES;
                
                [button setTitle:self.task [indexPath.row] forState:UIControlStateNormal];
                [button setTitleColor:[UIColor colorWithRed:0.14f green:0.33f blue:0.51f alpha:1.00f] forState:UIControlStateDisabled];
                [button setTitleColor:[UIColor colorWithRed:0.14f green:0.33f blue:0.51f alpha:1.00f] forState:UIControlStateNormal];
                
                [button addTarget:self action:@selector(nextTaskButton:) forControlEvents: UIControlEventTouchUpInside];
                button.titleLabel.font = cell.textLabel.font;

//                if (indexPath.row == 3)
//                {
//                    [button addTarget:self action:@selector(nextTaskButton:) forControlEvents: UIControlEventTouchUpInside];
//                }
//                else if (indexPath.row == 4)
//                {
//                }
                

                [cell.contentView addSubview: button];
            }
            else
            {
                cell.imageView.image = nil;
                cell.userInteractionEnabled = NO;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.numberOfLines = 2;
                cell.textLabel.text = self.task [indexPath.row];
            }
            
            break;
            
        case kModeGameEn:
        case kModeGameRu:
            
            if (self.isTimed && indexPath.row == 0 && self.timeLabel == nil)
            {
                float heightOffset = 0;
                
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                    heightOffset = 40;
                }
                
#ifdef LITE_VERSION
                heightOffset += 40;
#endif
                self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 220, 10 + heightOffset, 200, 50)];
                self.timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size: 20.0f];
                self.timeLabel.backgroundColor = [UIColor clearColor];
                self.timeLabel.textColor = [UIColor colorWithRed:0.14f green:0.33f blue:0.51f alpha:1.00f];
                self.timeLabel.textAlignment = NSTextAlignmentRight;
                self.timeLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
                [self.view addSubview: self.timeLabel];
            }

            if (indexPath.row == 1)
            {
                // Question cell
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size: 26.0f];
                cell.textLabel.numberOfLines = 2;
                cell.imageView.image = nil;
                cell.userInteractionEnabled = NO;
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            else
            {
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size: 24.0f];
                cell.textLabel.numberOfLines = 1;
                cell.textLabel.textAlignment = NSTextAlignmentLeft;

                if ([self.task [indexPath.row] isEqualToString:@""])
                {
                    cell.imageView.image = nil;
                    cell.userInteractionEnabled = NO;
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                }
                else
                {
//                    NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory barButtonItemIconFactory];
//                    
//                    factory.colors = @[[UIColor colorWithRed:0.18f green:0.39f blue:0.59f alpha:1.00f]];
//                    factory.size = 25.0;

                    //cell.imageView.image = [UIImage imageNamed:@"empty"];//[factory createImageForIcon:NIKFontAwesomeIconCheckEmpty];
                    cell.imageView.image = self.emptyCircleImage;
                    cell.userInteractionEnabled = YES;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
            }
            
            cell.textLabel.text = self.task [indexPath.row];

            break;
            
        case kModeScore:
            
            cell.imageView.image = nil;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.userInteractionEnabled = NO;
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:24.0f];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.numberOfLines = 1;
            cell.textLabel.text = @"";
            cell.imageView.image = nil;

            if ((indexPath.row == 0) || (indexPath.row == 6) || (indexPath.row == 7))
            {
                cell.imageView.image = nil;
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:28.0f];
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.text = self.task [indexPath.row];

                if (indexPath.row == 6)
                {
                    cell.textLabel.text = @"";

                    FlatPillButton *button = [[FlatPillButton alloc] initWithFrame:CGRectMake(xPoint, 5, BUTTON_SIZE, 50)];
                    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:24.0f];
                    button.enabled = YES;
                    
                    [button setTitle:self.task [indexPath.row] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor colorWithRed:0.14f green:0.33f blue:0.51f alpha:1.00f] forState:UIControlStateDisabled];
                    [button setTitleColor:[UIColor colorWithRed:0.14f green:0.33f blue:0.51f alpha:1.00f] forState:UIControlStateNormal];

                    [button addTarget:self action:@selector(resetGame) forControlEvents: UIControlEventTouchUpInside];
                    [cell.contentView addSubview: button];
                    
                    cell.userInteractionEnabled = YES;
                }
                else if (indexPath.row == 7)
                {
                    cell.textLabel.text = @"";
                    
                    //FlatPillButton *button = [[FlatPillButton alloc] initWithFrame:CGRectMake(40, 5, 240, 50)];
                    
                    FlatPillButton *button = [[FlatPillButton alloc] initWithFrame:CGRectMake(xPoint, 5, BUTTON_SIZE, 50)];
                    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:24.0f];
                    button.enabled = YES;
                    
                    [button setTitle:self.task [indexPath.row] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor colorWithRed:0.14f green:0.33f blue:0.51f alpha:1.00f] forState:UIControlStateDisabled];
                    [button setTitleColor:[UIColor colorWithRed:0.14f green:0.33f blue:0.51f alpha:1.00f] forState:UIControlStateNormal];
                    
                    [button addTarget:self action:@selector(showShareOptions) forControlEvents: UIControlEventTouchUpInside];
                    [cell.contentView addSubview: button];
                                        
                    cell.userInteractionEnabled = YES;
                }
            }
            else
            {
                cell.textLabel.textAlignment = NSTextAlignmentLeft;
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:24.0f];
                cell.textLabel.text = self.task [indexPath.row];

                if (self.isTimed)
                {
                    if (indexPath.row == 1)
                    {
                        int minutes = self.seconds / 60;
                        int leftSeconds = self.seconds % 60;
                        
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%02d : %02d", minutes, leftSeconds];
                    }
                    else if (indexPath.row == 2)
                    {
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", self.errors];
                    }
                    else if (indexPath.row == 3)
                    {
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", self.score];
                    }
                    else if (indexPath.row == 4)
                    {
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", self.maxInSequence];
                    }
                }
                else
                {
                    if (indexPath.row == 1)
                    {                    
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", self.totalPassed];
                    }
                    else
                    {
                        cell.detailTextLabel.text = @"";
                    }
                }
            }

            break;
            
        case kModeShare:
            
            cell.imageView.image = nil;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.userInteractionEnabled = NO;
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:28.0f];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.numberOfLines = 1;
            cell.imageView.image = nil;
            cell.textLabel.text = self.task [indexPath.row];
                
            if (indexPath.row == 1)
            {
                cell.textLabel.text = @"";
                
                FlatPillButton *button = [[FlatPillButton alloc] initWithFrame:CGRectMake(xPoint, 5, BUTTON_SIZE, 50)];
                button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:24.0f];
                button.enabled = YES;
                
                [button setTitle:self.task [indexPath.row] forState:UIControlStateNormal];
                [button setTitleColor:[UIColor colorWithRed:0.14f green:0.33f blue:0.51f alpha:1.00f] forState:UIControlStateDisabled];
                [button setTitleColor:[UIColor colorWithRed:0.14f green:0.33f blue:0.51f alpha:1.00f] forState:UIControlStateNormal];
                
                [button addTarget:self action:@selector(shareToEmail) forControlEvents: UIControlEventTouchUpInside];
                [cell.contentView addSubview: button];
                
                cell.userInteractionEnabled = YES;
            }
            else if (indexPath.row == 2)
            {
                cell.textLabel.text = @"";
                
                FlatPillButton *button = [[FlatPillButton alloc] initWithFrame:CGRectMake(xPoint, 5, BUTTON_SIZE, 50)];
                button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:24.0f];
                button.enabled = YES;
                
                [button setTitle:self.task [indexPath.row] forState:UIControlStateNormal];
                [button setTitleColor:[UIColor colorWithRed:0.14f green:0.33f blue:0.51f alpha:1.00f] forState:UIControlStateDisabled];
                [button setTitleColor:[UIColor colorWithRed:0.14f green:0.33f blue:0.51f alpha:1.00f] forState:UIControlStateNormal];
                
                [button addTarget:self action:@selector(shareToFacebook) forControlEvents: UIControlEventTouchUpInside];
                [cell.contentView addSubview: button];
                
                cell.userInteractionEnabled = YES;
            }
            else if (indexPath.row == 3)
            {
                cell.textLabel.text = @"";
                
                FlatPillButton *button = [[FlatPillButton alloc] initWithFrame:CGRectMake(xPoint, 5, BUTTON_SIZE, 50)];
                button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:24.0f];
                button.enabled = YES;
                
                [button setTitle:self.task [indexPath.row] forState:UIControlStateNormal];
                [button setTitleColor:[UIColor colorWithRed:0.14f green:0.33f blue:0.51f alpha:1.00f] forState:UIControlStateDisabled];
                [button setTitleColor:[UIColor colorWithRed:0.14f green:0.33f blue:0.51f alpha:1.00f] forState:UIControlStateNormal];
                
                [button addTarget:self action:@selector(shareToTwitter) forControlEvents: UIControlEventTouchUpInside];
                [cell.contentView addSubview: button];
                
                cell.userInteractionEnabled = YES;
            }
            else if (indexPath.row == 4)
            {
                cell.textLabel.text = @"";
                
                FlatPillButton *button = [[FlatPillButton alloc] initWithFrame:CGRectMake(xPoint, 5, BUTTON_SIZE, 50)];
                button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:24.0f];
                button.enabled = YES;
                
                [button setTitle:self.task [indexPath.row] forState:UIControlStateNormal];
                [button setTitleColor:[UIColor colorWithRed:0.14f green:0.33f blue:0.51f alpha:1.00f] forState:UIControlStateDisabled];
                [button setTitleColor:[UIColor colorWithRed:0.14f green:0.33f blue:0.51f alpha:1.00f] forState:UIControlStateNormal];
                
                [button addTarget:self action:@selector(shareToVkontakte) forControlEvents: UIControlEventTouchUpInside];
                [cell.contentView addSubview: button];
                
                cell.userInteractionEnabled = YES;
            }
            else if (indexPath.row == 6)
                {
                    cell.textLabel.text = @"";
                    
                    FlatPillButton *button = [[FlatPillButton alloc] initWithFrame:CGRectMake(xPoint, 5, BUTTON_SIZE, 50)];
                    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:24.0f];
                    button.enabled = YES;
                    
                    [button setTitle:self.task [indexPath.row] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor colorWithRed:0.14f green:0.33f blue:0.51f alpha:1.00f] forState:UIControlStateDisabled];
                    [button setTitleColor:[UIColor colorWithRed:0.14f green:0.33f blue:0.51f alpha:1.00f] forState:UIControlStateNormal];
                    
                    [button addTarget:self action:@selector(resetGame) forControlEvents: UIControlEventTouchUpInside];
                    [cell.contentView addSubview: button];
                    
                    cell.userInteractionEnabled = YES;
                }

            break;
            
        default:
            break;
    }
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated: YES];
    
    if (self.tableMode == kModeStart)
    {
        if (indexPath.row == self.correctWordIndex)
        {            
            // Start the game
            self.tableMode = kModeGameRu;
            [self generateNextTask];
        }
        else
        {
            // Quit somehow
            [self goBack: nil];
        }
    }
    else
    {
        UITableViewCell *cell = nil;
                
        for (int i=0; i<self.task.count; i++)
        {
            cell = [self.tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow:i inSection:0]];
            cell.userInteractionEnabled = NO;

            if (cell.imageView.image != nil)
            {
                if (i == self.correctWordIndex)
                {
                    cell.imageView.image = self.correctCircleImage;
                }
                else
                {
                    cell.imageView.image = self.incorrectCircleImage;
                }
            }
        }

        if (indexPath.row == self.correctWordIndex)
        {
            self.score++;
            self.inSequence++;
            
            if (self.inSequence > self.maxInSequence)
            {
                self.maxInSequence = self.inSequence;
            }
            
            if (self.tableMode == kModeScore)
            {
                [self startNewGame: nil];
            }
        }
        else
        {
            self.inSequence = 0;
            self.errors++;
            
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            
            if (self.isTimed == NO && self.tableMode == kModeGameRu)
            {
                self.totalPassed++;
                [self showScore];
                return;
            }
        }
        self.totalPassed++;
        self.allPassed++;
        
        [self performSelector:@selector(generateNextTask) withObject:nil afterDelay:1];
    }
}

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((self.tableMode == kModeScore) && (indexPath.row > 0))
    {
        if ((indexPath.row == 6) || (indexPath.row == 7))
        {
            return 60;
        }
        else
        {
            return 40;
        }
    }
    else
    {
        return 60;
    }
}

- (void)showShareResults: (UIView*) button
{
    [Flurry logEvent: @"Show share results"];

    NSString *message = [NSString stringWithFormat:@"\nВсего слов: %d\nошибок: %d\nправильно: %d\nи правильно подряд уже: %d! Можешь лучше? #ЖиШи ", self.totalPassed, self.errors, self.score, self.maxInSequence];
    
    //[button setHidden: YES];

    self.laSharekit.title    = @"Мой результат сегодня: ";
    self.laSharekit.url      = [NSURL URLWithString:@"https://itunes.apple.com/ru/app/zi-si/id493483440?ls=1&mt=8"];
    self.laSharekit.text     = [NSString stringWithFormat:@"%@%@", self.laSharekit.title, message];
    self.laSharekit.imageUrl = [NSURL URLWithString:@"https://dl.dropbox.com/u/14628282/zhishi512.png"];
    self.laSharekit.image    = [UIImage imageNamed:@"icon144x144"];
    self.laSharekit.tweetCC  = @"";
    
    return;
    
    [BCDShareSheet sharedSharer].appName = @"Жи-Ши";
    [BCDShareSheet sharedSharer].hashTag = @"ЖиШи";
    [BCDShareSheet sharedSharer].rootViewController = self;
    
    BCDShareableItem *item = [[BCDShareableItem alloc] initWithTitle:@"Мой результат сегодня: "];
    
    [item setDescription:message];
    [item setShortDescription:message];
    [item setItemURLString: @"https://itunes.apple.com/ru/app/zi-si/id493483440?ls=1&mt=8"];
    [item setImageURLString:@"https://dl.dropbox.com/u/14628282/zhishi512.png"];
     
    UIActionSheet *sheet = [[BCDShareSheet sharedSharer] sheetForSharing:item completion:^(BCDResult result)
    {
        if (result == BCDResultSuccess)
        {
            NSLog(@"Yay!");
        }
    }];
    
    [sheet showInView:self.tableView];
}

- (NSInteger)expandingSelector:(id) expandingSelect numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (void)shareToEmail {
    [self.laSharekit performSelector:@selector(emailIt) withObject:nil afterDelay:.1];
    [Flurry logEvent: @"Share to email"];
}

- (void)shareToFacebook {
    [self.laSharekit performSelector:@selector(facebookPost) withObject:nil afterDelay:.1];
    [Flurry logEvent: @"Share to facebook"];
}

- (void)shareToTwitter {
    [self.laSharekit performSelector:@selector(tweet) withObject:nil afterDelay:.1];
    [Flurry logEvent: @"Share to twitter"];
}

- (void)shareToVkontakte {
    [self.laSharekit performSelector:@selector(vkPost) withObject:nil afterDelay:.1];
    [Flurry logEvent: @"Share to vkontakte"];
}

// Called after the user changes the selection.
- (void)expandingSelector:(id)expandingSelect didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
#ifdef LITE_VERSION
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ATTENTION_TXT message:FEATURE_NOT_AVAILABLE delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    alert.tag = 1001;
    [alert show];
    
    return;
#endif
    
    switch (indexPath.row)
    {
        case kIndexEmail:
            [self.laSharekit performSelector:@selector(emailIt) withObject:nil afterDelay:.1];
            [Flurry logEvent: @"Share to email"];

            break;
        case kIndexFaceBook:
            [self.laSharekit performSelector:@selector(facebookPost) withObject:nil afterDelay:.1];
            
            [Flurry logEvent: @"Share to facebook"];

            break;
        case kIndexTwitter:
            [self.laSharekit performSelector:@selector(tweet) withObject:nil afterDelay:.1];
            
            [Flurry logEvent: @"Share to twitter"];

            break;
        case kIndexVK:
            [self.laSharekit performSelector:@selector(vkPost) withObject:nil afterDelay:.1];
            
            [Flurry logEvent: @"Share to vkontakte"];

            return;
        default:
            break;
    }

    return;
    
    UIImage* sharedImage = [UIImage imageNamed:@"icon512.png"];
    NSString *subj = @"Мой результат сегодня: ";
    NSString *message = [NSString stringWithFormat:@"\nВсего слов: %d\nошибок: %d\nправильно: %d\nи правильно подряд уже: %d!", self.totalPassed, self.errors, self.score, self.maxInSequence];
    
    SLComposeViewController* shareViewController = nil;
    
    switch (indexPath.row)
    {
        case kIndexEmail:
        {
            MFMailComposeViewController* mailViewController = [[MFMailComposeViewController alloc] init];
            
            [mailViewController setMailComposeDelegate: self];
            [mailViewController setSubject: subj];
            [mailViewController setMessageBody:message isHTML:NO];
            
            NSData *imageAttachment = UIImageJPEGRepresentation(sharedImage,1);
            
            [mailViewController addAttachmentData: imageAttachment mimeType:@"image/png" fileName:@"icon512.png"];
            [self presentViewController: mailViewController animated: YES completion: nil];
            
            return;
        }
            break;
        case kIndexFaceBook:
            shareViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            break;
        case kIndexTwitter:
            shareViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            break;
        case kIndexVK:
            //Handle favorites
            
            return;
        default:
            break;
    }
    [shareViewController addURL:[NSURL URLWithString:@"https://itunes.apple.com/ru/app/zi-si/id493483440?ls=1&mt=8"]];
    [shareViewController setInitialText: [NSString stringWithFormat:@"%@%@ #ЖиШи", subj, message]];
    [shareViewController addImage: sharedImage];
    
    if ([SLComposeViewController isAvailableForServiceType:shareViewController.serviceType])
    {
        [self presentViewController:shareViewController animated:YES completion: nil];
    }
    else
    {
        UIAlertView* errorAlert = [[UIAlertView alloc] initWithTitle: @"Сервис не доступен"
                                                             message: @"Пожалуйста, настройте сервис в настройках."
                                                            delegate: nil
                                                   cancelButtonTitle: nil
                                                   otherButtonTitles: nil];
        [errorAlert show];
    }
}

//Called after the animations have completed
- (void)expandingSelector:(id)expandingSelect didFinishExpandingAtPoint:(CGPoint) point
{
    NSLog(@"Finished expanding at point (%f, %f)", point.x, point.y);
}
- (void)expandingSelector:(id)expandingSelect didFinishCollapsingAtPoint:(CGPoint) point
{
    NSLog(@"Finished Collapsing at point (%f, %f)", point.x, point.y);
}

#pragma mark - MFMailComposerDelegate callback - Not required by KLExpandingSelect
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#ifdef LITE_VERSION

- (IBAction)buyFullVerButtonClicked: (UIButton*)button
{
#if RU_LANG == 1
    NSString *url = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?type=Purple+Software&id=493483440";
#else
    NSString *url = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?type=Purple+Software&id=496458462";
#endif
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
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
    }
}

#endif

#ifdef LITE_VERSION

- (void)updateAdBannerPosition {
    self.tableView.tableHeaderView = self.adBanner;
    
}

#endif

@end
