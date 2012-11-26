//
//  BCDShareSheet.m
//  BCDShareSheet
//
//  Created by Jake MacMullin on 18/01/12.
//  Copyright (c) 2012 Jake MacMullin.
//

#import "AppDelegate.h"
#import "MBProgressHUD.h"

typedef enum {
	BCDEmailService,
    BCDFacebookService,
    BCDTwitterService
} BCDService;

NSString * const kEmailServiceTitle = @"Email";
NSString * const kFacebookServiceTitle = @"Facebook";
NSString * const kTwitterServiceTitle = @"Twitter";

NSString * const kTitleKey = @"title";
NSString * const kServiceKey = @"service";

NSString * const kFBAccessTokenKey = @"FBAccessTokenKey";
NSString * const kFBExpiryDateKey = @"FBExpirationDateKey";

#import <Twitter/Twitter.h>
#import "BCDShareSheet.h"

typedef void (^CompletionBlock)(BCDResult);

@interface BCDShareSheet()

@property (nonatomic, retain) BCDShareableItem *item; // the item that will be shared
@property (nonatomic, copy) CompletionBlock completionBlock;
@property (nonatomic, retain) NSMutableArray *availableSharingServices; // services available for sharing
@property (nonatomic) BOOL waitingForFacebookAuthorisation;
@property (nonatomic, strong) MBProgressHUD *hud;

- (void)determineAvailableSharingServices;

- (void)shareViaEmail;
- (void)shareViaFacebook;
- (void)shareViaTwitter;

// Facebook integration
//- (void)initialiseFacebookIfNeeded;
//- (BOOL)checkIfFacebookIsAuthorised;
//- (void)showFacebookShareDialog;

@end


@implementation BCDShareSheet

@synthesize rootViewController = _rootViewController;
@synthesize facebookAppID = _facebookAppID;
@synthesize appName = _appName;
@synthesize hashTag = _hashTag;
@synthesize item = _item;
@synthesize completionBlock = _completionBlock;
@synthesize availableSharingServices = _availableSharingServices;
@synthesize waitingForFacebookAuthorisation = _waitingForFacebookAuthorisation;
@synthesize hud = _hud;

+ (BCDShareSheet *)sharedSharer {
    static BCDShareSheet *sharedInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedInstance = [[self alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:sharedInstance selector:@selector(sessionStateChanged:) name:FBSessionStateChangedNotification
         object:nil];
    });
    return sharedInstance;
}

- (void)dealloc {
    [self setItem:nil];
    [self setFacebookAppID:nil];
    [self setRootViewController:nil];
    [self setCompletionBlock:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (UIActionSheet *)sheetForSharing:(BCDShareableItem *)item completion:(void (^)(BCDResult))completionBlock {
    [self setItem:item];
    
    [self setCompletionBlock:completionBlock];
        
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Поделиться в:"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    [self determineAvailableSharingServices];
    for (NSDictionary *serviceDictionary in self.availableSharingServices)
    {
        [sheet addButtonWithTitle:[serviceDictionary valueForKey:kTitleKey]];
    }
    
    [sheet setCancelButtonIndex:[sheet addButtonWithTitle:@"Cancel"]];
    
    return sheet;
}

#pragma mark -
#pragma mark Action Sheet Delegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == [actionSheet cancelButtonIndex]) {
        if (self.completionBlock!=nil) {
            self.completionBlock(BCDResultCancel);
        }
        return;
    }
    
    int selectedService = [[[self.availableSharingServices objectAtIndex:buttonIndex] valueForKey:kServiceKey] intValue];
    
    switch (selectedService) {
        case BCDEmailService:
            [self shareViaEmail];
            break;
            
        case BCDFacebookService:
            [self shareViaFacebook];
            break;
            
        case BCDTwitterService:
            [self shareViaTwitter];
            break;
            
        default:
            break;
    }
}


