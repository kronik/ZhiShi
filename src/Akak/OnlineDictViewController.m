//
//  OnlineDictViewController.m
//  Akak
//
//  Created by dima on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OnlineDictViewController.h"
#import "Resources.h"
#import "AdWhirlView.h"

@interface OnlineDictViewController()

@property (nonatomic) BOOL alreadyLoaded;

@end

@implementation OnlineDictViewController

@synthesize webView = _webView;
@synthesize delegate = _delegate;
@synthesize word = _word;
@synthesize searchURL = _searchURL;
@synthesize av = _av;
@synthesize bannerView = _bannerView;
@synthesize localHtml = _localHtml;
@synthesize bannerIsVisible = _bannerIsVisible;
@synthesize myAdView = _myAdView;
@synthesize alreadyLoaded = _alreadyLoaded;

#if LITE_VER == 1
@synthesize adView;
#endif

- (void)goBack
{
    [self.navigationController popViewControllerAnimated: YES];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    //Obtaining the current device orientation
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown)
    {
        return;
    }
    
    if (self.av == nil)
    {
        return;
    }
    
    CGRect cgRect =[[UIScreen mainScreen] bounds];
    CGSize cgSize = cgRect.size;
    
    if (UIDeviceOrientationIsPortrait(orientation))
    {
        self.av.center = CGPointMake(cgSize.width/2, cgSize.height/3);
    }
    else
    {
        self.av.center = CGPointMake(cgSize.height/2, cgSize.width/3);
    }
}

-(BOOL) canPerformAction:(SEL)action withSender:(id)sender
{
    return NO;
}

- (void)viewDidLoad
{   
    [super viewDidLoad]; 

    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
    
    self.webView.backgroundColor = UIColorFromRGB(0xFFF4CB);
    
    UIImage *navBarImage = [UIImage imageNamed:@"ipad-menubar"];
    [[UINavigationBar appearance] setBackgroundImage:navBarImage forBarMetrics:UIBarMetricsDefault];
    
    UIImage* buttonImage = [UIImage imageNamed:@"back.png"];
    
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.navigationItem.title = self.header;
    
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],UITextAttributeTextColor,
                                               [UIColor blackColor], UITextAttributeTextShadowColor,
                                               [NSValue valueWithUIOffset:UIOffsetMake(-1, 0)], UITextAttributeTextShadowOffset, nil];
    
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    
    NSString *urlAddress = [[NSString alloc] initWithFormat:self.searchURL, self.word];
    
	//Create a URL object FROM THAT STRING
	NSURL *url = [NSURL URLWithString:[urlAddress stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
	
	//URL Requst Object CREATD FROM YOUR URL OBJECT
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    if (self.word != nil && [self.word isEqualToString:@""] != YES)
    {
        [self.webView loadRequest:requestObj];
    }
    else
    {
        [self.webView loadHTMLString:self.localHtml baseURL:baseURL];        
    }
    
#if LITE_VER == 1
    self.adView = [AdWhirlView requestAdWhirlViewWithDelegate:self];
    self.adView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:self.adView];
    
    [self adjustAdSize];
#endif 
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    CGRect cgRect = self.view.bounds;
    CGSize cgSize = cgRect.size;
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    self.av = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle
               :UIActivityIndicatorViewStyleGray];
	self.av.frame=CGRectMake(130, 180, 50, 50);
	self.av.tag  = 1;
    
    if (UIDeviceOrientationIsPortrait(orientation))
    {
        self.av.center = CGPointMake(cgSize.width/2, cgSize.height/3);
    }
    else
    {
        self.av.center = CGPointMake(cgSize.width/2, cgSize.height/3);
    }
    
	[self.webView addSubview:self.av];
	[self.av startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	UIActivityIndicatorView *tmpimg = (UIActivityIndicatorView *)[webView viewWithTag:1];
	[tmpimg removeFromSuperview];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{    
    UIActivityIndicatorView *tmpimg = (UIActivityIndicatorView *)[webView viewWithTag:1];
	[tmpimg removeFromSuperview];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TXT message:UNABLE_TO_LOAD_WEBPAGE_TXT delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    //[self done:self];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (IBAction)done:(id)sender
{
    [self.delegate onlineDictViewControllerDidFinish:self];
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
#if LITE_VER == 1
    [self adjustAdSize];
    
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
        self.bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
    else
        self.bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
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
    return YES;
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
#endif

- (IBAction)buyFullVerButtonClicked: (UIButton*)button
{
#if RU_LANG == 1
    NSString *url = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?type=Purple+Software&id=493483440";
#else
    NSString *url = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?type=Purple+Software&id=496458462";
#endif
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

#pragma mark AdWhirl

#if LITE_VER == 1
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
