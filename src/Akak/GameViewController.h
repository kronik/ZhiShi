//
//  GameViewController.h
//  witrapp.ru
//
//  Created by Dmitry Klimkin on 19/11/12.
//
//

#import <UIKit/UIKit.h>
#import "UITableView+Toches.h"
#import <MessageUI/MessageUI.h>
#import "BasicViewController.h"

@interface GameViewController : BasicViewController <UITableViewDataSource, UITableViewDelegate,
                                                     MFMailComposeViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *ruWords;

- (void)addBackButton;

#ifdef LITE_VERSION

- (IBAction)buyFullVerButtonClicked: (UIButton*)button;
#endif

@end
