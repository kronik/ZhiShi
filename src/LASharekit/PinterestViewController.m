//
//  PinterestViewController.m
//  El Naturalista
//
//  Created by Luis Ascorbe on 09/11/12.
//  Copyright (c) 2012 Luis Ascorbe. All rights reserved.
//
/*
 
 LASharekit is available under the MIT license.
 
 Copyright © 2012 Luis Ascorbe.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "PinterestViewController.h"

@interface PinterestViewController ()
{
    IBOutlet UIWebView *webView;
    IBOutlet UIActivityIndicatorView *spinner;
}

@property (nonatomic, retain) NSString *desc;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSURL *imageUrl;

- (IBAction)closeWebVIew:(id)sender;

@end

@implementation PinterestViewController

- (id)init:(NSURL *)url_ imageUrl:(NSURL *)imageUrl_ description:(NSString *)desc_
{
    self = [super init];
    if (self)
    {
        NSAssert(url_, @"Url must not be nil. (Pinterest)");
        NSAssert(imageUrl_, @"Image URL must not be nil. (Pinterest)");
        
        // Customize
        self.url        = url_;
        self.imageUrl   = imageUrl_;
        self.desc       = desc_;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *htmlString = [self generatePinterestHTML];
    NSLog(@"Generated HTML String:%@", htmlString);
    //webView.backgroundColor = [UIColor clearColor];
    //webView.opaque = NO;
    [webView loadHTMLString:htmlString baseURL:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#if !__has_feature(objc_arc)
- (void)dealloc
{
    if (_desc)
        [_desc release];
    [_url release];
    [_imageUrl release];
    
    [super dealloc];
}
#endif

#pragma mark - WebView

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [spinner startAnimating];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [spinner stopAnimating];
}

#pragma mark - FUNCTIONS

- (NSString*) generatePinterestHTML
{
    NSString *sUrl = [self.url absoluteString];
    NSString *sImageUrl = [self.imageUrl absoluteString];
    NSLog(@"URL:%@", sUrl);
    
    NSString *protectedUrl = [sUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *protectedImageUrl = [sImageUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Protected URL:%@", protectedUrl);
    NSString *imageUrl = [NSString stringWithFormat:@"\"%@\"", protectedImageUrl];
    NSString *buttonUrl = [NSString stringWithFormat:@"\"http://pinterest.com/pin/create/button/?url=%@&media=%@&description=%@\"", protectedUrl, protectedImageUrl, self.desc];
    
    
    NSMutableString *htmlString = [[NSMutableString alloc] initWithCapacity:1000];
    [htmlString appendFormat:@"<html> <body>"];
    [htmlString appendFormat:@"<p align=\"center\"><a href=%@ class=\"pin-it-button\" count-layout=\"horizontal\"><img border=\"0\" src=\"http://assets.pinterest.com/images/PinExt.png\" title=\"Pin It\" /></a></p>", buttonUrl];
    [htmlString appendFormat:@"<p align=\"center\"><img src=%@></img></p>", imageUrl]; //width=\"400px\" height = \"400px\"
    [htmlString appendFormat:@"<script type=\"text/javascript\" src=\"//assets.pinterest.com/js/pinit.js\"></script>"];
    [htmlString appendFormat:@"</body> </html>"];
    return htmlString;
}

- (IBAction)closeWebVIew:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