#pragma mark -
#pragma mark MFMailComposeViewController Delegate Methods

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    [self.rootViewController dismissModalViewControllerAnimated:YES];
                            
                            if (error!=nil) {
                                if (self.completionBlock!=nil) {
                                    self.completionBlock(BCDResultFailure);
                                }
                            } else {
                                if (self.completionBlock!=nil) {
                                    self.completionBlock(BCDResultSuccess);
                                }
                            }
}


#pragma mark -
#pragma mark Private Methods

- (void)determineAvailableSharingServices {
    if (self.availableSharingServices==nil) {
        
        NSMutableArray *services = [NSMutableArray array];
        
        // Check to see if email if available
        if ([MFMailComposeViewController canSendMail]) {
            NSDictionary *mailService = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInt:BCDEmailService], kServiceKey, 
                                         kEmailServiceTitle, kTitleKey,
                                         nil];
            [services addObject:mailService];
        }
        
        NSDictionary *facebookService = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInt:BCDFacebookService], kServiceKey, 
                                     kFacebookServiceTitle, kTitleKey,
                                     nil];
        [services addObject:facebookService];

        // Twitter is only available on iOS5 or later
        if([TWTweetComposeViewController class]) {
            NSDictionary *twitterService = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSNumber numberWithInt:BCDTwitterService], kServiceKey, 
                                            kTwitterServiceTitle, kTitleKey,
                                            nil];
            [services addObject:twitterService];
        }
        
        [self setAvailableSharingServices:services];
    }
}

#pragma mark - Email

- (NSString *)messageBody
{
    NSMutableString *body = [NSMutableString string];
        
    if (self.item.description!=nil) {
        [body appendFormat:@"%@", self.item.description];
    }
    
    // Fill out the email body text
    NSMutableString *emailBody = [NSMutableString stringWithFormat:@"<div> \n"
                                  "<p style=\"font:17px Helvetica,Arial,sans-serif\">%@</p> \n"
                                  "<table border=\"0\"> \n"
                                  "<tbody> \n"
                                  "<tr> \n"
                                  "<td style=\"padding-right:10px;vertical-align:top\"> \n"
                                  "<a target=\"_blank\" href=\"%@\"><img height=\"170\" border=\"0\" src=\"%@\" alt=\"Cover Art\"></a> \n"
                                  "</td> \n"
                                  "<td style=\"vertical-align:top\"> \n"
                                  "<a target=\"_blank\" href=\"%@\" style=\"color: Black;text-decoration:none\"> \n"
                                  "<h1 style=\"font:bold 16px Helvetica,Arial,sans-serif\">%@</h1> \n"
                                  "<p style=\"font:14px Helvetica,Arial,sans-serif;margin:0 0 2px\">%@</p> \n"
                                  "<p style=\"font:14px Helvetica,Arial,sans-serif;margin:0 0 2px\">Категория: %@</p> \n"
                                  "</a> \n"
                                  "<p style=\"font:14px Helvetica,Arial,sans-serif;margin:0\"> \n"
                                  "<a target=\"_blank\" href=\"%@\"><img src=\"http://ax.phobos.apple.com.edgesuite.net/email/images_shared/view_item_button.png\"></a> \n"
                                  "</p> \n"
                                  "</td> \n"
                                  "</tr> \n"
                                  "</tbody> \n"
                                  "</table> \n"
                                  "<br> \n"
                                  "<br> \n"
                                  "<table align=\"center\"> \n"
                                  "<tbody> \n"
                                  "<tr> \n"
                                  "<td valign=\"top\" align=\"center\"> \n"
                                  "<span style=\"font-family:Helvetica,Arial;font-size:11px;color:#696969;font-weight:bold\"> \n"
                                  "</td> \n"
                                  "</tr> \n"
                                  "<tr> \n"
                                  "<td align=\"center\"> \n"
                                  "<span style=\"font-family:Helvetica,Arial;font-size:11px;color:#696969\"> \n"
                                  "</span> \n"
                                  "</td> \n"
                                  "</tr> \n"
                                  "</tbody> \n"
                                  "</table> \n"
                                  "</div>",
                                  body,
                                  self.item.itemURLString,
                                  self.item.imageURLString,
                                  self.item.itemURLString,
                                  self.appName,
                                  @"",
                                  @"Образование",
                                  self.item.itemURLString];
    return emailBody;
}

