//
//  LASharekit.m
//
//  Created by Luis Ascorbe on 08/11/12.
//  Copyright (c) 2012 Luis Ascorbe. All rights reserved.
//
/*
 
 LASharekit is available under the MIT license.
 
 Copyright © 2012 Luis Ascorbe.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */



#import <Twitter/Twitter.h>
#import <Social/Social.h>
#import <objc/runtime.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <FacebookSDK/FacebookSDK.h>
#import "Vkontakte.h"

#import "LASharekit.h"
#import "PinterestViewController.h"
#import "REComposeViewController.h"

#define SYSTEM_VERSION_LESS_THAN(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define BLOCK_DONE                      @"BlockDone"
#define BLOCK_CANCELED                  @"BlockCanceled"
#define BLOCK_FAILED                    @"BlockFailed"
#define BLOCK_SAVED                     @"BlockSaved"


typedef enum {
    typeDone = 1,
    typeCanceled,
    typeFailed,
    typeSaved
}typeResult;

typedef enum {
    typeString = 1,
    typeUrl,
    typeImage
}copyType;

#pragma mark -

@interface LASharekit () <MFMailComposeViewControllerDelegate, FBLoginViewDelegate, UIAlertViewDelegate>

// Controller   -> Is used to present modalViews (is the target)
// title        -> Is used for the title in facebook, twitter and pinterest, then in the subject for email
// Text         -> Is used for the text in facebook, twitter and pinterest, then in the boddy for email
// Url          -> Is used for the url in facebook, twitter and pinterest, then in the boddy for email
// ImageUrl     -> Is used for pinterest, to show the image
// Image        -> Is used for the image in facebook, twitter and pinterest, then in the attached for email and to save in the cameraroll
// tweetCC      -> Is used to insert a cc on the tweet

@end

#pragma mark -

@implementation LASharekit

- (id)init
{
    self = [super init];
    if (self)
    {
        self.controller     = nil;
        self.title          = nil;
        self.text           = nil;
        self.url            = nil;
        self.imageUrl       = nil;
        self.image          = nil;
        self.tweetCC        = nil;
    }
    return self;
}

- (id)init:(id)controller_
{
    self = [super init];
    if (self)
    {
        self.controller     = controller_;
        self.title          = nil;
        self.text           = nil;
        self.url            = nil;
        self.imageUrl       = nil;
        self.image          = nil;
        self.tweetCC        = nil;
    }
    return self;
}

- (id)init:(id)controller_ title:(NSString *)title_ text:(NSString *)text_ image:(UIImage *)image_ url:(NSURL *)url_
{
    self = [super init];
    if (self)
    {
        self.controller     = controller_;
        self.title          = title_;
        self.text           = text_;
        self.url            = url_;
        self.imageUrl       = nil;
        self.image          = image_;
        self.tweetCC        = nil;
    }
    return self;
}

- (id)init:(id)controller_ title:(NSString *)title_ text:(NSString *)text_ image:(UIImage *)image_ url:(NSURL *)url_ imageUrl:(NSURL *)imageUrl_
{
    self = [super init];
    if (self)
    {
        self.controller     = controller_;
        self.title          = title_;
        self.text           = text_;
        self.url            = url_;
        self.imageUrl       = imageUrl_;
        self.image          = image_;
        self.tweetCC        = nil;
    }
    return self;
}

- (id)init:(id)controller_ title:(NSString *)title_ text:(NSString *)text_ image:(UIImage *)image_ url:(NSURL *)url_  completionDone:(MyCompletionBlock)blockDone completionCanceled:(MyCompletionBlock)blockCanceled
{
    self = [super init];
    if (self)
    {
        objc_setAssociatedObject(self, BLOCK_DONE, blockDone, OBJC_ASSOCIATION_COPY);
        objc_setAssociatedObject(self, BLOCK_CANCELED, blockCanceled, OBJC_ASSOCIATION_COPY);
        
        self.controller     = controller_;
        self.title          = title_;
        self.text           = text_;
        self.url            = url_;
        self.imageUrl       = nil;
        self.image          = image_;
        self.tweetCC        = nil;
    }
    return self;
}

