//
//  GameViewController.m
//  witrapp.ru
//
//  Created by Dmitry Klimkin on 19/11/12.
//
//

#import "GameViewController.h"

typedef enum gameTableMode
{
    kModeStart,
    kModeGameRu,
    kModeGameEn,
    kModeScore
} gameTableMode;

@interface GameViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) gameTableMode tableMode;
@property (nonatomic, strong) NSArray *ruWords;
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

- (void)resetGame
{
    self.score = 0;
    self.errors = 0;
    self.totalPassed = 0;
    self.correctWordIndex = 0;
    self.inSequence = 0;
    self.maxInSequence = 0;
    self.tableMode = kModeStart;
    
    self.task = @[[self getScoreText], @"Начать?", @"", @"Да", @"Нет"];
    self.correctWordIndex = 3;
    
    [self.tableView reloadData];
}

- (NSString*)getScoreText
{
    return [NSString stringWithFormat:@"E: %d, S: %d, T: %d", self.errors, self.score, self.totalPassed];
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
    NSString *baseWord = nil;
    NSString *firstIncorrect = nil;
    NSString *secondIncorrect = nil;
    
    while (baseWord == nil || firstIncorrect == nil || secondIncorrect == nil)
    {
        baseWord = [self getNextWord];
        firstIncorrect = [self getIncorrectWordBasedOn: baseWord];
        secondIncorrect = [self getIncorrectWordBasedOn: baseWord];
    }
    
    int permut = 0;
    
    switch (permut)
    {
        case 0:
            self.task = @[[self getScoreText], @"Выбери правильный вариант:", @"", baseWord, firstIncorrect, secondIncorrect];
            self.correctWordIndex = 3;
            break;
        case 1:
            self.task = @[[self getScoreText], @"Выбери правильный вариант:", @"", firstIncorrect, baseWord, secondIncorrect];
            self.correctWordIndex = 4;
            break;
        case 2:
            self.task = @[[self getScoreText], @"Выбери правильный вариант:", @"", firstIncorrect, secondIncorrect, baseWord];
            self.correctWordIndex = 5;
            break;
            
        default:
            break;
    }
    
    [self.tableView reloadData];
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
    
    UIImage *navBarImage = [UIImage imageNamed:@"ipad-menubar-right"];
    [[UINavigationBar appearance] setBackgroundImage:navBarImage forBarMetrics:UIBarMetricsDefault];
    
    UIImage* buttonImage = [UIImage imageNamed:@"back.png"];
    
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.rules = [NSDictionary dictionaryWithObjectsAndKeys:@"раст", @"рост", @"жи", @"жы", @"ши", @"шы", @"нн", @"н", @"ок", @"окк",  @"ак", @"акк",  @"акк", @"ак",  @"окк", @"ок",  @"лаг", @"лог",  @"лог", @"лаг",  @"рост", @"раст", @"ращ", @"рощ",  @"рощ", @"ращ", @"рос", @"рас", @"рас", @"рос",  @"лож", @"лаж", @"кас", @"кос",  @"кос", @"кас", @"гар", @"гор",  @"гор", @"гар", @"зар", @"зор", @"зор", @"зар", @"клан", @"клон", @"клон", @"клан", @"твар", @"твор", @"твор", @"твар", @"мак", @"мок", @"мок", @"мак", @"равн", @"ровн", @"ровн", @"равн", @"цы", @"ци", @"ци", @"цы", @"ше", @"шо", @"шо", @"ше", @"же", @"жо", @"жо", @"же", @"пре", @"при", @"при", @"пре", @"ива", @"ыва", @"ыва", @"ива", @"ова", @"ева", @"ева", @"ова", @"не", @"ни", @"ни", @"не", @"бир", @"бер", @"бер", @"бир", @"дер", @"дир", @"дир", @"дер", @"мир", @"мер", @"мер", @"мир", @"тир", @"тер", @"тер", @"тир", @"пир", @"пер", @"пер", @"пир", @"жиг", @"жег", @"жег", @"жиг", @"стил", @"стел", @"стел", @"стил", @"блист", @"блест",  @"блест", @"блист", @"чит", @"чет", @"чет", @"чит", @"чот", @"чет", @"чет", @"чот", @"че", @"чо", @"чо", @"че", @"рос", @"роз", @"роз", @"рос",nil];
    
    [self resetGame];    
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated: YES];
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
        cell.textLabel.font = [UIFont boldSystemFontOfSize: 16.0];
    }
    else if (indexPath.row == 3 && self.tableMode == kModeStart)
    {
        cell.textLabel.font = [UIFont systemFontOfSize: 18.0];
    }
    else
    {
        cell.textLabel.font = [UIFont systemFontOfSize: 14.0];
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
            self.inSequence = 0;
            self.errors++;
        }
        self.totalPassed++;
        
        [self performSelector:@selector(generateNextTask) withObject:nil afterDelay:2];
    }
}

- (void)showCorrectWord
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:self.correctWordIndex inSection: 0]];
    
    cell.imageView.image = [UIImage imageNamed:@"correct"];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

@end