- (void)shareViaEmail {
    MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
    [mailComposeViewController setMailComposeDelegate:self];
    [mailComposeViewController setSubject:self.item.title];
    
    [mailComposeViewController setMessageBody:[self messageBody] isHTML: YES];
    [self.rootViewController presentModalViewController:mailComposeViewController animated:YES];
}

#pragma mark - Facebook

- (void)publishStory
{
    NSMutableDictionary *postParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                             self.item.itemURLString, @"link",
                                             self.item.imageURLString, @"picture",
                                             @"Жи-Ши", @"name",
                                             self.item.title, @"caption",
                                             self.item.description, @"description", nil];
    
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.rootViewController.navigationController.view];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = @"Публикую...";
    self.hud.alpha = 0.7;
    
    [self.rootViewController.navigationController.view addSubview: self.hud];
    
    [self.hud show: YES];
    
    [FBRequestConnection startWithGraphPath:@"me/feed"
                                 parameters:postParams
                                 HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error)
    {
         NSString *alertText;
        
         [self.hud hide: YES];
         [self.hud removeFromSuperview];
    
         if (error)
         {
             alertText = [NSString stringWithFormat:
                          @"error: domain = %@, code = %d",
                          error.domain, error.code];
         }
         else
         {
             alertText = @"Отправлено в Facebook";
         }
        
         self.hud = [[MBProgressHUD alloc] initWithView:self.rootViewController.navigationController.view];
         self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
         self.hud.mode = MBProgressHUDModeCustomView;
         self.hud.labelText = alertText;
        
         [self.rootViewController.navigationController.view addSubview: self.hud];

         [self.hud show: YES];

         [self performSelector:@selector(hideHud) withObject:nil afterDelay:2.0];
         // Show the result in an alert
         //[[[UIAlertView alloc] initWithTitle:@"Результат:" message:alertText delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil] show];
     }];
}

- (void) hideHud
{
    [self.hud hide: YES];
    [self.hud removeFromSuperview];
}

- (void)sessionStateChanged:(NSNotification*)notification
{
    if (FBSession.activeSession.isOpen)
    {
        if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
            
            [FBSession.activeSession reauthorizeWithPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                                       defaultAudience:FBSessionDefaultAudienceFriends
                                                     completionHandler:^(FBSession *session, NSError *error) {
                                                         if (!error) {
                                                             // re-call assuming we now have the permission
                                                             [self sessionStateChanged: nil];
                                                         }
                                                     }];
        } else
        {
            [self publishStory];
        }
    }
    else
    {
    }
}

- (void) checkPermissionsAndSend
{
    // Ask for publish_actions permissions in context
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound)
    {
        // No permissions found in session, ask for it
        [FBSession.activeSession reauthorizeWithPublishPermissions: [NSArray arrayWithObject:@"publish_actions"]
                                                   defaultAudience:FBSessionDefaultAudienceEveryone
                                                 completionHandler:^(FBSession *session, NSError *error)
         {
             if (!error)
             {
                 // If permissions granted, publish the story
                 [self publishStory];
             }
         }];
    } else
    {
        // If permissions present, publish the story
        [self publishStory];
    }
}

- (void)shareViaFacebook
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // The user has initiated a login, so call the openSession method
    // and show the login UX if necessary.
    [appDelegate openSessionWithAllowLoginUI:YES];