- (id)init:(id)controller_ title:(NSString *)title_ text:(NSString *)text_ image:(UIImage *)image_ url:(NSURL *)url_  imageUrl:(NSURL *)imageUrl_ completionDone:(MyCompletionBlock)blockDone completionCanceled:(MyCompletionBlock)blockCanceled
{
    self = [super init];
    if (self)
    {
        objc_setAssociatedObject(self, BLOCK_DONE, blockDone, OBJC_ASSOCIATION_COPY);
        objc_setAssociatedObject(self, BLOCK_CANCELED, blockCanceled, OBJC_ASSOCIATION_COPY);
        
        self.controller     = controller_;
        self.title          = title_;
        self.text           = text_;
        self.url            = url_;
        self.imageUrl       = imageUrl_;
        self.image          = image_;
        self.tweetCC        = nil;
    }
    return self;
}

- (id)initWithImage:(UIImage *)image_
{
    self = [super init];
    if (self)
    {
        NSAssert(image_, @"Image must not be nil.");
        
        self.controller     = nil;
        self.title          = nil;
        self.text           = nil;
        self.url            = nil;
        self.imageUrl       = nil;
        self.image          = image_;
        self.tweetCC        = nil;
    }
    return self;
}

#if !__has_feature(objc_arc)
- (void)dealloc
{
    [_controller release];
    [_title release];
    [_text release];
    [_url release];
    [_imageUrl release];
    [_image release];
    [_tweetCC release];
    
    objc_removeAssociatedObjects(self);
    
    [super dealloc];
}
#endif

#pragma mark - BLOQUES

- (void) setCompletionDone:(MyCompletionBlock)blockDone
{
    objc_setAssociatedObject(self, BLOCK_DONE, blockDone, OBJC_ASSOCIATION_COPY);
}

- (void) setCompletionCanceled:(MyCompletionBlock)blockCanceled
{
    objc_setAssociatedObject(self, BLOCK_CANCELED, blockCanceled, OBJC_ASSOCIATION_COPY);
}

- (void) setCompletionFailed:(MyCompletionBlock)blockFailed
{
    objc_setAssociatedObject(self, BLOCK_FAILED, blockFailed, OBJC_ASSOCIATION_COPY);
}

- (void) setCompletionSaved:(MyCompletionBlock)blockSaved
{
    objc_setAssociatedObject(self, BLOCK_SAVED, blockSaved, OBJC_ASSOCIATION_COPY);
}

#pragma mark - FUNCTIONS

- (void)setController:(id)controller_ title:(NSString *)title_ text:(NSString *)text_ image:(UIImage *)image_ url:(NSURL *)url_
{
    self.controller     = controller_;
    self.title          = title_;
    self.text           = text_;
    self.url            = url_;
    self.imageUrl       = nil;
    self.image          = image_;
    self.tweetCC        = nil;
}

- (void)setController:(id)controller_ title:(NSString *)title_ text:(NSString *)text_ image:(UIImage *)image_ url:(NSURL *)url_ imageUrl:(NSURL *)imageUrl_
{
    self.controller     = controller_;
    self.title          = title_;
    self.text           = text_;
    self.url            = url_;
    self.imageUrl       = imageUrl_;
    self.image          = image_;
    self.tweetCC        = nil;
}

- (void)setController:(id)controller_ title:(NSString *)title_ text:(NSString *)text_ image:(UIImage *)image_ url:(NSURL *)url_ completionDone:(MyCompletionBlock)blockDone completionCanceled:(MyCompletionBlock)blockCanceled
{
    objc_setAssociatedObject(self, BLOCK_DONE, blockDone, OBJC_ASSOCIATION_COPY);
    objc_setAssociatedObject(self, BLOCK_CANCELED, blockCanceled, OBJC_ASSOCIATION_COPY);
    
    self.controller     = controller_;
    self.title          = title_;
    self.text           = text_;
    self.url            = url_;
    self.imageUrl       = nil;
    self.image          = image_;
    self.tweetCC        = nil;
}

