//
//  RulesSearcherViewController.m
//  witrapp.ru
//
//  Created by Dmitry Klimkin on 18/11/12.
//
//

#import "RulesSearcherViewController.h"
#import "OnlineDictViewController.h"
#import "Resources.h"

@interface RulesSearcherViewController () <UISearchBarDelegate, OnlineDictViewControllerDelegate>

@property (nonatomic, strong) NSArray *dataList;
@property (nonatomic, strong) NSMutableArray *displayDataList;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation RulesSearcherViewController

@synthesize dataList = _dataList;
@synthesize displayDataList = _displayDataList;
@synthesize tableView = _tableView;
@synthesize searchBar = _searchBar;
@synthesize sendNotifications = _sendNotifications;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"rules" ofType:@"bin"];
    
    _dataList = [NSArray arrayWithContentsOfFile: filePath];

    _displayDataList = [NSMutableArray arrayWithArray: self.dataList];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.searchBar.showsCancelButton = NO;
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Новый поиск";
    self.searchBar.tintColor = [UIColor darkGrayColor];
    
    CGRect rect = CGRectMake(0, 0, 1, 1);
    // Create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    
    [[UIColor colorWithRed:0.18f green:0.39f blue:0.59f alpha:1.00f] setFill];
    
    UIRectFill(rect);   // Fill it with your color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.searchBar setBackgroundImage:image];
    
    float heightOffset = 0.0;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        heightOffset = 0;
    } else {
        heightOffset = 20;
    }
    
    self.tableView = [[MYTableView alloc] initWithFrame: CGRectMake(0, heightOffset, self.view.frame.size.width, self.view.frame.size.height) style: UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.allowsSelection = YES;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView setUserInteractionEnabled:YES];

    [self.view addSubview:self.tableView];

    self.navigationItem.titleView = self.searchBar;
    
    //self.tableView.separatorColor = [UIColor clearColor];//[UIColor colorWithRed:180/255.0f green:188/255.0f blue:164/255.0f alpha:1.0];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor grayColor];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.98f green:0.98f blue:0.98f alpha:1.00f];
    [self.tableView reloadData];
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
    
    UIImage* buttonImage = [UIImage imageNamed:@"back.png"];
    
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated: YES];
    
    if (self.sendNotifications)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATION_HIDE_RIGHT_VIEW object: nil];
    }
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
    return self.displayDataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *item  = [self.displayDataList objectAtIndex:indexPath.row];
    CGFloat height = 85.0f;
    
    CGSize titleSize = [item sizeWithFont: [UIFont fontWithName:@"Arial" size:13.0f] constrainedToSize:CGSizeMake(260.0f, 1024.0)];
        
    // adde the 24 pixels to get the height plus the time ago label.
    height =  titleSize.height + 44.0f;
    
    return height;
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
    
    cell.backgroundColor = [UIColor colorWithRed:0.98f green:0.98f blue:0.98f alpha:1.00f];
    cell.textLabel.text = self.displayDataList[indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [Flurry logEvent: @"Show selected rule"];

    [self.tableView deselectRowAtIndexPath:indexPath animated: YES];
    int index = 0;
    
    NSString *selectedRule = self.displayDataList [indexPath.row];
    
    for (int i=0; i<self.dataList.count; i++)
    {
        NSString *word = self.dataList [i];
        
        if ([word isEqualToString: selectedRule])
        {
            index = i + 1;
            break;
        }
    }
    
    NSString *templateFile = [[NSBundle mainBundle] pathForResource:@"template" ofType:@"html"];
    NSString *ruleFile = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d", index] ofType:@"html"];
    
    NSString *template = [NSString stringWithContentsOfFile:templateFile encoding:NSUTF8StringEncoding error:nil];
    NSString *rule = [NSString stringWithContentsOfFile:ruleFile encoding:NSUTF8StringEncoding error:nil];

    rule = [template stringByReplacingOccurrencesOfString:@"{data}" withString:rule];
    rule = [rule stringByReplacingOccurrencesOfString:@"{header}" withString: selectedRule];
    
    OnlineDictViewController *controller = nil;
    
    controller = [[OnlineDictViewController alloc] initWithNibName:@"OnlineDictView" bundle:nil];
    controller.delegate = self;
    controller.word = nil;
    
#if RU_LANG == 1
    controller.localHtml = rule;
#else
    controller.localHtml = nil;
#endif
    
    controller.header = RULES_TXT;
    controller.searchURL = GOOGLE_URL_RU;
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController pushViewController:controller animated:YES];// presentModalViewController:controller animated:YES];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        self.searchBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 22);
    }
    else
    {
        self.searchBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    }

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.searchBar resignFirstResponder];
    
    UIView *touchedView = [[touches anyObject] view];

    if (touchedView == self.tableView)
    {
        [self.searchBar resignFirstResponder];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATION_REQUEST_TO_HIDE_KEYPAD object: nil];

    [self.searchBar becomeFirstResponder];
}

- (void) updateItems: (NSString*)searchPattern
{
    [self.displayDataList removeAllObjects];
    NSString *searchPrefix = [searchPattern lowercaseString];
    
    for (int i=0; i<self.dataList.count; i++)
    {
        NSString *word = [self.dataList [i] lowercaseString];
        
        if ([searchPrefix isEqualToString:@""] || [word rangeOfString:searchPrefix].location != NSNotFound)
        {
            [self.displayDataList addObject:[self.dataList objectAtIndex:i]];
        }
    }
    
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self updateItems:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

- (void)onlineDictViewControllerDidFinish:(OnlineDictViewController *)controller
{
}

@end
