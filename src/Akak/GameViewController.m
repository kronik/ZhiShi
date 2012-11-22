//
//  GameViewController.m
//  witrapp.ru
//
//  Created by Dmitry Klimkin on 19/11/12.
//
//

#import "GameViewController.h"

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

- (id) init
{
    self = [super init];
    
    if (self != nil)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dictionaryReady:) name:NOTIFICATION_DICTIONARY_READY object:nil];
    }
    return self;
}

- (void)resetGame
{
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
        
        self.task = @[@"", @"", @"Загрузка...", @"", @""];
        self.correctWordIndex = 100;
    }
    
    [self.tableView reloadData];
}

- (void)showScore
{
    self.tableMode = kModeScore;
    self.task = @[@"Итого:", [NSString stringWithFormat: @"Слов: %d", self.totalPassed],
                             [NSString stringWithFormat: @"Правильно: %d", self.score],
                             [NSString stringWithFormat: @"Ошибок: %d", self.errors], @"", @"Начать заново"];
    self.correctWordIndex = 5;

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
    
    while (baseWord == nil || firstIncorrect == nil || secondIncorrect == nil || ([secondIncorrect isEqualToString:firstIncorrect]))
    {
        baseWord = [self getNextWord];
        firstIncorrect = [self getIncorrectWordBasedOn: baseWord];
        secondIncorrect = [self getIncorrectWordBasedOn: baseWord];
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
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView setUserInteractionEnabled:YES];
    
    [self.view addSubview:self.tableView];
        
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-BG@2x.png"]];
    
    self.rules = [NSDictionary dictionaryWithObjectsAndKeys:@"раст", @"рост", @"жы", @"жи", @"шы", @"ши", @"н", @"нн", @"ок", @"окк",  @"ак", @"акк",  @"акк", @"ак",  @"окк", @"ок",  @"лаг", @"лог",  @"лог", @"лаг",  @"рост", @"раст", @"ращ", @"рощ",  @"рощ", @"ращ", @"рос", @"рас", @"рас", @"рос",  @"лож", @"лаж", @"кас", @"кос",  @"кос", @"кас", @"гар", @"гор",  @"гор", @"гар", @"зар", @"зор", @"зор", @"зар", @"клан", @"клон", @"клон", @"клан", @"твар", @"твор", @"твор", @"твар", @"мак", @"мок", @"мок", @"мак", @"равн", @"ровн", @"ровн", @"равн", @"цы", @"ци", @"ци", @"цы", @"ше", @"шо", @"шо", @"ше", @"же", @"жо", @"жо", @"же", @"пре", @"при", @"при", @"пре", @"ива", @"ыва", @"ыва", @"ива", @"ова", @"ева", @"ева", @"ова", @"не", @"ни", @"ни", @"не", @"бир", @"бер", @"бер", @"бир", @"дер", @"дир", @"дир", @"дер", @"мир", @"мер", @"мер", @"мир", @"тир", @"тер", @"тер", @"тир", @"пир", @"пер", @"пер", @"пир", @"жиг", @"жег", @"жег", @"жиг", @"стил", @"стел", @"стел", @"стил", @"блист", @"блест",  @"блест", @"блист", @"чит", @"чет", @"чет", @"чит", @"чот", @"чет", @"чет", @"чот", @"че", @"чо", @"чо", @"че", @"рос", @"роз", @"роз", @"рос",nil];
        
    [self resetGame];
}

- (void)dictionaryReady:(NSNotification *)inNotification
{
    NSArray *notificationData = (NSArray *)inNotification.object;
    
    if (notificationData != nil)
    {
        self.ruWords = notificationData;
    
        self.tableMode = kModeStart;

        self.task = @[@"", @"Поиграем?", @"", @"Да", @"Нет"];
        self.correctWordIndex = 3;
        
        [self.tableView reloadData];
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
    static NSString *CellIdentifier = @"CellForSearchTable";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.highlightedTextColor = [UIColor blackColor];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.numberOfLines = 1;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    cell.imageView.image = nil;
    
    if (indexPath.row < 3)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setUserInteractionEnabled: NO];
    }
    else
    {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        [cell setUserInteractionEnabled: YES];
    }
    
    if (indexPath.row == 1)
    {
        // Header cell
        cell.textLabel.font = [UIFont boldSystemFontOfSize: 26.0];
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    else if (indexPath.row == 3 && self.tableMode == kModeStart)
    {
        cell.textLabel.font = [UIFont systemFontOfSize: 28.0];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    else
    {
        cell.textLabel.font = [UIFont systemFontOfSize: 24.0];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;

        if ((self.tableMode == kModeGameRu) && ([self.task [indexPath.row] isEqualToString:@""] == NO))
        {
            cell.imageView.image = [UIImage imageNamed:@"point2"];
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
        }
    }
    
    if ((self.tableMode == kModeScore) && (indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3))
    {
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    cell.textLabel.text = self.task [indexPath.row];
    
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
            [self goBack];
        }
    }
    else
    {
        [self showCorrectWord];

        if (indexPath.row == self.correctWordIndex)
        {
            self.score++;
            self.inSequence++;
            
            if (self.inSequence > self.maxInSequence)
            {
                self.maxInSequence = self.inSequence;
            }
        }
        else
        {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath: indexPath];
            cell.imageView.image = [UIImage imageNamed:@"wrong"];

            self.inSequence = 0;
            self.errors++;
        }
        self.totalPassed++;
        
        [self performSelector:@selector(generateNextTask) withObject:nil afterDelay:2];
    }
}

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)showCorrectWord
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:self.correctWordIndex inSection: 0]];
    
    cell.imageView.image = [UIImage imageNamed:@"correct2"];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

@end