- (void)setController:(id)controller_ title:(NSString *)title_ text:(NSString *)text_ image:(UIImage *)image_ url:(NSURL *)url_ imageUrl:(NSURL *)imageUrl_ completionDone:(MyCompletionBlock)blockDone completionCanceled:(MyCompletionBlock)blockCanceled
{
    objc_setAssociatedObject(self, BLOCK_DONE, blockDone, OBJC_ASSOCIATION_COPY);
    objc_setAssociatedObject(self, BLOCK_CANCELED, blockCanceled, OBJC_ASSOCIATION_COPY);
    
    self.controller     = controller_;
    self.title          = title_;
    self.text           = text_;
    self.url            = url_;
    self.imageUrl       = imageUrl_;
    self.image          = image_;
    self.tweetCC        = nil;
}

#pragma mark - SHARE

// Vkontakte
- (void) vkPost
{
    if (YES /* is vk auth ok?*/)
    {
        REComposeViewController *composeViewController = [[REComposeViewController alloc] init];
#if !__has_feature(objc_arc)
        [composeViewController autorelease];
#endif
        composeViewController.hasAttachment = YES;
        composeViewController.attachmentImage = self.image;
        composeViewController.text = self.text;
        
        // Service name
        UILabel *titleView          = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 110, 30)];
        titleView.font              = [UIFont boldSystemFontOfSize:17.0];
        titleView.textAlignment     = NSTextAlignmentCenter;
        titleView.backgroundColor   = [UIColor clearColor];
        titleView.textColor         = [UIColor whiteColor];
        titleView.text              = @"ВКонтакте";
        composeViewController.navigationItem.titleView = titleView;
        
        // UIApperance setup
        // Facebook colors
        composeViewController.navigationBar.tintColor                       = [UIColor colorWithRed:0.34f green:0.48f blue:0.64f alpha:1.00f];
        //composeViewController.navigationItem.leftBarButtonItem.tintColor    = [UIColor colorWithRed:70.0/255.0 green:91.0/255.0 blue:192.0/255.0 alpha:1.0];
        //composeViewController.navigationItem.rightBarButtonItem.tintColor   = [UIColor colorWithRed:70.0/255.0 green:91.0/255.0 blue:192.0/255.0 alpha:1.0];
        
        // Alternative use with REComposeViewControllerCompletionHandler
        composeViewController.completionHandler = ^(REComposeResult result)
        {
            switch (result)
            {
                case REComposeResultCancelled:
                    [self completionResult:typeCanceled];
                    break;
                    
                case REComposeResultPosted:
//                    [self performPublishAction:^{
//                        
//                        // paso los parametros para mandar al feed del usuario
//                        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                                       UIImagePNGRepresentation(self.image), @"source",
//                                                       self.text, @"message",
//                                                       [self.url absoluteString], @"link",
//                                                       self.title, @"caption",
//                                                       self.imageUrl, @"picture",
//                                                       @"Жи-Ши", @"name",
//                                                       nil];
//                        [FBRequestConnection startWithGraphPath:@"me/feed"
//                                                     parameters:params
//                                                     HTTPMethod:@"POST"
//                                              completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                                                  
//                                                  if (!error)
//                                                  {
//                                                      [self completionResult:typeDone];
//                                                  }
//                                                  else
//                                                  {
//                                                      NSLog(@"ERROR AT 'startWithGraphPath': %@", [error localizedDescription]);
//                                                      [self completionResult:typeCanceled];
//                                                  }
//                                              }];
//                    }];
                    break;
                    
                default:
                    break;
            }
        };
        
        [self.controller presentViewController:composeViewController animated:YES completion:nil];
    }
}

