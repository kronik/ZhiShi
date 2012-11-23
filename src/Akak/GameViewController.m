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

#define TESTS_IN_SESSION 5

typedef enum gameTableMode
{
    kModeInit,
    kModeStart,
    kModeGameRu,
    kModeGameEn,
    kModeScore
} gameTableMode;

@interface GameViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) gameTableMode tableMode;
@property (nonatomic, strong) NSDictionary *rules;
@property (nonatomic, strong) NSArray *task;
@property (nonatomic) int score;
@property (nonatomic) int errors;
@property (nonatomic) int totalPassed;
@property (nonatomic) int correctWordIndex;
@property (nonatomic) int inSequence;
@property (nonatomic) int maxInSequence;
@property (strong, nonatomic) NSArray *yesSounds;
@property (strong, nonatomic) NSArray *noSounds;
@property (strong, nonatomic) MBProgressHUD *hud;

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

- (id) init
{
    self = [super init];
    
    if (self != nil)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dictionaryReady:) name:NOTIFICATION_DICTIONARY_READY object:nil];
    }
    return self;
}

- (void)playSound: (NSString*)soundFile
{
    NSArray *tokens = [soundFile componentsSeparatedByString:@"."];
    
    SystemSoundID soundID;
    NSString *path = [[NSBundle mainBundle] pathForResource: tokens[0] ofType:tokens[1]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
    AudioServicesPlaySystemSound(soundID);
    AudioServicesDisposeSystemSoundID(soundID);    
}

- (void)playBgSound: (NSString*)soundFile
{    
    NSError *error = nil;
    NSString *path = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], soundFile];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    if( [[NSFileManager defaultManager] fileExistsAtPath: path] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:[NSString stringWithFormat: @"Нет файла: %@", soundFile] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        return;
    }
        
    AVAudioPlayer *soundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    soundPlayer.numberOfLoops = 0;
    soundPlayer.volume = 1.0;
    
    if (error != nil)
    {
        NSLog(@"%@", [error description]);
    }
    
    [soundPlayer prepareToPlay];
    [soundPlayer play];
}

-(void)playYesSound
{
    int idx = arc4random() % self.yesSounds.count;
    [self playBgSound:[self.yesSounds objectAtIndex:idx]];
}

-(void)playNoSound
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

    int idx = arc4random() % self.noSounds.count;
    [self playBgSound:[self.noSounds objectAtIndex:idx]];
}

-(NSArray*)yesSounds
{
    if (_yesSounds == nil)
    {
        _yesSounds = [[NSArray alloc] initWithObjects:@"да.mp3", @"здорово.mp3", @"молодец.mp3", @"отлично.mp3", @"умничка.mp3", nil];
    }
    
    return _yesSounds;
}

-(NSArray*)noSounds
{
    if (_noSounds == nil)
    {
        _noSounds = [[NSArray alloc] initWithObjects:@"еще разок1.mp3", @"еще разок2.mp3", @"нееет.mp3", @"нет.mp3", @"попробуй еще раз1.mp3", @"попробуй еще раз2.mp3", @"хммм.mp3", nil];
    }
    
    return _noSounds;
}

- (void)startNewGame
{
    self.score = 0;
    self.errors = 0;
    self.totalPassed = 0;
    self.correctWordIndex = 0;
    self.inSequence = 0;
    
    self.tableMode = kModeGameRu;
    [self generateNextTask];
}

- (void)resetGame
{
    self.navigationItem.title = @"Проверятор";
    self.navigationItem.rightBarButtonItem = nil;

    self.score = 0;
    self.errors = 0;
    self.totalPassed = 0;
    self.correctWordIndex = 0;
    self.inSequence = 0;
    self.maxInSequence = 0;
    
    if (self.ruWords != nil && self.ruWords.count > 0)
    {
        self.tableMode = kModeStart;
        
        self.task = @[@"", @"Поиграем?", @"", @"Да", @"Нет"];
        self.correctWordIndex = 3;
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
    self.tableMode = kModeScore;
    self.task = @[@"Итого:", @"Слов:", @"Ошибок:", @"Правильно:", @"Правильно подряд:", @"", @"Начать заново"];
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
        
        if (word.length < 6)
        {
            word = nil;
        }
    }
    
    return word;
}

- (BOOL)disablesAutomaticKeyboardDismissal
{
    return NO;
}

