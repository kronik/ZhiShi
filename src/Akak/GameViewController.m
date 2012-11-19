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
    kModeLangSelect,
    kModeGameRu,
    kModeGameEn,
    kModeScore
} gameTableMode;

@interface GameViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) gameTableMode tableMode;
@property (nonatomic, strong) NSArray *ruWords;
@property (nonatomic, strong) NSDictionary *rules;

@end

@implementation GameViewController

@synthesize tableView = _tableView;
@synthesize tableMode = _tableMode;
@synthesize ruWords = _ruWords;
@synthesize rules = _rules;

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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView = [[MYTableView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style: UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.allowsSelection = YES;
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
    
    [self.tableView reloadData];
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
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellForSearchTable";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.textLabel.highlightedTextColor = [UIColor blackColor];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.numberOfLines = 4;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        [cell setUserInteractionEnabled: YES];
    }
    
    //cell.textLabel.text = self.displayDataList[indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated: YES];
    
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

@end