// FACEBOOK
- (void) facebookPost
{
    //share to facebook
    // esto lo hago solo si la version del sistema es menor a la 6.0
    if (SYSTEM_VERSION_LESS_THAN(@"6.0"))
    {
        // If the session is open, do the post, if not, try login
        if (FBSession.activeSession.isOpen)
        {
            // if it is available to us, we will post using the native dialog
            BOOL displayedNativeDialog = [FBNativeDialogs presentShareDialogModallyFrom:self.controller
                                                                            initialText:self.text
                                                                                  image:self.image
                                                                                    url:self.url
                                                                                handler:nil];
            
            // si no presenta caja de dialogo nativo del sistema, presento una propia
            if (!displayedNativeDialog)
            {
                REComposeViewController *composeViewController = [[REComposeViewController alloc] init];
#if !__has_feature(objc_arc)
                [composeViewController autorelease];
#endif
                composeViewController.hasAttachment = YES;
                composeViewController.attachmentImage = self.image;
                composeViewController.text = self.text;
                
                // Service name 
                UILabel *titleView          = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 110, 30)];
                titleView.font              = [UIFont boldSystemFontOfSize:17.0];
                titleView.textAlignment     = NSTextAlignmentCenter;
                titleView.backgroundColor   = [UIColor clearColor];
                titleView.textColor         = [UIColor whiteColor];
                titleView.text              = @"Facebook";
                composeViewController.navigationItem.titleView = titleView;
                
                // UIApperance setup
                // Facebook colors
                composeViewController.navigationBar.tintColor                       = [UIColor colorWithRed:44.0/255.0 green:67.0/255.0 blue:136.0/255.0 alpha:1.0];
                //composeViewController.navigationItem.leftBarButtonItem.tintColor    = [UIColor colorWithRed:70.0/255.0 green:91.0/255.0 blue:192.0/255.0 alpha:1.0];
                //composeViewController.navigationItem.rightBarButtonItem.tintColor   = [UIColor colorWithRed:70.0/255.0 green:91.0/255.0 blue:192.0/255.0 alpha:1.0];
                
                // Alternative use with REComposeViewControllerCompletionHandler
                composeViewController.completionHandler = ^(REComposeResult result)
                {
                    switch (result)
                    {
                        case REComposeResultCancelled:
                            [self completionResult:typeCanceled];
                            break;
                            
                        case REComposeResultPosted:
                            [self performPublishAction:^{
                                
                                // paso los parametros para mandar al feed del usuario 
                                NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                               UIImagePNGRepresentation(self.image), @"source",
                                                               self.text, @"message",
                                                               [self.url absoluteString], @"link",
                                                               self.title, @"caption",
                                                               self.imageUrl, @"picture",
                                                               @"Жи-Ши", @"name",
                                                               nil];
                                [FBRequestConnection startWithGraphPath:@"me/feed"
                                                             parameters:params
                                                             HTTPMethod:@"POST"
                                                      completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                                           
                                                           if (!error)
                                                           {
                                                               [self completionResult:typeDone];
                                                           }
                                                           else
                                                           {
                                                               NSLog(@"ERROR AT 'startWithGraphPath': %@", [error localizedDescription]);
                                                               [self completionResult:typeCanceled];
                                                           }
                                                       }];
                            }];
                            break;
                            
                        default:
                            break;
                    }
                };
                
                [self.controller presentViewController:composeViewController animated:YES completion:nil];
            }
        }
        else
        {
            [self openSessionWithAllowLoginUI:YES];
        }
    }
    else
    {
        NSAssert(self.controller, @"ViewController must not be nil.");
        
        SLComposeViewController *socialComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        if (self.title != nil)
            [socialComposer setTitle:self.title];
        if (self.text != nil)
            [socialComposer setInitialText:self.text];
        if (self.url != nil)
            [socialComposer addURL:self.url];
        if (self.image != nil)
            [socialComposer addImage:self.image];
        
        [socialComposer setCompletionHandler:^(SLComposeViewControllerResult result){
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    [self completionResult:typeCanceled];
                    
                    break;
                case SLComposeViewControllerResultDone:
                    [self completionResult:typeDone];
                    
                    break;
                default:
                    [self completionResult:typeFailed];
                    break;
            }
            
            //[controller dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [self.controller presentModalViewController:socialComposer animated:YES];
    }
}