- (NSString *) getIncorrectWordBasedOn: (NSString*) correctWord
{
    NSString *word = nil;
    int triesCount = 0;
    
    while (word == nil)
    {
        int keyIndex = arc4random() % self.rules.count;
        int i = 0;
        
        for (NSString *key in self.rules.keyEnumerator)
        {
            if (i == keyIndex)
            {
                NSString *destRule = self.rules [key];
                
                word = [correctWord stringByReplacingOccurrencesOfString: key withString: destRule];
                
                if ([word isEqualToString: correctWord] == NO)
                {
                    return word;
                }
                else
                {
                    word = nil;
                }
                
                break;
            }
            else
            {
                i++;
            }
        }
        triesCount ++;
        
        if (triesCount == 10)
        {
            break;
        }
    }
    
    return word;
}

- (void)generateNextTask
{
    if (self.totalPassed == TESTS_IN_SESSION)
    {
        [self showScore];
        return;
    }
    
    NSString *baseWord = nil;
    NSString *firstIncorrect = nil;
    NSString *secondIncorrect = nil;
    //NSString *thirdIncorrect = nil;
    
    while (baseWord == nil || firstIncorrect == nil || secondIncorrect == nil || ([secondIncorrect isEqualToString:firstIncorrect]))
    {
        baseWord = [self getNextWord];
        firstIncorrect = [self getIncorrectWordBasedOn: baseWord];
        secondIncorrect = [self getIncorrectWordBasedOn: baseWord];
        //thirdIncorrect = [self getIncorrectWordBasedOn: baseWord];
    }
    
    int permut = arc4random() % 3;
    
    switch (permut)
    {
        case 0:
            self.task = @[@"", @"Выбери правильный вариант:", @"", baseWord, firstIncorrect, secondIncorrect];
            self.correctWordIndex = 3;
            break;
        case 1:
            self.task = @[@"", @"Выбери правильный вариант:", @"", firstIncorrect, baseWord, secondIncorrect];
            self.correctWordIndex = 4;
            break;
        case 2:
            self.task = @[@"", @"Выбери правильный вариант:", @"", firstIncorrect, secondIncorrect, baseWord];
            self.correctWordIndex = 5;
            break;
//        case 3:
//            self.task = @[@"", @"Выбери правильный вариант:", @"", firstIncorrect, secondIncorrect, thirdIncorrect, baseWord];
//            self.correctWordIndex = 6;
//            break;
            
        default:
            break;
    }
    
    self.navigationItem.title = [NSString stringWithFormat:@"%d / %d", self.totalPassed + 1, TESTS_IN_SESSION];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATION_REQUEST_TO_HIDE_KEYPAD object: nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView = [[MYTableView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style: UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.allowsSelection = YES;
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView setUserInteractionEnabled:YES];
    
    [self.view addSubview:self.tableView];
        
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-BG@2x.png"]];
    
    self.rules = [NSDictionary dictionaryWithObjectsAndKeys:@"раст", @"рост", @"жы", @"жи", @"шы", @"ши", @"н", @"нн", @"ок", @"окк",  @"ак", @"акк",  @"акк", @"ак",  @"окк", @"ок",  @"лаг", @"лог",  @"лог", @"лаг",  @"рост", @"раст", @"ращ", @"рощ",  @"рощ", @"ращ", @"рос", @"рас", @"рас", @"рос",  @"лож", @"лаж", @"кас", @"кос",  @"кос", @"кас", @"гар", @"гор",  @"гор", @"гар", @"зар", @"зор", @"зор", @"зар", @"клан", @"клон", @"клон", @"клан", @"твар", @"твор", @"твор", @"твар", @"мак", @"мок", @"мок", @"мак", @"равн", @"ровн", @"ровн", @"равн", @"цы", @"ци", @"ци", @"цы", @"ше", @"шо", @"шо", @"ше", @"же", @"жо", @"жо", @"же", @"пре", @"при", @"при", @"пре", @"ива", @"ыва", @"ыва", @"ива", @"ова", @"ева", @"ева", @"ова", @"не", @"ни", @"ни", @"не", @"бир", @"бер", @"бер", @"бир", @"дер", @"дир", @"дир", @"дер", @"мир", @"мер", @"мер", @"мир", @"тир", @"тер", @"тер", @"тир", @"пир", @"пер", @"пер", @"пир", @"жиг", @"жег", @"жег", @"жиг", @"стил", @"стел", @"стел", @"стил", @"блист", @"блест",  @"блест", @"блист", @"чит", @"чет", @"чет", @"чит", @"чот", @"чет", @"чет", @"чот", @"че", @"чо", @"чо", @"че", @"рос", @"роз", @"роз", @"рос", @"шу", @"шю", @"жу", @"жю", nil];
        
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
    UIImage *navBarImage = [UIImage imageNamed:@"ipad-menubar-right"];
    [[UINavigationBar appearance] setBackgroundImage:navBarImage forBarMetrics:UIBarMetricsDefault];
    
    UIImage* buttonImage = [UIImage imageNamed:@"back"];
    
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)goBack
{
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
        cell.textLabel.highlightedTextColor = [UIColor blackColor];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:28.0f];
        cell.textLabel.numberOfLines = 1;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
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
            
            if (indexPath.row == 3 || indexPath.row == 4)
            {
                // YES and NO
                cell.imageView.image = nil;
                cell.userInteractionEnabled = YES;
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                
                if (indexPath.row == 3)
                {
                    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:26.0f];
                }
                else if (indexPath.row == 4)
                {
                    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:24.0f];
                }
            }
            else
            {
                cell.imageView.image = nil;
                cell.userInteractionEnabled = NO;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.numberOfLines = 2;
            }
            
            cell.textLabel.text = self.task [indexPath.row];

            break;
            
        case kModeGameEn:
        case kModeGameRu:

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
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                
                if ([self.task [indexPath.row] isEqualToString:@""])
                {
                    cell.imageView.image = nil;
                    cell.userInteractionEnabled = NO;
                }
                else
                {
                    cell.imageView.image = [UIImage imageNamed:@"point2"];
                    cell.userInteractionEnabled = YES;
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

            if ((indexPath.row == 0) || (indexPath.row == 6))
            {
                cell.imageView.image = nil;
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:28.0f];
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                
                if (indexPath.row == 6)
                {
                    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:24.0f];
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    cell.userInteractionEnabled = YES;
                    //cell.imageView.image = [UIImage imageNamed:@"point2"];
                }
                
                cell.textLabel.text = self.task [indexPath.row];
            }
            else
            {
                cell.textLabel.textAlignment = NSTextAlignmentLeft;
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:24.0f];
                