//    if (!appDelegate.session.isOpen)
//    {
//        if (appDelegate.session.state != FBSessionStateCreated)
//        {
//            // Create a new, logged out session.
//            appDelegate.session = [[FBSession alloc] init];
//        }
//        
//        [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObject:@"publish_actions"] defaultAudience:FBSessionDefaultAudienceEveryone allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
//
//            NSLog (@"ERROR: %@", error);
//            
//            if (appDelegate.session.isOpen)
//            {
//                [self checkPermissionsAndSend];
//            }
//
//        }];
    
        // if the session isn't open, let's open it now and present the login UX to the user
//        [appDelegate.session openWithCompletionHandler:^(FBSession *session,
//                                                         FBSessionState status,
//                                                         NSError *error)
//         {
//             NSLog (@"ERROR: %@", error);
//
//             if (appDelegate.session.isOpen)
//             {
//                 [self checkPermissionsAndSend];
//             }
//             // and here we make sure to update our UX according to the new session state
//         }];
        
//        NSLog (@"Session: %@", appDelegate.session);
        
        
        // if we don't have a cached token, a call to open here would cause UX for login to
        // occur; we don't want that to happen unless the user clicks the login button, and so
        // we check here to make sure we have a token before calling open
//        if (appDelegate.session.state == FBSessionStateCreatedTokenLoaded)
//        {
//            // even though we had a cached token, we need to login to make the session usable
//            [appDelegate.session openWithCompletionHandler:^(FBSession *session,
//                                                             FBSessionState status,
//                                                             NSError *error)
//             {
//                // we recurse here, in order to update buttons and labels
//                 if (appDelegate.session.isOpen)
//                 {
//                     [self checkPermissionsAndSend];
//                 }
//            }];
//        }
//    }
//
    

    
//    [self initialiseFacebookIfNeeded];
//    
//    BOOL isFacebookAuthorised = [self checkIfFacebookIsAuthorised];
//    if (isFacebookAuthorised == YES) {
//        // share
//        [self showFacebookShareDialog];
//    } else {
//        // request authorisation
//        // ask for 'offline access' so that the credentials don't
//        // expire.
//        NSArray *permissions = [NSArray arrayWithObjects:@"offline_access", nil];
//        [FBSession.activeSession authorize:permissions];
//        [self setWaitingForFacebookAuthorisation:YES];
//    }
}