// TWITTER
- (void) tweet
{
    NSAssert(self.controller, @"ViewController must not be nil.");
    
    // share to twitter
    // esto lo hago solo si la version del sistema es menor al 6.0
    if (SYSTEM_VERSION_LESS_THAN(@"6.0"))
    {
        TWTweetComposeViewController *tweetVC = [[TWTweetComposeViewController alloc] init];
#if !__has_feature(objc_arc)
        [tweetVC autorelease];
#endif
        
        // IMAGE
        if (self.image != nil)
            [tweetVC addImage:self.image];
        
        // TEXT
        if (self.text != nil)
        {
            // URL AND TWEETCC
            // creo el formato del texto a twittear
            NSString *format    = @"“%@”";
            if (self.url != nil)
                format          = [format stringByAppendingFormat:@" %@", [self.url absoluteString]];
            if (self.tweetCC != nil)
                format          = [format stringByAppendingFormat:@" %@", self.tweetCC];
            
            // TEXT
            NSUInteger idx      = self.text.length;
            // le quito todos los espacios que tenga el texto al principio y al final
            while([self.text hasPrefix:@" "])
                self.text = [self.text substringFromIndex:1];
            while([self.text hasSuffix:@" "])
            {
                idx       = idx-1;
                self.text = [self.text substringToIndex:idx];
            }
            
            
            // creo el mensaje
            NSString *message   = [NSString stringWithFormat:format, [NSString stringWithFormat:@"%@", [self.text substringToIndex:idx]]];
            
            // if the message is bigger than 140 characters, then cut the message
            while (![tweetVC setInitialText:message])
            {
                idx -= 5;
                if (idx > 5)
                {
                    message = [NSString stringWithFormat:format, [NSString stringWithFormat:@"%@", [self.text substringToIndex:idx]]];
                }
                else
                {
                    [tweetVC setInitialText:[self.url absoluteString]];
                    break;
                }
            }
        }
        else
        {
            [tweetVC setInitialText:[self.url absoluteString]];
        }
        
        
        //if (self.title != nil)
            //[tweetVC setTitle:self.title];
        //if (self.text != nil)
            //[tweetVC setInitialText:self.text];
        //if (self.url != nil)
            //[tweetVC addURL:self.url];
        
        [tweetVC setCompletionHandler:^(TWTweetComposeViewControllerResult result){
            switch (result) {
                case TWTweetComposeViewControllerResultCancelled:
                    [self completionResult:typeCanceled];
                    
                    break;
                case TWTweetComposeViewControllerResultDone:
                    [self completionResult:typeDone];
                    
                    break;
                default:
                    [self completionResult:typeFailed];
                    break;
            }
        }];
        
        [self.controller presentModalViewController:tweetVC animated:YES];
    }
    else
    {
        SLComposeViewController *socialComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        // IMAGE
        if (self.image != nil)
            [socialComposer addImage:self.image];
        
        // TEXT
        if (self.text != nil)
        {
            // URL AND TWEETCC
            // creo el formato del texto a twittear
//            NSString *format    = @"“%@”";
//            if (self.url != nil)
//                format          = [format stringByAppendingFormat:@" %@", [self.url absoluteString]];
//            if (self.tweetCC != nil)
//                format          = [format stringByAppendingFormat:@" %@", self.tweetCC];
            
            
            // TEXT
            NSUInteger idx      = self.text.length;
            // le quito todos los espacios que tenga el texto al principio y al final
            while([self.text hasPrefix:@" "])
                self.text = [self.text substringFromIndex:1];
            while([self.text hasSuffix:@" "])
            {
                idx       = idx-1;
                self.text = [self.text substringToIndex:idx];
            }
            // creo el mensaje
            NSString *message   = [NSString stringWithFormat:@"%@…", [self.text substringToIndex:idx]];
            
            
            // if the message is bigger than 140 characters, then cut the message
            while (![socialComposer setInitialText:message])
            {
                idx -= 5;
                if (idx > 5)
                {
                    message = [NSString stringWithFormat:@"%@…", [self.text substringToIndex:idx]];
                }
                else
                {
                    [socialComposer setInitialText:[self.url absoluteString]];
                    break;
                }
            }
        }
        else
        {
            [socialComposer setInitialText:[self.url absoluteString]];
        }
        
        
        
        /*if (self.title != nil)
            [socialComposer setTitle:self.title];
        if (self.text != nil)
            [socialComposer setInitialText:self.text];
        if (self.url != nil)
            [socialComposer addURL:self.url];
        if (self.image != nil)
            [socialComposer addImage:self.image];*/
        
        [socialComposer setCompletionHandler:^(SLComposeViewControllerResult result){
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    [self completionResult:typeCanceled];
                    
                    break;
                case SLComposeViewControllerResultDone:
                    [self completionResult:typeDone];
                    
                    break;
                default:
                    [self completionResult:typeFailed];
                    break;
            }
            
            //[controller dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [self.controller presentModalViewController:socialComposer animated:YES];
    }
}

// PINTEREST
- (void) pinIt
{
    NSAssert(_url, @"Url must not be nil.");
    NSAssert(_imageUrl, @"ImageUrl must not be nil for Pinterest.");
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"pinit12://pinterest.com/pin/create/bookmarklet/?url=%@&media=%@&description=%@\"", self.url, self.imageUrl, self.text]];
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
    else
    {
        // ask for download the app
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Pinterest", @"")
                                                        message:NSLocalizedString(@"Would you like to download Pinterest Application to share?", @"")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                              otherButtonTitles:NSLocalizedString(@"App Store", @""), NSLocalizedString(@"Open pinterest.com", @""), nil];
        
        [alert show];
        
        // else
        /*
         PinterestViewController *pinVC = [[PinterestViewController alloc] init:self.url imageUrl:self.imageUrl description:self.text];
         [self.controller presentModalViewController:pinVC animated:YES];
         
         #if !__has_feature(objc_arc)
         [pinVC autorelease];
         #endif
         */
    }
}