//                if (indexPath.row == 1)
//                {
//                    cell.textLabel.text = [NSString stringWithFormat: self.task [indexPath.row], self.totalPassed];
//                }
//                else if (indexPath.row == 2)
//                {
//                    cell.textLabel.text = [NSString stringWithFormat: self.task [indexPath.row], self.score];
//                }
//                else if (indexPath.row == 3)
//                {
//                    cell.textLabel.text = [NSString stringWithFormat: self.task [indexPath.row], self.errors];
//                }
                
                cell.textLabel.text = self.task [indexPath.row];

                if (indexPath.row == 1)
                {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", self.totalPassed];
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

            break;
            
        default:
            break;
    }
    
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
            [self playYesSound];
            
            // Start the game
            self.tableMode = kModeGameRu;
            [self generateNextTask];
        }
        else
        {
            // Quit somehow
            [self goBack];
        }
    }
    else
    {
        UITableViewCell *cell = nil;
        
        for (int i=0; i<self.task.count; i++)
        {
            cell = [self.tableView cellForRowAtIndexPath: [NSIndexPath indexPathForItem: i inSection:0]];
            cell.userInteractionEnabled = NO;

            if (cell.imageView.image != nil)
            {
                if (i == self.correctWordIndex)
                {
                    cell.imageView.image = [UIImage imageNamed:@"correct2"];
                }
                else
                {
                    cell.imageView.image = [UIImage imageNamed:@"wrong"];
                }
            }
        }

        if (indexPath.row == self.correctWordIndex)
        {
            [self playYesSound];

            self.score++;
            self.inSequence++;
            
            if (self.inSequence > self.maxInSequence)
            {
                self.maxInSequence = self.inSequence;
            }
            
            if (self.tableMode == kModeScore)
            {
                [self startNewGame];
            }
        }
        else
        {
            self.inSequence = 0;
            self.errors++;
            
            [self playNoSound];
        }
        self.totalPassed++;
        
        [self performSelector:@selector(generateNextTask) withObject:nil afterDelay:2];
    }
}

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((self.tableMode == kModeScore) && (indexPath.row > 0))
    {
        return 40;
    }
    else
    {
        return 60;
    }
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

@end