//- (void)initialiseFacebookIfNeeded
//{
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    
//    if (!appDelegate.session.isOpen)
//    {
//        if (appDelegate.session.state != FBSessionStateCreated)
//        {
//            // Create a new, logged out session.
//            appDelegate.session = [[FBSession alloc] init];
//        }
//        
//        // if the session isn't open, let's open it now and present the login UX to the user
//        [appDelegate.session openWithCompletionHandler:^(FBSession *session,
//                                                         FBSessionState status,
//                                                         NSError *error)
//        {
//            // and here we make sure to update our UX according to the new session state
//        }];
//        
//        // if we don't have a cached token, a call to open here would cause UX for login to
//        // occur; we don't want that to happen unless the user clicks the login button, and so
//        // we check here to make sure we have a token before calling open
//        if (appDelegate.session.state == FBSessionStateCreatedTokenLoaded)
//        {
//            // even though we had a cached token, we need to login to make the session usable
//            [appDelegate.session openWithCompletionHandler:^(FBSession *session,
//                                                             FBSessionState status,
//                                                             NSError *error) {
//                // we recurse here, in order to update buttons and labels
//            }];
//        }
//    }
//}
//
//- (void)sessionStateChanged:(FBSession *)session
//                      state:(FBSessionState) state
//                      error:(NSError *)error
//{
//    switch (state) {
//        case FBSessionStateOpen:
//        {
//        }
//            break;
//        case FBSessionStateClosed:
//        case FBSessionStateClosedLoginFailed:
//            // Once the user has logged in, we want them to
//            // be looking at the root view.
//            
//            [FBSession.activeSession closeAndClearTokenInformation];
//            
//            [self showLoginView];
//            break;
//        default:
//            break;
//    }
//    
//    if (error) {
//        UIAlertView *alertView = [[UIAlertView alloc]
//                                  initWithTitle:@"Error"
//                                  message:error.localizedDescription
//                                  delegate:nil
//                                  cancelButtonTitle:@"OK"
//                                  otherButtonTitles:nil];
//        [alertView show];
//    }    
//}
//
//- (void)openSession
//{
//    [FBSession openActiveSessionWithReadPermissions:nil
//                                       allowLoginUI:YES
//                                  completionHandler:
//     ^(FBSession *session,
//       FBSessionState state, NSError *error)
//    {
//         [self sessionStateChanged:session state:state error:error];
//     }];
//}
//
//- (BOOL)checkIfFacebookIsAuthorised
//{
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSString *accessToken = [defaults valueForKey:kFBAccessTokenKey];
//    NSDate *expirationDate = [defaults valueForKey:kFBExpiryDateKey];
//    
//    if (accessToken!=nil && expirationDate!=nil)
//    {
//        [self.facebook setAccessToken:accessToken];
//        [self.facebook setExpirationDate:expirationDate];
//    }
//    
//    return [self.facebook isSessionValid];
//}
//
//- (void)showFacebookShareDialog {    
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    if (self.item.title!=nil) {
//        [params setValue:self.item.title forKey:@"name"];
//        [params setValue:self.item.title forKey:@"caption"];
//    }
//    if (self.item.imageURLString!=nil) {
//        [params setValue:self.item.imageURLString forKey:@"picture"];
//    }
//    if (self.item.description!=nil) {
//        [params setValue:self.item.description forKey:@"description"];
//    }
//    if (self.item.itemURLString!=nil) {
//        [params setValue:self.item.itemURLString forKey:@"link"];
//    }
//    [self.facebook dialog:@"feed" andParams:params andDelegate:self];
//}
//    
//
//#pragma mark - FaceBook Dialog Delegate
//
//- (void)dialog:(FBDialog *)dialog didFailWithError:(NSError *)error {
//    if (self.completionBlock!=nil) {
//        self.completionBlock(BCDResultFailure);
//    }
//}
//
//- (void)dialogDidComplete:(FBDialog *)dialog {
//    if (self.completionBlock!=nil) {
//        self.completionBlock(BCDResultSuccess);
//    }
//}
//
//- (void)dialogDidNotComplete:(FBDialog *)dialog {
//    if (self.completionBlock!=nil) {
//        self.completionBlock(BCDResultFailure);
//    }
//}


#pragma mark - Twitter

- (void)shareViaTwitter
{    
    NSMutableString *tweetText = [NSMutableString string];
    
    [tweetText appendString:self.item.title];
    
    if (self.item.shortDescription!=nil) {
        [tweetText appendFormat:@" %@", self.item.shortDescription];
    }
    
    if (self.hashTag!=nil) {
        [tweetText appendFormat:@" #%@", self.hashTag];
    }
            
    TWTweetComposeViewController *tweetComposeViewController = [[TWTweetComposeViewController alloc] init];
    [tweetComposeViewController setInitialText:tweetText];
    [tweetComposeViewController addImage:[UIImage imageNamed:@"icon512.png"]];
    [tweetComposeViewController addURL:[NSURL URLWithString:self.item.itemURLString]];
    [self.rootViewController presentModalViewController:tweetComposeViewController animated:YES];
    
    [tweetComposeViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
        switch (result) {
            case TWTweetComposeViewControllerResultDone:
                if (self.completionBlock!=nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{            
                        self.completionBlock(BCDResultSuccess);
                    });
                }
                break;
                
            default:
                if (self.completionBlock!=nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{            
                        self.completionBlock(BCDResultFailure);
                    });
                    
                }
                break;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{            
            [self.rootViewController dismissViewControllerAnimated:NO completion:nil];
        });
    }];
}

@end
