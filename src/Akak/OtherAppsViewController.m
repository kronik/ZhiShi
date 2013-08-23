//
//  OtherAppsViewController.m
//  MyApps
//
//  Created by dima on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OtherAppsViewController.h"
#import "AppDescription.h"
#import <QuartzCore/QuartzCore.h>

@interface OtherAppsViewController ()

@property (strong, nonatomic) NSMutableArray *apps;

-(void)openAppPage: (int)appId;

@end

@implementation OtherAppsViewController

@synthesize tableView = _tableView;
@synthesize apps = _apps;
@synthesize delegate = _delegate;
@synthesize navBar = _navBar;

-(NSMutableArray*) apps
{
    if (_apps == nil)
    {
        _apps = [[NSMutableArray alloc] init]; 
    }
    return _apps;
}

- (id)init
{
    self = [super initWithNibName:@"OtherAppsView" bundle:nil];
    return self;
}

-(void)openAppPage:(int)appId
{
    NSString *url = [[NSString alloc] initWithFormat: @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?type=Purple+Software&id=%i", appId];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect rect = CGRectMake(0, 0, 1, 1);
    // Create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    
    [[UIColor colorWithRed:0.18f green:0.39f blue:0.59f alpha:1.00f] setFill];
    
    UIRectFill(rect);   // Fill it with your color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [[UINavigationBar appearance] setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
    /*
    UIImage *backButtonImage = [[UIImage imageNamed:@"menu-bar-button"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 4)];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] 
                                   initWithTitle: @"Назад" 
                                   style: UIBarButtonItemStyleBordered
                                   target:self action:@selector(done:)];
    
    //[self.navigationItem setBackBarButtonItem: backButton];
    
    [self.navigationItem setRightBarButtonItem:backButton];
     */
    
    UIImage* buttonImage = [UIImage imageNamed:@"back.png"];
    
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem:backButton];

    self.navigationItem.title = @"Наши приложения";
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-BG@2x.png"]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	// Do any additional setup after loading the view, typically from a nib.
    
//    AppDescription *zhiShi = [[AppDescription alloc] init];
//    zhiShi.name = @"Жи-Ши";
//    zhiShi.description = @"Орфография, Словарь, Правила";
//    zhiShi.iconName = @"zhi_shi.png";
//    zhiShi.appId = 493483440;
//    
//    [self.apps addObject:zhiShi];

    AppDescription *ebeanstalk = [[AppDescription alloc] init];
    ebeanstalk.name = @"eBeanstalk";
    ebeanstalk.description = @"Быстрый английский язык!";
    ebeanstalk.iconName = @"ebeanstalk.png";
    ebeanstalk.appId = 632528131;
    
    [self.apps addObject:ebeanstalk];

    AppDescription *ituneit = [[AppDescription alloc] init];
    ituneit.name = @"iTuneIt";
    ituneit.description = @"Профессиональный тюнер";
    ituneit.iconName = @"ituneit.png";
    ituneit.appId = 507357482;
    
    [self.apps addObject:ituneit];
    
    AppDescription *umka = [[AppDescription alloc] init];
    umka.name = @"Ум-ка";
    umka.description = @"Игра-обучалка для дошколят";
    umka.iconName = @"umka.png";
    umka.appId = 543565164;
    
    [self.apps addObject:umka];
    
    AppDescription *zhiShiEn = [[AppDescription alloc] init];
    zhiShiEn.name = @"iSpellIt";
    zhiShiEn.description = @"Spell checker, Words definition";
    zhiShiEn.iconName = @"zhi_shi_en.png";
    zhiShiEn.appId = 496458462;
    
    [self.apps addObject:zhiShiEn];
    
    AppDescription *ifeelgood = [[AppDescription alloc] init];
    ifeelgood.name = @"Я Здоров!";
    ifeelgood.description = @"Способы устранения болезней";
    ifeelgood.iconName = @"ifeelgood.png";
    ifeelgood.appId = 503469761;
    
    [self.apps addObject:ifeelgood];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 0;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 80.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";//@"Другие наши приложения:";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.apps.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDescription *currentApp = (AppDescription *)[self.apps objectAtIndex:indexPath.row];
    NSLog (@"Selected app: %i", currentApp.appId);
    
    [self openAppPage:currentApp.appId];
    
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.highlightedTextColor = [UIColor blackColor];
        //cell.textLabel.font = [UIFont fontWithName:@"days" size:18.0];
	}
    
    AppDescription *currentApp = (AppDescription *)[self.apps objectAtIndex:indexPath.row];
    
    cell.textLabel.text = currentApp.name;
    cell.detailTextLabel.font = [UIFont fontWithName:@"Marker Felt" size:14];
    cell.detailTextLabel.text = currentApp.description;
    cell.tag = currentApp.appId;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    [cell.imageView setImage:[currentApp icon]];
    
    cell.backgroundColor = [UIColor clearColor];

    return cell;
}

- (IBAction)done:(id)sender
{
    //[self.delegate otherAppsViewControllerDidFinish:self];
    [self.navigationController popViewControllerAnimated: YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
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

- (void)updateAdBannerPosition {
    self.tableView.tableHeaderView = self.adBanner;
    
}

#endif

@end