// EMAIL
- (void) emailIt
{
    if ([MFMailComposeViewController canSendMail]==YES)
    {
        NSAssert(self.controller, @"ViewController must not be nil.");
        
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        if (self.title)
            [controller setSubject:self.title];
        
        //Create a string with HTML formatting for the email body
        NSMutableString *emailBody = [[[NSMutableString alloc] initWithString:@"<html><body>"] retain];
        //Add some text to it however you want
        if (self.url)
        {
            NSString *strURL = [self.url absoluteString];
            [emailBody appendString:[NSString stringWithFormat:@"<p><a href='%@'>%@</a></p>", strURL, strURL]];
        }
        if (self.text)
            [emailBody appendString:[NSString stringWithFormat:@"<p>%@</p>", self.text]];
        
        //close the HTML formatting
        [emailBody appendString:@"</body></html>"];
        
        [controller setMessageBody:emailBody isHTML:YES];
            
        if (self.image)
        {
            NSData *data = UIImagePNGRepresentation(self.image);
            [controller addAttachmentData:data mimeType:@"image/png" fileName:@"image"];
        }
        
        if (controller) [self.controller presentModalViewController:controller animated:YES];
#if !__has_feature(objc_arc)
        [controller release];
#endif
    }
    else
    {
        NSString *deviceType        = [UIDevice currentDevice].model;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
                                                        message:[NSString stringWithFormat:NSLocalizedString(@"Your %@ must have an email account set up", @""), deviceType]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Ok", @"")
                                              otherButtonTitles:nil];
        [alert show];
#if !__has_feature(objc_arc)
        [alert release];
#endif
    }
}

// IMAGE
- (void) saveImage
{
    NSAssert(self.image, @"Image must not be nil.");
    
    if (self.image)
    {
        UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

#pragma mark - PasteBoard

// TITLE
- (void) copyTitleToPasteboard
{
    NSAssert(self.title, @"Title must not be nil.");
    
    [self copyToPasteBoard:self.title type:typeString];
}
// TEXT
- (void) copyTextToPasteboard
{
    NSAssert(self.text, @"Text must not be nil.");
    
    [self copyToPasteBoard:self.text type:typeString];
}
// URL
- (void) copyUrlToPasteboard
{
    NSAssert(self.url, @"Url must not be nil.");
    
    [self copyToPasteBoard:self.url type:typeUrl];
}
// IMAGE
- (void) copyImageToPasteboard
{
    NSAssert(self.image, @"Image must not be nil.");
    
    [self copyToPasteBoard:self.image type:typeImage];
}
// IMAGEURL
- (void) copyImageUrlToPasteboard
{
    NSAssert(self.imageUrl, @"ImageUrl must not be nil.");
    
    [self copyToPasteBoard:self.imageUrl type:typeUrl];
}

- (void) copyToPasteBoard:(id)toCopy type:(copyType)type
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    switch (type)
    {
        case typeString:
            [pasteboard setString:toCopy];
            break;
            
        case typeUrl:
            [pasteboard setURL:toCopy];
            break;
            
        case typeImage:
            [pasteboard setImage:toCopy];
            break;
            
        default:
            break;
    }
}

#pragma mark - Facebook

// Convenience method to perform some action that requires the "publish_actions" permissions.
- (void) performPublishAction:(void (^)(void)) action
{
    // we defer request for permission to post to the moment of post, then we check for the permission
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound)
    {
        // if we don't already have the permission, then we request it now
        [FBSession.activeSession reauthorizeWithPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                                   defaultAudience:FBSessionDefaultAudienceEveryone
                                                 completionHandler:^(FBSession *session, NSError *error) {
                                                     if (!error)
                                                     {
                                                         action();
                                                     }
                                                     else
                                                     {
                                                         [self completionResult:typeCanceled];
                                                     }
                                                 }];
    }
    else
    {
        action();
    }
    
}


- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI
{
    return [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                              defaultAudience:FBSessionDefaultAudienceEveryone
                                                 allowLoginUI:allowLoginUI
                                            completionHandler:^(FBSession *session,
                                                             FBSessionState state,
                                                             NSError *error) {
                                                if (!error)
                                                {
                                                    [self facebookPost];
                                                }
                                                else
                                                {
                                                    [self completionResult:typeCanceled];
                                                }
                                            }];
                                             
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0: // cancel
            
            break;
            
        case 1: // download the app
            NSLog(@"");
            NSString *stringURL = @"http://itunes.apple.com/us/app/pinterest/id429047995?mt=8";
            NSURL *url = [NSURL URLWithString:stringURL];
            [[UIApplication sharedApplication] openURL:url];
            
            break;
            
        case 2: // open pinterest.com
            NSLog(@"");
            PinterestViewController *pinVC = [[PinterestViewController alloc] init:self.url imageUrl:self.imageUrl description:self.text];
            [self.controller presentModalViewController:pinVC animated:YES];
            
#if !__has_feature(objc_arc)
            [pinVC autorelease];
#endif
            break;
            
        default:
            break;
    }
}

#pragma mark - MailComposeDelegate

- (void)mailComposeController:(MFMailComposeViewController*)mailController  didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
{
    switch (result)
    {
        case MFMailComposeResultSent:
            [self completionResult:typeDone];
            
            break;
            
        case MFMailComposeResultCancelled:
            [self completionResult:typeCanceled];
            
            break;
            
        case MFMailComposeResultFailed:
            [self completionResult:typeFailed];
            
            break;
            
        case MFMailComposeResultSaved:
            [self completionResult:typeSaved];
            
            break;
            
        default:
            break;
    }
    
    [mailController dismissModalViewControllerAnimated:YES];
}

#pragma mark - ImageSave

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    if (!error)
        [self saved];
    else
        [self failed];
}

#pragma mark - RESULTS

- (void) completionResult:(typeResult)result
{
    switch (result) {
        case typeDone:
            [self done];
            
            break;
        case typeCanceled:
            [self cancelled];
            
            break;
            
        case typeFailed:
            [self failed];
            
            break;
            
        case typeSaved:
            [self saved];
            
            break;
            
        default:
            [self cancelled];
            
            break;
    }
}

- (void) done
{
    MyCompletionBlock _completionBlock = (MyCompletionBlock)objc_getAssociatedObject(self, BLOCK_DONE);
    if (_completionBlock != nil)
    {
        _completionBlock();
    }
}

- (void) cancelled
{
    MyCompletionBlock _canceledBlock = (MyCompletionBlock)objc_getAssociatedObject(self, BLOCK_CANCELED);
    if (_canceledBlock != nil)
    {
        _canceledBlock();
    }
}

- (void) failed
{
    MyCompletionBlock _completionBlock = (MyCompletionBlock)objc_getAssociatedObject(self, BLOCK_FAILED);
    if (_completionBlock != nil)
    {
        _completionBlock();
    }
}

- (void) saved
{
    MyCompletionBlock _completionBlock = (MyCompletionBlock)objc_getAssociatedObject(self, BLOCK_SAVED);
    if (_completionBlock != nil)
    {
        _completionBlock();
    }
}

@end














